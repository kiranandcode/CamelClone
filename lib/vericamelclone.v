From Lib Require Import extraction.

Set Extraction File Comment  "Generated Automagically using Coq-extract - see corresponding .v file for proofs*)
open Core
(*".
Unset Extraction SafeImplicits.

From mathcomp.ssreflect Require Import ssreflect ssrnat ssrbool seq tuple eqtype .

Variable State : Set .
Variable InitialState : State .
Variable Repository : Set .
Variable Create_repositories : State -> Repository .
Variable State_updated_repositories : State -> seq Repository.
Variable State_update : unit -> State -> State.

(* Lightweight formulation of the abstract interface for the tool *)
Module Type AbstractCamelCloneParams.

  Variable t: Set.

  Axiom State: Set.
  Axiom initialState: State.


  Variable expand_filename  : option t -> t.


  Variable perform_git_operations :  State -> bool -> bool -> t -> t ->  (unit * State).

  Variable load_operation_data :  State -> option t ->  (t * seq t) * State.

  Variable post_task_operations : State -> bool ->  unit * State.

End AbstractCamelCloneParams.



Module AbstractCamelClone (Params: AbstractCamelCloneParams).


  Definition command_internal' state verbose strict o_name :=
    let (pair,state') := Params.load_operation_data state o_name in
    let (startdir,files) := pair in 
    let values := foldr (fun file state' => snd (Params.perform_git_operations state' verbose strict startdir file)) state' files in
    (Params.post_task_operations values verbose).

  Definition command_internal verbose strict o_name :=
    (command_internal' Params.initialState verbose strict o_name).

End AbstractCamelClone.

Module Proofs.
  (* Full specification of the abstract interface with all assumed preconditions *)
  Module ConcreteParams <: AbstractCamelCloneParams.
    Variable t: Set.
    Axiom State: Set.
    Axiom initialState: State.
    (* Initial sequence of updated git repositories *)
    Axiom GitRepositories: Set.
    Axiom State_git_repositories : State -> seq GitRepositories.
    (* Initially none of the  repositories are updated *)
    Axiom Hinit_State_git_repositories : State_git_repositories initialState  = [::].
    Axiom State_get_repository : State -> t -> GitRepositories.
    (* The mapping of files to repositories is unchanged by each application *)
    Axiom Hvalid_State_get_repository : forall file state state', State_get_repository state file =
                                                              State_get_repository state' file.
    Variable expand_filename  : option t -> t.
    (* Assume that the function doesn't fail on any input, and is deterministic *)
    Axiom H_expand_filename_none  : exists x, expand_filename None = x.
    Axiom H_expand_filename_some  : forall x, expand_filename (Some x) = x.
    Variable perform_git_operations :  State -> bool -> bool -> t -> t ->  (unit * State).
    (* Assume that performing git operations will always add the repository corresponding to its
     third argument to the list *)
    Axiom Hvalid_perform_git_operations : forall state state' verbose strict startdir file,
        perform_git_operations state verbose strict startdir file = (tt,state') ->
        (State_get_repository state file) :: State_git_repositories state = State_git_repositories state'.
    Variable load_operation_data :  State -> option t ->  (t * seq t) * State.
    (* Assume that loading operation data will not change as the repositories are updated *)
    Axiom Hvalid_load_operation_data : forall o_name, exists result, forall state,  (load_operation_data state o_name) = (result,state).
    Variable post_task_operations : State -> bool ->  unit * State.
    (* Assume that post task operation data will not change the number of updated repositories *)
    Axiom Hvalid_post_task_operations : forall state verbose, snd (post_task_operations state verbose) = state.
  End ConcreteParams.

  Module ConcreteCamelClone := AbstractCamelClone ConcreteParams.


  Export ConcreteCamelClone.
  Export ConcreteParams.


  (* Formal proof of 100% correctness - no bug reports allowed! *)
  Lemma Hcamel_clone_validity : forall verbose strict, forall o_name,
        ConcreteParams.State_git_repositories (snd (command_internal verbose strict o_name)) = 
        [seq State_get_repository initialState file
        | file <- snd (fst (ConcreteParams.load_operation_data initialState o_name))].
    (* Todo in a bit *)
    move=> verb strict o_name //=; rewrite/command_internal/command_internal'//=.
    case: ( Hvalid_load_operation_data o_name) => [[startdir files]] Hstate; rewrite Hstate //=.
    rewrite Hvalid_post_task_operations/snd //=.
    clear Hstate; elim: files => [| file files Hfiles]; first by apply Hinit_State_git_repositories.

    move=>//=.


    erewrite <-Hvalid_perform_git_operations with
        (file := file) (verbose:=verb) (strict:=strict) (startdir:=startdir) (state:= (foldr
          (fun (file0 : ConcreteParams.t) (state' : State) =>
           let (_, y) := ConcreteParams.perform_git_operations state' verb strict startdir file0 in y)
          initialState files)).
    by rewrite -Hfiles -(Hvalid_State_get_repository file initialState _).
    by case: (ConcreteParams.perform_git_operations _ _ _ _) => [[]] //=.
  Qed.
  
End Proofs.    
    





Cd "lib".
Extraction "vericamelclone" AbstractCamelClone. 
Cd "..".
