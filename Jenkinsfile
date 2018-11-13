def GIT_COMMIT = 'UNKNOWN'

pipeline {
    agent any

    tools {
      git 'system'
      nodejs 'node-10-lts'
    }

    stages {
        stage('Build') {
            steps {
                sh 'npm install'
            }
        }
        stage('Test') {
            when {
                expression { false == true }
            }
            steps {
                script {
                    docker.image('mysql:5.7').withRun('-e "MYSQL_USER=realworld" -e "MYSQL_PASSWORD=password" -e "MYSQL_DATABASE=realworld" -e "MYSQL_RANDOM_ROOT_PASSWORD=yes" -P') { c ->
                        docker.image('mysql:5').inside("--link ${c.id}:db") {
                            /* Wait until mysql service is up */
                            sh 'while ! mysqladmin ping -hdb --silent; do sleep 1; done'
                        }

                        sh """
                            cat << EOF > ormconfig.json
{
  "type": "mysql",
  "host": "localhost",
  "port": ${c.port(3306)},
  "username": "realworld",
  "password": "password",
  "database": "realworld",
  "entities": ["src/**/**.entity{.ts,.js}"],
  "synchronize": true
}
EOF
                        """
                        sh 'cp src/config.ts.example src/config.ts'
                        nodejs('node-10-lts') {
                            sh 'npm test'
                        }
                    }
                }
            }
        }
        stage('Publish Artifacts') {
            steps {
                script {
                    GIT_COMMIT = sh( script: 'git rev-parse HEAD', returnStdout: true ).trim()
                }
                sh """
                    touch api-${GIT_COMMIT}.tar.gz
                    tar -czf api-${GIT_COMMIT}.tgz . --exclude .git --exclude coverage --exclude api-${GIT_COMMIT}.tgz
                """
                archiveArtifacts artifacts: "api-${GIT_COMMIT}.tgz", fingerprint: true, onlyIfSuccessful: true
                s3Upload acl: 'Private', bucket: 'upli-builds', file: "api-${GIT_COMMIT}.tgz", path: 'api/'
            }
        }
    }
}
