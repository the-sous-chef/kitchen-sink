# The Kitchen Sink

Development environment for The Sous Chef ecosystem.

## Setup

### Install

- [volta](https://volta.sh/). Used to manage our node environments
- [dotnet core](https://dotnet.microsoft.com/en-us/download)
- [Docker](https://docs.docker.com/get-docker/)

### Contributing

TBD

### Developing

Whether you're testing one service in isolation or testing integration, we use [localstack](https://localstack.cloud/) to mock AWS services instead of running development clouds or testing against production. To run localstack:

```sh
cd localstack

docker-compose up --build
```

This will start locastack and deploy all cloud infrastructure. From there you can individually deploy services/servers.

- [ ] TODO allow selection of which service infrastructure to deploy
- [ ] TODO docker caching or cloud pods for faster startup
