pipeline {
  agent any

  environment {
    DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
    DOCKER_IMAGE           = 'shayancyan/mlops-project'
  }

  triggers {
    githubPush()
    pollSCM('H/5 * * * *')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Build and tag
          def builtImage = docker.build(
            "${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
          )
          // Record the tag
          env.BUILT_IMAGE = "${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry(
            'https://index.docker.io/v1/',
            DOCKER_HUB_CREDENTIALS
          ) {
            docker.image(env.BUILT_IMAGE).push('latest')
            docker.image(env.BUILT_IMAGE).push("${env.BUILD_NUMBER}")
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Build #${env.BUILD_NUMBER} succeeded; image pushed."
    }
    failure {
      echo "❌ Build #${env.BUILD_NUMBER} failed."
    }
  }
}
