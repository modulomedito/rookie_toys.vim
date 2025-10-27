scriptencoding utf-8

let g:rookie_toys_clangd_source_patterns = ['c', 'cpp']
let g:rookie_toys_clangd_header_patterns = ['h', 'hpp']
let g:rookie_toys_clangd_compiler = 'gcc'
let g:rookie_toys_clangd_args = ['-ferror-limit=3000']

function! s:SearchAndCollect(dir, patterns) abort
    let result = []

    " Ensure the directory path ends with a slash
    let dir_with_slash = substitute(a:dir, '\\', '/', 'g')
    if dir_with_slash !~ '/$'
        let dir_with_slash = dir_with_slash . '/'
    endif

    " Get all files recursively using globpath with the '**' wildcard
    let files = globpath(a:dir, '**', 0, 1)
    for file in files
        " Skip directories – process only files
        if !isdirectory(file)
            for pattern in a:patterns
                if file =~ pattern
                    let file_with_slash = substitute(file, '\\', '/', 'g')
                    let result += [file_with_slash]
                endif
            endfor
        endif
    endfor

    return result
endfunction

function! s:RemoveDuplicates(items) abort
    let seen = {}
    let result = []
    for item in a:items
        if !has_key(seen, item)
            let seen[item] = v:true
            let result += [item]
        endif
    endfor
    return result
endfunction

function! s:SearchAndCollectParent(dir, patterns) abort
    let raw_result = []
    let match_files = s:SearchAndCollect(a:dir, a:patterns)

    for match_file in match_files
        let parent = fnamemodify(match_file, ':h')
        let parent = substitute(parent, '\\', '/', 'g')
        let raw_result += [parent]
    endfor

    return s:RemoveDuplicates(raw_result)
endfunction

function! rookie_clangd#CreateCompileCommandsJson() abort
    let current_dir = substitute(getcwd(), '\\', '/', 'g')

    " Search header parent folders
    let header_patterns = []
    for pattern in g:rookie_toys_clangd_header_patterns
        let header_patterns += ['^.*\.' . pattern . '$']
    endfor
    let header_dirs = s:SearchAndCollectParent(current_dir, header_patterns)

    " Search source files
    let source_patterns = []
    for pattern in g:rookie_toys_clangd_source_patterns
        let source_patterns += ['^.*\.' . pattern . '$']
    endfor
    let sources = s:SearchAndCollect(current_dir, source_patterns)

    " First line output content
    let output_content = []
    call add(output_content, '[')

    " Setup compile command
    let compile_cmd = '    "command": "\"' . g:rookie_toys_clangd_compiler . '\" '

    " Append arguments
    for arg in g:rookie_toys_clangd_args
        let compile_cmd = compile_cmd . '\"' . arg . '\" '
    endfor

    " Append includes
    for header_dir in header_dirs
        let compile_cmd = compile_cmd . '\"-I' . header_dir . '\" '
    endfor

    " Body of the output content
    for src_file in sources
        call add(output_content, '  {')
        call add(output_content, '    "directory": "' . current_dir . '",')
        call add(output_content, compile_cmd . src_file . '",')
        call add(output_content, '    "file": "' . src_file . '",')
        call add(output_content, '    "output": "' . src_file . '.o"')
        if src_file == sources[len(sources)-1]
            call add(output_content, '  }')
        else
            call add(output_content, '  },')
        endif
    endfor

    " Last line output content
    call add(output_content, ']')

    call writefile(output_content, 'compile_commands.json')
    echo 'Created compile_commands.json'
endfunction
