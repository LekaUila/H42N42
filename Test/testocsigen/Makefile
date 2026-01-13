# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/07 12:52:54 by Leka Uïla         #+#    #+#              #
#    Updated: 2026/01/13 17:34:46 by Leka Uïla        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PROJECTNAME = testocsigen

CONFFILE = ${PROJECTNAME}.conf

LOGPATH = ./local/var/log/mysite/

all: rundune

runoc:
	ocsigenserver -c ${CONFFILE}

rundune :
	dune exec ${PROJECTNAME}

build :
	dune build

clean :
	dune clean
	rm ${LOGPATH}access.log ${LOGPATH}errors.log ${LOGPATH}warnings.log


fclean : clean


installEnv :
	bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
	opam init
	opam install js_of_ocaml js_of_ocaml-ppx js_of_ocaml-lwt
	opam install eliom
	opam install ocsigenserverclear ocsipersist-sqlite ocsipersist-sqlite-config
	