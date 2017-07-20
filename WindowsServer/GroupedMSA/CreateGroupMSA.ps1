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
      $dnsHostName = (($account) + "." + ($myFQDN))
      $TargetHost = ($line.'Host')
      $accounts.Add( @($account,$dnsHostName,$TargetHost) );
      $computer = Get-ADComputer $TargetHost;
      if($set.Contains($computer.SID) -ne $true) {
          Add-ADGroupMember $group -Members $computer
          Invoke-Command -ComputerName $TargetHost -ScriptBlock {klist purge}
          Invoke-Command -ComputerName $TargetHost -ScriptBlock {gpupdate /force}
      }
}


$output = @()

foreach($newaccount in $accounts) {
 try {
  $msg = 'Ok'
  $good = 1
  
 try{
    New-ADServiceAccount -name $newaccount[0] -DNSHostName $newaccount[1] -PrincipalsAllowedToRetrieveManagedPassword $group
    
 } catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] 
 {
      $msg = 'Account Already Exists'
 }
 
  $svcacct = Get-ADServiceAccount $newaccount[0]
  
  Add-ADGroupMember $group -Members $svcacct
  Add-ADComputerServiceAccount -Computer $computer -ServiceAccount $svcacct

  } catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]  {
     $msg =  $_.Exception.Message
     $good = 0
  }
   $outrow = @{
      Date = get-date
      ComputerName = $newaccount[2]
      Account = $newaccount[0]
      FQDN = $newaccount[1]
      good = $good
      message = $msg
   }
   $output += New-Object PSObject -Property  $outrow

 }
 $output | Export-Csv -Path (($path) + '.out') -NoTypeInformation
