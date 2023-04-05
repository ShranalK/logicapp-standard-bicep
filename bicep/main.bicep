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
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage.id, storage.apiVersion).keys[0].value}'
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
    minimumTlsVersion: '1.2'
  }
}

resource azureblob_connection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'azureblob-logicapp-standard'
  location: location
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
