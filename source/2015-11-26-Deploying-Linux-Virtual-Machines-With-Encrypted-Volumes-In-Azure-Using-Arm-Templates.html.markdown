---
title: Deploying Linux Virutal Machines With Encrypted Volumes In Azure Using ARM Templates
date: 2015-11-26
author: heath
author_full: Heath Skarlupka
tags: Azure, ARM Templates, Security, Infrastructure
---

Vince and I were at the Microsoft ARM Templating Hackathon last week to begin the process of integrating the Catalyze Platform as a Service into the Microsoft Azure Marketplace.  An Azure Resource Manager (ARM) template is a JSON file that provides the schematic for a set of resources that get built in the Azure Cloud.  These templates provide the building blocks for creating products in the Microsoft Azure Marketplace.

## Disk Encryption in Azure

Encrypting data at rest is a key component in the Catalyze Platform to ensure HIPAA compliance. Moving these encryption tasks to the infrastructure level helps simplify software design higher up the chain. We were excited to hear Microsoft announce recently native support for disk encryption in the Azure Cloud.  Disk encryption in the Azure Cloud relies on the Key Vault resource and a generic Application registered in Active Directory. The registered application will need permission to add and access disk encryption keys in the Key Vault. Sadly managing Active Directory resources is outside the capabilities of the Azure Resource Manager at this time, but can be manually managed in the old Azure Portal.

# Setting up a new Application in the Default Active Directory.

Lets walk through a quick example of setting up an encrypted volume on a virtual machine in the Azure Cloud with Active Directory and an ARM template.

### 1. Select the “Active Directory” tab in the Azure Portal.

![Active Directory Tab](/assets/img/posts/azure_1.png)

### 2. Select the “Default Directory”.

![Default Directory](/assets/img/posts/azure_2.png)

### 3. Select “Develop Applications” and then select "Add an application you’re developing".

![Develop Applications](/assets/img/posts/azure_3.png)

### 4. The information entered in the next few screens isn’t important to getting disk encryption working, but being descriptive will help for the next set of steps.

![Step One](/assets/img/posts/azure_4.png)
![Step Two](/assets/img/posts/azure_5.png)

### 5. After selecting the checkmark at the bottom right corner,  select "configure" in the newly created Application’s dashboard.

![Configure](/assets/img/posts/azure_6.png)

### 6. Under the "keys" section, select a 2 year key.

![Keys](/assets/img/posts/azure_7.png)

### 7. Select "save" at the bottom of the page.

![Save](/assets/img/posts/azure_8.png)

### 8. Once the Application has been saved a key will be revealed under the keys section.  This key is known as the Application Active Directory (AAD) Client Secret.  Save this secret key along with the AAD Client ID also on the “configure” page.

## Deploying a Virtual Machine with an encrypted volume via an ARM template

### 1. Install the [Azure CLI](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/)
### 2. Via the CLI, create a new Resource Group in the East US region
```curl
azure group create linuxDiskEncryptionGroup eastus
```
### 3. Download the [parameters file](https://raw.githubusercontent.com/catalyzeio/arm-testing/master/azuredeploy.parameters.json) and edit as needed.

| Parameter | Description |
|---|---|
| AADClientID | Client ID saved from step 1 |
| AADObjectID | Azure CLI: "azure ad sp show --search diskencryption" |
| AADClientSecret | Client Secret saved from step 1 |
| VolumeType | Always use “Data” for Linux VMs |
| SequenceVersion | Start with “1” and increment as needed |
| Passphrase | Disk encryption key |
| tenantID | Azure CLI: "azure account show ACCOUNT_NAME" |

### 4. Via the CLI, deploy the template using the remote [template URL](https://raw.githubusercontent.com/catalyzeio/arm-testing/master/azuredeploy.json -e parameters.json) and the local file path to the parameters file.

```curl
azure group deployment create -g  linuxDiskEncryptionGroup -n  linuxDiskEncryptionDeployment -f https://raw.githubusercontent.com/catalyzeio/arm-testing/master/azuredeploy.json -e parameters.json
```

## Linux Disk Encryption ARM Template Explained

Disc encryption in ARM depends on the "Azure Disk Encryption For Linux" Virtual Machine Extension.  ARM Virtual Machine Extensions are resources used to configure and manage Virtual Machines.  The parent Virtual Machine resource must be created before the Extension.  This seems reasonable in most cases because VM Extensions make changes to the parent Virtual Machine.  In the case of disk encryption, a resource loop is created because the disk encryption properties of the Virtual Machine depend on the Virtual Machine Extension which can’t get created without the Virtual Machine.  To get around the resource loop, an unencrypted Virtual Machine resource must first be created and then a second template must be deployed that includes the "Azure Disk Encryption For Linux" Virtual Machine Extension and the necessary property changes to the original Virtual Machine resource.  To condense these operations a bit, ARM templates can be instantiated in the resources section of a parent template.  In the above example, the "UpdateEncryptionSettings" template is called after the unencrypted Virtual Machine resource is created.

## Final Thoughts

Encrypting Linux Volumes in ARM templates requires a deep understanding of resource creation in the Azure Cloud.  It is not clear yet if the process for encrypting disks will map easily to Scale Sets, which would be required in a large infrastructure deployment.  As ARM templating matures and the demand for encrypted data at rest increases, Microsoft should make this process easier and more straightforward.
