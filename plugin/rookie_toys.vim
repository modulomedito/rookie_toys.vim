vim9script

# Prevents multiple loading
if exists('g:rookie_toys')
    finish
endif
g:rookie_toys = 1

# rookie_markdown
command -nargs=0 -bar RookieMarkdownTitleToAnchor rookie_markdown#ConvertMarkdownTitleToAnchorLink()
command -nargs=0 -bar -range RookieMarkdownLinter rookie_markdown#MarkdownLinter()
command -nargs=? -bar RookieSlugify echo rookie_markdown#SlugifyString(empty(<q-args>) ? getline('.') : <q-args>)
command -nargs=0 -bar RookieSlugifyLine setline('.', rookie_markdown#SlugifyString(getline('.')))
command -nargs=0 -bar RookieSlugifyYank {
    var _slug = rookie_markdown#SlugifyString(getline('.'))
    @" = _slug
    if has('clipboard')
        @+ = _slug
    endif
    echo _slug
}

# rookie_tabrename
command -nargs=? -bar RookieTabRename rookie_tabrename#Rename(<f-args>)

# rookie_tag
command -nargs=0 -bar RookieTagUpdate rookie_tag#UpdateTags()
command -nargs=0 -bar RookieTagSearch rookie_tag#SearchTags()
command -nargs=0 -bar RookieTagSearchGlobal rookie_tag#SearchGlobalTags()
command -nargs=0 -bar RookieTagAddFileName rookie_tag#AddFileNameTags()
command -nargs=0 -bar RookieTagSearchFileName rookie_tag#SearchFileNameTags()

# rookie_clangd
command -nargs=0 -bar RookieClangdGenerate rookie_clangd#CreateCompileCommandsJson()
command -nargs=0 -bar RookieRustTestFunctionUnderCursor rookie_rust#TestFunctionUnderCursor()
command -nargs=0 -bar RookieRetab rookie_retab#Retab()
command -nargs=0 -bar RookieToggleHeaderSource rookie_tag#ToggleHeaderSource()
command -nargs=0 -range=-1 -bar RookieHexToAscii rookie_hex#HexToAscii(<count> != -1)
command -nargs=0 -range=% -bar RookieHexChecksum rookie_hex#UpdateIntelHexChecksum()

# rookie_nerdtree
command -nargs=0 -bar RookieNERDTreeCopy enhance#nerdtree#CopyNode()
command -nargs=0 -bar RookieNERDTreeCopyContent enhance#nerdtree#CopyNodeContent()
command -nargs=0 -bar RookieNERDTreePaste enhance#nerdtree#PasteNode()
command -nargs=0 -bar RookieNERDTreePasteSystemClipboardContent enhance#nerdtree#PasteSystemClipboardContent()

# rookie_gitgraph
command -nargs=0 -bar RookieGitGraph rookie_gitgraph#OpenGitGraph(1)
command -nargs=0 -bar RookieGitGraphLocal rookie_gitgraph#OpenGitGraph(0)
command -nargs=0 -bar RookieGitDiff rookie_gitdiff#Diff()
command -nargs=0 -bar RookieGitDiffJumpToChange rookie_gitdiff#JumpToChange()
command -nargs=? -bar RookieGitOpenCommitDiff rookie_git#OpenCommitDiff(<f-args>)
command -nargs=0 -bar RookieGitDiffFileNext rookie_git#DiffFileNavigate(1)
command -nargs=0 -bar RookieGitDiffFilePrevious rookie_git#DiffFileNavigate(-1)
command -nargs=0 -bar RookieGitAutoFetch rookie_git#AutoFetch()

# rookie_project
command -nargs=0 -bar RookieProjectList rookie_project#ProjectList()
command -nargs=0 -bar RookieProjectAdd rookie_project#ProjectAdd()
command -nargs=0 -bar RookieProjectRemove rookie_project#ProjectRemove()
command -nargs=0 -bar RookieProjectRename rookie_project#ProjectRename()

# rookie_rooter
command -nargs=0 -bar RookieRooterSetup rookie_rooter#Setup()
command -nargs=0 -bar RookieRooterDisable rookie_rooter#Disable()
command -nargs=0 -bar RookieRooterEnable {
    g:rookie_rooter_enable = 1
    rookie_rooter#Setup()
}
command -nargs=0 -bar RookieRooterToggle {
    g:rookie_rooter_enable = get(g:, 'rookie_rooter_enable', 1) ? 0 : 1
    if g:rookie_rooter_enable
        rookie_rooter#Setup()
    else
        rookie_rooter#Disable()
    endif
}
command -nargs=0 -bar RookieRooterHere rookie_rooter#RootHere()

# rookie_guid
command -nargs=0 -bar RookieGuidGenerate rookie_guid#Insert()
command -nargs=0 -bar RookieGuidSearch rookie_guid#Search()
command -nargs=0 -bar RookieGuidList rookie_guid#List()

# rookie_aspice
command -nargs=0 -bar RookieAspiceShowTraceability rookie_aspice#ShowTraceability()
command -nargs=0 -bar RookieAspiceCloseTraceability rookie_aspice#CloseTraceability()

# rookie_rg
command -nargs=0 -bar RookieRgLiveGrep rookie_rg#LiveGrep()
command -nargs=0 -bar RookieRgGlobalGrep rookie_rg#GlobalGrep()
command -nargs=0 -range -bar RookieRgVisualGrep rookie_rg#VisualGrep()
command -nargs=0 -bar RookieRgClearHighlight rookie_rg#ClearHighlight()

# rookie_far
command -nargs=+ -complete=file RookieFarReplace rookie_far#Replace(<f-args>)
command -nargs=+ -complete=file RookieFarFind rookie_far#Find(<f-args>)
command -nargs=0 RookieFarDo rookie_far#Do()
command -nargs=0 RookieFarUndo rookie_far#Undo()

# rookie_smooth
command -nargs=0 RookieSmoothScrollHalfPageUp rookie_smooth#HalfPageUp()
command -nargs=0 RookieSmoothScrollHalfPageDown rookie_smooth#HalfPageDown()
command -nargs=0 RookieSmoothScrollPageUp rookie_smooth#PageUp()
command -nargs=0 RookieSmoothScrollPageDown rookie_smooth#PageDown()

# rookie_c
command -nargs=0 -range -bar RookieCCommentToSlash rookie_c#CommentToSlash(<line1>, <line2>)

# rookie_ascii
command -nargs=0 -range -bar RookieAsciiToHex rookie_ascii#ToHex()

# rookie_plugins
command -nargs=0 -bar RookiePlugCocGetConfig rookie_plugins#CocGetConfig()

# rookie_7zip
command -nargs=? -bar Rookie7zZip rookie_7zip#Zip(<f-args>)
command -nargs=? -bar Rookie7zUnzip rookie_7zip#Unzip(<f-args>)

# Setup
rookie_setup#Setup()
