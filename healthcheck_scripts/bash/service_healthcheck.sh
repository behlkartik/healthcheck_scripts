# Sophos healthcheck script
#!/usr/bin/env bash

check_service(){
    SERVICES=$(systemctl list-units —type=service | grep -e "^$1" | awk '{print $1,$4}')
    if [ -z $SERVICES ]
    then
        echo "No service named $1 found!!!"
        return 1
    fi

    for service in $SERVICES 
    do
        SERVICE_STATUS=$(echo $service | awk '{print $2}')
        SERVICE_NAME=$(echo $service | awk '{print $1}')
            retries=0
            while [ "$SERVICE_NAME" != "$2" ] && [ $retries < 5 ] 
            do      
                retries=$(($retries+1))
                echo "Trying to start service: $SERVICE_NAME, retries: $retries"
                systemctl start $SERVICE_NAME
                sleep 5 
            done
            if [ $retries == 5 ]
            then
                echo "Failed to start service $SERVICE_NAME after $reties retries"
                return 1
            else
                echo "$SERVICE_NAME is $2"
            fi
        
    done
}

EXPECTED_SERVICE_PREFIX="sav-*"
EXPECTED_SERVICE_STATUS="running"

check_service $EXPECTED_SERVICE_PREFIX $EXPECTED_SERVICE_STATUS



# # Sophos healthcheck script
# #!/usr/bin/env bash

# check_service(){
#     echo "Checking health of service $1 is $2"
#     local required_services=$(systemctl list-units --type=service --no-legend "$1"| awk '{print $1}')
#     echo "$required_services"

#     for service_name in $required_services
#     do
#         echo "checking $service_name is $2"
#         service_status=$(systemctl list-units --no-legend $service_name  | awk '{print $4}')
#         retries=0
#         echo "service status is $service_status"
#         while [ "$service_status" != "$2" ] && [ $retries -lt 5 ]
#         do
#             retries=$(($retries+1))
#             echo "Trying to start service: $service_name, retries: $retries"
#             systemctl start $service_name
#             sleep 5
#         done
#         if [[ $retries == 5 ]]
#         then
#             echo "Failed to start service $service_name after $reties retries"
#         fi
#     done
# }

# # install_ubuntu() {
# #   local bin_url="https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb"
# #   local install_cmd="dpkg -i /tmp/ssm/amazon-ssm-agent.deb"
# #   svc_stop_cmd="service amazon-ssm-agent stop"
# #   svc_start_cmd="service amazon-ssm-agent start"
# #   local svc_status_cmd="service amazon-ssm-agent status"
# #   install_generic "$bin_url" "$install_cmd" "$svc_stop_cmd" "$svc_start_cmd" "$svc_status_status"
# # }

# # install_rhel6() {
# #   local bin_url="https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm"
# #   local install_cmd="echo amazon ssm agent is already installed"
# #   if ! yum list installed amazon-ssm-agent; then
# #     install_cmd="yum install -y /tmp/ssm/amazon-ssm-agent.rpm"
# #   fi
# #   svc_stop_cmd="stop amazon-ssm-agent"
# #   svc_start_cmd="start amazon-ssm-agent"
# #   local svc_status_status="service amazon-ssm-agent status"
# #   install_generic "$bin_url" "$install_cmd" "$svc_stop_cmd" "$svc_start_cmd" "$svc_status_status"
# # }

# # install_rhel7() {
# #   local bin_url="https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm"
# #   local install_cmd="echo amazon ssm agent is already installed"
# #   if ! yum list installed amazon-ssm-agent; then
# #     install_cmd="yum install -y /tmp/ssm/amazon-ssm-agent.rpm"
# #   fi
# #   svc_stop_cmd="systemctl stop amazon-ssm-agent"
# #   svc_start_cmd="systemctl start amazon-ssm-agent"
# #   local svc_status_status="systemctl status amazon-ssm-agent"
# #   install_generic "$bin_url" "$install_cmd" "$svc_stop_cmd" "$svc_start_cmd" "$svc_status_status"
# # }

# # install_sles() {
# #   local bin_url="https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm"
# #   local install_cmd="rpm --install /tmp/ssm/amazon-ssm-agent.rpm"
# #   svc_stop_cmd="systemctl stop amazon-ssm-agent"
# #   svc_start_cmd="systemctl start amazon-ssm-agent"
# #   local svc_status_status="systemctl status amazon-ssm-agent"
# #   install_generic "$bin_url" "$install_cmd" "$svc_stop_cmd" "$svc_start_cmd" "$svc_status_status"
# # }

# # install_debian() {
# #   local bin_url="https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb"
# #   local install_cmd="sudo dpkg -i /tmp/ssm/amazon-ssm-agent.deb"
# #   svc_stop_cmd="systemctl stop amazon-ssm-agent"
# #   svc_start_cmd="systemctl start amazon-ssm-agent"
# #   local svc_status_status="systemctl status amazon-ssm-agent"
# #   install_generic "$bin_url" "$install_cmd" "$svc_stop_cmd" "$svc_start_cmd" "$svc_status_status"
# # }


# EXPECTED_SERVICE_PREFIX="sav-" # $1
# EXPECTED_SERVICE_STATUS="running" # $2


# check_service $1 $2
