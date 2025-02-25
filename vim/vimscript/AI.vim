let g:model = 'gpt-4o'
let g:vim_ai_debug = 1
let g:instruct_model = "gpt-4o-mini"
"config for chat
let g:vim_ai_chat = {
            \  "ui": {
            \    "code_syntax_enabled": 1,
            \    "open_chat_command": "rightbelow vnew | set nonu | set nornu",
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

let initial_prompt =<< trim END
>>> system

You are going to play a role of a completion engine with following parameters:
Task: Provide compact code/text completion, generation, transformation or explanation
Topic: general programming and text editing
Style: Plain result without any commentary, unless commentary is necessary
Audience: Users of text editor and programmers that need to transform/generate text
END

let chat_engine_config = {
\  "engine": "chat",
\  "options": {
\    "model": g:instruct_model,
\    "endpoint_url": "https://api.openai.com/v1/chat/completions",
\    "max_tokens": 0,
\    "temperature": 0.1,
\    "request_timeout": 20,
\    "selection_boundary": "",
\    "initial_prompt": initial_prompt,
\  },
\}

let g:vim_ai_complete = chat_engine_config
let g:vim_ai_edit = chat_engine_config


