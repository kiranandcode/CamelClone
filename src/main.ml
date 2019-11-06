open Core
open Lib

(* https://ocaml.janestreet.com/ocaml-core/latest/doc/core_kernel/Core_kernel/Command/Param/index.html *)

module type AbstractCamelCloneParams = sig

  type t

  val expand_filename  : t option -> t

  val perform_git_operations : bool -> bool -> t -> t -> unit

  val load_operation_data :  t option -> (t * t list)

  val post_task_operations : bool -> unit

end

module CamelCloneParams : AbstractCamelCloneParams with type t = string = struct
  type t = string
let expand_filename o_name = match o_name with
     Some v -> v
  |  None -> let name = ".camelclone" in  
  match Sys.getenv "HOME" with
    None -> name
  | Some v -> Filename.concat v name
                
let perform_git_operations verbose strict startdir file =
      try
        if verbose then print_endline (sprintf "INFO: Processing repository %s" file);
        Sys.chdir file;
        let add_result = Sys.command "git add ." in
        if verbose then print_endline (sprintf "INFO: added files %d" add_result);
        let currtime = (Time.to_string (Time.now ())) in
        if not ( Sys.command (sprintf "git commit -m \"CAMELCLONE AUTOCOMMIT %s\"" currtime) = 0)
        then raise (Sys_error (sprintf "error in git commit -m \"CAMELCLONE AUTOCOMMIT %s\"" currtime));
        if not ( Sys.command (sprintf "git push\"") = 0 )
        then raise (Sys_error (sprintf "error in git commit -m \"CAMELCLONE AUTOCOMMIT %s\"" currtime));
        Sys.chdir startdir;
        ()
      with
      | Sys_error (m)  -> if strict
        then raise (Sys_error m)
        else if verbose then print_endline (sprintf "INFO: adding repository %s failed %s" file m);
        Sys.chdir startdir
let load_operation_data o_name =
  let name = expand_filename o_name in
  let config = (Stdio__In_channel.read_all name) in
  let files = List.map ~f:String.strip (String.split_lines config) in
  let startdir = Sys.getcwd () in
  (startdir, files)
let post_task_operations verbose = 
  if verbose then print_endline "INFO: Completed task"; ()
end


module AbstractCamelClone (Params: AbstractCamelCloneParams) = struct
let command_internal verbose strict o_name =
  let (startdir, files) = Params.load_operation_data o_name in
  let _ = List.map files ~f:(Params.perform_git_operations verbose strict startdir) in
  Params.post_task_operations verbose
end

module CamelClone = AbstractCamelClone(CamelCloneParams)


let command =
  let open Command.Let_syntax in
  Command.basic
    ~summary:"Push changes to selected local repositories online."
    ~readme:(fun () -> "Intended to be run as a chron job for syncing repositories used for coordination")
    [%map_open
      let filename =
        flag "config" (optional string)
          ~doc:"configuration file to load repositories, defaults to ~/.camelclone"

      and verbose =
        flag "verbose" (optional_with_default false bool)
          ~doc:"whether the program should print detailed information. Defaults to false."

      and strict =
        flag "strict" (optional_with_default false bool)
          ~doc:"whether the program should immediately if any files are not found. Defaults to false."
      in
      fun () -> try
          CamelClone.command_internal verbose strict filename 
        with
          Sys_error (msg) -> print_endline (sprintf "ERROR(System): %s" msg)
    ]

let () =
  Command.run ~version:"1.0" ~build_info:"KGO" command

