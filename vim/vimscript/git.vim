
command! Gc :G commit | call GitCommitMessageFn()
command! Ga :w |  G add % 
command! Gaa :wa |  G add -u .
command! Gp :G push
command! Gf :G fetch | G pull
command! Gl :vsplit | wincmd L | call  RunTerm("tig")
command!-nargs=1 Gs :G switch -c <args>

function! GitCommitMessageFn()
  let l:diff = system('git --no-pager diff --staged')
  let l:prompt = "generate a short commit message that describe the changes made using the diff below:\n" . l:diff
  call vim_ai#AIRun({}, l:prompt)
endfunction
