command! Gc :Git commit | call GitCommitMessageFn()
command! Gcc :wa |  Git add -u . | Git commit | call GitCommitMessageFn() | Git Push
command! Ga :w | Git add % 
command! Gaa :wa |  Git add -u .
command! Gp :Git push
command! Gf :Git fetch | Git pull
command! Gl :vsplit | wincmd L | call  RunTerm("tig")
command Gb :vsplit | wincmd L | call RunTerm("source ~/.bashrc; gitdist")
command!-nargs=1 Gs :Git switch <args>
command G :vertical Git

function! GitCommitMessageFn()
  let l:diff = system('git --no-pager diff --staged')
  let l:prompt = "generate a short commit message that describe the changes made using the diff below:\n" . l:diff
  call vim_ai#AIRun(0, l:prompt)
endfunction
