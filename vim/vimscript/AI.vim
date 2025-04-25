let g:model = 'gpt-4o-search-preview'
let g:vim_ai_debug = 1
let g:instruct_model = "gpt-4o-mini"
let g:vim_ai_role = ''



let initial_prompt =<< trim END
>>> system

You are going to play the role of an assistant siting in neovim. 
You will be asked to edit, discuss and generate both code and prose.
Tips:
- Only return the text you have been asked to provide without wrapping it in code blocks. 
- Be aware of the current level of indenting of the text that has been given to you
- Make sure to return equaly indented text
- Try to keep code lines at less than 80 characters long, however prose can be as long as you want
- Ignore any preexisting wraps in prose that is sent to you, that will be reinserted by the editor
END
"config for chat

let g:vim_ai_chat = {
            \  "ui": {
            \    "code_syntax_enabled": 1,
            \    "open_chat_command": "rightbelow vnew | set nonu | set nornu",
            \    "scratch_buffer_keep_open": 0,
            \    "paste_mode": 0
            \  },
            \  "options": {
            \    "model": g:model,
            \    "max_tokens": 0,
            \    "temperature": -1,
            \    "initial_prompt": initial_prompt,
            \    "web_search_options": {
            \      "user_location": {
            \        "type": "approximate",
            \        "approximate": {
            \          "country": "AU",
            \          "region": "VIC",
            \          "city": "Bentleigh"
            \        }
            \      }
            \    }
            \  }
            \}

" map  enter to :AIChat when filetype is aichat
autocmd FileType aichat inoremap <buffer> <silent> <CR> <C-O>:AIChat<CR>
autocmd FileType aichat startinsert
autocmd FileType setlocal textwidth=80


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
\  "ui": {
\    "paste_mode": 0,
\  },
\}

let g:vim_ai_complete = chat_engine_config
let g:vim_ai_edit = chat_engine_config

