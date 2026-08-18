# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/02/03 14:57:38 by Leka Uïla         #+#    #+#              #
#    Updated: 2026/08/08 19:14:38 by Leka Uïla        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PROJECTNAME = h42n42

PROJECTPATH = ./h42n42/

LOCALPATH = ${PROJECTPATH}local/
LOGPATH = ${LOCALPATH}var/log/${PROJECTNAME}/
STATICFILEPATH = ${LOCALPATH}local/var/www/${PROJECTNAME}/

all: run

run :
	docker-compose up --build

status :
	docker-compose ps

log :
	docker-compose logs -f

stop :
	docker-compose down

dockerBash :
	docker-compose exec app bash

clean :
	


fclean : clean
	sudo docker system prune -af --volumes


installEnv :
	bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
	opam init
	opam install js_of_ocaml js_of_ocaml-ppx js_of_ocaml-lwt
	opam install eliom
	opam install ocsipersist-sqlite ocsipersist-sqlite-config
	