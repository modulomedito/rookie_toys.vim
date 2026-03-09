function! rookie_nerdtree#CopyNode()
    let l:node = g:NERDTreeFileNode.GetSelected()
    if empty(l:node)
        echo "No node selected"
        return
    endif
    let l:path = l:node.path.str()
    let @+ = l:path
    let @* = l:path

    " Copy file to system clipboard (for pasting in Explorer)
    if has('win32') || has('win64')
        let l:ps_path = substitute(l:path, "'", "''", 'g')
        let l:cmd = "powershell -NoProfile -Command \"Add-Type -AssemblyName System.Windows.Forms; $c = New-Object System.Collections.Specialized.StringCollection; $c.Add('" . l:ps_path . "'); [System.Windows.Forms.Clipboard]::SetFileDropList($c)\""
        call system(l:cmd)
    endif

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
