pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Terraform action to run')
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_IN_AUTOMATION   = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                // Terraform code lives in the ec2-main-1 repo
                git branch: 'main', url: 'https://github.com/Shafi23/ec2-main-1.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id',     variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id',     variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    script {
                        if (params.ACTION == 'destroy') {
                            sh 'terraform plan -destroy -input=false -out=tfplan'
                        } else {
                            sh 'terraform plan -input=false -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('Approval') {
            steps {
                input message: "Review the plan above. Proceed with terraform ${params.ACTION}?", ok: 'Yes, proceed'
            }
        }

        stage('Terraform Apply / Destroy') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id',     variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
    }

    post {
        success {
            echo "Terraform ${params.ACTION} completed successfully."
        }
        failure {
            echo "Terraform ${params.ACTION} failed. Check the stage logs above."
        }
        cleanup {
            sh 'rm -f tfplan'
        }
    }
}
