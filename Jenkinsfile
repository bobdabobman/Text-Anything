pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION          = 'us-east-1'
        ECR_REPO_URI                = '354923279633.dkr.ecr.us-east-1.amazonaws.com/hello-world-repo'
        twilio_auth_token           = credentials('twilio-auth-token')
        twilio_account_sid          = credentials('twilio-account-sid')
        APPLICATION_URL             = 'http://text18449410220anything.com'
        ECS_CLUSTER_NAME            = 'hello-world-cluster'
        ECS_SERVICE_NAME            = 'hello-world-service'
        ECS_TASK_EXECUTION_ROLE_ARN = 'arn:aws:iam::354923279633:role/jenkins-server-instance-role'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/bobdabobman/Text-Anything.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker Image: ${ECR_REPO_URI}:${env.BUILD_NUMBER}"
                    try {
                        sh """
                        docker build -t ${ECR_REPO_URI}:${env.BUILD_NUMBER} .
                        """
                        echo "Docker Image built successfully."
                    } catch (Exception e) {
                        echo "Docker build failed: ${e}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    echo "Logging in to ECR..."
                    sh '''
                    set -x
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 354923279633.dkr.ecr.us-east-1.amazonaws.com
                    if [ $? -ne 0 ]; then
                        echo "Failed to log in to ECR"
                        exit 1
                    fi
                    '''
                    echo "Pushing Docker Image: ${ECR_REPO_URI}:${env.BUILD_NUMBER}"
                    sh """
                    docker push ${ECR_REPO_URI}:${env.BUILD_NUMBER}
                    """
                }
            }
        }
        stage('Terraform Init and Apply') {
            steps {
                dir('terraform') {
                     sh '''
                        terraform init
                        terraform apply -auto-approve \
                            -var="twilio_auth_token=${twilio_auth_token}" \
                            -var="twilio_account_sid=${twilio_account_sid}"
                        '''
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
                                            "name": "twilio_auth_token",
                                            "value": "${twilio_auth_token}"
                                        },
                                        {
                                            "name": "twilio_account_sid",
                                            "value": "${twilio_account_sid}"
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
            agent any
            steps {
                cleanWs()
            }
        }
    }
}
