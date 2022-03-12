Cookbookly
===
[![lerna](https://img.shields.io/badge/maintained%20with-lerna-cc00ff.svg)](https://lerna.js.org/)

Monorepo for Cookbookly apps and services

# Prereqs

- [Python]()
- [node]()
- [Docker]()
- [awslocal](https://github.com/localstack/awscli-local)

# Setup

Update `${HOME}/.aws/credentials` to contain the following profiles:

(TODO use sts)

```
[souschef]
aws_access_key_id     = <value>
aws_secret_access_key = <value>

[localstack]
aws_access_key_id=test
aws_secret_access_key=test
```

And update `${HOME}/.aws/config` and add:

```
[profile localstack]
region=us-east-1
output=json
```

```sh
docker network create localstack
pip install awscli-local
npx lerna bootstrap
```

# Development

To run `localstack`,  `docker-compose up --build`

To run AWS CLI commands against localstack, use awscli-local.

In vscode, run `cmd-shift-P` and edit the `Thundra` configuration:

```
{
    "profiles": {
        "default": {
            "debugger": {
                "authToken": "<set-your-thundra-auth-token>",
                "sessionName": "<your name here>",
                "brokerHost": "debug.thundra.io",
                "brokerPort": 443
            }
        }
    }
}
```
