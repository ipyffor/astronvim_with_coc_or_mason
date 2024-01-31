local utils = require "astrocore"
return {
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "python", "toml" })
      end
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts) opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "ruff" }) end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, "python")
      if not opts.handlers then opts.handlers = {} end
      opts.handlers.python = function() end -- make sure python doesn't get set up by mason-nvim-dap, it's being set up by nvim-dap-python
    end,
  },
  {
    "linux-cultist/venv-selector.nvim",
    -- opts = {
    --   anaconda_base_path = "~/miniconda3",
    --   anaconda_envs_path = "~/miniconda3/envs",
    -- },
    config = function()
      local conda_envs = os.getenv "CONDA_ENVS"
      local conda_base
      if not conda_envs then
        conda_base = "~/miniconda3"
        conda_envs = conda_base .. "/envs"
      end

      function on_venv_changed(venv_path, venv_python) vim.env.VIRTUAL_ENV = venv_path end
      require("venv-selector").setup {
        anaconda_base_path = conda_base,
        anaconda_envs_path = conda_envs,
        changed_venv_hooks = table.insert(
          require("venv-selector.config").default_settings.changed_venv_hooks,
          on_venv_changed
        ),
        enable_debug_output = false,
      }
    end,
    cmd = { "VenvSelect", "VenvSelectCached" },
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = "mfussenegger/nvim-dap",
    ft = "python", -- NOTE: ft: lazy-load on filetype
    config = function(_, opts)
      local path = require("mason-registry").get_package("debugpy"):get_install_path() .. "/venv/bin/python"
      local dap_python = require "dap-python"
      dap_python.setup(path, opts)
    end,
  },
}
