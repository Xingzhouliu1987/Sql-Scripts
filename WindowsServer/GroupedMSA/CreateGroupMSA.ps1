$domain = Get-ADDomain -Current LoggedOnUser
$GroupName = Read-Host -Prompt 'Name of Security Group'
try {
$group = Get-ADGroup $GroupName
} catch {
   New-ADGroup -Name $GroupName -GroupCategory Security -GroupScope Global -Path $domain;
   Write-Host 'Creating Security Group' + ($GroupName)
   $group = Get-ADGroup $GroupName
}
$groupmembers = Get-ADGroupMember $group
$set = New-Object System.Collections.Generic.HashSet[string]
$myFQDN=(Get-WmiObject win32_computersystem).Domain
$accounts = New-Object System.Collections.ArrayList;

foreach($item in $groupmembers) {
   $set.Add($item.SID)
}

$path = Read-Host -Prompt 'FilePath';
$csv = Import-csv -path $path;
foreach($line in $csv) {
      $account = ($line.'Account Name')
      $TargetHost = ($line.'Host')
      $fqdn = (($account) + "." + ($myFQDN))
      $runnable = 1
      $msg = ''
      
      $computer = Get-ADComputer $TargetHost

      if($set.Contains($computer.SID) -ne $true) {
	    try {
            Add-ADGroupMember $group -Members $computer
            Invoke-Command -ComputerName $TargetHost -ScriptBlock {klist purge}
            Invoke-Command -ComputerName $TargetHost -ScriptBlock {gpupdate /force}
            $set.Add($computer.SID)
          } catch {
             $msg = $_.Exception.Message + ": Could not add computer to group"
             $runnable = 0
         }
      }
      $inputRow = @{
            account = $account 
            dnsHostName = $fqdn 
            host = $TargetHost
            runnable = $runnable
            msg = $msg
            date = get-date
      }
      $accounts += New-Object PSObject -Property $inputRow
}


$output = @()

foreach($newaccount in $accounts) {

if($newaccount.runnable -eq 1) { 
 try {
  $msg = 'Ok'
  $good = 1
  
 try{
    New-ADServiceAccount -name $newaccount.account -DNSHostName $newaccount.dnsHostName -PrincipalsAllowedToRetrieveManagedPassword $group
    
 } catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] 
 {
      $newaccount.msg = 'Account Already Exists'
 }
      $svcacct = Get-ADServiceAccount $newaccount.account
  
     Add-ADGroupMember $group -Members $svcacct
     Add-ADComputerServiceAccount -Computer $computer -ServiceAccount $svcacct
     $newaccount.runnable = 2

  } catch  {
     $newaccount.msg =  $_.Exception.Message 
     $newaccount.runnable = 0
  } 
 }
 $output += $newaccount
   

 }

 $output | Export-Csv -Path (($path) + '.out') -NoTypeInformation
