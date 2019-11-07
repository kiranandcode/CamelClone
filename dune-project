(lang dune 1.11)
(generate_opam_files true)
(package
   (name "CamelClone")
   (description "Automatically upload changes to selected repositories")
   (depends
      (coq (and (>= 8.9) (< 8.10)))
      (core (and (>= 0.12) (< 0.13)))
      (coq-mathcomp-ssreflect (and (>= 1.9) (< 1.10)))
   ))

