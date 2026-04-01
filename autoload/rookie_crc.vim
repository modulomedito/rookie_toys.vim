vim9script

export def Reflect(val: number, bits: number): number
    var res = 0
    var v = val
    for i in range(bits)
        res = or(res << 1, and(v, 1))
        v = v >> 1
    endfor
    return res
enddef

var tables_normal = {}
var tables_reflected = {}

def GetTableNormal(poly: number): list<number>
    if has_key(tables_normal, poly)
        return tables_normal[poly]
    endif
    var table = []
    for i in range(256)
        var crc = i << 24
        for _ in range(8)
            if and(crc, 0x80000000) != 0
                crc = xor(crc << 1, poly)
            else
                crc = crc << 1
            endif
            crc = and(crc, 0xFFFFFFFF)
        endfor
        add(table, crc)
    endfor
    tables_normal[poly] = table
    return table
enddef

def GetTableReflected(poly: number): list<number>
    if has_key(tables_reflected, poly)
        return tables_reflected[poly]
    endif
    var ref_poly = Reflect(poly, 32)
    # The Reflect(poly, 32) above is actually reflecting all 32 bits.
    # For standard CRC, reflecting the poly means bit-reversing it.
    # Let's double check the reflected poly for 0x04C11DB7.
    # 0x04C11DB7 -> 0xEDB88320.
    # My Reflect(0x04C11DB7, 32) will give 0xEDB88320. Correct.
    var table = []
    for i in range(256)
        var crc = i
        for _ in range(8)
            if and(crc, 1) != 0
                crc = xor(crc >> 1, ref_poly)
            else
                crc = crc >> 1
            endif
            crc = and(crc, 0xFFFFFFFF)
        endfor
        add(table, crc)
    endfor
    tables_reflected[poly] = table
    return table
enddef

export def ComputeCrc32(data: blob, poly: number, init: number, ref_in: bool, ref_out: bool, xor_out: number): number
    var crc = init
    if !ref_in
        var table = GetTableNormal(poly)
        for i in range(len(data))
            var byte = data[i]
            crc = xor(crc << 8, table[and(xor(crc >> 24, byte), 0xFF)])
            crc = and(crc, 0xFFFFFFFF)
        endfor
    else
        var table = GetTableReflected(poly)
        for i in range(len(data))
            var byte = data[i]
            crc = xor(crc >> 8, table[and(xor(crc, byte), 0xFF)])
            crc = and(crc, 0xFFFFFFFF)
        endfor
    endif
    # ref_out is handled by the table logic if ref_in == ref_out.
    # For all our algorithms, ref_in == ref_out.
    # If not, we'd need additional reflection at the end.
    if ref_in != ref_out
        crc = Reflect(crc, 32)
    endif
    return and(xor(crc, xor_out), 0xFFFFFFFF)
enddef

const crc32_algorithms = [
    { name: 'CRC-32/AIXM',       check: '0x3010BF7F', poly: 0x814141AB, init: 0x00000000, refin: false, refout: false, xorout: 0x00000000 },
    { name: 'CRC-32/AUTOSAR',    check: '0x1697D06A', poly: 0xF4ACFB13, init: 0xFFFFFFFF, refin: true,  refout: true,  xorout: 0xFFFFFFFF },
    { name: 'CRC-32/BASE91-D',   check: '0x87315576', poly: 0xA833982B, init: 0xFFFFFFFF, refin: true,  refout: true,  xorout: 0xFFFFFFFF },
    { name: 'CRC-32/BZIP2',      check: '0xFC891918', poly: 0x04C11DB7, init: 0xFFFFFFFF, refin: false, refout: false, xorout: 0xFFFFFFFF },
    { name: 'CRC-32/CD-ROM-EDC', check: '0x6EC2EDC4', poly: 0x8001801B, init: 0x00000000, refin: true,  refout: true,  xorout: 0x00000000 },
    { name: 'CRC-32/CKSUM',      check: '0x765E7680', poly: 0x04C11DB7, init: 0x00000000, refin: false, refout: false, xorout: 0xFFFFFFFF },
    { name: 'CRC-32/ISCSI',      check: '0xE3069283', poly: 0x1EDC6F41, init: 0xFFFFFFFF, refin: true,  refout: true,  xorout: 0xFFFFFFFF },
    { name: 'CRC-32/ISO-HDLC',   check: '0xCBF43926', poly: 0x04C11DB7, init: 0xFFFFFFFF, refin: true,  refout: true,  xorout: 0xFFFFFFFF },
    { name: 'CRC-32/JAMCRC',     check: '0x340BC6D9', poly: 0x04C11DB7, init: 0xFFFFFFFF, refin: true,  refout: true,  xorout: 0x00000000 },
    { name: 'CRC-32/MEF',        check: '0xD2C22F51', poly: 0x741B8CD7, init: 0xFFFFFFFF, refin: true,  refout: true,  xorout: 0x00000000 },
    { name: 'CRC-32/MPEG-2',     check: '0x0376E6E7', poly: 0x04C11DB7, init: 0xFFFFFFFF, refin: false, refout: false, xorout: 0x00000000 },
    { name: 'CRC-32/XFER',       check: '0xBD0BE338', poly: 0x000000AF, init: 0x00000000, refin: false, refout: false, xorout: 0x00000000 },
]

export def ShowCrc32(data: blob)
    var lines = []
    add(lines, printf("%-17s, %-10s, %-10s, %-10s, %-10s, %-5s, %-6s, %s,", "CRC-32", "Result", "Check", "Poly", "Init", "RefIn", "RefOut", "XorOut"))

    for alg in crc32_algorithms
        var res = ComputeCrc32(data, alg.poly, alg.init, alg.refin, alg.refout, alg.xorout)
        var result_str = printf("0x%08X", res)
        add(lines, printf("%-17s, %-10s, %-10s, %-10s, %-10s, %-5s, %-6s, %s,", alg.name, result_str, alg.check, printf("0x%08X", alg.poly), printf("0x%08X", alg.init), alg.refin ? "true" : "false", alg.refout ? "true" : "false", printf("0x%08X", alg.xorout)))
    endfor

    execute 'belowright split'
    execute 'enew'
    setline(1, lines)
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal filetype=csv
enddef

export def Crc32Hex()
    var line_start = line("'<")
    var line_end = line("'>")
    var lines = getline(line_start, line_end)
    if empty(lines) | return | endif

    # Process line by line to avoid huge string manipulation
    var data = 0z
    for line in lines
        var clean_line = substitute(line, '[^0-9a-fA-F]', '', 'g')
        if !empty(clean_line)
            if len(clean_line) % 2 != 0 | clean_line ..= '0' | endif
            data += eval('0z' .. clean_line)
        endif
    endfor

    ShowCrc32(data)
enddef

export def Crc32Ascii()
    var line_start = line("'<")
    var line_end = line("'>")

    # Use temporary file to read as blob for speed
    var temp = tempname()
    var lines = getline(line_start, line_end)
    writefile(lines, temp, 'b') # Write with newlines

    var data = readfile(temp, 'B')
    delete(temp)

    ShowCrc32(data)
enddef
