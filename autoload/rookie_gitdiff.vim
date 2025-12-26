scriptencoding utf-8

let g:rookie_gitdiff_sha1 = ''
let g:rookie_gitdiff_file = ''

function! rookie_gitdiff#Diff() abort
    if !exists(':Git')
        echo "RookieGitDiff: vim-fugitive is NOT installed, diff depends on it!"
        return
    endif

    let word = expand('<cword>')
    let is_short_sha = ((len(word) == 7) && (word != '') && (word =~# '\v[0-9a-f]{7}'))

    if !is_short_sha
        let g:rookie_gitdiff_file = expand('%')
        let g:rookie_gitdiff_sha1 = ''
        echo 'RookieGitDiff: Current file path saved, git sha cleared'
        return
    endif

    if g:rookie_gitdiff_file == ''
        echo 'RookieGitDiff: You should run command on your file first'
        return
    endif

    if g:rookie_gitdiff_sha1 == ''
        let g:rookie_gitdiff_sha1 = word
        echo 'RookieGitDiff: Git commit sha saved. Next run command on ANOTHER commit sha'
        return
    endif

    if g:rookie_gitdiff_sha1 == word
        echo 'RookieGitDiff: You should put cursor on ANOTHER valid git short sha (7 chars)'
        return
    endif

    let commit1 = g:rookie_gitdiff_sha1
    let commit2 = word
    let cmd1 = 'Gsplit ' . commit1 . ':' . substitute(g:rookie_gitdiff_file, '\\', '/', 'g')
    let cmd2 = 'vertical Gdiffsplit ' . commit2 . ':' . substitute(g:rookie_gitdiff_file, '\\', '/', 'g')
    let cmd_final = cmd1 . ' | ' . cmd2

    execute cmd_final
    let g:rookie_gitdiff_sha1 = ''
endfunction

" Jump to first differing column between this window and the other diff window
function! rookie_gitdiff#JumpToChange()
  let cur = getline('.')
  " find another window that has 'diff' enabled
  let other_buf = -1
  for w in range(1, winnr('$'))
    if w != winnr() && getwinvar(w, '&diff')
      let other_buf = winbufnr(w)
      break
    endif
  endfor
  if other_buf == -1
    echo "No other diff window found"
    return
  endif
  let other_line = getbufline(other_buf, line('.'))[0]
  let a = split(cur, '\zs')
  let b = split(other_line, '\zs')
  let m = min([len(a), len(b)])
  let col = 0
  for i in range(0, m - 1)
    if a[i] != b[i]
      let col = i + 1
      break
    endif
  endfor
  if col == 0
    if len(a) != len(b)
      let col = m + 1
    else
      echo "No difference on this line"
      return
    endif
  endif
  call cursor(line('.'), col)
endfunction
