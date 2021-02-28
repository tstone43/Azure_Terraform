#Create RG for storing State Files
#az group create --location westus2 --name terraformstate-rg

#Create Storage Account
az storage account create --name thomcstoneterrastate --resource-group terraformstate-rg --location westus2 --sku Standard_LRS

#Create Storage Container
az storage container create --name terrastate --account-name thomcstoneterrastate

#Enable versioning on Storage Account
az storage account blob-service-properties update --account-name thomcstoneterrastate --enable-change-feed --enable-versioning true