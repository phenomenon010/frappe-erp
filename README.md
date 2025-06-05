
# Getting Started

To get started you need [Docker](https://docs.docker.com/get-docker/), [docker-compose](https://docs.docker.com/compose/), and [git](https://docs.github.com/en/get-started/getting-started-with-git/set-up-git) setup on your machine. For Docker basics and best practices refer to Docker's [documentation](http://docs.docker.com).

## List of Included apps
(*)hrms
(*)crm
(*)helpdesk
(*)property management system
(*)non_profit
(*)lending
(*)lms
(*)studio
(*)builder
(*)print designer
(*)webshop
(*)payments
(*)wiki
(*)raven
(*)nextproject
(*)erpnext price estimation
(*)csf tz
(*)propms
(*)twilio integration
(*)newsletter
(*)insights

## Plugins
(*)geopy
(*)uuid_utils

## Default Configurations 
(Edit build-workspace/inint.sh to change)
set-config default_country `"United States"`
set-config default_currency `"USD"`
set-config default_company `"Dynamic Solutions"`
set-config fiscal_year `"2025-2026"`

### Try out

Clone the repo and run docker compose:

```sh
git clone
```

To Run:
`docker compose up -d`
or
`docker compose -f custom-containers.yaml -f overrides/compose.mariadb.yaml -f overrides/compose.redis.yaml up -d`  

## Final steps
Wait for for ERPNext site to be created and apps, check `create-site` has stopped running with success or the logs and delete the container, then you can open the browser on port 8080. (username: `Administrator`, password: `admin`)

To get the helpdesk running:
run the following command in the backend container `bench build --app helpdesk`
Note: do not run any commands as SU supper user sudo ect. They will throw errors and may not run correctly.

Example:
```sh
docker exec -it --user frappe frappe_docker-backend-1 bash
cd /home/frappe/frappe-bench
bench build --app helpdesk
```
For Production environment in docker (untested) build the helpdesk with:
bench build --app helpdesk --force --production --hard-link

## Additional Notes
Automated script is in build-workspace/inint.sh (included in the build package). It builds the site "crm.localhost" and installs all of the apps getting everything ready for first run.
The build-workspace folder is also a volume for easy updating of the script. 

1. If you don't want to start over from scratch and want to change the Apps that are installed simply comment out and start the containers.
```sh
bench --site crm.localhost install-app studio
# bench --site crm.localhost install-app builder
bench --site crm.localhost install-app print_designer
bench --site crm.localhost install-app webshop
```
 
2. If you don't want to start over from scratch and just want to change the setup by overwriting the configuration simply add --force to the new-site like so:
```sh
bench new-site crm.localhost --force \
--db-type mariadb \
--mariadb-user-host-login-scope='%' \
--db-type mariadb \
--db-host db \
--db-port 3306 \
```
A new site name will work just the same. 

3. Notice the frontend resolves domain names. See [Single Server Example](docs/single-server-example.md) for more info. Recommended setup for remote machine is to include treafik and allow traefik to resolve the port number and forwarding along the domain name. 

### Note about site naming
The domain name or site-name can be changed (with find and replace crm.localhost) to anything you like and it should resolve. 

Recommended setup for remote machine is to include treafik and allow traefik to resolve using the port number with forwarding domain name. The frontend resolves domain names. See Single Server Example for more info.
I will update script in the build as soon as I have time 

# Additional Documentation

### [Production](#production)
- [List of containers](docs/list-of-containers.md)
- [Single Compose Setup](docs/single-compose-setup.md)
- [Environment Variables](docs/environment-variables.md)
- [Single Server Example](docs/single-server-example.md)
- [Setup Options](docs/setup-options.md)
- [Site Operations](docs/site-operations.md)
- [Backup and Push Cron Job](docs/backup-and-push-cronjob.md)
- [Port Based Multi Tenancy](docs/port-based-multi-tenancy.md)
- [Migrate from multi-image setup](docs/migrate-from-multi-image-setup.md)
- [running on linux/mac](docs/setup_for_linux_mac.md)
- [TLS for local deployment](docs/tls-for-local-deployment.md)

### [Custom Images](#custom-images)
- [Custom Apps](docs/custom-apps.md)
- [Custom Apps with podman](docs/custom-apps-podman.md)
- [Build Version 10 Images](docs/build-version-10-images.md)

### [Development](#development)
- [Development using containers](docs/development.md)
- [Bench Console and VSCode Debugger](docs/bench-console-and-vscode-debugger.md)
- [Connect to localhost services](docs/connect-to-localhost-services-from-containers-for-local-app-development.md)

### [Credits]
Everything in this repo provided by and you can contribute to:
- [Frappe framework](https://github.com/frappe/frappe#contributing),
- [ERPNext](https://github.com/frappe/erpnext#contributing),
- [Frappe Bench](https://github.com/frappe/bench).
