vim9script

# Smartly delete the current buffer while preserving the window layout.
# Ported from rookie_bufoutline#SmartDeleteBuffer but using built-in buffer functions.
export def SmartDelete(bang: bool = false)
    const cur_buf = bufnr('%')

    # Get all listed buffers
    const listed_buffers = getbufinfo({'buflisted': 1})

    if len(listed_buffers) <= 1
        # If it's the only buffer, create a new empty one
        enew
        if buflisted(cur_buf)
            execute 'bdelete' .. (bang ? '!' : '') .. ' ' .. cur_buf
        endif
        return
    endif

    # Find the current buffer's position in the listed buffers
    var idx = -1
    for i in range(len(listed_buffers))
        if listed_buffers[i].bufnr == cur_buf
            idx = i
            break
        endif
    endfor

    # Determine the target buffer to switch to
    var target_buf = -1
    if idx != -1
        if idx < len(listed_buffers) - 1
            # Switch to the next buffer in the list
            target_buf = listed_buffers[idx + 1].bufnr
        else
            # If it's the last buffer, switch to the previous one
            target_buf = listed_buffers[idx - 1].bufnr
        endif
    endif

    # Switch to the target buffer if one was found
    if target_buf != -1
        execute 'buffer ' .. target_buf
    endif

    # Delete the original buffer
    if buflisted(cur_buf)
        execute 'bdelete' .. (bang ? '!' : '') .. ' ' .. cur_buf
    endif
enddef

# Setup the mapping for smart buffer deletion.
export def Setup()
    nnoremap <unique> <leader>x <scriptcmd>SmartDelete()<cr>
enddef