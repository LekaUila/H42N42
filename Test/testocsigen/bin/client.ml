(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   client.ml                                          :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/01/12 17:58:07 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/01/12 17:58:14 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let () =
  let body = document##.body in
  let div = createDiv document in
  div##.textContent := Js.some (Js.string "Hello depuis OCaml + js_of_ocaml !");
  body##appendChild div |> ignore