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

def GetTableNormal(poly: number, bits: number): list<number>
    var key = printf("%d_%x", bits, poly)
    if has_key(tables_normal, key)
        return tables_normal[key]
    endif
    var table = []
    var mask = bits == 32 ? 0x80000000 : 0x8000
    var full_mask = bits == 32 ? 0xFFFFFFFF : 0xFFFF
    for i in range(256)
        var crc = i << (bits - 8)
        for _ in range(8)
            if and(crc, mask) != 0
                crc = xor(crc << 1, poly)
            else
                crc = crc << 1
            endif
            crc = and(crc, full_mask)
        endfor
        add(table, crc)
    endfor
    tables_normal[key] = table
    return table
enddef

def GetTableReflected(poly: number, bits: number): list<number>
    var key = printf("%d_%x", bits, poly)
    if has_key(tables_reflected, key)
        return tables_reflected[key]
    endif
    var ref_poly = Reflect(poly, bits)
    var table = []
    var full_mask = bits == 32 ? 0xFFFFFFFF : 0xFFFF
    for i in range(256)
        var crc = i
        for _ in range(8)
            if and(crc, 1) != 0
                crc = xor(crc >> 1, ref_poly)
            else
                crc = crc >> 1
            endif
            crc = and(crc, full_mask)
        endfor
        add(table, crc)
    endfor
    tables_reflected[key] = table
    return table
enddef

export def ComputeCrc(data: blob, bits: number, poly: number, init: number, ref_in: bool, ref_out: bool, xor_out: number): number
    var crc = init
    var full_mask = bits == 32 ? 0xFFFFFFFF : 0xFFFF
    if !ref_in
        var table = GetTableNormal(poly, bits)
        for i in range(len(data))
            var byte = data[i]
            crc = xor(crc << 8, table[and(xor(crc >> (bits - 8), byte), 0xFF)])
            crc = and(crc, full_mask)
        endfor
    else
        var table = GetTableReflected(poly, bits)
        for i in range(len(data))
            var byte = data[i]
            crc = xor(crc >> 8, table[and(xor(crc, byte), 0xFF)])
            crc = and(crc, full_mask)
        endfor
    endif
    if ref_in != ref_out
        crc = Reflect(crc, bits)
    endif
    return and(xor(crc, xor_out), full_mask)
enddef

export def ComputeCrc32(data: blob, poly: number, init: number, ref_in: bool, ref_out: bool, xor_out: number): number
    return ComputeCrc(data, 32, poly, init, ref_in, ref_out, xor_out)
enddef

export def ComputeCrc16(data: blob, poly: number, init: number, ref_in: bool, ref_out: bool, xor_out: number): number
    return ComputeCrc(data, 16, poly, init, ref_in, ref_out, xor_out)
enddef

