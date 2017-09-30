#!/bin/bash

#####################################################################
# user defined parameters
LOCATION=""
RESOURCEGROUP=""
KUBERNETESNAME=""
ACRNAME=""
POSTGRESQLNAME=""
POSTGRESQLUSER="kubeadmin"
POSTGRESQLPASSWORD="KubE123...EbuK"
JENKINSPASSWORD="pwd123..."

while [[ $# > 0 ]]
do
  key="$1"
  shift
  case $key in
    --location)
      LOCATION="$1"
      shift
      ;;
    --resource-group)
      RESOURCEGROUP="$1"
      shift
      ;;
    --kubernetes-name)
      KUBERNETESNAME="$1"
      shift
      ;;
    --acr-name)
      ACRNAME="$1"
      shift
      ;;
    --postgresql-name)
      POSTGRESQLNAME="$1"
      shift
      ;;
    --postgresql-user)
      POSTGRESQLUSER="$1"
      shift
      ;;
    --postgresql-password)
      POSTGRESQLPASSWORD="$1"
      shift
      ;;
    --jenkins-password)
      JENKINSPASSWORD="$1"
      shift
      ;;
    *)
      echo "ERROR: Unknown argument '$key' to script '$0'" 1>&2
      exit -1
  esac
done


function throw_if_empty() {
  local name="$1"
  local value="$2"
  if [ -z "$value" ]; then
    echo "Parameter '$name' cannot be empty." 1>&2
    exit -1
  fi
}

#check parametrs
throw_if_empty --location $LOCATION
throw_if_empty --resource-group $RESOURCEGROUP
throw_if_empty --kubernetes-name  $KUBERNETESNAME
throw_if_empty --acr-name  $ACRNAME
throw_if_empty --postgresql-name $POSTGRESQLNAME
throw_if_empty --postgresql-user $POSTGRESQLUSER
throw_if_empty --postgresql-password $POSTGRESQLPASSWORD
throw_if_empty --jenkins-password $JENKINSPASSWORD

#####################################################################
# constants
APPINSIGHTSNAME="${KUBERNETESNAME}-appinsights"
GITURL="https://github.com/valda-z/devops-azure-multiplatform.git"
GITBRANCH="java-k8s"
JENKINSJOBNAME="MyJava"
IMAGENAME="myjavawebapp"
HELMCHART="myjavawebapp"
HELMRELEASE="myjavawebapp"
JENKINSSERVICENAME="myjenkins"
SSHPUBKEY=~/.ssh/id_rsa.pub
KUBERNETESADMINUSER=$(whoami)

#####################################################################
# internal variables
KUBE_JENKINS=""
JENKINS_USER="admin"
JENKINS_KEY=""
REGISTRY_SERVER=""
REGISTRY_USER_NAME=""
REGISTRY_PASSWORD=""
CREDENTIALS_ID=${REGISTRY_SERVER}
CREDENTIALS_DESC=${REGISTRY_SERVER}
POSTGRESQLSERVER_URL="jdbc:postgresql://{postgresqlfqdn}:5432/postgres?user={postgresqluser}@{postgresqlname}&password={postgresqlpassword}&ssl=true"
APPINSIGHTS_KEY=""

#############################################################
# supporting functions
#############################################################
function retry_until_successful {
    counter=0
    echo "      .. EXEC:" "${@}"
    "${@}"
    while [ $? -ne 0 ]; do
        if [[ "$counter" -gt 50 ]]; then
            exit 1
        else
            let counter++
        fi
        echo "Retrying ..."
        sleep 5
        "${@}"
    done;
}

