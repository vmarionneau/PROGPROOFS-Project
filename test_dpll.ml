
open Format

let run f =
  let t = Unix.gettimeofday () in
  f ();
  let t = Unix.gettimeofday () -. t in
  printf "%2.2f s@." t

let z = Z.of_int

type dimacs = { nb_variables: int; clauses: int list list }

let read_cnf (file: string) : dimacs =
  let c = open_in file in
  let rec read_p () =
    let s = input_line c in
    if s = "" || s.[0] = 'c' then read_p () else
    Scanf.sscanf s "p cnf %d %d" (fun nv nc -> nv, nc) in
  let nv, nc = read_p () in
  let rec read_c cl b =
    let l = Scanf.bscanf b " %d" (fun i -> i) in
    if l = 0 then List.rev cl else read_c (l :: cl) b in
  let cnf = ref [] in
  for _ = 1 to nc do
    let b = Scanf.Scanning.from_string (input_line c) in
    cnf := read_c [] b :: !cnf
  done;
  { nb_variables = nv; clauses = List.rev !cnf }

open Dpll

let make_3sat dimacs : int * int * cls array =
  let nv = ref dimacs.nb_variables in
  let clause3 acc cl =
    let rec split acc = function
      | []        -> assert false
      | [a]       -> (z a, z 0, z 0) :: acc
      | [a; b]    -> (z a, z b, z 0) :: acc
      | [a; b; c] -> (z a, z b, z c) :: acc
      | a :: b :: cl ->
          incr nv; split ((z a, z b, z !nv) :: acc) (- !nv :: cl)
    in
    split acc cl
  in
  let cl = List.fold_left clause3 [] dimacs.clauses in
  dimacs.nb_variables, !nv, Array.of_list cl

let file = Sys.argv.(1)
let dimacs = read_cnf file
let ov, nv, cl = make_3sat dimacs
let () = printf "%d variables, %d clauses@." nv (Array.length cl)

let is_sat () =
  let v = Array.make (1 + nv) Z.zero in
  if sat v cl then (
    printf "SAT@.";
    for i = 1 to ov do
      printf "%a " Z.pp_print v.(i)
    done;
    printf "0@.";
  ) else
    printf "UNSAT@."

let () = run is_sat
