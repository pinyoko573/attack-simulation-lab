# ---------- Sentinel schedule rules: Potential Kerberoasting ----------
resource "azurerm_sentinel_alert_rule_scheduled" "log_rule-potential_kerberoasting" {
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.log_sentinel.workspace_id
  name = "potential_kerberoasting"
  display_name = "Potential Kerberoasting"
  description = "A Kerberos ticket-granting service (TGS) for a Service Principal Name (SPN) was requested from the domain controller. The password hash in the requested ticket may be obtained to get the plaintext password of the service account through brute force techniques. Attackers usually request for TGS tickets with RC4 encryption standard due to weak cryptography algorithm."
  severity = "Low"
  enabled = true
  query = <<EOF
  Event
  | where EventID == 4769
  | extend CleanXml = replace(@'\s+xmlns="[^"]*"', "", EventData)
  | extend Parsed = parse_xml(CleanXml)
  | mv-expand DataNode = Parsed.DataItem.EventData.Data
  | extend Field = tostring(DataNode['@Name']),
            Value = tostring(DataNode['#text'])
  | summarize Bag = make_bag(pack(Field, Value)) by TimeGenerated, EventID
  | evaluate bag_unpack(Bag)
  | extend TicketEncryptionType = column_ifexists("TicketEncryptionType", '')
  | where TicketEncryptionType == "0x17"
  | extend TargetUserName = column_ifexists("TargetUserName", '')
  | extend TargetDomainName = column_ifexists("TargetDomainName", '')
  | extend IpAddress = column_ifexists("IpAddress", '')
  | extend ServiceName = column_ifexists("ServiceName", '')
  | extend userName = split(TargetUserName, '@')[0]
  | extend IpAddress_V4 = extract(@"(\d+\.\d+\.\d+\.\d+)", 1, IpAddress)
  EOF
  query_frequency = "PT10M"
  query_period = "PT1H"
  suppression_duration = "PT5H"
  suppression_enabled = false
  tactics = ["CredentialAccess"]
  techniques = ["T1558"]
  trigger_operator = "GreaterThan"
  trigger_threshold = 0
  entity_mapping {
    entity_type = "Account"
    field_mapping {
      column_name = "TargetDomainName"
      identifier = "NTDomain"
    }
    field_mapping {
      column_name = "userName"
      identifier = "Name"
    }
  }
  entity_mapping {
    entity_type = "IP"
    field_mapping {
      column_name = "IpAddress_V4"
      identifier = "Address"
    }
  }
  event_grouping {
    aggregation_method = "SingleAlert"
  }
  incident {
    create_incident_enabled = true
    grouping {
      by_alert_details = []
      by_custom_details = []
      by_entities = []
      enabled = false
      entity_matching_method = "AllEntities"
      lookback_duration = "PT5H"
      reopen_closed_incidents = false
    }
  }
}

# ---------- Sentinel schedule rules: Potential AS-REP Roasting ----------
resource "azurerm_sentinel_alert_rule_scheduled" "log_rule-potential_asreproasting" {
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.log_sentinel.workspace_id
  name = "potential_asreproasting"
  display_name = "Potential AS-REP Roasting"
  description = "When an account has enabled 'Do not require Kerberos preauthentication', an attacker can request for a Kerberos ticket-granting ticket (TGT) for that account without pre-authentication. The password hash in the requested ticket may be obtained to get the plaintext password of the account through brute force techniques. Attackers usually request for TGT tickets with RC4 encryption standard due to weak cryptography algorithm."
  severity = "Low"
  enabled = true
  query = <<EOF
  Event
  | where EventID == 4768
  | extend CleanXml = replace(@'\s+xmlns="[^"]*"', "", EventData)
  | extend Parsed = parse_xml(CleanXml)
  | mv-expand DataNode = Parsed.DataItem.EventData.Data
  | extend
      Field = tostring(DataNode['@Name']),
      Value = tostring(DataNode['#text'])
  | summarize Bag = make_bag(pack(Field, Value)) by TimeGenerated, EventID
  | evaluate bag_unpack(Bag)
  | extend PreAuthType = column_ifexists("PreAuthType", '')
  | where PreAuthType == "0"
  | extend SessionKeyEncryptionType = column_ifexists("SessionKeyEncryptionType", '')
  | where SessionKeyEncryptionType == "0x17"
  | extend ServiceName = column_ifexists("ServiceName", '')
  | where ServiceName == "krbtgt"
  | extend TargetUserName = column_ifexists("TargetUserName", '')
  | extend TargetDomainName = column_ifexists("TargetDomainName", '')
  | extend IpAddress = column_ifexists("IpAddress", '')
  | extend userName = split(TargetUserName, '@')[0]
  | extend IpAddress_V4 = extract(@"(\d+\.\d+\.\d+\.\d+)", 1, IpAddress)
  EOF
  query_frequency = "PT10M"
  query_period = "PT1H"
  suppression_duration = "PT5H"
  suppression_enabled = false
  tactics = ["CredentialAccess"]
  techniques = ["T1558"]
  trigger_operator = "GreaterThan"
  trigger_threshold = 0
  entity_mapping {
    entity_type = "Account"
    field_mapping {
      column_name = "TargetDomainName"
      identifier = "NTDomain"
    }
    field_mapping {
      column_name = "userName"
      identifier = "Name"
    }
  }
  entity_mapping {
    entity_type = "IP"
    field_mapping {
      column_name = "IpAddress_V4"
      identifier = "Address"
    }
  }
  event_grouping {
    aggregation_method = "SingleAlert"
  }
  incident {
    create_incident_enabled = true
    grouping {
      by_alert_details = []
      by_custom_details = []
      by_entities = []
      enabled = false
      entity_matching_method = "AllEntities"
      lookback_duration = "PT5H"
      reopen_closed_incidents = false
    }
  }
}

