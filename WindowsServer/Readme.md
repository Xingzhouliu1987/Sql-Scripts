# Create New Grouped MSA

This powershell script automates the following steps:

(1) Get a security group by user prompt or create one if needed (uses current user context)
(2) Creates new gMSA's based on an input csv with columns 

            Account Name, Host
            .... , <Target Host>
 
 (3) Adds the new gMSA to the chosen Security Group
 (4) Adds the target host to the chosen Security Group
 (5) Installs the gMSA onto the chosen host
 
 This script does not need to be run on the target host.
 
 # TODO
 (1) Automate process of checking and ensuring that gMSA's have logon as service privilege on target hosts
 (2) Take context as argument rather than current user context
 
