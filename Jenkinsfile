pipeline {
  agent any

  environment {
    // update this to match the Jenkins credential ID you created
    DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
    DOCKER_IMAGE            = 'shayancyan/mlops-project'
  }

  // optional: fallback polling every 5 minutes if webhook is missed
  triggers {
    pollSCM('H/5 * * * *')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      when {
        anyOf {
          // PRs whose target branch is `test`
          changeRequest target: 'test'
          // any direct commits (push/merge) into `test`
          branch 'test'
          // if you also want to build for main
          // changeRequest target: 'main'
          // branch 'main'
        }
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
        anyOf {
          changeRequest target: 'test'
          branch 'test'
        }
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
        anyOf {
          changeRequest target: 'test'
          branch 'test'
        }
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
      echo "✅ Pipeline succeeded on ${env.BRANCH_NAME} (Build #${env.BUILD_NUMBER})"
    }
    failure {
      echo "❌ Pipeline failed on ${env.BRANCH_NAME}"
    }
  }
}
