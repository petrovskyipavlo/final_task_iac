// Jenkinsfile
String credentials_id = 'pavelp'
def JENKINS_IP=""

properties([pipelineTriggers([githubPush()])])


pipeline {
  
  environment {
    envvar             ='prod'   
    plan_file          = 'plan.tfplan'
    AWS_DEFAULT_REGION ="eu-central-1"        
  }

  agent any
  options {
    disableConcurrentBuilds()
  }

  stages{

    
    stage("Checkout") {
      steps {
        git credentialsId: 'github-key', url: 'https://github.com/petrovskyipavlo/final_task_iac.git', branch: 'main'

      }
    }

    stage('Load Environment Variables') {     
        steps {
          //"env.VAULT_LOCATION="$JENKINS_HOME/.vault"" 
          script {
              load "/var/lib/jenkins/.envvars/.env.groovy"
              echo "${env.VAULT_LOCATION}"               
          }
        }
    }
    
    stage('Tools versions') {
      steps {
        sh '''
          terraform --version
          aws --version          
          docker --version
        '''
      }
    }

    stage ('Decrypt the Secrets File') {
        steps{
            sh """
              set +x 
              cd ${WORKSPACE}/terraform
              ansible-vault decrypt --vault-password-file=${env.VAULT_LOCATION}/${envvar}.txt ${env.VAULT_LOCATION}/${envvar}-secrets.tfvars       
            """
        } 
    }

    stage('Terraform Initialisation') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: credentials_id, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh 'echo "#---> Initialisation and validation infrastructure with TF..."'
          sh """            
            cd ${WORKSPACE}/terraform
            terraform init && terraform validate             
          """
        }
      }
    }

    stage('Plan Infrastructure ') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: credentials_id, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh 'echo "#---> Create  infrastructure with TF..."'
          sh """            
            cd ${WORKSPACE}/terraform                      
            terraform plan  -var-file=${env.VAULT_LOCATION}/${envvar}-secrets.tfvars
          """
        }
      }
    }

    stage("Approve Creating Infrastructure") {
      steps { approve('Do you want to create your infrastructure?') }
		}

    stage('Create Infrastructure ') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: credentials_id, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh 'echo "#---> Create  infrastructure with TF..."'
          sh """            
            cd ${WORKSPACE}/terraform                      
            terraform apply -auto-approve -var-file=${env.VAULT_LOCATION}/${envvar}-secrets.tfvars
          """
        }
      }
    }
	
	  stage('Create list of output variables') {
        steps {
          withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: credentials_id, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            sh'echo "#---> Create list of output variables..."'
            /*script{
                def JENKINS_IP=""
            }*/
            sh """              
              cd ${WORKSPACE}/terraform                         
              terraform output			         
              ${JENKINS_IP}=$(terraform output -json | jq .public_ip_jenkins_master.value)
            """
          }
      }
    }

    stage ('Re-Encrypt the Secrets File') {
        steps{
            sh """
              set +x
              cd ${WORKSPACE}/terraform   
              ansible-vault encrypt --vault-password-file=${env.VAULT_LOCATION}/${envvar}.txt ${env.VAULT_LOCATION}/${envvar}-secrets.tfvars      
            """
        }
    }

    stage('Copy Jenkins files to Jenkins in AWS') {
      steps {
          /*sshagent(credentials : ['ssh-aws']) {
					sh  '''#!/bin/bash					                   
				           ssh -o "StrictHostKeyChecking=no" ubuntu@52.14.158.47 'docker stop $(docker ps -a -q) 2> /dev/null || true'
                           ssh -o "StrictHostKeyChecking=no" ubuntu@52.14.158.47 'docker rm -f $(docker ps -a -q) 2> /dev/null || true'
	                       ssh -o "StrictHostKeyChecking=no" ubuntu@52.14.158.47 'docker rmi -f $(docker images -a -q) 2> /dev/null || true'				    
				           ssh -o "StrictHostKeyChecking=no" ubuntu@52.14.158.47 'yes | docker system prune -f 2> /dev/null || true'
                   scp [OPTIONS] [[user@]src_host:]file1 [[user@]dest_host:]file2
                   scp file.txt remote_username@10.10.0.2:/remote/directory/newfilename.txt
				        '''	
				      
			    }*/
        }
      }
    }   

  } 
    
    stage("Approve Destroying Infrastructure") {
      steps { approve('Do you want to destroy your infrastructure?') }
		}

    stage('Destroy  Infrastructure ') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: credentials_id, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh'echo "#---> Destroy infrastructure with TF..."'
          sh """            
            cd ${WORKSPACE}/terraform            
            terraform destroy -auto-approve
          """
        }
      }
    }   

  }  
  
   

} 


def approve(msg) {
	timeout(time:5, unit:'DAYS') {
		input(msg)     
	}
}





