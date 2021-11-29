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
                sh 'sed -i "s/<TAG>/${BUILD_NUMBER}/" application/demo/views.py'
                sh '/kaniko/executor --context "`pwd`" --destination avattar/fp-app:${BUILD_NUMBER}'
            }
        }
        stage('Deploy') {
            steps {
                container('kubectl') {
                    //git url: 'https://github.com/AvaTTaR/python-app.git', branch: 'main'
                    checkout scm
                    sh '''
                    if [[ "$(kubectl -n application get deploy)" ]]
                    then
                        echo "There is active application running. Starting canary update"
                        sed -i "s/<TAG>/${BUILD_NUMBER}/" canary-deployment.yaml
                        kubectl apply -f canary-deployment.yaml -f Service.yaml
                        sleep 60


                        if [[ $(kubectl -n application get pods | grep app-canary-deployment | wc -l | awk '{print $1}') != $(kubectl -n application get pods | grep app-canary-deployment | grep Running | wc -l | awk '{print $1}') ]]
                        then
                          echo "Something went wrong, rollback to previously version"
                          kubectl -n application delete deployment app-canary-deployment
                        else
                          echo "New version looks fine, finishing deploy"
                          sed -i "s/<TAG>/${BUILD_NUMBER}/" Deployment.yaml
                          echo "    version: \\"${BUILD_NUMBER}\\"" >> Service.yaml
                          kubectl apply -f Deployment.yaml -f Service.yaml
                          kubectl -n application delete deployment app-canary-deployment
                        fi


                        
                    else
                      echo "There is no active application instances, deploing"
                      sed -i "s/<TAG>/${BUILD_NUMBER}/" Deployment.yaml
                      echo "    version: \\"${BUILD_NUMBER}\\"" >> Service.yaml
                      kubectl apply -f Deployment.yaml -f Service.yaml
                   fi
                  '''
                }
            }
        }
    }
}
