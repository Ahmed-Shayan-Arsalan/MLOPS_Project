pipeline {
  agent any

  environment {
    // your Docker Hub credentials ID
    DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
    DOCKER_IMAGE           = 'shayancyan/mlops-project'
  }

  triggers {
    // react to GitHub webhooks
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
          // build and tag the image
          def builtImage = docker.build(
            "${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
          )
          // store tag for later
          env.BUILT_IMAGE = "${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
        }
      }
    }

    stage('Run Tests on Host') {
      steps {
        script {
          if (isUnix()) {
            sh 'pytest --maxfail=1 --disable-warnings -q'
          } else {
            bat 'pytest --maxfail=1 --disable-warnings -q'
          }
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          // push only if tests passed
          docker.withRegistry('https://index.docker.io/v1/', DOCKER_HUB_CREDENTIALS) {
            docker.image(env.BUILT_IMAGE).push('latest')
            docker.image(env.BUILT_IMAGE).push("${env.BUILD_NUMBER}")
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ Build #${env.BUILD_NUMBER} succeeded and image pushed"
    }
    failure {
      echo "❌ Build #${env.BUILD_NUMBER} failed"
    }
  }
}
