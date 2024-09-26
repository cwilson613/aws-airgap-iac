#!/bin/bash

# Variables
CONFLUENT_VERSION="7.7.1"
ANSIBLE_ROLES_VERSION="7.7.0-post" # Adjusted based on available tags
DOWNLOAD_DIR="./confluent-offline-install"
ANSIBLE_COLLECTION_DIR="$DOWNLOAD_DIR/ansible"
GIT_REPO_DIR="$ANSIBLE_COLLECTION_DIR/confluent-platform-ansible"
RPM_DIR="$DOWNLOAD_DIR/rpms"
JAR_DIR="$DOWNLOAD_DIR/jars"
PIP_DIR="$DOWNLOAD_DIR/wheelhouse"
CONNECTORS_DIR="$DOWNLOAD_DIR/connectors"

CDN_URL="https://d2p6pa21dvn84.cloudfront.net/api/plugins/confluentinc"

# Define packages to download from standard Oracle Linux repos
PACKAGES=(
    oracle-epel-release-el9
    ansible-core
    tar
    python3
    python3-pip
    git
    unzip
)

# Define packages to download from confluent repo
CONFLUENT_RPMS=(
    confluent-platform
    confluent-security
    nc
    ansible
    createrepo
    java-11-openjdk
    java-17-openjdk
)

# Create download directory
mkdir -p "$DOWNLOAD_DIR"

# Pre-Prereqs for distro node
sudo yum update -y
sudo yum install -y "${PACKAGES[@]}"

# Step 1: Clone cp-ansible repository and build Ansible collection
echo "Cloning cp-ansible repository..."
mkdir -p "$ANSIBLE_COLLECTION_DIR"
git clone https://github.com/confluentinc/cp-ansible "$GIT_REPO_DIR"
pushd "$GIT_REPO_DIR"
echo "Checking out the $ANSIBLE_ROLES_VERSION branch..."
git fetch
git checkout "$ANSIBLE_ROLES_VERSION"
echo "Building Ansible collection..."
ansible-galaxy collection build --force
popd

# Copy the built collection tarball to the download directory
pwd
echo "$GIT_REPO_DIR"
echo $(ls $GIT_REPO_DIR)
cp "$GIT_REPO_DIR/confluent-platform-7.7.0.tar.gz" "$ANSIBLE_COLLECTION_DIR"
rm -rf $GIT_REPO_DIR

# Download the remaining collections
pushd $ANSIBLE_COLLECTION_DIR

# ansible.posix (provides sysctl)
curl -LO https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/ansible-posix-1.6.0.tar.gz
#ansible-galaxy collection download ansible.posix

# Ansible bugs in galaxy versions, just download the tarball and be done with it
curl -LO https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/community-general-9.4.0.tar.gz


# Return to the root directory
popd

# Step 2: Download cryptography pip package
echo "Downloading cryptography pip package..."
mkdir -p "$PIP_DIR"
pip3 download cryptography -d "$PIP_DIR"

# Step 3: Download epel-release package
echo "Downloading RPMs..."
mkdir -p "$RPM_DIR"

# Grab supplemental RPMs and their dependencies
yumdownloader --resolve --installroot=/tmp/ --destdir="$RPM_DIR" "${PACKAGES[@]}"

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

# Download packages and dependencies
mkdir -p "$RPM_DIR"

# Clean YUM cache
yum clean all
yumdownloader -c "$DOWNLOAD_DIR/confluent.repo" --installroot=/tmp/ --resolve --destdir="$RPM_DIR" "${CONFLUENT_RPMS[@]}"

# Step 6: Download monitoring JARs (Optional)
echo "Downloading monitoring JARs..."
mkdir -p "$JAR_DIR"

curl -L -o "$JAR_DIR/jolokia-jvm-1.6.2-agent.jar" \
  "https://repo1.maven.org/maven2/org/jolokia/jolokia-jvm/1.6.2/jolokia-jvm-1.6.2-agent.jar"

curl -o "$JAR_DIR/jmx_prometheus_javaagent-0.12.0.jar" \
  "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar"

# Step 7: Download .zip files for Confluent connectors (CDN nonsense means URLs may break in the future)
mkdir -p $CONNECTORS_DIR
pushd $CONNECTORS_DIR
curl -LO "$CDN_URL/kafka-connect-syslog/versions/1.5.9/confluentinc-kafka-connect-syslog-1.5.9.zip"
curl -LO "$CDN_URL/kafka-connect-s3/versions/10.5.15/confluentinc-kafka-connect-s3-10.5.15.zip"
curl -LO "$CDN_URL/kafka-connect-elasticsearch/versions/14.1.1/confluentinc-kafka-connect-elasticsearch-14.1.1.zip"
curl -LO "$CDN_URL/kafka-connect-jdbc/versions/10.7.12/confluentinc-kafka-connect-jdbc-10.7.12.zip"
popd


# Step 8: Bundle everything into a tarball
echo "Creating arigap tarball..."
tar -czvf "confluent-offline-install-$CONFLUENT_VERSION.tar.gz" -C "$DOWNLOAD_DIR" .

echo "Done. The offline dependency tarball is 'confluent-offline-install-$CONFLUENT_VERSION.tar.gz'"