# service healthcheck script
#!/usr/bin/env bash

: ' only check service is running/dead/terminated or not 
  if all expected services are expected status
    return 0
  else
    echo which services are not expected status
    return 1
'
declare -a EXPECTED_SERVICES=("sav-protect.service" "sav-rms.service")
EXPECTED_SERVICE_STATUS="running"
OS_UNSUPPORTED=4
services_not_expected_status=()

function join(){
    local IFS="$1"
    shift
    echo "$*"
}


find_value() {
  local key="$1"
  if [[ -f /etc/centos-release ]]; then
    [[ "${key}" == "ID" ]] && echo "centos" && return
    if [[ "${key}" == "VERSION_ID" ]]; then
      local version
      version=$(awk '{ for (i=1; i<=NF; ++i) { if ($i ~ /[[0-9]]/) print $i } }' /etc/centos-release)
      echo "${version}"
      return
    fi
  fi
  if [[ -f /etc/redhat-release ]]; then
    [[ "${key}" == "ID" ]] && echo "rhel" && return
    [[ "${key}" == "VERSION_ID" ]] && awk '{ for (i=1; i<=NF; ++i) { if ($i ~ /[[0-9]]/) print $i } }' /etc/redhat-release && return
  fi
  [[ -f /etc/os-release ]] && awk "/^$key=/" /etc/os-release | sed "s/\($key=\"\?\|\"$\)//g" && return
}

distro=$(find_value ID)
distro_version=$(find_value VERSION_ID)

get_service_status(){
  result=''
  if [[ $distro == "rhel" || $distro == "centos"  ]] && [[ $distro_version == 6* ]] 
  then
    status_info=$(service $1 status | awk 'NR==3')
    read prefix active expected_info <<< $status_info
    result=$( echo $expected_info | sed -e 's/(//g' | sed -e 's/).*//g' )
  else
    result=$(systemctl list-units -a --no-legend $1  | awk '{print $4}')
  fi
  
  echo $result
}

check_service(){
    are_services_expected_status=0
    for service_name in ${EXPECTED_SERVICES[@]}
    do
        service_status=$(get_service_status $service_name)
        if [[ $service_status != $EXPECTED_SERVICE_STATUS  ]]
        then
            are_services_expected_status=1
            services_not_expected_status+=("$service_name")
        fi
    done

    if [[ $are_services_expected_status -eq 1 ]]
    then
        echo "Not $EXPECTED_SERVICE_STATUS services: $( join , ${services_not_expected_status[@]})"
    fi
  
    exit $are_services_expected_status

}

check_service_ubuntu(){
    check_service
}

check_service_rhel6(){
    check_service
}

check_service_rhel7(){
    check_service
}

check_service_sles(){
    check_service
}
check_service_debian(){
    check_service
}


execute_check_service_with_distro(){
  case $distro in
  ubuntu)
    check_service_ubuntu
    ;;
  centos | rhel)
    if [[ "${distro_version}" == 6* ]]; then
      check_service_rhel6
    else
      check_service_rhel7
    fi
    ;;
  sles)
    check_service_sles
    ;;
  debian)
    check_service_debian
    ;;
  *)
    echo "Operating System unsupported."
    send_error $OS_UNSUPPORTED
    exit 1
    ;;
  esac
}

execute_check_service_with_distro