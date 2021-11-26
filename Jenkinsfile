pipeline {
    agent {
        kubernetes {
        //cloud 'kubernetes'
        defaultContainer 'kaniko'
        yaml '''
        kind: Pod
        spec:
          containers:
          - name: kubectl
            image: joshendriks/alpine-k8s
            command:
            - sleep
            args:
            - 99d
          - name: kaniko
            image: gcr.io/kaniko-project/executor:v1.6.0-debug
            imagePullPolicy: Always
            command:
            - sleep
            args:
            - 99d
            volumeMounts:
              - name: jenkins-docker-cfg
                mountPath: /kaniko/.docker
          volumes:
          - name: jenkins-docker-cfg
            projected:
              sources:
              - secret:
                  name: docker-credentials
                  items:
                    - key: .dockerconfigjson
                      path: config.json
            '''
        }
    }
    stages {
        stage('test') {
            steps {
                container('kubectl') {
                        withCredentials([file(credentialsId: 'mykubeconfig', variable: 'KUBECONFIG')]) {
                        git url: 'https://github.com/AvaTTaR/python-app.git', branch: 'main'
                        sh 'kubectl apply -f Deployment.yaml'
                    }
                }
            }
        }
    }
}