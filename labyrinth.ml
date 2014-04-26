open Printf
open Data

let get_path pred (xa,ya) (xb,yb) =
  let rec get_path' (x,y) path =
    if (x,y) = (xa,ya) then path
    else begin
      match pred.(x).(y) with
      | Some (dx,dy) -> get_path' (x-dx,y-dy) ((dx,dy) :: path)
      | None -> [] (* Should never happen *)
    end
  in
  get_path' (xb,yb) []

let shortest_path maze allowed (xa,ya) (xb,yb) =
  (* In pred we keep track of relative predecessors. *)
  let pred = Array.make_matrix maze.m maze.n None in
  let queue = Queue.create () in

  pred.(xa).(ya) <- Some (0,0);
  Queue.add (xa,ya) queue;
  try
    while not (Queue.is_empty queue) do
      let (x,y) = Queue.pop queue in
      Array.iter
        (fun (dx,dy) ->
          if (allowed maze.data.(x+dx).(y+dy)) then begin
            match pred.(x+dx).(y+dy) with
            | None ->
                begin
                  pred.(x+dx).(y+dy) <- Some (dx,dy);
                  if (x+dx,y+dy) = (xb,yb) then raise Exit;
                  Queue.push (x+dx,y+dy) queue
                end
            | Some _ -> ()
          end)
        [| (-1,0); (0,-1); (1,0); (0,1) |];
    done;
    []
  with
    Exit -> get_path pred (xa,ya) (xb,yb)

let is_door tile = 200 <= tile && tile < 400

let look_around maze (x,y) =
  let door_triplet = ref (0,0,0) in
  Array.iter
    (fun (dx,dy) ->
      if is_door maze.data.(x+dx).(y+dy) then begin
        if is_door maze.data.(x+dx+dx).(y+dy+dy) then
          door_triplet := (
            maze.data.(x).(y),
            maze.data.(x+dx).(y+dy),
            maze.data.(x+dx+dx).(y+dy+dy)
          )
        else
          door_triplet := (
            maze.data.(x-dx).(y-dy),
            maze.data.(x).(y),
            maze.data.(x+dx).(y+dy)
          )
      end
    )
    [| (-1,0); (0,-1); (1,0); (0,1) |];
  !door_triplet

let doors_along_path maze start path =
  let rec doors_along_path' (x,y) path doors =
    let tile = maze.data.(x).(y) in
    if is_door tile then
      let door_triplet = look_around maze (x,y) in
      let doors' = door_triplet :: doors in
      match path with
      | [] -> doors'
      | (dx,dy) :: tail -> doors_along_path' (x+dx,y+dy) tail doors'
    else
      match path with
      | [] -> doors
      | (dx,dy) :: tail -> doors_along_path' (x+dx,y+dy) tail doors
  in
  doors_along_path' start path []

let process_doors solver doors =
  let switches = Hashtbl.create 100 in
  let to_lit door =
    let switch = door mod 100 in
    let v =
      if Hashtbl.mem switches switch then
        Hashtbl.find switches switch
      else begin
        let v' = solver#new_var in
        Hashtbl.add switches switch v';
        v'
      end
    in
    if door < 300 then Minisat.neg_lit v
    else Minisat.pos_lit v
  in
  List.iter
    (fun (a,b,c) ->
      let lit_a = to_lit a in
      let lit_b = to_lit b in
      let lit_c = to_lit c in
      ignore(solver#add_clause [| lit_a; lit_b; lit_c |])
    )
    doors;
  switches

let find_tile maze tile =
  let pos = ref (0,0) in
  try
    for x = 1 to maze.m - 1 do
      for y = 1 to maze.n - 1 do
        if maze.data.(x).(y) = tile then begin
          pos := (x,y);
          raise Exit
        end
      done
    done;
    !pos
  with
    Exit -> !pos

let to_sequence path =
  let rec to_sequence' path sequence =
    match path with
    | (-1,0) :: tail -> to_sequence' tail (sequence ^ "U")
    | (0,-1) :: tail -> to_sequence' tail (sequence ^ "L")
    | (1,0) :: tail -> to_sequence' tail (sequence ^ "D")
    | (0,1) :: tail -> to_sequence' tail (sequence ^ "R")
    | _ -> sequence
  in
  to_sequence' path ""

let get_sequence maze allowed start toggle finish =
  let rec get_sequence' prev toggle chunks =
    match toggle with
    | [] ->
        let path = shortest_path maze allowed prev finish in
        let chunk = to_sequence path in
        chunk :: chunks
    | switch :: tail ->
        let switch_pos = find_tile maze (100 + switch) in
        let path = shortest_path maze allowed prev switch_pos in
        let chunk = to_sequence path in
        get_sequence' switch_pos tail ((chunk ^ "P") :: chunks)
  in
  let chunks = get_sequence' start toggle [] in
  String.concat "" (List.rev chunks)

let get_toggle solver switches =
  Hashtbl.fold
    (fun switch v toggle ->
      match solver#model.(v) with
      | Minisat.True -> switch :: toggle
      | _ -> toggle
    )
    switches
    []

let get_allow_open solver switches =
  let is_open door =
    let switch = door mod 100 in
    let v = Hashtbl.find switches switch in
    match solver#model.(v) with
    | Minisat.True -> door < 300
    | _ -> door >= 300
  in
  fun tile -> tile > 0 && (not (is_door tile) || is_open tile)

let solve level =
  let allow_all tile = tile <> 0 in
  let start = find_tile level.maze 2 in
  let finish = find_tile level.maze 3 in
  let path = shortest_path level.maze allow_all start finish in
  let doors = doors_along_path level.maze start path in
  let solver = new Minisat.solver in
  let switches = process_doors solver doors in
  if solver#solve then
    let toggle = get_toggle solver switches in
    let allow_open = get_allow_open solver switches in
    let s = get_sequence level.maze allow_open start toggle finish in
    { level with sequence = s }
  else
    { level with sequence = "ERROR" }

let print results =
  List.iter (
    fun result ->
      printf "{ name = \"%s\"\n  sequence = \"%s\"\n}\n" result.name result.sequence
  )
  results

let () =
  let results = List.map solve levels in
  print results
