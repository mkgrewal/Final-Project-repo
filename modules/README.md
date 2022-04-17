         ___        ______     ____ _                 _  ___  
        / \ \      / / ___|   / ___| | ___  _   _  __| |/ _ \ 
       / _ \ \ /\ / /\___ \  | |   | |/ _ \| | | |/ _` | (_) |
      / ___ \ V  V /  ___) | | |___| | (_) | |_| | (_| |\__, |
     /_/   \_\_/\_/  |____/   \____|_|\___/ \__,_|\__,_|  /_/ 
 ----------------------------------------------------------------- 


Hi there! Welcome to AWS Cloud9!

To get started, create some files, play with the terminal,
or visit https://docs.aws.amazon.com/console/cloud9/ for our documentation.

Happy coding!

Pre-requisites
We created the three buckets for each environment and one separate buckets for uploading images. We uploaded the images manually and allow the public access. We then add that image url in our httpd file that is shown when our dns runs.


Requirement
Outcome of this project was to understand benefits of Devops and basic cloud components using terraform infrastructure as a code. 
The main objective was to deploy various environments using Terraform and commit it to github repository using git commands.
Terraform is a Infrastructure as a code tool from Harshicorp and uses HCL and bash.
it is widely used with various provides. When tf init is successful it creates .tf folder which has all the plugins.

Commands used

vi ~/.bashrc - to provide alias fro terraform
tf init -for initialisation
tf fmt - to check format
tf validate - to validate
tf plan - to check the differences whether it has to be changed or destroy
tf apply -auto-approve - for applying changes
tf destroy -auto-approve - for destrou=ying environment.
ssh-keygen -t rsa -f ~/.ssh/(keyname)
vi (Keyname)- To create Key and copy it form the key created already for checking
ssh -i (keyname) ec2-user@(ip address of VM's)
curl localhost
curl (private ip address)- for checking if webserver is installed.


Components Known in this assignment
Bastion
Nat Gateway
Usage of various public and private subnets
Load Balancer
Auto Scaling
Target Groups for Load Balancer
Launch Configurations for Auto Scaling

Steps performed
Created Dev environment code and created S3 bucket performed below steps.
tf init
tf fmt
tf validate
tf plan
tf apply -auto-approve

Created Prod environment with seperate S3 bucket and performed below steps.
tf init
tf fmt
tf validate
tf plan
tf apply -auto-approve

Created Staging environment code and created seperate S3 bucket performed below steps.
tf init
tf fmt
tf validate
tf plan
tf apply -auto-approve


