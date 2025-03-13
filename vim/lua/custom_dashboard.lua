local fill = { ',',':', '-', '=', '#', '@' }

local ascii_heatmap = require('git-dashboard-nvim').setup {
  show_only_weeks_with_commits = false,
  show_contributions_count = true,
  use_current_branch = true,
  use_git_username_as_author=true,
  title = 'owner_with_repo_name',
  top_padding = 10,
  centered = false,
  empty_square= '.',
    colors = {
        days_and_months_labels = '#8fbcbb',
        empty_square_highlight = '#3b4252',
        filled_square_highlights = { 
           '#88c0d0', 
           '#a5adcb', 
           '#8aadf4', 
           '#8bd5ca', 
           '#a6da95', 
           '#eed49f' 
           },
        branch_highlight = '#88c0d0',
        dashboard_title = '#88c0d0',
    },
  filled_squares=fill
}

local opts = {
  theme = 'doom',
  config = {
    header = ascii_heatmap,
    center = {
      { action = 'ene | startinsert', desc = 'New file', icon = '', key = 'i' },
      { action = 'call RunTerm("source ~/.bashrc; gh issue list && gh pr list && echo `` && gitdist; tail -f /dev/null")', desc = 'List Git', icon = '', key = 'l' },
      { action = 'call RunTerm("gh issue new; tail -f /dev/null")', desc = 'Create an issue', icon = '', key = 'n' },
      { action = 'call RunTerm("/bin/bash")', desc = 'Open Terminal', icon = '', key = 't' },
      { action = ':call vim_ai#AIChatRun(0,{})', desc = 'open chat', icon = '', key = 'c' },

    },
    footer = function()
      return {}
    end,
  },
}

-- Proper way to require and set up dashboard-nvim
require('dashboard').setup(opts)

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    if vim.bo.filetype ~= "dashboard" then
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "dashboard" then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end
  end,
})


