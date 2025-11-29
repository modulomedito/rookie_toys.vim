# rookie\_toys.vim

A comprehensive Vim plugin collection providing powerful development tools and utilities for modern vim9script environments.

## Prerequisite

Vim which supports **vim9script** (Vim 9.0+)

## Install

**vim-plug**

```vim9script
Plug 'https://github.com/modulomedito/rookie_toys.vim'
```

## Features Overview

This plugin provides a collection of powerful development tools organized into several modules:

- **rookie_clangd**: C/C++ development with clangd integration
- **rookie_gitgraph**: Git visualization and graph display
- **rookie_gitdiff**: Advanced git diff utilities
- **rookie_markdown**: Markdown editing and formatting tools
- **rookie_tag**: Tag-based file organization and search
- **rookie_retab**: Smart tab management
- **rookie_setup**: Complete Vim environment configuration
- **rookie_lsp**: LSP (Language Server Protocol) integration
- **rookie_rg**: Ripgrep integration for fast searching
- **rookie_project**: Lightweight project management via CSV and quickfix
- **rookie_rooter**: Automatic root detection and CWD management

---

## Detailed Features

### 🔧 rookie\_clangd

Automatically generates `compile_commands.json` for clangd language server integration, enabling powerful C/C++ development features.

#### Global Variables

```vim9script
g:rookie_toys_clangd_source_patterns = ['c', 'cpp'] # Source files search pattern
g:rookie_toys_clangd_header_patterns = ['h', 'hpp'] # Header files search pattern
g:rookie_toys_clangd_compiler = 'gcc'               # Any compiler you prefer
g:rookie_toys_clangd_args = ['-ferror-limit=3000']  # Arguments for clangd
```

#### Commands

- **`:RookieClangdGenerate`** - Recursively searches your project directory and generates a `compile_commands.json` file for clangd indexing

**Usage Example:**
```vim
:RookieClangdGenerate
```

---

### 📁 rookie_project

Lightweight project management using a CSV info file.

#### Commands

- **`:RookieProjectList`** - List projects in quickfix; press `<CR>` to open and set CWD
- **`:RookieProjectAdd`** - Add current CWD as a project; prompts for name
- **`:RookieProjectRemove`** - Remove selected project from the info file
- **`:RookieProjectRename`** - Rename selected project in the quickfix list

**Features:**
- Stores `.rookie_toys_project.csv` in runtime directory
  - Non‑Windows: `$HOME/.vim/.rookie_toys_project.csv`
  - Windows: `$HOME/vimfiles/.rookie_toys_project.csv`
- CSV columns: `name,path`
- Quickfix shows aligned columns for readability
- When opening a project: quickfix closes, CWD changes, project moves to top

**Usage Example:**
```vim
:RookieProjectList
" In the quickfix window, move cursor to a project and press <CR>

:RookieProjectAdd
:RookieProjectRemove   " run with cursor on a project line in quickfix
:RookieProjectRename   " run with cursor on a project line in quickfix
```

---

### 🧭 rookie_rooter

Automatic working directory management based on root markers, designed not to conflict with `rookie_project`.

#### Global Variables

```vim
let g:rookie_rooter_enable = 1                     " enable/disable auto-root
let g:rookie_rooter_scope = 'cd'                   " 'cd'|'tcd'|'lcd'
let g:rookie_rooter_patterns = ['.git', 'compile_commands.json', 'Cargo.toml', 'Makefile', '.root']
let g:rookie_rooter_exclude_filetypes = ['git', 'help', 'qf', 'quickfix', 'nerdtree']
let g:rookie_rooter_lock_seconds = 2               " cool down after project open
let g:rookie_rooter_auto_setup = 1                 " auto setup on plugin load
let g:rookie_rooter_echo_changed = 1               " echo message when CWD changes
```

#### Commands

- **`:RookieRooterSetup`** — Setup auto-root autocmds
- **`:RookieRooterDisable`** — Disable auto-root
- **`:RookieRooterEnable`** — Enable and setup
- **`:RookieRooterToggle`** — Toggle enable/disable
- **`:RookieRooterHere`** — Root immediately based on current buffer

