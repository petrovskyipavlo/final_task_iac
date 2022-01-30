// Jenkinsfile
String credentials_id = 'pavelp'
properties([pipelineTriggers([githubPush()])])
pipeline {
  
  environment {
       
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
    
    stage('Tools versions') {
      steps {
        sh '''
          terraform --version
          aws --version          
          docker --version
        '''
      }
    }

    stage('Terraform Initialisation') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: credentials_id, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            echo "#---> Initialisation and validation infrastructure with TF..."
            cd ${WORKSPACE}/terraform
            terraform init && terraform validate
            
          '''
        }
      }
    }

    stage('Create Infrastructure ') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: credentials_id, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            echo "#---> Create  infrastructure with TF..."
            cd ${WORKSPACE}/terraform       
                     
            terraform apply -auto-approve
          '''
        }
      }
    }
	
	stage('Create list of output variables') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: credentials_id, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            echo "#---> Create list of output variables..."
            cd ${WORKSPACE}/terraform       
                       
            terraform output
			terraform output -json
          '''
        }
      }
    }
    
    stage("Approve") {
      steps { approve('Do you want to destroy your infrastructure?') }
		}

    stage('WARNING!!! Destroy  Infrastructure ') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: credentials_id, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            echo "#---> Destroy infrastructure with TF..."
            cd ${WORKSPACE}/terraform
            
            terraform destroy -auto-approve
          '''
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





