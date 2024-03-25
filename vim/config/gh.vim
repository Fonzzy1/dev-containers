command! Gr : call GhPrCreate()
command! Grl : bot call  term_start('gh  pr list') | set nornu | set nu! 
command!-nargs=1 Grv : bot call  term_start('gh  pr view ' . <args>) | set nornu | set nu! 
command!-nargs=1 Gre : bot call  term_start('gh  pr edit ' . <args>,{'term_finish':'close'}) | set nornu | set nu! 
command!-nargs=1 Grm : bot call  term_start('gh  pr merge ' . <args>) | set nornu | set nu! 
command!-nargs=1 Grc : bot call  term_start('gh  pr checkout ' . <args>, {'term_finish':'close'}) | set nornu | set nu! 
command!-nargs=? Grr : bot call  term_start('gh  pr review ' . <args>, {'term_finish':'close'}) | set nornu | set nu! 
command!-nargs=? Grd : bot call  term_start('gh  pr close ' . <args>, {'term_finish':'close'}) | set nornu | set nu! 

command! Gi : call GhIssueCreate()
command! Gil : bot call  term_start('gh issue list ') | set nornu | set nu! 
command!-nargs=1 Giv : bot call  term_start('gh issue view ' . <args>) | set nornu | set nu! 
command!-nargs=1 Gie : bot call  term_start('gh issue  edit ' . <args>,{'term_finish':'close'}) | set nornu | set nu! 
command!-nargs=1 Gir : bot call  term_start('gh issue comment ' . <args>, {'term_finish':'close'}) | set nornu | set nu! 
command!-nargs=1 Gic : bot call  term_start('gh issue develop -c ' . <args>, {'term_finish':'close'}) | set nornu | set nu! 
command!-nargs=1 Gid : bot call  term_start('gh issue close ' . <args>, {'term_finish':'close'}) | set nornu | set nu! 
command!-nargs=* Gh : bot call term_start('gh ' . <q-args>) | set nornu | set nu! 

command! -nargs=? Gt call RunGhAct(<f-args>)
command! Gtl : bot call  term_start('gh act --list ') | set nornu | set nu! 
command! Gth : bot call  term_start('gh run view ') | set nornu | set nu!  | wincmd L 
command! Gtw call VieworWatchLatest()

function! RunGhAct(...)
  let github_token = $GH_TOKEN
  let cmd = 'gh act -s GITHUB_TOKEN=' . github_token
  if a:0 > 0 " Check if there is an argument
    let cmd .= ' -j ' . a:1
  endif
  echo(cmd)
  " Start a new terminal session with the command
  call term_start(cmd)
  " Set 'nonumber', toggle 'number'
  set nonu
  set nu!
  wincmd L
endfunction

function! VieworWatchLatest()
  let l:branch_name = system('git rev-parse --abbrev-ref HEAD')
  
  " Run the 'gh run list' command and capture the JSON output
  let l:run_info_json = system('gh run list -b '. shellescape(l:branch_name) .' --limit 1 --json status,databaseId')
  
  " Parse the JSON to get the list of runs
  let l:runs = json_decode(l:run_info_json)
  
  " Check that we have at least one run to process
  if !empty(l:runs)
    " Get the first run's (latest) status and databaseId
    let l:latest_run_status = l:runs[0].status
    let l:latest_run_databaseId = l:runs[0].databaseId

    " Determine action based on run status
    if l:latest_run_status != "completed"
      " If in_progress, open a terminal on the right to watch the run
      vert call term_start('gh run watch '. l:latest_run_databaseId)
    else
      " If not in_progress, open a terminal on the right to view the run details
      vert call term_start('gh run view '. l:latest_run_databaseId) 
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
  let l:config = {
  \  "engine": "chat",
  \  "options": {
  \    "model": g:model,
  \    "initial_prompt": ">>> system\nyou are a code assistant",
  \    "temperature": 1,
  \  },
  \}
  call vim_ai#AIRun( l:config, l:prompt)
endfunction
