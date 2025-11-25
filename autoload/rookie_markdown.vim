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

    " Convert Chinese punctuation to English equivalents across buffer
    let punct_map = {
        \ '，': ',',
        \ '。': '.',
        \ '！': '!',
        \ '？': '?',
        \ '；': ';',
        \ '：': ':',
        \ '、': ',',
        \ '“': '"',
        \ '”': '"',
        \ '‘': "'",
        \ '’': "'",
        \ '（': '(',
        \ '）': ')',
        \ '【': '[',
        \ '】': ']',
        \ '《': '"',
        \ '》': '"',
        \ '「': '"',
        \ '」': '"',
        \ '『': '"',
        \ '』': '"',
        \ '…': '...',
        \ '—': '-',
        \ '～': '~',
        \ '·': '.',
        \ '‥': '..',
        \ '　': ' '
    \ }

    " Apply punctuation conversions from map
    for item in items(punct_map)
        let k = item[0]
        let v = item[1]
        execute '%s/' . escape(k, '/\') . '/' . escape(v, '/\') . '/ge'
    endfor

    " Normalize spaces after punctuation (single space), and fix dot sequences
    execute '%s/\([.,!?:]\)\s\+/\1 /ge'
    execute '%s/\([.,!?:;]\)\(\S\)/\1 \2/ge'
    execute '%s/\. \./../ge'

    " Normalize spacing around double quotes
    execute '%s/\(\S\)\s\+"\([^"\+]\+\)"/\1 "\2"/ge'
    execute '%s/\(\S\)"\([^"\+]\+\)"/\1 "\2"/ge'
    execute '%s/"\([^"\+]\+\)"\s\+\(\S\)/"\1" \2/ge'
    execute '%s/"\([^"\+]\+\)"\(\S\)/"\1" \2/ge'

    " Normalize spacing around parentheses and remove space before punctuation
    execute '%s/\(\S\)\s\+(/\1 (/ge'
    execute '%s/\(\S\)(/\1 (/ge'
    execute '%s/)\s\+\(\S\)/) \1/ge'
    execute '%s/)\(\S\)/) \1/ge'
    execute '%s/\([)]\) \([.,!?:\*]\)/\1\2/ge'

    " Insert spaces between ASCII and CJK characters (both directions)
    execute '%s/\([\x21-\x7e]\)\([^\x00-\xff]\)/\1 \2/ge'
    execute '%s/\([^\x00-\xff]\)\([\x21-\x7e]\)/\1 \2/ge'

    call setpos('.', save_cursor)
endfunction
