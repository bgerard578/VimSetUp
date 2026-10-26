" ===== Vim Configuration =====

set nocompatible
filetype plugin indent on
syntax on

set mouse=a
set number
set hidden
set updatetime=300
set signcolumn=yes
set completeopt=menuone,noinsert

" ===== CoC Code Completion =====

" Tab: next suggestion
inoremap <silent><expr> <TAB>
    \ coc#pum#visible() ? coc#pum#next(1) :
    \ coc#refresh()

" Shift+Tab: previous suggestion
inoremap <silent><expr> <S-TAB>
    \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Enter: accept suggestion
inoremap <silent><expr> <CR>
    \ coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" Go to definition
nmap <silent> gd <Plug>(coc-definition)

" Show documentation
nnoremap <silent> K :call CocActionAsync('doHover')<CR>

" ===== Windows-Style Clipboard Shortcuts =====

" Ctrl+C: copy selected text
vnoremap <C-c> "+y

" Ctrl+X: cut selected text
vnoremap <C-x> "+d

" Ctrl+V: paste clipboard
nnoremap <C-v> "+p
inoremap <C-v> <C-r>+
vnoremap <C-v> "+p

" Ctrl+A: select all text in the file
nnoremap <C-a> ggVG

" Ctrl+Z: Undo
nnoremap <C-z> u
inoremap <C-z> <C-o>u

" Backspace: delete selected text
vnoremap <BS> d
