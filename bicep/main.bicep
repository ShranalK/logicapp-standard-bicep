param location string

resource asp 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'asp-logicapp-standard-demo'
  location: location
  sku: {
    name: 'Free'
    tier: 'F1'
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
  }
}

// resource azureblob_connection 'Microsoft.Web/connections@2016-06-01' = {
//   name: 'azureblobconnection'
//   location: 'australiaeast'
//   properties: {
//     api: {
//       id: '/subscriptions/860a62c6-1e81-422f-b572-ae170e61099c/providers/Microsoft.Web/locations/australiaeast/managedApis/azureblob'
//     }
//     displayName: 'azureblobconnection'
//     parameterValues: {
//       authenticationType: 'ManagedServiceIdentity'
//     }
//   }
// }
