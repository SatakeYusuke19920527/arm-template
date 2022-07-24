param newVMName string = 'satake008'
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
    artifacts: [
      {
        artifactId: resourceId('Microsoft.DevTestLab/labs/artifactSources/artifacts', labName, 'public repo', 'windows-azurepowershell')
      }
    ]
    labSubnetName: labSubnetName
    disallowPublicIpAddress: false
    storageType: 'Premium'
    allowClaim: false
  }
  resource installCustomScriptExtension 'extensions' = {
    name: 'InstallCustomScript'
    location: resourceGroup().location
    properties: {
      azPowerShellVersion: '6.4'
      primaryScriptUri: 'https://adtllabo9035.blob.core.windows.net/test/test1.ps1'
      supportingScriptUris: []
      timeout: 'PT30M'
      cleanupPreference: 'OnSuccess'
      retentionInterval: 'P1D'
    }
  }
}

output labVMId string = vmId
