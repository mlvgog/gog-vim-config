-- ============================================================
-- Neovim Configuration: .NET + Python Development
-- Visual Studio keybinds | Monokai Pro | lazy.nvim
-- ============================================================
-- First launch:  plugins + LSP servers install automatically
--                (requires git, cmake, .NET SDK, Python)
-- :Mason         → install / manage LSP servers & debuggers
-- :Lazy          → manage plugins
-- :checkhealth   → diagnose issues
-- Press <Space>  → see all keybinds (which-key popup)
-- ============================================================
--
-- QUICK-REFERENCE (Visual Studio keybinds)
--   F5            Start / Continue debug
--   Shift+F5      Stop debug
--   F9            Toggle breakpoint
--   Shift+F9      Conditional breakpoint
--   F10           Step over
--   F11           Step into
--   Shift+F11     Step out
--   F12           Go to Definition
--   Shift+F12     Find All References
--   Alt+F12       Hover / Peek Documentation
--   Ctrl+F12      Go to Implementation
--   F2            Rename symbol
--   Ctrl+R, R     Rename symbol (VS chord)
--   Ctrl+.        Code Actions / Quick Fix
--   Ctrl+K, D     Format document
--   Ctrl+K, C     Comment selection
--   Ctrl+K, U     Uncomment selection
--   Ctrl+Shift+F  Find in files (live grep)
--   Ctrl+P        Find files
--   Ctrl+B        Toggle file explorer
--   Ctrl+Tab      Next buffer
--   Ctrl+Shift+Tab Previous buffer
--   Ctrl+F4       Close buffer
-- ============================================================

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ============================================================
-- BOOTSTRAP lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- EDITOR OPTIONS
-- ============================================================
vim.opt.termguicolors  = true
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.cursorline     = true
vim.opt.signcolumn     = "yes"
vim.opt.colorcolumn    = "120"
vim.opt.scrolloff      = 8
vim.opt.sidescrolloff  = 8
vim.opt.wrap           = false
vim.opt.showbreak      = "↪ "
vim.opt.showmatch      = true

vim.opt.expandtab      = true
vim.opt.shiftwidth     = 4
vim.opt.tabstop        = 4
vim.opt.softtabstop    = 4
vim.opt.breakindent    = true

vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.incsearch      = true
vim.opt.hlsearch       = true

vim.opt.clipboard      = "unnamedplus"
vim.opt.undofile       = true
vim.opt.swapfile       = false
vim.opt.backup         = false
vim.opt.writebackup    = false
vim.opt.autoread       = true
vim.opt.updatetime     = 250
-- 400ms timeout: short enough for fast <C-r><C-r> rename chord,
-- long enough not to mis-fire on single <C-r> (redo).
vim.opt.timeoutlen     = 400

vim.opt.completeopt    = { "menuone", "noselect" }
vim.opt.shortmess:append("c")
vim.opt.wildmenu       = true
vim.opt.wildmode       = "longest:full,full"
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.equalalways    = false
vim.opt.laststatus     = 3

vim.opt.list           = true
vim.opt.listchars      = { tab = "→ ", trail = "·", extends = "»", precedes = "«", nbsp = "␣" }

-- Lua files use 2-space indent; everything else uses 4 (good for C#/Python)
vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "lua" },
  callback = function()
    vim.opt_local.shiftwidth  = 2
    vim.opt_local.tabstop     = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Auto-reload files changed on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, { command = "checktime" })

-- Flash yanked region
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

