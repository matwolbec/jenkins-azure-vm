pipeline {
    agent any

    environment {
        ACTION = "${params.ACTION}"
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

    options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    parameters {
        choice (name: 'ACTION',
                choices: [ 'plan', 'apply', 'destroy'],
                description: 'Run terraform plan / apply / destroy')

        choice (name: 'DOCKER',
                choices: [ 'no', 'yes'],
                description: 'Pre-install docker engine')
    }

    stages {

        stage('Checkout Git source') {
            steps {
                git url: 'https://github.com/matwolbec/jenkins-azure-vm.git', branch: 'main'
            }
        }

        stage('Terraform Plan') {
            when { anyOf
                    {
                        environment name: 'ACTION', value: 'plan';
                    }
                }
            steps {
                script {
                    sh 'terraform init \
                            --backend-config "resource_group_name=${resource_group_name}" \
                            --backend-config "storage_account_name=${storage_account_name}" \
                            --backend-config "container_name=${container_name}" \
                            --backend-config "key=${key}"'
                            
                    sh 'terraform plan \
                            -var "public_key_file=${public_key_file}"'
                }
            }
        }


        stage('Terraform Apply') {
           when { anyOf
                    {
                        environment name: 'ACTION', value: 'apply';
                    }
                }
            steps {
                script {
                    sh 'terraform init \
                            --backend-config "resource_group_name=${resource_group_name}" \
                            --backend-config "storage_account_name=${storage_account_name}" \
                            --backend-config "container_name=${container_name}" \
                            --backend-config "key=${key}"'
                            
                    sh 'terraform apply --auto-approve \
                            -var "public_key_file=${public_key_file}"'
                }
            }
        }

        stage('Terraform destroy') {    
            when { anyOf
                    {
                        environment name: 'ACTION', value: 'destroy';
                    }
                }
            steps {
                script {
                    def IS_APPROVED = input(
                        message: "Destroy?",
                        parameters: [
                            string(name: 'IS_APPROVED', defaultValue: 'Yes', description: 'Are you sure?')
                        ]
                    )
                    if (IS_APPROVED != 'Yes') {
                        currentBuild.result = "ABORTED"
                        error "User cancelled"
                    }
                }

                script {
                    sh 'terraform init \
                            --backend-config "resource_group_name=${resource_group_name}" \
                            --backend-config "storage_account_name=${storage_account_name}" \
                            --backend-config "container_name=${container_name}" \
                            --backend-config "key=${key}"'
                            
                    sh 'terraform destroy --auto-approve \
                            -var "public_key_file=${public_key_file}"'
                }
            }
        }
        
        stage('Install Docker Engine') {
           when { anyOf
                    {
                        environment name: 'DOCKER', value: 'yes';
                    }
                }
            steps {
                    ansiblePlaybook(
                        become: true,
                        colorized: true,
                        credentialsId: 'TF_adminuser_key',
                        inventory: 'azurerm_linux_virtual_machine_public_ip',
                        disableHostKeyChecking: true,
                        installation: 'ansible',
                        playbook: 'ansible.yml')
            }
        }
    }
}