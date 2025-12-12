function! Summarise(file)
  " Check if the input file is provided and not empty
  if empty(a:file)
    echoerr "Error: Please provide a PDF file."
    return
  endif

  " Check if pdftotext is available in the system
  if executable('pdftotext') == 0
    echoerr "Error: pdftotext is not installed. Please install it to use this function."
    return
  endif

  " Prepare the command to convert PDF to text
  let l:tempfile = tempname() . '.txt'
  let l:command = 'pdftotext ' . shellescape(a:file) . ' ' . l:tempfile

  " Execute the system command
  let l:result = system(l:command)

  " Check for system command execution errors
  if v:shell_error != 0
    echoerr "Error: Failed to execute pdftotext command. Please check the file path and pdftotext installation."
    return
  endif

  " Check if the tempfile was successfully created and is readable
  if filereadable(l:tempfile)
    let l:filetext = join(readfile(l:tempfile), "\n")
    let l:prompt = ">>> system\n Extract and list the main claims of the following journal article or text in a single paragraph. Present each claim as a standalone, explicit sentence, separated by a full stop and then a newline. Do not include explanations, introductions, or references between sentences. Minimize pronouns by explicitly naming things and concepts; assume each sentence will be read in isolation; These claims should be the things that the article could be cited for; Do not start the sentences b by saying 'This artcile claims' or the like"

    let l:config = {
    \  "options": {
    \    "model": "gpt-4.1",
    \    "initial_prompt": l:prompt,
    \    "temperature": 0.5,
    \  },
    \}
    " Attempt to call AI service with appropriate error handling
    call vim_ai#AIRun(0,l:config, l:filetext)
    
    call delete(l:tempfile)
  else
    echoerr "Error: Failed to convert PDF or read tempfile."
  endif
endfunction


" Define the command to call the function
command! -nargs=1 -complete=file Summarise call Summarise(<f-args>)

