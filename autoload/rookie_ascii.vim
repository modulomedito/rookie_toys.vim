function! rookie_ascii#ToHex() abort
    " Save current register content
    let l:saved_reg = @"

    " Re-select the last visual selection and yank it
    normal! gvy
    let l:selection = @"

    " Restore register
    let @" = l:saved_reg

    if empty(l:selection)
        echo "No selection found"
        return
    endif

    let l:hex_values = []
    " Split string into characters safely
    let l:chars = split(l:selection, '\zs')

    for l:char in l:chars
        call add(l:hex_values, printf('%02X', char2nr(l:char)))
    endfor

    let l:result = join(l:hex_values, ' ')

    " Copy to system clipboard if available
    if has('clipboard')
        let @+ = l:result
        let @* = l:result
    endif

    " Also copy to unnamed register for convenience
    let @" = l:result

    echo "Copied ASCII Hex: " . l:result
endfunction
