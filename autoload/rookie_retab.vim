vim9script

export def Retab(spaces: number)
    var convert_cmd = "%s/^ \\{" .. spaces .. "\\}/\\t/g"
    execute convert_cmd
enddef
