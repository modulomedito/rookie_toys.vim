vim9script

# Setup the GitGutter plugin.
export def Setup()
    # Map <S-u> (U) to undo hunk.
    nnoremap <silent> <S-u> :GitGutterUndoHunk<CR>
enddef
