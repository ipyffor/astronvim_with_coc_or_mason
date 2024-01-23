return {
    "ahmedkhalf/project.nvim",
    config = function()
        require("project_nvim").setup {
            detection_methods = { "pattern" },

            -- All the patterns used to detect root dir, when **"pattern"** is in
            -- detection_methods
            patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
        }
    end
}