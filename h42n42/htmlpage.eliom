(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   htmlpage.eliom                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/02/03 16:55:37 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/02/04 15:39:11 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module Echd = Eliom_content.Html.D

let page svg_elt =
  (Echd.html 
    (Echd.head 
      (Echd.title
        (Echd.txt "Home")) 
      [Echd.css_link
        ~uri:
          (Echd.make_uri
            ~service:(Eliom_service.static_dir ())
              ["css"; "h42n42.css"]
          )
        ()
      ]
    )
    (Echd.body
      [Echd.h1
        [Echd.txt "Hello"];
        svg_elt
      ]
    )
  )