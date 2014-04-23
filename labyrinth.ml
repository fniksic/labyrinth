(* Need to solve hard cases. *)

type level = {
  name : string;
  data : (int list) list
}

type result = {
  name : string;
  sequence : string
}

let () =
  let data_file = open_in "data.js" in
  let levels = parse data_file in
  let hard_levels = (* filter hard levels *) in
  let results = (* map solve_level hard_levels *) in
  print results
