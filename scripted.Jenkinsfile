podTemplate(yaml: '''
    apiVersion: v1
    kind: Pod
    spec:
      containers:
      - name: kaniko
        image: gcr.io/kaniko-project/executor:debug
        command:
        - sleep
        args:
        - 9999999
        volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker
      restartPolicy: Never
      volumes:
      - name: kaniko-secret
        secret:
            secretName: docker-credentials
            items:
            - key: .dockerconfigjson
              path: config.json
''') {
  node(POD_LABEL) {


    stage('Build Java Image') {
      git url: 'https://github.com/AvaTTaR/python-app.git', branch: 'main'
      container('kaniko') {
        stage('Build a Go project') {
          
          sh '''
            /kaniko/executor --context "`pwd`" --destination avattar/hello-kaniko:1.0
          '''
        }
      }
    }

  }
}