pipeline {
  agent any

  environment {
    DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
    DOCKER_IMAGE           = 'shayancyan/mlops-project'
    IMAGE_TAG              = 'latest'
  }

  triggers {
    githubPush()
    pollSCM('H/5 * * * *')
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build & Tag Docker Image') {
      steps {
        script {
          // build with a fixed 'latest' tag every time
          docker.build("${env.DOCKER_IMAGE}:${env.IMAGE_TAG}")
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_CREDENTIALS) {
            docker.image("${env.DOCKER_IMAGE}:${env.IMAGE_TAG}").push()
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Successfully built & pushed ${DOCKER_IMAGE}:${IMAGE_TAG}"
    }
    failure {
      echo "❌ Build failed"
    }
  }
}
