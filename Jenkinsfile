pipeline {
    environment {
        DOCKER_ID = "elie150100" // replace this with your docker-id
        DOCKER_MOVIE_IMAGE = "movie-service"
        DOCKER_CAST_IMAGE = "cast-service"
        DOCKER_TAG = "v.${BUILD_ID}.0" // Tag our images with the current build
    }
    agent any // Jenkins will be able to select all available agents
    stages {
        stage('Docker Build') { // Docker build image stage
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

        stage('Docker Run') { // Run container from our built image
            steps {
                script {
                    sh '''
                    docker run -d -p 80:80 --name jenkins $DOCKER_ID/$DOCKER_MOVIE_IMAGE:$DOCKER_TAG
                    docker run -d -p 80:80 --name jenkins $DOCKER_ID/$DOCKER_CAST_IMAGE:$DOCKER_TAG
                    sleep 10
                    '''
                }
            }
        }

        stage('Test Acceptance') { // Validate the container responds to the request
            steps {
                script {
                    sh '''
                    curl http://localhost:8081/api/v1/movies/docs
                    '''
                }
            }
        }

        stage('Docker Push') { // Push the built images to Docker Hub
            environment {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS") // Retrieve Docker password
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
                KUBECONFIG = credentials("config") // Retrieve kubeconfig
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    ls
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

        stage('Deploiement en staging') {
            environment {
                KUBECONFIG = credentials("config") // Retrieve kubeconfig
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    ls
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
                KUBECONFIG = credentials("config") // Retrieve kubeconfig
            }
            steps { // Add the missing `steps` block
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    ls
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
