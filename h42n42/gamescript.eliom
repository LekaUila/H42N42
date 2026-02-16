(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   gamescript.eliom                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/02/04 14:41:20 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/02/16 14:44:59 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open%client Js_of_ocaml_lwt

let%shared width  = 1000.
let%shared height = 500.

let%client creek_width = 50
let%client creek_height = 50

let%shared river_width = width
let%shared river_height = 50.

let%shared hospital_width = width
let%shared hospital_height = 50.

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
  let log s () = Js_of_ocaml.Firebug.console##log (Js_of_ocaml.Js.string s) in
  let mouse_coor_x = ref 0. in
  let mouse_coor_y = ref 0. in
  let mouse_holding = ref 0 in
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
      img_svg##setAttribute (Js_of_ocaml.Js.string "href") (Js_of_ocaml.Js.string "./img/geek_duck.png");
      (* Ajouter l'image au SVG *)
      Js_of_ocaml.Dom.appendChild (Js_of_ocaml.Js.Unsafe.coerce gamewindow) img_svg;
      list := ({elt = img_svg; coord = {x = (float_of_int x); y = (float_of_int y)}; direction = {x = 1.; y = 1.}; status = 0; holded = false;} : creature) :: !list;
      ()
  in

  (* Fonction à exécuter à chaque intervalle *)
  let callback () : unit =
    let rec moveCreature list = 
      match list with
      | [] -> []
      | hd :: tl ->
        if hd.holded then
        (
          if !mouse_holding == 2 then
          (
            hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int ((int_of_float !mouse_coor_x) - (creek_width / 2))));
            hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int ((int_of_float !mouse_coor_y) - (creek_height / 2))));
            ({elt = hd.elt; coord = {x = (!mouse_coor_x -. (float_of_int (creek_width / 2))); y = (!mouse_coor_y -. (float_of_int (creek_height / 2)))}; direction = hd.direction; status = hd.status; holded = false;} : creature) :: moveCreature tl
          )
          else
          (
            hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int ((int_of_float !mouse_coor_x) - (creek_width / 2))));
            hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int ((int_of_float !mouse_coor_y) - (creek_height / 2))));
            ({elt = hd.elt; coord = {x = (!mouse_coor_x -. (float_of_int (creek_width / 2))); y = (!mouse_coor_y -. (float_of_int (creek_height / 2)))}; direction = hd.direction; status = hd.status; holded = hd.holded;} : creature) :: moveCreature tl
          )
        )
        else
        (
          if !mouse_holding == 1 &&
            !mouse_coor_x < hd.coord.x +. (float_of_int creek_width) && hd.coord.x < !mouse_coor_x &&
            !mouse_coor_y < hd.coord.y +. (float_of_int creek_height) && hd.coord.y < !mouse_coor_y then
          (
            set_mouse_holding 0;
            hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int ((int_of_float !mouse_coor_x) - (creek_width / 2))));
            hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int ((int_of_float !mouse_coor_y) - (creek_height / 2))));
            ({elt = hd.elt; coord = {x = (!mouse_coor_x -. (float_of_int (creek_width / 2))); y = (!mouse_coor_y -. (float_of_int (creek_height / 2)))}; direction = hd.direction; status = hd.status; holded = true;} : creature) :: moveCreature tl
          )
          else
          (
            let new_x_dir = 
              if hd.coord.x +. hd.direction.x < 0. || hd.coord.x +. (float_of_int creek_width) +. hd.direction.x > width then
                (hd.direction.x *. -1.)
              else
                (hd.direction.x)
            in
            let new_y_dir = 
              if hd.coord.y +. hd.direction.y < 0. || hd.coord.y +. (float_of_int creek_height) +. hd.direction.y > height then
                (hd.direction.y *. -1.)
              else
                (hd.direction.y);
            in
            let new_x_coor = hd.coord.x +. new_x_dir in
            let new_y_coor = hd.coord.y +. new_y_dir in
            hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_x_coor)));
            hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_y_coor)));
            ({elt = hd.elt; coord = {x = new_x_coor; y = new_y_coor}; direction = {x = new_x_dir; y = new_y_dir}; status = hd.status; holded = hd.holded;} : creature) :: moveCreature tl
          )
        )
    in
    log "tick" ();
    listcreature := moveCreature !listcreature;
    set_mouse_holding 0;
    ()
  in
  addCreek listcreature gamewindow 75 75;
  addCreek listcreature gamewindow 0 0;

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



