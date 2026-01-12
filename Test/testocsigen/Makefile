# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/07 12:52:54 by Leka Uïla         #+#    #+#              #
#    Updated: 2026/01/12 17:36:29 by Leka Uïla        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

PROJECTNAME = testocsigen

directory = ./testocsigen/

run:
	dune exec ${PROJECTNAME}
#dune exec ./app.ext

build :
	dune build

clean :
	dune clean


installEnv :
	bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
	opam init
	opam install js_of_ocaml js_of_ocaml-ppx js_of_ocaml-lwt
	opam install eliom
	opam install ocsigenserverclear ocsipersist-sqlite
	