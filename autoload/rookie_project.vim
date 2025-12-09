scriptencoding utf-8

function! s:InfoFilePath() abort
    if has('win32') || has('win64')
        let base = expand('$HOME/vimfiles')
    else
        let base = expand('$HOME/.vim')
    endif
    if base ==# ''
        let base = expand('~')
    endif
    return base . '/.rookie_toys_project.csv'
endfunction

function! s:EnsureInfoFile() abort
    let f = s:InfoFilePath()
    if !filereadable(f)
        if !isdirectory(fnamemodify(f, ':h'))
            call mkdir(fnamemodify(f, ':h'), 'p')
        endif
        call writefile([], f)
        echomsg 'Projects does not exist, please add one.'
    endif
endfunction

function! s:ReadProjects() abort
    let f = s:InfoFilePath()
    if !filereadable(f)
        return []
    endif
    let lines = readfile(f)
    let res = []
    for l in lines
        if l ==# ''
            continue
        endif
        let parts = split(l, ',')
        if len(parts) >= 2
            let name = parts[0]
            let path = join(parts[1:], ',')
            call add(res, {'name': name, 'path': path})
        endif
    endfor
    return res
endfunction

function! s:WriteProjects(projects) abort
    let lines = []
    for p in a:projects
        call add(lines, p.name . ',' . p.path)
    endfor
    call writefile(lines, s:InfoFilePath())
endfunction

function! s:NameWidth(projects) abort
    let w = 0
    for p in a:projects
        let w = max([w, strdisplaywidth(p.name)])
    endfor
    return w
endfunction

function! s:SetQuickfix(projects) abort
    let w = s:NameWidth(a:projects)
    let qf = []
    let idx = 1
    for p in a:projects
        let text = printf('%-' . w . 's | %s', p.name, p.path)
        call add(qf, {'lnum': idx, 'text': text})
        let idx += 1
    endfor
    call setqflist(qf, 'r')
    copen
    let b:rookie_project_qf_name_width = w
    let b:rookie_project_items = a:projects
    execute 'nnoremap <buffer> <CR> :call rookie_project#OpenSelectedProject()<CR>'
endfunction

function! rookie_project#ProjectList() abort
    call s:EnsureInfoFile()
    let projects = s:ReadProjects()
    call s:SetQuickfix(projects)
endfunction

function! rookie_project#OpenSelectedProject() abort
    if &buftype !=# 'quickfix'
        return
    endif
    if !exists('b:rookie_project_items')
        return
    endif
    let idx = line('.') - 1
    if idx < 0 || idx >= len(b:rookie_project_items)
        return
    endif
    let prj = b:rookie_project_items[idx]
    if isdirectory(prj.path)
        execute 'cd ' . fnameescape(prj.path)
        if exists('*rookie_rooter#Lock')
            call rookie_rooter#Lock(get(g:, 'rookie_rooter_lock_seconds', 2))
        endif
        if exists(':NERDTreeCWD')
            let has_tree = 0
            for b in getbufinfo({'bufloaded': 1})
                if getbufvar(b.bufnr, '&filetype') ==# 'nerdtree'
                    let has_tree = 1
                    break
                endif
            endfor
            if has_tree
                execute 'NERDTreeCWD'
            endif
        endif
    endif

    " Remove the quickfix <CR> remap now that the project is opened
    silent! nunmap <buffer> <CR>
    " Remove the quickfix buffer
    cclose
    " Delete all buffers because of entering a new project
    silent! execute '%bd!'

    echomsg 'Opened [' . prj.name . '] at [' . prj.path . ']'
    let all = s:ReadProjects()
    let filtered = []
    for p in all
        if !(p.name ==# prj.name && p.path ==# prj.path)
            call add(filtered, p)
        endif
    endfor
    let newlist = [prj] + filtered
    call s:WriteProjects(newlist)
endfunction

function! rookie_project#ProjectAdd() abort
    call s:EnsureInfoFile()
    let path = getcwd()
    let name = input('Enter project name: ')
    if name ==# ''
        let name = fnamemodify(path, ':t')
    endif
    let projects = s:ReadProjects()
    " Check if project name exists; prompt to overwrite
    let exists = 0
    for p in projects
        if p.name ==# name
            let exists = 1
            break
        endif
    endfor
    if exists
        let ans = input("Project '" . name . "' exists. Overwrite with current path? (y/N): ")
        if tolower(ans) !=# 'y'
            echomsg 'Project add canceled.'
            return
        endif
        let out = []
        for p in projects
            if p.name ==# name
                call add(out, {'name': name, 'path': path})
            else
                call add(out, p)
            endif
        endfor
        call s:WriteProjects(out)
        echomsg 'Project ' . name . ' updated to ' . path
        return
    endif
    call add(projects, {'name': name, 'path': path})
    call s:WriteProjects(projects)
    echomsg 'Project ' . name . ' added at ' . path
endfunction

function! rookie_project#ProjectRemove() abort
    if &buftype !=# 'quickfix'
        return
    endif
    if !exists('b:rookie_project_items')
        return
    endif
    let idx = line('.') - 1
    if idx < 0 || idx >= len(b:rookie_project_items)
        return
    endif
    let prj = b:rookie_project_items[idx]
    let all = s:ReadProjects()
    let out = []
    for p in all
        if p.name ==# prj.name && p.path ==# prj.path
            continue
        endif
        call add(out, p)
    endfor
    call s:WriteProjects(out)
    echomsg 'Project ' . prj.name . ' removed.'
    call s:SetQuickfix(out)
endfunction

function! rookie_project#ProjectRename() abort
    if &buftype !=# 'quickfix'
        return
    endif
    if !exists('b:rookie_project_items')
        return
    endif
    let idx = line('.') - 1
    if idx < 0 || idx >= len(b:rookie_project_items)
        return
    endif
    let prj = b:rookie_project_items[idx]
    let newname = input('Enter new project name: ')
    if newname ==# ''
        let newname = prj.name
    endif
    let all = s:ReadProjects()
    let out = []
    for p in all
        if p.name ==# prj.name && p.path ==# prj.path
            call add(out, {'name': newname, 'path': p.path})
        else
            call add(out, p)
        endif
    endfor
    call s:WriteProjects(out)
    call s:SetQuickfix(out)
endfunction
