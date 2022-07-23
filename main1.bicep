param newVMName string = 'satake001'
param labName string = 'DTL-labo'
param size string = 'Standard_D2s_v3'
param userName string = 'satake'

@secure()
param password string

var labSubnetName = 'DTL-subnet'
var labVirtualNetworkId = resourceId('Microsoft.DevTestLab/labs/virtualnetworks', labName, labVirtualNetworkName)
var labVirtualNetworkName = 'DTL-vnet'
var vmId = resourceId('Microsoft.DevTestLab/labs/virtualmachines', labName, newVMName)
var vmName_var = '${labName}/${newVMName}'

resource vmName 'Microsoft.DevTestLab/labs/virtualmachines@2018-10-15-preview' = {
  name: vmName_var
  location: resourceGroup().location
  properties: {
    labVirtualNetworkId: labVirtualNetworkId
    notes: 'WindowsServer2019-sysprep'
    customImageId: '/subscriptions/8818225c-58f0-44de-a997-92f946312b3b/resourcegroups/dtl/providers/microsoft.devtestlab/labs/dtl-labo/customimages/windowsserver2019-sysprep'
    size: size
    userName: userName
    password: password
    isAuthenticationWithSshKey: false
    labSubnetName: labSubnetName
    disallowPublicIpAddress: false
    storageType: 'Premium'
    allowClaim: false
  }
}
resource runPowerShellInline 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runPowerShellInline'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  identity: {
    type: 'userAssigned'
    userAssignedIdentities: {
      '/subscriptions/01234567-89AB-CDEF-0123-456789ABCDEF/resourceGroups/myResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myID': {
      }
    }
  }
  properties: {
    forceUpdateTag: '1'
    containerSettings: {
      containerGroupName: 'mycustomaci'
    }
    storageAccountSettings: {
      storageAccountName: 'myStorageAccount'
      storageAccountKey: 'myKey'
    }
    azPowerShellVersion: '6.4'
    arguments: '-name \\"John Dole\\"'
    environmentVariables: [
      {
        name: 'UserName'
        value: 'jdole'
      }
      {
        name: 'Password'
        secureValue: 'jDolePassword'
      }
    ]
    // scriptContent: '''
    //   Install-WindowsFeature Web-Server -IncludeManagementTools
    // '''
    primaryScriptUri: 'https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/deployment-script/deploymentscript-helloworld.ps1'
    supportingScriptUris: []
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output labVMId string = vmId
