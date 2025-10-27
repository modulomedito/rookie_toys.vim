scriptencoding utf-8

function! rookie_lsp#Setup() abort
    " Configure autocmds and LSP servers
    augroup RookieLsp
        autocmd!
        autocmd BufRead *.c,*.cpp LspDiag highlight disable | setlocal iskeyword-=-
        autocmd User LspSetup call LspOptionsSet({'autoHighlightDiags': v:true})
        autocmd User LspSetup call LspAddServer([
        \ {'name': 'c', 'filetype': ['c', 'cpp'], 'path': 'clangd', 'args': ['--background-index']},
        \ {'name': 'markdown', 'filetype': ['markdown'], 'path': 'marksman', 'args': ['server'], 'syncInit': v:true},
        \ {'name': 'rust', 'filetype': ['rust'], 'path': 'rust-analyzer', 'args': [], 'syncInit': v:true},
        \ {'name': 'toml', 'filetype': ['toml'], 'path': 'taplo', 'args': ['lsp', 'stdio'], 'syncInit': v:true},
        \ ])
    augroup END

    nnoremap <leader>rn             :LspRename<CR>
    nnoremap <silent> <S-M-f>       :LspFormat<CR>
    nnoremap <silent> <leader>hh    :LspSwitchSourceHeader<CR>
    nnoremap <silent> [d            :LspDiagPrev<CR>
    nnoremap <silent> ]d            :LspDiag highlight enable<CR>:LspDiagNext<CR>
    nnoremap <silent> gS            :LspSymbolSearch<CR>
    nnoremap <silent> gd            :LspGotoDefinition<CR>
    nnoremap <silent> gh            :LspHover<CR>
    nnoremap <silent> gi            :LspGotoImpl<CR>
    nnoremap <silent> gr            :LspShowReferences<CR>
    nnoremap <silent> gs            :LspDocumentSymbol<CR>
    nnoremap <silent> gy            :LspGotoTypeDef<CR>
endfunction
