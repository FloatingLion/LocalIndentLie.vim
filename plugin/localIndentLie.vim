" configuration {{{
"
" COMMAND:
" :LocalIndentLieOn
" Enable LocalIndentLie.
"
" COMMAND:
" :LocalIndentLieOff
" Disable it.
"
" COMMAND:
" :LocalIndentLieStatus
" Check LocalIndentLie's status (on|off).
"
" VARIABLE:
" g:localIndentLie_char :: Char
" Default:     '|'
" Alternative: '¦', '┆', '┊', ...
" 
" VARIABLE:
" g:localIndentLie_guiColor  :: String
" g:localIndentLie_termColor :: String
" Default: Link to <highlight>:Operator
" Specify: '#RRGGBB' or 'red' 'grey' ...
"          see more in :help cterm-colors and :help gui-colors
"
" VARIABLE:
" g:localIndentLie_insertDisable :: Bool(1|0)
" Default: 0
" Use `let g:localIndentLie_insertDisable = 1` to disable LocalIndentLie in 
" Insert-Mode
"
" VARIABLE:
" g:localIndentLie_useconceal :: Bool(1|0)
" Default: 1
" LocalIndentLie will link your <highlight>Conceal in global, and adjust your
" &conceallevel and &concealcursor in buffer. Use 
" `let g:localIndentLie_useconceal = 0` to set them by manual.
"
" LICENSE: MIT
" }}}

" ==============================================================================

if exists('g:loaded_LocalIndentLie')
  finish
endif
let g:loaded_LocalIndentLie = 1

if !has('conceal') || !exists('*matchaddpos')
  command! LocalIndentLieOn     echo "Your vim isn't supporting LocalIndentLie."
  command! LocalIndentLieOff    echo "Your vim isn't supporting LocalIndentLie."
  command! LocalIndentLieStatus echo "Your vim isn't supporting LocalIndentLie."
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

"content{{{

"global variables{{{
if !exists('g:localIndentLie_char')
  let g:localIndentLie_char = '|'
endif

if !exists('g:localIndentLie_useconceal')
  let g:localIndentLie_useconceal = 1
endif

if !exists('g:localIndentLie_insertDisable')
  let g:localIndentLie_insertDisable = 0
endif

if !exists('g:_localIndentLie')
  let g:_localIndentLie = {
        \ 'lower': 0,
        \ 'upper': 0,
        \ 'level': 0,
        \ 'key':  [],
        \}
endif

"}}}

"command{{{
command! -nargs=0 LocalIndentLieOn call s:SwitchLocalIndentLieOn()
command! -nargs=0 LocalIndentLieOff call s:SwitchLocalIndentLieOff()
command! -nargs=0 LocalIndentLieStatus echo s:CheckStatus()
autocmd FileType * call s:CleanLocalLie()
"}}}

"SwitchLocalIndentLie{{{

"On{{{
function s:SwitchLocalIndentLieOn()
  if g:localIndentLie_insertDisable
    augroup localIndentLie
      au!
      autocmd CursorMoved,TextChanged,InsertLeave <buffer> call s:Update(0)
      autocmd BufWinLeave,WinLeave,BufLeave,TabLeave,InsertEnter <buffer> call s:CleanLocalLie()
    augroup END
  else
    augroup localIndentLie
      au!
      autocmd CursorMoved,TextChanged <buffer> call s:Update(0)
      autocmd CursorMovedI,TextChangedI <buffer> call s:Update(1)
      autocmd BufWinLeave,WinLeave,BufLeave,TabLeave <buffer> call s:CleanLocalLie()
    augroup END
  endif
  let b:localIndentLieLineRec   = -1
  let b:localIndentLieIndentRec = -1

  if exists('b:localIndentLieRunning')
    return
  endif
  let b:localIndentLieCLRec  = &conceallevel
  let b:localIndentLieCCRec = &concealcursor
  let &l:conceallevel          = 1
  let &l:concealcursor         = "vin"

  if g:localIndentLie_useconceal
    if !exists('g:localIndentLie_termColor') && !exists('g:localIndentLie_guiColor')
      highlight! link Conceal Operator
    else
      if !exists('g:localIndentLie_termColor')
        let g:localIndentLie_termColor = '245'
      endif
      if !exists('g:localIndentLie_guiColor')
        let g:localIndentLie_guiColor = 'grey'
      endif
      execute 'highlight LocalIndentLieDefault cterm=NONE ctermfg=' . g:localIndentLie_termColor .
            \ ' ctermbg=NONE gui=NONE guifg=' . g:localIndentLie_guiColor . " guibg=NONE"
      highlight! link Conceal LocalIndentLieDefault
    endif
  endif
  let b:localIndentLieRunning = 1
