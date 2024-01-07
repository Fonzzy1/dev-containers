function! GhIssueCreate()
    bot new /tmp/ghissuecreate.md
    :1,$d 
endfunction
    
autocmd BufWritePost /tmp/ghissuecreate.md :call GhIssueCreateCLI()

function! GhIssueCreateCLI()
    let l:title = system("head -n1 /tmp/ghissuecreate.md | sed 's/^#//' | xargs")
    let l:body = system("sed -e 1,2d /tmp/ghissuecreate.md")
    let l:command = "gh issue create --body \"" . l:body . "\" -t \" " . l:title . "\"" 
    bot call  term_start(l:command,{'term_finish':'close'})
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
    bot call  term_start(l:command,{'term_finish':'close'})
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
  let l:range = 0
  let l:config = {
    \ "engine": "chat",
    \ "options": {
      \ "model": g:model,
      \ "endpoint_url": "https://api.openai.com/v1/chat/completions",
\    "max_tokens": 0,
      \ "temperature": 1,
      \ "request_timeout": 20,
      \ "enable_auth": 1,
      \ "selection_boundary": "",
      \ "initial_prompt": ">>> system \n You are a general assistant. ,If you attach a code block add syntax type after ``` to enable syntax highlighting. "
    \ },
  \ }
  call vim_ai#AIRun(l:range, l:config, l:prompt)
endfunction

