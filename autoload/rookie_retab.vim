vim9script

export def Retab(): void
    &tabstop = 4
    &expandtab = false
    execute(':%retab!')
    &expandtab = true
enddef
