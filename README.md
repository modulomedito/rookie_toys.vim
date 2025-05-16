# rookie\_toys.vim

Powerful rookie toys with various features.

## Prerequisite

Vim which support **vim9script**

## Install

**vim-plug**

```vim9script
Plug 'https://github.com/modulomedito/rookie_clangd.vim'
```

## Features

### rookie\_clangd

This feature will search your current working directory recursively, then generate a "fake"
`compile_commands.json` in the root for clangd tool indexing your code base.

#### Global Variables

You can set the global variable below.

```vim9script
g:rookie_toys_clangd_source_patterns = ['c', 'cpp'] # Source files search pattern
g:rookie_toys_clangd_header_patterns = ['h', 'hpp'] # Header files search pattern
g:rookie_toys_clangd_compiler = 'gcc'               # Any compiler you prefer
g:rookie_toys_clangd_args = ['-ferror-limit=3000']  # Some arguments for clangd
```

#### Commands

Just type command below and enter, the `compile_commands.json` will be generated under your current
workspace. `RkMc` means `Rookie makes compile_commands.json`

```
:RkMc
```
