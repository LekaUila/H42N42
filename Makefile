# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/02/03 14:57:38 by Leka Uïla         #+#    #+#              #
#    Updated: 2026/02/04 16:08:24 by Leka Uïla        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PROJECTNAME = h42n42

PROJECTPATH = ./h42n42/

LOCALPATH = ${PROJECTPATH}local/
LOGPATH = ${LOCALPATH}var/log/${PROJECTNAME}/
STATICFILEPATH = ${LOCALPATH}local/var/www/${PROJECTNAME}/

all: run

run :
	cd ${PROJECTPATH} && make test.byte

build :
	cd ${PROJECTPATH} && make byte

clean :
	cd ${PROJECTPATH} && make clean


fclean : clean
	rm -fr ${LOCALPATH}


installEnv :
	bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
	opam init
	opam install js_of_ocaml js_of_ocaml-ppx js_of_ocaml-lwt
	opam install eliom
	opam install ocsigenserverclear ocsipersist-sqlite ocsipersist-sqlite-config
	