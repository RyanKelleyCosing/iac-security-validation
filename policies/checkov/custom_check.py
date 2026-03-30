"""
Custom Checkov policy for Azure resource naming conventions.
Demonstrates policy-as-code for organizational standards.
"""

from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from checkov.common.models.enums import CheckResult, CheckCategories


class AzureResourceNamingConvention(BaseResourceCheck):
    """
    Ensure Azure resources follow naming convention:
    - Storage accounts: st<project><env><random>
    - Key Vaults: kv-<project>-<env>-<random>
    - Resource Groups: rg-<project>-<env>
    """

    def __init__(self):
        name = "Ensure Azure resources follow naming convention"
        id = "CKV_CUSTOM_AZURE_1"
        supported_resources = [
            "azurerm_storage_account",
            "azurerm_key_vault",
            "azurerm_resource_group"
        ]
        categories = [CheckCategories.CONVENTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
        Validates resource naming follows convention.
        """
        resource_name = conf.get("name", [""])[0] if isinstance(conf.get("name"), list) else conf.get("name", "")
        
        # Storage account naming: starts with 'st'
        if self.resource_type == "azurerm_storage_account":
            if resource_name.startswith("st"):
                return CheckResult.PASSED
            return CheckResult.FAILED
        
        # Key Vault naming: starts with 'kv-'
        if self.resource_type == "azurerm_key_vault":
            if resource_name.startswith("kv-"):
                return CheckResult.PASSED
            return CheckResult.FAILED
        
        # Resource Group naming: starts with 'rg-'
        if self.resource_type == "azurerm_resource_group":
            if resource_name.startswith("rg-"):
                return CheckResult.PASSED
            return CheckResult.FAILED
        
        return CheckResult.PASSED


class RequireEnvironmentTag(BaseResourceCheck):
    """
    Ensure all resources have an 'Environment' tag for cost allocation.
    """

    def __init__(self):
        name = "Ensure resources have Environment tag"
        id = "CKV_CUSTOM_AZURE_2"
        supported_resources = ["*"]  # All resources
        categories = [CheckCategories.GENERAL_SECURITY]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
        Check if Environment tag exists.
        """
        tags = conf.get("tags", {})
        if isinstance(tags, list) and len(tags) > 0:
            tags = tags[0]
        
        if tags and "Environment" in tags:
            return CheckResult.PASSED
        
        return CheckResult.FAILED


# Register checks
check_naming = AzureResourceNamingConvention()
check_env_tag = RequireEnvironmentTag()

