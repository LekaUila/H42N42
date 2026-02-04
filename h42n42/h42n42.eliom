(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   h42n42.eliom                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/02/03 15:09:09 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/02/04 15:55:44 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

module H42n42_app =
  Eliom_registration.App (struct
      let application_name = "h42n42"
      let global_data_path = None
    end)

(* Services *)

  
    let main_service = Eliom_service.create
      ~path:(Eliom_service.Path [""])
      ~meth:(Eliom_service.Get Eliom_parameter.unit)
      ()




(*utils*)

let width  = 300.
let height = 300.

let%server svg_elt =
  Eliom_content.Html.D.svg
    ~a:[
      Eliom_content.Svg.D.a_id "mon_svg";
      Eliom_content.Svg.D.a_width (100., Some `Percent);
      Eliom_content.Svg.D.a_height (800., Some `Px);
      Eliom_content.Svg.D.a_viewBox (0., 0., width, height);
    ]
    [
      Eliom_content.Svg.D.circle
        ~a:[
          Eliom_content.Svg.D.a_cx (50., Some `Px);
          Eliom_content.Svg.D.a_cy (50., Some `Px);
          Eliom_content.Svg.D.a_r (50., Some `Px);
          Eliom_content.Svg.D.a_fill (`Color ("red", None));
        ]
        []
    ]


(* Services Registration *)
let%server () = H42n42_app.register
    ~service:main_service
      (fun () () ->
      (* Cf. section "Client side side-effects on the server" *)
       let _ = [%client (Gamescript.init_client () : unit)  ] in
      Lwt.return (Htmlpage.page svg_elt ))


