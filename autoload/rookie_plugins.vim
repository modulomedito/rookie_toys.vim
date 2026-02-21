scriptencoding utf-8

function! rookie_plugins#SetupPlugins() abort
    " call plug#begin()
    " Plug 'github/copilot.vim'              " Use LLM
    Plug 'SirVer/ultisnips'                 " Snippets
    Plug 'Xuyuanp/nerdtree-git-plugin'      " Nerdtree git icon
    Plug 'andrejlevkovitch/vim-lua-format'  " Lua formatter
    Plug 'azabiong/vim-highlighter'         " Highlight words
    Plug 'dhruvasagar/vim-table-mode'       " Table alignment
    Plug 'godlygeek/tabular'                " Markdown code syntax Highlighting
    Plug 'honza/vim-snippets'               " Snippets
    Plug 'hotoo/pangu.vim'                  " Chinese formatter
    Plug 'joshdick/onedark.vim'             " Colorscheme
    Plug 'junegunn/vim-easy-align'          " Easy align
    Plug 'justinmk/vim-dirvish'             " File browser
    Plug 'kshenoy/vim-signature'            " Bookmarks
    Plug 'mbbill/undotree'                  " Undo history visualizer
    Plug 'modulomedito/far.vim'             " Find and replace
    Plug 'neoclide/coc.nvim', {'branch': 'release'} " LSP
    Plug 'octol/vim-cpp-enhanced-highlight' " C language syntax highlight enhance
    Plug 'preservim/nerdtree'               " File browser
    Plug 'sainnhe/everforest'               " Colorscheme
    Plug 'skywind3000/asyncrun.vim'         " Asynchronously run
    Plug 't9md/vim-textmanip'               " Text movement
    Plug 'tpope/vim-commentary'             " Comment out
    Plug 'tpope/vim-fugitive'               " Git integration
    Plug 'tpope/vim-surround'               " Surroud word with char
    Plug 'tpope/vim-unimpaired'             " Efficient keymaps
    Plug 'vim-airline/vim-airline'          " Vim bottom status line
    Plug 'vim-airline/vim-airline-themes'   " Vim bottom status line
    Plug 'vim-scripts/DrawIt'               " Draw ASCII art
    " call plug#end()
endfunction