# Check Service Status and Restart if not running #
$EXPECTED_SERVICES= @(
    "SAVService",
    "Sophos Agent",
    "Sophos AutoUpdate Service",
    "Sophos Message Router",
    "Sophos Web Control Service",
    "SAVAdminService",
    "swi_service",
    "swi_filter",
    "Sophos System Protection Service"
    )
$EXPECTED_SERVICE_STATUS="Running"
$are_services_expected_status = $true
$services_not_expected_status = @()
foreach($service in $services) 
 { 
    $serviceName=$service.Name
    $service.Refresh()
    $serviceStatus = $service.Status
    if ( $serviceStatus -ne $EXPECTED_SERVICE_STATUS ){
        $are_services_expected_status = $false
        $services_not_expected_status += @("$serviceName")
    }
 } 

 if ($are_services_expected_status -eq $false){
    $result = "Not $EXPECTED_SERVICE_STATUS services: $($services_not_expected_status -join ',')"
    Write-Host $result
    exit 1
 }
 exit 0
