# Securing a 3-Tier Webapp on Azure
With this project we will deploy with 3-tier web application composed of a Frond-end, Backend and Database infrastructure. 
![WEBAPP-CAPTURE](https://github.com/Armandkeza/N-tier-Azure-Web-APP/assets/4728642/1da6aa3a-c8c1-47ee-9de1-0a39bdffdd6e)

# # # 1. Securing Web application access
 The enduser will access the Frontend of the application via an application gateway with WAF. For application availability the frontend servers are configured in an auto-scaling group accross 2 Availabilty zone.
WAF policies will be configured to inspect all incoming traffic to the application to detect and block any malicious traffic toward the application.

2.Backend Servers access
 The Backend servers will be in a dedicated subnet with Network security group configured to allow only the Front end to interact with the backend server on specific ports.
For application high-availabily the backend servers are hosted behind a Azure load balancer with auto-scaling configured  accross 2 Availability zones.

3.Database servers
 The application data will be stored on a Posgrel database configured accross 2 availability zone in a primary-standby design with synchronous replication.
For security purposes we use VNET integration feature to host the PAAS postgrel database on the application VNET avoiding the need to traverse internet for database connectivity.

4.File Storage
 Azure storage container will be used to host multimedia files used by the application. 
The azure storage container will only be available from the Frontend subnet and prvate link will be used to interconnect the storage account and the Frontend subnet.

5.Private DNS
Private DNS zone will be used to connect to PAAS services privately without going through the internet.
A private DNS zone will be configured for accessing the Postgrel database through it's private IP and another zone will be configured for accessing Azure storage container blob.

6. IAM
   A managed identity will be used to allow the Front-end VM to be able to connect to Azure storage account.

7. Azure Bastion
   Azure Bastion will be used to allow administrators to be able to connect securely to Azure VM without the need to exposed VM ports on the Internet.

8.Azure Firewall
Azure Firewall will be deployed in each Availability zone to filter outbound traffic towards the internet.

