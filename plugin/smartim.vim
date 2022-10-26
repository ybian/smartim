" =============================================================================
" A plugin to make vim stand well with input methods (Mac only)
" Author:       Ying Bian <bianying@gmail.com>
" Last Change:  2022-09-27
" Version:      1.0.1
" Repository:   https://github.com/ybian/smartim
" License:      MIT
" =============================================================================

if exists('g:smartim_loaded') || &cp
  finish
endif
let g:smartim_loaded = 1

if !exists("g:smartim_default")
  let g:smartim_default = "com.apple.keylayout.US"
endif

if !exists("g:smartim_disable")
  let g:smartim_disable = 0
endif

if !exists("g:smartim_debug")
  let g:smartim_debug = 0
endif

let s:imselect_path = expand('<sfile>:p:h') . "/im-select"
let s:smartim_debug_output = $HOME . "/vim_smartim_debug_output"

function! Smartim_debug_print(msg)
  if g:smartim_debug == 0
    return
  endif

  let l:debug_msg = strftime("[%Y-%m-%d_%H:%M:%S]") . ' ' . a:msg
  silent call writefile([l:debug_msg], s:smartim_debug_output, "a")
endfunction

function! Smartim_start_debug()
  if g:smartim_debug == 0
    return
  endif

  let l:start_debug_msg = strftime("[%Y-%m-%d_%H:%M:%S]") . " - Debug Start"
  silent call writefile([l:start_debug_msg], s:smartim_debug_output)

  call Smartim_debug_print('g:smartim_loaded = ' . g:smartim_loaded)
  call Smartim_debug_print('g:smartim_default = ' . g:smartim_default)
  call Smartim_debug_print('g:smartim_disable = ' . g:smartim_disable)
  call Smartim_debug_print('g:smartim_debug = ' . g:smartim_debug)
  call Smartim_debug_print('s:imselect_path = ' . s:imselect_path)
endfunction

call Smartim_start_debug()

function! s:Smartim_GetInputMethodHandler_Vim(channel, msg)
  call s:Smartim_RestoreDefaultIm(a:msg)
endfunction

function! s:Smartim_GetInputMethodHandler_Nvim(job_id, data, event) dict
  let output = a:data[0][:-1]
  if len(output)
    call s:Smartim_RestoreDefaultIm(output)
  endif
endfunction

function! s:Smartim_RestoreDefaultIm(current)
    silent let b:saved_im = a:current
    silent call system(s:imselect_path . ' ' .g:smartim_default)
    call Smartim_debug_print('b:saved_im = ' . b:saved_im)
    call Smartim_debug_print('<<< Smartim_SelectDefault returned ' . v:shell_error)
endfunction

function! Smartim_SelectDefault()
  call Smartim_debug_print('>>> Smartim_SelectDefault')

  if g:smartim_disable == 1 
    return
  endif

  if has('job')
    call job_start([s:imselect_path], {'callback': 's:Smartim_GetInputMethodHandler_Vim'})
  elseif has('nvim')
    call jobstart([s:imselect_path], {'on_stdout' : function('s:Smartim_GetInputMethodHandler_Nvim')})
  else
    silent let output = system(s:imselect_path)
    silent call s:Smartim_RestoreDefaultIm(output)
  endif

endfunction

function! Smartim_SelectSaved()
  call Smartim_debug_print('>>> Smartim_SelectSaved')
  if g:smartim_disable == 1 
    return
  endif
  if exists("b:saved_im") && b:saved_im != g:smartim_default
    if has('job')
      call job_start([s:imselect_path, b:saved_im])
    elseif has('nvim')
      call jobstart([s:imselect_path, b:saved_im])
    else
      silent call system(s:imselect_path . ' '. b:saved_im)
    endif
    call Smartim_debug_print('b:saved_im=' . b:saved_im.'')
    call Smartim_debug_print('<<< Smartim_SelectSaved returned ' . v:shell_error)
  else
    call Smartim_debug_print('<<< Smartim_SelectSaved returned')
  endif
endfunction

augroup smartim
  autocmd!
  autocmd VimLeavePre * call Smartim_SelectDefault()
  autocmd InsertLeave * call Smartim_SelectDefault()
  autocmd InsertEnter * call Smartim_SelectSaved()
augroup end

" vim:ts=2:sw=2:sts=2