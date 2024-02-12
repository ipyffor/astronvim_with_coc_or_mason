return {
  {
    "astronvim/astrolsp",
    ---@type astrolspopts
    opts = {
      features = {
        -- configuration table of features provided by astrolsp
        autoformat = false, -- enable or disable auto formatting on start
        codelens = true, -- enable/disable codelens refresh on start
        lsp_handlers = true, -- enable/disable setting of lsp_handlers
        semantic_tokens = true, -- enable/disable semantic token highlighting
        inlay_hints = false,
        diagnostics_mode = 3,
      },
      -- configuration options for controlling formatting with language servers
      formatting = {
        -- control auto formatting on save
        format_on_save = false,
        -- disable formatting capabilities for specific language servers
        disabled = {},
        -- default format timeout
        timeout_ms = 600000,
      },
      capabilities = {
        workspace = {
          didchangewatchedfiles = { dynamicregistration = true },
        },
      },
      diagnostics = {
        underline = true,
        virtual_text = {
          spacing = 5,
          severity_limit = "warn",
          severity = {
            min = vim.diagnostic.severity.warn,
          },
        },
        signs = {
          severity = {
            min = vim.diagnostic.severity.warn,
          },
        },
        update_in_insert = false,
      },
      -- mappings to be set up on attaching of a language server
      mappings = {
        n = {
          gl = { function() vim.diagnostic.open_float() end, desc = "hover diagnostics" },
        },
        i = {
          ["<c-l>"] = {
            function() vim.lsp.buf.signature_help() end,
            desc = "signature help",
            cond = "textdocument/signaturehelp",
          },
        },
      },
    },
  },

  {
    "ray-x/lsp_signature.nvim",
    config = function()
      local cfg = {
        bind = true,
        toggle_key = nil,
        floating_window = true,
        floating_window_above_cur_line = true,
        hint_enable = true,
        fix_pos = false,
        -- floating_window_above_first = true,
        -- log_path = vim.fn.expand "$HOME" .. "/tmp/sig.log",
        debug = true,
        hi_parameter = "Search",
        wrap = true,
        zindex = 200,
        timer_interval = 100,
        extra_trigger_chars = {},
        handler_opts = {
          border = "single", -- "shadow", --{"╭", "─" ,"╮", "│", "╯", "─", "╰", "│" },
        },
      }

      require("lsp_signature").on_attach(cfg)
      require("lsp_signature").setup()
    end,
  },
}
