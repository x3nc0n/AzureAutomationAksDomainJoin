# AzureAutomationAksDomainJoin
Joins AKS VMSS Windows nodes to a domain

## How to use this
Download the aksvmssdomainjoinwithkeyvault.ps1 script and deploy it to your Azure Automation subscription. You must have parameter values for the following:

- VmssResourceGroupName - This is the RG of the node pool VMSS, not the AKS service
- VmssName - The name of the VMSS, not the AKS service
- domainName - The FQDN of the domain you wish to join - e.g. corp.contoso.com
- OUPath - the OU for the computer object joining the domain, optional (will default to Computers OU)
- User - the domain user with permissions to join the machines to the domain (e.g. CORP\user)
- JoinOptions - the domain join operation options; put 3 if you don't know otherwise
- VaultName - the Azure Key Vault where you have stored the password for the User above as a secret
- SecretName - the name of the secret in the Key Vault above that contains the User's password

## Other Notes
Setup the Key Vault, add the secret. I make the secret for a user the user's name; it's easier to remember.
Grant the Automation Account's RunAs account access to the secret.
Check for domain connectivty from the AKS node pool. Tip: Use bastion to login to an AKS Windows node and run sconfig to try and manually join the domain in case of errors.
Failure is always an option.