const crc16_algorithms = [
    { name: 'CRC-16/ARC',               check: '0xBB3D', poly: 0x8005, init: 0x0000, refin: true,  refout: true,  xorout: 0x0000 },
    { name: 'CRC-16/CDMA2000',          check: '0x4C06', poly: 0xC867, init: 0xFFFF, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/CMS',               check: '0xAEE7', poly: 0x8005, init: 0xFFFF, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/DDS-110',           check: '0x9ECF', poly: 0x8005, init: 0x800D, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/DECT-R',            check: '0x007E', poly: 0x0589, init: 0x0000, refin: false, refout: false, xorout: 0x0001 },
    { name: 'CRC-16/DECT-X',            check: '0x007F', poly: 0x0589, init: 0x0000, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/DNP',               check: '0xEA82', poly: 0x3D65, init: 0x0000, refin: true,  refout: true,  xorout: 0xFFFF },
    { name: 'CRC-16/EN-13757',          check: '0xC2B7', poly: 0x3D65, init: 0x0000, refin: false, refout: false, xorout: 0xFFFF },
    { name: 'CRC-16/GENIBUS',           check: '0xD64E', poly: 0x1021, init: 0xFFFF, refin: false, refout: false, xorout: 0xFFFF },
    { name: 'CRC-16/GSM',               check: '0xCE3C', poly: 0x1021, init: 0x0000, refin: false, refout: false, xorout: 0xFFFF },
    { name: 'CRC-16/IBM-3740',          check: '0x29B1', poly: 0x1021, init: 0xFFFF, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/IBM-SDLC',          check: '0x906E', poly: 0x1021, init: 0xFFFF, refin: true,  refout: true,  xorout: 0xFFFF },
    { name: 'CRC-16/ISO-IEC-14443-3-A', check: '0xBF05', poly: 0x1021, init: 0xC6C6, refin: true,  refout: true,  xorout: 0x0000 },
    { name: 'CRC-16/KERMIT',            check: '0x2189', poly: 0x1021, init: 0x0000, refin: true,  refout: true,  xorout: 0x0000 },
    { name: 'CRC-16/LJ1200',            check: '0xBDF4', poly: 0x6F63, init: 0x0000, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/M17',               check: '0x772B', poly: 0x5935, init: 0xFFFF, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/MAXIM-DOW',         check: '0x44C2', poly: 0x8005, init: 0x0000, refin: true,  refout: true,  xorout: 0xFFFF },
    { name: 'CRC-16/MCRF4XX',           check: '0x6F91', poly: 0x1021, init: 0xFFFF, refin: true,  refout: true,  xorout: 0x0000 },
    { name: 'CRC-16/MODBUS',            check: '0x4B37', poly: 0x8005, init: 0xFFFF, refin: true,  refout: true,  xorout: 0x0000 },
    { name: 'CRC-16/NRSC-5',            check: '0xA066', poly: 0x080B, init: 0xFFFF, refin: true,  refout: true,  xorout: 0x0000 },
    { name: 'CRC-16/OPENSAFETY-A',      check: '0x5D38', poly: 0x5935, init: 0x0000, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/OPENSAFETY-B',      check: '0x20FE', poly: 0x755B, init: 0x0000, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/PROFIBUS',          check: '0xA819', poly: 0x1DCF, init: 0xFFFF, refin: false, refout: false, xorout: 0xFFFF },
    { name: 'CRC-16/RIELLO',            check: '0x63D0', poly: 0x1021, init: 0xB2AA, refin: true,  refout: true,  xorout: 0x0000 },
    { name: 'CRC-16/SPI-FUJITSU',       check: '0xE5CC', poly: 0x1021, init: 0x1D0F, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/T10-DIF',           check: '0xD0DB', poly: 0x8BB7, init: 0x0000, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/TELEDISK',          check: '0x0FB3', poly: 0xA097, init: 0x0000, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/TMS37157',          check: '0x26B1', poly: 0x1021, init: 0x89EC, refin: true,  refout: true,  xorout: 0x0000 },
    { name: 'CRC-16/UMTS',              check: '0xFEE8', poly: 0x8005, init: 0x0000, refin: false, refout: false, xorout: 0x0000 },
    { name: 'CRC-16/USB',               check: '0xB4C8', poly: 0x8005, init: 0xFFFF, refin: true,  refout: true,  xorout: 0xFFFF },
    { name: 'CRC-16/XMODEM',            check: '0x31C3', poly: 0x1021, init: 0x0000, refin: false, refout: false, xorout: 0x0000 },
]

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

def UpdateOutputBuffer(lines: list<string>)
    var bufname = '__Rookie_CRC__'
    var winid = bufwinid(bufname)
    if winid != -1
        win_gotoid(winid)
        setlocal modifiable
        silent :%delete _
    else
        execute 'belowright :35split ' .. bufname
    endif
    setline(1, lines)
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal filetype=csv
    setlocal nomodifiable
enddef

export def ShowCrc32(data: blob)
    var lines = []
    add(lines, printf("%-17s, %-10s, %-10s, %-10s, %-10s, %-5s, %-6s, %s,", "CRC-32", "Result", "Check", "Poly", "Init", "RefIn", "RefOut", "XorOut"))

    for alg in crc32_algorithms
        var res = ComputeCrc32(data, alg.poly, alg.init, alg.refin, alg.refout, alg.xorout)
        var result_str = printf("0x%08X", res)
        add(lines, printf("%-17s, %-10s, %-10s, %-10s, %-10s, %-5s, %-6s, %s,", alg.name, result_str, alg.check, printf("0x%08X", alg.poly), printf("0x%08X", alg.init), alg.refin ? "true" : "false", alg.refout ? "true" : "false", printf("0x%08X", alg.xorout)))
    endfor

    UpdateOutputBuffer(lines)
enddef

export def ShowCrc16(data: blob)
    var lines = []
    add(lines, printf("%-25s, %-10s, %-10s, %-10s, %-10s, %-5s, %-6s, %s,", "CRC-16", "Result", "Check", "Poly", "Init", "RefIn", "RefOut", "XorOut"))

    for alg in crc16_algorithms
        var res = ComputeCrc16(data, alg.poly, alg.init, alg.refin, alg.refout, alg.xorout)
        var result_str = printf("0x%04X", res)
        add(lines, printf("%-25s, %-10s, %-10s, %-10s, %-10s, %-5s, %-6s, %s,", alg.name, result_str, alg.check, printf("0x%04X", alg.poly), printf("0x%04X", alg.init), alg.refin ? "true" : "false", alg.refout ? "true" : "false", printf("0x%04X", alg.xorout)))
    endfor

    UpdateOutputBuffer(lines)
enddef

export def Crc16Hex()
    var line_start: number
    var line_end: number

    if mode() == 'v' || mode() == 'V' || mode() == "\<C-V>"
        line_start = line("'<")
        line_end = line("'>")
    else
        line_start = 1
        line_end = line('$')
    endif

    try
        var lines = getline(line_start, line_end)
        if empty(lines) | return | endif

        var data = 0z
        for line in lines
            var clean_line = substitute(line, '[^0-9a-fA-F]', '', 'g')
            if !empty(clean_line)
                if len(clean_line) % 2 != 0 | clean_line ..= '0' | endif
                data += eval('0z' .. clean_line)
            endif
        endfor

        ShowCrc16(data)
    catch
        echoerr "RookieCrc16Hex Error: " .. v:exception
    endtry
enddef

export def Crc16Ascii()
    var line_start: number
    var line_end: number

    if mode() == 'v' || mode() == 'V' || mode() == "\<C-V>"
        line_start = line("'<")
        line_end = line("'>")
    else
        line_start = 1
        line_end = line('$')
    endif

    try
        var temp = tempname()
        var lines = getline(line_start, line_end)
        writefile(lines, temp, 'b')

        var data = readfile(temp, 'B')
        delete(temp)

        ShowCrc16(data)
    catch
        echoerr "RookieCrc16Ascii Error: " .. v:exception
    endtry
enddef

export def Crc32Hex()
    var line_start: number
    var line_end: number

    if mode() == 'v' || mode() == 'V' || mode() == "\<C-V>"
        line_start = line("'<")
        line_end = line("'>")
    else
        line_start = 1
        line_end = line('$')
    endif

    try
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
    catch
        echoerr "RookieCrc32Hex Error: " .. v:exception
    endtry
enddef

export def Crc32Ascii()
    var line_start: number
    var line_end: number

    if mode() == 'v' || mode() == 'V' || mode() == "\<C-V>"
        line_start = line("'<")
        line_end = line("'>")
    else
        line_start = 1
        line_end = line('$')
    endif

    try
        # Use temporary file to read as blob for speed
        var temp = tempname()
        var lines = getline(line_start, line_end)
        writefile(lines, temp, 'b') # Write with newlines

        var data = readfile(temp, 'B')
        delete(temp)

        ShowCrc32(data)
    catch
        echoerr "RookieCrc32Ascii Error: " .. v:exception
    endtry
enddef
