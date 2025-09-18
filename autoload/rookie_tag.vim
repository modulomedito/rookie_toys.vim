vim9script

export def UpdateTags()
    var line = getline('.')
    var current_tags = []
    for word in split(line)
        if word =~ '#\w\+'
            var tag = substitute(word, '#', '', '')
            if tag != ''
                call add(current_tags, tag)
            endif
        endif
    endfor
    var user_input = input("Enter tags (space separated): ")
    var input_tags = []
    if user_input != ''
        input_tags = split(user_input, ' \s*')
    else
        return
    endif
    var all_tags = current_tags + input_tags
    var uniq_tags = []
    for t in all_tags
        if index(uniq_tags, t) < 0
            call add(uniq_tags, t)
        endif
    endfor
    call sort(uniq_tags)
    var result = join(map(uniq_tags, '"#" .. v:val'), ' ')
    call setline('.', result)
enddef

export def SearchTags()
    var tags = input('Enter tags (space separated): ')
    if empty(tags)
        echomsg 'No tags entered.'
        return
    endif
    var taglist = split(tags, ' ')
    call sort(taglist)
    var sorted_tags = join(taglist, ' ')
    echomsg 'Sorted tags: ' .. sorted_tags
    var qf = []
    for lnum in range(1, line('$'))
        var line = getline(lnum)
        if line !~ ' #\w\+'
            continue
        endif
        var found = 1
        for tag in taglist
            if line !~ '\(#' .. tag .. '\)'
                found = 0
                break
            endif
        endfor
        if found
            add(qf, {'filename': expand('%'), 'lnum': lnum, 'col': 1, 'text': line})
        endif
    endfor
    if !empty(qf)
        if len(qf) == 1
            var single = qf[0]
            call cursor(single.lnum, 1)
        else
            call setqflist(qf, 'r')
            echomsg 'Results sent to quickfix. Opening quickfix window...'
            copen
        endif
    else
        echomsg 'No matching lines found.'
    endif
enddef

export def SearchGlobalTags()
    var tags = input('Enter global search tags (space separated): ')
    if empty(tags)
        echomsg 'No tags entered.'
        return
    endif
    var taglist = split(tags, ' ')
    call sort(taglist)
    var sorted_tags = '\#' .. join(taglist, '.*\#')
    echomsg 'Sorted tags: ' .. sorted_tags
    if has('unix')
        execute("silent! grep '" .. sorted_tags .. "' .")
    else
        execute("silent! grep " .. sorted_tags .. " .")
    endif
    var qf = getqflist()
    if !empty(qf)
        if len(qf) == 1
            var single = qf[0]
            call cursor(single.lnum, 1)
        else
            execute("copen")
            execute("redraw!")
            echomsg 'Results sent to quickfix. Opening quickfix window...'
        endif
    else
        echomsg 'No matching lines found.'
    endif
enddef

export def AddFileNameTags()
    var input_tags = input('Enter file name tags (space separated): ')
    if empty(input_tags)
        echomsg 'No tags entered.'
        return
    endif
    var tags_list = split(input_tags, ' ')
    var cur_file_name = expand('%:t:r')
    var cur_file_path = expand('%:p:h')
    var cur_file_ext = expand('%:e')
    var cur_file_tags = split(cur_file_name, '-')
    var all_tags = cur_file_tags + tags_list
    var uniq_tags = []
    for t in all_tags
        if index(uniq_tags, t) < 0
            call add(uniq_tags, t)
        endif
    endfor
    call sort(uniq_tags)
    var sorted_tags = join(uniq_tags, '-')
    execute('Rename ' ..
        sorted_tags ..
        '.' ..
        cur_file_ext)
enddef

def SearchFilesWithTags(tags: list<string>)
    var cwd = getcwd()
    var matching_files = []
    var files = globpath(cwd, '**/*', 0, 1)
    call filter(files, 'filereadable(v:val)')
    for file in files
        if empty(file)
            continue
        endif
        var filename = fnamemodify(file, ':t')
        var all_tags_match = 1
        for tag in tags
            if filename !~? tag
                all_tags_match = 0
                break
            endif
        endfor
        if all_tags_match
            call add(matching_files, file)
        endif
    endfor
    if len(matching_files) == 0
        echo "\nNo files found containing all tags: [" .. join(tags, ', ') .. "]"
    elseif len(matching_files) == 1
        execute 'edit ' .. fnameescape(matching_files[0])
    else
        var qf_list = []
        for file in matching_files
            call add(qf_list, {
                \ 'filename': file,
                \ 'text': 'File containing all tags: ' .. join(tags, ', ')
                \ })
        endfor
        call setqflist(qf_list)
        copen
    endif
enddef

export def SearchFileNameTags()
    var input_tags = input('Search file name tags (space separated): ')
    if empty(input_tags)
        echomsg 'No tags entered.'
        return
    endif
    var tags_list = split(input_tags, ' ')
    call SearchFilesWithTags(tags_list)
enddef

export def ToggleHeaderSource()
    var filename = expand('%:t:r')
    var extension = expand('%:e')
    var pattern = '**/' .. filename .. '.h'
    if extension == 'h'
        pattern = '**/' .. filename .. '.c'
    endif
    var matches = glob(pattern, 0, 1)
    if empty(matches)
        echomsg 'Corresponding header/source not exists'
        return
    endif
    execute('edit ' .. fnameescape(matches[0]))
enddef