scriptencoding utf-8

let g:rookie_gitdiff_sha1 = ''
let g:rookie_gitdiff_file = ''

function! rookie_gitdiff#Diff() abort
    if !exists(':Git')
        echo "RookieGitDiff: vim-fugitive is NOT installed, diff depends on it!"
        return
    endif

    let word = expand('<cword>')
    let is_short_sha = ((len(word) == 7) && (word != '') && (word =~# '\v[0-9a-f]{7}'))

    if !is_short_sha
        let g:rookie_gitdiff_file = expand('%')
        let g:rookie_gitdiff_sha1 = ''
        echo 'RookieGitDiff: Current file path saved, git sha cleared'
        return
    endif

    if g:rookie_gitdiff_file == ''
        echo 'RookieGitDiff: You should run command on your file first'
        return
    endif

    if g:rookie_gitdiff_sha1 == ''
        let g:rookie_gitdiff_sha1 = word
        echo 'RookieGitDiff: Git commit sha saved. Next run command on ANOTHER commit sha'
        return
    endif

    if g:rookie_gitdiff_sha1 == word
        echo 'RookieGitDiff: You should put cursor on ANOTHER valid git short sha (7 chars)'
        return
    endif

    let commit1 = g:rookie_gitdiff_sha1
    let commit2 = word
    let cmd1 = 'Gsplit ' . commit1 . ':' . substitute(g:rookie_gitdiff_file, '\\', '/', 'g')
    let cmd2 = 'vertical Gdiffsplit ' . commit2 . ':' . substitute(g:rookie_gitdiff_file, '\\', '/', 'g')
    let cmd_final = cmd1 . ' | ' . cmd2

    execute cmd_final
    let g:rookie_gitdiff_sha1 = ''
endfunction

