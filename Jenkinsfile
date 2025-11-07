// Jenkinsfile (para el pipeline Multibranch 'CICD')

pipeline {
    agent any
    
    // Variables globales (puerto y nombre de la imagen)
    environment {
        // Establecer variables basadas en el nombre de la rama
        APP_PORT = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') ? '3000' : '3001'
        IMAGE_NAME = (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') ? 'nodemain:v1.0' : 'nodedev:v1.0'
        DOCKER_REGISTRY = 'tu_dockerhub_username' // Reemplaza con tu usuario
    }
    
    tools {
        // Usar la herramienta NodeJS configurada globalmente
        nodejs 'node' 
    }
    
    stages {
        // --- 1. CHECKOUT ---
        stage('Checkout SCM') {
            steps {
                // Checkout automático por ser Multibranch Pipeline
                checkout scm 
            }
        }

        // --- 2. BUILD ---
        stage('Build Tool Install') {
            steps {
                sh 'npm install'
            }
        }
        
        // --- 3. TEST ---
        stage('Test') {
            steps {
                // Ejecutar las pruebas, asumiendo que el script 'test' está en package.json
                sh 'npm run test' 
            }
        }
        
        // --- 4. BUILD DOCKER IMAGE ---
        stage('Docker build') {
            steps {
                script {
                    // Construir la imagen con la etiqueta específica de la rama
                    sh "docker build -t ${IMAGE_NAME} ."
                    
                    // Opcional: Subir la imagen al registro (para Advanced Tasks)
                    // withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', passwordVariable: 'DOCKERPASS', usernameVariable: 'DOCKERUSER')]) {
                    //     sh "docker tag ${IMAGE_NAME} ${DOCKER_REGISTRY}/${IMAGE_NAME}"
                    //     sh "docker login -u ${DOCKERUSER} -p ${DOCKERPASS} ${DOCKER_REGISTRY}"
                    //     sh "docker push ${DOCKER_REGISTRY}/${IMAGE_NAME}"
                    // }
                }
            }
        }
        
        // --- 5. DEPLOY (Despliegue local y sencillo para el Multibranch) ---
        stage('Deploy') {
            steps {
                echo "Intentando desplegar ${IMAGE_NAME} en el puerto ${APP_PORT}:3000"
                
                // 1. Eliminar contenedores viejos
                sh "docker rm -f app-${env.BRANCH_NAME} || true"
                
                // 2. Desplegar el nuevo contenedor
                // Mapeo: Puerto de Jenkins:Puerto de Contenedor (3000 es el puerto interno en tu Dockerfile)
                sh "docker run -d --name app-${env.BRANCH_NAME} -p ${APP_PORT}:3000 ${IMAGE_NAME}"
                
                echo "Aplicación desplegada en http://localhost:${APP_PORT}"
            }
        }
    }
}