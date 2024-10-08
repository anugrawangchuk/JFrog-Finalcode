pipeline {
    agent any
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Select action: apply or destroy')
    }
    environment {
        // Define AWS credentials as environment variables
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        REGION                = 'us-east-1'
    }
    stages {
        stage('Checkout') {
            steps {
                // Check out the repository with Terraform code
                git branch: 'main', 
                    url: 'https://github.com/anugrawangchuk/JFrog-Finalcode.git'
            }
        }
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init \
                        -backend-config="bucket=jfrog-anugra" \
                        -backend-config="key=terraform/state" \
                        -backend-config="region=${REGION}" \
                        -backend-config="dynamodb_table=demo"
                    '''
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -lock=false'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform apply -auto-approve -lock=false
                        terraform output -raw IP_Public_Bastion > bastion_ip.txt
                        terraform output -raw IP_jfrog > jfrog_ip.txt
                    '''
                }
            }
        }
        stage('Approval for Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                // Prompt for approval before destroying resources
                input "Do you want to Terraform Destroy?"
            }
        }
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir('terraform') {
                    sh 'terraform destroy -auto-approve'
                }
            }
            post {
                always {
                    // Cleanup workspace after the build
                    cleanWs()
                }
            }
        }
        stage('Ansible Playbook Execution') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('terraform') {
                    // Checking if the output files exist before proceeding
                    script {
                        def bastionIpPath = "${env.WORKSPACE}/terraform/bastion_ip.txt"
                        def jfrogIpPath = "${env.WORKSPACE}/terraform/jfrog_ip.txt"
                        if (fileExists(bastionIpPath) && fileExists(jfrogIpPath)) {
                            def bastionIp = readFile(bastionIpPath).trim()
                            def jfrogIp = readFile(jfrogIpPath).trim()

                            // Dynamically creating the inventory file with the correct IP addresses
                            writeFile file: 'inventory', text: """
                            [bastion]
                            ${bastionIp} ansible_ssh_private_key_file=/var/lib/jenkins/Terraform_1.pem ansible_user=ubuntu
                            [Jfrog]
                            ${jfrogIp} ansible_ssh_private_key_file=/var/lib/jenkins/Terraform_1.pem ansible_user=ubuntu
                            """

                            // Disable host key checking during scp and ssh
                            sh """
                                scp -o StrictHostKeyChecking=no -i /var/lib/jenkins/Terraform_1.pem /var/lib/jenkins/Terraform_1.pem ubuntu@${bastionIp}:/home/ubuntu/
                                ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/Terraform_1.pem ubuntu@${bastionIp} 'sudo chmod 400 /home/ubuntu/Terraform_1.pem'
                            """

                            sh '''
                            ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory /var/lib/jenkins/workspace/Jfrog/playbook.yml
                            '''
                        } else {
                            error "One or both of the IP files (bastion_ip.txt, jfrog_ip.txt) were not found!"
                        }
                    }
                }
            }
        }
    }
}
