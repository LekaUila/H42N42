(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   h42n42.eliom                                       :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/02/03 15:09:09 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/06/12 17:37:30 by Leka Uïla        ###   ########.fr       *)
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



(* Services Registration *)
let%server () = H42n42_app.register
    ~service:main_service
      (fun () () ->
      (* Cf. section "Client side side-effects on the server" *)
       let _ = [%client (Gamescript.init_client () : unit)  ] in
      Lwt.return (Htmlpage.page Gamescript.svg_elt Gamescript.button ))


