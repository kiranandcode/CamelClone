open Core

open Vericamelclone



(* https://ocaml.janestreet.com/ocaml-core/latest/doc/core_kernel/Core_kernel/Command/Param/index.html *)


module CamelCloneParams : AbstractCamelCloneParams with
  type t = string and
  type coq_State = unit = struct
  type t = string
  type coq_State = unit

  let initialState = ()

  let expand_filename o_name = match o_name with
      Some v -> v
    |  None -> let name = ".camelclone" in  
      match Sys.getenv "HOME" with
        None -> name
      | Some v -> Filename.concat v name

  let perform_git_operations () verbose strict startdir file =
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
      (),()
    with
    | Sys_error (m)  -> if strict
      then raise (Sys_error m)
      else if verbose then print_endline (sprintf "INFO: adding repository %s failed %s" file m);
      Sys.chdir startdir;
      (),()

  let load_operation_data () o_name =
    let name = expand_filename o_name in
    let config = (Stdio__In_channel.read_all name) in
    let files = List.map ~f:String.strip (String.split_lines config) in
    let startdir = Sys.getcwd () in
    (startdir, files),()

  let post_task_operations () verbose = 
    if verbose then print_endline "INFO: Completed task"; (),()
end

module Impl  = AbstractCamelClone(CamelCloneParams)

let command_internal  ~verbose ~strict ~filename = 
          fst (Impl.command_internal verbose strict filename)


