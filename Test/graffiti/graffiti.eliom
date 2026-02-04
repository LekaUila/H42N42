(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   graffiti.eliom                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/01/15 13:41:27 by Leka Uïla         #+#    #+#             *)
(*   Updated: 2026/02/03 16:49:36 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

open%client Js_of_ocaml_lwt
open%server Eliom_content.Html.D (* provides functions to create HTML nodes *)
open%client Js_of_ocaml

[@@@ocaml.warning "-39"] (* disable warning 39 because wtf this warning is ? *)
type%shared messages =
    ((int * int * int) * int * (int * int) * (int * int))
    [@@deriving json]
[@@@ocaml.warning "+39"]

module Graffiti_app =
  Eliom_registration.App (struct
      let application_name = "graffiti"
      let global_data_path = None
    end)

let%server width  = 700
let%server height = 400

let%client draw ctx ((r, g, b), size, (x1, y1), (x2, y2)) =
  let color = CSS.Color.string_of_t (CSS.Color.rgb r g b) in
  ctx##.strokeStyle := (Js.string color);
  ctx##.lineCap := Js.string "round";
  ctx##.lineWidth := float size;
  ctx##beginPath;
  ctx##(moveTo (float x1) (float y1));
  ctx##(lineTo (float x2) (float y2));
  ctx##stroke

let%server canvas_elt =
  Eliom_content.Html.D.canvas ~a:[Eliom_content.Html.D.a_width width; Eliom_content.Html.D.a_height height]
    [Eliom_content.Html.D.txt "your browser doesn't support canvas"]

let%server page () =
  html
     (head (title (txt "Graffiti")) [])
     (body [h1 [txt "Graffiti"];
            canvas_elt])

let%server bus = Eliom_bus.create [%json: messages]

let%client init_client () =

  let canvas = Eliom_content.Html.To_dom.of_canvas ~%canvas_elt in
  let ctx = canvas##(getContext (Dom_html._2d_)) in
  
  let x = ref 0 and y = ref 0 in

  let set_coord ev =
    let x0, y0 = Dom_html.elementClientPosition canvas in
    x := ev##.clientX - x0; y := ev##.clientY - y0
  in

  let compute_line ev =
    let oldx = !x and oldy = !y in
    set_coord ev;
    ((0, 0, 0), 5, (oldx, oldy), (!x, !y))
  in

  let line ev =
    let v = compute_line ev in
    let _ = Eliom_bus.write ~%bus v in
    draw ctx v;
    Lwt.return ()
  in

  Lwt.async (fun () ->
    let open Lwt_js_events in
    mousedowns canvas
      (fun ev _ ->
         set_coord ev;
         let%lwt () = line ev in
         Lwt.pick
           [mousemoves Dom_html.document (fun x _ -> line x);
            let%lwt ev = mouseup Dom_html.document in line ev]));
  Lwt.async (fun () ->
    Lwt_stream.iter (draw ctx) (Eliom_bus.stream ~%(bus : (messages, messages) Eliom_bus.t)))




let%server main_service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["graff"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let%server () =
  Graffiti_app.register
    ~service:main_service
    (fun () () ->
       (* Cf. section "Client side side-effects on the server" *)
       let _ = [%client (init_client () : unit) ] in
       Lwt.return (page ()))
