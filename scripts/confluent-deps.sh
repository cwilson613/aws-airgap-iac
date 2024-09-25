#!/bin/bash

# Variables
CONFLUENT_VERSION="7.7.1"
ANSIBLE_ROLES_VERSION="7.7.0-post" # Adjusted based on available tags
DOWNLOAD_DIR="./confluent_offline_install"
ANSIBLE_COLLECTION_DIR="$DOWNLOAD_DIR/ansible_collections/confluent"

# Create download directory
mkdir -p "$DOWNLOAD_DIR"

# Pre-Prereqs for distro node
sudo yum update -y
sudo yum install \
    yum-utils \
    ansible-core \
    tar \
    python3 \
    python3-pip \
    git -y

# Step 1: Clone cp-ansible repository and build Ansible collection
echo "Cloning cp-ansible repository..."
mkdir -p "$ANSIBLE_COLLECTION_DIR"
git clone https://github.com/confluentinc/cp-ansible "$ANSIBLE_COLLECTION_DIR/platform"

echo "Checking out the $ANSIBLE_ROLES_VERSION branch..."
cd "$ANSIBLE_COLLECTION_DIR/platform"
git fetch
git checkout "$ANSIBLE_ROLES_VERSION"

echo "Building Ansible collection..."
ansible-galaxy collection build

# Copy the built collection tarball to the download directory
cp confluent-platform-*.tar.gz "$DOWNLOAD_DIR/"

# Return to the root directory
cd -

# Step 2: Download cryptography pip package
echo "Downloading cryptography pip package..."
mkdir -p "$DOWNLOAD_DIR/pip_packages"
pip3 download cryptography -d "$DOWNLOAD_DIR/pip_packages"

# Step 3: Download epel-release package
echo "Downloading epel-release package..."
mkdir -p "$DOWNLOAD_DIR/extra_rpms"
yumdownloader --resolve --destdir="$DOWNLOAD_DIR/extra_rpms" \
    epel-release \
    ansible-core \
    tar \
    python3 \
    python3-pip \
    git
    

# Step 4: Create confluent.repo file
echo "Creating confluent.repo file..."
cat << EOF > "$DOWNLOAD_DIR/confluent.repo"
[Confluent.dist]
baseurl = https://packages.confluent.io/rpm/7.7
enabled = 1
gpgcheck = 1
gpgkey = https://packages.confluent.io/rpm/7.7/archive.key
name = Confluent repository (dist)

[Confluent]
baseurl = https://packages.confluent.io/rpm/7.7
enabled = 1
gpgcheck = 1
gpgkey = https://packages.confluent.io/rpm/7.7/archive.key
name = Confluent repository
EOF

# Step 5: Download Confluent Platform RPMs and other required packages
echo "Downloading Confluent Platform RPMs and dependencies..."

# Ensure yum-utils is installed
if ! command -v yumdownloader &> /dev/null
then
    echo "Installing yum-utils..."
    sudo yum install -y yum-utils
fi

# Clean YUM cache
yum clean all

# Define packages to download
PACKAGES=(
    confluent-platform
    confluent-security
    nc
    ansible
    createrepo
    java-11-openjdk
    java-17-openjdk
)

# Download packages and dependencies
mkdir -p "$DOWNLOAD_DIR/rpms"
yumdownloader -c "$DOWNLOAD_DIR/confluent.repo" --resolve --destdir="$DOWNLOAD_DIR/rpms" "${PACKAGES[@]}"

# Step 6: Download monitoring JARs (Optional)
echo "Downloading monitoring JARs..."
mkdir -p "$DOWNLOAD_DIR/monitoring_jars"

curl -L -o "$DOWNLOAD_DIR/monitoring_jars/jolokia-jvm-1.6.2-agent.jar" \
  "https://repo1.maven.org/maven2/org/jolokia/jolokia-jvm/1.6.2/jolokia-jvm-1.6.2-agent.jar"

curl -o "$DOWNLOAD_DIR/monitoring_jars/jmx_prometheus_javaagent-0.12.0.jar" \
  "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar"

# Step 7: Bundle everything into a tarball
echo "Creating tarball..."
tar -czvf "confluent_offline_install_$CONFLUENT_VERSION.tar.gz" -C "$DOWNLOAD_DIR" .

echo "Done. The offline installer is 'confluent_offline_install_$CONFLUENT_VERSION.tar.gz'"