function! GhIssueCreate()
    bot new /tmp/ghissuecreate.md
    :1,$d 
endfunction
    
autocmd BufWritePost /tmp/ghissuecreate.md :call GhIssueCreateCLI()

function! GhIssueCreateCLI()
    let l:title = system("head -n1 /tmp/ghissuecreate.md | sed 's/^#//' | xargs")
    let l:body = system("sed -e 1,2d /tmp/ghissuecreate.md")
    let l:command = "gh issue create --body \"" . l:body . "\" -t \" " . l:title . "\"" 
    :vsplit
    call StartTerm(l:command)
endfunction

function! GhPrCreate()
    bot new /tmp/ghprcreate.md
    :1,$d
    :call GitPrRequestGeneration()
endfunction

autocmd BufWritePost /tmp/ghprcreate.md :call GhPrCreateCLI()

function! GhPrCreateCLI()
    let l:title = system("head -n1 /tmp/ghprcreate.md | sed 's/^#//' | xargs")
    let l:body = system("sed -e 1,2d /tmp/ghprcreate.md")
    let l:command = "gh pr create --body \"" . l:body . "\" -t \" " . l:title . "\"" 
    :vsplit
    call StartTerm(l:command)
    wincmd J
endfunction

command! Gc :G commit | call GitCommitMessageFn()
command! Ga :w |  G add % 
command! Gaa :wa |  G add -u .
command! Gp :G push
command! Gf :G fetch | G pull
command! Gl :!tig
command!-nargs=1 Gs :G switch -c <args>

function! GitCommitMessageFn()
  let l:diff = system('git --no-pager diff --staged')
  let l:prompt = "generate a short commit message from the diff below with a single short (less than 50 character) line summarizing the change, followed by a blank line and then a more thorough description where each sentence is on a new line and it less than 72 characters long, do not use ``` at all in the commit message:\n" . l:diff
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

