if exists('g:loaded_tailf')
  finish
endif
let g:loaded_tailf = 1

let s:save_cpo = &cpo
set cpo&vim

let g:tailf_timer_interval = get(g:, 'tailf_timer_interval', 500)

let s:tailf_timer_id = v:none
let s:last_timestamp = v:none

function! s:get_timestamp(path) abort
  let cmd = 'stat --print=%y ' . a:path
  return trim(system(cmd))
endfunction

function! s:polling() abort
  let timestamp = s:get_timestamp(expand('%:p'))
  if timestamp !=# s:last_timestamp
    let s:last_timestamp = timestamp
    silent exe ':e'
    silent normal! G
  endif
endfunction

function! s:start() abort
  let s:tailf_timer_id = timer_start(
        \ g:tailf_timer_interval,
        \ {-> s:polling()}, {'repeat': -1})
endfunction

function! s:stop() abort
  if !empty(s:tailf_timer_id)
    call timer_stop(s:tailf_timer_id)
  endif
endfunction

command! TailfStart call s:start()
command! TailfStop  call s:stop()

let &cpo = s:save_cpo
unlet s:save_cpo

