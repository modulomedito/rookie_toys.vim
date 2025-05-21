vim9script

export def Retab(spaces: string)
    var convert_cmd = '%s/\( \{' ..
                      spaces ..
                      '}\)\+/\=repeat("\t", len(submatch(0)) / ' ..
                      spaces ..
                      ')/g'
    execute convert_cmd
enddef