-- ============================================================
-- PLUGINS
-- ============================================================
require("lazy").setup({

  -- ── Colorscheme: Monokai Pro ─────────────────────────────
  {
    "tanvirtin/monokai.nvim",
    lazy     = false,
    priority = 1000,
    config   = function()
      vim.cmd.colorscheme("monokai_pro")
    end,
  },

  -- ── Icons (required by many plugins) ─────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Status line ──────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme            = "auto",
          globalstatus     = true,
          section_separators   = { left = "", right = "" },
          component_separators = { left = "│", right = "│" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ── Buffer line (open files shown as tabs at top) ────────
  {
    "akinsho/bufferline.nvim",
    version      = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require("bufferline").setup({
        options = {
          numbers                 = "ordinal",
          diagnostics             = "nvim_lsp",
          separator_style         = "thin",
          show_buffer_close_icons = true,
          show_close_icon         = false,
          always_show_bufferline  = true,
          offsets = {
            {
              filetype   = "NvimTree",
              text       = "File Explorer",
              highlight  = "Directory",
              separator  = true,
            },
          },
        },
      })
    end,
  },

  -- ── Utility library (required by telescope etc.) ─────────
  { "nvim-lua/plenary.nvim", lazy = true },

  -- ── Telescope: fuzzy finder ───────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    tag          = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- Requires cmake + a C compiler (Visual Studio Build Tools or MinGW)
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
        cond  = function() return vim.fn.executable("cmake") == 1 end,
      },
    },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
              ["<C-u>"] = false,
              ["<C-d>"] = false,
            },
          },
        },
      })
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  -- ── Treesitter: syntax highlighting + smart indent ───────
  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    config = function()
      -- nvim-treesitter v1+ renamed the entry point from 'configs' to the root module
      require("nvim-treesitter").setup({
        ensure_installed = {
          "c_sharp", "python", "lua", "vim", "vimdoc",
          "json", "yaml", "toml", "xml", "markdown",
          "html", "css", "javascript", "typescript", "bash",
        },
        auto_install = true,
        highlight    = { enable = true },
        indent       = { enable = true },
      })
    end,
  },

  -- ── Mason: install LSP servers & debug adapters ──────────
  {
    "williamboman/mason.nvim",
    build  = ":MasonUpdate",
    config = function()
      require("mason").setup({ ui = { border = "rounded" } })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config       = function()
      require("mason-lspconfig").setup({
        -- OmniSharp = .NET/C#,  pyright = Python
        ensure_installed       = { "omnisharp", "pyright" },
        automatic_installation = true,
      })
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    config       = function()
      -- Defer slightly so mason-lspconfig's installations don't collide.
      -- automatic_installation is intentionally omitted: ensure_installed
      -- handles first-time installs; the reactive auto-install was the
      -- source of the "Package is already installing" race condition.
      vim.defer_fn(function()
        require("mason-nvim-dap").setup({
          ensure_installed = { "coreclr", "python" },
          handlers         = {},  -- wire DAP adapters automatically
        })
      end, 500)
    end,
  },

  -- ── LSP configuration ─────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
    },
    config = function()
      -- Diagnostic gutter icons
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        vim.fn.sign_define("DiagnosticSign" .. type,
          { text = icon, texthl = "DiagnosticSign" .. type, numhl = "" })
      end

      vim.diagnostic.config({
        virtual_text  = { spacing = 4, prefix = "●" },
        signs         = true,
        underline     = true,
        severity_sort = true,
        float         = { border = "rounded", source = "always" },
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- ── on_attach: runs when an LSP server connects to a buffer ──
      local on_attach = function(client, bufnr)
        -- Helper: noremap keybind scoped to this buffer
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs,
            { buffer = bufnr, silent = true, noremap = true, desc = desc })
        end
        -- Helper: remap = true so gcc/gc from Comment.nvim chain correctly
        local function rmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs,
            { buffer = bufnr, silent = true, noremap = false, desc = desc })
        end

        -- ── Navigation (Visual Studio) ──────────────────────────
        map("n", "<F12>",   vim.lsp.buf.definition,                         "LSP: Go to Definition (F12)")
        map("n", "<A-F12>", vim.lsp.buf.hover,                              "LSP: Hover / Peek (Alt+F12)")
        map("n", "<C-F12>", vim.lsp.buf.implementation,                     "LSP: Go to Implementation (Ctrl+F12)")
        map("n", "<S-F12>",
          function() require("telescope.builtin").lsp_references() end,     "LSP: Find All References (Shift+F12)")

        -- Vim-native equivalents (reliable in any terminal)
        map("n", "gd",  vim.lsp.buf.definition,                             "LSP: Go to Definition")
        map("n", "gD",  vim.lsp.buf.declaration,                            "LSP: Go to Declaration")
        map("n", "gi",  vim.lsp.buf.implementation,                         "LSP: Go to Implementation")
        map("n", "gr",
          function() require("telescope.builtin").lsp_references() end,     "LSP: References")
        map("n", "gt",  vim.lsp.buf.type_definition,                        "LSP: Type Definition")
        map("n", "K",   vim.lsp.buf.hover,                                  "LSP: Hover Docs")

        -- ── Refactoring ─────────────────────────────────────────
        -- F2              Rename symbol
        -- Ctrl+R, Ctrl+R  Rename (Visual Studio chord).
        --                 Note: single <C-r> (redo) waits timeoutlen ms
        --                 before firing so the chord can be detected.
        -- Ctrl+.          Code Actions / Quick Fix
        map("n", "<F2>",         vim.lsp.buf.rename,      "LSP: Rename (F2)")
        map("n", "<C-r><C-r>",   vim.lsp.buf.rename,      "LSP: Rename (Ctrl+R,R)")
        map("n", "<C-.>",        vim.lsp.buf.code_action, "LSP: Code Actions (Ctrl+.)")
        map("n", "<leader>ca",   vim.lsp.buf.code_action, "LSP: Code Actions")
        map("v", "<leader>ca",   vim.lsp.buf.code_action, "LSP: Code Actions (selection)")

        -- ── Signature Help ───────────────────────────────────────
        map("i", "<C-S-Space>", vim.lsp.buf.signature_help, "LSP: Signature Help")

        -- ── Format Document (Ctrl+K, Ctrl+D in Visual Studio) ───
        map("n", "<C-k><C-d>",
          function() vim.lsp.buf.format({ async = true }) end,              "LSP: Format Document (Ctrl+K,D)")
        map("n", "<leader>lf",
          function() vim.lsp.buf.format({ async = true }) end,              "LSP: Format Document")

        -- ── Commenting (Ctrl+K,C / Ctrl+K,U — Visual Studio) ────
        -- These chain into gcc/gc from Comment.nvim (noremap = false)
        rmap("n", "<C-k><C-c>", "gcc", "Comment Line (Ctrl+K,C)")
        rmap("v", "<C-k><C-c>", "gc",  "Comment Selection (Ctrl+K,C)")
        rmap("n", "<C-k><C-u>", "gcc", "Uncomment Line (Ctrl+K,U)")
        rmap("v", "<C-k><C-u>", "gc",  "Uncomment Selection (Ctrl+K,U)")

        -- ── Diagnostics ──────────────────────────────────────────
        map("n", "[d",         vim.diagnostic.goto_prev,  "LSP: Prev Diagnostic")
        map("n", "]d",         vim.diagnostic.goto_next,  "LSP: Next Diagnostic")
        map("n", "<leader>ld", vim.diagnostic.open_float, "LSP: Show Diagnostic")
        map("n", "<leader>lq", vim.diagnostic.setloclist, "LSP: Diagnostic List")

        -- ── Symbol Search ────────────────────────────────────────
        map("n", "<leader>ls",
          function() require("telescope.builtin").lsp_document_symbols() end,  "LSP: Document Symbols")
        map("n", "<leader>lS",
          function() require("telescope.builtin").lsp_workspace_symbols() end, "LSP: Workspace Symbols")

        -- Highlight all references to the word under cursor
        if client.supports_method("textDocument/documentHighlight") then
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer   = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd("CursorMoved", {
            buffer   = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end

      -- Apply on_attach + capabilities to ALL enabled LSP servers globally.
      -- This is the nvim 0.11+ native API (replaces the deprecated lspconfig framework).
      vim.lsp.config("*", {
        on_attach    = on_attach,
        capabilities = capabilities,
      })

      -- OmniSharp (.NET / C#) — server config sourced from nvim-lspconfig
      -- Requires: .NET SDK installed and in PATH
      vim.lsp.config("omnisharp", {
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports           = true,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
          },
        },
      })

      -- Pyright (Python) — server config sourced from nvim-lspconfig
      -- Requires: Python installed and in PATH
      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode       = "basic",
              autoSearchPaths        = true,
              useLibraryCodeForTypes = true,
              diagnosticMode         = "workspace",
            },
          },
        },
      })

      -- Activate servers — they start automatically when a matching file opens
      vim.lsp.enable({ "omnisharp", "pyright" })
    end,
  },

  -- ── Completion (nvim-cmp) ─────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        version      = "v2.*",
        dependencies = { "rafamadriz/friendly-snippets" },
        config       = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          -- Tab cycles completion items; also expands/jumps snippets
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          {
            { name = "nvim_lsp", priority = 1000 },
            { name = "luasnip",  priority = 750  },
          },
          {
            { name = "buffer",   priority = 500  },
            { name = "path",     priority = 250  },
          }
        ),
        formatting = {
          format = function(entry, item)
            local labels = {
              nvim_lsp = "[LSP]", luasnip = "[Snip]",
              buffer   = "[Buf]", path    = "[Path]",
            }
            item.menu = labels[entry.source.name] or ""
            return item
          end,
        },
      })
    end,
  },

  -- ── Debugging (nvim-dap) ──────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui",        dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap   = require("dap")
      local dapui = require("dapui")

      -- Show variable values inline while stepping
      require("nvim-dap-virtual-text").setup({ commented = true })

      -- Debug UI layout (mirrors VS: variables/breakpoints/stack left, console bottom)
      dapui.setup({
        icons   = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.30 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.25 },
            },
            size     = 45,
            position = "left",
          },
          {
            elements = {
              { id = "repl",    size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size     = 12,
            position = "bottom",
          },
        },
      })

      -- Auto open/close the debug UI on debug session events
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

      -- Python: point nvim-dap-python at the active Python interpreter.
      -- debugpy is installed automatically by mason.
      local py = vim.fn.exepath("python") ~= "" and vim.fn.exepath("python")
              or vim.fn.exepath("python3")
              or "python"
      require("dap-python").setup(py)
      require("dap-python").test_runner = "pytest"

      -- C# / .NET: netcoredbg adapter is wired automatically by mason-nvim-dap.
      -- If the auto-setup doesn't work, uncomment and adjust the path below:
      -- dap.adapters.coreclr = {
      --   type    = "executable",
      --   command = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe",
      --   args    = { "--interpreter=vscode" },
      -- }

      -- Default C# launch configs (only set if mason-nvim-dap didn't set them)
      if not dap.configurations.cs or #dap.configurations.cs == 0 then
        dap.configurations.cs = {
          {
            type    = "coreclr",
            name    = "Launch (C#)",
            request = "launch",
            -- Will prompt for the compiled .dll on each debug start
            program = function()
              return vim.fn.input("Path to .dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
            end,
          },
          {
            type      = "coreclr",
            name      = "Attach to Process (C#)",
            request   = "attach",
            processId = require("dap.utils").pick_process,
          },
        }
      end
    end,
  },

  -- ── File Explorer (Solution Explorer equivalent) ──────────
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      vim.g.loaded_netrw       = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view = { width = 35 },
        renderer = {
          group_empty = true,
          icons = {
            show = { git = true, folder = true, file = true, folder_arrow = true },
          },
        },
        filters             = { dotfiles = false },
        git                 = { enable = true, ignore = false },
        actions             = { open_file = { quit_on_open = false } },
        -- Automatically highlight the tree entry for the active buffer
        update_focused_file = { enable = true, update_root = false },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          -- Load all default nvim-tree mappings first
          api.config.mappings.default_on_attach(bufnr)
          local opts = function(desc)
            return { buffer = bufnr, noremap = true, silent = true, nowait = true, desc = desc }
          end
          -- Override / add a few convenient bindings
          vim.keymap.set("n", "<CR>",  api.node.open.edit,       opts("Open"))
          vim.keymap.set("n", "v",     api.node.open.vertical,   opts("Open: vertical split"))
          vim.keymap.set("n", "s",     api.node.open.horizontal, opts("Open: horizontal split"))
        end,
      })
    end,
  },

  -- ── Autopairs ─────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true })
      -- Integrate with nvim-cmp so accepted completions get paired
      require("cmp").event:on(
        "confirm_done",
        require("nvim-autopairs.completion.cmp").on_confirm_done()
      )
    end,
  },

  -- ── Comments ─────────────────────────────────────────────
  -- gcc  = toggle comment on current line
  -- gc   = toggle comment on visual selection
  -- VS-style Ctrl+K,C / Ctrl+K,U are mapped in on_attach above
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- ── Indent guides ─────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main   = "ibl",
    config = function()
      require("ibl").setup({ indent = { char = "│" } })
    end,
  },

  -- ── Git signs in the gutter ───────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "│" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
          end
          map("]g",          gs.next_hunk,    "Git: Next Hunk")
          map("[g",          gs.prev_hunk,    "Git: Prev Hunk")
          map("<leader>gp",  gs.preview_hunk, "Git: Preview Hunk")
          map("<leader>gb",  gs.blame_line,   "Git: Blame Line")
          map("<leader>gs",  gs.stage_hunk,   "Git: Stage Hunk")
          map("<leader>gr",  gs.reset_hunk,   "Git: Reset Hunk")
          map("<leader>gS",  gs.stage_buffer, "Git: Stage Buffer")
          map("<leader>gd",  gs.diffthis,     "Git: Diff This")
        end,
      })
    end,
  },

  -- ── Trouble: VS-style Error List panel ───────────────────
  -- <leader>xx to open workspace diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require("trouble").setup({})
    end,
  },

  -- ── Which-key: keybind popup on <Space> ──────────────────
  {
    "folke/which-key.nvim",
    event  = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({})
      wk.add({
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find / Files" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>t", group = "Toggle" },
        { "<leader>x", group = "Trouble / Errors" },
      })
    end,
  },

}, {
  ui      = { border = "rounded" },
  checker = { enabled = true, notify = false },
})

