scriptencoding utf-8

function! rookie_plugins#SetupPlugins() abort
    if exists('g:textmanip_enable_mappings')
        call rookie_plugins#Setup_VimTextmanip()
    endif
endfunction

function! rookie_plugins#Setup_VimTextmanip() abort
    xnoremap <M-d>                  <Plug>(textmanip-duplicate-down)
    nnoremap <M-d>                  <Plug>(textmanip-duplicate-down)
    xnoremap <M-D>                  <Plug>(textmanip-duplicate-up)
    nnoremap <M-D>                  <Plug>(textmanip-duplicate-up)
    xnoremap <C-j>                  <Plug>(textmanip-move-down)
    xnoremap <C-k>                  <Plug>(textmanip-move-up)
    xnoremap <C-h>                  <Plug>(textmanip-move-left)
    xnoremap <C-l>                  <Plug>(textmanip-move-right)
    nnoremap <F6>                   <Plug>(textmanip-toggle-mode)
    xnoremap <F6>                   <Plug>(textmanip-toggle-mode)
    xnoremap <Up>                   <Plug>(textmanip-move-up-r)
    xnoremap <Down>                 <Plug>(textmanip-move-down-r)
    xnoremap <Left>                 <Plug>(textmanip-move-left-r)
    xnoremap <Right>                <Plug>(textmanip-move-right-r)
endfunction
