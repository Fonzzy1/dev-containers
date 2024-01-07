" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap q :call LeftBarToQF()<cr>
nmap Q :call AddCursorToQuickfix()<cr>

function! AddCursorToQuickfix()
  " Get the current cursor position
  let cursor_position = getpos('.')
  let line_number = cursor_position[1]
  let column_number = cursor_position[2]
  
  " Get the text of the line at the current cursor position
  let line_text = getline(line_number)

  " Prompt the user for a name/text to associate with the quickfix entry
  let name = input('Enter a name for the quickfix entry: ')

  " Use the user-provided name or fallback to the line's text if left blank
  let text_for_quickfix = (len(name) > 0) ? name : line_text
  
  " Create the new quickfix item with the cursor location and input text
  let quickfix_item = {
        \ 'filename': expand('%'),
        \ 'lnum': line_number,
        \ 'col': column_number,
        \ 'text': text_for_quickfix,
        \ }
  
  " Add the quickfix item to the quickfix list
  call setqflist([quickfix_item], 'a')
endfunction

function! LeftBarToQF()
  call LeftBarToggle()
  copen
endfunction

function! FindStringAndAddToQFList(string)
  " Save the current qf list
  let l:old_qflist = getqflist()

  " Grep for the string in the current directory files
  execute 'vimgrep /' . a:string . '/ **/*'

  " Get the results of vimgrep
  let l:new_qflist = getqflist()

  " Restore the old qf list
  call setqflist(l:old_qflist)

  " Append the new results to the qf list
  call setqflist(l:new_qflist, 'a')
endfunction

command! -nargs=1 Find call FindStringAndAddToQFList(<f-args>)


function! s:ToggleLocation()
    if ! v:count && &l:conceallevel != 0
        setlocal conceallevel=0
        silent! syntax clear qfLocation
    else
        setlocal concealcursor=nc
        silent! syntax clear qfLocation
        if v:count == 1
            " Hide file paths only.
            setlocal conceallevel=1
            " XXX: Couldn't find a way to integrate the concealment with the
            " existing "qfFileName" definition, and had to replace it. This will
            " persist when toggling off; only a new :setf qf will fix that.
            syntax match qfLocation /^\%([^/\\|]*[/\\]\)\+/ transparent conceal cchar=‥ nextgroup=qfFileName
            syntax clear qfFileName
            syntax match qfFileName /[^|]\+/ contained
        elseif v:count == 2
            " Hide entire filespec.
            setlocal conceallevel=2
            syntax match qfLocation /^[^|]*/ transparent conceal
        else
            " Hide filespec and location.
            setlocal conceallevel=2
            syntax match qfLocation /^[^|]*|[^|]*| / transparent conceal
        endif
    endif
endfunction
"[N]<LocalLeader>tf Toggle filespec and location to allow focusing on the
"           error text.
"           [N] = 1: Hide file paths only.
"           [N] = 2: Hide entire filespec.
"           [N] = 3: Hide filespec and location.
nnoremap <buffer> <silent> <LocalLeader>tf :<C-u>call <SID>ToggleLocation()<CR>
