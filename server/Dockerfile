# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/08/08 16:11:48 by Leka Uïla         #+#    #+#              #
#    Updated: 2026/08/08 18:56:17 by Leka Uïla        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM ocaml/opam:debian-ocaml-5.2

WORKDIR /server

COPY . .

RUN sudo chown -R opam:opam /server

RUN sudo apt-get update && \
    sudo apt-get install -y ocaml && sudo apt install ocaml-dune


RUN	opam install js_of_ocaml js_of_ocaml-ppx js_of_ocaml-lwt
RUN	opam install eliom
RUN opam install lwt_ppx ocsipersist-sqlite ocsigen-ppx-rpc


RUN eval $(opam env)

#RUN eval $(opam env) && dune build

EXPOSE 8080

CMD ["bash", "-c", "eval $(opam env) && make run"]
#CMD ["bash", "-c", "eval $(opam env) && yes"]