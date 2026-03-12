-- Global statusline (Neovim 0.7+)
vim.o.laststatus = 3

-- Always show absolute path
vim.o.statusline = table.concat({
  "%F",                -- full file path
  "%m%r%h%w",          -- flags: modified/readonly/help/preview
  "%=",                -- right align after this
  "%y",                -- filetype
  " [%{&ff}]",         -- fileformat
  " [%{&fenc!=''?&fenc:&enc}]", -- encoding (fallback to &enc)
  " %p%%",             -- percentage through file
  " %l:%c",            -- line:column
})
-- Set colorscheme to habamax
vim.cmd.colorscheme("habamax")

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Undo history across sessions
vim.opt.undofile = true

-- Case-insensitive search unless uppercase used
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Incremental search + highlight
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Mouse support (helpful for data inspection)
vim.opt.mouse = "a"

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- Keep indentation when wrapping lines
vim.opt.breakindent = true

-- Show invisible characters
vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",
  trail = "·",
  extends = "»",
  precedes = "«",
  nbsp = "␣",
}

vim.opt.number = true

vim.opt.wrap = true
vim.opt.linebreak = true     -- wrap at word boundaries
vim.opt.showbreak = "↪ "

-- Keep context around cursor
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Smooth horizontal scrolling
vim.opt.sidescroll = 1

-- Disable swapfile for temp/data files
vim.opt.swapfile = false

-- Enable backups (but keep them out of the way)
vim.opt.backup = false
vim.opt.writebackup = false

-- Auto-reload files changed on disk
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
})

-- Open splits in intuitive directions
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Resize splits more naturally
vim.opt.equalalways = false

vim.opt.completeopt = { "menuone", "noselect" }

-- Trigger completion faster
vim.opt.updatetime = 250

-- Pretty-print JSON (jq must be installed)
vim.keymap.set("n", "<leader>jq", ":%!jq .<CR>", { desc = "Format JSON" })

-- Compact JSON
vim.keymap.set("n", "<leader>jc", ":%!jq -c .<CR>", { desc = "Compact JSON" })

-- Highlight current line
vim.opt.cursorline = true

-- Show matching brackets
vim.opt.showmatch = true

-- Shorter messages, less noise
vim.opt.shortmess:append("c")

-- Always show statusline
vim.opt.laststatus = 3

-- Better command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"


vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
