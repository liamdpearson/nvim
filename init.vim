call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-sensible'

Plug 'sphamba/smear-cursor.nvim'

Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'

Plug 'nvim-lua/plenary.nvim'                 " required dependency
Plug 'nvim-telescope/telescope.nvim'

Plug 'neovim/nvim-lspconfig'

Plug 'williamboman/mason.nvim'

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
require("nvim-tree").setup({
  renderer = {
    icons = {
      show = {
        file = false,
        folder = false,
        folder_arrow = false,
        git = false,
        modified = false,
        diagnostics = false,
        bookmarks = false,
        hidden = false,
      },
    },
  },
})
require("mason").setup()

local java_settings = { java = { project = { sourcePaths = { "." } } } }

vim.lsp.config("jdtls", {
      -- project root = source root, worked out from the file's own package line
      root_dir = function(bufnr, on_dir)
              local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
              for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 200, false)) do
                      local pkg = line:match("^%s*package%s+([%w_.]+)%s*;")
                      if pkg then
                              for _ in pkg:gmatch("[^.]+") do
                                      dir = vim.fs.dirname(dir)
                              end
                              break
                      end
              end
              on_dir(dir)
      end,
      -- one jdtls cache per source root, named after its full path
      cmd = function(dispatchers, config)
              local data_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. config.root_dir:gsub("/", "_")
              return vim.lsp.rpc.start({ "jdtls", "-data", data_dir }, dispatchers, { env = config.cmd_env })
      end,
      cmd_env = { JAVA_HOME = "/usr/lib/jvm/java-25-openjdk-amd64" },
      settings = java_settings,
      init_options = { settings = java_settings },
})
vim.lsp.enable("jdtls")
vim.diagnostic.config({ virtual_text = true,
			update_in_insert = false})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
    	vim.cmd("NvimTreeToggle")
        vim.cmd("botright split | resize 10 | terminal")
    end,
})
EOF
