-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/AstroNvim/AstroNvim/blob/main/lua/astronvim/options.lua
-- Add any additional options here

vim.opt.conceallevel = 2 -- enable conceal
vim.opt.concealcursor = ""
vim.opt.list = false -- show whitespace characters
vim.opt.listchars = { tab = "│→", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" }
vim.opt.showbreak = "↪ "
vim.opt.showtabline = (vim.t.bufs and #vim.t.bufs > 1) and 2 or 1
vim.opt.spellfile = vim.fn.expand "~/.config/nvim/spell/en.utf-8.add"
vim.opt.splitkeep = "screen"
vim.opt.swapfile = false
vim.opt.thesaurus = vim.fn.expand "~/.config/nvim/spell/mthesaur.txt"
vim.opt.wrap = true -- soft wrap lines
vim.opt.scrolloff = 5 -- keep 3 lines when scrolling

vim.g.mapleader = " "
vim.g.maplocalleader = ""
vim.g.resession_enabled = true
vim.g.inlay_hints_enabled = true
vim.g.transparent_background = true
local original_directory
local isedit
vim.api.nvim_create_autocmd("CmdlineEnter", {
  callback = function ()
    isedit = false
    original_directory = vim.fn.getcwd()
  end
})


vim.api.nvim_create_autocmd("CmdlineLeave", {
  callback = function ()
      isedit = false
      vim.fn.execute("lcd " .. original_directory)
  end
})

vim.api.nvim_create_autocmd("CmdlineChanged", {
  callback = function()
    local cmdline_text = vim.fn.getcmdline()
    -- 检查 cmdline 是否以 :e 或 :edit 开头
    -- print(cmdline_text)
    if cmdline_text:find "^e " == 1 or cmdline_text:find "^edit " == 1 then
      -- 处于edit只切换一次
      if not isedit then
      -- 获取当前 buffer 所在目录

        -- print("切换" .. cmdline_text)
        local buffer_directory = vim.fn.expand "%:p:h"
        -- 切换目录
        vim.fn.execute("lcd " .. buffer_directory)
        isedit = true
      -- print(vim.fn.getcwd())
      end
    -- 处于其他目录上次命令不是edit则不操作，否则还原目录。
    else
      if isedit then
        vim.fn.execute("lcd " .. original_directory)
        -- print("还原" .. cmdline_text)
        isedit = false
      -- print(vim.fn.getcwd())
      end
    end
  end,
})