**Features:**
- Upward search for root markers; sets CWD with configurable scope
- Skips auto-root briefly after `rookie_project` opens a project to avoid override
- Optional echo showing the new CWD and which marker was matched

**Usage Example:**
```vim
let g:rookie_rooter_scope = 'tcd'
let g:rookie_rooter_patterns = ['.git', 'compile_commands.json', 'Cargo.toml']
:RookieRooterSetup
" Manually root current buffer
:RookieRooterHere
```

### 📊 rookie\_gitgraph

Provides beautiful git graph visualization directly in Vim using vim-fugitive.

#### Commands

- **`:RookieGitGraph`** - Opens git graph showing all branches with decorations
- **`:RookieGitGraphLocal`** - Opens git graph for current branch only

**Features:**
- Displays commit hashes, dates, authors, and commit messages
- Shows branch decorations and merge relationships
- Automatically closes existing git buffers before opening new ones

**Usage Example:**
```vim
:RookieGitGraph        " Show all branches
:RookieGitGraphLocal   " Show current branch only
```

---

### 🔄 rookie\_gitdiff

Advanced git diff utility for comparing specific commits of files.

#### Commands

- **`:RookieGitDiff`** - Interactive git diff between two commits

**Workflow:**
1. Run `:RookieGitDiff` on any file to save the file path
2. Place cursor on a 7-character git SHA and run the command again to save first commit
3. Place cursor on another git SHA and run the command to open diff view

**Usage Example:**
```vim
" 1. On your target file
:RookieGitDiff
" 2. Place cursor on commit SHA like 'a1b2c3d' and run
:RookieGitDiff
" 3. Place cursor on another SHA like 'e4f5g6h' and run
:RookieGitDiff
" Opens split diff view comparing the two commits
```

---

### 📝 rookie\_markdown

Comprehensive markdown editing and formatting tools.

#### Commands

- **`:RookieMarkdownTitleToAnchor`** - Converts markdown headers to anchor links
- **`:RookieMarkdownLinter`** - Formats and lints markdown files

**MarkdownLinter Features:**
- Condenses multiple blank lines to maximum of 2
- Adds blank lines before headers for better readability
- Adds blank lines after headers for proper spacing
- Preserves cursor position after formatting

**Usage Example:**
```vim
" Convert header to anchor link
:RookieMarkdownTitleToAnchor

" Format and lint current markdown file
:RookieMarkdownLinter
```

---

### 🏷️ rookie\_tag

Powerful tag-based file organization and search system for project management.

#### Commands

- **`:RookieTagUpdate`** - Add/update tags on current line
- **`:RookieTagSearch`** - Search for lines containing specific tags
- **`:RookieTagSearchGlobal`** - Global search across all files for tags
- **`:RookieTagAddFileName`** - Add tags to current filename
- **`:RookieTagSearchFileName`** - Search files by filename tags
- **`:RookieToggleHeaderSource`** - Toggle between header and source files

**Tag System Features:**
- Uses `#tag` format for tagging
- Automatically sorts and deduplicates tags
- Supports multi-tag search with AND logic
- Integrates with quickfix list for multiple results
- File renaming based on tag system

**Usage Examples:**
```vim
" Add tags to current line
:RookieTagUpdate
" Enter: web frontend javascript

" Search for lines with specific tags
:RookieTagSearch
" Enter: web javascript

" Add tags to filename (renames file)
:RookieTagAddFileName
" Enter: component button

" Search files by tags in filename
:RookieTagSearchFileName
" Enter: component

" Toggle between header/source files
:RookieToggleHeaderSource
```

---

### 📐 rookie\_retab

Smart tab management utility for consistent code formatting.

#### Commands

- **`:RookieRetab`** - Converts tabs to spaces with smart formatting

**Features:**
- Sets tabstop to 4 spaces
- Temporarily disables expandtab for retab operation
- Re-enables expandtab for consistent spacing
- Maintains code structure and indentation

