#!/bin/bash

#set defaults
jenkins_url="http://localhost:8080/"
jenkins_username="admin"

# NOTE: Intentionally setting this after the first retry_until_successful to ensure the initialAdminPassword file exists
jenkins_password=`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

#process input parameters
credentials_id="docker_credentials"
credentials_desc="Docker Container Registry Credentials"
job_short_name="basic-docker-build"
job_display_name="Basic Docker Build"
job_description="A basic pipeline that builds a Docker container."
scm_poll_schedule="* * * * * *"
scm_poll_ignore_commit_hooks="0"
artifacts_location="https://raw.githubusercontent.com/valda-z/devops-azure-multiplatform/java/src/main/jenkins/"
artifacts_location_devopsutils="https://raw.githubusercontent.com/Azure/azure-devops-utils/master/"
jenkins_jdk="JDK8_121"
jenkins_maven="Maven3"

while [[ $# > 0 ]]
do
  key="$1"
  shift
  case $key in
    --jenkins_fqdn|-jf)
      jenkins_fqdn="$1"
      shift
      ;;
    --jenkins_release_type|-jrt)
      jenkins_release_type="$1"
      shift
      ;;
    --git_url|-g)
      git_url="$1"
      shift
      ;;
    --git_branch|-gb)
      git_branch="$1"
      shift
      ;;
    --docker_imagename|-img)
      docker_imagename="$1"
      shift
      ;;
    --registry|-r)
      registry="$1"
      shift
      ;;
    --registry_user_name|-ru)
      registry_user_name="$1"
      shift
      ;;
    --registry_password|-rp)
      registry_password="$1"
      shift
      ;;
    --credentials_id|-ci)
      credentials_id="$1"
      shift
      ;;
    --credentials_desc|-cd)
      credentials_desc="$1"
      shift
      ;;
    --job_short_name|-jsn)
      job_short_name="$1"
      shift
      ;;
    --job_display_name|-jdn)
      job_display_name="$1"
      shift
      ;;
    --job_description|-jd)
      job_description="$1"
      shift
      ;;
    --scm_poll_schedule|-sps)
      scm_poll_schedule="$1"
      shift
      ;;
    --scm_poll_ignore_commit_hooks|-spi)
      scm_poll_ignore_commit_hooks="$1"
      shift
      ;;
    --artifacts_location|-al)
      artifacts_location="$1"
      shift
      ;;
    --sas_token|-st)
      artifacts_location_sas_token="$1"
      shift
      ;;
    --help|-help|-h)
      print_usage
      exit 13
      ;;
    *)
      echo "ERROR: Unknown argument '$key' to script '$0'" 1>&2
      exit -1
  esac
done

######################################################################################
#
# supporting functions
#
######################################################################################
function run_util_script_devops() {
  local script_path="$1"
  shift
  curl --silent "${artifacts_location_devopsutils}${script_path}${artifacts_location_sas_token}" | sudo bash -s -- "$@"
  local return_value=$?
  if [ $return_value -ne 0 ]; then
    >&2 echo "Failed while executing script '$script_path'."
    exit $return_value
  fi
}

function throw_if_empty() {
  local name="$1"
  local value="$2"
  if [ -z "$value" ]; then
    echo "Parameter '$name' cannot be empty." 1>&2
    print_usage
    exit -1
  fi
}

function retry_until_successful {
    counter=0
    "${@}"
    while [ $? -ne 0 ]; do
        if [[ "$counter" -gt 20 ]]; then
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
    if [ ! -e jenkins-cli.jar ]; then
        >&2 echo "Downloading Jenkins CLI..."
        retry_until_successful wget ${jenkins_url}jnlpJars/jenkins-cli.jar -O jenkins-cli.jar
    fi
    >&2 echo "Running \"$1\"..."
    retry_until_successful java -jar jenkins-cli.jar -s "${jenkins_url}" -auth "${jenkins_username}":"${jenkins_password}" $1
}

function run_cli_commandfile {
    >&2 echo "Running \"$1\"..."
    >&2 echo "XML: "
    cat "$2"
    counter=0
    cat "$2" | java -jar jenkins-cli.jar -s "${jenkins_url}" -auth "${jenkins_username}":"${jenkins_password}" $1
    while [ ${PIPESTATUS[1]} -ne 0 ]; do
        if [[ "$counter" -gt 20 ]]; then
            exit 1
        else
            let counter++
        fi
        echo "Retrying ..."
        sleep 5
        cat "$2" | java -jar jenkins-cli.jar -s "${jenkins_url}" -auth "${jenkins_username}":"${jenkins_password}" $1
    done;
}

######################################################################################
#
# install part
#
######################################################################################

#check parametrs
throw_if_empty --git_url $git_url
throw_if_empty --git_branch $git_branch
throw_if_empty --registry $registry
throw_if_empty --registry_user_name $registry_user_name
throw_if_empty --registry_password $registry_password
throw_if_empty --docker_imagename $docker_imagename
throw_if_empty --jenkins_fqdn $jenkins_fqdn
throw_if_empty --jenkins_release_type $jenkins_release_type

######################################################################################
#install Jenkins by official script
######################################################################################
run_util_script_devops "jenkins/install_jenkins.sh"

#install git
sudo apt-get install git --yes

#install docker if not already installed
if !(command -v docker >/dev/null); then
  sudo curl -sSL https://get.docker.com/ | sh
fi

#make sure jenkins has access to docker cli
sudo gpasswd -a jenkins docker
skill -KILL -u jenkins
sudo service jenkins restart

#install the required plugins
plugins=(docker-workflow git build-pipeline-plugin maven-plugin pipeline-maven docker-build-step analysis-core junit-attachments tasks)
for plugin in "${plugins[@]}"; do
    run_cli_command "install-plugin $plugin -deploy"
done
run_cli_command "install-plugin credentials -restart"

#prepare credentials.xml
credentials_xml=$(curl -s ${artifacts_location}/basic-user-pwd-credentials.xml${artifacts_location_sas_token})
credentials_xml=${credentials_xml//'{insert-credentials-id}'/${credentials_id}}
credentials_xml=${credentials_xml//'{insert-credentials-description}'/${credentials_desc}}
credentials_xml=${credentials_xml//'{insert-user-name}'/${registry_user_name}}
credentials_xml=${credentials_xml//'{insert-user-password}'/${registry_password}}
#add user/pwd
echo "${credentials_xml}" > credentials.xml
run_cli_commandfile 'create-credentials-by-xml SystemCredentialsProvider::SystemContextResolver::jenkins (global)' "credentials.xml"

#download dependencies
job_xml=$(curl -s ${artifacts_location}/basic-docker-build-job.xml${artifacts_location_sas_token})
job_xml=${job_xml//'{insert-job-display-name}'/${job_display_name}}
job_xml=${job_xml//'{insert-job-description}'/${job_description}}
job_xml=${job_xml//'{insert-git-url}'/${git_url}}
job_xml=${job_xml//'{insert-git-branch}'/${git_branch}}
job_xml=${job_xml//'{insert-docker-credentials}'/${credentials_id}}
job_xml=${job_xml//'{insert-container-registry}'/${registry}}
job_xml=${job_xml//'{insert-jdk}'/${jenkins_jdk}}
job_xml=${job_xml//'{insert-maven}'/${jenkins_maven}}
job_xml=${job_xml//'{insert-docker-dockerimage}'/${docker_imagename}}


if [ -n "${scm_poll_schedule}" ]
then
  scm_poll_ignore_commit_hooks_bool="false"
  if [[ "${scm_poll_ignore_commit_hooks}" == "1" ]]
  then
    scm_poll_ignore_commit_hooks_bool="true"
  fi
  triggers_xml_node=$(cat <<EOF
<triggers>
  <hudson.triggers.SCMTrigger>
  <spec>${scm_poll_schedule}</spec>
  <ignorePostCommitHooks>${scm_poll_ignore_commit_hooks_bool}</ignorePostCommitHooks>
  </hudson.triggers.SCMTrigger>
</triggers>
EOF
)
  job_xml=${job_xml//'<triggers/>'/${triggers_xml_node}}
fi

#job_xml=${job_xml//'{insert-groovy-script}'/"$(curl -s ${artifacts_location}/Jenkinsfile${artifacts_location_sas_token})"}
echo "${job_xml}" > job.xml

run_cli_commandfile "create-job ${job_short_name}" job.xml

#change configuration
mainconfig=$(cat /var/lib/jenkins/config.xml)
newjdk=$(cat <<EOF
  <jdks>
    <jdk>
      <name>{jenkins-jdk}</name>
      <home></home>
      <properties>
        <hudson.tools.InstallSourceProperty>
          <installers>
            <hudson.tools.ZipExtractionInstaller>
              <url>https://valda.blob.core.windows.net/pub/jdk-8u121-linux-x64.tar.gz</url>
              <subdir>jdk1.8.0_121</subdir>
            </hudson.tools.ZipExtractionInstaller>
          </installers>
        </hudson.tools.InstallSourceProperty>
      </properties>
    </jdk>
  </jdks>
EOF
)
newjdk=${newjdk//'{jenkins-jdk}'/${jenkins_jdk}}
echo "${mainconfig//'<jdks/>'/${newjdk}}" > /var/lib/jenkins/config.xml


newmvn=$(cat <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<hudson.tasks.Maven_-DescriptorImpl>
  <installations>
    <hudson.tasks.Maven_-MavenInstallation>
      <name>{jenkins-maven}</name>
      <properties>
        <hudson.tools.InstallSourceProperty>
          <installers>
            <hudson.tasks.Maven_-MavenInstaller>
              <id>3.5.0</id>
            </hudson.tasks.Maven_-MavenInstaller>
          </installers>
        </hudson.tools.InstallSourceProperty>
      </properties>
    </hudson.tasks.Maven_-MavenInstallation>
  </installations>
</hudson.tasks.Maven_-DescriptorImpl>
EOF
)
newmvn=${newmvn//'{jenkins-maven}'/${jenkins_maven}}
echo "${newmvn}" > /var/lib/jenkins/hudson.tasks.Maven.xml

#final restart of jenkins to handle updates and installations
sudo service jenkins restart
