" autoload/rookie_syntax.vim

if exists('g:autoload_rookie_syntax')
    finish
endif
let g:autoload_rookie_syntax = 1

let s:extensions = {}

" Function to register new syntax extensions
" name: String identifier for the extension
" filetypes: List of filetypes to apply this extension to (empty for all)
" callback: Funcref to call to setup the syntax
function! rookie_syntax#RegisterExtension(name, filetypes, callback) abort
    let s:extensions[a:name] = {
        \ 'filetypes': a:filetypes,
        \ 'callback': a:callback
        \ }
endfunction

" Main setup function called on FileType event
function! rookie_syntax#Setup() abort
    if !get(g:, 'rookie_toys_syntax_highlight_enable', 1)
        return
    endif

    let l:ft = &filetype
    if empty(l:ft)
        return
    endif

    for [l:name, l:ext] in items(s:extensions)
        if empty(l:ext.filetypes) || index(l:ext.filetypes, l:ft) >= 0
            try
                call call(l:ext.callback, [])
            catch
                " Ignore errors in extensions to prevent breaking other things
            endtry
        endif
    endfor
endfunction

" Doxygen support implementation
function! rookie_syntax#Doxygen() abort
    " Define the doxygen keyword matches
    " Match @keyword or \keyword
    syntax match RookieDoxygenKeyword /@\w\+/ contained
    syntax match RookieDoxygenKeyword /\\\w\+/ contained

    highlight default link RookieDoxygenKeyword SpecialComment

    " List of common comment groups in various languages
    let l:comment_groups = [
        \ 'cComment', 'cCommentL',
        \ 'cppComment', 'cppCommentL',
        \ 'javaComment', 'javaDocComment', 'javaLineComment',
        \ 'vimComment', 'vimLineComment',
        \ 'pythonComment',
        \ 'csComment', 'csXmlComment',
        \ 'phpComment', 'phpDocComment',
        \ 'javascriptComment', 'jsComment', 'jsDocComment',
        \ 'typescriptComment', 'tsComment', 'tsDocComment',
        \ 'rustComment', 'rustCommentLine', 'rustCommentBlock'
        \ ]

    let l:group_str = join(l:comment_groups, ',')

    " Inject the doxygen keywords into these groups
    execute 'syntax match RookieDoxygenKeyword /@\w\+/ contained containedin=' . l:group_str
    execute 'syntax match RookieDoxygenKeyword /\\\w\+/ contained containedin=' . l:group_str
endfunction

" Register the built-in Doxygen extension
call rookie_syntax#RegisterExtension('doxygen',
    \ ['c', 'cpp', 'java', 'vim', 'python', 'cs', 'php', 'javascript', 'typescript', 'rust'],
    \ function('rookie_syntax#Doxygen'))
