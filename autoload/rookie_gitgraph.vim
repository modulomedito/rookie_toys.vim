vim9script

export def OpenGitGraph(all_branches: bool)
    var cmd = 'Git log --graph --decorate '
    if all_branches
        cmd = cmd .. '--all '
    endif
    cmd = cmd .. '--pretty=format:"%h [%ad] {%an} |%d %s" --date=format-local:"%y-%m-%d %H:%M"'
    execute cmd
enddef
