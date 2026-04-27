let g:model = 'gpt-5.4'
let g:vim_ai_debug = 1
let g:instruct_model = "gpt-5.4-mini"
let g:vim_ai_role = ''
let g:vim_ai_chat_markdown = 0
let g:vim_ai_async_chat = 1
let g:vim_ai_roles_config_file = ".roles.ini"



let g:vim_ai_chat = {
            \  "provider": "openai",
            \  "options": {
            \    "model": g:model,
            \    "stream": 1,
            \    "selection_boundary": "```",
            \  },
            \  "ui": {
            \    "open_chat_command": "rightbelow vnew | set nonu | set nornu",
            \  },
            \}

" map  enter to :AIChat when filetype is aichat
function! SetupAIChat()
    function! AIIncludeAllWindows()
      let l:lines = ['', '>>> include', '']

      for win in getwininfo()
        let l:buf = winbufnr(win.winid)
        let l:name = bufname(l:buf)
        if l:name != '' && filereadable(l:name)
          call add(l:lines, l:name)
        endif
    endfor

      call append(line('.'), l:lines + [''])
    endfunction
  " Set up insert mode mapping for <CR>
  inoremap <buffer> \! <Esc>o<CR>>>> exec<CR><CR>
  inoremap <buffer> \// <Esc>o<CR>>>> include<CR><CR>
  inoremap <buffer> \/a <Esc>:call AIIncludeAllWindows()<CR>
  inoremap <buffer> <silent> <CR> <Esc>:AIC<CR>
  call QuartoExtras()

  " Enable Markview
  :Markview attach

  " Define syntax highlighting for roles
  syntax match aichatRole "<<< thinking"
  syntax match aichatRole "<<< assistant"

  " Link aichatRole to Comment highlight
  highlight default link aichatRole Comment

  echo 'AIChat Setup'

endfunction

autocmd FileType aichat call timer_start(10, { -> SetupAIChat() })


let chat_engine_config = {
\  "engine": "chat",
\  "options": {
\    "model": g:instruct_model,
\    "endpoint_url": "https://api.openai.com/v1/chat/completions",
\    "max_tokens": 0,
\    "temperature": 0.1,
\    "request_timeout": 20,
\    "selection_boundary": "",
\  },
\  "ui": {
\    "paste_mode": 0,
\  },
\}

let g:vim_ai_complete = chat_engine_config
let g:vim_ai_edit = chat_engine_config

