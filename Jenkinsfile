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
                    url: 'https://github.com/anugrawangchuk/Test.git'
            }
        }

        stage('Terraform Init') {
            steps {
                // Initialize the Terraform backend (S3 and DynamoDB for state locking)
                sh '''
                    terraform init \
                    -backend-config="bucket=jfrog-anugra" \
                    -backend-config="key=terraform/state" \
                    -backend-config="region=${REGION}" \
                    -backend-config="dynamodb_table=demo"
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                // Show the Terraform plan with lock disabled
                sh 'terraform plan -lock=false -out=tfplan'
            }
        }

        // stage('User Approval') {
        //     input {
        //         message 'Do you want to apply the Terraform changes?'
        //         ok 'Yes, apply'
        //     }
        // }

        stage('Terraform Apply') {
            steps {
                // Apply the Terraform changes with lock disabled
                sh 'terraform apply -auto-approve -lock=false'
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
                // Destroy Infra
                sh 'terraform destroy -auto-approve'
            }
        }
    }

    // post {
    //     always {
    //         // Cleanup workspace after the build
    //         cleanWs()
    //     }
    // }
}
