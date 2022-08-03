.PHONY: ps up down reup build python mysql logs

ps:
	docker compose ps

up:
	docker compose up -d

down:
	docker compose down

reup:
	docker compose up -d --build

build:
	docker compose build

python:
	docker compose exec python /bin/bash

mysql:
	docker compose exec mysql mysql -u root -p

logs:
	docker compose logs -f
