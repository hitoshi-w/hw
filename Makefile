build:
	docker-compose build

console:
	docker-compose run --rm app bundle exec rails console

up:
	rm -rf tmp/pids/*
	touch tmp/caching-dev.txt
	docker-compose up

stop:
	docker-compose stop

down:
	docker-compose down

install:
	docker-compose run --rm app bundle install
	docker-compose run --rm app yarn install

db_migrate:
	docker-compose run --rm app bundle exec rails db:migrate

db_create:
	docker-compose run --rm app bundle exec rails db:create

bash:
	docker-compose exec app /bin/bash
