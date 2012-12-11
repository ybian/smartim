if g:smartim_status == "enable"
    if !exists("g:smartim_default")
        let g:smartim_default = "com.apple.keylayout.US"
    endif
    
    function! SmartIM_SelectDefault()
        let b:saved_im = system("im-select")
        let l:a = system("im-select " . g:smartim_default)
    endfunction
    
    function! SmartIM_SelectSaved()
       if exists("b:saved_im")
          let l:a = system("im-select " . b:saved_im)
       endif
    endfunction
    
    autocmd InsertLeave * call SmartIM_SelectDefault()
    autocmd InsertEnter * call SmartIM_SelectSaved()
endif
