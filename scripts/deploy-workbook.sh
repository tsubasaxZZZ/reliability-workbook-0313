#!/bin/sh

# Return current date and time with passed log message
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a log
}

prompt() {
    optional=$3
    read_str=
    while :
    do
        echo -n "$1"
        read read_str
        if [ x$read_str = x"" -a x$optional = x"" ]; then
            continue
        else
            break
        fi
    done
    echo $read_str > $2
}

# Get target subscription from user input
prompt "Enter target Subscription ID: " subscription_id
subscription_id=`cat subscription_id`

# Get target resource group from user input
prompt "Enter target Resource Group name: " resource_group_name
resource_group_name=`cat resource_group_name`

# Get tenant from user input
prompt "Enter target Tenant name(optional): " tenant yes
tenant=`cat tenant`
[ x$tenant != x"" ] && tenant="-t $tenant"

# az login
log "Login to Azure"
az login $tenant --use-device-code

log "Check existance of target resource group"
az group show --name $resource_group_name --subscription $subscription_id
if [ $? -ne 0 ]; then
    log "Please input correct SubscriptionID and Resource Group name"
    exit 1
fi

base_url="https://raw.githubusercontent.com/tsubasaxZZZ/reliability-workbook-0313/main/"

# Deploy Workbook
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookAdvisor.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookAzureSiteRecovery.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookCompute.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookContainers.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookDatabases.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookExport.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookIntegration.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookNetworking.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookServiceAlert.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookStorage.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookSummary.parameters.json
az deployment group create -g $resource_group_name --template-uri $base_url/build/main.bicep --parameters $base_url/artifacts/ReliabilityWorkbookWeb.parameters.json
