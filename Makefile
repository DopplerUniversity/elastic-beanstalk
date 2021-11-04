SHELL=/bin/bash

build:
	docker build -t doppleruniversity/elastic-beanstalk-sync .

sync:
	docker run --rm -it --env-file <(doppler secrets download --no-file --format docker) doppleruniversity/elastic-beanstalk-sync $(CMD)
