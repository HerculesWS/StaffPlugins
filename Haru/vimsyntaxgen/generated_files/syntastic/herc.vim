" Vim syntastic definition
" Language:    Hercules/*Athena Script
" Maintainer:  Haru <haru@dotalux.com>
" Last Change: 2013-12-11


" It is possible to add additional compiler options to the syntax
" checking execution via the variable 'g:syntastic_herc_compiler_options':
"
"   let g:syntastic_herc_compiler_options = ' -my_custom_options'
"
" Additionally the setting 'g:syntastic_herc_config_file' allows you to define a
" file that contains additional compiler arguments.
" The file is expected to contain one option per line. If none is
" given the filename defaults to '.syntastic_herc_config':
"
"   let g:syntastic_herc_config_file = '.config'
"
" Use the variable 'g:syntastic_herc_errorformat' to override the default error
" format:
"
"   let g:syntastic_herc_errorformat = '%f:%l:%c: %trror: %m'
"
" Set your compiler executable with e.g. (defaults to script-checker)
"
"   let g:syntastic_herc_compiler = '/path/to/Hercules/script-checker'

if exists('g:loaded_syntastic_herc_hercules_checker')
    finish
endif
let g:loaded_syntastic_herc_hercules_checker = 1

if !exists('g:syntastic_herc_compiler')
    let g:syntastic_herc_compiler = 'script-checker'
endif

function! SyntaxCheckers_herc_hercules_IsAvailable()
    return executable(g:syntastic_herc_compiler)
endfunction

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:syntastic_herc_compiler_options')
    let g:syntastic_herc_compiler_options = ''
endif

if !exists('g:syntastic_herc_config_file')
    let g:syntastic_herc_config_file = '.syntastic_herc_config'
endif

