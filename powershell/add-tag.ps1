param (
    [Parameter(Mandatory=$true)]
    [string]
    $owner
)
$owner
$payload = '{"instance": {"metadata": [{"name": "Owner","value": "' + $owner + '"}]}}'
$serviceBearer = "f301b182-045a-47d1-91c3-fa38ba74c83b"
[hashtable] $header = @{"Authorization" = "BEARER $serviceBearer" }
$response = Invoke-WebRequest -Uri "https://192.168.1.162/api/instances/152" -Headers $header -SkipCertificateCheck -Method Put -Body $payload

Write-Output $



winrm set winrm/config/service/auth '@{Basic="false"}'
winrm set winrm/config/service '@{AllowUnencrypted="false"}'