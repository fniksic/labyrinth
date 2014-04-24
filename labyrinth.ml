(* Need to solve hard cases. *)

open Printf

type level =
  { name: string;
    data : int array array;
    sequence : string
  }

let parse file = [
  { name = "Easy 6";
    data = [|
      [|   0;   0;   0;   0;   0;   0;   0;   0;   0;   0;   0;   0;   0;   0|];
      [|   0;   0;   0;   1;   1;   1;   1;   1;   1;   1;   1;   1;   1;   0|];
      [|   0;   0;   0;   1;   0;   0;   0;   0;   0;   0;   0;   0;   1;   0|];
      [|   0;   1; 202;   1;   0;   1;   1;   1;   1;   1;   0;   1;   1;   0|];
      [|   0;   1; 300;   1;   0;   1;   0;   0;   0;   1;   0;   1;   0;   0|];
      [|   0;   1; 203;   1;   0;   1;   0;   0;   0;   1;   0;   1;   1;   0|];
      [|   0;   1;   0;   0;   1;   1;   1;   0;   1;   1;   1;   0;   1;   0|];
      [|   0;   1;   0;   0;   1;   1;   1;   0; 203; 200; 202;   0;   1;   0|];
      [|   0;   1;   1;   0; 302; 200; 201;   0;   1;   1;   1;   0;   1;   0|];
      [|   0;   0;   1;   0;   1;   1;   1;   0;   1;   1;   1;   0;   1;   0|];
      [|   0;   1;   1;   0; 302; 203; 201;   0; 201; 302; 200;   0;   1;   0|];
      [|   0;   1;   0;   0;   1;   1;   1;   0;   1;   1;   1;   0;   3;   0|];
      [|   0;   1;   0;   0;   0;   1;   0;   0;   1;   1;   1;   0;   0;   0|];
      [|   0;   1;   1; 200;   1;   1;   0; 100;   1;   1;   1; 102;   0;   0|];
      [|   0;   1;   1; 203;   1;   1;   0;   0;   1;   1;   1;   0;   0;   0|];
      [|   0;   0;   1; 201;   1;   0;   0; 101;   1;   2;   1; 103;   0;   0|];
      [|   0;   0;   0;   0;   0;   0;   0;   0;   0;   0;   0;   0;   0;   0|]
    |];
    sequence = ""
  }
]

let solve level =
  { level with sequence = "TEST" }

let print results =
  List.iter (
    fun result ->
      printf "{ name = \"%s\"\n  sequence = \"%s\"\n}\n" result.name result.sequence
  )
  results

let () =
  let file = open_in "data.js" in
  let levels = parse file in
  let hard_levels = (* filter hard levels *) levels in
  let results = List.map solve hard_levels in
  print results
