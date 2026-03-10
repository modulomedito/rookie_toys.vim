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
        echo "Source and destination are the same."
        return
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

function! rookie_nerdtree#RunExecutableDetached()
    let l:node = g:NERDTreeFileNode.GetSelected()
    if empty(l:node)
        return
    endif
    let l:path = l:node.path.str()
    let l:cmd = ':silent !start "' . l:path . '"'
    call feedkeys(l:cmd)
endfunction

function! s:AddNERDTreeMenuItems()
    if exists('*NERDTreeAddMenuItem')
        call NERDTreeAddMenuItem({
            \ 'text': '(R)un system executable file detach',
            \ 'shortcut': 'R',
            \ 'callback': 'rookie_nerdtree#RunExecutableDetached'
            \ })
    endif
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
    function! s:NTChCwd() abort
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
    command! -nargs=0 NTChCwd call <SID>NTChCwd()
    autocmd! FileType nerdtree nnoremap <buffer> a :call NERDTreeAddNode()<CR>
        \|nnoremap <buffer> <leader>cd :NTChCwd<CR>:NERDTreeCWD<CR>
        \|nnoremap <buffer> <C-S-e> :NERDTreeToggle<CR>
        \|nnoremap <buffer> mc :RookieNERDTreeCopy<CR>
        \|nnoremap <buffer> mC :RookieNERDTreeCopyContent<CR>
        \|nnoremap <buffer> mP :RookieNERDTreePaste<CR>
    nnoremap <C-S-e> :NERDTreeFocus<CR>
    nnoremap <C-y> :NERDTreeToggle<CR>
    nnoremap <leader>find :NERDTreeFind<CR>
endfunction