-- ============================================================
-- GLOBAL KEYBINDS (non-LSP, not buffer-local)
-- ============================================================
local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- ── Debugging (Visual Studio keybinds) ──────────────────────
map("n", "<F5>",
  function() require("dap").continue() end,                              "Debug: Start/Continue (F5)")
map("n", "<S-F5>",
  function() require("dap").terminate() end,                             "Debug: Stop (Shift+F5)")
map("n", "<C-S-F5>",
  function() require("dap").restart() end,                               "Debug: Restart")
map("n", "<F9>",
  function() require("dap").toggle_breakpoint() end,                     "Debug: Toggle Breakpoint (F9)")
map("n", "<S-F9>", function()
  vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
    if cond then require("dap").set_breakpoint(cond) end
  end)
end,                                                                     "Debug: Conditional Breakpoint (Shift+F9)")
map("n", "<F10>",
  function() require("dap").step_over() end,                             "Debug: Step Over (F10)")
map("n", "<F11>",
  function() require("dap").step_into() end,                             "Debug: Step Into (F11)")
map("n", "<S-F11>",
  function() require("dap").step_out() end,                              "Debug: Step Out (Shift+F11)")
map("n", "<leader>du",
  function() require("dapui").toggle() end,                              "Debug: Toggle UI")
map("n", "<leader>dr",
  function() require("dap").repl.open() end,                             "Debug: Open REPL")
