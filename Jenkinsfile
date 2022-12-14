def USER_APPROVAL
pipeline {
    agent {
        kubernetes {
            cloud "kubernetes"
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    job: rest-service-build-pod
spec:
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
      type: Socket
  containers:
  - name: helm
    image: alpine/helm
    tty: true
    command: ['cat'] 
  - name: mvn
    image: maven
    tty: true
    command: ['cat']   
  - name: docker
    image: docker
    tty: true
    command: ['cat']
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: functest
    image: sijinnalpadi/alpine
    tty: true
    command: ['cat'] 
  - name: perftest
    image: sijinnalpadi/hey
    tty: true
    command: ['cat']       
         
'''
        }
    }
   environment {
        registry = "sijinnalpadi/restserviceapi"
        registryCredential = 'dockerhub'
        dockerImage = ''
    }
    stages {
        stage('Cloning our Git') {
            steps {
                git 'https://github.com/SijinNalpadi/rest-service.git'
            }
        }

        stage('Maven Build') {
            steps{
                container('mvn') {
                    script {
                        sh 'mvn -B -DskipTests clean package'
                    }
                }
            }
        }

        stage('Maven Test') {
            steps{
                container('mvn') {
                    script {
                        sh 'mvn test'
                    }
                }
            }
        }

        stage('Code Quality Check') {
            steps{
                container('mvn') {
                    withSonarQubeEnv('sonar') {
                        script {
                            sh 'mvn clean package sonar:sonar -Dsonar.projectKey=rest-service -Dsonar.organization=sonarjavasample'
                    }
                }
                }
            }
        }

        stage('Publish Code to Nexus') {
            steps{
                container('mvn') {
                    configFileProvider([configFile(fileId: 'mavenglobal', variable: 'MAVEN_SETTINGS')]) { 
                    script {
                        
                        sh 'mvn -s $MAVEN_SETTINGS deploy'
                    }
                    }
                }
            }
        } 
        
        stage('Building Docker Image for APIs') {
            steps{
                container('docker') {
                    script {
                        dockerImage = docker.build registry + ":$BUILD_NUMBER"
                    }
                }
            }
        }

        stage('Pushing Docker Image to Registry') {
            steps{
                  container('docker') {
                    script {
                      docker.withRegistry( '', registryCredential ) {
                      dockerImage.push()
                      }
                    }
                 }
            }
        }
        
        stage ('Deploy Code to Development Environment'){
            steps{
                container('helm') {
                    withCredentials([file(credentialsId: 'kube-config', variable: 'KUBECONFIG')]){    
                        script{
                            sh 'helm upgrade --install devopsapp --namespace dev --set image.name=$registry:$BUILD_NUMBER apphelm/'

                        }            
                    }
                }
            }
        }      

        stage('Performing App Functional Test') {
            steps{
                container('functest') {
                    script {
                        sh '''
                            chmod +x apptest.sh
                            bash apptest.sh
                        '''
                    }
                }
            }
        }

        stage('Performing App Performance Test') {
            steps{
                container('perftest') {
                    script {
                        sh '''
                            /hey -n 10 -c 5 http://34.242.57.126/greeting
                        '''
                    }
                }
            }
        }

        stage('Approval') {
            steps{
                container('functest') {
                    script {
                        USER_APPROVAL = input(
                            message: 'Proceed with production deployment?',
                            parameters: [
                                [$class: 'ChoiceParameterDefinition',
                                choices: ['no','yes'].join('\n'),
                                name: 'User Approval',
                                description: '']
                            ])
                    echo "The selection is: ${USER_APPROVAL}"
                    }
                }
            }
        }	

        stage ('Deploy Code to Production Environment'){
            when {
                    expression { "${USER_APPROVAL}" == "yes" }
                }
            steps{
                container('helm') {
                    withCredentials([file(credentialsId: 'kube-config', variable: 'KUBECONFIG')]){    
                        script{

                            sh 'helm upgrade --install devopsapp --namespace prod --set image.name=$registry:$BUILD_NUMBER --set ingress.hosts[0].paths[0].path=/greetingprod --set ingress.hosts[0].paths[0].pathType=ImplementationSpecific apphelm/'

                        }            
                    }
                }
            }
        }              

    }

}
