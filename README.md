# AzureAutomationAksDomainJoin

Joins AKS VMSS Windows nodes to a domain

## How to use this

### Preparation

- Setup the Key Vault, add the secret. I make the secret for a user the user's name; it's easier to remember.
- Check for domain connectivity from the AKS node pool. Tip: Use bastion to login to an AKS Windows node and run `sconfig` to try and manually join the domain in case of errors.
- Grant the Automation Account's RunAs account access to the secret and subscription if vmss is in another subscription

### Deploy runbook

Download the [aksvmssdomainjoinwithkeyvault.ps1](https://github.com/x3nc0n/AzureAutomationAksDomainJoin/blob/master/aksvmssdomainjoinwithkeyvault.ps1) script and deploy it to your Azure Automation subscription. You must have parameter values for the following:

- VmssResourceGroupName - This is the RG of the node pool VMSS, with name starting with "MC_", not the AKS service
- VmssName - The name of the VMSS under $VmssResourceGroupName, not the AKS service
- domainName - The FQDN of the domain you wish to join (e.g. corp.contoso.com)
- OUPath - the OU for the computer object joining the domain, optional (will default to Computers OU)
- User - the domain user with permissions to join the machines to the domain (e.g. CORP\user)
- JoinOptions - the domain join operation options; put 3 if you don't know otherwise
- VaultName - the Azure Key Vault where you have stored the password for the User above as a secret
- SecretName - the name of the secret in the Key Vault above that contains the User's password

In case AZ module is not loaded, please import [install Az.Accounts, Az.Compute, Az.KeyVault modules into Automation Account](https://docs.microsoft.com/en-us/azure/automation/shared-resources/modules#import-az-modules)

## Other Notes

- Failure is always an option.
