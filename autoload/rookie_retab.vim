scriptencoding utf-8

function! rookie_retab#Retab() abort
    let &l:tabstop = 4
    let &l:expandtab = 0
    execute(':%retab!')
    let &l:expandtab = 1
endfunction
