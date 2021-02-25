# Steps for Creating an Azure Windows VM that Leverages Existing Key Vault
## Create a service principal for Terraform in Azure CLI
1.  az login
2.  az account list
3.  az account set --subscription="SUBSCRIPTION_ID"
4.  az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
5.  Configure the following environment variables locally and use the values from previous command:
    **export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"**
    **export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"**
    **export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"**
    **export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"**

## How to Assign Service Principal to Access Policy in Existing Key Vault in Azure CLI
1.  Make sure the account that you are logged with to Azure CLI is granted rights to the Key Vault through Access Policy
2.  I have already configured secrets called "WinVMUser" and "WinVMPassword" in my Key Vault.  I can now verify my access to these secrets with this command:
    **az keyvault secret list --vault-name "[KeyVault Name]"**
3.  Now I need to assign a Key Vault Access Policy to the Service Principal I created and this can be done with the following command:
    **az keyvault set-policy --name "[KeyVault Name]" --spn [Client ID for Service Principal] --secret-permissions get**
