return function(client, bufnr)
  local lsp_type = require("user.config.lsp_type").lsp_type
  if lsp_type ~= 'coc' then
    if client.server_capabilities.inlayHintProvider then
      local inlayhints_avail, inlayhints = pcall(require, "lsp-inlayhints")
      if inlayhints_avail then inlayhints.on_attach(client, bufnr, _) end
    end
  end
end
