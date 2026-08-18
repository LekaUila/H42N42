(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   gamescript.eliom                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: lflandri <liam.flandrinck.58@gmail.com>    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/02/04 14:41:20 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/08/18 20:57:17 by lflandri         ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open%client Js_of_ocaml_lwt

let%client game_running = ref false


let%shared button =
  Eliom_content.Html.D.button
    ~a:[
      Eliom_content.Html.D.a_id "start_button";

    ]
    [
      Eliom_content.Html.D.txt "Star Game"

    ]

let%shared svg_elt =
  Eliom_content.Html.D.svg
    ~a:[
      Eliom_content.Svg.D.a_id "mon_svg";
      Eliom_content.Svg.D.a_width (80., Some `Percent);
      Eliom_content.Svg.D.a_viewBox (0., 0., GameInfo.width, GameInfo.height);
    ]
    [
      (*BACKGROUND*)
      Eliom_content.Svg.D.image
        ~a:[
          Eliom_content.Svg.D.a_x (0., Some `Px);
          Eliom_content.Svg.D.a_y (GameInfo.river_height, Some `Px);
          Eliom_content.Svg.D.a_width (GameInfo.width , Some `Px);
          Eliom_content.Svg.D.a_height (GameInfo.height -. GameInfo.hospital_height -. GameInfo.river_height, Some `Px);
          Eliom_content.Svg.D.a_href "./img/grass4.png";  
          Eliom_content.Svg.D.a_preserveAspectRatio "xMidYMid slice";
        ]
        [];
    (*WATER PART*)

      Eliom_content.Svg.D.rect (*in case img not loading*)
        ~a:[
          Eliom_content.Svg.D.a_x (0., Some `Px);
          Eliom_content.Svg.D.a_y (0., Some `Px);
          Eliom_content.Svg.D.a_width (GameInfo.river_width, Some `Px);
          Eliom_content.Svg.D.a_height (GameInfo.river_height, Some `Px);
          Eliom_content.Svg.D.a_fill (`Color ("blue", None));
        ]
        [];
        
      Eliom_content.Svg.D.image
        ~a:[
          Eliom_content.Svg.D.a_x (0., Some `Px);
          Eliom_content.Svg.D.a_y (GameInfo.river_height -. 200., Some `Px);
          Eliom_content.Svg.D.a_width (200., Some `Px);
          Eliom_content.Svg.D.a_height (200., Some `Px);
          Eliom_content.Svg.D.a_href "./img/tile_water_2.gif";
        ]
        [];
              Eliom_content.Svg.D.image
        ~a:[
          Eliom_content.Svg.D.a_x (200., Some `Px);
          Eliom_content.Svg.D.a_y (GameInfo.river_height -. 200., Some `Px);
          Eliom_content.Svg.D.a_width (200., Some `Px);
          Eliom_content.Svg.D.a_height (200., Some `Px);
          Eliom_content.Svg.D.a_href "./img/tile_water_2.gif";
        ]
        [];
              Eliom_content.Svg.D.image
        ~a:[
          Eliom_content.Svg.D.a_x (400., Some `Px);
          Eliom_content.Svg.D.a_y (GameInfo.river_height -. 200., Some `Px);
          Eliom_content.Svg.D.a_width (200., Some `Px);
          Eliom_content.Svg.D.a_height (200., Some `Px);
          Eliom_content.Svg.D.a_href "./img/tile_water_2.gif";
        ]
        [];
              Eliom_content.Svg.D.image
        ~a:[
          Eliom_content.Svg.D.a_x (600., Some `Px);
          Eliom_content.Svg.D.a_y (GameInfo.river_height -. 200., Some `Px);
          Eliom_content.Svg.D.a_width (200., Some `Px);
          Eliom_content.Svg.D.a_height (200., Some `Px);
          Eliom_content.Svg.D.a_href "./img/tile_water_2.gif";
        ]
        [];
              Eliom_content.Svg.D.image
        ~a:[
          Eliom_content.Svg.D.a_x (800., Some `Px);
          Eliom_content.Svg.D.a_y (GameInfo.river_height -. 200., Some `Px);
          Eliom_content.Svg.D.a_width (200., Some `Px);
          Eliom_content.Svg.D.a_height (200., Some `Px);
          Eliom_content.Svg.D.a_href "./img/tile_water_2.gif";
        ]
        [];

      (*Hospital*)
      Eliom_content.Svg.D.rect
        ~a:[
          Eliom_content.Svg.D.a_x (0., Some `Px);
          Eliom_content.Svg.D.a_y (GameInfo.height -. GameInfo.hospital_height, Some `Px);
          Eliom_content.Svg.D.a_width (GameInfo.hospital_width, Some `Px);
          Eliom_content.Svg.D.a_height (GameInfo.hospital_height, Some `Px);
          Eliom_content.Svg.D.a_fill (`Color ("white", None));
        ]
        [];

              Eliom_content.Svg.D.image
        ~a:[
          Eliom_content.Svg.D.a_x (0., Some `Px);
          Eliom_content.Svg.D.a_y (GameInfo.height -. GameInfo.hospital_height, Some `Px);
          Eliom_content.Svg.D.a_width (GameInfo.hospital_width, Some `Px);
          Eliom_content.Svg.D.a_height (GameInfo.hospital_height, Some `Px);
          Eliom_content.Svg.D.a_preserveAspectRatio "none";
          Eliom_content.Svg.D.a_href "./img/hospital2.png";
        ]
        [];
      (*Other*)

        Eliom_content.Svg.D.text
          ~a:[
            Eliom_content.Svg.D.a_id "game_over_text";
            Eliom_content.Svg.D.a_x_list [ (220., Some `Px) ];
            Eliom_content.Svg.D.a_y_list [ (270., Some `Px) ];
            Eliom_content.Svg.D.a_font_size "102px";
          ]
          [Eliom_content.Svg.D.txt "Game Over"]
    ]
  

let%client init_client () =
  Random.self_init ();
  let log s = ignore ( Js_of_ocaml.Js.Unsafe.global##.console##log (Js_of_ocaml.Js.string s)) in
  let next_sprite = ref 1 in
  let speed_mul = ref 1. in
  let mouse_coor_x = ref 0. in
  let mouse_coor_y = ref 0. in
  let mouse_holding = ref 0 in
  let time_before_spawn = ref GameInfo.initial_time_before_spawn in
  let time_before_spawn_restart = ref GameInfo.initial_time_before_spawn in
  let set_mouse_holding i = mouse_holding := i in
  let svg_core = Js_of_ocaml.Dom_html.getElementById_opt "mon_svg" in
  let button_core = Js_of_ocaml.Dom_html.getElementById_opt "start_button" in
  let txt_lose = Js_of_ocaml.Dom_html.getElementById_opt "game_over_text" in
  let listcreature = ref [] in
  let creek_thread_fun = ref (fun (nb) -> let _ = nb + 1 in Lwt.return_unit) in
  match svg_core with
  | None -> log "SVG introuvable"
  | Some gamewindow -> log "SVG trouvé";
  match button_core with
  | None -> log "start button introuvable"
  | Some button_start -> log "start button trouvé";
  match txt_lose with
  | None -> log "game over text introuvable"
  | Some game_over_txt -> log "game over text trouvé";
  game_over_txt##setAttribute (Js_of_ocaml.Js.string "opacity") (Js_of_ocaml.Js.string "0.0");
  gamewindow##setAttribute (Js_of_ocaml.Js.string "style") (Js_of_ocaml.Js.string "margin : auto; display:block");
  button_start##setAttribute (Js_of_ocaml.Js.string "style") (Js_of_ocaml.Js.string "margin : 1% auto; display:block");

  let set_mouse_coor ev =
    let x0, y0 = Js_of_ocaml.Dom_html.elementClientPosition gamewindow in
    let x1 = gamewindow##.clientWidth in
    let y1 = gamewindow##.clientHeight in
    mouse_coor_x := (float_of_int (((int_of_float (Js_of_ocaml.Js.float_of_number ev##.clientX)) - x0) * (int_of_float GameInfo.width) / x1));
    mouse_coor_y := (float_of_int (((int_of_float (Js_of_ocaml.Js.float_of_number ev##.clientY)) - y0) * (int_of_float GameInfo.height) / y1));
    log (string_of_float !mouse_coor_x);
    log (string_of_float !mouse_coor_y);
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

  let addCreek list gamewindow x y = 
    (* Créer un nouvel élément <image> SVG *)
    let svg_ns = "http://www.w3.org/2000/svg" in
      let img_svg =  Js_of_ocaml.Dom_html.document##createElementNS
          (Js_of_ocaml.Js.string svg_ns)
          (Js_of_ocaml.Js.string "image") in

      (* Définir les attributs *)
      img_svg##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int x));
      img_svg##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int y));
      img_svg##setAttribute (Js_of_ocaml.Js.string "width") (Js_of_ocaml.Js.string (string_of_int GameInfo.creek_width));
      img_svg##setAttribute (Js_of_ocaml.Js.string "height") (Js_of_ocaml.Js.string (string_of_int GameInfo.creek_height));
      img_svg##setAttribute (Js_of_ocaml.Js.string "href") (Js_of_ocaml.Js.string (getEltOfList (getEltOfListList GameInfo.sprite_right 0) 0));
      img_svg##setAttribute (Js_of_ocaml.Js.string "style") (Js_of_ocaml.Js.string "z-index: 500");
      (* Ajouter l'image au SVG *)
      Js_of_ocaml.Dom.appendChild (Js_of_ocaml.Js.Unsafe.coerce gamewindow) img_svg;
      let rec add_new_creek new_creek nb list =
        match list with
        | [] -> Lwt.async (fun () -> (!creek_thread_fun) nb); [new_creek]
        | hd::tl -> hd :: (add_new_creek new_creek (nb + 1) tl)
      in
      list := add_new_creek ({elt = img_svg; coord = {x = (float_of_int x); y = (float_of_int y)}; direction = {x = (float_of_int (Random.int 2 * -2 + 1)) *. GameInfo.creek_speed; y = (float_of_int (Random.int 2 * -2 + 1)) *. GameInfo.creek_speed}; status = 0; holded = false; sprite_index = 0; width=float_of_int (GameInfo.creek_width); height=float_of_int (GameInfo.creek_height); grab_time=0;death_time=0} : GameInfo.creature) 0 !list;
      ()
  in

  let rec addXCreek list gamewindow nb =
    match nb with
    | 0 -> ()
    | _ -> 
      addCreek listcreature gamewindow (Random.int ((int_of_float GameInfo.width) - GameInfo.creek_width)) (Random.int ((int_of_float GameInfo.height) - GameInfo.creek_height - (int_of_float GameInfo.river_height) - (int_of_float GameInfo.hospital_height)) + (int_of_float GameInfo.river_height));
      addXCreek list gamewindow (nb - 1)
  in

  let rec empty_list_creature (list : GameInfo.creature list) gamewindow =
    match list with
    | [] -> []
    | hd :: tl -> 
      Js_of_ocaml.Dom.removeChild (Js_of_ocaml.Js.Unsafe.coerce gamewindow) (hd : GameInfo.creature).elt;
      empty_list_creature tl gamewindow
  in

  let restart_game () =
    speed_mul := 1.;
    time_before_spawn := GameInfo.initial_time_before_spawn;
    time_before_spawn_restart := GameInfo.initial_time_before_spawn;
    listcreature := empty_list_creature !listcreature gamewindow;
    addXCreek listcreature gamewindow GameInfo.nb_starting_creek

  in

  button_start##.onclick := Js_of_ocaml.Dom_html.handler (fun _event ->
            restart_game();
            game_over_txt##setAttribute (Js_of_ocaml.Js.string "style") (Js_of_ocaml.Js.string "z-index :1000");
            game_over_txt##setAttribute (Js_of_ocaml.Js.string "opacity") (Js_of_ocaml.Js.string "0.0");
            button_start##setAttribute (Js_of_ocaml.Js.string "style") (Js_of_ocaml.Js.string "margin : 1% auto; display:block; opacity :0.0");
            button_start##setAttribute
                (Js_of_ocaml.Js.string "disabled")
                (Js_of_ocaml.Js.string "");
            game_running := true;
          Js_of_ocaml.Js._false
        );


  Gameloop.start_game next_sprite mouse_coor_x mouse_coor_y mouse_holding time_before_spawn getEltOfList getEltOfListList
      time_before_spawn_restart set_mouse_holding listcreature game_running gamewindow game_over_txt speed_mul button_start addCreek creek_thread_fun;

  Lwt.async (fun () ->
    let open Lwt_js_events in
    mousedowns gamewindow
      (fun ev _ ->
        set_mouse_holding 1;
         let%lwt () = set_mouse_coor ev in
         Lwt.pick
           [mousemoves Js_of_ocaml.Dom_html.document (fun x _ -> set_mouse_coor x);
            let%lwt ev = mouseup Js_of_ocaml.Dom_html.document in set_mouse_holding 2; set_mouse_coor ev]))



