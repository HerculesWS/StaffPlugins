" Vim File type detection file
" Language:    Hercules/*Athena Script
" Maintainer:  Haru <haru@dotalux.com>
" Last Change: 2013-12-11


"if exists("did_load_filetypes")
"  finish
"endif
augroup filetypedetect
  " au! commands to set the filetype go here
  au! BufNewFile,BufRead *.txt call s:FTath()
  function! s:FTath()
    if getline(1) =~ '^//=.*\(eAthena\|rAthena\|Hercules\) Script'
      setf herc
    endif
  endfunction
augroup END
