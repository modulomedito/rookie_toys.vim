vim9script

g:rookie_gitdiff_sha1 = ""
g:rookie_gitdiff_file = ""

export def Diff()
    var word = expand('<cword>')
    var is_short_sha = ((len(word) == 7) && (word != "") && (word =~# '\v[0-9a-f]{7}'))

    if !is_short_sha
        g:rookie_gitdiff_file = expand('%')
        g:rookie_gitdiff_sha1 = ""
        echo "RookieGitDiff: Current file path saved, git sha cleared"
        return
    endif

    if g:rookie_gitdiff_file == ""
        echo "RookieGitDiff: You should run command on your file first"
        return
    endif

    if g:rookie_gitdiff_sha1 == ""
        g:rookie_gitdiff_sha1 = word
        echo "RookieGitDiff: Git commit sha saved. Next run command on ANOTHER commit sha"
        return
    endif

    if g:rookie_gitdiff_sha1 == word
        echo "RookieGitDiff: You should put cursor on ANOTHER valid git short sha (7 chars)"
        return
    endif

    var commit1 = g:rookie_gitdiff_sha1
    var commit2 = word
    var cmd1 = 'Gedit ' .. commit1 .. ':' .. g:rookie_gitdiff_file
    var cmd2 = 'vertical ' .. commit2 .. ':' .. g:rookie_gitdiff_file
    call execute(cmd1 .. ' | ' .. cmd2)

    g:rookie_gitdiff_sha1 = ""
    g:rookie_gitdiff_reg2 = ""
    g:rookie_gitdiff_file = ""
enddef

