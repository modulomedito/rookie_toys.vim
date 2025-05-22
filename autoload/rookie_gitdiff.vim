vim9script

g:rookie_gitdiff_reg1 = ""
g:rookie_gitdiff_reg2 = ""

export def Diff()
    var word = expand('<cword>')

    if g:rookie_gitdiff_reg1 == ""
        g:rookie_gitdiff_reg1 = word
        return
    else
        if g:rookie_gitdiff_reg1 != g:rookie_gitdiff_reg2
            g:rookie_gitdiff_reg2 = word
        else
            g:rookie_gitdiff_reg1 = ""
            g:rookie_gitdiff_reg2 = ""
            return
        endif
    endif

    var reg1 = g:rookie_gitdiff_reg1
    var reg2 = g:rookie_gitdiff_reg2
    var cmd1 = 'Gedit ' .. reg1 .. ':' .. expand('%')
    var cmd2 = 'vertical ' .. reg2 .. ':' .. expand('%')
    call execute(cmd1 .. ' | ' .. cmd2)
    g:rookie_gitdiff_reg1 = ""
    g:rookie_gitdiff_reg2 = ""
enddef

