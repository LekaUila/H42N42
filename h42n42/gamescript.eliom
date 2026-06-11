(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   gamescript.eliom                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/02/04 14:41:20 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/06/11 20:31:23 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open%client Js_of_ocaml_lwt

let%shared width  = 1000.
let%shared height = 500.
let%shared river_width = width
let%shared river_height = 50.
let%shared hospital_width = width
let%shared hospital_height = 50.

let%client creek_width = 50
let%client creek_height = 35
let%client creek_speed = 0.5
let%client creek_random_max_move = 500 (*42 : min   the bigger the value is, less often the creek will change direction*)
let%client creek_panik_speed = 0.0003
let%client contamination_rate = 2 (*rate can't be float*)
let%client initial_time_before_spawn = 200 (*200 = 5s*)
let%client minimal_time_before_spawn = 50 (*50 = 1.25s*)
let%client max_grab_time = 50 (*50 = 1.25s*)
let%client max_death_time = 1800 (*1800 = 45s*)




let%client sprite_right =   [
                              [
                                "./img/sprite_normal_right/sprite_0.png";
                                "./img/sprite_normal_right/sprite_1.png";
                                "./img/sprite_normal_right/sprite_2.png";
                                "./img/sprite_normal_right/sprite_3.png";
                                "./img/sprite_normal_right/sprite_4.png";
                                "./img/sprite_normal_right/sprite_5.png";
                                "./img/sprite_normal_right/sprite_6.png"
                              ];
                              [
                                "./img/sprite_sick_right/sprite_0.png";
                                "./img/sprite_sick_right/sprite_1.png";
                                "./img/sprite_sick_right/sprite_2.png";
                                "./img/sprite_sick_right/sprite_3.png";
                                "./img/sprite_sick_right/sprite_4.png";
                                "./img/sprite_sick_right/sprite_5.png";
                                "./img/sprite_sick_right/sprite_6.png"
                              ];
                              [
                                "./img/sprite_mean_right/sprite_0.png";
                                "./img/sprite_mean_right/sprite_1.png";
                                "./img/sprite_mean_right/sprite_2.png";
                                "./img/sprite_mean_right/sprite_3.png";
                                "./img/sprite_mean_right/sprite_4.png";
                                "./img/sprite_mean_right/sprite_5.png";
                                "./img/sprite_mean_right/sprite_6.png"
                              ];
                              [
                                "./img/sprite_rage_right/sprite_0.png";
                                "./img/sprite_rage_right/sprite_1.png";
                                "./img/sprite_rage_right/sprite_2.png";
                                "./img/sprite_rage_right/sprite_3.png";
                                "./img/sprite_rage_right/sprite_4.png";
                                "./img/sprite_rage_right/sprite_5.png";
                                "./img/sprite_rage_right/sprite_6.png"
                              ]
                            ]

let%client sprite_left =    [
                              [
                                "./img/sprite_normal_left/sprite_0.png";
                                "./img/sprite_normal_left/sprite_1.png";
                                "./img/sprite_normal_left/sprite_2.png";
                                "./img/sprite_normal_left/sprite_3.png";
                                "./img/sprite_normal_left/sprite_4.png";
                                "./img/sprite_normal_left/sprite_5.png";
                                "./img/sprite_normal_left/sprite_6.png"
                              ];
                              [
                                "./img/sprite_sick_left/sprite_0.png";
                                "./img/sprite_sick_left/sprite_1.png";
                                "./img/sprite_sick_left/sprite_2.png";
                                "./img/sprite_sick_left/sprite_3.png";
                                "./img/sprite_sick_left/sprite_4.png";
                                "./img/sprite_sick_left/sprite_5.png";
                                "./img/sprite_sick_left/sprite_6.png"
                              ];
                              [
                                "./img/sprite_mean_left/sprite_0.png";
                                "./img/sprite_mean_left/sprite_1.png";
                                "./img/sprite_mean_left/sprite_2.png";
                                "./img/sprite_mean_left/sprite_3.png";
                                "./img/sprite_mean_left/sprite_4.png";
                                "./img/sprite_mean_left/sprite_5.png";
                                "./img/sprite_mean_left/sprite_6.png"
                              ];
                              [
                                "./img/sprite_rage_left/sprite_0.png";
                                "./img/sprite_rage_left/sprite_1.png";
                                "./img/sprite_rage_left/sprite_2.png";
                                "./img/sprite_rage_left/sprite_3.png";
                                "./img/sprite_rage_left/sprite_4.png";
                                "./img/sprite_rage_left/sprite_5.png";
                                "./img/sprite_rage_left/sprite_6.png"
                              ]
                            ]

type%client coordonate =
{
  x : float;
  y : float;
}
type%client creature = 
{
  elt : Js_of_ocaml.Dom_html.element Js_of_ocaml.Js.t;
  coord : coordonate;
  direction : coordonate;
  status: int;
  holded: bool;
  sprite_index: int;
  width: float;
  height: float;
  grab_time: int;
  death_time: int;
}


let%shared svg_elt =
  Eliom_content.Html.D.svg
    ~a:[
      Eliom_content.Svg.D.a_id "mon_svg";
      Eliom_content.Svg.D.a_width (80., Some `Percent);

      Eliom_content.Svg.D.a_viewBox (0., 0., width, height);
    ]
    [
      (*Eliom_content.Svg.D.circle
        ~a:[
          Eliom_content.Svg.D.a_cx (50., Some `Px);
          Eliom_content.Svg.D.a_cy (50., Some `Px);
          Eliom_content.Svg.D.a_r (50., Some `Px);
          Eliom_content.Svg.D.a_fill (`Color ("red", None));
        ]
        [];*)
      Eliom_content.Svg.D.rect
        ~a:[
          Eliom_content.Svg.D.a_x (0., Some `Px);
          Eliom_content.Svg.D.a_y (0., Some `Px);
          Eliom_content.Svg.D.a_width (river_width, Some `Px);
          Eliom_content.Svg.D.a_height (river_height, Some `Px);
          Eliom_content.Svg.D.a_fill (`Color ("blue", None));
        ]
        [];
      Eliom_content.Svg.D.rect
        ~a:[
          Eliom_content.Svg.D.a_x (0., Some `Px);
          Eliom_content.Svg.D.a_y (height -. hospital_height, Some `Px);
          Eliom_content.Svg.D.a_width (hospital_width, Some `Px);
          Eliom_content.Svg.D.a_height (hospital_height, Some `Px);
          Eliom_content.Svg.D.a_fill (`Color ("green", None));
        ]
        []
    ]

let%client init_client () =
  Random.self_init ();
  let log s () = Js_of_ocaml.Firebug.console##log (Js_of_ocaml.Js.string s) in
  let next_sprite = ref 1 in
  let speed_mul = ref 1. in
  let mouse_coor_x = ref 0. in
  let mouse_coor_y = ref 0. in
  let mouse_holding = ref 0 in
  let time_before_spawn = ref initial_time_before_spawn in
  let time_before_spawn_restart = ref initial_time_before_spawn in
  let set_mouse_holding i = mouse_holding := i in
  let svg_core = Js_of_ocaml.Dom_html.getElementById_opt "mon_svg" in
  let listcreature = ref [] in
  log "test" ();
  match svg_core with
  | None -> log "SVG introuvable" ()
  | Some gamewindow -> log "SVG trouvé" ();

  let set_mouse_coor ev =
    let x0, y0 = Js_of_ocaml.Dom_html.elementClientPosition gamewindow in
    let x1 = gamewindow##.clientWidth in
    let y1 = gamewindow##.clientHeight in
    mouse_coor_x := (float_of_int ((ev##.clientX - x0) * (int_of_float width) / x1));
    mouse_coor_y := (float_of_int ((ev##.clientY - y0) * (int_of_float height) / y1));
    log (string_of_float !mouse_coor_x) ();
    log (string_of_float !mouse_coor_y) ();
    Lwt.return ()
  in

  let rec getEltOfList l x = 
      match l with
      | [] -> ""
      | hd :: tl -> if x == 0 then hd else getEltOfList tl (x - 1)
   in

  let rec getEltOfListList l x = 
      match l with
      | [] -> []
      | hd :: tl -> if x == 0 then hd else getEltOfListList tl (x - 1)
   in

  (*let absI nb = if nb < 0 then nb * -1 else nb in*)
  let absF nb = if nb < 0. then nb *. -1. else nb in 
  
  let addCreek list gamewindow x y = 
    (* Créer un nouvel élément <image> SVG *)
    let svg_ns = "http://www.w3.org/2000/svg" in
      let img_svg =  Js_of_ocaml.Dom_html.document##createElementNS
          (Js_of_ocaml.Js.string svg_ns)
          (Js_of_ocaml.Js.string "image") in

      (* Définir les attributs *)
      img_svg##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int x));
      img_svg##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int y));
      img_svg##setAttribute (Js_of_ocaml.Js.string "width") (Js_of_ocaml.Js.string (string_of_int creek_width));
      img_svg##setAttribute (Js_of_ocaml.Js.string "height") (Js_of_ocaml.Js.string (string_of_int creek_height));
      img_svg##setAttribute (Js_of_ocaml.Js.string "href") (Js_of_ocaml.Js.string (getEltOfList (getEltOfListList sprite_right 0) 0));
      (* Ajouter l'image au SVG *)
      Js_of_ocaml.Dom.appendChild (Js_of_ocaml.Js.Unsafe.coerce gamewindow) img_svg;
      list := ({elt = img_svg; coord = {x = (float_of_int x); y = (float_of_int y)}; direction = {x = (float_of_int (Random.int 2 * -2 + 1)) *. creek_speed; y = (float_of_int (Random.int 2 * -2 + 1)) *. creek_speed}; status = 0; holded = false; sprite_index = 0; width=float_of_int (creek_width); height=float_of_int (creek_height); grab_time=0;death_time=0} : creature) :: !list;
      ()
  in

  (* Fonction à exécuter à chaque intervalle *)
  let callback () : unit =
    let rec moveCreature list listsafe = 
      match list with
      | [] -> []
      | hd :: tl ->
        if hd.holded then (* creek holded *)
        (
          let mouse_cx = if !mouse_coor_x < (hd.width /. 2.) then (hd.width /. 2.) else (if !mouse_coor_x > (width -. (hd.width /. 2.)) then (width -. (hd.width /. 2.)) else !mouse_coor_x) in
          let mouse_cy = if !mouse_coor_y < (hd.height /. 2.) then (hd.height /. 2.) else (if !mouse_coor_y > (height -. (hd.height /. 2.)) then (height -. (hd.height /. 2.)) else !mouse_coor_y) in
          if !mouse_holding == 2 || (hd.status != 4 && hd.grab_time >= max_grab_time) then (* creek released *)
          (
            hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int ((int_of_float mouse_cx) - (int_of_float (hd.width /. 2.)))));
            hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int ((int_of_float mouse_cy) - (int_of_float (hd.height /. 2.)))));
            if (hd.coord.y +. (hd.height)) > (height -. hospital_height) then (* check if creek release in hospital *)
              ({elt = hd.elt; coord = {x = (mouse_cx -. (hd.width /. 2.)); y = (mouse_cy -. (hd.height /. 2.))}; direction = hd.direction; status = (if hd.status == 4 then 4 else 0); holded = false; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=0;death_time=0} : creature) :: moveCreature tl listsafe
            else
              ({elt = hd.elt; coord = {x = (mouse_cx -. (hd.width /. 2.)); y = (mouse_cy -. (hd.height /. 2.))}; direction = hd.direction; status = hd.status; holded = false; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=0;death_time=hd.death_time} : creature) :: moveCreature tl listsafe
          )
          else (* creek holded *)
          (
            hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int ((int_of_float mouse_cx) - (int_of_float (hd.width /. 2.)))));
            hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int ((int_of_float mouse_cy) - (int_of_float (hd.height /. 2.)))));
            if hd.status == 4 then
              hd.elt##setAttribute (Js_of_ocaml.Js.string "transform") (Js_of_ocaml.Js.string ("rotate(180 " ^ (string_of_int (int_of_float ((mouse_cx -. (hd.width /. 2.)) +. (hd.width /. 2.)))) ^ " " ^ (string_of_int (int_of_float ((mouse_cy -. (hd.height /. 2.)) +. (hd.height /. 2.)))) ^  ")")) else ();
            ({elt = hd.elt; coord = {x = (mouse_cx -. (hd.width /. 2.)); y = (mouse_cy -. (hd.height /. 2.))}; direction = hd.direction; status = hd.status; holded = hd.holded; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=hd.grab_time + 1;death_time=hd.death_time} : creature) :: moveCreature tl listsafe
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
            ({elt = hd.elt; coord = {x = (!mouse_coor_x -. (hd.width /. 2.)); y = (!mouse_coor_y -. (hd.height /. 2.))}; direction = hd.direction; status = hd.status; holded = true; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=hd.grab_time;death_time=hd.death_time} : creature) :: moveCreature tl listsafe
          )
          else if hd.status == 4 then
            ({elt = hd.elt; coord = hd.coord; direction = hd.direction; status = hd.status; holded = hd.holded; sprite_index = hd.sprite_index; width=hd.width; height=hd.height; grab_time=hd.grab_time;death_time=hd.death_time} : creature) :: moveCreature tl listsafe
          else
          (
            let new_death_time = if hd.status != 0 then hd.death_time + 1 else 0 in
            let new_status =
              if hd.death_time >= max_death_time then
                (
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "transform") (Js_of_ocaml.Js.string ("rotate(180 " ^ (string_of_int (int_of_float (hd.coord.x +. (hd.width /. 2.)))) ^ " " ^ (string_of_int (int_of_float (hd.coord.y +. (hd.height /. 2.)))) ^  ")"));
                  4
                )
              else
                (
                  if hd.coord.y < river_height && hd.status == 0 then
                    (
                      match Random.int 10 with
                      | 9 -> 3
                      | 8 -> 2
                      | _ -> 1
                    )
                  else if hd.status == 0 then
                    (
                      let rec findtouchingcreek x y listsafe =
                        match listsafe with
                        | [] -> 0
                        | hd :: tl ->
                          if hd.status != 0 && hd.holded != true &&
                            x < hd.coord.x +. hd.width &&
                            x +. float_of_int (creek_width) > hd.coord.x &&
                            y < hd.coord.y +. hd.height &&
                            y +. float_of_int (creek_height) > hd.coord.y
                            then 1
                            else findtouchingcreek x y tl
                      in if findtouchingcreek hd.coord.x hd.coord.y listsafe == 1 && Random.int 100 < contamination_rate then
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
            let rec find_target listsafe dist creek x y =
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
                    if hd.coord.x +. hd.direction.x < 0. || hd.coord.x +. hd.width +. hd.direction.x > width then
                      (hd.direction.x *. -1.)
                    else if Random.int creek_random_max_move == 42 then
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
                    if hd.coord.y +. hd.direction.y < 0. || hd.coord.y +. hd.height +. hd.direction.y > height then
                      (hd.direction.y *. -1.)
                    else if Random.int creek_random_max_move == 42 then
                      (hd.direction.y *. -1.)
                    else
                      (hd.direction.y);
                  )
            in
            let new_width = if hd.status == 3 then (if hd.width < float_of_int (creek_width * 4) then hd.width *. 1.001 else hd.width)
                            else if hd.status == 0 then (if hd.width > float_of_int (creek_width) then hd.width *. 0.999 else hd.width) else hd.width in 
            let new_height = if hd.status == 3 then (if hd.height < float_of_int (creek_height * 4) then hd.height *. 1.001 else hd.height)
                            else if hd.status == 0 then (if hd.height > float_of_int (creek_height) then hd.height *. 0.999 else hd.height) else hd.height in 
            let new_x_coor = hd.coord.x +. (new_x_dir *. speed *. !speed_mul) in
            let new_y_coor = hd.coord.y +. (new_y_dir *. speed *. !speed_mul) in
            hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_x_coor)));
            hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_y_coor)));
            hd.elt##setAttribute (Js_of_ocaml.Js.string "width") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_width)));
            hd.elt##setAttribute (Js_of_ocaml.Js.string "height") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_height)));
            if new_status != 4 then
              (
                if new_x_dir < 0. then
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "href") (Js_of_ocaml.Js.string (getEltOfList (getEltOfListList sprite_left new_status) new_sprite_index))
                else
                  hd.elt##setAttribute (Js_of_ocaml.Js.string "href") (Js_of_ocaml.Js.string (getEltOfList (getEltOfListList sprite_right new_status) new_sprite_index));
              ) else ();
            ({elt = hd.elt; coord = {x = new_x_coor; y = new_y_coor}; direction = {x = new_x_dir; y = new_y_dir}; status = new_status; holded = hd.holded; sprite_index = new_sprite_index; width=new_width; height=new_height; grab_time=hd.grab_time;death_time=new_death_time} : creature) :: moveCreature tl listsafe
          )
        )
    in
    if !time_before_spawn > 0 then
      time_before_spawn := !time_before_spawn - (Random.int 2)
    else
      (
        if !time_before_spawn_restart != minimal_time_before_spawn
          then time_before_spawn_restart := !time_before_spawn_restart - 1 else ();
        addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
        time_before_spawn := !time_before_spawn_restart;
        log "spawn new creek" ()
      );
    log "tick" ();
    listcreature := moveCreature !listcreature !listcreature;
    next_sprite := (!next_sprite + 1) mod 5;
    set_mouse_holding 0;
    speed_mul := !speed_mul +. creek_panik_speed;
    ()
  in
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));
  addCreek listcreature gamewindow (Random.int ((int_of_float width) - creek_width)) (Random.int ((int_of_float height) - creek_height - (int_of_float river_height) - (int_of_float hospital_height)) + (int_of_float river_height));

    (* setInterval correctement typé *)
  let _ = (Js_of_ocaml.Dom_html.window##setInterval (Js_of_ocaml.Js.wrap_callback callback) 25.  )
  in 

  Lwt.async (fun () ->
    let open Lwt_js_events in
    mousedowns gamewindow
      (fun ev _ ->
        set_mouse_holding 1;
         let%lwt () = set_mouse_coor ev in
         Lwt.pick
           [mousemoves Js_of_ocaml.Dom_html.document (fun x _ -> set_mouse_coor x);
            let%lwt ev = mouseup Js_of_ocaml.Dom_html.document in set_mouse_holding 2; set_mouse_coor ev]))



