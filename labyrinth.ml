(* Need to solve hard cases. *)

open Printf

type labyrinth =
  { m : int;
    n : int;
    data : int array array
  }

type level =
  { name : string;
    maze : labyrinth;
    sequence : string
  }

let levels = [
  { name = "Easy 6";
    maze =
      { m = 15;
        n = 12;
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
        |]
      };
    sequence = ""
  }
]

let find_value maze v =
  let pos = ref None in
  try
    for x = 1 to maze.m do
      for y = 1 to maze.n do
        if maze.data.(x).(y) = v then begin
          pos := Some (x,y);
          raise Exit
        end
      done
    done;
    !pos
  with
    Exit -> !pos

let shortest_path maze allowed (xa,ya) (xb,yb) =
  (* In pred we keep track of relative predecessors. *)
  let pred = Array.make_matrix (maze.m + 2) (maze.n + 2) None in
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
    Exit ->
      (* Recover the path *)
      let rec get_path (x,y) path =
        if (x,y) = (xa,ya) then path
        else begin
          match pred.(x).(y) with
          | Some (dx,dy) -> get_path (x-dx,y-dy) ((dx,dy) :: path)
          | None -> [] (* Should never happen *)
        end in
      get_path (xb,yb) []

let solve level =
  (* Roughly like this:
    * Find the shortest path from start to finish.
    * See which clauses it hits.
    * Construct a formula: not c if c is open, c if c is closed
    * Get a satisfying assignment: visit circles c for which c is true.
    * From the last circle, go to finish. Allowed fields are 1, 2, 3, 1xx, and
    * 3xx or 4xx depending on the satisfying assignment.
    * Concatenate all paths.
    *)
  { level with sequence = "TEST" }

let print results =
  List.iter (
    fun result ->
      printf "{ name = \"%s\"\n  sequence = \"%s\"\n}\n" result.name result.sequence
  )
  results

let print_path path =
  printf "[";
  List.iter (
    fun (dx,dy) ->
      printf "(%d,%d)" dx dy
  )
  path;
  printf "]\n"

let () =
  (* let results = List.map solve levels in
  print results *)
  List.iter (
    fun level ->
      let allowed v = v <> 0 in
      let oa = find_value level.maze 2 in
      let ob = find_value level.maze 3 in
      match oa with
      | Some a ->
          begin match ob with
          | Some b ->
              print_path (shortest_path level.maze allowed a b)
          | None -> ()
          end
      | None -> ()
  ) levels
