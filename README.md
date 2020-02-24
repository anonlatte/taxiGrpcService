# Taxi application stack

## Getting started

I were interested to created something like Uber or Gett, so I decided create the same application for a college degree.

### Overview

It contains [microservice](https://github.com/anonlatte/taxiGrpcService), which has been written in Go using gRPC, android [driver's application](https://github.com/anonlatte/TaxiService/tree/master/drivers_app), [user's application](https://github.com/anonlatte/TaxiService/tree/master/customers_app) and primitive desktop [disptatcher's application](https://github.com/anonlatte/DispatcherApp) were written in Kotlin. Desktop application (**dispactcher's app**) is using JavaFX12\. MySQL was chosen as a database due to its comfortable data presentation.

## Quick start

### Requirements

- Docker
- Docker-Compose

You can use the [prepared image](https://hub.docker.com/r/anonlatte/taxi-grpc-service) and run it by this command.

```
docker run -p 48690:48690 --entrypoint "/go/bin/taxiGrpcService" anonlatte/taxi-grpc-service -grpc-port=48690 -db-host=mysql:3306 -db-user=root -db-password=root -db-schema=taxi
```

**Use your own credentials, ports and database name**

### Service installing

1. Clone [service's repository](https://github.com/anonlatte/taxiGrpcService) and check the settings.

#### Basic service's settings

##### Dockerfile environment settings

[Source file link](https://github.com/anonlatte/taxiGrpcService/blob/master/.env)

```
Paths to
    * mysql folder          -   DB_PATH_HOST=./databases
    * source files          -   APP_PATH_HOST=./src
    * main Dockerfile       -   APP_PATH_DOCKER=/go/src/taxiGrpcService
gRPC port number            -   GRPC_PORT=48695
MySQL
    * database host         -   DB_HOST=db:3306
    * database username     -   DB_USER=root
    * user's password       -   DB_PASSWORD=157266
    * schema name           -   DB_SCHEMA=taxi
    * dump file             -   DB_RESTORE_TARGET=./dumps/db_dump.sql
```

## Mobile application

After all we can test the [mobile applications](http://github.com/anonlatte/TaxiService).

## Built With

- [gRPC](https://github.com/grpc/grpc-go)

## Authors

- [Proshunin German](https://www.linkedin.com/in/anonlatte/)

See also the list of [contributors](https://github.com/anonlatte/taxiGrpcService/graphs/contributors) who participated in this project.

## License

This project is licensed under GNU GENERAL PUBLIC LICENSE - see the <LICENSE> file for more details.
