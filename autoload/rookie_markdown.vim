scriptencoding utf-8

function! rookie_markdown#ConvertMarkdownTitleToAnchorLink() abort
    let current_line = line('.')
    let title = substitute(getline('.'), '^#\+\s*', '', '')

    let anchor = substitute(tolower(title), '[ _]\+', '-', 'g')
    let anchor = substitute(anchor, '[()]', '', 'g')
    let anchor = substitute(anchor, '[^a-z0-9-]', '', 'g')
    let anchor = substitute(anchor, '-\+', '-', 'g')
    let anchor = substitute(anchor, '^-\|-$', '', 'g')

    let mdlink = printf("[%s](#%s)", title, anchor)
    call append(current_line - 1, mdlink)
endfunction

function! rookie_markdown#MarkdownLinter() abort
    " Condense blank lines
    silent! %s/\(\n\)\{3,}/\r\r/g
    let save_cursor = getpos('.')
    normal! gg

    " Add blank line before headers
    while search('^\s*#\+\s', 'W') > 0
        let current_line = line('.')
        let prev_line = current_line - 1

        if prev_line > 0
            let prev_content = getline(prev_line)
            if prev_content !~ '^\s*$' && prev_content !~ '^\s*#\+\s'
                call append(prev_line, '')
            endif
        endif
    endwhile

    " Add blank line after headers
    normal! gg
    while search('^\s*#\+\s', 'W') > 0
        let current_line = line('.')
        let next_line = current_line + 1

        if next_line <= line('$')
            let next_content = getline(next_line)
            if next_content !~ '^\s*$' && next_content !~ '^\s*#\+\s'
                call append(current_line, '')
            endif
        endif
    endwhile

    call setpos('.', save_cursor)
endfunction
