# service healthcheck script
#!/usr/bin/env bash

: ' only check service is running or not 
  if all services related to service prefix are running
    return 0
  else
    prepare error json as {"error": "Description of what failed"} &
    return 1
'
# yum install -y jq
declare -a EXPECTED_SERVICES=("sav-protect.service" "sav-rms.service")
EXPECTED_SERVICE_STATUS="running"
OS_UNSUPPORTED=4
not_running_services=()

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
    read prefix active running_info <<< $status_info
    result=$( echo $running_info | sed -e 's/(//g' | sed -e 's/).*//g' )
  else
    result=$(systemctl list-units -a --no-legend $1  | awk '{print $4}')
  fi
  
  echo $result
}

check_service(){
    # echo "checking services ${EXPECTED_SERVICES[@]} is state:$EXPECTED_SERVICE_STATUS for distribution:$distro with version:$distro_version"
    not_running=1
    for service_name in ${EXPECTED_SERVICES[@]}
    do
        # echo "checking $service_name is $EXPECTED_SERVICE_STATUS"
        service_status=$(get_service_status $service_name)
        # echo "service status is $service_status"
        if [[ $service_status != $EXPECTED_SERVICE_STATUS  ]]
        then
            not_running=0
            # output=$(echo $output | jq '. += [[{"service": "'"$service_name"'", "status": "'"$service_status"'"}]]')
            not_running_services+=("$service_name")
        fi
    done

    if [[ $not_running -eq 0 ]]
    then
        echo "Not $EXPECTED_SERVICE_STATUS services: $( join , ${not_running_services[@]})"
        exit 1
    else
        exit 0
    fi

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