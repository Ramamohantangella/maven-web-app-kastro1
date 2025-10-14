pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        // Define dynamic names per branch
        IMAGE_NAME = "myapp-ram"
        CONTAINER_NAME = "myapp-${env.BRANCH_NAME}-latest"
        IMAGE_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
    }

    stages {

        stage('Git Checkout') {
            steps {
                echo "Checking out branch: ${env.BRANCH_NAME}"
                checkout scm
            }
        }

        stage('Clean old files') {
            steps {
                echo "Cleaning the project..."
                sh 'mvn clean'
            }
        }

        stage('Compile') {
            steps {
                echo "Compiling the Java project..."
                sh 'mvn compile'
            }
        }

        stage('Package WAR') {
            steps {
                echo "Packaging the project..."
                sh 'mvn package'
            }
        }

        stage('Install') {
            steps {
                echo "Installing dependencies..."
                sh 'mvn install'
            }
        }

        stage('Copy WAR to root directory') {
            steps {
                echo "Copying WAR file to root..."
                sh 'cp target/maven-web-app.war Application.war'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image for branch: ${env.BRANCH_NAME}"
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Stop and Remove Old Container (if exists)') {
            steps {
                echo "Checking for old container: ${CONTAINER_NAME}"
                script {
                    sh """
                    if [ \$(docker ps -aq -f name=${CONTAINER_NAME}) ]; then
                        echo "Stopping and removing old container..."
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true
                    fi
                    """
                }
            }
        }

        stage('Run New Container') {
            steps {
                echo "Starting new container: ${CONTAINER_NAME}"
                sh """
                docker run -d --name ${CONTAINER_NAME} -p 9099:8080 ${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }
    }

    post {
        success {
            echo "✅ Build and Deployment successful for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "❌ Build failed for branch: ${env.BRANCH_NAME}"
        }
    }
}
