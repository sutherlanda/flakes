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
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

vim.o.completeopt = 'menuone,noselect'
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
  capabilities = capabilities
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

nvim_lsp.tsserver.setup({
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false

    local ts_utils = require('nvim-lsp-ts-utils')
    ts_utils.setup({
      eslint_bin = "eslint_d",
      eslint_enable_diagnostics = true,
      eslint_enable_code_actions = true,
      enable_formatting = true,
      formatter = "prettier"
    })
    ts_utils.setup_client(client)
    on_attach(client, bufnr)
  end,
  capabilities = capabilities
})

require('null-ls').setup({
  on_attach = on_attach,
  sources = {
    require('null-ls').builtins.formatting.prettier.with({
      command = '.yarn/sdks/prettier/index.js'
    })
  }
})

nvim_lsp.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities
})

vim.cmd [[
" Decode URI encoded characters
function! DecodeURI(uri)
    return substitute(a:uri, '%\([a-fA-F0-9][a-fA-F0-9]\)', '\=nr2char("0x" . submatch(1))', "g")
endfunction

" Attempt to clear non-focused buffers with matching name
function! ClearDuplicateBuffers(uri)
    " if our filename has URI encoded characters
    if DecodeURI(a:uri) !=# a:uri
        " wipeout buffer with URI decoded name - can print error if buffer in focus
        sil! exe "bwipeout " . fnameescape(DecodeURI(a:uri))
        " change the name of the current buffer to the URI decoded name
        exe "keepalt file " . fnameescape(DecodeURI(a:uri))
        " ensure we don't have any open buffer matching non-URI decoded name
        sil! exe "bwipeout " . fnameescape(a:uri)
    endif
endfunction

function! RzipOverride()
    " Disable vim-rzip's autocommands
    autocmd! zip BufReadCmd   zipfile:*,zipfile:*/*
    exe "au! zip BufReadCmd ".g:zipPlugin_ext

    " order is important here, setup name of new buffer correctly then fallback to vim-rzip's handling
    autocmd zip BufReadCmd   zipfile:*  call ClearDuplicateBuffers(expand("<afile>"))
    autocmd zip BufReadCmd   zipfile:*  call rzip#Read(DecodeURI(expand("<afile>")), 1)

    if has("unix")
        autocmd zip BufReadCmd   zipfile:*/*  call ClearDuplicateBuffers(expand("<afile>"))
        autocmd zip BufReadCmd   zipfile:*/*  call rzip#Read(DecodeURI(expand("<afile>")), 1)
    endif

    exe "au zip BufReadCmd ".g:zipPlugin_ext."  call rzip#Browse(DecodeURI(expand('<afile>')))"
endfunction

autocmd VimEnter * call RzipOverride()
]]
