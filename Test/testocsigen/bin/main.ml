(*let () = print_endline "Hello, World!"*)



(*Start serveur (on port 8080) with a base repertory set in static*)

let () = 
  Ocsigen_server.start [ Ocsigen_server.host [Staticmod.run ~dir:"static" ()]]

