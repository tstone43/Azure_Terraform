# Create a Terraform Backend in Azure

1.  Sign into the Azure CLI with **az login**
2.  If you have more than one subscription in Azure make sure you are set to use the correct subscription
3.  Under the VM_with_Virtual_Network_with_Backend folder there a shell script to create the Azure Storage
4.  Modify the create-backend.sh script, so that your Azure storage account has a unique name
5.  In the main.tf file the backend config starts at line 10.  Make sure you are specifying the correct names here that you are using in the script.
6.  While in folder mentioned above run **chmod+x create-backend.sh**, so that you can execute the script
7.  Now execute the script to create the backend: **./create-backend.sh**
8.  Now run **terraform init** and this will create the backend
9.  Notice when you run a **terraform plan** or **terraform apply** that terraform is now using the remote backend
