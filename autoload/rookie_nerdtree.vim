function! rookie_nerdtree#CopyNode()
    let l:node = g:NERDTreeFileNode.GetSelected()
    if empty(l:node)
        echo "No node selected"
        return
    endif
    let l:path = l:node.path.str()
    let @+ = l:path
    let @* = l:path
    echo "Marked for copy to clipboard: " . l:path
endfunction

function! s:BuildCopyTargetPath(sourcePath, destDir) abort
    let l:sourceName = fnamemodify(a:sourcePath, ':t')
    let l:sourceRoot = fnamemodify(l:sourceName, ':r')
    let l:sourceExt = fnamemodify(l:sourceName, ':e')
    let l:suffix = '(copy)'
    let l:index = 1

    while 1
        if isdirectory(a:sourcePath)
            let l:targetName = l:sourceName . l:suffix . (l:index > 1 ? ' ' . l:index : '')
        elseif empty(l:sourceExt)
            let l:targetName = l:sourceName . l:suffix . (l:index > 1 ? ' ' . l:index : '')
        else
            let l:targetName = l:sourceRoot . l:suffix . (l:index > 1 ? ' ' . l:index : '') . '.' . l:sourceExt
        endif

        let l:targetPath = a:destDir . nerdtree#slash() . l:targetName
        if glob(l:targetPath) ==# ""
            return l:targetPath
        endif

        let l:index += 1
    endwhile
endfunction

function! rookie_nerdtree#PasteNode()
    let l:sourcePath = @+
    if l:sourcePath ==# ""
        let l:sourcePath = @*
    endif

    if l:sourcePath ==# ""
        echo "Clipboard is empty."
        return
    endif

    if !filereadable(l:sourcePath) && !isdirectory(l:sourcePath)
        echo "Clipboard content is not a valid path: " . l:sourcePath
        return
    endif

    let l:destNode = g:NERDTreeFileNode.GetSelected()
    if empty(l:destNode)
        echo "No destination node selected"
        return
    endif

    let l:destDir = l:destNode.path.str()
    if !l:destNode.path.isDirectory
        let l:destDir = fnamemodify(l:destDir, ':h')
    endif

    let l:sourceName = fnamemodify(l:sourcePath, ':t')
    let l:targetPath = l:destDir . nerdtree#slash() . l:sourceName

    if l:targetPath ==# l:sourcePath
        let l:targetPath = s:BuildCopyTargetPath(l:sourcePath, l:destDir)
    endif

    if glob(l:targetPath) !=# ""
        echo "Target already exists: " . l:targetPath
        return
    endif

    try
        let l:sourcePathObj = g:NERDTreePath.New(l:sourcePath)
        call l:sourcePathObj.copy(l:targetPath)
        call b:NERDTree.root.refresh()
        call NERDTreeRender()
        echo "Copied to " . l:targetPath
    catch /^NERDTree/
        call nerdtree#echoWarning('Could not copy node')
    endtry
endfunction

