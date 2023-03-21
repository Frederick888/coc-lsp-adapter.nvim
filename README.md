# Project Status: Experimental

This project was created only to allow [nvim-jdtls][1] to leverage
[coc.nvim][2] and has only been tested in this scenario.


# Description

'Polyfills' [`vim.lsp.client`][3] calls with coc.nvim LSP client. For
example, it intercepts `vim.lsp.get_active_clients()` and returns a
table of (somewhat) native-client-compatible clients if the native API
returned no clients.

These polyfilled clients then redirect calls like `request()`,
`request_async()`, etc., to their coc.nvim counterparts.


# Configuration

```vim
Plug 'Frederick888/coc-lsp-adapter.nvim'
Plug 'mfussenegger/nvim-dap'
let g:nvim_jdtls = 1
Plug 'mfussenegger/nvim-jdtls'
```

```lua
M = {}

M.coc_dap_initialised = false
M.coc_dap_timer = nil
function M.coc_dap_initialise()
  if M.coc_dap_initialised or vim.g.coc_service_initialized ~= 1 then
    return
  end

  require('coc-lsp-adapter')
  local clients = vim.lsp.get_active_clients()
  if vim.tbl_count(clients) == 0 then
    return
  end

  for _, client in pairs(clients) do
    if client.name == 'java' then
      require('jdtls').setup_dap({ hotcodereplace = 'auto' })
      require('jdtls.dap').setup_dap_main_class_configs()
      vim.notify('Done setting up nvim-dap and coc-java')
    end
  end

  M.coc_dap_initialised = true
  vim.fn.timer_stop(M.coc_dap_timer)
end

M.coc_dap_timer = vim.fn.timer_start(1000, M.coc_dap_initialise, {
  ['repeat'] = -1,
})

return M
```


# Contributions

This is an experimental project and I currently do not plan to implement
any new features. Contributions are welcome if they are maintainable.


[1]: https://github.com/mfussenegger/nvim-jdtls
[2]: https://github.com/neoclide/coc.nvim
[3]: https://neovim.io/doc/user/lsp.html#vim.lsp.client
