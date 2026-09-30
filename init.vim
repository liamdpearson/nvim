call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-sensible'

Plug 'sphamba/smear-cursor.nvim'

Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'

Plug 'nvim-lua/plenary.nvim'                 " required dependency
Plug 'nvim-telescope/telescope.nvim'

call plug#end()

lua require('smear_cursor').enabled = true

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

nnoremap <leader>tr <cmd>NvimTreeToggle<cr>
nnoremap <leader>vv <cmd>vsplit<cr>
nnoremap <leader>hh <cmd>split<cr>
nnoremap <leader>tt <cmd>botright split \| resize 10 \| terminal<cr>

tnoremap <Esc> <C-\><C-N>

lua << EOF
require("nvim-tree").setup()
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
    	vim.cmd("NvimTreeToggle")
        vim.cmd("botright split | resize 10 | terminal")
    end,
})
EOF
