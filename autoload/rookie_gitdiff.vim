vim9script

g:rookie_gitdiff_reg1 = ""
g:rookie_gitdiff_reg2 = ""
g:rookie_gitdiff_file = ""

export def Diff()
    var word = expand('<cword>')

    if g:rookie_gitdiff_file == ""
        if (len(word) == 7) && (word != "") && (word =~# '\v[0-9a-f]{7}')
            echo "RookieGitDiff: You should run command on your file first"
            return
        else
            g:rookie_gitdiff_file = expand('%')
        endif
    endif

    if g:rookie_gitdiff_reg1 == ""
        g:rookie_gitdiff_reg1 = word
        return
    else
        if g:rookie_gitdiff_reg1 != g:rookie_gitdiff_reg2
            g:rookie_gitdiff_reg2 = word
        else
            g:rookie_gitdiff_reg1 = ""
            g:rookie_gitdiff_reg2 = ""
            g:rookie_gitdiff_file = ""
            echo "RookieGitDiff: All saved variables cleaned"
            return
        endif
    endif

    var reg1 = g:rookie_gitdiff_reg1
    var reg2 = g:rookie_gitdiff_reg2
    var cmd1 = 'Gedit ' .. reg1 .. ':' .. g:rookie_gitdiff_file
    var cmd2 = 'vertical ' .. reg2 .. ':' .. g:rookie_gitdiff_file
    call execute(cmd1 .. ' | ' .. cmd2)
    g:rookie_gitdiff_reg1 = ""
    g:rookie_gitdiff_reg2 = ""
enddef

