vim9script

export def ConvertMarkdownTitleToAnchorLink()
    var current_line = line('.')
    var title = substitute(getline('.'), '^#\+\s*', '', '')

    var anchor = substitute(tolower(title), '[ _]\+', '-', 'g')
    anchor = substitute(anchor, '[()]', '', 'g')
    anchor = substitute(anchor, '[^a-z0-9-]', '', 'g')
    anchor = substitute(anchor, '-\+', '-', 'g')
    anchor = substitute(anchor, '^-\|-$', '', 'g')

    var mdlink = printf("[%s](#%s)", title, anchor)
    call append(current_line - 1, mdlink)
enddef
