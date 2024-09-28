pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION          = 'us-east-1'
        ECR_REPO_URI                = 'account-id.dkr.ecr.us-east-1.amazonaws.com/hello-world-repo'
        TWILIO_AUTH_TOKEN           = credentials('twilio-auth-token')
        TWILIO_ACCOUNT_SID          = credentials('twilio-account-sid')
        APPLICATION_URL             = 'http://text18449410220anything.com'  // Replace with your actual application URL
        ECS_CLUSTER_NAME            = 'hello-world-cluster'
        ECS_SERVICE_NAME            = 'hello-world-service'
        ECS_TASK_EXECUTION_ROLE_ARN = 'arn:aws:iam::your-account-id:role/ecsTaskExecutionRole'  // Replace with actual ARN
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/bobdabobman/Text-Anything.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${ECR_REPO_URI}:${env.BUILD_NUMBER}")
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    sh '$(aws ecr get-login --no-include-email --region us-east-1)'
                    dockerImage.push()
                }
            }
        }
        stage('Terraform Init and Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Deploy to ECS') {
            steps {
                script {
                    // Register a new task definition with the new image
                    def taskDefinition = sh(
                        script: """
                        aws ecs register-task-definition \
                            --family hello-world-task \
                            --execution-role-arn ${ECS_TASK_EXECUTION_ROLE_ARN} \
                            --network-mode awsvpc \
                            --requires-compatibilities FARGATE \
                            --cpu "256" \
                            --memory "512" \
                            --container-definitions '[
                                {
                                    "name": "app",
                                    "image": "${ECR_REPO_URI}:${env.BUILD_NUMBER}",
                                    "essential": true,
                                    "portMappings": [
                                        {
                                            "containerPort": 5000,
                                            "hostPort": 5000,
                                            "protocol": "tcp"
                                        }
                                    ],
                                    "environment": [
                                        {
                                            "name": "TWILIO_AUTH_TOKEN",
                                            "value": "${TWILIO_AUTH_TOKEN}"
                                        },
                                        {
                                            "name": "TWILIO_ACCOUNT_SID",
                                            "value": "${TWILIO_ACCOUNT_SID}"
                                        }
                                    ],
                                    "logConfiguration": {
                                        "logDriver": "awslogs",
                                        "options": {
                                            "awslogs-group": "/ecs/hello-world-app",
                                            "awslogs-region": "${AWS_DEFAULT_REGION}",
                                            "awslogs-stream-prefix": "ecs"
                                        }
                                    }
                                }
                            ]'
                        """,
                        returnStdout: true
                    ).trim()
                    
                    // Extract task definition ARN
                    def taskDefArn = readJSON(text: taskDefinition).taskDefinition.taskDefinitionArn

                    // Update ECS service to use the new task definition
                    sh """
                    aws ecs update-service \
                        --cluster ${ECS_CLUSTER_NAME} \
                        --service ${ECS_SERVICE_NAME} \
                        --task-definition ${taskDefArn}
                    """
                }
            }
        }
        stage('Verification') {
            steps {
                script {
                    // Wait for the service to stabilize
                    sh "aws ecs wait services-stable --cluster ${ECS_CLUSTER_NAME} --services ${ECS_SERVICE_NAME}"

                    // Wait additional time if necessary
                    sleep(time: 30, unit: 'SECONDS')

                    // Check HTTP status code
                    def http_status = sh(
                        script: "curl -s -o /dev/null -w '%{http_code}' ${APPLICATION_URL}",
                        returnStdout: true
                    ).trim()

                    if (http_status == '200') {
                        echo 'HTTP status code is 200.'
                    } else {
                        error "Deployment verification failed. HTTP status code: ${http_status}"
                    }

                    // Fetch the response content
                    def response_body = sh(
                        script: "curl -s ${APPLICATION_URL}",
                        returnStdout: true
                    ).trim()

                    // Check if the response contains 'hello world'
                    if (response_body.contains('hello world')) {
                        echo 'Response contains "hello world".'
                    } else {
                        error 'Deployment verification failed. Response did not contain expected content.'
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
