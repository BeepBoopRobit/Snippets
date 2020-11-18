[CmdletBinding()]
param (
    # appliance hostname only
    [Parameter(mandatory = $true)]
    [string]
    $applianceHostname,
    # access/bearer token generated via morpheus ui(easiest) or api call
    [Parameter(Mandatory = $true)]
    [string]
    $accessToken,
    # cloud name
    [Parameter(Mandatory = $false)]
    [string]
    $zoneName,
    # primary dns server
    [Parameter(Mandatory = $false)]
    [string]
    $primaryDns,
    # secondary dns server
    [Parameter(Mandatory = $false)]
    [string]
    $secondaryDns
)
function Invoke-MorphRest {
    param (
        # Morpheus hostname
        [Parameter(Mandatory = $true)]
        [string]
        $applianceHostname,
        # Endpoint
        [Parameter(Mandatory = $true)]
        [string]
        $apiEndpoint,
        # REST Method
        [Parameter(Mandatory = $true)]
        [string]
        $method,
        # Access/bearer token
        [Parameter(Mandatory = $true)]
        [string]
        $accessToken,
        # Payload
        [Parameter(Mandatory = $false)]
        [string]
        $jsonPayload
    )

    [hashtable] $header = @{"Authorization" = "BEARER $accessToken" }
    [string]$url = "https://" + $applianceHostname + "/api/" + $apiEndpoint
    [array] $responseStream = (Invoke-WebRequest -SkipCertificateCheck -Method $method -Uri $url -Headers $header -Body $jsonPayload).content | ConvertFrom-Json

    return $responseStream
}
$endpoint = "networks"



$allNetworks = (Invoke-MorphRest -applianceHostname $applianceHostname -apiEndpoint $endpoint -method "get" -accessToken $accessToken -jsonPayload "").networks

foreach ($net in $allNetworks) {
    
    $net = $net | Select-Object * | Where-Object { $_.zone.name -eq $zoneName }
    if ($net) {
    
        $payload = @{
            network = @{
            }
        }
        $pattern = [Regex]::new("(?:\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b)(.*)")
        $netInfo = $pattern.Match($net.name).Value
        if ($netInfo) {
            $gateway = $netInfo -replace "(?:\d-.*)", "1"
            $cidr = $netInfo -replace "-", "/"
        }
        ### INSERT NEEDLESS COMPLEXITY HERE ###

        $p = @("dnsPrimary", "dnsSecondary", "gateway", "cidr")
        switch ($p) {
            $p[0] {
                $payload.network.Add($p[0], $primaryDns)
            }
            $p[1] {
                $payload.network.Add($p[1], $secondaryDns)
            }
            $p[2] {
                $payload.network.Add($p[2], $gateway)
            }
            $p[3] {
                $payload.network.Add($p[3], $cidr)
            }
        }

        # $payload.network.Add("dnsPrimary", "")
        # $payload.network.Add("dnsSecondary", "")
        # $payload.network.Add("gateway", "")

        ### END NEEDLESS COMPLEXITY ###

        $response = Invoke-MorphRest -applianceHostname $applianceHostname -apiEndpoint ($endpoint + "/" + $net.id) -method "put" -accessToken $accessToken -jsonPayload ($payload | ConvertTo-Json)
    }
    $cidr = $null
    $gateway = $null
} 