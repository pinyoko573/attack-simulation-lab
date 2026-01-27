# Attack Simulation Lab

![Diagram](https://github.com/user-attachments/assets/859cdd43-ddc8-4a77-bd0a-d4bdaf069690)

Simulate and detect real-world attack scenarios in a controlled environment to strengthen on-premise and cloud security practices through automation tools.

This project has helped me:
- Apply concepts from the AZ-500 and SC-200 Microsoft Azure certification exams through hands-on practice
- Implement Infrastructure as Code (IaC) principles using Terraform and Ansible
- Explore emerging technologies such as Azure OpenAI (coming soon)

## Features

List of infrastructures and attacks simulated:
1. Active Directory
  - Kerberoasting
  - AS-REP Roasting
2. Azure Services
  - Port Scanning on *VM Public IP Address*
  - Modify Cloud Infrastructure Resources through *Service Principal secret*
  - Steal Credentials from *Key Vault*

All of these attacks are audited into logs and forwarded to **Microsoft Sentinel**.

## Infrastructure Setup

Setup is done through Ansible (for Active Directory) and Terraform (for Azure Services).

### Ansible

Active
| Platform | Task                  | Description                                                   | Automated |
| -------- | --------------------- | ------------------------------------------------------------- | --------- |
| Windows  | win_changehostname    | Set WinRM service to Auto and changes the host name           | ✅ |
| Windows  | win_azurearc          | Onboard machine to Azure Arc                                  | ✅ |
| Windows  | win_joindomain        | Join an Active Directory domain                               | ✅ |
| Windows  | win_createdomain      | Create an Active Directory Domain Controller as a new forest  | ✅ |
| Windows  | win_eventcollector    | Configure Windows Event Collector                             | ✅ |
| Windows  | win_eventforwarder    | Provide GPO settings to configure Windows Event Forwarder     | ❌ |

Inactive, for future use
| Platform | Task                  | Description                                                   | Automated |
| -------- | --------------------- | ------------------------------------------------------------- | --------- |
| Ubuntu   | ubuntu_changehostname | Change the host name                                          | ✅ |
| Ubuntu   | ubuntu_azurearc       | Onboard machine to Azure Arc                                  | ✅ |
| Ubuntu   | ubuntu_joindomain     | Join an Active Directory domain                               | ✅ |
| Ubuntu   | ubuntu_rsyslog        | Provide information on installing rsyslog                     | ❌ |
| Ubuntu   | ubuntu_mysql          | Install MySQL server                                          | ✅ |
| Ubuntu   | ubuntu_wordpress      | Install WordPress                                             | ✅ |

### Terraform

| Service                   | Module         | Description                                                                                 | Automated |
| ------------------------- | -------------- | ------------------------------------------------------------------------------------------- | --------- |
| Sentinel                  | sentinel       | Create Log Analytics Workspace, Onboard to Sentinel and import analytic rules and watchlist | ⚠️ <sup>1</sup> |
| Sentinel - Azure Activity | -              | Enable Azure Activity in Data Connector to ingest activity log                              | ❌ <sup>1</sup> |
| Azure Arc                 | arc            | Connect Windows/Linux machine to Arc-enabled server and enable Azure Monitor Agent          | ✅ |
| Virtual Machine           | vm             | Create Virtual Machine, Virtual Network, Public IP, Network Security Group                  | ✅ |
| Virtual Network Flow Logs | vnet_flow_logs | Create flow logs for logging network traffic                                                | ✅ |
| Key Vault                 | keyvault       | Create Key Vault and enable audit log in Diagnostic setting                                 | ✅ |

- ⚠️<sup>1</sup> Watchlist is created but you will need to import the data manually (Ignore this if you don't want to simulate *Modify Cloud Infrastructure Resources* attack)
- ❌<sup>1</sup> There is no Terraform support for Sentinel Content Hub. You will need to install in Content Hub, go to Data Connector and create the built-in policy assignment to ingest logs.

## Attack Simulations

### Active Directory

1. Kerberoasting
  - Description
    - Kerberoasting is an attack where an attacker targets on service accounts by:
      1. Enumerate service accounts with SPNs from the domain controller.
      2. Using the authenticated user's ticket-granting ticket (TGT) to request for a Kerberos ticket-granting service (TGS) for every SPN, with the TGS's encryption type to be RC4, a weak cryptography algorithm.
      3. Attempt to brute force the password hash in TGS to obtain the plaintext password of the service account.
  - Assumptions
    - Attacker is within the AD network and has an authenticated user account.
  - Detections
    - Look for Windows events with ID 4769, with the ticket encryption type RC4 (0x17).

2. AS-REP Roasting
  - Description
    - When an account has enabled 'Do not require Kerberos preauthentication', the domain controller will return a AS-REP message containing the TGT, where the TGT contains the password hash. An attacker can retrieve the plaintext password by:
      1. Enumerate accounts with the DONT_REQ_PREAUTH flag set on the userAccountControl attribute.
      2. Sends a Authentication Server Request (AS-REQ) to the domain controller, in which a Authentication Server Response (AS-REP) message will be returned to the attacker without pre-authentication validation.
      3. Attempt to brute force the password hash in TGT to obtain the plaintext password of the account.
 - Assumptions
    - Attacker is within the AD network and has an authenticated user account.
  - Detections
    - Look for Windows events with ID 4768, with the ticket encryption type RC4 (0x17).

### Azure Services

1. Port Scanning on *VM Public IP Address*

2. Modify Cloud Infrastructure Resources through *Service Principal secret*

3. Steal Credentials from *Key Vault*

WIP

## Instructions

### Ansible

To add or remove tasks, modify the tasks of the host groups in *site.yml* to your needs.

Be sure to modify the hosts and variables in ***inventory.yml*** and ***/group_vars*** before running!

To run, enter `ansible-playbook site.yml -i inventory.yml [-l win_dc]`

#### For Windows machines

1. To perform tasks on a Windows machine, enable the Windows Remote Management (WinRM) protocol by running `winrm quickconfig`.
2. A password is mandatory for authentication using WinRM. `Ctrl+Alt+Delete` -> Change password to assign a password.
3. Ensure that Network Location for the network adapter is set to **Private** to prevent any Firewall issues.
4. (For Windows Server) If you encounter a SID duplicate error when joining a domain, run `%WINDIR%\system32\sysprep\sysprep.exe /generalize /restart /oobe /quiet`

#### For Linux machines

1. Generate a SSH key pair for installing public key on control node and private key on managed node using `ssh-keygen -f ~/.ssh/<control node computer name> -t ed25519`
2. Copy the SSH public key to the control node: `ssh-copy-id -i ~/.ssh/control_node.pub ubuntu@192.168.100.1`
3. Start the ssh-agent program and copy the private key to the agent in order to skip the passphrase prompt `ssh-agent $SHELL && ssh-add ~/.ssh/control_node`

### Terraform

Make sure to [create a Service Principal and set the credentials in environment variables](https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build) to provision the resources.

To provision, enter:
```
terraform init
terraform apply [-target module.sentinel_vnet_flow_logs]
```