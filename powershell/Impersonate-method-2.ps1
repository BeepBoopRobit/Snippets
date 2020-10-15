$username = "DOMAIN\username"
$password = "asdf" # this can be a "<%= cypher.read('secret/password') %>" variable for security

$secure = ConvertTo-SecureString -String $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username,$secure)

$session = New-PSSession -ComputerName localhost -Credential $cred
Invoke-Command -Session $session -ScriptBlock {Invoke-WebRequest "https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.54/bin/apache-tomcat-8.5.54.exe" -OutFile "c:\test\apache-tomcat-8.5.54.exe"}