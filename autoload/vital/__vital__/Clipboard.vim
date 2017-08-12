"=============================================================================
" FILE: autoload/vital/__vital__/Clipboard.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================

function! s:_vital_loaded(V) abort
  let s:Base64 = a:V.import('Data.Base64')
endfunction

function! s:_vital_depends() abort
  return ['Data.Base64']
endfunction

" Copy text by sending string to the terminal clipboard using the OSC 52
" escape sequence, as specified in
" http://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-Operating-System-Commands,
" section 'Operating System Commands', Ps => 52.
"
" OSC stands for 'Operating System Commands'. (\x1b], <esc>])
" ST stands for 'String terminator'. (<esc>\)
"
" Format: \e]52;Pc;Pd\e\\
"
" \e]52; -> identifies this as a clipboard operation
" Pc       -> selection parameters for clipboard (it can be empty)
" Pd       -> selection data encoded in base64
" \e\\   -> string terminator
"
" References:
" - http://invisible-island.net/xterm/ctlseqs/ctlseqs.html
" - https://chromium.googlesource.com/chromiumos/platform/assets/+/factory-3004.B/chromeapps/hterm/doc/faq.txt
" - https://chromium.googlesource.com/apps/libapps/+/HEAD/hterm/etc/osc52.sh
" - http://qiita.com/kefir_/items/515ed5264fce40dec522
" - https://www.iterm2.com/documentation-escape-codes.html
" - https://sunaku.github.io/tmux-yank-osc52.html
function! s:copy_osc52(text) abort
  silent call system(printf("printf '%s' > /dev/tty", s:_osc52_sequence(a:text)))
  redraw!
endfunction

function! s:_osc52_sequence(text) abort
  let b64 = s:Base64.encode(a:text)
  if $TMUX !=# ''
    return printf("\ePtmux;\e\e]52;;%s\e\e\\\e\\", b64)
  elseif $TERM ==# 'screen'
    return printf("\eP\e]52;;%s]\x07\e\\", b64)
  else
    return printf("\e]52;;%s\e\\", b64)
  endif
endfunction

" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
