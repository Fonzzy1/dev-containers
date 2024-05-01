let g:model = 'gpt-4-0613'
let g:instruct_model = 'gpt-3.5-turbo-0125'

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
autocmd FileType aichat  inoremap <buffer> <C-M> <C-O>:AIChat<CR> | setlocal wrap

let complete_initial_prompt =<< trim END
>>> system

You are a text and code completion engine. 
You will be sent an instruction, which may be followed by a colon and a chunk of text.
You will return code or text that will be directy inserted into a file
If there is no chunk, then your response will be inserted into an empty file. Make sure to inclue a shebang if writing code
If there is a chunk, the your response will be insertred directly below it
Do not give any commentary about the text
If you are returning code, do not place it in code blocks, instead just return the code as plain text
END

let edit_initial_prompt =<< trim END
>>> system

You are a text and code editing engine. 
You will be sent send you an instruction, followed by a colon and then a chunk of text
You will return code or text that will be directy inserted into a file
Your response will be directy insersted in place of the chunk you have been sent
Do not give any commentary about the text
If you are returning code, do not place it in code blocks, instead just return the code as plain text
END

let g:vim_ai_complete = {
            \  "engine": "chat",
            \  "options": {
            \    "model": g:instruct_model,
            \    "endpoint_url": "https://api.openai.com/v1/chat/completions",
            \    "max_tokens": 0,
            \    "temperature": 0.2,
            \    "request_timeout": 20,
            \    "selection_boundary": "",
            \    "initial_prompt": complete_initial_prompt,
            \  },
            \}

let g:vim_ai_edit = {
            \  "engine": "chat",
            \  "options": {
            \    "model": g:instruct_model,
            \    "endpoint_url": "https://api.openai.com/v1/chat/completions",
            \    "max_tokens": 0,
            \    "temperature": 0.2,
            \    "request_timeout": 20,
            \    "selection_boundary": "",
            \    "initial_prompt": edit_initial_prompt,
            \  },
            \}
