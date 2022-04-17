### Create AWS VPC with Public Subnet Private Subnet Internet Gateway and NAT Gateway then deploy Wordpress
1. Write an Infrastructure as code using Terraform, which automatically creates a VPC.

2. In that VPC we have to create 2 subnets:

  1.  public subnet [Accessible for Public World! ]

  2.  private subnet [ Restricted for Public World! ]

3. Create a public-facing internet gateway to connect our VPC/Network to the internet world and attach this gateway to our VPC.

4. Create a routing table for Internet gateway so that instance can connect to the outside world, update and associate it with the public subnet.

5. Create a NAT gateway to connect our VPC/Network to the internet world and attach this gateway to our VPC in the public network

6. Update the routing table of the private subnet, so that to access the internet it uses the nat gateway created in the public subnet

7. Launch an ec2 instance that has WordPress setup already having the security group allowing port 80 so that our client can connect to our WordPress site. Also, attach the key to an instance for further login into it.

8. Launch an ec2 instance that has MYSQL setup already with security group allowing port 3306 in a private subnet so that our WordPress VM can connect with the same. Also, attach the key with the same.

Note: WordPress instance has to be part of the public subnet so that our client can connect our site. MySQL instance has to be part of a private subnet so that the outside world can't connect to it. Don't forget to add auto IP assign and auto DNS name assignment options to be enabled.
