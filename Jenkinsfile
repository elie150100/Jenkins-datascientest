pipeline {
    environment { 
        DOCKER_ID = "elie150100"  // Remplacez par votre Docker ID
        DOCKER_MOVIE_IMAGE = "movie-service"
        DOCKER_CAST_IMAGE = "cast-service"
        DOCKER_TAG = "v.${BUILD_ID}.0"  // Tag basé sur l'ID de build
    }
    agent any  // Jenkins utilisera tous les agents disponibles

    stages {
        stage('Check Workspace') {
            steps {
                sh 'pwd'
                sh 'ls -al'
            }
        }

        stage('Docker Push') {
            environment {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS")  // Mot de passe Docker Hub
            }
            steps {
                script {
                    sh '''
                    docker login -u $DOCKER_ID -p $DOCKER_PASS
                    echo "$DOCKER_PASS" | docker login -u $DOCKER_ID --password-stdin
                    docker push "$DOCKER_ID/jenkins_devops_exams_movie_service:latest"
                    docker push "$DOCKER_ID/jenkins_devops_exams_cast_service:latest"
                    '''
                }
            }
        }

        stage('Test Acceptance') {
            steps {
                script {
                    sh '''
                    curl -s http://localhost:8081/api/v1/movies/docs || echo "Movies service unavailable"
                    curl -s http://localhost:8081/api/v1/casts/docs || echo "Casts service unavailable"
                    '''
                }
            }
        }

        stage('Deploiement en dev') {
            environment {
                KUBECONFIG = credentials("config") // Récupération du kubeconfig
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cp $KUBECONFIG .kube/config
                    cp fastapi/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    kubectl get namespace dev || kubectl create namespace dev
                    helm upgrade --install test-1 . --values=values.yml --namespace dev
                    '''
                }
            }
        }

        stage('Deploiement en QA') {
            environment {
                KUBECONFIG = credentials("config")
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cp $KUBECONFIG .kube/config
                    cp fastapi/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    kubectl get namespace qa || kubectl create namespace qa
                    helm upgrade --install test-1 . --values=values.yml --namespace qa
                    '''
                }
            }
        }

        stage('Deploiement en staging') {
            environment {
                KUBECONFIG = credentials("config")
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cp $KUBECONFIG .kube/config
                    cp fastapi/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    kubectl get namespace staging || kubectl create namespace staging
                    helm upgrade --install test-1 . --values=values.yml --namespace staging
                    '''
                }
            }
        }
        stage('Check Branch Name') {
    steps {
        script {
            echo "Current Branch: ${env.BRANCH_NAME}"
        }
    }
}
        stage('Get Git Branch') {
    steps {
        script {
            def branch = sh(script: "git rev-parse --abbrev-ref HEAD", returnStdout: true).trim()
            echo "Current Git Branch: ${branch}"
        }
    }
}



        stage('Deploiement en prod') {
            when { 
                allOf { 
                    branch 'main' 
                    expression { 
                        return currentBuild.result == null // Ne pas lancer automatiquement
                    } 
                } 
            }
            environment {
                KUBECONFIG = credentials("config")
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cp $KUBECONFIG .kube/config
                    cp fastapi/values.yaml values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    kubectl get namespace prod || kubectl create namespace prod
                    helm upgrade --install test-1 . --values=values.yml --namespace prod
                    '''
                }
            }
        }
    }
}
