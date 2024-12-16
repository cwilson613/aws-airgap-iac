import json
import os

def main():
    outputs_file = '../terraform/outputs.json'
    inventory_file = 'ansible_inventory.ini'

    with open(outputs_file) as f:
        outputs = json.load(f)

    # Extract the ansible inventory value
    ansible_inventory = outputs['ansible_inventory']['value']

    with open(inventory_file, 'w') as f:
        # Write sections for each component
        for component, data in ansible_inventory.items():
            f.write(f'[{component}]\n')
            for host in data['hosts']:
                f.write(f'{host}\n')
            f.write('\n')  # Add spacing between sections

    print(f"Ansible inventory written to {inventory_file}")

if __name__ == '__main__':
    main()

# import json
# import os

# def main():
#     outputs_file = 'terraform/outputs.json'
#     inventory_file = 'ansible_inventory.ini'

#     with open(outputs_file) as f:
#         outputs = json.load(f)

#     private_ips = outputs['private_ips']['value']

#     with open(inventory_file, 'w') as f:
#         f.write('[confluent_nodes]\n')
#         for ip in private_ips:
#             f.write(f'{ip}\n')

#     print(f"Ansible inventory written to {inventory_file}")

# if __name__ == '__main__':
#     main()