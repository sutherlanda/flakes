-- Executed when language server has been attached.
local opts = { noremap = true, silent = true }
local on_attach = function(client, bufnr)

  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Customize diagnostic handling.
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        underline = true,
      }
    )

  -- Customize the LSP diagnostic gutter signs
  local signs = { Error = ">>", Warn = ">", Hint = "*", Info = "*" }
  for type, icon in pairs(signs) do
    local name = "DiagnosticSign" .. type
    vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
  end

  -- Format on save.
  vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.formatting_sync()]]

  -- Set up language server keybindings.
  -- Goto definition/declaration
  buf_set_keymap('n', '<leader>ag', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<leader>aG', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)

  -- References
  buf_set_keymap('n', '<leader>ar', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

  -- Hover
  buf_set_keymap('n', '<leader>ah', '<cmd>lua vim.lsp.buf.hover({focusable=false})<CR>', opts)

  -- Rename
  buf_set_keymap('n', '<leader>an', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

  -- Diagnostics
  buf_set_keymap('n', '<C-j>', '<cmd>lua vim.diagnostic.goto_next({enable_popup=false})<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.diagnostic.goto_prev({enable_popup=false})<CR>', opts)
  buf_set_keymap('n', '<leader>ak', '<cmd>lua vim.diagnostic.show_line_diagnostics({focusable=false})<CR>', opts)

  -- Diagnostics in preview window
  buf_set_keymap('n', '<leader>ad', '<cmd>lua PrintDiagnostics()<CR>', opts)

  -- Location list
  buf_set_keymap('n', '<leader>lo', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<leader>lc', '<cmd>lclose<CR>', opts)
  buf_set_keymap('n', '<leader>lp', '<cmd>lprevious<CR>', opts)
  buf_set_keymap('n', '<leader>ln', '<cmd>lnext<CR>', opts)

  -- Quickfix window
  buf_set_keymap('n', '<leader>qo', '<cmd>copen<CR>', opts)
  buf_set_keymap('n', '<leader>qc', '<cmd>cclose<CR>', opts)
  buf_set_keymap('n', '<leader>qp', '<cmd>cprevious<CR>', opts)
  buf_set_keymap('n', '<leader>qn', '<cmd>cnext<CR>', opts)

  -- Format
  buf_set_keymap('n', '<leader>af', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end


-- Print the diagnostics under the cursor to the Preview Window
function PrintDiagnostics(opts, bufnr, line_nr, client_id)
  opts = opts or {}
  bufnr = bufnr or 0
  line_nr = line_nr or (vim.api.nvim_win_get_cursor(bufnr)[1] - 1)

  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, line_nr, opts, client_id)
  if vim.tbl_isempty(line_diagnostics) then return end

  local lines = {}
  for i, diagnostic in ipairs(line_diagnostics) do
    local str = diagnostic.message
    for s in str:gmatch("[^\r\n]+") do
      table.insert(lines, s)
    end
  end
  ShowInPreview(lines)
end

-- Opens the Preview Window and displays the given diagnostic table.
function ShowInPreview(lines)
  vim.cmd([[
    pclose
    keepalt new +setlocal\ previewwindow|setlocal\ buftype=nofile|setlocal\ noswapfile|setlocal\ wrap [Document]
    setl bufhidden=wipe
    setl nobuflisted
    setl nospell
    exe 'setl filetype=text'
    setl conceallevel=0
    setl nofoldenable
  ]])
  vim.api.nvim_buf_set_lines(0, 0, -1, 0, lines)
  vim.cmd('exe "normal! z" .' .. #lines .. '. "\\<cr>"')
  vim.cmd([[
    exe "normal! gg"
    wincmd p
  ]])
end

-- Autocomplete and snippet configuration

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

vim.o.completeopt = 'menuone,noselect,noinsert'
local luasnip = require 'luasnip'

local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- Load language servers and override on_attach.
local nvim_lsp = require('lspconfig')

nvim_lsp.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  checkOnSave = {
    command = "clippy"
  }
})

nvim_lsp.hls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "haskell-language-server-wrapper", "--lsp" }
})

nvim_lsp.rnix.setup({
  on_attach = on_attach,
  capabilities = capabilities
})

nvim_lsp.bashls.setup({
  on_attach = on_attach,
  capabilities = capabilities
})

nvim_lsp.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities
})

nvim_lsp.tsserver.setup({
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
  },
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities
})

local null_ls = require('null-ls')
null_ls.setup({
  debug = true,
  on_attach = on_attach,
  sources = {
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.formatting.autopep8,
    null_ls.builtins.diagnostics.eslint_d
  }
})

nvim_lsp.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities
})
