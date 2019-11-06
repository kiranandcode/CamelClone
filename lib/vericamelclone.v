From Lib Require Import extraction.

Set Extraction File Comment  "Generated Automagically using Coq-extract - see corresponding .v file for proofs*)
open Core
(*".
Unset Extraction SafeImplicits.

From mathcomp.ssreflect Require Import ssreflect ssrnat ssrbool seq tuple eqtype .


Module Type AbstractCamelCloneParams.

  Variable t: Set.

  Variable expand_filename  : option t -> t.

  Variable perform_git_operations : bool -> bool -> t -> t -> unit.

  Variable load_operation_data :  option t -> (t * seq t).

  Variable post_task_operations : bool -> unit.

  Axiom Hvalid_perform_git_operations  : forall (x: t), load_operation_data (Some x) = (x, [::]).

End AbstractCamelCloneParams.


Module AbstractCamelClone (Params: AbstractCamelCloneParams).


  Definition command_internal' verbose strict o_name :=
     let (startdir,files) := Params.load_operation_data o_name in
     let values := map (Params.perform_git_operations verbose strict startdir) files in
     (Params.post_task_operations verbose,values).

  Definition command_internal verbose strict o_name :=
    fst (command_internal' verbose strict o_name).

End AbstractCamelClone.



Cd "lib".
Extraction "vericamelclone" AbstractCamelClone. 
Cd "..".
