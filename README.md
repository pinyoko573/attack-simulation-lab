# Attack Simulation Lab

## Overview

The purpose of this lab is to simulate and detect real-world attack scenarios in a controlled environment to strengthen on-premise and cloud security practices through automation tools. This has also benefited me in:
- Translating concepts from the AZ-500 and SC-200 Microsoft Azure certification exams into hands-on practice
- Applying Infrastructure as Code (IaC) principles using Terraform and Ansible.
- Learning new technologies e.g. Azure OpenAI (coming soon)

## Features

![Diagram](https://github.com/user-attachments/assets/859cdd43-ddc8-4a77-bd0a-d4bdaf069690)

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
| Sentinel                  | sentinel       | Create Log Analytics Workspace, Onboard to Sentinel and import analytic rules and watchlist | ❗ |
| Sentinel - Azure Activity | -              | Enable Azure Activity in Data Connector to ingest activity log                              | ❌ |
| Azure Arc                 | arc            | Connect Windows/Linux machine to Arc-enabled server and enable Azure Monitor Agent          | ✅ |
| Virtual Machine           | vm             | Create Virtual Machine, Virtual Network, Public IP, Network Security Group                  | ✅ |
| Virtual Network Flow Logs | vnet_flow_logs | Create flow logs for logging network traffic                                                | ✅ |
| Key Vault                 | keyvault       | Create Key Vault, store a secret and enable audit log in Diagnostic setting                 | ❗ |

## Attack Simulations

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

## Instructions

WIP