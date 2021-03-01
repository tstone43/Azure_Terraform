# Steps for Creating an Azure Windows VM that Leverages Existing Key Vault
## Create a Service Principal for Terraform in Azure CLI
1.  **az login**
2.  **az account list**
3.  **az account set --subscription="SUBSCRIPTION_ID"**
4.  **az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"**
5.  Configure the following environment variables locally and use the values from previous command:
    **export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"**
    **export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"**
    **export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"**
    **export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"**

## How to Assign Service Principal to Access Policy in Existing Key Vault in Azure CLI
1.  Make sure the account that you are logged with to Azure CLI is granted rights to the Key Vault through Access Policy
2.  I have already configured secrets called "WinVMUser" and "WinVMPassword" in my Key Vault.  I can now verify my access to these secrets with this command:<br/>
    **az keyvault secret list --vault-name "[KeyVault Name]"**
3.  Now I need to assign a Key Vault Access Policy to the Service Principal I created and this can be done with the following command:<br/>
    **az keyvault set-policy --name "[KeyVault Name]" --spn [Client ID for Service Principal] --secret-permissions get**
    
## Importing Existing Resource Group and Key Vault into Terraform State
1.  Add the configuration for your existing Resource Group and existing Key Vault to your main.tf file.
2.  Terraform syntax for importing existing resource in Azure is like this:<br/> 
    **terraform import **[Terraform Resource Name].[Resource Label] [Azure Resource ID]****
4.  Run **Terraform Init** to intialize the Azure Provider
5.  Use the Azure CLI to identify the existing Resource ID for your existing Resource Group where your existing Key Vault resides:<br/> 
    **az group show --name [existing Resource Group name]**
5.  Import your existing Resource Group with syntax like this:<br/>
    **terraform import azurerm_resource_group.rg1 [entire value for id from previous command]**
6.  Use the Azure CLI to identify the existing Resource ID for your existing Key Vault:<br/>
    **az keyvault show --name [existing Key Vault name]**
7.  Importing your existing Key Vault with syntax like this:<br/>
    **terraform import azurerm_key_vault.kv [entire value for id from previous command]**
    
## Deploy the VM and VNET Using Terraform
1.  In the VM_with_Virtual_Network directory first run **terraform plan**
2.  Review output of previous command to make sure necessary resources are being created
3.  Next run **terraform apply** and input yes to create the resources

## Verify that your VM is Using the Correct User Name and Password from the Key Vault
1.  Determine the public IP address by going to your newly created VM in the Azure portal
2.  Use Remote Desktop to connect to the VM to see if the credentials from your Key Vault will allow to authenticate to VM

## Important Note Regarding Terraform Destroy
Don't run **terraform destroy** unless you want to delete your existing Key Vault.  If you want to redeploy VM you can just delete the Resource Group and objects within it

## Retrieving Secrets from Existing Key Vault Without Importing it into Terraform State
1.  It is not necessary to import an existing resource group and an existing Key Vault in order to use the secrets from the existing Key Vault.
2.  You can use the following syntax to reference an existing Key Vault that you have setup in Azure:
    <br/>**data "azurerm_key_vault" "kvdata" {
         <br/>name = var.existing-kv-name<br/>
         resource_group_name = var.existing-rg<br/>
    }**
3.  You can then use the following syntax to refer to an existing secret in Key Vault:
    <br/>**data "azurerm_key_vault_secret" "kvsecret" {
         <br/>name = "WinVMPassword"<br/>
         key_vault_id = data.azurerm_key_vault.kvdata.id<br/>
    }**
