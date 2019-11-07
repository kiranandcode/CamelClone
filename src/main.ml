open Core
open Lib


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
          (* 100% verified no errors nada nilch. Tests are for loosers *)
          Camelclone.command_internal ~verbose ~strict ~filename 
        with
          Sys_error (msg) -> print_endline (sprintf "ERROR(System): %s" msg)
    ]

let () =
  Command.run ~version:"1.0" ~build_info:"KGO" command

