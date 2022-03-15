# Ruby bindings for ODGI efficient pangenome tools

This module allows fast processing of pangenome graphs using the ODGI C++ tooling.

See [guix.scm](./guix.scm) header how to build odgi and run ruby-odgi.
The idea is to create a GNU Guix container with all dependencies and the odgi (git recursive) sources in ../odgi directory.
Next build odgi with shared libs and we are good to go in Ruby!