function run_cli_command {
    >&2 echo "      .. Running \"$1\"..."
    if [ -z "$2" ]; then
        retry_until_successful kubectl exec ${KUBE_JENKINS} -- java -jar  /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth "${JENKINS_USER}":"${JENKINS_KEY}" $1
    else
        retry_until_successful kubectl cp "$2" ${KUBE_JENKINS}:/tmp/tmp.xml
        tmpcmd="cat /tmp/tmp.xml | java -jar  /var/jenkins_home/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 -auth \"${JENKINS_USER}\":\"${JENKINS_KEY}\" $1"
        tmpcmd="${tmpcmd//'('/'\('}"
        tmpcmd="${tmpcmd//')'/'\)'}"
        echo "${tmpcmd}" > mycmd
        retry_until_successful kubectl cp mycmd ${KUBE_JENKINS}:/tmp/mycmd
        retry_until_successful kubectl exec ${KUBE_JENKINS} -- sh /tmp/mycmd
        retry_until_successful kubectl exec ${KUBE_JENKINS} -- rm /tmp/mycmd
        retry_until_successful kubectl exec ${KUBE_JENKINS} -- rm /tmp/tmp.xml
        rm mycmd
    fi
}

#############################################################
# create Azure resources
#############################################################

### login to Azure
# az login

### create resource group
echo "  .. create Resource group"
az group create --name ${RESOURCEGROUP} --location ${LOCATION} > /dev/null

### create kubernetes cluster
echo "  .. create ACS with kubernetes"
az acs create --orchestrator-type kubernetes --resource-group ${RESOURCEGROUP} --name ${KUBERNETESNAME} --location ${LOCATION} --ssh-key-value "$(< ${SSHPUBKEY})" > /dev/null

### create application insights
echo "  .. create App Insights"
APPINSIGHTS_KEY=$(az resource create -g ${RESOURCEGROUP} -n ${APPINSIGHTSNAME} --resource-type microsoft.insights/components --is-full-object --properties "{ \"location\": \"${LOCATION}\", \"kind\": \"web\",  \"properties\": { \"ApplicationId\": \"${APPINSIGHTSNAME}\"  }}" --query [properties.InstrumentationKey] -o tsv)

