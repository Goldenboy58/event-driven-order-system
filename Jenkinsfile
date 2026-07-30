pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Checking Python syntax...'
                sh 'python3 -m py_compile lambda_function.py'
            }
        }
        stage('Test') {
            steps {
                echo 'Running basic validation...'
                sh 'python3 -c "import lambda_function; print(\'Lambda module loads successfully\')"'
            }
        }
        stage('Package') {
            steps {
                echo 'Packaging Lambda function...'
                sh 'zip -u function.zip lambda_function.py'
            }
        }
    }
}
