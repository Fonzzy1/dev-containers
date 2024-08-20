let g:model = 'gpt-4o'
let g:instruct_model = "gpt-3.5-turbo-instruct"
"config for chat
let g:vim_ai_chat = {
            \  "ui": {
            \    "code_syntax_enabled": 1,
            \    "open_chat_command": "rightbelow vnew | set nonu | set nornu | call vim_ai#MakeScratchWindow()",
            \    "scratch_buffer_keep_open": 0,
            \    "paste_mode": 1
            \  },
            \  "options": {
            \    "model": g:model,
            \    "max_tokens": 0
            \  }
            \}

" map  enter to :AIChat when filetype is aichat
autocmd FileType aichat inoremap <buffer> <CR> <C-O>:AIChat<CR>
autocmd FileType aichat setlocal wrap
autocmd FileType aichat startinsert

let g:vim_ai_complete = {
\  "engine": "complete",
\  "options": {
\    "model": g:instruct_model,
\    "endpoint_url": "https://api.openai.com/v1/completions",
\    "max_tokens": 1000,
\    "temperature": 0.1,
\    "request_timeout": 20,
\    "enable_auth": 1,
\    "selection_boundary": "#####",
\  },
\  "ui": {
\    "paste_mode": 1,
\  },
\}

let g:vim_ai_edit = {
\  "engine": "complete",
\  "options": {
\    "model": g:instruct_model,
\    "endpoint_url": "https://api.openai.com/v1/completions",
\    "max_tokens": 1000,
\    "temperature": 0.1,
\    "request_timeout": 20,
\    "enable_auth": 1,
\    "selection_boundary": "#####",
\  },
\  "ui": {
\    "paste_mode": 1,
\  },
\}
