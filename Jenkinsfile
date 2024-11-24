pipeline {
    environment { 
        DOCKER_ID = "elie150100" // Remplacez par votre Docker ID
        DOCKER_MOVIE_IMAGE = "movie-service"
        DOCKER_CAST_IMAGE = "cast-service"
        DOCKER_TAG = "v.${BUILD_ID}.0" // Tag basé sur l'ID de build
    }
    agent any // Jenkins utilisera tous les agents disponibles

    stages {
        stage(' Docker Build') { // Construire les images Docker
            steps {
                script {
                    sh '''
                    docker rm -f jenkins
                    docker build -t $DOCKER_ID/$DOCKER_MOVIE_IMAGE:$DOCKER_TAG .
                    docker build -t $DOCKER_ID/$DOCKER_CAST_IMAGE:$DOCKER_TAG .
                    sleep 6
                    '''
                }
            }
        }

        stage('Docker Push') { // Pousser les images vers Docker Hub
            environment {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS") // Mot de passe Docker Hub
            }
            steps {
                script {
                    sh '''
                    docker login -u $DOCKER_ID -p $DOCKER_PASS
                    docker push $DOCKER_ID/$DOCKER_MOVIE_IMAGE:$DOCKER_TAG
                    docker push $DOCKER_ID/$DOCKER_CAST_IMAGE:$DOCKER_TAG
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
                    cat values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    kubectl get namespace dev || kubectl create namespace dev
                    helm upgrade --install app fastapi --values=values.yml --namespace dev
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
                    cat values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    kubectl get namespace qa || kubectl create namespace qa
                    helm upgrade --install app fastapi --values=values.yml --namespace qa
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
                    cat values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    kubectl get namespace staging || kubectl create namespace staging
                    helm upgrade --install app fastapi --values=values.yml --namespace staging
                    '''
                }
            }
        }

        stage('Deploiement en prod') {
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
                    cat values.yml
                    sed -i "s+tag.*+tag: ${DOCKER_TAG}+g" values.yml
                    kubectl get namespace prod || kubectl create namespace prod
                    helm upgrade --install app fastapi --values=values.yml --namespace prod
                    '''
                }
            }
        }
    }
}

