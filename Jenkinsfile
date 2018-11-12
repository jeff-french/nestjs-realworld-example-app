dev shortCommit = 'UNKNOWN'

pipeline {
    agent any

    tools {
      git 'Default'
      nodejs 'node-10-lts'
    }

    stages {
        stage ('Prepare Variables') {
            steps {
                script {
                    shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
                }
            }
        }
        stage('Build') {
            steps {
                echo "${shortCommit}"
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
        stage('Package Artifacts') {
            steps {
                sh "tar -czf api-${shortCommit}.tar.gz * --exlclude .git --exclude coverage"
                archiveArtifacts artifacts: "api-${shortCommit}.zip", fingerprint: true, onlyIfSuccessful: true
                s3Upload acl: 'Private', bucket: 'upli-builds', file: 'api-${shortCommit}.tar.gz', path: 'api/'
            }
        }
    }
}