# ---------- Sentinel schedule rules: Port Scanning on Azure Public IP ----------
resource "azurerm_sentinel_alert_rule_scheduled" "log_rule-port_scanning_on_azure_public_ip" {
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.log_sentinel.workspace_id
  name = "port_scanning_on_azure_public_ip"
  display_name = "Port Scanning on Azure Public IP"
  description = "An attacker has scanned more than 10 unique port numbers within 5 minutes on an Azure Public IP."
  severity = "Low"
  enabled = true
  query = <<EOF
  NTANetAnalytics
  | extend src_ip = coalesce(SrcIp, split(SrcPublicIps, '|')[0])
  | summarize no_of_ports=dcount(DestPort) by src_ip, bin(FlowStartTime, 5m)
  | where no_of_ports > 10
  EOF
  query_frequency = "PT10M"
  query_period = "PT10M"
  suppression_duration = "PT5H"
  suppression_enabled = false
  tactics = ["Discovery"]
  techniques = ["T1423"]
  trigger_operator = "GreaterThan"
  trigger_threshold = 0
  entity_mapping {
    entity_type = "IP"
    field_mapping {
      column_name = "src_ip"
      identifier = "Address"
    }
  }
  event_grouping {
    aggregation_method = "SingleAlert"
  }
  incident {
    create_incident_enabled = true
    grouping {
      by_alert_details = []
      by_custom_details = []
      by_entities = []
      enabled = false
      entity_matching_method = "AllEntities"
      lookback_duration = "PT5H"
      reopen_closed_incidents = false
    }
  }
}

# ---------- Sentinel schedule rules: Actions performed on Azure Resource by Service Principal ----------
resource "azurerm_sentinel_alert_rule_scheduled" "log_rule-successful_actions_performed_on_azure_resource_by_sp" {
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.log_sentinel.workspace_id
  name = "successful_actions_performed_on_azure_resource_by_sp"
  display_name = "Successful actions performed on Azure Resource by Service Principal"
  description = "Successful actions (create, delete, update) have been performed on Azure Resources by a Service Principal that was created in App Registrations."
  severity = "High"
  enabled = true
  query = <<EOF
  AzureActivity
  | extend principalType = extract_json("$.evidence.principalType", Authorization)
  | where principalType == "ServicePrincipal" and ActivityStatusValue == "Success"
  | extend appId = extract_json("$.appid", Claims)
  | where appId !in ((_GetWatchlist("azure_app_ids") | project appId))
  | extend message = extract_json("$.message", Properties)
  | extend entity = extract_json("$.entity", Properties)
  | extend operation = strcat(message, ' ', entity)
  | summarize operations = strcat_array(make_list(operation), ',') by appId
  EOF
  query_frequency = "PT10M"
  query_period = "PT10M"
  suppression_duration = "PT5H"
  suppression_enabled = false
  tactics = ["DefenseEvasion"]
  techniques = ["T1578"]
  trigger_operator = "GreaterThan"
  trigger_threshold = 0
  entity_mapping {
    entity_type = "Account"
    field_mapping {
      column_name = "appId"
      identifier = "AadUserId"
    }
  }
  event_grouping {
    aggregation_method = "SingleAlert"
  }
  incident {
    create_incident_enabled = true
    grouping {
      by_alert_details = []
      by_custom_details = []
      by_entities = []
      enabled = false
      entity_matching_method = "AllEntities"
      lookback_duration = "PT5H"
      reopen_closed_incidents = false
    }
  }

  depends_on = [ azurerm_sentinel_watchlist_item.log_watchlist_item-azure_app_ids ]
}

# ---------- Sentinel schedule rules: Failed Request to access Key Vault by Service Principal ----------
resource "azurerm_sentinel_alert_rule_scheduled" "log_rule-failed_request_to_access_key_vault_by_sp" {
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.log_sentinel.workspace_id
  name = "failed_request_to_access_key_vault_by_sp"
  display_name = "Failed request to access Key Vault by Service Principal"
  description = "A HTTP Request was made to access the Key Vault by a Service Principal, but its response was returned with a code other than 200 OK."
  severity = "Medium"
  enabled = true
  query = <<EOF
  AzureDiagnostics
  | where identity_claim_idtyp_s == "app" and ResourceProvider == "MICROSOFT.KEYVAULT"
  | where httpStatusCode_d != 200
  EOF
  query_frequency = "PT10M"
  query_period = "PT10M"
  suppression_duration = "PT5H"
  suppression_enabled = false
  tactics = ["CredentialAccess"]
  techniques = ["T1555"]
  trigger_operator = "GreaterThan"
  trigger_threshold = 0
  entity_mapping {
    entity_type = "Account"
    field_mapping {
      column_name = "identity_claim_appid_g"
      identifier = "AadUserId"
    }
  }
  event_grouping {
    aggregation_method = "SingleAlert"
  }
  incident {
    create_incident_enabled = true
    grouping {
      by_alert_details = []
      by_custom_details = []
      by_entities = []
      enabled = false
      entity_matching_method = "AllEntities"
      lookback_duration = "PT5H"
      reopen_closed_incidents = false
    }
  }
}