#!/bin/bash

# trap cleanup INT

# function cleanup() {
#     echo "Exiting..."
#     cd $APP_ROOT
#     kill 0
#     docker-compose down --remove-orphans
# }

function main() {
    # if [ "$( docker container inspect -f '{{.State.Status}}' localstack )" != "running" ]; then
    #     echo ">>> Starting localstack"
    #     docker-compose up --build --detach

    #     until [ "$( docker container inspect -f '{{.State.Status}}' localstack )" == "running" ]; do
    #         echo "Docker status: $( docker container inspect -f '{{.State.Status}}' localstack )"
    #         sleep 3s
    #     done
    # else
    #     echo ">>> Localstack is already running"
    # fi

    export AWS_ACCESS_KEY_ID=test
    export AWS_ACCOUNT_ID=000000000000
    export AWS_DEFAULT_REGION=us-east-1
    export AWS_SECRET_ACCESS_KEY=test
    export AWS_REGION=us-east-1
    export DOMAIN_NAME=thesouschef.local
    export CDK_NEW_BOOTSTRAP=1

    echo ">>> Initializing boot environment"

    NODE_VERSION=16.17.0

    apt-get update
    apt-get install -y git xz-utils curl

    # install node
    curl "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" -O
    tar -xf "node-v$NODE_VERSION-linux-x64.tar.xz"
    ln -s "/node-v$NODE_VERSION-linux-x64/bin/node" /usr/local/bin/node
    ln -s "/node-v$NODE_VERSION-linux-x64/bin/npm" /usr/local/bin/npm
    ln -s "/node-v$NODE_VERSION-linux-x64/bin/npx" /usr/local/bin/npx

    # clear
    npm cache clean --force
    rm -rf /var/lib/apt/lists/*
    rm -f "/node-v$NODE_VERSION-linux-x64.tar.xz"
    apt-get clean
    apt-get autoremove

    npm install -g aws-cdk-local aws-cdk --force

    echo ">>> Deploying core AWS infrastructure"

    cd $APP_ROOT/aws

    cdklocal bootstrap
    cdklocal deploy --all --require-approval never

    export AWS_CERTIFICATE_ARN=$(aws --endpoint-url=http://localhost:4566 acm list-certificates --query 'CertificateSummaryList[].[CertificateArn,DomainName]' --output text | grep $DOMAIN_NAME | cut -f1)
    export HOSTED_ZONE_ID=$(aws --endpoint-url=http://localhost:4566 route53 list-hosted-zones-by-name --dns-name $DOMAIN_NAME --query 'HostedZones[].Id' --output text)
    export VPC_ID=$(aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs --filters Name=tag:Name,Values=thesouschef-development-vpc --query 'Vpcs[].VpcId' --output text)
    export ZONE_NAME=$(aws --endpoint-url=http://localhost:4566 route53 list-hosted-zones-by-name --dns-name $DOMAIN_NAME --query 'HostedZones[].Name' --output text)

    echo ">>> Deploying Services infrastructure"
    cd $APP_ROOT/Services/cdk/apps/infrastructure
    cdklocal deploy --all --require-approval never

    echo ">>> Deploying Web App infrastructure"
    cd $APP_ROOT/sous-chef-web/cdk/apps/infrastructure
    cdklocal deploy --all --require-approval never

    echo ">>> Upload mock configuration folder to S3"
    cd $APP_ROOT
    aws --endpoint-url=http://localhost:4566 s3 cp /var/lib/sc/mocks/appConfig.json s3://sous-chef-web-configuration/development/config.json
    aws --endpoint-url=http://localhost:4566 s3 ls s3://sous-chef-web-configuration/development

    # Waiting on https://github.com/localstack/localstack/issues/6892
    # echo ">>> Trigger an app config deployment"
    # cd $APP_ROOT/sous-chef-web/cdk/apps/appConfig
    # TOKEN=$(aws --endpoint-url=http://localhost:4566 appconfigdata start-configuration-session --application-identifier sous-chef-web --environment-identifier sous-chef-web-development-environment --configuration-profile-identifier sous-chef-web-development-configuration-profile --output text)
    # aws --endpoint-url=http://localhost:4566 appconfigdata get-latest-configuration --configuration-token $TOKEN --output text --query '' .config.txt
    # export CONFIGURATION_VERSION=
    # rm .config.txt
    # cdklocal deploy --all --require-approval never

    cd $APP_ROOT
}

main
