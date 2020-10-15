## Set Computer with AD utilities installed (domain controller or script server for example) ##
$jumpHost = "computername"

## Account with rights to modify AD objects ##
$username = "DOMAIN\username"
$password = "password" # this can be a "<%= cypher.read('secret/password') %>" variable for security

$secure = ConvertTo-SecureString -String $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username,$secure)

try{

Write-Output "Getting AD User Object using 'mail' attribute."
invoke-command -computername $jumpHost -Credential $cred -scriptblock{ 
$owner = Get-ADUser -Filter {mail -like "<%= instance.createdByEmail %>"}
Write-Output $owner
Set-ADComputer "<%= instance.hostname %>" -ManagedBy $owner.SamAccountName

write-output "Parameter set successful"
Get-ADComputer "<%= instance.hostname %>" -Properties * | select ManagedBy
}

}catch{
    Write-Output "Unable to retrieve user information or contact remote server/domain"
    Write-Output $_.Exception.Message
}