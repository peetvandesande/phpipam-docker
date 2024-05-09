# phpipam-docker
Deploys a set of Docker containers to run phpIPAM.
- phpipam nightly (due to bug #4094)
- mariadb latest

# Software
- Docker
- Terraform

# HOWTO
Deploy:
```
terraform init
terraform plan
terraform apply
```  
After deploying, log in to phpipam using the URL as output by terraform and using the credentials mentioned below. 

In there, enable the API feature under Administration -> phpIPAM settings.  

Scroll down to Feature settings and enable API. Hit Save down at the bottom.  

Next, go to Administration -> API to create an API key.  

Enter a name for the App ID (this will become part of the url: https://phpipam/api/<appid>/).  

Set the app permissions to 'Read / Write / Admin' and verify the App security is 'SSL with App token'.  

Note the App id and App code (this is the token) for use in your application.

Don't forget to hit the green Add button.  

Undo:
`terraform destroy`

# phpipam login
Username: Admin  
Password: ipamadmin  
If the above don't work, look here: https://phpipam.net/demo/