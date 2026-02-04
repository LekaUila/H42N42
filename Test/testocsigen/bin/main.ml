(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   main.ml                                            :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/01/13 11:07:09 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/02/03 14:52:22 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

(*let () = print_endline "Hello, World!"*)

(* Services *)

  (*Web page*)
    let main_service = Eliom_service.create
      ~path:(Eliom_service.Path [""])
      ~meth:(Eliom_service.Get Eliom_parameter.unit)
      ()

    let user_service  = Eliom_service.create
      ~path:(Eliom_service.Path ["users"])
      ~meth:(Eliom_service.Get Eliom_parameter.(suffix (string "name")))
      ()

    let new_user_form_service = Eliom_service.create
      ~path:(Eliom_service.Path ["registration"])
      ~meth:(Eliom_service.Get Eliom_parameter.unit)
      ()


  (*account service*)
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

  let account_confirmation_service =
    Eliom_service.create_attached_post
      ~fallback:new_user_form_service
      ~post_params:(Eliom_parameter.(string "name" **  string "password"))
      ()




(* User names and passwords: *)
  let users = ref [("Calvin", "123"); ("Hobbes", "456")]

(* Session data *)
  let username =
    Eliom_reference.eref ~scope:Eliom_common.default_session_scope None
  let wrong_pwd =
    Eliom_reference.eref ~scope:Eliom_common.request_scope false


(*HTML BLOCK*)

  (*User list*)
    let user_links = Eliom_content.Html.D.(
      let link_of_user = fun (name, _) ->
        li [a ~service:user_service [txt name] name]
      in
      fun () -> ul (List.map link_of_user !users)
    )

  (*disconnect box*)
    let disconnect_box () = Eliom_content.Html.D.(
      Form.post_form ~service:disconnection_service
        (fun _ ->
          [fieldset [Form.input ~input_type:`Submit ~value:"Log out" Form.string]]
        )
        ()
    )

  (*connect box*)
    let connection_box () = Eliom_content.Html.D.(
      let%lwt u = Eliom_reference.get username in
      let%lwt wp = Eliom_reference.get wrong_pwd in
      Lwt.return
        (match u with
          | Some s -> div [p [txt "You are connected as "; txt s; ];
                          disconnect_box () ]
          | None ->
            let l =
              [Form.post_form ~service:connection_service
                (fun (name1, name2) ->
                  [fieldset
              [label [txt "login: "];
                      Form.input ~input_type:`Text ~name:name1 Form.string;
                      br ();
                      label [txt "password: "];
                      Form.input ~input_type:`Password ~name:name2 Form.string;
                      br ();
                      Form.input ~input_type:`Submit ~value:"Connect" Form.string
                    ]]) ();
                p [a ~service:new_user_form_service [txt "Create an account"] ()]]
            in
            if wp
            then div ((p [em [txt "Wrong user or password"]])::l)
            else div l
        )
    )

  (*registration box*)
    let account_form () = Eliom_content.Html.D.(
      Form.post_form ~service:account_confirmation_service
        (fun (name1, name2) ->
          [fieldset
            [label [txt "login: "];
              Form.input ~input_type:`Text ~name:name1 Form.string;
              br ();
              label [txt "password: "];
              Form.input ~input_type:`Password ~name:name2 Form.string;
              br ();
              Form.input ~input_type:`Submit ~value:"Connect" Form.string
            ]]) ()
    )

(*utils*)
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
                     user_links ();
                  svg []])));

Eliom_registration.Action.register
    ~service:connection_service
    (fun () (name, password) ->
      if check_pwd name password
      then Eliom_reference.set username (Some name)
      else Eliom_reference.set wrong_pwd true);

Eliom_registration.Any.register
    ~service:user_service
    (fun name () ->
      if List.mem_assoc name !users then
	begin
	  let%lwt cf = connection_box () in
	  Eliom_registration.Html.send
            (html (head (title (txt name)) [])
               (body [h1 [txt name];
                      cf;
                      p [a ~service:main_service [txt "Home"] ()]]))
	end
      else
	Eliom_registration.Html.send
          ~code:404
          (html (head (title (txt "404")) [])
             (body [h1 [txt "404"];
                    p [txt "That page does not exist"]]))
    );

Eliom_registration.Action.register
    ~service:disconnection_service
    (fun () () -> Eliom_state.discard ~scope:Eliom_common.default_session_scope ());

Eliom_registration.Html.register
  ~service:new_user_form_service
  (fun () () ->
    Lwt.return
      (html (head (title (txt "")) [])
            (body [h1 [txt "Create an account"];
                    account_form ();
                  ])));

Eliom_registration.Html.register
    ~service:account_confirmation_service
    (fun () (name, pwd) ->
      let create_account_service =
        Eliom_service.create_attached_get
                ~fallback:main_service
                ~get_params:Eliom_parameter.unit
                ~timeout:60.
                ~max_use:1
	              ()
      in
      let _ = Eliom_registration.Action.register
	      ~service:create_account_service
        (fun () () ->
          users := (name, pwd)::!users;
          Lwt.return ())
      in
      Lwt.return
	          (html
            (head (title (txt "")) [])
            (body
              [h1 [txt "Confirm account creation for "; txt name];
               p [a ~service:create_account_service [txt "Yes"] ();
                  txt " ";
                  a ~service:main_service [txt "No"] ()]
              ])))
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

