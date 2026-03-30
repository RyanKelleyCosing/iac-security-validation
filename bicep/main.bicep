// IaC Security & Validation Pipeline - Sample Bicep Configuration
// Demonstrates secure infrastructure patterns

@description('Environment name')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Azure region')
param location string = resourceGroup().location

// Variables
var suffix = uniqueString(resourceGroup().id)
var storageAccountName = 'stiacsec${environment}${suffix}'
var keyVaultName = 'kv-iacsec-${environment}-${suffix}'

// Common tags
var commonTags = {
  Environment: environment
  ManagedBy: 'Bicep'
  Project: 'IaC-Security-Demo'
}

// Secure Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: commonTags
  sku: {
    name: 'Standard_GRS' // Geo-redundant
  }
  kind: 'StorageV2'
  properties: {
    // Security: HTTPS only
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    
    // Security: Disable public blob access
    allowBlobPublicAccess: false
    
    // Security: Enable infrastructure encryption
    encryption: {
      services: {
        blob: { enabled: true }
        file: { enabled: true }
        queue: { enabled: true }
        table: { enabled: true }
      }
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
    }
    
    // Security: Network rules
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// Blob services with versioning and soft delete
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: true
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Secure Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: commonTags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    
    // Security: Enable RBAC
    enableRbacAuthorization: true
    
    // Security: Soft delete and purge protection
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: false // Set to true for production
    
    // Security: Network ACLs
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// Outputs
output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri

