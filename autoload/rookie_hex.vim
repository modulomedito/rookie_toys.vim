scriptencoding utf-8

function! rookie_hex#HexToAscii(...) abort
    let l:is_visual = get(a:, 1, 0)
    let l:hex_data = ''

    if l:is_visual
        let l:text = s:GetVisualSelection()
        " Check if it looks like Intel Hex (contains lines starting with :)
        if l:text =~# '^\s*:' || l:text =~# '\n\s*:'
             let l:hex_data = s:ParseIntelHexBlock(l:text)
        else
             let l:hex_data = s:CleanHex(l:text)
        endif
    else
        " Normal mode: Current line
        let l:line = getline('.')
        " Strip leading whitespace for check? Original code didn't.
        " Original code: l:line[0] !=# ':'
        " I will allow leading whitespace to be friendly, but original code was strict.
        " Requirement says "current intel hex line".
        if l:line =~# '^\s*:'
            let l:hex_data = s:ParseIntelHexLine(substitute(l:line, '^\s*', '', ''), 0)
        else
            echohl ErrorMsg
            echomsg "Current line is not a valid Intel HEX record (must start with ':')"
            echohl None
            return
        endif
    endif

    if l:hex_data ==# ''
        echomsg "No valid hex data found."
        return
    endif

    " Convert hex_data (raw hex string) to ASCII
    let l:result = s:HexToAsciiString(l:hex_data)

    " Echo result
    echo "Decoded: " . l:result

    " Copy to clipboard
    let @" = l:result
    if has('clipboard')
        let @+ = l:result
        echon " (Copied to clipboard)"
    else
        echon " (Copied to register \")"
    endif
endfunction

function! s:GetVisualSelection() abort
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif

    let selection_mode = visualmode()
    if selection_mode ==# 'v'
        " Character-wise
        let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
        let lines[0] = lines[0][column_start - 1:]
    elseif selection_mode ==# 'V'
        " Line-wise: lines are already correct
    elseif selection_mode ==# "\<C-V>"
        " Block-wise
        for i in range(len(lines))
            let lines[i] = lines[i][column_start - 1 : column_end - (&selection == 'inclusive' ? 1 : 2)]
        endfor
    endif
    return join(lines, "\n")
endfunction

function! s:ParseIntelHexBlock(text) abort
    let l:lines = split(a:text, "\n")
    let l:raw_hex = ''
    for l:line in l:lines
        let l:line = substitute(l:line, '^\s*', '', '')
        if l:line =~# '^:'
            let l:raw_hex .= s:ParseIntelHexLine(l:line, 1)
        endif
    endfor
    return l:raw_hex
endfunction

function! s:ParseIntelHexLine(line, silent) abort
    if len(a:line) < 1 || a:line[0] !=# ':'
        if !a:silent
            echohl ErrorMsg
            echomsg "Current line is not a valid Intel HEX record (must start with ':')"
            echohl None
        endif
        return ''
    endif

    " Parse Byte Count (chars 1-2)
    let l:byte_count_hex = strpart(a:line, 1, 2)
    let l:byte_count = str2nr(l:byte_count_hex, 16)

    " Parse Record Type (chars 7-8)
    let l:record_type = strpart(a:line, 7, 2)

    " Check if it is a Data Record (00)
    if l:record_type !=# '00'
        if !a:silent
            echomsg "Record type is " . l:record_type . " (not Data), skipping ASCII conversion."
        endif
        return ''
    endif

    " Extract Data (starts at index 9, length is byte_count * 2)
    return strpart(a:line, 9, l:byte_count * 2)
endfunction

function! s:CleanHex(text) abort
    return substitute(a:text, '[^0-9A-Fa-f]', '', 'g')
endfunction

function! s:HexToAsciiString(hex) abort
    let l:res = ''
    let l:i = 0
    while l:i < len(a:hex)
        let l:byte_hex = strpart(a:hex, l:i, 2)
        if len(l:byte_hex) < 2
            break
        endif
        let l:char_code = str2nr(l:byte_hex, 16)
        let l:res .= nr2char(l:char_code)
        let l:i += 2
    endwhile
    return l:res
endfunction
