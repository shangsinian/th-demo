#!/usr/bin/env groovy

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(daysToKeepStr: '30', artifactDaysToKeepStr: "20"))
        disableConcurrentBuilds()
        skipStagesAfterUnstable()
        timestamps()
        preserveStashes(buildCount: 20)
        ansiColor('xterm')
    }

    environment {
        DEPLOY_BRANCH  = "master"
        EMAIL_RECEP    = "huanggan1992@gmail.com"
    }

    stages {

        stage('Fetch Git Version') {
            steps {
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: scm.branches,
                        doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                        extensions: [[$class: 'CloneOption', noTags: false, shallow: false, depth: 0, reference: '']],
                        userRemoteConfigs: scm.userRemoteConfigs,
                     ])
                    env.gitVersion=sh(returnStdout: true, script: "git describe --always | sed 's/^v//'").trim()
                    echo gitVersion
                }
            }
        }

        stage('Build') {
            steps {
                echo "Build docker image"
            }
        }

        stage('Deploy to Dev Sandbox') {
            steps {
                echo "Deploy to QA"
            }
        }

        stage('Deploy to QA') {
            when {
                branch env.DEPLOY_BRANCH
            }
            steps {
                echo "Deploy to QA"
            }
        }

        stage('Deploy to Pre Prod') {
            when {
                branch env.DEPLOY_BRANCH
            }
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        checkout scm
                        approvalRet = input message: 'Deploy to prod?',
                                            submitterParameter: 'APPROVER',
                                            parameters: [
                                              string(name: 'IMAGE_NAME', defaultValue: "${env.gitVersion}", description: 'The docker image to deploy', trim: true),
                                            ]
                        userList = readYaml file: "OWNERS"
                        if (approvalRet['APPROVER'] in userList) {
                            echo "INFO: User ${approvalRet['APPROVER']} is one of the approvers, proceeding..."
                        } else {
                            error("ERROR: User ${approvalRet['APPROVER']} is not allowed to approve this stage!, please post your email address to OWNERS to get the permission")
                        }
                    }
                }
                script {
                    parallel(
                        'pre-prod1': {
                            echo "Deploying to prod1"
                        },
                        'pre-prod2' {
                            echo "Deploying to prod2"
                        }
                    )
                }
            }
        }

        stage('Running tests against Pre Prod') {
            when {
                branch env.DEPLOY_BRANCH
            }
            steps {
                echo "Running tests against Pre Prod"
            }
        }

        stage('Deploy to Prod') {
            when {
                branch env.DEPLOY_BRANCH
            }
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        checkout scm
                        approvalRet = input message: 'Deploy to prod?',
                                            submitterParameter: 'APPROVER',
                                            parameters: [
                                              string(name: 'IMAGE_NAME', defaultValue: "${env.gitVersion}", description: 'The docker image to deploy', trim: true),
                                            ]
                        userList = readYaml file: "OWNERS"
                        if (approvalRet['APPROVER'] in userList) {
                            echo "INFO: User ${approvalRet['APPROVER']} is one of the approvers, proceeding..."
                        } else {
                            error("ERROR: User ${approvalRet['APPROVER']} is not allowed to approve this stage!, please post your email address to OWNERS to get the permission")
                        }
                    }
                }
                script {
                    parallel(
                        'prod1': {
                            echo "Deploying to prod1"
                        },
                        'prod2' {
                            echo "Deploying to prod2"
                        }
                    )
                }
            }
        }
    }
    post {
        always {
             slackSend channel: 'test',
                       message: "[${env.BUILD_URL}]"
        }
    }
}
