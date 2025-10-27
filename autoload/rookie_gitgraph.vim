scriptencoding utf-8

function! rookie_gitgraph#OpenGitGraph(all_branches) abort
    let cmd = 'Git log --graph --decorate '
    if a:all_branches
        let cmd = cmd . '--all '
    endif
    let cmd = cmd . '--pretty=format:"%h [%ad] {%an} |%d %s" --date=format-local:"%y-%m-%d %H:%M"'

    for b in getbufinfo({'bufloaded': 1})
        if getbufvar(b.bufnr, '&filetype') ==# 'git'
            execute 'bd ' . b.bufnr
        endif
    endfor
    execute cmd
endfunction
