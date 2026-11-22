cd C:\shares\Scripts

$users = Get-ADUser -filter * -SearchBase "OU=Users,OU=ZaidCo,DC=lab,DC=local"
$employed = foreach ($user in $users){
$info = Get-ADUser $user -Properties *
$department = get-adprincipalgroupmembership -Identity $info.samaccountname
[PSCustomObject]@{
name = $user.name
department = $info.department
username = $info.SamAccountName
Title = $info.title
}
}
$employed | Export-Csv .\CurrentlyEmployed.csv -NoTypeInformation