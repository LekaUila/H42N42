(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/01/13 11:07:09 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/01/13 15:00:54 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(*let () = print_endline "Hello, World!"*)

(* Services *)
let main_service = Eliom_service.create
  ~path:(Eliom_service.Path [""])
  ~meth:(Eliom_service.Get Eliom_parameter.unit)
  ()

let user_service  = Eliom_service.create
  ~path:(Eliom_service.Path ["users"])
  ~meth:(Eliom_service.Get Eliom_parameter.(suffix (string "name")))
  ()

let connection_service = Eliom_service.create
  ~path:(Eliom_service.No_path)
  ~meth:(Eliom_service.Post (
    Eliom_parameter.unit,
    Eliom_parameter.(string "name" ** string "password")))
  ()

let disconnection_service = Eliom_service.create
  ~path:(Eliom_service.No_path)
  ~meth:(Eliom_service.Post (Eliom_parameter.unit, Eliom_parameter.unit))
  ()

(* User names and passwords: *)
let users = ref [("Calvin", "123"); ("Hobbes", "456")]

let user_links = Eliom_content.Html.D.(
  let link_of_user = fun (name, _) ->
    li [a ~service:user_service [txt name] name]
  in
  fun () -> ul (List.map link_of_user !users)
)

let username =
  Eliom_reference.eref ~scope:Eliom_common.default_session_scope None

let disconnect_box () = Eliom_content.Html.D.(
  Form.post_form ~service:disconnection_service
    (fun _ ->
      [fieldset [Form.input ~input_type:`Submit ~value:"Log out" Form.string]]
    )
    ()
)

let connection_box () = Eliom_content.Html.D.(
  let%lwt u = Eliom_reference.get username in
  Lwt.return
    (match u with
      | Some s -> div [p [txt "You are connected as "; txt s]; disconnect_box () ]
      | None ->
        Form.post_form ~service:connection_service
          (fun (name1, name2) ->
            [fieldset
	       [label [txt "login: "];
                Form.input
                  ~input_type:`Text ~name:name1
                  Form.string;
                br ();
                label [txt "password: "];
                Form.input
                  ~input_type:`Password ~name:name2
                  Form.string;
                br ();
                Form.input
                  ~input_type:`Submit ~value:"Connect"
                  Form.string
               ]]) ())
)


let check_pwd name pwd =
  try List.assoc name !users = pwd with Not_found -> false

(* Services Registration *)
let () = Eliom_content.Html.D.(

Eliom_registration.Html.register
    ~service:main_service
    (fun () () ->
      let%lwt cf = connection_box () in
      Lwt.return
        (html (head (title (txt "Home")) [])
              (body [h1 [txt "Hello"];
                     cf;
                     user_links ()])));

Eliom_registration.Action.register
    ~service:connection_service
    (fun () (name, password) ->
      if check_pwd name password
      then Eliom_reference.set username (Some name)
      else Lwt.return ());

Eliom_registration.Html.register
    ~service:user_service
    (fun name () ->
      let%lwt cf = connection_box () in
      Lwt.return
        (html (head (title (txt name)) [])
              (body [h1 [txt name];
		     cf;
                     p [a ~service:main_service [txt "Home"] ()]])));

Eliom_registration.Action.register
    ~service:disconnection_service
    (fun () () -> Eliom_state.discard ~scope:Eliom_common.default_session_scope ())


)


(*Start serveur (on port 8080) with a base repertory set in static*)
(*
let () = 
  Ocsigen_server.start [ Ocsigen_server.host [Staticmod.run ~dir:"static" (); Eliom.run ()]]
*)
let () = 
  Ocsigen_server.start 
    ~command_pipe:"local/var/run/mysite-cmd"
    ~logdir:"local/var/log/mysite"
    ~datadir:"local/var/data/mysite"
    ~default_charset:(Some "utf-8")
    [
      Ocsigen_server.host
       [ Staticmod.run ~dir:"static" ()
       ; Eliom.run () ]
    ]

