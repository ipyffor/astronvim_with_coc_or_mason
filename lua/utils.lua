local M = {}

function M.print_r ( t )  
  local print_r_cache={}
  local function sub_print_r(t,indent)
      if (print_r_cache[tostring(t)]) then
          print(indent.."*"..tostring(t))
      else
          print_r_cache[tostring(t)]=true
          if (type(t)=="table") then
              for pos,val in pairs(t) do
                  if (type(val)=="table") then
                      print(indent.."["..pos.."] => "..tostring(t).." {")
                      sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                      print(indent..string.rep(" ",string.len(pos)+6).."}")
                  elseif (type(val)=="string") then
                      print(indent.."["..pos..'] => "'..val..'"')
                  else
                      print(indent.."["..pos.."] => "..tostring(val))
                  end
              end
          else
              print(indent..tostring(t))
          end
      end
  end
  if (type(t)=="table") then
      print(tostring(t).." {")
      sub_print_r(t,"  ")
      print("}")
  else
      sub_print_r(t,"  ")
  end
  print()
end

function M.better_search(key)
  return function()
    local searched, error =
      pcall(vim.cmd.normal, { args = { (vim.v.count > 0 and vim.v.count or "") .. key }, bang = true })
    if not searched and type(error) == "string" then require("astrocore").notify(error, vim.log.levels.ERROR) end
  end
end

function M.remove_keymap(mode, key)
  for _, map in pairs(vim.api.nvim_get_keymap(mode)) do
    if map.lhs == key then vim.api.nvim_del_keymap(mode, key) end
  end
end

function M.toggle_lazy_git()
  return function()
    local worktree = require("astrocore").file_worktree()
    local flags = worktree and (" --work-tree=%s --git-dir=%s"):format(worktree.toplevel, worktree.gitdir) or ""
    require("astrocore").toggle_term_cmd {
      cmd = "lazygit " .. flags,
      hidden = true,
      on_open = function()
        M.remove_keymap("t", "<C-H>")
        M.remove_keymap("t", "<C-J>")
        M.remove_keymap("t", "<C-K>")
        M.remove_keymap("t", "<C-L>")
      end,
      on_close = function()
        vim.api.nvim_set_keymap("t", "<C-h>", "<cmd>wincmd h<cr>", { silent = true, noremap = true })
        vim.api.nvim_set_keymap("t", "<C-j>", "<cmd>wincmd j<cr>", { silent = true, noremap = true })
        vim.api.nvim_set_keymap("t", "<C-k>", "<cmd>wincmd k<cr>", { silent = true, noremap = true })
        vim.api.nvim_set_keymap("t", "<C-l>", "<cmd>wincmd l<cr>", { silent = true, noremap = true })
      end,
      on_exit = function(t, job, code, event)
        -- For Stop Term Mode
        vim.cmd [[stopinsert]]
      end,
    }
  end
end

function M.toggle_joshuto(path)
  return function()
    local output_path = "/tmp/joshuto_filechosen"
    os.remove(output_path)
    path = vim.fn.expand "%:p:h"
    local cmd = string.format('joshuto --file-chooser --output-file "%s" "%s"', output_path, path)
    require("astrocore").toggle_term_cmd {
      cmd = cmd,
      hidden = true,
      on_open = function()
        M.remove_keymap("t", "<C-H>")
        M.remove_keymap("t", "<C-J>")
        M.remove_keymap("t", "<C-K>")
        M.remove_keymap("t", "<C-L>")
      end,
      on_close = function()
        vim.api.nvim_set_keymap("t", "<C-h>", "<cmd>wincmd h<cr>", { silent = true, noremap = true })
        vim.api.nvim_set_keymap("t", "<C-j>", "<cmd>wincmd j<cr>", { silent = true, noremap = true })
        vim.api.nvim_set_keymap("t", "<C-k>", "<cmd>wincmd k<cr>", { silent = true, noremap = true })
        vim.api.nvim_set_keymap("t", "<C-l>", "<cmd>wincmd l<cr>", { silent = true, noremap = true })
      end,
      on_exit = function(t, job, code, event)
        if code == 102 then
          local open_path = vim.fn.readfile(output_path)[1]
          vim.cmd "silent! :checktime"
          vim.loop.new_timer():start(
            0,
            0,
            vim.schedule_wrap(function()
              if open_path then vim.cmd(string.format("edit %s", open_path)) end
            end)
          )
        end
      end,
    }
  end
end

function M.removeValueFromTable(tbl, value)
  for i, v in ipairs(tbl) do
    if v == value then
      table.remove(tbl, i)
      return true
    end
  end
  return false
end

function M.list_remove_unique(lst, vals)
  if not lst then lst = {} end
  assert(vim.tbl_islist(lst), "Provided table is not a list like table")
  if not vim.tbl_islist(vals) then vals = { vals } end
  local added = {}
  vim.tbl_map(function(v) added[v] = true end, lst)
  for _, val in ipairs(vals) do
    if added[val] then
      M.removeValueFromTable(lst, val)
      added[val] = false
    end
  end
  return lst
end

return M
