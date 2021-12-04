Cookbookly
===
[![lerna](https://img.shields.io/badge/maintained%20with-lerna-cc00ff.svg)](https://lerna.js.org/)

Monorepo for Cookbookly apps and services

# Prereqs

- [Python]()
- [node]()
- [Dcker]()

# Setup

Update `${HOME}/.aws/credentials` and the following profile:

(TODO use sts)

```
[souschef]
aws_access_key_id     = <value>
aws_secret_access_key = <value>
```

```sh
docker network create localstack
pip install awscli-local
npx lerna bootstrap
```

# Development

Prior to running `localstack` via `docker-compose up --build`, run:

```sh
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
```

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
