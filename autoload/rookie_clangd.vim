vim9script

g:rookie_toys_clangd_source_patterns = ['c', 'cpp']
g:rookie_toys_clangd_header_patterns = ['h', 'hpp']
g:rookie_toys_clangd_compiler = 'gcc'
g:rookie_toys_clangd_args = ['-ferror-limit=3000']

def SearchAndCollect(dir: string, patterns: list<string>): list<string>
    var result = []

    # Ensure the directory path ends with a slash
    var dir_with_slash = dir
    dir_with_slash = substitute(dir_with_slash, '\\', '/', 'g')
    if dir_with_slash[-1] != '/'
        dir_with_slash = dir_with_slash .. '/'
    endif

    # Get all files recursively using globpath with the '**' wildcard
    var files = globpath(dir, '**', 0, 1)
    for file in files
        # Skip directories – process only files
        if !isdirectory(file)
            for pattern in patterns
                if file =~ pattern
                    var file_with_slash = substitute(file, '\\', '/', 'g')
                    result += [file_with_slash]
                endif
            endfor
        endif
    endfor

    return result
enddef

def RemoveDuplicates(items: list<string>): list<string>
    var seen = {}
    var result: list<string> = []
        for item in items
            if !has_key(seen, item)
                seen[item] = v:true
                result += [item]
            endif
        endfor
    return result
enddef

def SearchAndCollectParent(dir: string, patterns: list<string>): list<string>
    var result = []
    var raw_result = []
    var match_files = SearchAndCollect(dir, patterns)

    for match_file in match_files
        var parent = fnamemodify(match_file, ':h')
        parent = substitute(parent, '\\', '/', 'g')
        raw_result += [parent]
    endfor

    result = RemoveDuplicates(raw_result)
    return result
enddef

export def CreateCompileCommandsJson()
    var current_dir = substitute(getcwd(), '\\', '/', 'g')

    # Search header parent folders
    var header_patterns = []
    for pattern in g:rookie_toys_clangd_header_patterns
        header_patterns += ['^.*\.' .. pattern .. '$']
    endfor
    var header_dirs = SearchAndCollectParent(current_dir, header_patterns)

    # Search source files
    var source_patterns = []
    for pattern in g:rookie_toys_clangd_source_patterns
        source_patterns += ['^.*\.' .. pattern .. '$']
    endfor
    var sources = SearchAndCollect(current_dir, source_patterns)

    # First line output content
    var output_content: list<string> = []
    output_content += ["["]

    # Setup compile command
    var compile_cmd = '    "command": "\"' .. g:rookie_toys_clangd_compiler .. '\" '

    # Append arguments
    for arg in g:rookie_toys_clangd_args
        compile_cmd = compile_cmd .. '\"' .. arg .. '\" '
    endfor

    # Append includes
    for header_dir in header_dirs
        compile_cmd = compile_cmd .. '\"-I' .. header_dir .. '\" '
    endfor

    # Body of the output content
    for src_file in sources
        output_content += ["  {"]
        output_content += ['    "directory": "' .. current_dir .. '",']
        output_content += [compile_cmd .. src_file .. '",']
        output_content += ['    "file": "' .. src_file .. '",']
        output_content += ['    "output": "' .. src_file .. '.o"']
        if src_file == sources[-1]
            output_content += ["  }"]
        else
            output_content += ["  },"]
        endif
    endfor

    # Last line output content
    output_content += ["]"]

    call writefile(output_content, "compile_commands.json")
    echo "Created compile_commands.json"
enddef
