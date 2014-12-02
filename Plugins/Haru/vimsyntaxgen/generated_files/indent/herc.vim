" Vim indent file
" Language:    Hercules/*Athena Script
" Maintainer:  Haru <haru@dotalux.com>
" Last Change: 2013-12-11


" Only load this indent file when no other was loaded.
if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

" C indenting is built-in, thus this is very simple
" Custom settings:
" - align contents of a case label with case rather than what follows it
" - disable preprocessor directives indentation
setlocal cindent cinoptions+=l1 cinkeys-=#

let b:undo_indent = "setl cin<"
