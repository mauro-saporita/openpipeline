pipeline {
  agent {
    kubernetes {
      yamlFile 'agentPod.yaml'
    }
  }

  stages {
    stage ('1. TESTS') {
      steps {
        container('agent') {
          sh """
            git config --global --add safe.directory /home/jenkins/agent/workspace/openpipelines/push

            bin/init

            aws s3 cp s3://itx-bmo-openpipelines-devops/viash_tag ./bin/
            chmod +x ./bin/viash_tag

            bin/viash_tag -b target -t main_build -r itx-aiv.artifactrepo.jnj.com -s ghcr.io -o openpipelines-bio

            bin/viash_push -m release -t main_build
          """
        }
      }
    }
  }
}
