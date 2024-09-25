vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

require("render-markdown").setup {
  latex_converter = '${pkgs.python312Packages.pylatexenc}/bin/latex2text',
}

local otter = require'otter'
otter.setup{}
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = {"*.md"},
  callback = function() otter.activate({'python', 'rust', 'c', 'lua', 'bash' }, true, true, nil) end,
})
vim.filetype.add({
  extension = {
    mdx = "markdown",
  }
})

require("onedark").setup {
    style = "deep",
    highlights = {
        ["@lsp.type.comment"] = {fg = '#77B767'},
        ["@comment.documentation.rust"] = {fg = '#77B767'},
        ["@comment.documentation"] = {fg = '#77B767'},
        ["@comment"] = {fg = '#426639'}
    }
}
require("onedark").load()

local cmp = require("cmp")
cmp.setup {
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    view = {
      docs = {
        auto_open = false
      }
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ['<CR>'] = cmp.mapping.confirm({ select = true }),

        ['<C-g>'] = function()
          if cmp.visible_docs() then
            cmp.close_docs()
          else
            cmp.open_docs()
          end
        end
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = "otter" },
        { name = 'path' },
        { name = 'vsnip' },
        { name = 'spell' },
    }, {
        { name = 'buffer' },
    }),
    comparators = {
      -- compare.score_offset, -- not good at all
      cmp.config.compare.locality,
      cmp.config.compare.recently_used,
      cmp.config.compare.score,
      cmp.config.compare.offset,
      cmp.config.compare.order,
    },
}

-- key mapping
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local builtin = require('telescope.builtin')
  
-- comment
vim.keymap.set("n", "<leader>c", ":lua require('Comment.api').toggle.linewise.current()<CR> j", { remap = true })
vim.keymap.set("v", "<leader>c", ":lua require('Comment.api').toggle.blockwise.current()<CR> j", { remap = true })

-- indent and dedent using tab/shift-ta
vim.keymap.set("n", "<tab>", ">>_")
vim.keymap.set("n", "<s-tab>", "<<_")
vim.keymap.set("i", "<s-tab>", "<c-d>")
vim.keymap.set("v", "<Tab>", ">gv")
vim.keymap.set("v", "<S-Tab>", "<gv")

vim.keymap.set('n', 'gr', builtin.lsp_references, {})
vim.keymap.set('n', 'gd', builtin.lsp_definitions, {})
vim.keymap.set('n', 'gi', builtin.lsp_implementations, {})
vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, {})

-- format on wq and x and replace X, W and Q with x, w and q
vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]]
vim.cmd [[cabbrev x execute "Format sync" <bar> x]]
vim.cmd [[cnoreabbrev W w]]
vim.cmd [[cnoreabbrev X execute "Format sync" <bar> x]]
vim.cmd [[cnoreabbrev Q q]]
vim.cmd [[nnoremap ; :]]

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>s', "<cmd>vertical sb<cr>", {})
vim.keymap.set('n', '<leader><leader>', builtin.find_files, {})
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
vim.keymap.set('n', '<leader>h', builtin.search_history, {})
vim.keymap.set('n', '<leader>d', "<cmd>Telescope diagnostics bufnr=0<cr>", {})
vim.keymap.set('n', '<leader>ad', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>em', "<cmd>RustLsp expandMacro<cr>")
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)

vim.keymap.set("n", "<leader>x", require("telescope.builtin").resume, {
  noremap = true,
  silent = true,
  desc = "Resume",
})

local gitsigns = require('gitsigns')
vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk)
vim.keymap.set('n', '<leader>gd', gitsigns.diffthis)

vim.keymap.set({'o', 'x'}, 'ig', ':<C-U>Gitsigns select_hunk<CR>')
vim.keymap.set('n', 't', ':Neotree toggle<CR>')

-- ============ files and directories ==============

-- don't change the directory when a file is opened
-- to work more like an IDE
vim.opt.autochdir = false

-- ============ tabs and indentation ==============
-- automatically indent the next line to the same depth as the current line
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
-- backspace across lines
vim.opt.backspace = { "indent", "eol", "start" }

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- ============ line numbers ==============
-- set number,relativenumber
vim.opt.number = true
vim.opt.relativenumber = true

-- ============ history ==============
vim.cmd([[
  set undodir=~/.vimdid
  set undofile
]])

vim.opt.undofile = true

-- ============ miscelaneous ==============
vim.opt.belloff = "all"

-- show (usually) hidden characters
vim.opt.list = true
vim.opt.listchars = {
  nbsp = "¬",
  extends = "»",
  precedes = "«",
  trail = "·",
  tab = ">-",
}

-- paste and yank use global system clipboard
vim.opt.clipboard = "unnamedplus"

-- show partial commands entered in the status line
-- (like show "da" when typing "daw")
vim.opt.showcmd = true
vim.opt.mouse = "a"

vim.opt.modeline = true

-- highlight the line with the cursor on it
vim.opt.cursorline = true

-- enable spell checking (todo: plugin?)
vim.opt.spell = false

vim.opt.wrap = false

-- better search
vim.cmd([[
  " Better search
  set incsearch
  set ignorecase
  set smartcase
  set gdefault

  nnoremap <silent> n n:call BlinkNextMatch()<CR>
  nnoremap <silent> N N:call BlinkNextMatch()<CR>

  function! BlinkNextMatch() abort
    highlight JustMatched ctermfg=white ctermbg=magenta cterm=bold

    let pat = '\c\%#' . @/
    let id = matchadd('JustMatched', pat)
    redraw

    exec 'sleep 150m'
    call matchdelete(id)
    redraw
  endfunction

  nnoremap <silent> <Space> :silent noh<Bar>echo<CR>
  nnoremap <silent> <Esc> :silent noh<Bar>echo<CR>

  nnoremap <silent> n nzz
  nnoremap <silent> N Nzz
  nnoremap <silent> * *zz
  nnoremap <silent> # #zz
  nnoremap <silent> g* g*zz

  " very magic by default
  nnoremap ? ?\v
  nnoremap / /\v
  cnoremap %s/ %sm/
]])

vim.cmd([[
  inoremap <silent> <F1> <CMD>FloatermToggle<CR>
  nnoremap <silent> <F1> <CMD>FloatermToggle<CR>
  tnoremap <silent> <F1> <C-\><C-n><CMD>FloatermToggle<CR>
]])

vim.cmd([[
    let g:suda_smart_edit = 1
    filetype plugin indent on
]])


-- multicursor
vim.g.VM_default_mappings = 1
vim.g.VM_reselect_first = 1
vim.g.VM_notify_previously_selected = 1
vim.g.VM_theme = "iceblue"

