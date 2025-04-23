command! Gr :vsplit | wincmd L | call  RunTerm("/usr/bin/gh pr create")
command! Grl :vsplit | wincmd L | call  RunTerm("/usr/bin/gh pr list")
command!-nargs=? Grv :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr view ' . <q-args>) 
command!-nargs=? Gre :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr edit ' . <q-args>)
command!-nargs=? Grm :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr merge ' . <q-args>)
command!-nargs=? Grd :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr checkout ' . <q-args>)
command!-nargs=? Grr :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr review ' . <q-args>)
command!-nargs=? Grx :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr close ' . <q-args>)

command! Gi :vsplit | wincmd L | call  RunTerm("/usr/bin/gh issue create")
command! Gin :vsplit | wincmd L | call  RunTerm("/usr/bin/gh issue create -R fonzzy1/dev-containers")
command! Gil :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue list ')
command!-nargs=? Giv :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue view ' . <q-args>)
command!-nargs=? Gie :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue  edit ' . <q-args>)
command!-nargs=? Gir :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue comment ' . <q-args>)
command!-nargs=1 Gid :call CheckoutOrCreateBranchFromIssue(<q-args>)

command!-nargs=? Gix :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue close ' . <q-args>)
command!-nargs=* Gh :vsplit | wincmd L call StartTerm('/usr/bin/gh ' . <q-args>)

command! -nargs=? Gt call RunGhAct(<f-args>)
command! Gtl :vsplit | wincmd L | call RunTerm('/usr/bin/gh act --list ') | set nornu | set nu! 
command! Gth :vsplit | wincmd L | call RunTerm('/usr/bin/gh run view ') | set nornu | set nu!  | wincmd L 
command! Gtw call VieworWatchLatest()

function! CheckoutOrCreateBranchFromIssue(issue_number)
  " Store the command to check for existing branches
  let l:branch_check_cmd = 'git branch -r --list | grep ' . a:issue_number 

  " Run the command and capture the output
  let l:branches = system(l:branch_check_cmd)

  " Check if we found any branches
  if !empty(l:branches)
    " Extract the branch name, assuming the first match is relevant
    let l:branch_name = split(l:branches)[0]
    let l:branch_name = substitute(l:branch_name, '^origin/', '', '')

    " Checkout the found branch
    execute '!git checkout ' . l:branch_name
  else
    " Use gh to develop the issue, which will create a branch
    let l:gh_cmd = '!gh issue develop ' . a:issue_number

    " Run the gh command
    execute l:gh_cmd
  endif
endfunction

function! RunGhAct(...)
  let github_token = $GH_TOKEN
  let cmd = '/usr/bin/gh act -s GITHUB_TOKEN=' . github_token
  if a:0 > 0 " Check if there is an argument
    let cmd .= ' -j ' . a:1
  endif
  echo(cmd)
  " Start a new terminal session with the command
    :vsplit
    call RunTerm(cmd)
  " Set 'nonumber', toggle 'number'
  set nonu
  set nu!
  wincmd L
endfunction

function! VieworWatchLatest()
  let l:branch_name = system('git rev-parse --abbrev-ref HEAD')
  
  " Run the '/usr/bin/gh run list' command and capture the JSON output
  let l:run_info_json = system('/usr/bin/gh run list -b '. shellescape(l:branch_name) .' --limit 1 --json status,databaseId')
  
  " Parse the JSON to get the list of runs
  let l:runs = json_decode(l:run_info_json)
  
  " Check that we have at least one run to process
  if !empty(l:runs)

    " Get the first run's (latest) status and databaseId
    let l:latest_run_status = l:runs[0].status
    let l:latest_run_databaseId = l:runs[0].databaseId

    " Determine action based on run status
    if l:latest_run_status != "completed"
      " If in_progress, open a terminal on the ri/usr/bin/ght to watch the run
      let cmd = '/usr/bin/gh run watch '. l:latest_run_databaseId
      :vsplit
      call StartTerm(cmd)
    else
      " If not in_progress, open a terminal on the ri/usr/bin/ght to view the run details
      let cmd = '/usr/bin/gh run view '. l:latest_run_databaseId
      :vsplit
      call StartTerm(cmd)
    endif
    wincmd L

  else
    echo 'No runs found for branch: '. l:branch_name
  endif
endfunction

function! GitPrRequestGeneration()
  let l:log = system('git log --pretty=%s:%b  $(git branch -l main master)..$(git rev-parse --abbrev-ref HEAD)')
  let l:diff = system('git diff $(git branch -l main master)..$(git rev-parse --abbrev-ref HEAD)')
  let l:branch_name = system('git rev-parse --abbrev-ref HEAD')
  let l:prompt = "Generate a message for a pull request in the form of a rmarkdown file  with a descriptive title, an in depth description of what the pull request will acheive, and a summary of changes made, including a list of modified files given the following branch name: \n" . l:branch_name . "git log: \n" . l:log . " and the following git diff \n" . l:diff . "Mimic the following format: \n #(a descritive title) \n\n ##Description \n\n ##Summary of changes \n ### Changed Files. Do not use ``` to encase the overall text"
  call vim_ai#AIRun( {}, l:prompt)
endfunction

