pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    stages {

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

        stage('Build & Deploy Docker') {
            steps {
                script {
                    // Docker image/container name based on branch
                    def branchSafe = env.BRANCH_NAME.replaceAll('/', '-')
                    def dockerImage = "mohan/maven-web-app:${branchSafe}"
                    def containerName = "maven-web-app-${branchSafe}"

                    // Delete old image if exists
                    def imageExists = sh(
                        script: "docker images -q ${dockerImage}",
                        returnStdout: true
                    ).trim()
                    if (imageExists) {
                        echo "🗑️ Removing existing Docker image ${dockerImage}..."
                        sh "docker rmi -f ${dockerImage}"
                    }

                    // Build Docker image
                    sh "docker build -t ${dockerImage} ."

                    // Remove old container if exists
                    sh """
                        if [ \$(docker ps -aq -f name=${containerName}) ]; then
                            docker rm -f ${containerName}
                        fi
                    """

                    // Find free port
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

                    // Run container
                    sh "docker run -d --name ${containerName} -p ${freePort}:8080 ${dockerImage}"
                    echo "✅ Application running at http://<host>:${freePort}"
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
