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

function! s:UpdateLineChecksum(lnum) abort
    let l:line = getline(a:lnum)
    " Remove whitespace
    let l:clean_line = substitute(l:line, '^\s*', '', '')
    let l:clean_line = substitute(l:clean_line, '\s*$', '', '')

    if l:clean_line !~# '^:'
        return 0
    endif

    let l:content = l:clean_line[1:]
    " Min length: LL (2) + AAAA (4) + TT (2) + CC (2) = 10 chars
    if len(l:content) < 10
        return 0
    endif

    " Check if the length is even (hex pairs)
    if len(l:content) % 2 != 0
        return 0
    endif

    " The data to sum is everything excluding the last byte (2 chars) which is the old checksum
    let l:data_hex = l:content[:-3]

    let l:sum = 0
    let l:i = 0
    while l:i < len(l:data_hex)
        let l:byte_hex = strpart(l:data_hex, l:i, 2)
        let l:sum += str2nr(l:byte_hex, 16)
        let l:i += 2
    endwhile

    let l:checksum = (0x100 - (l:sum % 0x100)) % 0x100
    let l:new_checksum_hex = printf('%02X', l:checksum)

    " Reconstruct the line: Original indentation + : + data + new checksum
    let l:indent = matchstr(l:line, '^\s*')
    let l:new_line = l:indent . ':' . l:data_hex . l:new_checksum_hex

    if l:new_line !=# l:line
        call setline(a:lnum, l:new_line)
        return 1
    endif
    return 0
endfunction

function! rookie_hex#UpdateIntelHexChecksum(...) abort
    let l:start_line = 1
    let l:end_line = line('$')

    let l:count = 0
    for l:lnum in range(l:start_line, l:end_line)
        let l:count += s:UpdateLineChecksum(l:lnum)
    endfor

    if l:count > 0
        echo "Updated checksum for " . l:count . " line(s)."
    else
        echo "No checksums updated."
    endif
endfunction
