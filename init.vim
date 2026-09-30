call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-sensible'

Plug 'sphamba/smear-cursor.nvim'

Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'

Plug 'nvim-lua/plenary.nvim'                 " required dependency
Plug 'nvim-telescope/telescope.nvim'

call plug#end()

lua require('smear_cursor').enabled = true
lua << EOF
require("nvim-tree").setup()
EOF
