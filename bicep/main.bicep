param location string

resource asp 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'asp-logicapp-standard-demo'
  location: location
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
  }
  kind: 'windows'
}

resource logicapp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'la-logicapp-standard-demo'
  location: location
  kind: 'workflowapp,functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: asp.id
    httpsOnly: true
    siteConfig: {
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      appSettings: [
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
        {
          name: 'AzureBlob_blobStorageEndpoint'
          value: storage.properties.primaryEndpoints.blob
        }
        {
          name: 'AZUREBLOB_CONNECTION_ID'
          value: azureblob_connection.id
        }
        {
          name: 'AZUREBLOB_API_ID'
          value: azureblob_connection.properties.api.id
        }
        {
          name: 'AZUREBLOB_RUNTIME_URL'
          value: azureblob_connection.properties.connectionRuntimeUrl
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage.id, storage.apiVersion).keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'STORAGE_ACCOUNT_NAME'
          value: storage.name
        }    
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
      ]
    }
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'salasdemo'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
  }

  resource blobservice 'blobServices@2022-09-01' = {
    name: 'default'

    resource container 'containers@2022-09-01' = {
      name: 'demo'
    }
  }
}

resource logicapp_roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, logicapp.name, storage.name, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  scope: storage
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: logicapp.identity.principalId
  }
}

resource azureblob_connection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'azureblob-logicapp-standard'
  location: location
  kind: 'V2'
  properties: {
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azureblob'
    }
    displayName: 'azureblob-logicapp-standard'
    parameterValueSet: {
      name: 'managedIdentityAuth'
      values: {}
    }
  }
}

resource azureblob_accesspolicy 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${logicapp.name}-${guid(resourceGroup().name)}'
  location: location
  parent: azureblob_connection
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: subscription().tenantId
        objectId: logicapp.identity.principalId
      }
    }
  }
}
