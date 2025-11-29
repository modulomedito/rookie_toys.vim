# rookie_toys.vim

Practical Vim plugin collection with focused, ready-to-use features.

## Compatibility

- Vim 8.2+ or Neovim 0.6+

## Install

**vim-plug**

```vim
Plug 'https://github.com/modulomedito/rookie_toys.vim'
```

## Features Overview

Active modules:

- **rookie_project** — Project list and opener (CSV + quickfix)
- **rookie_markdown** — Markdown tools (anchor, linter, slugify)
- **rookie_tag** — Tag editing and searching utilities
- **rookie_retab** — Consistent tab-to-space conversion
- **rookie_gitgraph** — Git graph visualization (requires vim-fugitive)
- **rookie_gitdiff** — Interactive diff between commits (requires vim-fugitive)
- **rookie_clangd** — Generate `compile_commands.json` for clangd

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


**Note:** All commands must be used with their full names. No short aliases are available.

### Setup

The plugin automatically loads all modules. To use the complete environment setup:

```vim9script
" In your vimrc
call rookie_setup.Setup()
```

This will configure your entire Vim environment with all the productivity features, key mappings, and integrations.

---

## Requirements

- `vim-fugitive` for Git graph and diff commands
- Optional: NERDTree for project-tree sync on project open
- Optional: clangd to consume generated `compile_commands.json`

## Troubleshooting

- Git commands fail or `:Git` not found
  - Install `vim-fugitive` and ensure the `:Git` command is available
- Project quickfix shows no items
  - Ensure `.rookie_toys_project.csv` exists; add a project with `:RookieProjectAdd`
- Opening a project didn’t change CWD
  - Verify the path exists; re-add the project if the path changed
- NERDTree didn’t update after opening a project
  - Ensure a NERDTree buffer is open; the plugin runs `:NERDTreeCWD` when available
- `compile_commands.json` missing entries
  - Adjust `g:rookie_toys_clangd_*` patterns to match your file extensions

## License

MIT License — see `LICENSE` for details.
