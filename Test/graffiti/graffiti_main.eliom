(** This is the main file if you are using static linking without config file.
 *)

module%shared Graffiti = Graffiti

let%server _ =
  Ocsigen_server.start
    ~ports:[`All, 8080]
    ~veryverbose:()
    ~debugmode:true
    ~logdir:"local/var/log/graffiti"
    ~datadir:"local/var/data/graffiti"
    ~uploaddir:(Some "/tmp")
    ~usedefaulthostname:true
    ~command_pipe:"local/var/run/graffiti-cmd"
    ~default_charset:(Some "utf-8")
    [ Ocsigen_server.host
      [Staticmod.run ~dir:"local/var/www/graffiti" (); Eliom.run ()] ]
