pipeline {
  agent any

  environment {
    DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
    DOCKER_IMAGE            = 'shayancyan/mlops-project'
  }

  triggers {
    // react to GitHub webhooks for PRs & pushes
    githubPush()
    // fallback polling every 5 minutes
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
          dockerImage = docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
        }
      }
    }

    stage('Run Tests') {
      steps {
        sh """
          docker run --rm \
            ${DOCKER_IMAGE}:${BUILD_NUMBER} \
            pytest --maxfail=1 --disable-warnings -q
        """
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_CREDENTIALS) {
            dockerImage.push('latest')
            dockerImage.push("${BUILD_NUMBER}")
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Build #${BUILD_NUMBER} succeeded on test"
    }
    failure {
      echo "❌ Build #${BUILD_NUMBER} failed on test"
    }
  }
}
