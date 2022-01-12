pipeline {
    agent any
    tools {
        terraform 'Terraform-11'
    }

    stages {
        stage('Git Checkout') {
            steps {
                 git branch: 'build', credentialsId: 'abhitahaa', url: 'https://github.com/abhitahaa/jenkins_terraform/'
            }
        }
        stage('terraform init') {
            steps {
                 sh label: '', script: 'terraform init'
            }
        }
        stage('terraform plan') {
            steps {
                 sh label: '', script: 'terraform plan'
            }
        }
    }
    
}
