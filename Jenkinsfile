pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose the Terraform action to perform')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')  // AWS credentials stored in Jenkins
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout the repository containing Terraform and Ansible code
                git url: 'https://github.com/your-repo/JFrog-Finalcode.git', branch: 'main'
            }
        }

        stage('Terraform Init') {
            steps {
                // Initialize Terraform
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                // Run Terraform plan to preview changes before applying
                dir('terraform') {
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                // Apply the Terraform changes with lock disabled
                dir('terraform') {
                    sh 'terraform apply -auto-approve -lock=false'
                }
            }
        }

        stage('Approval for Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                // Prompt for approval before destroying resources
                input "Do you want to proceed with Terraform Destroy?"
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                // Destroy the infrastructure
                dir('terraform') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }

        stage('Ansible Playbook Execution') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                // Run the Ansible playbook using dynamic inventory (aws_ec2.yml)
                dir('ansible') {
                    withCredentials([sshUserPrivateKey(credentialsId: 'my-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                        sh '''
                        ansible-playbook -i aws_ec2.yml playbook.yml --private-key $SSH_KEY
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            // Cleanup workspace after the build
            cleanWs()
        }
        success {
            echo 'Terraform and Ansible execution succeeded!'
        }
        failure {
            echo 'Terraform and Ansible execution failed!'
        }
    }
}
