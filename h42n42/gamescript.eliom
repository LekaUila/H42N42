(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   gamescript.eliom                                   :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/02/04 14:41:20 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/02/04 19:31:00 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let%shared width  = 300.
let%shared height = 300.

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

let%client init_client () =
  let log s () = Js_of_ocaml.Firebug.console##log (Js_of_ocaml.Js.string s) in
  let gamewindow = Js_of_ocaml.Dom_html.getElementById_opt "mon_svg" in
  let listcreature = ref [] in
  log "test" ();
  match gamewindow with
  | None -> log "SVG introuvable" ()
  | Some elt -> log "SVG trouvé" ();

  (* Créer un nouvel élément <image> SVG *)
    let svg_ns = "http://www.w3.org/2000/svg" in
      let img_svg =  Js_of_ocaml.Dom_html.document##createElementNS
          (Js_of_ocaml.Js.string svg_ns)
          (Js_of_ocaml.Js.string "image") in

      (* Définir les attributs *)
      img_svg##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string "50");
      img_svg##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string "50");
      img_svg##setAttribute (Js_of_ocaml.Js.string "width") (Js_of_ocaml.Js.string "50");
      img_svg##setAttribute (Js_of_ocaml.Js.string "height") (Js_of_ocaml.Js.string "50");
      img_svg##setAttribute (Js_of_ocaml.Js.string "href") (Js_of_ocaml.Js.string "./img/mayuri.jpeg");
      (* Ajouter l'image au SVG *)
      Js_of_ocaml.Dom.appendChild (Js_of_ocaml.Js.Unsafe.coerce elt) img_svg;
      listcreature := ({elt = img_svg; coord = {x = 50.; y = 50.}; direction = {x = 5.; y = 5.}; status = 0; holded = false;} : creature) :: !listcreature;

  (* Fonction à exécuter à chaque intervalle *)
  let callback () : unit =
    let rec moveCreature list = 
      match list with
      | [] -> []
      | hd :: tl ->
        let new_x_dir = 
          if hd.coord.x +. hd.direction.x < 0. || hd.coord.x +. 50. +. hd.direction.x > width then
            (hd.direction.x *. -1.)
          else
            (hd.direction.x)
        in
        let new_y_dir = 
          if hd.coord.y +. hd.direction.y < 0. || hd.coord.y +. 50. +. hd.direction.y > height then
            (hd.direction.y *. -1.)
          else
            (hd.direction.y);
        in
        let new_x_coor = hd.coord.x +. new_x_dir in
        let new_y_coor = hd.coord.y +. new_y_dir in
        hd.elt##setAttribute (Js_of_ocaml.Js.string "x") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_x_coor)));
        hd.elt##setAttribute (Js_of_ocaml.Js.string "y") (Js_of_ocaml.Js.string (string_of_int (int_of_float new_y_coor)));
        ({elt = hd.elt; coord = {x = new_x_coor; y = new_y_coor}; direction = {x = new_x_dir; y = new_y_dir}; status = hd.status; holded = hd.holded;} : creature) :: moveCreature tl
    in
    log "tick" ();
    listcreature := moveCreature !listcreature;
    ()
  in

  (* setInterval correctement typé *)
let _ = (Js_of_ocaml.Dom_html.window##setInterval (Js_of_ocaml.Js.wrap_callback callback) 25.  ) in ()

