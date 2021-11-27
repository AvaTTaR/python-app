pipeline {
    agent {
        kubernetes {
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
            volumeMounts:
            - name: kube-conf-map
              mountPath: /root/.kube/config
              subPath: config
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
          - name: kube-conf-map
            configMap:
              name: kube-conf-map
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
        stage('Build image'){
            steps {
                //git url: 'https://github.com/AvaTTaR/python-app.git', branch: 'main'
                checkout scm
                sh '/kaniko/executor --context "`pwd`" --destination avattar/fp-app:${BUILD_NUMBER}'
            }
        }
        stage('Deploy') {
            steps {
                container('kubectl') {
                    //git url: 'https://github.com/AvaTTaR/python-app.git', branch: 'main'
                    checkout scm
                    sh 'sed -i "s/<TAG>/${BUILD_NUMBER}/" Deployment.yaml'
                    sh 'kubectl apply -f Deployment.yaml'
                }
            }
        }
    }
}
