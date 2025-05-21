vim9script

export def Retab(spaces: string)
    var convert_cmd = ':%s/^ \{' .. spaces .. '\}/\t/g'
    execute convert_cmd
enddef