**Usage Example:**
```vim
:RookieRetab
```

---

### ⚙️ rookie\_setup

Complete Vim environment configuration with sensible defaults and key mappings.

#### Features

**Key Mappings:**
- `<Space>` as leader key
- `<C-s>` - Save file and remove trailing whitespace
- `<C-q>` - Quick quit
- `<C-p>` - Find files
- `<F2>` - Search and replace current word
- `<M-j>/<M-k>` - Move lines up/down
- And many more productivity mappings

**Vim Options:**
- Modern defaults with sensible settings
- Relative line numbers with absolute current line
- Smart case searching
- Persistent undo
- Terminal GUI colors
- Custom status line with git integration

**Plugin Integration:**
- Automatically sets up LSP keymaps
- Configures ripgrep integration
- Sets up text manipulation plugins

---

### 🔍 rookie\_lsp

Language Server Protocol integration with support for multiple languages.

#### Supported Languages

- **C/C++** - clangd with background indexing
- **Markdown** - marksman language server
- **Rust** - rust-analyzer
- **TOML** - taplo language server

#### Key Mappings

- `<leader>rn` - Rename symbol
- `<S-M-f>` - Format document
- `<leader>hh` - Switch between source/header
- `[d` / `]d` - Navigate diagnostics
- `gd` - Go to definition
- `gr` - Show references
- `gh` - Show hover information
- `gi` - Go to implementation
- `gy` - Go to type definition
- `gs` - Document symbols
- `gS` - Symbol search

---

### 🔎 rookie\_rg

Ripgrep integration for blazing fast text searching across projects.

#### Features

- Automatically detects and configures ripgrep if available
- Smart case searching with hidden file support
- Vim-compatible grep format
- Quickfix integration

#### Key Mappings

- `<leader>gg` - Search word under cursor across project
- `<leader>gf` - Interactive live grep with custom pattern

**Usage Example:**
```vim
" Search current word under cursor
<leader>gg

" Interactive search
<leader>gf
" Enter your search pattern when prompted
```

---

## Command Reference

### Available Commands

| Command | Description |
|---------|-------------|
| `:RookieClangdGenerate` | Generate compile_commands.json |
| `:RookieGitGraph` | Show git graph (all branches) |
| `:RookieGitGraphLocal` | Show git graph (current branch) |
| `:RookieGitDiff` | Interactive git diff |
| `:RookieMarkdownTitleToAnchor` | Convert header to anchor |
| `:RookieMarkdownLinter` | Format markdown file |
| `:RookieRetab` | Smart tab conversion |
| `:RookieTagUpdate` | Update line tags |
| `:RookieTagSearch` | Search by tags |
| `:RookieTagSearchGlobal` | Global tag search |
| `:RookieTagAddFileName` | Add tags to filename |
| `:RookieTagSearchFileName` | Search files by tags |
| `:RookieToggleHeaderSource` | Toggle header/source |
| `:RookieProjectList` | List projects in quickfix |
| `:RookieProjectAdd` | Add current CWD as a project |
| `:RookieProjectRemove` | Remove selected project |
| `:RookieProjectRename` | Rename selected project |
| `:RookieRooterSetup` | Setup auto-root |
| `:RookieRooterDisable` | Disable auto-root |
| `:RookieRooterEnable` | Enable and setup auto-root |
| `:RookieRooterToggle` | Toggle auto-root |
| `:RookieRooterHere` | Root immediately |

**Note:** All commands must be used with their full names. No short aliases are available.

### Setup

The plugin automatically loads all modules. To use the complete environment setup:

```vim9script
" In your vimrc
call rookie_setup.Setup()
```

This will configure your entire Vim environment with all the productivity features, key mappings, and integrations.

---

## Dependencies

- **vim-fugitive** (for git features)
- **ripgrep** (optional, for enhanced searching)
- **Language servers** (optional, for LSP features):
  - clangd (C/C++)
  - marksman (Markdown)
  - rust-analyzer (Rust)
  - taplo (TOML)

## License

MIT License - see LICENSE file for details.
