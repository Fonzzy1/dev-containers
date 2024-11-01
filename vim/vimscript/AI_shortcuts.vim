function! Summarise(file)
  if empty(a:file)
    echo "Error: Please provide a PDF file."
    return
  endif

  " Use pdftotext to convert PDF to text, storing it in a temporary file
  let l:tempfile = tempname() . '.txt'
  let l:command = 'pdftotext ' . shellescape(a:file) . ' ' . l:tempfile

  " Execute the system command
  call system(l:command)

  " Check if the temp file was successfully created
  if filereadable(l:tempfile)
    " Read the file contents and put it at the cursor position
    let l:filetext = join(readfile(l:tempfile), "\n")
    let l:prompt = "Please summarize the following journal article or academic piece. Focus on clarity and brevity while retaining the essential information. Retain the structure of the origional peice, and return it as a quarto document, including a yaml header and headers such as abstract, introduction, etc. ... ."
    call vim_ai#AIRun({"options":{"prompt":l:prompt}}, l:filetext)
    call delete(l:tempfile)
  else
    echo "Error: Failed to convert PDF or read tempfile."
  endif
endfunction

" Define the command to call the function
command! -nargs=1 -complete=file Summarise call Summarise(<f-args>)

command! -range=% FS <line1>,<line2>AIE fix spelling and gramar using australian english, assume marrdown formatting is being used:


