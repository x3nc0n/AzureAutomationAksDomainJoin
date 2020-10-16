# Declare parameters

Param
(
  [Parameter (Mandatory= $true)]
  [String] $VmssResourceGroupName,
  [Parameter (Mandatory= $true)]
  [String] $VmssSubscriptionID,
  [Parameter (Mandatory= $true)]
  [String] $VmssName,
  [Parameter (Mandatory= $true)]
  [String] $domainName,
  [Parameter (Mandatory= $false)]
  [String] $OUPath,
  [Parameter (Mandatory= $true)]
  [String] $User,
  [Parameter (Mandatory= $true)]
  [String] $JoinOptions,
  [Parameter (Mandatory= $true)]
  [String] $VaultName,
  [Parameter (Mandatory= $true)]
  [String] $SecretName
)

function _doImport {
    param(
    [Parameter (Mandatory= $true)]
    [String] $VmssResourceGroupName,
    [Parameter (Mandatory= $true)]
    [String] $VmssSubscriptionID,
    [Parameter (Mandatory= $true)]
    [String] $VmssName,
    [Parameter (Mandatory= $true)]
    [String] $domainName,
    [Parameter (Mandatory= $false)]
    [String] $OUPath,
    [Parameter (Mandatory= $true)]
    [String] $User,
    [Parameter (Mandatory= $true)]
    [String] $JoinOptions,
    [Parameter (Mandatory= $true)]
    [String] $VaultName,
    [Parameter (Mandatory= $true)]
    [String] $SecretName
    )
}

Import-Module Az.Accounts
Import-Module Az.Compute
Import-Module Az.KeyVault

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection"
    $servicePrincipalConnection = Get-AutomationConnection -Name 'AzureRunAsConnection'

    "Logging in to Azure..."
    Add-AzAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

# Login-AzAccount -Credential $servicePrincipalConnection
Set-AzContext -SubscriptionId $VmssSubscriptionID

# Create the settings for the JsonAdDomainJoin Extension
# The key vault and secret must already exist

$Settings = @{"Name" = $domainName; "OUPath" = "$OUPath"; "User" = "$User"; "Restart" = "true"; "Options" = "$JoinOptions"};
$ProtectedSettings = @{"Password" = (Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName).SecretValueText};
$vmss = Get-AzVmss -ResourceGroupName $VmssResourceGroupName -VMScaleSetName $vmssName
$vmssExtensionName = "domainjoin"
$vmssPublisher = "Microsoft.Compute"
$vmssExtensionType = "JsonADDomainExtension"
$ExtVer = "1.3"

# Create the extension config

Add-AzVmssExtension -VirtualMachineScaleSet $vmss -Name $vmssExtensionName -Publisher $vmssPublisher  `
  -Type $vmssExtensionType -TypeHandlerVersion $ExtVer -AutoUpgradeMinorVersion $True  `
  -Setting $Settings -ProtectedSetting $ProtectedSettings

# Update the VMSS with the new config

Update-AzVmss -ResourceGroupName $VmssResourceGroupName -Name $vmssName -VirtualMachineScaleSet $vmss -ErrorAction Stop