function! rookie_nerdtree#CopyNodeContent()
    let l:node = g:NERDTreeFileNode.GetSelected()
    if empty(l:node)
        echo "No node selected"
        return
    endif

    let l:path = l:node.path.str()
    " Ensure backslashes for Windows path
    let l:path = substitute(l:path, '/', '\', 'g')

    if !filereadable(l:path) && !isdirectory(l:path)
        echo "Path not readable: " . l:path
        return
    endif

    " Escape single quotes for PowerShell
    let l:ps_path = substitute(l:path, "'", "''", "g")

    " PowerShell command to copy file to clipboard as FileDropList
    let l:cmd = "powershell -NoProfile -Command \"Add-Type -AssemblyName System.Windows.Forms; $files = New-Object System.Collections.Specialized.StringCollection; $files.Add('" . l:ps_path . "'); [System.Windows.Forms.Clipboard]::SetFileDropList($files)\""

    let l:output = system(l:cmd)

    if v:shell_error == 0
        echo "Copied file to system clipboard (Explorer compatible): " . l:path
    else
        echo "Failed to copy file to clipboard: " . l:output
    endif
endfunction

function! rookie_nerdtree#PasteSystemClipboardContent()
    let l:node = g:NERDTreeFileNode.GetSelected()
    if empty(l:node)
        echo "No node selected"
        return
    endif

    let l:destDir = l:node.path.str()
    if !l:node.path.isDirectory
        let l:destDir = fnamemodify(l:destDir, ':h')
    endif

    let l:timestamp = strftime('%Y%m%d_%H%M%S')

    if has('win32') || has('win64')
        let l:destDir_ps = substitute(l:destDir, "'", "''", "g")
        let l:script = "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $dest = '" . l:destDir_ps . "'; if ([System.Windows.Forms.Clipboard]::ContainsFileDropList()) { $files = [System.Windows.Forms.Clipboard]::GetFileDropList(); foreach ($f in $files) { Copy-Item -Path $f -Destination $dest -Recurse -Force }; Write-Host 'Copied files' } elseif ([System.Windows.Forms.Clipboard]::ContainsImage()) { $img = [System.Windows.Forms.Clipboard]::GetImage(); $path = Join-Path $dest ('clipboard_image_" . l:timestamp . ".png'); $img.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); Write-Host ('Saved image to ' + $path) } elseif ([System.Windows.Forms.Clipboard]::ContainsText()) { $txt = [System.Windows.Forms.Clipboard]::GetText(); $path = Join-Path $dest ('clipboard_text_" . l:timestamp . ".txt'); [IO.File]::WriteAllText($path, $txt); Write-Host ('Saved text to ' + $path) } else { Write-Host 'Clipboard is empty or unsupported format' }"
        let l:cmd = 'powershell -NoProfile -Command "' . l:script . '"'
        let l:output = system(l:cmd)
        echo l:output
    elseif has('mac') || has('macunix')
        let l:destDir_sh = escape(l:destDir, "'")
        let l:cmd = "sh -c 'if pbpaste | grep -q \"^/\"; then for file in $(pbpaste); do cp -r \"$file\" ''" . l:destDir_sh . "''/ 2>/dev/null; done; echo \"Copied paths\"; else pbpaste > ''" . l:destDir_sh . "/clipboard_text_" . l:timestamp . ".txt''; echo \"Saved text\"; fi'"
        let l:output = system(l:cmd)
        echo l:output
    else
        let l:destDir_sh = escape(l:destDir, "'")
        let l:cmd = "sh -c 'if xclip -selection clipboard -o | grep -q \"^/\"; then for file in $(xclip -selection clipboard -o); do cp -r \"$file\" ''" . l:destDir_sh . "''/ 2>/dev/null; done; echo \"Copied paths\"; else xclip -selection clipboard -o > ''" . l:destDir_sh . "/clipboard_text_" . l:timestamp . ".txt''; echo \"Saved text\"; fi'"
        let l:output = system(l:cmd)
        echo l:output
    endif

    call b:NERDTree.root.refresh()
    call NERDTreeRender()
endfunction

function! rookie_nerdtree#RunExecutableDetached()
    let l:node = g:NERDTreeFileNode.GetSelected()
    if empty(l:node)
        return
    endif
    let l:path = l:node.path.str()
    " let l:cmd = ':silent !start "' . l:path . '"'
    " call feedkeys(l:cmd)
    execute 'silent !start "' . shellescape(l:path) . '"'
endfunction

function! rookie_nerdtree#RemoveBuffersNotUnderRoot() abort
    if !exists('b:NERDTree')
        return
    endif
    let l:root_path = b:NERDTree.root.path.str()
    let l:root_path = fnamemodify(l:root_path, ':p')
    " Normalize slashes for comparison
    let l:root_path = substitute(l:root_path, '\\', '/', 'g')

    let l:buffers_to_delete = []
    for l:buf in getbufinfo({'buflisted': 1})
        let l:buf_name = fnamemodify(l:buf.name, ':p')
        let l:buf_name = substitute(l:buf_name, '\\', '/', 'g')
        " If the buffer is a file and not under the new root, mark for deletion
        if !empty(l:buf.name) && stridx(l:buf_name, l:root_path) != 0
            call add(l:buffers_to_delete, l:buf.bufnr)
        endif
    endfor

    let l:listed_buffers = len(getbufinfo({'buflisted': 1}))
    let l:will_be_empty = (l:listed_buffers == len(l:buffers_to_delete))

    if l:will_be_empty && len(l:buffers_to_delete) > 0
        enew
    endif

    for l:bufnr in l:buffers_to_delete
        " If the buffer is displayed in any window, switch that window to an empty buffer first
        for l:win in getwininfo()
            if l:win.bufnr == l:bufnr
                call win_execute(l:win.winid, 'enew')
            endif
        endfor
        execute 'silent! bdelete ' . l:bufnr
    endfor
endfunction

function! rookie_nerdtree#BookmarkEnter(bm) abort
    call a:bm.activate(b:NERDTree)
    call timer_start(200, {t -> feedkeys(":\<C-u>NTChCwd\<CR>:\<C-u>NERDTreeCWD\<CR>:\<C-u>call rookie_nerdtree#RemoveBuffersNotUnderRoot()\<CR>", 'n')})
endfunction

function! s:AddNERDTreeMenuItems()
    if exists('*NERDTreeAddMenuItem')
        " call NERDTreeAddMenuItem({
        "     \ 'text': '(R)un system executable file detach',
        "     \ 'shortcut': 'R',
        "     \ 'callback': 'rookie_nerdtree#RunExecutableDetached'
        "     \ })
        " call NERDTreeAddMenuItem({
        "     \ 'text': 'copy node path to (c)lipboard',
        "     \ 'shortcut': 'c',
        "     \ 'callback': 'rookie_nerdtree#CopyNode'
        "     \ })
        " call NERDTreeAddMenuItem({
        "     \ 'text': 'Paste nerdtree node like Ctrl+(v)',
        "     \ 'shortcut': 'v',
        "     \ 'callback': 'rookie_nerdtree#PasteNode'
        "     \ })
        " call NERDTreeAddMenuItem({
        "     \ 'text': '(C)opy node content to system clipboard',
        "     \ 'shortcut': 'C',
        "     \ 'callback': 'rookie_nerdtree#CopyNodeContent'
        "     \ })
        " call NERDTreeAddMenuItem({
        "     \ 'text': '(P)aste system clipboard content',
        "     \ 'shortcut': 'P',
        "     \ 'callback': 'rookie_nerdtree#PasteSystemClipboardContent'
        "     \ })
    endif
    if exists('*NERDTreeAddKeyMap')
        call NERDTreeAddKeyMap({
            \ 'key': '<CR>',
            \ 'scope': 'Bookmark',
            \ 'callback': 'rookie_nerdtree#BookmarkEnter',
            \ 'override': 1
            \ })
    endif
endfunction

function! rookie_nerdtree#ChangeCwdToNode() abort
    let l:node = g:NERDTreeFileNode.GetSelected()
    if empty(l:node)
        echo 'select a node first'
        return
    endif
    try
        call l:node.path.changeToDir()
    catch /^NERDTree.PathChangeError/
        echohl WarningMsg | echom 'could not change cwd' | echohl NONE
    endtry
endfunction

function! rookie_nerdtree#Setup() abort
    if exists('g:loaded_nerd_tree')
        call s:AddNERDTreeMenuItems()
    else
        augroup RookieNERDTreeMenu
            autocmd!
            autocmd User NERDTreeInit call s:AddNERDTreeMenuItems()
        augroup END
    endif

    " Plug 'Xuyuanp/nerdtree-git-plugin'
    let g:NERDTreeGitStatusUseNerdFonts = 0

    let g:NERDTreeWinSize = 40
    command! -nargs=0 NTChCwd call rookie_nerdtree#ChangeCwdToNode()
    autocmd! FileType nerdtree nnoremap <buffer> a :call NERDTreeAddNode()<CR>
        \|nnoremap <buffer> <leader>cd :NTChCwd<CR>:NERDTreeCWD<CR>
        \|nnoremap <buffer> <C-S-e> :NERDTreeToggle<CR>
        \|nnoremap <buffer> mc :RookieNERDTreeCopy<CR>
        \|nnoremap <buffer> mR :call rookie_nerdtree#RunExecutableDetached()<CR>
        \|nnoremap <buffer> mv :call rookie_nerdtree#PasteNode()<CR>
        \|nnoremap <buffer> mC :call rookie_nerdtree#CopyNodeContent()<CR>
        \|nnoremap <buffer> mP :call rookie_nerdtree#PasteSystemClipboardContent()<CR>
    nnoremap <C-S-e> :NERDTreeFocus<CR>
    nnoremap <C-y> :NERDTreeToggle<CR>
    nnoremap <leader>find :NERDTreeFind<CR>
endfunction