map("n", "<leader>db",
  function() require("dap").toggle_breakpoint() end,                     "Debug: Toggle Breakpoint")

-- ── Find (Telescope) ────────────────────────────────────────
-- Ctrl+P      = Find files (like VS Code / ReSharper)
-- Ctrl+Shift+F = Live grep across project (like VS "Find in Files")
map("n", "<C-p>",
  function() require("telescope.builtin").find_files() end,              "Find Files (Ctrl+P)")
map("n", "<C-S-f>",
  function() require("telescope.builtin").live_grep() end,               "Find in Files (Ctrl+Shift+F)")
map("n", "<leader>ff",
  function() require("telescope.builtin").find_files() end,              "Find Files")
map("n", "<leader>fg",
  function() require("telescope.builtin").live_grep() end,               "Live Grep")
map("n", "<leader>fb",
  function() require("telescope.builtin").buffers() end,                 "Find Buffers")
map("n", "<leader>fh",
  function() require("telescope.builtin").help_tags() end,               "Find Help")
map("n", "<leader>fr",
  function() require("telescope.builtin").oldfiles() end,                "Recent Files")
map("n", "<leader>fd",
  function() require("telescope.builtin").diagnostics() end,             "Find Diagnostics")

-- ── File Explorer (Solution Explorer equivalent) ────────────
-- Ctrl+B mirrors VS's Solution Explorer toggle shortcut
map("n", "<C-b>",      "<cmd>NvimTreeToggle<CR>",    "Toggle Explorer (Ctrl+B)")
map("n", "<leader>fe", "<cmd>NvimTreeToggle<CR>",    "Toggle Explorer")
map("n", "<leader>fE", "<cmd>NvimTreeFindFile<CR>",  "Reveal Current File in Explorer")

