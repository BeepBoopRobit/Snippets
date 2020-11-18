$json = Get-Content -Path /Users/rickynelson/Documents/response.json

$converted = ConvertFrom-Json -InputObject $json

$output = @()
$converted.instances 
foreach($item in $converted.instances){
$object = [PSCustomObject]@{
    id = $item.id
    group = $item.group.name
    cloud = $item.cloud.name
    name = $item.name
    owner = $item.owner.username
    dateCreated = $item.dateCreated

}

$output += $object
}
$output | Sort-Object dateCreated -Descending |  Format-Table