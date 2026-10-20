call plug#begin('~/.local/share/nvim/plugged')

" plug ins
Plug 'tpope/vim-sensible'
Plug 'sphamba/smear-cursor.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-lua/plenary.nvim'                 " required dependency
Plug 'nvim-telescope/telescope.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'mfussenegger/nvim-lint'
Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'main', 'do': ':TSUpdate'}

call plug#end()

" set tab length
set tabstop=4
set shiftwidth=4
set expandtab

" no line wrap
set nowrap

" shortcuts for common commands
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>tr <cmd>NvimTreeToggle<cr>
nnoremap <leader>vv <cmd>vsplit<cr>
nnoremap <leader>hh <cmd>split<cr>
nnoremap <leader>tt <cmd>rightbelow vsplit \| terminal powershell.exe<cr>

" to get back to normal mode inside terminal
tnoremap <Esc> <C-\><C-N>

lua << EOF

require('smear_cursor').setup()

vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin;" .. vim.env.PATH

-- ai generated function
local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Load the default nvim-tree keymaps first
  api.config.mappings.default_on_attach(bufnr)

  -- CUSTOM CD KEYMAPS:
  -- Press '.' on a folder to make it the current working directory
  vim.keymap.set('n', '.', api.tree.change_root_to_node, opts('CD into directory'))
  
  -- Press ',' to go up to the parent folder and make it the current working directory
  vim.keymap.set('n', ',', api.tree.change_root_to_parent, opts('CD to parent directory'))
end

require("nvim-tree").setup({
    git = {
        enable = true,
        ignore = false,
    },
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
        highlight_git = "all",
        highlight_opened_files = "none",
        highlight_modified = "none",
    },
    filters = {
        git_ignored = false,
    },
    auto_reload_on_write = true,
    filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
    },
    on_attach = my_on_attach,
    actions = {
        change_dir = {
            enable = true;
            global = true;
        }
    }
})
-- make git status colors explicit so they show up regardless of colorscheme
local function set_tree_git_hl()
    local groups = {
        NvimTreeGitFileDirtyHL    = "#e5c07b",
        NvimTreeGitFolderDirtyHL  = "#e5c07b",
        NvimTreeGitFileStagedHL   = "#98c379",
        NvimTreeGitFolderStagedHL = "#98c379",
        NvimTreeGitFileNewHL      = "#98c379",
        NvimTreeGitFolderNewHL    = "#98c379",
        NvimTreeGitFileDeletedHL  = "#e06c75",
        NvimTreeGitFolderDeletedHL = "#e06c75",
        NvimTreeGitFileMergeHL    = "#d19a66",
        NvimTreeGitFolderMergeHL  = "#d19a66",
    }
    for name, fg in pairs(groups) do
        vim.api.nvim_set_hl(0, name, { fg = fg })
    end
end
set_tree_git_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_tree_git_hl })

require("mason").setup()

-- jdtls thing to figure out source and project root for java projects written by claude
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
              local data_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. config.root_dir:gsub("[/\\:]", "_")
              return vim.lsp.rpc.start({ "jdtls.cmd", "-data", data_dir }, dispatchers, { env = config.cmd_env })
      end,
      cmd_env = { JAVA_HOME = "C:/Program Files/Java/jdk-25.0.4.1" },
      settings = java_settings,
      init_options = { settings = java_settings },
})
vim.lsp.enable("jdtls")
vim.diagnostic.config({ virtual_text = true,
			update_in_insert = false})

-- commands that run on open
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
    	vim.cmd("NvimTreeToggle")
        vim.cmd("botright split | resize 8 | terminal powershell")
    end,
})

require("nvim-autopairs").setup {}

require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "jdtls" }
})

vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",          -- Activates clang-tidy checks
        "--header-insertion=iwyu",
        "--query-driver=C:/TDM-GCC-64/bin/*"
    },
})

vim.lsp.enable("clangd")

vim.env.CC = 'C:/TDM-GCC-64/bin/gcc.exe'
require('nvim-treesitter').install({ 'c', 'cpp', 'java', 'lua', 'vim', 'vimdoc', 'query' })

EOF
