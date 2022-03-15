;; To use this file to build HEAD of odgi:
;;
;;   guix build -f guix.scm
;;
;; To get a development container (emacs shell will work)
;;
;;   guix shell -C -D -f guix.scm --expose=../odgi=/odgi
;;
;; Because of cmake out-of-tree builds we can do:
;;
;;   guix shell -C -D -f guix.scm --share=../odgi=/odgi -c 1 -M 1
;;   mkdir -p build
;;   cd build
;;   cmake -DCMAKE_BUILD_TYPE=Debug -DINLINE_HANDLEGRAPH_SOURCES=ON /odgi
;;   make
;;   make install
;;   cd ..
;;   ruby test.rb
;;
;; env LD_LIBRARY_PATH=$GUIX_ENVIRONMENT/lib:/odgi/lib:./libbf-prefix/lib/ LD_PRELOAD=libjemalloc.so.2:libsdsl.so:libbf.so ruby ../test.rb
;;
;; renders
;;
;; Hello, World using libc!
;; "ODGI version: 2e1cd30"

(use-modules
  (ice-9 popen)
  (ice-9 rdelim)
  ((guix licenses) #:prefix license:)
  (guix gexp)
  (guix packages)
  (guix download)
  (guix git-download)
  (guix build-system cmake)
  (guix utils)
  (gnu packages base)
  (gnu packages compression)
  (gnu packages bioinformatics)
  (gnu packages build-tools)
  (gnu packages commencement) ; gcc-toolchain
  (gnu packages curl)
  (gnu packages datastructures)
  (gnu packages gdb)
  (gnu packages gcc)
  (gnu packages jemalloc)
  (gnu packages libffi)
  (gnu packages mpi)
  (gnu packages python)
  (gnu packages python-xyz)
  (gnu packages pkg-config)
  (gnu packages ruby)
  (gnu packages tls)
  (gnu packages version-control)
)

(define %source-dir (dirname (current-filename)))

(define %git-commit
  (read-string (open-pipe "git show HEAD | head -1 | cut -d ' ' -f 2" OPEN_READ)))

(define-public odgi-git
  (package
    (name "odgi-git")
    (version (git-version "0.6.3" "HEAD" %git-commit))
    (source (local-file %source-dir #:recursive? #t))
    (build-system cmake-build-system)
    (inputs
     `(
       ("coreutils" ,coreutils)
       ; ("cpp-httplib" ,cpp-httplib) later!
       ("pybind11" ,pybind11) ;; see libstd++ note in remarks above
       ; ("intervaltree" ,intervaltree) later!
       ("jemalloc" ,jemalloc)
       ("gcc" ,gcc-11)
       ("gcc-lib" ,gcc-11 "lib")
       ("gcc-toolchain" ,gcc-toolchain)
       ("gdb" ,gdb)
       ("git" ,git)
       ; ("lodepng" ,lodepng) later!
       ("openmpi" ,openmpi)
       ("python" ,python)
       ("ruby" ,ruby)
       ("ruby-ffi" ,ruby-ffi)
       ("sdsl-lite" ,sdsl-lite)
       ("libdivsufsort" ,libdivsufsort)
       ))
    (native-inputs
     `(("pkg-config" ,pkg-config)
       ))
    (arguments
      `(#:phases
        (modify-phases
         %standard-phases
         ;; This stashes our build version in the executable
         (add-after 'unpack 'set-version
           (lambda _
             (mkdir-p "include")
             (with-output-to-file "include/odgi_git_version.hpp"
               (lambda ()
                 (format #t "#define ODGI_GIT_VERSION \"~a\"~%" version)))
             #t))
         (delete 'check))
        #:make-flags (list ,(string-append "CC=" (cc-for-target)))))
     (synopsis "odgi optimized dynamic sequence graph implementation")
     (description
"odgi provides an efficient, succinct dynamic DNA sequence graph model, as well
as a host of algorithms that allow the use of such graphs in bioinformatic
analyses.")
     (home-page "https://github.com/vgteam/odgi")
     (license license:expat)))

odgi-git
