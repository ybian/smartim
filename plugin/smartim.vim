if exists('did_smartim_loaded') | finish | endif
let did_smartim_loaded = 1

if !exists("g:smartim_default")
    let g:smartim_default = "com.apple.keylayout.US"
endif

let s:imselect_path = expand('<sfile>:p:h') . "/im-select "
let s:im_status_save_path = $HOME . "/.vim_smartim_status"

function! SmartIM_ForceDefault()
    if exists('g:smartim_disable')
        return
    endif
    let l:a = system(s:imselect_path . g:smartim_default)
endfunction

function! SmartIM_SelectDefault()
    if exists('g:smartim_disable')
        return
    endif
    let b:saved_im = system(s:imselect_path)
    call writefile([b:saved_im], s:im_status_save_path)
    let l:a = system(s:imselect_path . g:smartim_default)
endfunction

function! SmartIM_SelectSaved()
    if exists('g:smartim_disable')
        return
    endif
    if filereadable(s:im_status_save_path)
      let b:saved_im = get(readfile(s:im_status_save_path), 0)
    endif
    if exists("b:saved_im")
        let l:a = system(s:imselect_path . b:saved_im)
    endif
endfunction

augroup smartim
  autocmd!
  autocmd VimLeavePre * call SmartIM_ForceDefault()
  autocmd InsertLeave * call SmartIM_SelectDefault()
  autocmd InsertEnter * call SmartIM_SelectSaved()
augroup end
