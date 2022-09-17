CONTENTS OF THIS FILE
---------------------

 * Transformers
 * Prerequisites
 * Configuration
 * Run
 * Access index page
 * Design Architecture Doc
 * Maintainers

TRANSFORMERS
------

This project is a AWS provisioning system using Terraform.

PREREQUISITES
-------------

1. You must have installed terraform of version 1.0 or later.

2. You must have an AWS account with Access and Secret Keys generated.

3. Generate the ssh keys which will be used to assign to the EC2 instances
```bash
 ssh-keygen -t rsa #name it aws-key
```
and place it under the `transformers/keys/` path


CONFIGURATION
-------------

1. Modify the `env_variables.sh` in the `support-files` directory to add the AWS Access, Secret key and Region. Then run the following command:
```bash
source env_variables.sh
```

2. You can optionally check if all the necessary environment variables are populated by running the env.py script in the `support-files` directory
```bash
python env.py
```


RUN IT
------

Please make sure that you completed the step in the sections Prerequisites and Configuration.

Head over the `infrastructure` directory within the project and run the following commands

```bash
terraform init
terraform apply
```


ACCESS INDEX HTML PAGE FROM LB
------------------------------

After the successful provisioning, i have added as an output the DNS name of the LB generated.

Additionally, you can run the following command to obtain the link:
```bash
 terraform output -raw load_balancer_link
```

Now you can see the surprise message which is served with the 2 nginx ec2 instances.

DESIGN ARCHITECTURE DOC
-----------------------

#### SSH KEYS GENERATION AND SHARING

* Typically i was using an existing ssh key created from the key pairs AWS service, but since you do not have access to my free tier account i am generating manually an ssh keypair and using it to create a new ssh keypair in AWS. I am adding this method in order to automate the provisioning instead of forcing you to create manually a key pair in AWS.
* Another solution was to generate the ssh keys using terraform, but from the documentation i can see that the private key remains in the .tfstate file, which is very risky to publish to git repositories.
* The ultimate solution which i would normally use, in my opinion, would be to let developers provide me their public keys, which i then could create new AWS key pairs, and use them to create new ec2 instances.

#### AWS ARCHIRECTURAL DECISIONS

* Created a VPC
* Created a public subnet for the instances to communicate over internet
* Created an Internet Gateway for the VPC to communicate over internet. I was not able to ssh into the nodes.
* Created routing table for the public subnets to reach to the internet
* Used the aws launch configuration to create the template for the EC2 instances which for the Autoscaling Group to manage.


![alt text](http://akentominas.com/wp-content/uploads/2022/09/Screenshot_50.png)

I would like to point out that in production, i would rather create an instance in public subnet which will allow connection to the instance of the private subnet (also known as bastion). But this is a discussion for more to analyse.

#### PROJECT STRUCTURE


 * [infrastructure](./infrastructure)
   * #terraform code
 * [keys](./keys)
   * #ssh keys directory
 * [support-files](./support-files)
   * #helper scripts


This is my first terraform project. However in software engineering the best practice is always maintain a well structured project for maintainability and readability.
I have separated the terraform code, like the variables, provider and instrastructure provisioning code in files, inside the infrastructure directory 

#### SUPPORT FILES

For the engineer's convenience i have added scripts which handles the necessary environment variables population, in order to read the sensitive variables from the environment instead of hardcoding them to the project.
I have added also a python script which checks if the env variables have populated succussfully. 

MAINTAINERS
-----------

Anastasios Kentominas <akentominas@gmail.com>
