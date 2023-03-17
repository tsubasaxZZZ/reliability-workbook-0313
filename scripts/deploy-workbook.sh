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
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/advisor.parameters.json --query 'properties.outputs.resource_id.value' -o json > advisor_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/azuresiterecovery.parameters.json --query 'properties.outputs.resource_id.value' -o json > azuresiterecovery_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/compute.parameters.json --query 'properties.outputs.resource_id.value' -o json > compute_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/containers.parameters.json --query 'properties.outputs.resource_id.value' -o json > containers_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/databases.parameters.json --query 'properties.outputs.resource_id.value' -o json > databases_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/export.parameters.json --query 'properties.outputs.resource_id.value' -o json > export_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/integration.parameters.json --query 'properties.outputs.resource_id.value' -o json > integration_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/networking.parameters.json --query 'properties.outputs.resource_id.value' -o json > networking_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/servicealert.parameters.json --query 'properties.outputs.resource_id.value' -o json > servicealert_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/storage.parameters.json --query 'properties.outputs.resource_id.value' -o json > storage_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/summary.parameters.json --query 'properties.outputs.resource_id.value' -o json > summary_id
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters $base_url/artifacts/web.parameters.json --query 'properties.outputs.resource_id.value' -o json > web_id

[ ! -e workbook.tpl.json ] && wget $base_url/build/templates/workbook.tpl.json
for f in *_id
do
    resource_id=`cat $f | tr -d '\"'`
    resource_type=`echo $f | sed 's/_id//g'`
    # Replace placeholder in the file by sed
    sed -i "s#\\\${${resource_type}_workbook_resource_id}#$resource_id#g" workbook.tpl.json
done

overview_information=$(cat <<EOS
          ,{
            "type": 1,
            "content": {
              "json": "* This workbook source is maintained publicly as OpenSource in [GitHub Repository](https://github.com/Azure/reliability-workbook). There is no Service Level guarantees or warranties associated with the usage of this workbook. Refer [license](https://github.com/Azure/reliability-workbook/blob/main/LICENSE) for more details.\r\n\r\n> If there are any bugs or suggestions for improvements, feel free to raise an issue in the above GitHub repository. In case you want to reach out to maintainers, please email to [FTA Reliability vTeam](mailto:fta-reliability-team@microsoft.com)",
              "style": "info"
            },
            "name": "text - 3"
          }
EOS
)

escaped_replacement_text=$(printf '%s\n' "$overview_information" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${overview_information}/$escaped_replacement_text/g" workbook.tpl.json

link_of_Summary=$(cat <<EOS
          ,{
            "id": "d6656d8e-acfc-4d7d-853d-a8c628907ba6",
            "cellValue": "selectedTab",
            "linkTarget": "parameter",
            "linkLabel": "Summary",
            "subTarget": "Summary2",
            "style": "link"
          }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$link_of_Summary" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${link_of_Summary}/$escaped_replacement_text/g" workbook.tpl.json

summary_id=$(cat summary_id)
tab_of_Summary=$(cat <<EOS
    ,{
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "template",
        "loadFromTemplateId": "${summary_id}",
        "items": []
      },
      "conditionalVisibility": {
        "parameterName": "selectedTab",
        "comparison": "isEqualTo",
        "value": "Summary2"
      },
      "name": "summary group"
    }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$tab_of_Summary" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${tab_of_Summary}/$escaped_replacement_text/g" workbook.tpl.json


link_of_Advisor=$(cat <<EOS
         ,{
            "id": "d983c7c7-b5a0-4245-86fa-52ac1266fb13",
            "cellValue": "selectedTab",
            "linkTarget": "parameter",
            "linkLabel": "Azure Advisor",
            "subTarget": "Advisor",
            "style": "link"
          }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$link_of_Advisor" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${link_of_Advisor}/$escaped_replacement_text/g" workbook.tpl.json

advisor_id=$(cat advisor_id)
tab_of_Advisor=$(cat <<EOS
    ,{
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "template",
        "loadFromTemplateId": "${advisor_id}",
        "items": []
      },
      "conditionalVisibility": {
        "parameterName": "selectedTab",
        "comparison": "isEqualTo",
        "value": "Advisor"
      },
      "name": "Advisor"
    }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$tab_of_Advisor" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${tab_of_Advisor}/$escaped_replacement_text/g" workbook.tpl.json

link_of_Export=$(cat <<EOS
          ,{
            "id": "0f548bfa-f959-4a25-a9ac-7c986be6d33b",
            "cellValue": "selectedTab",
            "linkTarget": "parameter",
            "linkLabel": "Export",
            "subTarget": "Export",
            "style": "link"
          }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$link_of_Export" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${link_of_Export}/$escaped_replacement_text/g" workbook.tpl.json

export_id=$(cat export_id)
tab_of_Export=$(cat <<EOS
    ,{
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "template",
        "loadFromTemplateId": "${export_id}",
        "items": []
      },
      "conditionalVisibility": {
        "parameterName": "selectedTab",
        "comparison": "isEqualTo",
        "value": "Export"
      },
      "name": "ExportStep"
    }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$tab_of_Export" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${tab_of_Export}/$escaped_replacement_text/g" workbook.tpl.json

