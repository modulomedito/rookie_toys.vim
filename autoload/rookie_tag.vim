scriptencoding utf-8

function! rookie_tag#UpdateTags() abort
    let line = getline('.')
    let current_tags = []
    for word in split(line)
        if word =~ '#\w\+'
            let tag = substitute(word, '#', '', '')
            if tag != ''
                call add(current_tags, tag)
            endif
        endif
    endfor
    let user_input = input('Enter tags (space separated): ')
    let input_tags = []
    if user_input != ''
        let input_tags = split(user_input, ' \s*')
    else
        return
    endif
    let all_tags = current_tags + input_tags
    let uniq_tags = []
    for t in all_tags
        if index(uniq_tags, t) < 0
            call add(uniq_tags, t)
        endif
    endfor
    call sort(uniq_tags)
    let result = join(map(copy(uniq_tags), '"#" . v:val'), ' ')
    call setline('.', result)
endfunction

function! rookie_tag#SearchTags() abort
    let tags = input('Enter tags (space separated): ')
    if empty(tags)
        echomsg 'No tags entered.'
        return
    endif
    let taglist = split(tags, ' ')
    call sort(taglist)
    let sorted_tags = join(taglist, ' ')
    " echomsg 'Sorted tags: ' . sorted_tags
    let qf = []
    for lnum in range(1, line('$'))
        let line = getline(lnum)
        if line !~ ' #\w\+'
            continue
        endif
        let found = 1
        for tag in taglist
            if line !~ '\(#' . tag . '\)'
                let found = 0
                break
            endif
        endfor
        if found
            call add(qf, {'filename': expand('%'), 'lnum': lnum, 'col': 1, 'text': line})
        endif
    endfor
    if !empty(qf)
        if len(qf) == 1
            let single = qf[0]
            call cursor(single.lnum, 1)
        else
            call setqflist(qf, 'r')
            echomsg 'Results sent to quickfix. Opening quickfix window...'
            copen
        endif
    else
        echomsg 'No matching lines found.'
    endif
endfunction

function! rookie_tag#SearchGlobalTags() abort
    let tags = input('Enter global search tags (space separated): ')
    if empty(tags)
        echomsg 'No tags entered.'
        return
    endif
    let taglist = split(tags, ' ')
    call sort(taglist)
    let sorted_tags = '\#' . join(taglist, '.*\#')
    echomsg 'Sorted tags: ' . sorted_tags
    if has('unix')
        execute("silent! grep '" . sorted_tags . "' .")
    else
        execute('silent! grep ' . sorted_tags . ' .')
    endif
    let qf = getqflist()
    if !empty(qf)
        let seen = {}
        let merged = []
        for entry in qf
            let fname = get(entry, 'filename', '')
            if fname ==# '' && has_key(entry, 'bufnr') && entry.bufnr > 0
                let fname = bufname(entry.bufnr)
            endif
            let key = fname . ':' . entry.lnum
            if !has_key(seen, key)
                let seen[key] = 1
                call add(merged, entry)
            endif
        endfor

        if len(merged) == 1
            let single = merged[0]
            call cursor(single.lnum, 1)
        else
            call setqflist(merged, 'r')
            copen
            redraw!
            echomsg 'Results sent to quickfix (deduped rows).'
        endif
    else
        echomsg 'No matching lines found.'
    endif
endfunction

function! rookie_tag#AddFileNameTags() abort
    let input_tags = input('Enter file name tags (space separated): ')
    if empty(input_tags)
        echomsg 'No tags entered.'
        return
    endif
    let tags_list = split(input_tags, ' ')
    let cur_file_name = expand('%:t:r')
    let cur_file_path = expand('%:p:h')
    let cur_file_ext = expand('%:e')
    let cur_file_tags = split(cur_file_name, '-')
    let all_tags = cur_file_tags + tags_list
    let uniq_tags = []
    for t in all_tags
        if index(uniq_tags, t) < 0
            call add(uniq_tags, t)
        endif
    endfor
    call sort(uniq_tags)
    let sorted_tags = join(uniq_tags, '-')
    execute('Rename ' . sorted_tags . '.' . cur_file_ext)
endfunction

function! s:SearchFilesWithTags(tags) abort
    let cwd = getcwd()
    let matching_files = []
    let files = globpath(cwd, '**/*', 0, 1)
    call filter(files, 'filereadable(v:val)')
    for file in files
        if empty(file)
            continue
        endif
        let filename = fnamemodify(file, ':t')
        let all_tags_match = 1
        for tag in a:tags
            if filename !~? tag
                let all_tags_match = 0
                break
            endif
        endfor
        if all_tags_match
            call add(matching_files, file)
        endif
    endfor
    if len(matching_files) == 0
        echo "\nNo files found containing all tags: [" . join(a:tags, ', ') . "]"
    elseif len(matching_files) == 1
        execute 'edit ' . fnameescape(matching_files[0])
    else
        let qf_list = []
        for file in matching_files
            call add(qf_list, {
                \ 'filename': file,
                \ 'text': 'File containing all tags: ' . join(a:tags, ', ')
                \ })
        endfor
        call setqflist(qf_list)
        copen
    endif
endfunction

function! rookie_tag#SearchFileNameTags() abort
    let input_tags = input('Search file name tags (space separated): ')
    if empty(input_tags)
        echomsg 'No tags entered.'
        return
    endif
    let tags_list = split(input_tags, ' ')
    call s:SearchFilesWithTags(tags_list)
endfunction

function! rookie_tag#ToggleHeaderSource() abort
    let filename = expand('%:t:r')
    let extension = expand('%:e')
    let pattern = '**/' . filename . '.h'
    if extension ==# 'h'
        let pattern = '**/' . filename . '.c'
    endif
    let matches = glob(pattern, 0, 1)
    if empty(matches)
        echomsg 'Corresponding header/source not exists'
        return
    endif
    execute('edit ' . fnameescape(matches[0]))
endfunction