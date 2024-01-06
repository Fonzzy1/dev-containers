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
