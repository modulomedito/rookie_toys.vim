vim9script

# Default configuration
if !exists('g:rookie_toys_clangd_source_patterns')
    g:rookie_toys_clangd_source_patterns = ['c', 'cpp']
endif
if !exists('g:rookie_toys_clangd_header_patterns')
    g:rookie_toys_clangd_header_patterns = ['h', 'hpp']
endif
if !exists('g:rookie_toys_clangd_compiler')
    g:rookie_toys_clangd_compiler = 'gcc'
endif
if !exists('g:rookie_toys_clangd_args')
    g:rookie_toys_clangd_args = ['-ferror-limit=3000']
endif

# Search and collect files matching patterns recursively
def SearchAndCollect(dir: string, patterns: list<string>): list<string>
    var result: list<string> = []

    # Ensure the directory path ends with a slash
    var dir_with_slash = substitute(dir, '\\', '/', 'g')
    if dir_with_slash !~ '/$'
        dir_with_slash ..= '/'
    endif

    # Get all files recursively using globpath with the '**' wildcard
    var files = globpath(dir, '**', 0, 1)
    for file in files
        # Skip directories – process only files
        if !isdirectory(file)
            for pattern in patterns
                if file =~ pattern
                    var file_with_slash = substitute(file, '\\', '/', 'g')
                    add(result, file_with_slash)
                endif
            endfor
        endif
    endfor

    return result
enddef

# Remove duplicates from a list
def RemoveDuplicates(items: list<string>): list<string>
    var seen = {}
    var result: list<string> = []
    for item in items
        if !has_key(seen, item)
            seen[item] = true
            add(result, item)
        endif
    endfor
    return result
enddef

# Search and collect parent folders of matching files
def SearchAndCollectParent(dir: string, patterns: list<string>): list<string>
    var raw_result: list<string> = []
    var match_files = SearchAndCollect(dir, patterns)

    for match_file in match_files
        var parent = fnamemodify(match_file, ':h')
        parent = substitute(parent, '\\', '/', 'g')
        add(raw_result, parent)
    endfor

    return RemoveDuplicates(raw_result)
enddef

# Main function to create compile_commands.json
export def CreateCompileCommandsJson()
    var current_dir = substitute(getcwd(), '\\', '/', 'g')

    # Search header parent folders
    var header_patterns: list<string> = []
    for pattern in g:rookie_toys_clangd_header_patterns
        add(header_patterns, '^.*\.' .. pattern .. '$')
    endfor
    var header_dirs = SearchAndCollectParent(current_dir, header_patterns)

    # Search source files
    var source_patterns: list<string> = []
    for pattern in g:rookie_toys_clangd_source_patterns
        add(source_patterns, '^.*\.' .. pattern .. '$')
    endfor
    var sources = SearchAndCollect(current_dir, source_patterns)

    # First line output content
    var output_content: list<string> = []
    add(output_content, '[')

    # Setup compile command
    var compile_cmd = '    "command": "\"' .. g:rookie_toys_clangd_compiler .. '\" '

    # Append arguments
    for arg in g:rookie_toys_clangd_args
        compile_cmd ..= '\"' .. arg .. '\" '
    endfor

    # Append includes
    for header_dir in header_dirs
        compile_cmd ..= '\"-I' .. header_dir .. '\" '
    endfor

    # Body of the output content
    var num_sources = len(sources)
    for i in range(num_sources)
        var src_file = sources[i]
        add(output_content, '  {')
        add(output_content, '    "directory": "' .. current_dir .. '",')
        add(output_content, compile_cmd .. src_file .. '",')
        add(output_content, '    "file": "' .. src_file .. '",')
        add(output_content, '    "output": "' .. src_file .. '.o"')
        if i == num_sources - 1
            add(output_content, '  }')
        else
            add(output_content, '  },')
        endif
    endfor

    # Last line output content
    add(output_content, ']')

    writefile(output_content, 'compile_commands.json')
    echo 'Created compile_commands.json'
enddef
