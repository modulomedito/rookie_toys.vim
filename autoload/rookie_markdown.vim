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

function! rookie_markdown#MarkdownLinter() range abort
    " Condense blank lines
    let first = a:firstline
    let last  = a:lastline
    execute first . ',' . last . 's/\(\n\)\{3,}/\r\r/ge'
    let save_cursor = getpos('.')
    " Add blank line before headers (within range)
    let lnum = first
    while lnum <= last
        if getline(lnum) =~ '^\s*#\+\s'
            if lnum - 1 >= first
                let prev_content = getline(lnum - 1)
                if prev_content !~ '^\s*$' && prev_content !~ '^\s*#\+\s'
                    call append(lnum - 1, '')
                    let last += 1
                    let lnum += 1
                endif
            endif
        endif
        let lnum += 1
    endwhile

    " Add blank line after headers (within range)
    let lnum2 = first
    while lnum2 <= last
        if getline(lnum2) =~ '^\s*#\+\s'
            if lnum2 + 1 <= last
                let next_content = getline(lnum2 + 1)
                if next_content !~ '^\s*$' && next_content !~ '^\s*#\+\s'
                    call append(lnum2, '')
                    let last += 1
                endif
            endif
        endif
        let lnum2 += 1
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
    " Apply punctuation conversions from map
    for item in items(punct_map)
        let k = item[0]
        let v = item[1]
        execute first . ',' . last . 's/' . escape(k, '/\') . '/' . escape(v, '/\') . '/ge'
    endfor

    " Normalize spaces after punctuation (single space), and fix dot sequences
    execute first . ',' . last . 's/\([.,!?:]\)\s\+/\1 /ge'
    execute first . ',' . last . 's/\([.,!?:;]\)\(\S\)/\1 \2/ge'
    execute first . ',' . last . 's/\. \./../ge'

    " Normalize spacing around double quotes
    execute first . ',' . last . 's/\(\S\)\s\+"\([^"\+]\+\)"/\1 "\2"/ge'
    execute first . ',' . last . 's/\(\S\)"\([^"\+]\+\)"/\1 "\2"/ge'
    execute first . ',' . last . 's/"\([^"\+]\+\)"\s\+\(\S\)/"\1" \2/ge'
    execute first . ',' . last . 's/"\([^"\+]\+\)"\(\S\)/"\1" \2/ge'

    " Insert spaces between ASCII and CJK characters (both directions)
    execute first . ',' . last . 's/\([\x21-\x7e]\)\([^\x00-\xff]\)/\1 \2/ge'
    execute first . ',' . last . 's/\([^\x00-\xff]\)\([\x21-\x7e]\)/\1 \2/ge'

    " Remove space after '(' when followed by CJK
    execute first . ',' . last . 's/(\s\+\([^\x00-\xff]\))/(\1/ge'
    " Remove space before ')' when preceded by CJK
    execute first . ',' . last . 's/\([^\x00-\xff]\)\s\+)/\1)/ge'

    " Normalize spacing around parentheses and remove space before punctuation
    execute first . ',' . last . 's/\(\S\)\s\+(/\1 (/ge'
    execute first . ',' . last . 's/\(\S\)(/\1 (/ge'
    execute first . ',' . last . 's/)\s\+\(\S\)/) \1/ge'
    execute first . ',' . last . 's/)\(\S\)/) \1/ge'
    execute first . ',' . last . 's/\([)]\) \([.,!?:\*]\)/\1\2/ge'

    call setpos('.', save_cursor)
endfunction
