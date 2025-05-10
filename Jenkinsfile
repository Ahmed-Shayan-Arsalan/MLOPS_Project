/pipeline {
  agent any

  environment {
    DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
    DOCKER_IMAGE            = 'shayancyan/mlops-project'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      when {
        changeRequest target: 'test'
      }
      steps {
        script {
          dockerImage = docker.build(
            "${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
          )
        }
      }
    }

    stage('Run Tests') {
      when {
        changeRequest target: 'test'
      }
      steps {
        sh '''
          docker run --rm \
            ${DOCKER_IMAGE}:${BUILD_NUMBER} \
            pytest --maxfail=1 --disable-warnings -q
        '''
      }
    }

    stage('Push to Docker Hub') {
      when {
        changeRequest target: 'test'
      }
      steps {
        script {
          docker.withRegistry(
            'https://index.docker.io/v1/', 
            "${env.DOCKER_HUB_CREDENTIALS}"
          ) {
            dockerImage.push('latest')
            dockerImage.push("${env.BUILD_NUMBER}")
          }
        }
      }
    }
  }

  post {
    success {
      echo "✅ PR → test pipeline succeeded: pushed ${DOCKER_IMAGE}:${BUILD_NUMBER} & :latest"
    }
    failure {
      echo "❌ PR → test pipeline failed."
    }
  }
}
