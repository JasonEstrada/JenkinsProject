// Jenkinsfile (para el pipeline Multibranch 'CICD')

pipeline {
    agent any
    
    // Variables globales (puerto y nombre de la imagen)
    environment {
        DOCKER_REGISTRY = '13102003'
    }
    
    tools {
        // Usar la herramienta NodeJS configurada globalmente
        nodejs 'node' 
    }
    
    stages {
        // --- 1. CHECKOUT ---
        stage('Checkout SCM') {
            steps {
                checkout scm 
            }
        }

        // --- 2. BUILD (npm install) ---
        stage('Build Tool Install') {
            steps {
                    bat 'npm install'
            }
        }
        
        // --- 3. TEST ---
        stage('Test') {
            steps {
                // Comando corregido
                bat 'npm run test' 
            }
        }
        
        // --- 4. BUILD & PUSH DOCKER IMAGE ---
        stage('Docker Build & Push') {
            steps {
                script {
                    // Lógica Condicional: Definir variables de Groovy
                    def appPort = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') ? '3000' : '3001'
                    def imageName = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') ? 'nodemain:v1.0' : 'nodedev:v1.0'
                    def fullImageName = "${DOCKER_REGISTRY}/${imageName}"

                    echo "Construyendo imagen: ${fullImageName}"
                    
                    // 1. Construir la imagen
                    bat "docker build -t ${fullImageName} ."
                    
                    // 2. Subir la imagen al registro usando credenciales
                    // IMPORTANTE: Debes tener una credencial de Jenkins guardada con el ID 'docker-hub-creds'
                    // (Tipo Username with password: tu_usuario_dockerhub / tu_token_dockerhub)
                    
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', 
                                                     passwordVariable: 'DOCKERPASS', 
                                                     usernameVariable: 'DOCKERUSER')]) {
                        bat "docker login -u %DOCKERUSER% -p %DOCKERPASS% "
                        bat "docker push ${fullImageName}"
                    }
                    
                    // Exportar variables de entorno para la siguiente etapa (opcional, pero buena práctica)
                    env.APP_PORT = appPort
                    env.IMAGE_NAME = fullImageName
                }
            }
        }
        
        // --- 5. DEPLOY (Despliegue local y sencillo) ---
        stage('Deploy') {
            steps {
                script {
                    def appPort = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') ? '3000' : '3001'
                    def containerName = "app-${env.BRANCH_NAME}"
                    
                    def deployImage = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') ? "${env.DOCKER_REGISTRY}/nodemain:v1.0" : "${env.DOCKER_REGISTRY}/nodedev:v1.0"

                    echo "Intentando desplegar ${deployImage} en el puerto ${appPort}:3000"
                    
                    bat "docker rm -f ${containerName} || true"
                    
                    bat "docker run -d --name ${containerName} -p ${appPort}:3000 ${deployImage}"
                    
                    echo "Aplicación desplegada en http://localhost:${appPort}"
                }
            }
        }
    }
}