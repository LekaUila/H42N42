(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   gameloop.eliom                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: lflandri <liam.flandrinck.58@gmail.com>    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/08/18 14:48:44 by lflandri          #+#    #+#             *)
(*   Updated: 2026/08/18 20:51:18 by lflandri         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)


let%client start_game next_sprite mouse_coor_x mouse_coor_y mouse_holding time_before_spawn getEltOfList getEltOfListList
      time_before_spawn_restart set_mouse_holding listcreature  game_running gamewindow game_over_txt speed_mul button_start addCreek creek_thread_fun
      : unit =
  let mutex = Lwt_mutex.create () in

  (*let absI nb = if nb < 0 then nb * -1 else nb in*)
  let absF nb = if nb < 0. then nb *. -1. else nb in 

  let rec checkIfLoose (list : GameInfo.creature list) =
    match list with
    | [] -> true
    | hd::tl -> if hd.status == 0 then false else checkIfLoose tl 
  in

  let gamecallback () : unit =
    let tempo () : unit Lwt.t = 
      if !game_running then
        (
          if checkIfLoose !listcreature then
            (
              game_running := false;
              game_over_txt##setAttribute (Js_of_ocaml.Js.string "opacity") (Js_of_ocaml.Js.string "1.0");
              button_start##setAttribute (Js_of_ocaml.Js.string "style") (Js_of_ocaml.Js.string "margin : 1% auto; display:block; opacity :1.0");
              button_start##removeAttribute (Js_of_ocaml.Js.string "disabled");

            )
          else ();
          let%lwt () =
          Lwt_mutex.with_lock mutex (fun () ->

              if !time_before_spawn > 0 then
                time_before_spawn := !time_before_spawn - (Random.int 2)
              else
                (
                  if !time_before_spawn_restart != GameInfo.minimal_time_before_spawn
                    then time_before_spawn_restart := !time_before_spawn_restart - 1 else ();
                  addCreek listcreature gamewindow (Random.int ((int_of_float GameInfo.width) - GameInfo.creek_width)) (Random.int ((int_of_float GameInfo.height) - GameInfo.creek_height - (int_of_float GameInfo.river_height) - (int_of_float GameInfo.hospital_height)) + (int_of_float GameInfo.river_height));
                  time_before_spawn := !time_before_spawn_restart
                );
              next_sprite := (!next_sprite + 1) mod 5;
              set_mouse_holding 0;
              speed_mul := !speed_mul +. GameInfo.creek_panik_speed;
              Lwt.return_unit
          )
          in Lwt.return_unit
        )
      else Lwt.return_unit
    in
    let _ = tempo () in ()
  in
  
  let creek_thread nb : unit Lwt.t =
    let rec loop nb () =
      if !game_running then
      (
        let%lwt () =
          Lwt_mutex.with_lock mutex (fun () ->
            (*entering special lwt context : entering mutex safe zone*)



          let rec moveCreature (list : GameInfo.creature list) (listsafe : GameInfo.creature list) n  =
            if n != 0 then
            (
              match list with
              | [] -> []
              | hd :: tl-> hd :: moveCreature tl listsafe (n - 1)
                
            )
            else
            (
            match list with
            | [] -> []
            | hd :: tl ->
              if hd.holded then (* creek holded *)
              (
                let mouse_cx = if !mouse_coor_x < (hd.width /. 2.) then (hd.width /. 2.) else (if !mouse_coor_x > (GameInfo.width -. (hd.width /. 2.)) then (GameInfo.width -. (hd.width /. 2.)) else !mouse_coor_x) in
                let mouse_cy = if !mouse_coor_y < (hd.height /. 2.) then (hd.height /. 2.) else (if !mouse_coor_y > (GameInfo.height -. (hd.height /. 2.)) then (GameInfo.height -. (hd.height /. 2.)) else !mouse_coor_y) in
                if !mouse_holding == 2 || (hd.status != 4 && hd.grab_time >= GameInfo.max_grab_time) then (* creek released *)
                (
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int ((int_of_float mouse_cx) - (int_of_float (hd.width /. 2.)))));
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int ((int_of_float mouse_cy) - (int_of_float (hd.height /. 2.)))));
                  if (hd.coord.y +. (hd.height)) > (GameInfo.height -. GameInfo.hospital_height) then (* check if creek release in hospital *)
                    ({elt = hd.elt; coord = {x = (mouse_cx -. (hd.width /. 2.)); y = (mouse_cy -. (hd.height /. 2.))}; direction = hd.direction; status = (if hd.status == 4 then 4 else 0); holded = false; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=0;death_time=0} : GameInfo.creature) :: tl
                  else
                    ({elt = hd.elt; coord = {x = (mouse_cx -. (hd.width /. 2.)); y = (mouse_cy -. (hd.height /. 2.))}; direction = hd.direction; status = hd.status; holded = false; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=0;death_time=hd.death_time} : GameInfo.creature) :: tl
                )
                else (* creek holded *)
                (
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int ((int_of_float mouse_cx) - (int_of_float (hd.width /. 2.)))));
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int ((int_of_float mouse_cy) - (int_of_float (hd.height /. 2.)))));
                  if hd.status == 4 then
                    hd.elt##setAttribute (Js_of_ocaml.Js.string "transform") (Js_of_ocaml.Js.string ("rotate(180 " ^ (string_of_int (int_of_float ((mouse_cx -. (hd.width /. 2.)) +. (hd.width /. 2.)))) ^ " " ^ (string_of_int (int_of_float ((mouse_cy -. (hd.height /. 2.)) +. (hd.height /. 2.)))) ^  ")")) else ();
                  ({elt = hd.elt; coord = {x = (mouse_cx -. (hd.width /. 2.)); y = (mouse_cy -. (hd.height /. 2.))}; direction = hd.direction; status = hd.status; holded = hd.holded; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=hd.grab_time + 1;death_time=hd.death_time} : GameInfo.creature) :: tl
                )
              )
              else
              (
                if !mouse_holding == 1 &&
                  !mouse_coor_x < hd.coord.x +. (hd.width) && hd.coord.x < !mouse_coor_x &&
                  !mouse_coor_y < hd.coord.y +. (hd.height) && hd.coord.y < !mouse_coor_y then
                ( (* creek captured *)
                  set_mouse_holding 0;
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int ((int_of_float !mouse_coor_x) - (int_of_float (hd.width /. 2.)))));
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int ((int_of_float !mouse_coor_y) - (int_of_float (hd.height /. 2.)))));
                  ({elt = hd.elt; coord = {x = (!mouse_coor_x -. (hd.width /. 2.)); y = (!mouse_coor_y -. (hd.height /. 2.))}; direction = hd.direction; status = hd.status; holded = true; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=hd.grab_time;death_time=hd.death_time} : GameInfo.creature) :: tl
                )
                else if hd.status == 4 then
                  ({elt = hd.elt; coord = hd.coord; direction = hd.direction; status = hd.status; holded = hd.holded; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=hd.grab_time;death_time=hd.death_time} : GameInfo.creature) :: tl
                else
                (
                  let new_death_time = if hd.status != 0 then hd.death_time + 1 else 0 in
                  let new_status =
                    if hd.death_time >= GameInfo.max_death_time then
                      (
                        hd.elt##setAttribute (Js_of_ocaml.Js.string "transform") (Js_of_ocaml.Js.string ("rotate(180 " ^ (string_of_int (int_of_float (hd.coord.x +. (hd.width /. 2.)))) ^ " " ^ (string_of_int (int_of_float (hd.coord.y +. (hd.height /. 2.)))) ^  ")"));
                        4
                      )
                    else
                      (
                        if hd.coord.y < GameInfo.river_height && hd.status == 0 then
                          (
                            match Random.int 10 with
                            | 9 -> 3
                            | 8 -> 2
                            | _ -> 1
                          )
                        else if hd.status == 0 then
                          (
                            let rec findtouchingcreek x y (listsafe : GameInfo.creature list) =
                              match listsafe with
                              | [] -> 0
                              | hd :: tl ->
                                if hd.status != 0 && hd.holded != true &&
                                  x < hd.coord.x +. hd.width &&
                                  x +. float_of_int (GameInfo.creek_width) > hd.coord.x &&
                                  y < hd.coord.y +. hd.height &&
                                  y +. float_of_int (GameInfo.creek_height) > hd.coord.y
                                  then 1
                                  else findtouchingcreek x y tl
                            in if findtouchingcreek hd.coord.x hd.coord.y listsafe == 1 && Random.int 100 < GameInfo.contamination_rate then
                                  (
                                    match Random.int 10 with
                                    | 9 -> 3
                                    | 8 -> 2
                                    | _ -> 1
                                  )
                              else hd.status
                          )
                        else hd.status
                      ) 
                  in
                  let speed = match new_status with
                              | 3 -> 0.85
                              | 2 -> 2.
                              | 1 -> 0.85
                              | _ -> 1.
                  in
                  let new_sprite_index = if !next_sprite == 0 then (hd.sprite_index + 1) mod 7 else hd.sprite_index in
                  let rec find_target (listsafe : GameInfo.creature list) dist creek x y =
                          match listsafe with
                          | [] -> creek
                          | hd :: tl ->
                            if hd.status != 0 || hd.holded
                            then find_target tl dist creek x y
                            else
                              if absF (hd.coord.x -. x) +. absF (hd.coord.y -. y) < dist
                                then find_target tl (absF (hd.coord.x -. x) +. absF (hd.coord.y -. y)) hd x y
                                else find_target tl dist creek x y
                  in 
                  let target = if hd.status == 2 then find_target listsafe 10000000. hd hd.coord.x hd.coord.y else hd in
                  let new_x_dir =
                    if hd.status == 2 && target.status != 2
                      then
                        if (target.coord.x > hd.coord.x && hd.direction.x < 0.) || (target.coord.x < hd.coord.x && hd.direction.x > 0.) then
                          (hd.direction.x *. -1.)
                        else  (hd.direction.x)
                      else
                        (
                          if hd.coord.x +. hd.direction.x < 0. || hd.coord.x +. hd.width +. hd.direction.x > GameInfo.width then
                            (hd.direction.x *. -1.)
                          else if Random.int GameInfo.creek_random_max_move == 42 then
                            (hd.direction.x *. -1.)
                          else
                            (hd.direction.x)
                        )
                  in
                  let new_y_dir =
                    if hd.status == 2 && target.status != 2
                      then
                        if (target.coord.y > hd.coord.y && hd.direction.y < 0.) || (target.coord.y < hd.coord.y && hd.direction.y > 0.) then
                          (hd.direction.y *. -1.)
                        else  (hd.direction.y)
                      else
                        (
                          if hd.coord.y +. hd.direction.y < 0. || hd.coord.y +. hd.height +. hd.direction.y > GameInfo.height then
                            (hd.direction.y *. -1.)
                          else if Random.int GameInfo.creek_random_max_move == 42 then
                            (hd.direction.y *. -1.)
                          else
                            (hd.direction.y);
                        )
                  in
                  let new_width = if hd.status == 3 then (if hd.width < float_of_int (GameInfo.creek_width * 4) then hd.width *. 1.001 else hd.width)
                                  else if hd.status == 0 then (if hd.width > float_of_int (GameInfo.creek_width) then hd.width *. 0.999 else hd.width) else hd.width in 
                  let new_height = if hd.status == 3 then (if hd.height < float_of_int (GameInfo.creek_height * 4) then hd.height *. 1.001 else hd.height)
                                  else if hd.status == 0 then (if hd.height > float_of_int (GameInfo.creek_height) then hd.height *. 0.999 else hd.height) else hd.height in 
                  let new_x_coor = hd.coord.x +. (new_x_dir *. speed *. !speed_mul) in
                  let new_y_coor = hd.coord.y +. (new_y_dir *. speed *. !speed_mul) in
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_x_coor)));
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_y_coor)));
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "width") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_width)));
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "height") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_height)));
                  if new_status != 4 then
                    (
                      if new_x_dir < 0. then
                        hd.elt##setAttribute (Js_of_ocaml.Js.string "href") (Js_of_ocaml.Js.string (getEltOfList (getEltOfListList GameInfo.sprite_left new_status) new_sprite_index))
                      else
                        hd.elt##setAttribute (Js_of_ocaml.Js.string "href") (Js_of_ocaml.Js.string (getEltOfList (getEltOfListList GameInfo.sprite_right new_status) new_sprite_index));
                    ) else ();
                  ({elt = hd.elt; coord = {x = new_x_coor; y = new_y_coor}; direction = {x = new_x_dir; y = new_y_dir}; status = new_status; holded = hd.holded; sprite_index = new_sprite_index; width=new_width; height=new_height; grab_time=hd.grab_time;death_time=new_death_time} : GameInfo.creature) :: tl
                )
              )
            )
          in
          listcreature := moveCreature !listcreature !listcreature nb;
        (*exiting lwt context : quiting mutex safe zone*)
        Lwt.return_unit
        )
        in loop nb ();
      ) else (Lwt.return true)
    in
    let tempo nb : unit Lwt.t = 
      let _ = loop nb () in
      Lwt.return_unit
    in
    tempo nb
  in
  creek_thread_fun := creek_thread;
    (* setInterval correctement typé *)
  let _ = (Js_of_ocaml.Dom_html.window##setInterval (Js_of_ocaml.Js.wrap_callback gamecallback) (Js_of_ocaml.Js.float 25.)  ) in ()

  