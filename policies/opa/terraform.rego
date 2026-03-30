# OPA/Rego Policy for Terraform Plans
# Custom policies for infrastructure compliance

package terraform

import future.keywords.in

# Deny rules - these will fail the pipeline if violated

# Rule: Storage accounts must have HTTPS only
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.after.enable_https_traffic_only == false
    msg := sprintf("Storage account '%s' must enforce HTTPS traffic only", [resource.address])
}

# Rule: Storage accounts must use TLS 1.2+
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.after.min_tls_version != "TLS1_2"
    msg := sprintf("Storage account '%s' must use TLS 1.2 or higher", [resource.address])
}

# Rule: Key Vaults must enable RBAC authorization
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_key_vault"
    resource.change.after.enable_rbac_authorization == false
    msg := sprintf("Key Vault '%s' must use RBAC authorization", [resource.address])
}

# Rule: Key Vaults must enable soft delete
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_key_vault"
    resource.change.after.soft_delete_retention_days < 7
    msg := sprintf("Key Vault '%s' must have soft delete enabled with at least 7 days retention", [resource.address])
}

# Rule: Storage accounts must not allow public blob access
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.after.allow_nested_items_to_be_public == true
    msg := sprintf("Storage account '%s' must not allow public blob access", [resource.address])
}

# Rule: All resources must have required tags
required_tags := ["Environment", "ManagedBy"]

deny[msg] {
    resource := input.resource_changes[_]
    resource.change.actions[_] == "create"
    tags := resource.change.after.tags
    tag := required_tags[_]
    not tags[tag]
    msg := sprintf("Resource '%s' is missing required tag: %s", [resource.address, tag])
}

# Rule: Production resources must have specific configurations
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_key_vault"
    resource.change.after.tags.Environment == "prod"
    resource.change.after.purge_protection_enabled == false
    msg := sprintf("Production Key Vault '%s' must have purge protection enabled", [resource.address])
}

# Warning rules - these will be reported but won't fail the pipeline
warn[msg] {
    resource := input.resource_changes[_]
    resource.type == "azurerm_storage_account"
    resource.change.after.account_replication_type == "LRS"
    msg := sprintf("Storage account '%s' uses LRS replication - consider GRS for better durability", [resource.address])
}

warn[msg] {
    resource := input.resource_changes[_]
    resource.change.actions[_] == "delete"
    msg := sprintf("Resource '%s' will be deleted - please confirm this is intentional", [resource.address])
}

