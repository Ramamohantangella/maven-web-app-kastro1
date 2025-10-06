pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        // Safe branch name for Docker image/container (replace '/' with '-')
        BRANCH_NAME_SAFE = env.BRANCH_NAME.replaceAll('/', '-')
        DOCKER_IMAGE = "mohan/maven-web-app:${BRANCH_NAME_SAFE}"
        CONTAINER_NAME = "maven-web-app-${BRANCH_NAME_SAFE}"
    }

    stages {

        stage('Check Branch') {
            when {
                expression { env.BRANCH_NAME.startsWith('Feature/') }
            }
            steps {
                echo "✅ Branch ${env.BRANCH_NAME} is a feature branch. Proceeding..."
            }
        }

        stage('Checkout') {
            steps {
                echo "📥 Checking out branch ${env.BRANCH_NAME}..."
                checkout scm
            }
        }

        stage('Build Maven Project') {
            steps {
                echo "🔨 Building WAR..."
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Prepare WAR for Docker') {
            steps {
                echo "📦 Copying WAR file to Docker context..."
                sh "cp target/maven-web-app.war app.war"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Preparing Docker image ${DOCKER_IMAGE}..."
                script {
                    // Delete old image if exists
                    def imageExists = sh(
                        script: "docker images -q ${DOCKER_IMAGE}",
                        returnStdout: true
                    ).trim()
                    if (imageExists) {
                        echo "🗑️ Removing existing Docker image ${DOCKER_IMAGE}..."
                        sh "docker rmi -f ${DOCKER_IMAGE}"
                    }

                    echo "📦 Building new Docker image ${DOCKER_IMAGE}..."
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                echo "🚀 Deploying Docker container ${CONTAINER_NAME}..."
                script {
                    // Remove old container if exists
                    sh """
                        if [ \$(docker ps -aq -f name=${CONTAINER_NAME}) ]; then
                            echo '🗑️ Removing existing container...'
                            docker rm -f ${CONTAINER_NAME}
                        fi
                    """

                    // Find a free port between 8000-9000
                    def freePort = sh(
                        script: """
                            for port in \$(seq 8000 9000); do
                                if ! ss -Htan | awk '{print \$4}' | grep -q ":\\\$port\$"; then
                                    echo \$port
                                    break
                                fi
                            done
                        """,
                        returnStdout: true
                    ).trim()
                    echo "Selected free port: ${freePort}"

                    // Run container
                    sh "docker run -d --name ${CONTAINER_NAME} -p ${freePort}:8080 ${DOCKER_IMAGE}"
                    echo "✅ Application is running at http://<host>:${freePort}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build & deployment successful for branch ${env.BRANCH_NAME}!"
        }
        failure {
            echo "❌ Build or deployment failed for branch ${env.BRANCH_NAME}. Check logs."
        }
    }
}
