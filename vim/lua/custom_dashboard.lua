-- Function to execute shell commands
local function shell_exec(command)
  return vim.fn.systemlist(command)
end

-- Custom function to list branches using Telescope
function _G.ListBranches()
  local branches = shell_exec('git branch --list')
  print(table.concat(branches, '\n'))
end

-- Custom function to list PRs (using GitHub CLI)
function _G.ListPRs()
  local prs = shell_exec('gh pr list')
  print(table.concat(prs, '\n'))
end

-- Custom function to list Issues (using GitHub CLI)
function _G.ListIssues()
  local issues = shell_exec('gh issue list')
  print(table.concat(issues, '\n'))
end

require('dashboard').setup {
  theme = 'doom',
  config = {
    header = {
      '',
      '     _   _   _   _   _   _   _   _',
      '    / \\ / \\ / \\ / \\ / \\ / \\ / \\ / \\',
      '   ( N | E | O | V | I | M )   )',
      '    \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/ \\_/',
      '',
    },
    center = {
      {
        icon = '  ',
        desc = 'List all branches   ',
        action = 'lua ListBranches()'
      },
      {
        icon = '  ',
        desc = 'List open PRs      ',
        action = 'lua ListPRs()'
      },
      {
        icon = '  ',
        desc = 'List issues        ',
        action = 'lua ListIssues()'
      }
    },
  }
}
