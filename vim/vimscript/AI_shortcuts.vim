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
    let l:prompt = "Please summarize the following journal article or academic piece. Focus on clarity and brevity while retaining the essential information. Retain the structure of the original piece, and return it as a markdown document, including a yaml header and headers such as abstract, introduction, etc. Before this summary include a section called key take aways, that will have the key information that I should take away from the peice ."
    
    " Attempt to call AI service with appropriate error handling
    try
      call vim_ai#AIRun({"options": {"prompt": l:prompt}}, l:filetext)
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

command! -range=% FS <line1>,<line2>AIE fix spelling and gramar using australian english, assume marrdown formatting is being used:


