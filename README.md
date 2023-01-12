# healthcheck_scripts

Shell and Powershell scripts to check if list of services are running.
:param EXPECTED_SERVICES - List of services to check
:param EXPECTED_SERVICE_STATUS - "Running" | "Stopped" | "Dead"
:return 
  exit code 0 - if all services in EXPECTED_SERVICES are EXPECTED_SERVICE_STATUS, 
  [Failed Services string] with exit code 1 - if any of the service is not EXPECTED_SERVICE_STATUS
