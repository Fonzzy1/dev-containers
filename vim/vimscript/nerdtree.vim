lua <<EOF
-- Disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Optionally enable 24-bit color
vim.opt.termguicolors = true


-- Setup nvim-tree with your specific configurations
require("nvim-tree").setup({
  actions = {
    open_file = {
      window_picker = {
        enable = false,
      },
    },
  },
  on_attach = function(bufnr)
  local api = require('nvim-tree.api')

  local function opts(desc)
    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  vim.keymap.set("n", "<CR>",           api.node.open.vertical,             opts("Open: Vertical Split"))
  vim.keymap.set("n", ".",              api.node.run.cmd,                   opts("Run Command"))
  vim.keymap.set("n", "-",              api.tree.change_root_to_parent,     opts("Up"))
  vim.keymap.set("n", "a",              api.fs.create,                      opts("Create File Or Directory"))
  vim.keymap.set("n", "bd",             api.marks.bulk.delete,              opts("Delete Bookmarked"))
  vim.keymap.set("n", "bt",             api.marks.bulk.trash,               opts("Trash Bookmarked"))
  vim.keymap.set("n", "bmv",            api.marks.bulk.move,                opts("Move Bookmarked"))
  vim.keymap.set("n", "B",              api.tree.toggle_no_buffer_filter,   opts("Toggle Filter: No Buffer"))
  vim.keymap.set("n", "c",              api.fs.copy.node,                   opts("Copy"))
  vim.keymap.set("n", "d",              api.fs.remove,                      opts("Delete"))
  vim.keymap.set("n", "g?",             api.tree.toggle_help,               opts("Help"))
  vim.keymap.set("n", "H",              api.tree.toggle_hidden_filter,      opts("Toggle Filter: Dotfiles"))
  vim.keymap.set("n", "J",              api.node.navigate.sibling.last,     opts("Last Sibling"))
  vim.keymap.set("n", "K",              api.node.navigate.sibling.first,    opts("First Sibling"))
  vim.keymap.set("n", "L",              api.node.open.toggle_group_empty,   opts("Toggle Group Empty"))
  vim.keymap.set("n", "M",              api.tree.toggle_no_bookmark_filter, opts("Toggle Filter: No Bookmark"))
  vim.keymap.set("n", "m",              api.marks.toggle,                   opts("Toggle Bookmark"))
  vim.keymap.set("n", "p",              api.fs.paste,                       opts("Paste"))
  vim.keymap.set("n", "r",              api.fs.rename,                      opts("Rename"))
  vim.keymap.set("n", "R",              api.tree.reload,                    opts("Refresh"))
  vim.keymap.set("n", "x",              api.node.run.system,                opts("Run System"))
  vim.keymap.set("n", "u",              api.fs.rename_full,                 opts("Rename: Full Path"))
  vim.keymap.set("n", "U",              api.tree.toggle_custom_filter,      opts("Toggle Filter: Hidden"))
  vim.keymap.set("n", "W",              api.tree.collapse_all,              opts("Collapse"))
  vim.keymap.set("n", "x",              api.fs.cut,                         opts("Cut"))
  vim.keymap.set("n", "y",              api.fs.copy.filename,               opts("Copy Name"))
  vim.keymap.set("n", "Y",              api.fs.copy.relative_path,          opts("Copy Relative Path"))
end
,
  -- Set the width of the nvim-tree window
  view = {
    width = 32,
    -- Custom mappings
  },
  -- Renderer settings
  renderer = {
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      },
    },
  },
  -- Git integration settings
  git = {
    enable = true,
    ignore = false,
  },
  -- UI settings
  hijack_cursor = false,
  update_cwd = false,
  diagnostics = {
    enable = false,
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {},
  },
  system_open = {
    cmd = nil,
    args = {},
  },
})  


EOF


function! LeftBarToNerd()
    call LeftBarToggle()
    NvimTreeFocus
    call LeftBarPost()
endfunction

function! LeftBarToNerdFind()
    call LeftBarToggle()
    NvimTreeFindFile
    call LeftBarPost()
endfunction
  
  
