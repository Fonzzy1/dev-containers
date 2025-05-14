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
    let l:prompt = ">>> system \n Please summarize the following journal article or text. Focus on the key findings of the peice, and its contribution to knowledge. Keep your response in sentences seperated by ';'"
    
    " Attempt to call AI service with appropriate error handling
    try
      call vim_ai#AIRun(5,{"options": {"initial_prompt": l:prompt, 'temperature':0.5}}, l:filetext)
    catch
      echoerr "Error: An issue occurred while trying to summarize the text with the AI service."
    endtry
    
    call delete(l:tempfile)
  else
    echoerr "Error: Failed to convert PDF or read tempfile."
  endif
endfunction


" Define the command to call the function
command! -nargs=1 -complete=file Summarise call Summarise(<f-args>)

function! RunPythonScriptInScratch(...)
    let l:question = join(a:000, ' ')
    let l:cmd = 'python3 /wiki/References/_ask_question.py ' . shellescape(l:question)
    let l:result = system(l:cmd)
    vnew
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal filetype=quarto
    setlocal noswapfile
    call setline(1, split(l:result, "\n"))
endfunction


