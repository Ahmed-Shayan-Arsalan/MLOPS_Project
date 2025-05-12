pipeline {
  agent any

  environment {
    // Your Docker Hub credential ID in Jenkins
    DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
    DOCKER_IMAGE           = 'shayancyan/mlops-project'
    IMAGE_TAG              = 'latest'
  }

  triggers {
    // React to GitHub push & PR webhooks
    githubPush()
    // Fallback SCM polling every 5 minutes
    pollSCM('H/5 * * * *')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Fetch Data') {
      steps {
        script {
          if (isUnix()) {
            // On Linux agents
            sh 'python3 -m pip install --upgrade pip'
            sh 'python3 -m pip install -r requirements.txt dvc'
            sh 'dvc pull'
          } else {
            // On Windows agents
            bat 'python -m pip install --upgrade pip'
            bat 'python -m pip install -r requirements.txt dvc'
            bat 'python -m dvc pull'
          }
        }
      }
    }

    stage('Build & Tag Docker Image') {
      steps {
        script {
          // Always build the :latest image
          docker.build("${env.DOCKER_IMAGE}:${env.IMAGE_TAG}")
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', env.DOCKER_HUB_CREDENTIALS) {
            docker.image("${env.DOCKER_IMAGE}:${env.IMAGE_TAG}").push()
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Docker image ${env.DOCKER_IMAGE}:${env.IMAGE_TAG} built & pushed successfully"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}
