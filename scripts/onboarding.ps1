cd C:\Shares\Scripts
$users = Import-Csv .\user.csv
$password = Read-Host "Enter temp password" -AsSecureString
foreach ($user in $users){
$username = $user.firstname.toLower() + $user.lastname.toLower()
$groupname = $user.department + " " + $user.level + " Security"
$fullname = $user.firstname + " " + $user.lastname
$GivenName = $user.firstname
$Surname = $user.lastname
$login = $username + "@lab.local"
$ou = "OU=" + $user.department + ",OU=Users,OU=ZaidCo,DC=lab,DC=local"
New-ADUser -Name $fullname -Displayname $fullname -SamAccountName $username -GivenName $GivenName -Surname $Surname -Path $ou -AccountPassword $password -Enabled $True -ChangePasswordAtLogon $True -UserPrincipalName $login -Department $user.department
Add-ADGroupMember -Identity $groupname -Members $username 
}


