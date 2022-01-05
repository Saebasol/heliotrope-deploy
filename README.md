# heliotrope-deploy

> This repository makes it easy to deploy heliotrope.
> ref: <https://github.com/seia-soto/saebasol-the-server>

## How to?

* Install Docker and Docker Compose

[Docker](https://docs.docker.com/get-docker/)  
[Docker Compose](https://docs.docker.com/compose/install/)

* Clone repo

```sh
git clone https://github.com/Saebasol/heliotrope-deploy
```

* Edit setup.sh
* Edit docker-compose.yml
* Run setup.sh
  
```sh
sudo bash setup.sh
```

## Warning

* If you modify the forwarded secret, you must also modify ``docker\gateway\snippets\_proxy_preset.conf``.
* Deploying with default settings can be dangerous.
