local system = vim.loop.os_uname().sysname
local is_available = require("astrocore").is_available
local M = {}
local pluginKeys = {}
-- nvim-cmp 自动补全
pluginKeys.cmp = function(cmp)
  local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
  end
  local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
  end
  return {
    -- 出现补全

    ---- 自定义代码段跳转到下一个参数
    --["<C-l>"] = cmp.mapping(function(_)
    --if vim.fn["vsnip#available"](1) == 1 then
    --feedkey("<Plug>(vsnip-expand-or-jump)", "")
    --end
    --end, {"i", "s"}),

    ---- 自定义代码段跳转到上一个参数
    --["<C-h>"] = cmp.mapping(function()
    --if vim.fn["vsnip#jumpable"](-1) == 1 then
    --feedkey("<Plug>(vsnip-jump-prev)", "")
    --end
    --end, {"i", "s"}),

    -- Super Tab
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
        -- elseif vim.fn["vsnip#available"](1) == 1 then
        --     feedkey("<Plug>(vsnip-expand-or-jump)", "")
        -- elseif has_words_befo`
      else
        fallback()         -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require("luasnip").jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
        -- elseif vim.fn["vsnip#jumpable"](-1) == 1 then
        -- feedkey("<Plug>(vsnip-jump-prev)", "")
      else
        fallback()
      end
    end, { "i", "s" }),
    -- end of super Tab

    ["<A-.>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    -- 取消
    ["<A-,>"] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    -- 上一个
    ["<A-k>"] = cmp.mapping.select_prev_item(),
    -- 下一个
    ["<A-j>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
      else
        cmp.complete()
      end
    end, { "i", "s" })
    ,
    -- 确认
    ["<CR>"] = cmp.mapping.confirm({
      select = true,
      behavior = cmp.ConfirmBehavior.Replace,
    }),
    -- 如果窗口内容太多，可以滚动
    -- ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    -- ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    -- ["<C-p>"] = cmp.config.disable,
    -- ["<C-n>"] = cmp.config.disable
  }
end

pluginKeys.cmp_cmdline = function(cmp, default_mappings)
  -- require("utils").print_r(default_mappings)
  -- 禁用补全选择与历史命令冲突，默认用tab选择
  -- 大写P, table里小写认为不同的键，虽然按键是一样的，因此用table传递快捷键注意大小写一致
  default_mappings["<C-P>"] = cmp.mapping(function(fallback)
    fallback()
    -- previous history
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Up>', true, true, true), 'c', true)
  end, { "c" })
  -- next history
  default_mappings["<C-N>"] = cmp.mapping(function(fallback)
    fallback()
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down>', true, true, true), 'c', true)
  end, { "c" })
  -- require("utils").print_r(default_mappings)
  return default_mappings
end

M.pluginKeys = pluginKeys

function M.mappings(maps)
  maps.n["<Leader>n"] = false

  maps.n.n = { require("utils").better_search "n", desc = "Next search" }
  maps.n.N = { require("utils").better_search "N", desc = "Previous search" }

  maps.v["K"] = { ":move '<-2<CR>gv-gv", desc = "Move line up", silent = true }
  maps.v["J"] = { ":move '>+1<CR>gv-gv", desc = "Move line down", silent = true }

  maps.i["<C-Enter>"] = { "<esc>o", desc = "jump new line", silent = true }
  maps.i["<C-s>"] = { "<esc>:w<cr>a", desc = "Save file", silent = true }

  maps.n["<Leader>wo"] = { "<C-w>o", desc = "Close other screen" }

  -- windows 分屏快捷键
  maps.n["sv"] = { ":vsp<CR>", desc = "Split vertically", silent = true }
  maps.n["sh"] = { ":sp<CR>", desc = "Split horizontally", silent = true }

  -- 关闭当前
  maps.n["sc"] = { "<C-w>c", desc = "Close current", silent = true }

  -- 关闭其他
  maps.n["so"] = { "<C-w>o", desc = "Close others", silent = true }

  -- Alt + hjkl  窗口之间跳转
  maps.n["<A-h>"] = { "<C-w>h", desc = "Jump to left window", silent = true }
  maps.n["<A-j>"] = { "<C-w>j", desc = "Jump to bottom window", silent = true }
  maps.n["<A-k>"] = { "<C-w>k", desc = "Jump to top window", silent = true }
  maps.n["<A-l>"] = { "<C-w>l", desc = "Jump to down window", silent = true }

  -- 左右比例控制
  maps.n["<C-Left>"] = { ":vertical resize -2<CR>", desc = "Decrease width", silent = true }
  maps.n["<C-Right>"] = { ":vertical resize +2<CR>", desc = "Increase width", silent = true }
  -- maps.n["s,"] = { ":vertical resize -20<CR>", desc = "Decrease height", silent = true }
  -- maps.n["s."] = { ":vertical resize +20<CR>", desc = "opt", silent = true }
  -- 上下比例
  -- maps.n["sj"] = { ":resize +10<CR>", desc = "opt", silent = true }
  -- maps.n["sk"] = { ":resize -10<CR>", desc = "opt", silent = true }
  maps.n["<C-Down>"] = { ":resize +2<CR>", desc = "Increase height", silent = true }
  maps.n["<C-Up>"] = { ":resize -2<CR>", desc = "Decrease height", silent = true }
  -- 等比例
  maps.n["s="] = { "<C-w>=", desc = "Balance window", silent = true }

  -- Terminal相关
  -- maps.n["<Leader>t"] = { ":sp | terminal<CR>", desc = "terminal vertical", silent = true }
  -- maps.n["<Leader>vt"] = { ":vsp | terminal<CR>", desc = "termial horizontal", silent = true }
  maps.t["<Esc>"] = { "<C-\\><C-n>", silent = true }
  maps.t["<A-h>"] = { [[ <C-\><C-N><C-w>h ]], silent = true }
  maps.t["<A-j>"] = { [[ <C-\><C-N><C-w>j ]], silent = true }
  maps.t["<A-k>"] = { [[ <C-\><C-N><C-w>k ]], silent = true }
  maps.t["<A-l>"] = { [[ <C-\><C-N><C-w>l ]], silent = true }

  -- -- visual模式下缩进代码
  -- maps.v["<"] = { "<gv", silent = true }
  -- maps.v[">"] = { ">gv", silent = true }
  -- -- 上下移动选中文本
  -- maps.v["J"] = { ":move '>+1<CR>gv-gv", silent = true }
  -- maps.v["K"] = { ":move '<-2<CR>gv-gv", silent = true }


  -- 上下滚动浏览
  -- maps.n["<C-j>"] = { "4j", silent = true }
  -- maps.n["<C-k>"] = { "4k", silent = true }
  -- -- ctrl u / ctrl + d  只移动9行，默认移动半屏
  -- maps.n["<C-u>"] = { "9k", silent = true }
  -- maps.n["<C-d>"] = { "9j", silent = true }

  -- 在visual 模式里粘贴不要复制
  maps.v["p"] = { '"_dP', silent = true }

  -- insert 模式下，移动一个字符
  maps.i["<C-h>"] = { "<ESC>hi", silent = true }
  maps.i["<C-l>"] = { "<ESC>la", silent = true }


  -- nvim-tree
  maps.n["<A-m>"] = { ":Neotree toggle<CR>", silent = true }
  maps.n["<Leader>m"] = { ":Neotree toggle<CR>", silent = true }


  -- bufferline
  -- 左右Tab切换
  maps.n["<C-h>"] = { ":BufferLineCyclePrev<CR>", silent = true }
  maps.n["<C-l>"] = { ":BufferLineCycleNext<CR>", silent = true }
  -- 关闭
  --"moll/vim-bbye"
  maps.n["<C-w>"] = { ":Bdelete!<CR>", silent = true }
  maps.n["<Leader>bl"] = { ":BufferLineCloseRight<CR>", silent = true }
  maps.n["<Leader>bh"] = { ":BufferLineCloseLeft<CR>", silent = true }
  maps.n["<Leader>bc"] = { ":BufferLinePickClose<CR>", silent = true }

  if vim.g.neovide then
    if system == "Darwin" then
      vim.g.neovide_input_use_logo = 1 -- enable use of the logo (cmd) key
      -- Save
      maps.n["<D-s>"] = ":w<CR>"
      -- Paste normal mode
      maps.n["<D-v>"] = '"+P'
      -- Copy
      maps.v["<D-c>"] = '"+y'
      -- Paste visual mode
      maps.v["<D-v>"] = '"+P'
      -- Paste command mode
      maps.c["<D-v>"] = "<C-R>+"
      -- Paste insert mode
      maps.i["<D-v>"] = '<esc>"+pli'
    end
  end

  -- telescope plugin mappings
  if is_available "telescope.nvim" then
    maps.v["<Leader>f"] = { desc = "󰍉 Find" }

    -- Telescope
    -- 查找文件
    maps.n["<Leader>fp"] = { ":Telescope find_files<CR>", desc = "Find files", silent = true }
    maps.n["<Leader>fl"] = {
      ':lua require("telescope.builtin")' ..
      '.find_files({cwd = vim.fs.normalize("/")})<CR>',
      desc = "Find files /",
      silent = true
    }
    maps.n["<Leader>ff"] = { ":Telescope file_browser<CR>", desc = "Telescope file_browser", silent = true }
    maps.n["<Leader>fP"] = { ":Telescope media_files<CR>", desc = "Telescope media_files", silent = true }
    -- 全局搜索
    maps.n["<Leader>sp"] = { ":Telescope live_grep<CR>", desc = "Telescope live_grep", silent = true }
    maps.n["<Leader>ss"] = {
      ':lua require("telescope.builtin")' ..
      '.current_buffer_fuzzy_find({results_ts_highlight = false})<CR>',
      desc = "Search in current buffer",
      silent = true
    }
    maps.n["<Leader>fs"] = { "<esc>:w<cr>", desc = "Save file", silent = true }
    -- maps.n["<Leader>ff"] = { ":lua require('telescope.builtin').find_files( { cwd = vim.fn.expand('%:p:h') })<cr>", desc =
    -- "Find files" }
    maps.n["<Leader>fT"] = { "<cmd>TodoTelescope<cr>", desc = "Find TODOs" }
    maps.n["<Leader>mm"] = { ":Telescope notify<cr>", desc = "View notify history" }
    maps.n["<Leader>fr"] = { ":Telescope oldfiles<cr>", desc = "Recent files" }
    -- buffer switching
    maps.n["<Leader>bb"] = {
      function()
        if #vim.t.bufs > 1 then
          require("telescope.builtin").buffers { sort_mru = true, ignore_current_buffer = true }
        else
          require("astrocore").notify "No other buffers open"
        end
      end,
      desc = "Switch Buffers In Telescope",
    }
  end

  if is_available "nvim-dap-ui" then
    maps.n["<Leader>dU"] = {
      function() require("dapui").toggle { reset = true } end,
      desc = "Toggle Debugger UI and reset layout",
    }
    if is_available "persistent-breakpoints.nvim" then
      maps.n["<F9>"] = {
        function() require("persistent-breakpoints.api").toggle_breakpoint() end,
        desc = "Debugger: Toggle Breakpoint",
      }
      maps.n["<Leader>db"] = {
        function() require("persistent-breakpoints.api").toggle_breakpoint() end,
        desc = "Toggle Breakpoint (F9)",
      }
      maps.n["<Leader>dB"] = {
        function() require("persistent-breakpoints.api").clear_all_breakpoints() end,
        desc = "Clear All Breakpoints",
      }
      maps.n["<Leader>dC"] = {
        function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
        desc = "Conditional Breakpoint (S-F9)",
      }
      maps.n["<F21>"] = {
        function() require("persistent-breakpoints.api").set_conditional_breakpoint() end,
        desc = "Conditional Breakpoint (S-F9)",
      }
    end
  end

  if is_available "venv-selector.nvim" then
    maps.n["<Leader>lv"] = {
      "<cmd>VenvSelect<CR>",
      desc = "Select VirtualEnv",
    }
    maps.n["<Leader>lV"] = {
      "<cmd>VenvSelectCached<CR>",
      desc = "VenvSelectCached",
    }
  end

  -- close mason
  if is_available "refactoring.nvim" then
    maps.n["<Leader>r"] = { desc = " Refactor" }
    maps.v["<Leader>r"] = { desc = " Refactor" }
    maps.x["<Leader>r"] = { desc = " Refactor" }
    maps.n["<Leader>rb"] = {
      function() require("refactoring").refactor "Extract Block" end,
      desc = "Extract Block",
    }
    maps.n["<Leader>ri"] = {
      function() require("refactoring").refactor "Inline Variable" end,
      desc = "Inline Variable",
    }
    maps.n["<Leader>rp"] = {
      function() require("refactoring").debug.printf { below = false } end,
      desc = "Debug: Print Function",
    }
    maps.n["<Leader>rc"] = {
      function() require("refactoring").debug.cleanup {} end,
      desc = "Debug: Clean Up",
    }
    maps.n["<Leader>rd"] = {
      function() require("refactoring").debug.print_var { below = false } end,
      desc = "Debug: Print Variable",
    }
    maps.n["<Leader>rbf"] = {
      function() require("refactoring").refactor "Extract Block To File" end,
      desc = "Extract Block To File",
    }

    maps.x["<Leader>re"] = {
      function() require("refactoring").refactor "Extract Function" end,
      desc = "Extract Function",
    }
    maps.x["<Leader>rf"] = {
      function() require("refactoring").refactor "Extract Function To File" end,
      desc = "Extract Function To File",
    }
    maps.x["<Leader>rv"] = {
      function() require("refactoring").refactor "Extract Variable" end,
      desc = "Extract Variable",
    }
    maps.x["<Leader>ri"] = {
      function() require("refactoring").refactor "Inline Variable" end,
      desc = "Inline Variable",
    }

    maps.v["<Leader>re"] = {
      function() require("refactoring").refactor "Extract Function" end,
      desc = "Extract Function",
    }
    maps.v["<Leader>rf"] = {
      function() require("refactoring").refactor "Extract Function To File" end,
      desc = "Extract Function To File",
    }
    maps.v["<Leader>rv"] = {
      function() require("refactoring").refactor "Extract Variable" end,
      desc = "Extract Variable",
    }
    maps.v["<Leader>ri"] = {
      function() require("refactoring").refactor "Inline Variable" end,
      desc = "Inline Variable",
    }
    maps.v["<Leader>rb"] = {
      function() require("refactoring").refactor "Extract Block" end,
      desc = "Extract Block",
    }
    maps.v["<Leader>rbf"] = {
      function() require("refactoring").refactor "Extract Block To File" end,
      desc = "Extract Block To File",
    }
    maps.v["<Leader>rr"] = {
      function() require("refactoring").select_refactor() end,
      desc = "Select Refactor",
    }
    maps.v["<Leader>rp"] = {
      function() require("refactoring").debug.printf { below = false } end,
      desc = "Debug: Print Function",
    }
    maps.v["<Leader>rc"] = {
      function() require("refactoring").debug.cleanup {} end,
      desc = "Debug: Clean Up",
    }
    maps.v["<Leader>rd"] = {
      function() require("refactoring").debug.print_var { below = false } end,
      desc = "Debug: Print Variable",
    }
  end

  if is_available "noice.nvim" then
    local noice_down = function()
      if not require("noice.lsp").scroll(4) then return "<C-d>" end
    end
    local noice_up = function()
      if not require("noice.lsp").scroll(-4) then return "<C-u>" end
    end

    maps.n["<C-d>"] = {
      noice_down,
      desc = "Scroll down",
      silent = true,
      expr = true,
    }
    maps.i["<C-d>"] = {
      noice_down,
      desc = "Scroll down",
      silent = true,
      expr = true,
    }
    maps.s["<C-d>"] = {
      noice_down,
      desc = "Scroll down",
      silent = true,
      expr = true,
    }
    maps.n["<C-u>"] = {
      noice_up,
      desc = "Scroll down",
      silent = true,
      expr = true,
    }
    maps.i["<C-u>"] = {
      noice_up,
      desc = "Scroll down",
      silent = true,
      expr = true,
    }
    maps.s["<C-u>"] = {
      noice_up,
      desc = "Scroll down",
      silent = true,
      expr = true,
    }
  end

  if system == "Darwin" or system == "Linux" then
    if is_available "Comment.nvim" then
      maps.n["<C-/>"] = {
        function() require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end,
        desc = "Comment line",
      }
      maps.v["<C-/>"] = {
        "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
        desc = "Toggle comment line",
      }
      maps.n["<Leader>/"] = false
      maps.n["<Leader>/"] = false
    end
  end

  if is_available "dial.nvim" then
    maps.v["<C-a>"] = {
      function() return require("dial.map").manipulate("increment", "visual") end,
      desc = "Increment",
    }
    maps.v["<C-x>"] = {
      function() return require("dial.map").manipulate("decrement", "visual") end,
      desc = "Decrement",
    }
    maps.v["g<C-a>"] = {
      function() return require("dial.map").manipulate("increment", "gvisual") end,
      desc = "Increment",
    }
    maps.v["g<C-x>"] = {
      function() return require("dial.map").manipulate("decrement", "gvisual") end,
      desc = "Decrement",
    }
    maps.n["<C-a>"] = {
      function() return require("dial.map").manipulate("increment", "normal") end,
      desc = "Increment",
    }
    maps.n["<C-x>"] = {
      function() return require("dial.map").manipulate("decrement", "normal") end,
      desc = "Decrement",
    }
    maps.n["g<C-a>"] = {
      function() return require("dial.map").manipulate("increment", "gnormal") end,
      desc = "Increment",
    }
    maps.n["g<C-x>"] = {
      function() return require("dial.map").manipulate("decrement", "gnormal") end,
      desc = "Decrement",
    }
  end

  if is_available "marks.nvim" then
    -- print(require("astrocore").is_available "marks.nvim")
    -- marks
    maps.n["m"] = { desc = "󰈚 Marks" }
    maps.n["m,"] = { "<Plug>(Marks-setnext)<CR>", desc = "Set Next Lowercase Mark" }
    maps.n["m;"] = { "<Plug>(Marks-toggle)<CR>", desc = "Toggle Mark(Set Or Cancel Mark)" }
    maps.n["m]"] = { "<Plug>(Marks-next)<CR>", desc = "Move To Next Mark" }
    maps.n["m["] = { "<Plug>(Marks-prev)<CR>", desc = "Move To Previous Mark" }
    maps.n["m:"] = { "<Plug>(Marks-preview)", desc = "Preview Mark" }

    maps.n["dm"] = { "<Plug>(Marks-delete)", desc = "Delete Marks" }
    maps.n["dm-"] = { "<Plug>(Marks-deleteline)<CR>", desc = "Delete All Marks On The Current Line" }
    maps.n["dm<space>"] = { "<Plug>(Marks-deletebuf)<CR>", desc = "Delete All Marks On Current Buffer" }
  end

  -- close search highlight
  maps.n["<Leader>nh"] = { ":nohlsearch<CR>", desc = "Close search highlight" }

  maps.n["<Leader><Leader>"] = { desc = "󰍉 User" }
  maps.n["s"] = "<Nop>"

  maps.n["H"] = { "^", desc = "Go to start without blank" }
  maps.n["L"] = { "$", desc = "Go to end without blank" }

  if is_available "vim-visual-multi" then
    -- visual multi
    vim.g.VM_maps = {
      ["Find Under"] = "<C-n>",
      ["Find Subword Under"] = "<C-n>",
      ["Add Cursor Up"] = "<C-S-k>",
      ["Add Cursor Down"] = "<C-S-j>",
      ["Select All"] = "<C-S-n>",
      ["Skip Region"] = "<C-x>",
    }
  end

  maps.v["<"] = { "<gv", desc = "Unindent line" }
  maps.v[">"] = { ">gv", desc = "Indent line" }

  if is_available "toggleterm.nvim" then
    if vim.fn.executable "lazygit" == 1 then
      maps.n["<Leader>tl"] = {
        require("utils").toggle_lazy_git(),
        desc = "ToggleTerm lazygit",
      }
      maps.n["<Leader>gg"] = maps.n["<Leader>tl"]
    end
    if vim.fn.executable "joshuto" == 1 then
      maps.n["<Leader>tj"] = {
        require("utils").toggle_joshuto(),
        desc = "ToggleTerm joshuto",
      }
    end
  end

  -- 在visual mode 里粘贴不要复制
  maps.n["x"] = { '"_x', desc = "Cut without copy" }

  -- 分屏快捷键
  maps.n["<Leader>w"] = { desc = "󱂬 Window" }
  maps.n["<Leader>ww"] = { "<cmd><cr>", desc = "Save" }
  maps.n["<Leader>wc"] = { "<C-w>c", desc = "Close current screen" }
  maps.n["<Leader>wo"] = { "<C-w>o", desc = "Close other screen" }
  -- 多个窗口之间跳转
  maps.n["<Leader>w="] = { "<C-w>=", desc = "Make all window equal" }
  maps.n["<TAB>"] =
  { function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end, desc = "Next buffer" }
  maps.n["<S-TAB>"] = {
    function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
    desc = "Previous buffer",
  }
  maps.n["<Leader>bo"] =
  { function() require("astrocore.buffer").close_all(true) end, desc = "Close all buffers except current" }
  maps.n["<Leader>ba"] = { function() require("astrocore.buffer").close_all() end, desc = "Close all buffers" }
  maps.n["<Leader>bc"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" }
  maps.n["<Leader>bC"] = { function() require("astrocore.buffer").close(0, true) end, desc = "Force close buffer" }
  maps.n["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" }
  maps.n["<Leader>bD"] = {
    function()
      require("astrocore.status").heirline.buffer_picker(function(bufnr) require("astrocore.buffer").close(bufnr) end)
    end,
    desc = "Pick to close",
  }

  -- lsp restart
  maps.n["<Leader>lm"] = { "<Cmd>LspRestart<CR>", desc = "Lsp restart" }
  maps.n["<Leader>lg"] = { "<Cmd>LspLog<CR>", desc = "Show lsp log" }

  if is_available "flash.nvim" then
    maps.n["<Leader>s"] = {
      function() require("flash").jump() end,
      desc = "Flash",
    }
    maps.x["<Leader>s"] = {
      function() require("flash").jump() end,
      desc = "Flash",
    }
    maps.o["<Leader>s"] = {
      function() require("flash").jump() end,
      desc = "Flash",
    }
    maps.n["<Leader><Leader>s"] = {
      function() require("flash").treesitter() end,
      desc = "Flash Treesitter",
    }
    maps.x["<Leader><Leader>s"] = {
      function() require("flash").treesitter() end,
      desc = "Flash Treesitter",
    }
    maps.o["<Leader><Leader>s"] = {
      function() require("flash").treesitter() end,
      desc = "Flash Treesitter",
    }
  end

  if is_available "substitute.nvim" then
    -- substitute, 交换和替换插件, 寄存器中的值，将会替换到s位置, s{motion}
    maps.n["s"] = { require("substitute").operator, desc = "Replace with {motion}" }
    maps.n["ss"] = { require("substitute").line, desc = "Replace with line" }
    maps.n["S"] = { require("substitute").eol, desc = "Replace until eol" }
    maps.v["p"] = { require("substitute").visual, desc = "Replace in visual" }
    -- exchange
    maps.n["sx"] = { require("substitute.exchange").operator, desc = "Exchange with {motion}" }
    maps.n["sxx"] = { require("substitute.exchange").line, desc = "Exchange with line" }
    maps.n["sxc"] = { require("substitute.exchange").cancel, desc = "Exchange exchange" }
    maps.v["X"] = { require("substitute.exchange").visual, desc = "Exchange in visual" }
  end

  if is_available "nvim-treesitter" then
    -- TsInformation
    maps.n["<Leader>lT"] = { "<cmd>TSInstallInfo<cr>", desc = "Tree sitter Information" }
  end

  if is_available "neoconf.nvim" then
    maps.n["<Leader>pd"] = { "<cmd>Neoconf<CR>", desc = "Select local/global neoconf config" }
    maps.n["<Leader>pb"] = { "<cmd>Neoconf show<CR>", desc = "Show neoconf merge config" }
    maps.n["<Leader>pc"] = { "<cmd>Neoconf lsp<CR>", desc = "Show neoconf merge lsp config" }
  end

  return maps
end

return M
