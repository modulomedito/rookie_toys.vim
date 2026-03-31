vim9script
# scriptencoding utf-8

# Convert hex data to ASCII string and copy to clipboard
export def HexToAscii(is_visual: any = 0)
    var hex_data = ''

    if is_visual
        var text = GetVisualSelection()
        # Check if it looks like Intel Hex (contains lines starting with :)
        if text =~# '^\s*:' || text =~# '\n\s*:'
             hex_data = ParseIntelHexBlock(text)
        else
             hex_data = CleanHex(text)
        endif
    else
        # Normal mode: Current line
        var line = getline('.')
        # Requirement says "current intel hex line".
        if line =~# '^\s*:'
            hex_data = ParseIntelHexLine(substitute(line, '^\s*', '', ''), false)
        else
            echohl ErrorMsg
            echomsg "Current line is not a valid Intel HEX record (must start with ':')"
            echohl None
            return
        endif
    endif

    if hex_data ==# ''
        echomsg "No valid hex data found."
        return
    endif

    # Convert hex_data (raw hex string) to ASCII
    var result = HexToAsciiString(hex_data)

    # Echo result
    echo "Decoded: " .. result

    # Copy to clipboard
    @\" = result
    if has('clipboard')
        @+ = result
        echon " (Copied to clipboard)"
    else
        echon " (Copied to register \")"
    endif
enddef

def GetVisualSelection(): string
    var [line_start, column_start] = getpos("'<")[1 : 2]
    var [line_end, column_end] = getpos("'>")[1 : 2]
    var lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif

    var selection_mode = visualmode()
    if selection_mode ==# 'v'
        # Character-wise
        lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
        lines[0] = lines[0][column_start - 1 :]
    elseif selection_mode ==# 'V'
        # Line-wise: lines are already correct
    elseif selection_mode ==# "\<C-V>"
        # Block-wise
        for i in range(len(lines))
            lines[i] = lines[i][column_start - 1 : column_end - (&selection == 'inclusive' ? 1 : 2)]
        endfor
    endif
    return join(lines, "\n")
enddef

def ParseIntelHexBlock(text: string): string
    var lines = split(text, "\n")
    var raw_hex = ''
    for line in lines
        var clean_line = substitute(line, '^\s*', '', '')
        if clean_line =~# '^:'
            raw_hex ..= ParseIntelHexLine(clean_line, true)
        endif
    endfor
    return raw_hex
enddef

def ParseIntelHexLine(line: string, silent: bool): string
    if len(line) < 1 || line[0] !=# ':'
        if !silent
            echohl ErrorMsg
            echomsg "Current line is not a valid Intel HEX record (must start with ':')"
            echohl None
        endif
        return ''
    endif

    # Parse Byte Count (chars 1-2)
    var byte_count_hex = strpart(line, 1, 2)
    var byte_count = str2nr(byte_count_hex, 16)

    # Parse Record Type (chars 7-8)
    var record_type = strpart(line, 7, 2)

    # Check if it is a Data Record (00)
    if record_type !=# '00'
        if !silent
            echomsg "Record type is " .. record_type .. " (not Data), skipping ASCII conversion."
        endif
        return ''
    endif

    # Extract Data (starts at index 9, length is byte_count * 2)
    return strpart(line, 9, byte_count * 2)
enddef

def CleanHex(text: string): string
    return substitute(text, '[^0-9A-Fa-f]', '', 'g')
enddef

def HexToAsciiString(hex: string): string
    var res = ''
    var i = 0
    while i < len(hex)
        var byte_hex = strpart(hex, i, 2)
        if len(byte_hex) < 2
            break
        endif
        var char_code = str2nr(byte_hex, 16)
        res ..= nr2char(char_code)
        i += 2
    endwhile
    return res
enddef

def UpdateLineChecksum(lnum: number): bool
    var line = getline(lnum)
    # Remove whitespace
    var clean_line = substitute(line, '^\s*', '', '')
    clean_line = substitute(clean_line, '\s*$', '', '')

    if clean_line !~# '^:'
        return false
    endif

    var content = clean_line[1 :]
    # Min length: LL (2) + AAAA (4) + TT (2) + CC (2) = 10 chars
    if len(content) < 10
        return false
    endif

    # Check if the length is even (hex pairs)
    if len(content) % 2 != 0
        return false
    endif

    # The data to sum is everything excluding the last byte (2 chars) which is the old checksum
    var data_hex = content[:-3]

    var sum = 0
    var i = 0
    while i < len(data_hex)
        var byte_hex = strpart(data_hex, i, 2)
        sum += str2nr(byte_hex, 16)
        i += 2
    endwhile

    var checksum = (0x100 - (sum % 0x100)) % 0x100
    var new_checksum_hex = printf('%02X', checksum)

    # Reconstruct the line: Original indentation + : + data + new checksum
    var indent = matchstr(line, '^\s*')
    var new_line = indent .. ':' .. data_hex .. new_checksum_hex

    if new_line !=# line
        setline(lnum, new_line)
        return true
    endif
    return false
enddef

export def UpdateIntelHexChecksum()
    var start_line = 1
    var end_line = line('$')

    var count = 0
    for lnum in range(start_line, end_line)
        if UpdateLineChecksum(lnum)
            count += 1
        endif
    endfor

    if count > 0
        echo "Updated checksum for " .. count .. " line(s)."
    else
        echo "No checksums updated."
    endif
enddef