-- ── Trouble: Error List ──────────────────────────────────────
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",            "Trouble: Workspace Errors")
map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>","Trouble: Buffer Errors")
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                 "Trouble: Quickfix")

-- ── Buffer Management ────────────────────────────────────────
map("n", "<C-F4>",     "<cmd>bdelete<CR>",                               "Close Buffer (Ctrl+F4)")
map("n", "<leader>bd", "<cmd>bdelete<CR>",                               "Close Buffer")
map("n", "<C-Tab>",    "<cmd>BufferLineCycleNext<CR>",                   "Next Buffer (Ctrl+Tab)")
map("n", "<C-S-Tab>",  "<cmd>BufferLineCyclePrev<CR>",                   "Prev Buffer (Ctrl+Shift+Tab)")
-- Alt+1..9 jump directly to a numbered buffer (like VS Ctrl+1..9 or VS Code)
for i = 1, 9 do
  map("n", "<A-" .. i .. ">",
    "<cmd>BufferLineGoToBuffer " .. i .. "<CR>",                         "Go to Buffer " .. i)
end

-- ── Window Navigation ────────────────────────────────────────
-- Use Alt+hjkl so Ctrl+K stays free for VS-style Ctrl+K,x chords
map("n", "<A-h>", "<C-w>h", "Window: Move Left")
map("n", "<A-j>", "<C-w>j", "Window: Move Down")
map("n", "<A-k>", "<C-w>k", "Window: Move Up")
map("n", "<A-l>", "<C-w>l", "Window: Move Right")

-- ── Misc ─────────────────────────────────────────────────────
map("n", "<Esc>",      "<cmd>nohlsearch<CR>",    "Clear Search Highlight")
map("n", "<leader>jq", ":%!jq .<CR>",            "Format JSON (requires jq)")
map("n", "<leader>jc", ":%!jq -c .<CR>",         "Compact JSON (requires jq)")

-- Toggle auto-format on save per buffer (default: OFF)
-- Turn on with <leader>tf if you want format-on-save behaviour
vim.keymap.set("n", "<leader>tf", function()
  vim.b.autoformat = not (vim.b.autoformat == true)
  vim.notify("Auto-format on save: " .. (vim.b.autoformat and "ON" or "OFF"))
end, { desc = "Toggle Auto-format on Save" })
