cd C:\Shares\Scripts
$users = Import-Csv .\offboarding-user.csv

foreach ($user in $users){
$firstname = $user.firstname
$lastname = $user.lastname
$department = $user.department
$username = $firstname.toLower() + $lastname.toLower()
$groupnameold = $department + " " + $user.level + " Security" 
$distname = "CN=" + $firstname + " " + $lastname + ",Ou=" + $department + ",OU=Users,OU=ZaidCo,DC=lab,DC=local"
$groupname = Get-ADPrincipalGroupMembership -Identity $username
Disable-ADAccount -Identity $username 
Move-ADObject -Identity $distname -TargetPath "OU=Disabled Users,OU=ZaidCo,DC=lab,DC=local" 

    foreach ($group in $groupname){
if ($group.name -ne "Domain Users"){
Remove-ADGroupMember -Identity $group -Members $username -Confirm:$false 
} 
}
$offboarded = "Users Offboarded = " + $username + " from " + $department + " on " + (Get-date)
Add-Content -path C:\Shares\Logs\Offboarding.txt -Value $offboarded -PassThru
}
