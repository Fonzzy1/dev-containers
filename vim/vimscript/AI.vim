let g:model = 'gpt-4.1'
let g:vim_ai_debug = 1
let g:instruct_model = "gpt-4.1-mini"
let g:vim_ai_role = ''
let g:vim_ai_chat_markdown = 0
let g:vim_ai_async_chat = 0


let g:vim_ai_chat = {
            \  "provider": "openai",
            \  "prompt": "",
            \  "options": {
            \    "model": g:model,
            \    "endpoint_url": "https://api.openai.com/v1/chat/completions",
            \    "max_tokens": 0,
            \    "max_completion_tokens": 0,
            \    "temperature": 1,
            \    "request_timeout": 20,
            \    "stream": 1,
            \    "auth_type": "bearer",
            \    "token_file_path": "",
            \    "token_load_fn": "",
            \    "selection_boundary": "",
            \  },
            \  "ui": {
            \    "open_chat_command": "rightbelow vnew | set nonu | set nornu",
            \    "scratch_buffer_keep_open": 0,
            \    "populate_options": 0,
            \    "force_new_chat": 0,
            \    "paste_mode": 0,
            \  },
            \}

" map  enter to :AIChat when filetype is aichat
function! SetupAIChat()
  " Set up insert mode mapping for <CR>
  inoremap <buffer> <silent> <CR> <Esc>:AIC<CR>

  " Configure local settings
  setlocal noautoindent nosmartindent nocindent
  setlocal tw=80

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

