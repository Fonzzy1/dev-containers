let g:model = 'gpt-5.5'
let g:vim_ai_debug = 1
let g:instruct_model = "gpt-5.4-mini"
let g:vim_ai_role = ''
let g:vim_ai_chat_markdown = 0
let g:vim_ai_async_chat = 1


let g:vim_ai_chat = {
            \  "provider": "openai",
            \  "prompt": "",
            \  "options": {
            \    "model": g:model,
            \    "endpoint_url": "https://api.openai.com/v1/chat/completions",
            \    "stream": 1,
            \    "auth_type": "bearer",
            \    "selection_boundary": "```",
            \  },
            \  "ui": {
            \    "open_chat_command": "rightbelow vnew | set nonu | set nornu",
            \  },
            \}

" map  enter to :AIChat when filetype is aichat
function! SetupAIChat()
  function! AIIncludeAllBuffers()
    let l:lines = ['', '>>> include', '']

    for buf in getbufinfo({'buflisted': 1})
      if buf.loaded && buf.name != '' && filereadable(buf.name)
        call add(l:lines, buf.name)
      endif
  endfor

    call append(line('.'), l:lines + [''])
  endfunction
  " Set up insert mode mapping for <CR>
  inoremap <buffer> \! <Esc>o<CR>>>> exec<CR><CR>
  inoremap <buffer> \// <Esc>o<CR>>>> include<CR><CR>
  inoremap <buffer> \/a <Esc>:call AIIncludeAllBuffers()<CR>
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

