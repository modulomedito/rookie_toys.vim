vim9script

export def ConvertMarkdownTitleToAnchorLink()
    var current_line = line('.')
    var title = substitute(getline('.'), '^#\+\s*', '', '')

    var anchor = substitute(tolower(title), '[ _]\+', '-', 'g')
    anchor = substitute(anchor, '[()]', '', 'g')
    anchor = substitute(anchor, '[^a-z0-9-]', '', 'g')
    anchor = substitute(anchor, '-\+', '-', 'g')
    anchor = substitute(anchor, '^-\|-$', '', 'g')

    var mdlink = printf("[%s](#%s)", title, anchor)
    call append(current_line - 1, mdlink)
enddef

export def MarkdownLinter()
    # Condense blank lines
    silent! :%s/\(\n\)\{3,}/\r\r/g
    var save_cursor = getpos('.')
    normal! gg

    # Add blank line before headers
    while search('^\s*#\+\s', 'W') > 0
        var current_line = line('.')
        var prev_line = current_line - 1

        if prev_line > 0
            var prev_content = getline(prev_line)
            if prev_content !~ '^\s*$' && prev_content !~ '^\s*#\+\s'
                append(prev_line, '')
            endif
        endif
    endwhile

    # Add blank line after headers
    normal! gg
    while search('^\s*#\+\s', 'W') > 0
        var current_line = line('.')
        var next_line = current_line + 1

        if next_line <= line('$')
            var next_content = getline(next_line)
            if next_content !~ '^\s*$' && next_content !~ '^\s*#\+\s'
                append(current_line, '')
            endif
        endif
    endwhile

    setpos('.', save_cursor)
enddef
