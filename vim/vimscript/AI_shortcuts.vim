function! Summarise(file)
  if empty(a:file)
    echoerr "Error: Please provide a PDF file."
    return
  endif

  if executable('pdftotext') == 0
    echoerr "Error: pdftotext is not installed. Please install it to use this function."
    return
  endif

  let l:tempfile = tempname() . '.txt'
  let l:command = 'pdftotext ' . shellescape(a:file) . ' ' . l:tempfile
  call system(l:command)

  if v:shell_error != 0
    echoerr "Error: Failed to execute pdftotext command. Please check the file path and pdftotext installation."
    return
  endif

  if filereadable(l:tempfile)
    let l:filetext = join(readfile(l:tempfile), "\n")
    let l:instruction = "Extract and list the main claims of the following journal article or text in a single paragraph. Present each claim as a standalone, explicit sentence, separated by a full stop and then a newline. Do not include explanations, introductions, or references between sentences. Minimize pronouns by explicitly naming things and concepts; assume each sentence will be read in isolation; These claims should be the things that the article could be cited for; Do not start the sentences by saying 'This article claims' or the like.\n\n"
    let g:_summarise_prompt = l:instruction . l:filetext
    lua require('opencode').ask(vim.g._summarise_prompt, { submit = true })
    call delete(l:tempfile)
  else
    echoerr "Error: Failed to convert PDF or read tempfile."
  endif
endfunction

command! -nargs=1 -complete=file Summarise call Summarise(<f-args>)
