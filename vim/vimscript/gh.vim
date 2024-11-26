command! Gr :vsplit | wincmd L | call  RunTerm("/usr/bin/gh pr create")
command! Grl :vsplit | wincmd L | call  RunTerm("/usr/bin/gh pr list")
command!-nargs=1 Grv :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr view ' . <args>) 
command!-nargs=1 Gre :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr edit ' . <args>)
command!-nargs=1 Grm :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr merge ' . <args>)
command!-nargs=1 Grc :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr checkout ' . <args>)
command!-nargs=? Grr :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr review ' . <args>)
command!-nargs=? Grd :vsplit | wincmd L | call RunTerm('/usr/bin/gh  pr close ' . <args>)

command! Gi :split | call  RunTerm("/usr/bin/gh issue create")
command! Gil :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue list ')
command!-nargs=1 Giv :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue view ' . <args>)
command!-nargs=1 Gie :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue  edit ' . <args>)
command!-nargs=1 Gir :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue comment ' . <args>)
command!-nargs=1 Gic :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue develop -c ' . <args>)
command!-nargs=1 Gid :vsplit | wincmd L | call RunTerm('/usr/bin/gh issue close ' . <args>)
command!-nargs=* Gh :vsplit | wincmd L call StartTerm('/usr/bin/gh ' . <q-args>)

command! -nargs=? Gt call RunGhAct(<f-args>)
command! Gtl :vsplit | wincmd L | call RunTerm('/usr/bin/gh act --list ') | set nornu | set nu! 
command! Gth :vsplit | wincmd L | call RunTerm('/usr/bin/gh run view ') | set nornu | set nu!  | wincmd L 
command! Gtw call VieworWatchLatest()

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

