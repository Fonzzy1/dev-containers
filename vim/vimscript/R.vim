function! RExtras()
  setlocal shiftwidth=2 softtabstop=2 expandtab
  inoremap <buffer> > %>%
  inoremap <buffer> < <-
endfunction

autocmd FileType r call RExtras()