### create postgresql as a service
echo "  .. create postgresql PaaS database"
az postgres server create -l ${LOCATION} -g ${RESOURCEGROUP} -n ${POSTGRESQLNAME} -u ${POSTGRESQLUSER} -p ${POSTGRESQLPASSWORD} --performance-tier Basic --compute-units 50 --ssl-enforcement Enabled --storage-size 51200 > /dev/null
az postgres server firewall-rule create -g ${RESOURCEGROUP} -s ${POSTGRESQLNAME} -n allowall --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255 > /dev/null
read postgresqlfqdn <<< $(az postgres server show -g ${RESOURCEGROUP} -n ${POSTGRESQLNAME} --query [fullyQualifiedDomainName] -o tsv)
POSTGRESQLSERVER_URL=${POSTGRESQLSERVER_URL//'{postgresqlfqdn}'/${postgresqlfqdn}}
POSTGRESQLSERVER_URL=${POSTGRESQLSERVER_URL//'{postgresqlname}'/${POSTGRESQLNAME}}
POSTGRESQLSERVER_URL=${POSTGRESQLSERVER_URL//'{postgresqluser}'/${POSTGRESQLUSER}}
POSTGRESQLSERVER_URL=${POSTGRESQLSERVER_URL//'{postgresqlpassword}'/${POSTGRESQLPASSWORD}}

### create ACR
echo "  .. create ACR"
az acr create -n ${ACRNAME} -g ${RESOURCEGROUP} --location ${LOCATION} --admin-enabled true --sku Basic > /dev/null
read REGISTRY_SERVER <<< $(az acr show -g ${RESOURCEGROUP} -n ${ACRNAME} --query [loginServer] -o tsv)
read REGISTRY_USER_NAME REGISTRY_PASSWORD <<< $(az acr credential show -g ${RESOURCEGROUP} -n ${ACRNAME} --query [username,passwords[0].value] -o tsv)

#############################################################
# configure kubectl, helm
#############################################################

echo "  .. configuring kubectl and helm"

echo "      .. get kubectl credentials"
### initialize .kube/config
az acs kubernetes get-credentials --resource-group=${RESOURCEGROUP} --name=${KUBERNETESNAME} > /dev/null
retry_until_successful kubectl get nodes

echo "      .. helm init"
### initialize helm
retry_until_successful helm init --upgrade > /dev/null
sleep 10

#############################################################
# jenkins installation / configuration
#############################################################

echo "  .. installing jenkins"

echo "      .. helming jenkins"
### install jenkins to kubernetes cluster
helm install --name ${JENKINSSERVICENAME} stable/jenkins --set "Master.AdminPassword=${JENKINSPASSWORD}" >/dev/null

echo "      .. waiting for pods"
### get node name
echo -n "         ."
KUBE_JENKINS=""
while [  -z "$KUBE_JENKINS" ]; do
    echo "."
    sleep 3
    KUBE_JENKINS=$(kubectl get pods | grep "\-jenkins\-" | awk '{print $1;}')
done
echo ""

echo "      .. configuring jenkins"
### get jenkins token
retry_until_successful kubectl exec ${KUBE_JENKINS} -- curl -D - -s -k -X POST -c /tmp/cook.txt -b /tmp/cook.txt -d j_username=${JENKINS_USER} -d j_password=${JENKINSPASSWORD} http://localhost:8080/j_security_check &>/dev/null
JENKINS_KEY=$(kubectl exec ${KUBE_JENKINS} -- curl -D - -s -k -c /tmp/cook.txt -b /tmp/cook.txt http://localhost:8080/me/configure | grep "apiToken" | sed -n 's/.*id=.apiToken.\(.*\)\/>.*/\1/p' | sed -n 's/.*value=\"\([[:xdigit:]^>]*\)\".*/\1/p' 2>/dev/null)

### create secrets for ACR

credentials_xml=$(cat <<EOF
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>{insert-credentials-id}</id>
  <description>{insert-credentials-description}</description>
  <username>{insert-user-name}</username>
  <password>{insert-user-password}</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF
)

#add user/pwd
credentials_xml=${credentials_xml//'{insert-credentials-id}'/${CREDENTIALS_ID}}
credentials_xml=${credentials_xml//'{insert-credentials-description}'/${CREDENTIALS_DESC}}
credentials_xml=${credentials_xml//'{insert-user-name}'/${REGISTRY_USER_NAME}}
credentials_xml=${credentials_xml//'{insert-user-password}'/${REGISTRY_PASSWORD}}
echo "${credentials_xml}" > tmp.xml
run_cli_command 'create-credentials-by-xml SystemCredentialsProvider::SystemContextResolver::jenkins (global)' "tmp.xml"
rm tmp.xml

### importing job

job_xml=$(cat <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.13">
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.StringParameterDefinition>
          <name>acr</name>
          <description></description>
          <defaultValue>{acr}</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>giturl</name>
          <description></description>
          <defaultValue>{giturl}</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>gitbranch</name>
          <description></description>
          <defaultValue>{gitbranch}</defaultValue>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>imagename</name>
          <description></description>
          <defaultValue>{imagename}</defaultValue>
        </hudson.model.StringParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers/>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.40">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@3.4.0">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>{giturl}</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/{gitbranch}</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>src/main/jenkins/Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF
)

job_xml=${job_xml//'{acr}'/${REGISTRY_SERVER}}
job_xml=${job_xml//'{giturl}'/${GITURL}}
job_xml=${job_xml//'{gitbranch}'/${GITBRANCH}}
job_xml=${job_xml//'{imagename}'/${IMAGENAME}}
echo "${job_xml}" > tmp.xml
run_cli_command "create-job ${JENKINSJOBNAME}" "tmp.xml"
rm tmp.xml

#############################################################
# configure kubernetes credentials
#############################################################

echo "  .. install kubernetes security assets"
### create secrets (which will be used by helm install later on)
kubectl create secret generic ${HELMRELEASE}-${HELMCHART} --from-literal=application-insights-ikey="${APPINSIGHTS_KEY}" --from-literal=postgresqlserver-url="${POSTGRESQLSERVER_URL}"

#############################################################
# wait for jenkins public IP
#############################################################

echo "  .. waiting for jenkins public IP"
echo -n "     ."
JENKINS_IP=""
while [  -z "$JENKINS_IP" ]; do
    echo "."
    sleep 3
    JENKINS_IP=$(kubectl describe service myjenkins-jenkins | grep "LoadBalancer Ingress:" | awk '{print $3}')
done
echo ""

echo "### DONE!"
echo "### now you can login to http://${JENKINS_IP}:8080 with username: ${JENKINS_USER} , password: ${JENKINSPASSWORD}"
