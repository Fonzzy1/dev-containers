command! -nargs=? Gc execute ':Git commit' | call GitCommitMessageFn(<q-args>)
command! -nargs=? Gcc execute ':wa | Git add -u . | Git commit' | call GitCommitMessageFn(<q-args>) | execute ':Git push'
command! Ga :w | Git add % 
command! Gaa :wa |  Git add -u .
command! Gp :Git push
command! Gf :Git fetch | Git pull
command! Gl :vsplit | wincmd L | call  RunTerm("tig")
command Gb :vsplit | wincmd L | call RunTerm("source ~/.bashrc; gitdist")
command!-nargs=1 Gs :Git switch <args>
command G :vertical Git

function! GitCommitMessageFn(issue_number)
  let l:diff = system('git --no-pager diff --staged')
  let l:prompt = "generate a short commit message that describes the changes made using the diff below"
  
  if a:issue_number !=# ''
    " Fetch issue details using the GitHub CLI
    let l:issue_details = system('gh issue view ' . a:issue_number . ' --json title,body --template "{{.title}}: {{.body}}"')

    " Append issue information to the prompt
    let l:prompt .= " and fixes #" . a:issue_number . " (" . l:issue_details . ")"
  endif

  let l:prompt .= ":\n" . l:diff
  call vim_ai#AIRun(0, {}, l:prompt)
endfunction