function! SyntaxCheckers_herc_hercules_GetLocList()
    "let makeprg = g:syntastic_herc_compiler . ''
    let makeprg = syntastic#makeprg#build({
        \ 'exe' : g:syntastic_herc_compiler,
        \ 'args' : '',
        \ 'filetype' : 'herc',
        \ 'subchecker' : 'hercules' })

    " Generic errors
    let errorformat =
        \ '[%tarning]: %m in file ''%f''%\, line ''%l''%.%#,' .
        \ '[%trror]: %m in file ''%f''%\, line ''%l''%.%#,'
    " from npc_parsename
    " > ShowWarning("npc_parsename: Display name of '%s' is too long (len=%u) in file '%s', line '%d'. Truncating to %u characters.\n");
    " > ShowWarning("npc_parsename: Unique name of '%s' is too long (len=%u) in file '%s', line '%d'. Truncating to %u characters.\n");
    " > ShowWarning("npc_parsename: Name '%s' is too long (len=%u) in file '%s', line '%d'. Truncating to %u characters.\n");
    " > ShowWarning("npc_parsename: Invalid unique name in file '%s', line '%d'. Renaming '%s' to '%s'.\n");
    " > ShowWarning("npc_parsename: Duplicate unique name in file '%s', line '%d'. Renaming '%s' to '%s'.\n");
    " (skip) ShowDebug("this npc:\n   display name '%s'\n   unique name '%s'\n   map=%s, x=%d, y=%d\n");
    " (skip) ShowDebug("other npc in '%s' :\n   display name '%s'\n   unique name '%s'\n   map=%s, x=%d, y=%d\n");
    let errorformat .=
        \ '%-G[Debug]: this npc:,' .
        \ '%-G[Debug]: other npc in ''%.%#'' :,'
    " from npc_parse_warp
    " > ShowError("npc_parse_warp: Invalid warp definition in file '%s', line '%d'.\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowError("npc_parse_warp: Unknown destination map in file '%s', line '%d' : %s\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowError("npc_parse_warp: out-of-bounds coordinates (\"%s\",%d,%d), map is %dx%d, in file '%s', line '%d'\n");
    let errorformat .= ''
    " from npc_parse_shop
    " > ShowError("npc_parse_shop: Invalid shop definition in file '%s', line '%d'.\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowError("npc_parse_shop: out-of-bounds coordinates (\"%s\",%d,%d), map is %dx%d, in file '%s', line '%d'\n");
    " > ShowError("npc_parse_shop: Invalid item definition in file '%s', line '%d'. Ignoring the rest of the line...\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowWarning("npc_parse_shop: Invalid sell item in file '%s', line '%d' (id '%d').\n");
    " > ShowWarning("npc_parse_shop: Item %s [%d] is being sold for FREE in file '%s', line '%d'.\n")
    " > ShowWarning("npc_parse_shop: Item %s [%d] discounted buying price (%d->%d) is less than overcharged selling price (%d->%d) at file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_shop: Ignoring empty shop in file '%s', line '%d'.\n");
    let errorformat .= ''
    " from npc_convertlabel_db
    " * ShowError("npc_parse_script: label name longer than 23 chars! (%s) in file '%s'\n");
    let errorformat .=
        \ '[%trror]: %m in file ''%f''%\%.,'
    " from npc_skip_script
    " > ShowError("npc_skip_script: Missing left curly in file '%s', line '%d'.\n");
    " > ShowError("Missing %d right curlys at file '%s', line '%d'.\n");
    let errorformat .= ''
    " from npc_parse_script
    " > ShowError("npc_parse_script: Invalid placement format for a script in file '%s', line '%d'. Skipping the rest of file...\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowError("npc_parse_script: Missing left curly ',{' in file '%s', line '%d'. Skipping the rest of the file.\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowWarning("npc_parse_script: duplicate event %s::%s in file '%s'.\n");
    let errorformat .= ''
    " from npc_parse_duplicate
    " > ShowError("npc_parse_script: bad duplicate name in file '%s', line '%d': %s\n");
    " > ShowError("npc_parse_script: original npc not found for duplicate in file '%s', line '%d': %s\n");
    " > ShowError("npc_parse_duplicate: Invalid placement format for duplicate in file '%s', line '%d'. Skipping line...\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowError("npc_parse_duplicate: out-of-bounds coordinates (\"%s\",%d,%d), map is %dx%d, in file '%s', line '%d'\n");
    " > ShowError("npc_parse_duplicate: Invalid span format for duplicate warp in file '%s', line '%d'. Skipping line...\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowWarning("npc_parse_duplicate: duplicate event %s::%s in file '%s'.\n");
    let errorformat .= ''
    " from npc_parse_function
    " > ShowError("npc_parse_function: Missing left curly '%%TAB%%{' in file '%s', line '%d'. Skipping the rest of the file.\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowWarning("npc_parse_function: Overwriting user function [%s] in file '%s', line '%d'.\n");
    let errorformat .= ''
    " from npc_parse_mob
    " > ShowError("npc_parse_mob: Invalid mob definition in file '%s', line '%d'.\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowError("npc_parse_mob: Unknown map '%s' in file '%s', line '%d'.\n");
    " > ShowError("npc_parse_mob: Spawn coordinates out of range: %s (%d,%d), map size is (%d,%d) - %s %s in file '%s', line '%d'.\n");
    " > ShowError("npc_parse_mob: Unknown mob ID %d in file '%s', line '%d'.\n");
    " > ShowError("npc_parse_mob: Invalid number of monsters %d, must be inside the range [1,1000] in file '%s', line '%d'.\n");
    " > ShowError("npc_parse_mob: Invalid size number %d for mob ID %d in file '%s', line '%d'.\n");
    " > ShowError("npc_parse_mob: Invalid ai %d for mob ID %d in file '%s', line '%d'.\n");
    " > ShowError("npc_parse_mob: Invalid level %d for mob ID %d in file '%s', line '%d'.\n");
    " > ShowError("npc_parse_mob: Invalid spawn delays %u %u in file '%s', line '%d'.\n");
    " > ShowError("npc_parse_mob: Invalid dataset for monster ID %d in file '%s', line '%d'.\n");
    let errorformat .= ''
    " from npc_parse_mapflag
    " > ShowError("npc_parse_mapflag: Invalid mapflag definition in file '%s', line '%d'.\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowWarning("npc_parse_mapflag: Unknown map in file '%s', line '%d' : %s\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowWarning("npc_parse_mapflag: Specified save point map '%s' for mapflag 'nosave' not found in file '%s', line '%d', using 'SavePoint'.\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " > ShowWarning("npc_parse_mapflag: You can't set PvP and GvG flags for the same map! Removing GvG flags from %s in file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_mapflag: You can't set PvP and BattleGround flags for the same map! Removing BattleGround flag from %s in file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_mapflag: You can't set PvP and BattleGround flags for the same map! Removing PvP flag from %s in file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_mapflag: You can't set GvG and BattleGround flags for the same map! Removing GvG flag from %s in file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_mapflag: Missing 5th param for 'adjust_unit_duration' flag! removing flag from %s in file '%s', line '%d'.\n")
    " > ShowWarning("npc_parse_mapflag: Unknown skill (%s) for 'adjust_unit_duration' flag! removing flag from %s in file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_mapflag: Invalid modifier '%d' for skill '%s' for 'adjust_unit_duration' flag! removing flag from %s in file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_mapflag: Missing 5th param for 'adjust_skill_damage' flag! removing flag from %s in file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_mapflag: Unknown skill (%s) for 'adjust_skill_damage' flag! removing flag from %s in file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_mapflag: Invalid modifier '%d' for skill '%s' for 'adjust_skill_damage' flag! removing flag from %s in file '%s', line '%d'.\n");
    " > ShowWarning("npc_parse_mapflag: Invalid zone '%s'! removing flag from %s in file '%s', line '%d'.\n");
    " > ShowError("npc_parse_mapflag: unrecognized mapflag '%s' in file '%s', line '%d'.\n");
    let errorformat .= ''
    " from npc_parsesrcfile
    " ShowError("npc_parsesrcfile: Parse error in file '%s', line '%d'. Stopping...\n");
    " ShowWarning("npc_parsesrcfile: w1 truncated, too much data (%d) in file '%s', line '%d'.\n");
    " ShowWarning("npc_parsesrcfile: w2 truncated, too much data (%d) in file '%s', line '%d'.\n");
    " ShowWarning("npc_parsesrcfile: w3 truncated, too much data (%d) in file '%s', line '%d'.\n");
    " ShowWarning("npc_parsesrcfile: w4 truncated, too much data (%d) in file '%s', line '%d'.\n");
    " ShowError("npc_parsesrcfile: Unknown syntax in file '%s', line '%d'. Stopping...\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    " ShowError("npc_parsesrcfile: Unknown map '%s' in file '%s', line '%d'. Skipping line...\n");
    " ShowError("npc_parsesrcfile: Unknown coordinates ('%d', '%d') for map '%s' in file '%s', line '%d'. Skipping line...\n");
    " ShowError("npc_parsesrcfile: Unable to parse, probably a missing or extra TAB in file '%s', line '%d'. Skipping line...\n * w1=%s\n * w2=%s\n * w3=%s\n * w4=%s\n");
    let errorformat .= ''
    " for ENABLE_CASE_CHECK
    let errorformat .=
        \ '[%trror]: %m (in ''%f'')%.%#,'

    let errorformat .=
        \ '%E[%trror]: %.script error in file ''%f'' line %l column %c,%Z%m,' .
        \ '%W[%tarning]: script error in file ''%f'' line %l column %c,%Z%m,' .
        \ '%-G[Debug]: mapindex_name2id: Map "%.%#" not found in index list!,' .
        \ '%E[%trror]: %m in file ''%f''%\, line ''%l'',%Z %# %m,' .
        \ '[%trror]: %m,' .
        \ '[%tarning]: %m,' .
        \ '%-G %.%#,' .
        \ '%-G* %.%#,' .
        \ '%m,'

    "if exists('g:syntastic_herc_errorformat')
    "    let errorformat = g:syntastic_herc_errorformat
    "endif

    " add optional user-defined compiler options
    "let makeprg .= g:syntastic_herc_compiler_options

    "let makeprg .= ' ' . syntastic#util#shexpand('%')

    " add optional config file parameters
    "let makeprg .= ' ' . syntastic#c#ReadConfig(g:syntastic_herc_config_file)

    " process makeprg
    return SyntasticMake({ 'makeprg': makeprg,
                \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'herc',
    \ 'name': 'hercules'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
