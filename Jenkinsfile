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
           
            sh """            
              cd ${WORKSPACE}/terraform                      
              terraform output
              terraform output -json
              
            """  
            //def JENKINS_IP = sh(script: "$(terraform output -json | jq .public_ip_jenkins_master.value)" , returnStdout: true)
            //println JENKINS_IP 

            //https://issues.jenkins.io/browse/JENKINS-55771
            // define GIT_COMMIT_EMAIL before pipeline or inside script
            /*script {
                JENKINS_IP= sh (
                script: 'terraform output -json | jq .public_ip_jenkins_master.value',
                returnStdout: true
                ).trim()
            }*/
                        
            //sh "JENKINS_IP=$(terraform output -json | jq .public_ip_jenkins_master.value) " 

            //https://stackoverflow.com/questions/36547680/how-do-i-get-the-output-of-a-shell-command-executed-using-into-a-variable-from-j
            /*script{
                sh "cd ${WORKSPACE}/terraform"   
                sh "rm -f command"              
                sh 'terraform output -json | jq .public_ip_jenkins_master.value > command '
                def command_var = readFile('command').trim()
                sh "export JENKINS_IP=$command_var"
                
            }*/ 

            //terraform output -json | jq .public_ip_jenkins_master.value > command out null from Jenkins, but works correct from terminal
            //https://stackoverflow.com/questions/758031/stripping-single-and-double-quotes-in-a-string-using-bash-standard-linux-comma
            //sh 'echo "Jenkins IP: ${JENKINS_IP}"'
            sh '''
               #!/bin/bash
               aws_ip=$(aws ec2 describe-instances  --filters "Name=tag:Name,Values=Jenkins" --query "Reservations[0].Instances[0].PublicIpAddress" )
               JENKINS_IP=$(eval echo ${aws_ip})
               '''
            sh 'echo "Jenkins IP: ${JENKINS_IP}"' 
                        
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
          sshagent(credentials : ['ssh-aws']) {
					      sh  '''#!/bin/bash  
				       	    
				        #aws_ip=$(aws ec2 describe-instances  --filters "Name=tag:Name,Values=Jenkins" --query "Reservations[0].Instances[0].PublicIpAddress" )
                #JENKINS_IP=$(eval echo ${aws_ip})  
                scp /var/lib/jenkins/ ubuntu@${JENKINS_IP}:/var/lib/jenkins/
                ssh -o "StrictHostKeyChecking=no" ubuntu@${JENKINS_IP} rm -rf /var/lib/jenkins/jobs/Infrastructure
                ssh -o "StrictHostKeyChecking=no" ubuntu@${JENKINS_IP} rm -rf /var/lib/jenkins/.terraform.d
                ssh -o "StrictHostKeyChecking=no" ubuntu@${JENKINS_IP} chown jenkins -R /var/lib/jenkins && chgrp jenkins -R /var/lib/jenkins
				        '''	
				      
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





