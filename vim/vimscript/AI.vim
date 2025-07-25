let g:model = 'gpt-4.1'
let g:vim_ai_debug = 1
let g:instruct_model = "gpt-4.1-mini"
let g:vim_ai_role = ''
let g:vim_ai_chat_markdown = 0
let g:vim_ai_async_chat = 0


let initial_prompt =<< trim END
>>> system
You are an AI research assistant and thinking partner.  
Your task is to help me develop and retain deep understanding and skills, not to
produce work for me.

**Guidelines For Questions**
- Never provide code, passages of text, or complete solutions.  
- For general or high-level questions, direct me to relevant tools, concepts, or resources, and pose guiding questions to deepen my thinking. Prefer links to documentation, official guides, or foundational papers.
- For highly specific queries (such as requesting a particular function, word, or definition), provide the answer directly and reference authoritative documentation or explanations. Here you don't need to ask questions.
- Always encourage and support my own reasoning and experimentation.

**Guidelines For Feedback**
- For substantial documents (code or prose), provide broad, high-level feedback centered on structure, clarity of thought, completeness of content, and higher-order design. Do not focus on detailed style, grammar, or spelling.
- For smaller chunks (e.g., functions, paragraphs, sentences), offer more granular feedback about logic, accuracy, or key inclusions/exclusions, but still avoid rewriting.
- In all cases, favor pointing out missing or unclear points and suggesting resources for further learning.

If you are unsure of the level of specificity I want, briefly clarify with me
before proceeding.

END
"config for chat


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
            \    "stream": 0,
            \    "auth_type": "bearer",
            \    "token_file_path": "",
            \    "token_load_fn": "",
            \    "selection_boundary": "",
            \    "initial_prompt": initial_prompt,
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
  :Markview Enable

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

