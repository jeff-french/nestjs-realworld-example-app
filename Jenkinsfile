pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                nodejs('node-10-lts') {
                    sh 'npm install'
                }
            }
        }
        stage('Test') {
            steps {
            docker.image('mysql:5.7').withRun('-e "MYSQL_USER=realworld" -e "MYSQL_PASSWORD=password" -e "MYSQL_DATABASE=realworld" -e "MYSQL_RANDOM_ROOT_PASSWORD=yes" -P') { c =>
                sh """
                    cat < EOF > ormconfig.json
                    {
                      "type": "mysql",
                      "host": "localhost",
                      "port": ${c.port(3306},
                      "username": "realworld",
                      "password": "password",
                      "database": "realworld",
                      "entities": ["src/**/**.entity{.ts,.js}"],
                      "synchronize": true
                    }
                    EOF
                """
                nodejs('node-10-lts') {
                    sh 'npm test'
                }
            }
        }
        stage('Package Artifacts') {
            steps {
                archiveArtifacts artifacts: '*', excludes: '.git/', fingerprint: true, onlyIfSuccessful: true
            }
        }
    }
}
