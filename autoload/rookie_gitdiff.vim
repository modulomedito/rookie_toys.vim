vim9script

g:rookie_gitdiff_temp = ""
g:rookie_gitdiff_file = ""

export def Diff()
    var word = expand('<cword>')
    var word_is_short_sha = ((len(word) == 7) && (word != "") && (word =~# '\v[0-9a-f]{7}'))

    if g:rookie_gitdiff_file == ""
        if word_is_short_sha
            echo "RookieGitDiff: You should run command on your file first"
            return
        else
            g:rookie_gitdiff_file = expand('%')
            return
        endif
    endif

    if !word_is_short_sha
        echo "RookieGitDiff: You should put cursor on a valid git short sha (7 chars)"
        return
    endif

    if g:rookie_gitdiff_temp == ""
        g:rookie_gitdiff_temp = word
        return
    endif

    if g:rookie_gitdiff_temp == word
        echo "RookieGitDiff: You should put cursor on ANOTHER valid git short sha (7 chars)"
        return
    endif

    var commit1 = g:rookie_gitdiff_temp
    var commit2 = word
    var cmd1 = 'Gedit ' .. commit1 .. ':' .. g:rookie_gitdiff_file
    var cmd2 = 'vertical ' .. commit2 .. ':' .. g:rookie_gitdiff_file
    call execute(cmd1 .. ' | ' .. cmd2)

    g:rookie_gitdiff_temp = ""
    g:rookie_gitdiff_reg2 = ""
    g:rookie_gitdiff_file = ""
enddef

