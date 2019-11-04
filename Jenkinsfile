pipeline {
    agent any
    environment {
        //be sure to replace "texanraj/welcomeapp" with your own Docker image
        DOCKER_IMAGE_NAME = "texanraj/welcomeapp"
    }
    stages {
    
        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    app = docker.build(DOCKER_IMAGE_NAME)
                }
            }
        }
        stage('Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
                        app.push("${env.BUILD_NUMBER}")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Scan Docker Image Using Aqua') {
            when {
                branch 'master'
            }    
            steps {
                script {            
              aqua customFlags: '', hideBase: false, hostedImage: DOCKER_IMAGE_NAME, localImage: '', locationType: 'hosted', notCompliesCmd: '', onDisallowed: 'ignore', policies: '', register: false, registry: '', showNegligible: true
                    }
            }
        }
        
        stage('DeployToProduction') {
            when {
                branch 'master'
            }
            steps {
//                input 'Deploy to Production?'
//                milestone(1)
                script {
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'welcomeapp.yaml',
                    enableConfigSubstitution: true
                )
              }
            }
        }
    }
}