endfunction
"}}}

"Off{{{
function s:SwitchLocalIndentLieOff()
  if !exists('b:localIndentLieRunning')
    return
  endif
  call s:CleanLocalLie()
  let &l:conceallevel = b:localIndentLieCLRec
  let &l:concealcursor = b:localIndentLieCCRec
  augroup localIndentLie
    autocmd!
  augroup END
  unlet b:localIndentLieRunning
endfunction
"}}}

"}}}

"s:LookupIndentArea{{{
function s:LookupIndentArea(theLine, theIndent)
  if a:theIndent == 0
    return 0
  endif

  let winMin = line('w0') - 1
  let winMax = line('w$') + 1
  
  let leftBound     = a:theLine
  let leftBoundPrev = prevnonblank(leftBound - 1)
  let prevIndent = indent(leftBoundPrev)
  while leftBound > winMin && prevIndent >= a:theIndent
    let leftBound     = leftBoundPrev
    let leftBoundPrev = prevnonblank(leftBound - 1)
    let prevIndent    = indent(leftBoundPrev)
  endwhile
  if prevIndent >= a:theIndent
    return 0
  endif

  let rightBound     = a:theLine
  let rightBoundNext = nextnonblank(rightBound + 1)
  let nextIndent = indent(rightBoundNext)
  while rightBound < winMax && nextIndent >= a:theIndent
    let rightBound     = rightBoundNext
    let rightBoundNext = nextnonblank(rightBound + 1)
    let nextIndent     = indent(rightBoundNext)
  endwhile

  let upperIndent = prevIndent < nextIndent ? nextIndent : prevIndent
  if upperIndent <= 0 || upperIndent >= a:theIndent
    return 0
  else
    let g:_localIndentLie.lower = leftBound
    let g:_localIndentLie.upper = rightBound
    let g:_localIndentLie.level = upperIndent
    return 1
  endif
endfunction
"}}}

"s:CleanLocalLie{{{
function s:CleanLocalLie()
  if !empty(g:_localIndentLie.key)
    for k in g:_localIndentLie.key
      silent! call matchdelete(k)
    endfor
    let g:_localIndentLie.key= []
  endif
endfunction
"}}}

"s:Update{{{
function s:Update(pre_check)
  let currentLine   = line('.')
  let currentIndent = indent(currentLine)
  if a:pre_check && 
        \ b:localIndentLieLineRec   == currentLine &&
        \ b:localIndentLieIndentRec == currentIndent
    return
  endif
  let b:localIndentLieLineRec   = currentLine
  let b:localIndentLieIndentRec = currentIndent

  call s:CleanLocalLie()

  if !s:LookupIndentArea(currentLine, currentIndent) ||
        \ g:_localIndentLie.lower > g:_localIndentLie.upper
    return
  endif

  let where = g:_localIndentLie.level + 1

  let iter   = g:_localIndentLie.lower
  let bound  = g:_localIndentLie.upper
  let guides = []
  while iter <= bound
    for _ in range(1, 8)
      call add(guides, [iter, where])
      let iter += 1
      if iter > bound
        break
      endif
    endfor
    call add(g:_localIndentLie.key,
          \ matchaddpos('Conceal', guides, 90, -1, { 'conceal': g:localIndentLie_char }))
    let guides = []
  endwhile
endfunction
"}}}

"s:CheckStatus{{{
function s:CheckStatus()
  if exists('b:localIndentLieRunning')
    return 'on'
  else
    return 'off'
  endif
endfunction
"}}}

"}}}

let &cpo = s:save_cpo
unlet s:save_cpo
