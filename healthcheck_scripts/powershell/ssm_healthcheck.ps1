# Check Service Status and Restart if not running #
$services= @(
    "SAVService",
    "Sophos Agent",
    "Sophos AutoUpdate Service",
    "Sophos Message Router",
    "Sophos Web Control Service",
    "SAVAdminService",
    "swi_service",
    "swi_filter",
    "sophossps",
    "Sophos System Protection Service"
    )
$services=Get-Service -Name "$servicePrefix"
$serviceNames=$services.Name
Write-Host "Services discovered $serviceNames"
$not_running = $false
$output = @()
foreach($service in $services) 
 { 
    $serviceName=$service.Name
    $service.Refresh()
    $serviceStatus = $service.Status
    if ( $serviceStatus -ne "Running" ){
        $not_running = $true
        $output += @{"service": "$serviceName", "status": "$serviceStatus" }
    }
 } 

 if ($not_running -eq $true){
    $result = $(ConvertTo-Json -InputObject @($body))
    Write-Host $result
    exit 1
 }
 exit 0
