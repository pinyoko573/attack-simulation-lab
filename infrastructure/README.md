# Setup Instructions

## Ansible
Modify the hosts and variables in ***inventory.yml*** and ***/group_vars*** before running.

To run, `ansible-playbook site.yml -i inventory.yml [-l win_dc]`.

### First-time setup

Windows
1. Enable the Windows Remote Management (WinRM) protocol by running `winrm quickconfig`.
2. A password is mandatory for authentication using WinRM. `Ctrl+Alt+Delete` -> Change password to assign a password.
3. Ensure that Network Location for the network adapter is set to **Private** to prevent any Firewall issues.
4. (For Windows Server) If encountering a SID duplicate error when joining a domain, run `%WINDIR%\system32\sysprep\sysprep.exe /generalize /restart /oobe /quiet`

Ubuntu
1. Generate a SSH key pair for installing public key on control node and private key on managed node using `ssh-keygen -f ~/.ssh/<control node computer name> -t ed25519`
2. Copy the SSH public key to the control node: `ssh-copy-id -i ~/.ssh/control_node.pub ubuntu@192.168.100.1`
3. Start the ssh-agent program and copy the private key to the agent in order to skip the passphrase prompt `ssh-agent $SHELL && ssh-add ~/.ssh/control_node`

## Terraform

Azure
1. [Create a Service Principal and set the credentials in environment variables](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build) to provision the resources in Azure.

To provision:
```bash
terraform init
terraform apply [-target module.sentinel_vnet_flow_logs]
```