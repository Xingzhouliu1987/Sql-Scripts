# Batch Create New Grouped Managed Service Accounts

Requirements:
- Powershell 2
- Windows Server 2012 or up
- SQL Server 2014 and up (if used as SQL Server Service Accounts)
- A KdsRootKey already present
- Remote Powershell must be enabled for the target host (uses Invoke-Command if target host not yet joined to security group to
  join the host and refresh state)
- User must be a Domain Administrator

To Create a KdsRootKey 

      for Dev
      Add-KdsRootKey -EffectiveTime ((get-date).addhours(-10))
      
      for Prod
      Add-KdsRootKey -EffectiveImmediately
      (to ensure the key is propogated to all Domain Controllers, the key will not be available until 10 hours after creation).

This powershell script automates the following steps:

(1) Get a security group by user prompt or create one if needed (uses current user context)

(2) Loads an input csv with columns 

            Account Name, Host
            .... , <Target Host>
 
 (3) Adds target hosts to the chosen Security Group, purges klist and forces a gpupdate (run on target host) if target host has not been joined to group.
 
 (4) Creates a new gMSA based on the input csv
 
 (5) Adds the new gMSA to the chosen Security Group
 
 (6) Installs the gMSA onto the chosen host
 
 (7) Prints output status for each account/host pair onto a csv file (inputfilepath) + ".out"
 
 This script does not need to be run on the target host.
 
 # TODO
 (1) Automate process of checking and ensuring that gMSA's have logon as service privilege on target hosts

 (2) Take context as argument rather than current user context
 
 (3) Error Action if step 3 fails.
 
