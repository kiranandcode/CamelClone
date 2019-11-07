# Camel Clone - 0% tested, 100% correct!
Example verified program built using Othudd theorem driven development.

Camel Clone implements a fairly simple algorithm that, given a
sequence of file directories containing git repositories as input from
a configuration file, navigates to each repository then commits and
pushes any changes to their respective remotes.

```
Push changes to selected local repositories online.

  camelclone.exe 

Intended to be run as a chron job for syncing repositories used for coordination

=== flags ===

  [-config configuration]  file to load repositories, defaults to ~/.camelclone
  [-strict]                whether the program should immediately exit if any files are not
                           found. Defaults to false.
  [-verbose]               whether the program should print detailed information.
                           Defaults to false.
```


As this software was developed using a theorem driven development
 cycle, it comes with a formally verified proof of correctness - see
 `lib/vericamelclone.v`.

Hence, CamelClone is 0% tested, but certainly 100% correct.

*Just you try adding a bug pull request.*


## Requirements
 - Coq - 8.9
 - Ssreflect - 1.9
 - Ocaml
 - Dune
 - Core

## Setup
1. Run make

```
make
```

4. Verify it works with
```
make run
```

