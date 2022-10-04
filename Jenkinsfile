pipeline {
    agent any

    stages {

        stage('Checkout Git source') {
            steps {
                git url: 'https://github.com/matwolbec/jenkins-azure-vm.git', branch: 'main'
            }
        }

        stage('Terraform Apply') {
            environment {
                ARM_CLIENT_ID = credentials('ARM_CLIENT_ID')
                ARM_CLIENT_SECRET = credentials('ARM_CLIENT_SECRET')
                ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
                ARM_TENANT_ID = credentials('ARM_TENANT_ID')
                resource_group_name = credentials('resource_group_name')
                storage_account_name = credentials('storage_account_name')
                container_name = credentials('container_name')
                key = credentials('key')
                public_key_file = credentials('public_key_file')
            }
            steps {
                script {
                    sh 'terraform init \
                            --backend-config "resource_group_name=${resource_group_name}" \
                            --backend-config "storage_account_name=${storage_account_name}" \
                            --backend-config "container_name=${container_name}" \
                            --backend-config "key=${key}"'
                            
                    sh 'terraform apply --auto-approve'
                }
            }
        }

    }
}