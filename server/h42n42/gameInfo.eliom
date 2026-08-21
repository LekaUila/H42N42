(* ************************************************************************** *)
(*                                                                            *)
(*                                                        :::      ::::::::   *)
(*   gameInfo.eliom                                     :+:      :+:    :+:   *)
(*                                                    +:+ +:+         +:+     *)
(*   By: Leka Uïla <liam.flandrinck.58@gmail.com    +#+  +:+       +#+        *)
(*                                                +#+#+#+#+#+   +#+           *)
(*   Created: 2026/08/18 14:52:33 by lflandri          #+#    #+#             *)
(*   Updated: 2026/08/21 18:36:52 by Leka Uïla        ###   ########.fr       *)
(*                                                                            *)
(* ************************************************************************** *)

let%shared width  = 1000.
let%shared height = 500.
let%shared river_width = width
let%shared river_height = 50.
let%shared hospital_width = width
let%shared hospital_height = 100.

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
let%client nb_starting_creek = 10




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