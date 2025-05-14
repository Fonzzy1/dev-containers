
function! RunTerm(cmd)
  " Escape the command for proper execution
  execute 'terminal '. a:cmd . ' && tail -f /dev/null'
  setlocal nonumber
  setlocal nornu
  setlocal scl=no
endfunction

function! GitCommitMessageFn(issue_number)
  let l:diff = system('git --no-pager diff --staged')
  let l:prompt = "generate a short commit message that describes the changes made using the diff below. Make sure it is not longer than 52 chars."
  
  if a:issue_number !=# ''
    " Fetch issue details using the GitHub CLI
    let l:issue_details = system('gh issue view ' . a:issue_number . ' --json title,body --template "{{.title}}: {{.body}}"')

    " Append issue information to the prompt
    let l:prompt .= " This commit fixes #" . a:issue_number . " (" . l:issue_details . ")"
  endif

  let l:prompt .= ":\n" . l:diff
  call vim_ai#AIRun(0, {}, l:prompt)
endfunction
