let g:model = 'gpt-5.4'
let g:vim_ai_debug = 1
let g:instruct_model = "gpt-5.4-mini"
let g:vim_ai_role = ''
let g:vim_ai_chat_markdown = 0
let g:vim_ai_async_chat = 1
if filereadable(".roles.ini")
  let g:vim_ai_roles_config_file = ".roles.ini"
endif


" This prompt instructs model to work with syntax highlighting
let g:initial_chat_prompt =<< trim END
>>> system

You are a general assistant, but your default role is reviewer-editor and helpful generalist peer, not primary creator or expert authority.

Your job is to preserve and improve my work without replacing my authorship. Treat my input as the source of truth for intent, reasoning, structure, and style. Prefer critique, explanation, and minimal suggested changes over wholesale rewriting.

Default behaviour:
- review before rewriting
- explain before replacing
- suggest before generating
- patch locally rather than rewrite globally
- do not output full-file or full-passage replacements unless explicitly asked

When responding to my work:
- identify issues briefly and clearly
- suggest minimal replacements with explanations
- preserve as much of my original material as possible
- keep changes local, targeted, and reversible
- offer alternatives only when they are genuinely useful

For prose:
- preserve voice, tone, argument, and stylistic character
- improve clarity, flow, grammar, and precision without flattening the writing

For code:
- preserve intent and overall structure
- improve correctness, readability, maintainability, robustness, typing, and documentation
- suggest local fixes before major refactors
- do not rewrite entire files or large blocks unless explicitly requested

If I provide a clear spec, outline, bullet points, pseudocode, or partial draft, you may generate a fuller result from that material, since the underlying ideas and direction are already mine. In those cases, stay within scope and avoid unnecessary invention.

Do not treat polish as an excuse for authorship. The goal is to shape and refine my work, not do the work for me.

For research or exploratory tasks, act as a strong generalist rather than a specialist. AI is useful here as a synthesiser and orienting tool, not as a substitute for raw sources or deep expertise. Your main value is helping me figure out what to read, what to look up, and which names, concepts, debates, methods, or literatures are relevant.

In research mode:
- help me locate the field rather than summarise it too confidently
- suggest authors, foundational works, concepts, search terms, schools of thought, methods, and recent developments
- point me toward useful references and directions for further reading
- make clear when you are offering high-level synthesis rather than established detail
- avoid pretending to know my project better than I do
- avoid overstating certainty in specialised areas

If unsure whether I want review, minimal edits, full generation, or research orientation, ask first.

Do not end responses with follow-up offers, suggested next steps, or unsolicited menus of options. Answer the request at hand and stop.

When including code blocks, always specify the language after the opening triple backticks (```language) and close the code block with triple backticks (```).

END

let g:vim_ai_chat = {
            \  "provider": "openai",
            \  "options": {
            \    "model": g:model,
            \    "stream": 1,
            \    "selection_boundary": "```",
            \    "initial_prompt": g:initial_chat_prompt,
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




lua << EOF

local actions        = require "telescope.actions"
local action_state   = require('telescope.actions.state')
local pickers        = require('telescope.pickers')
local finders        = require('telescope.finders')
local conf           = require('telescope.config').values
local themes         = require("telescope.themes")
local previewers     = require("telescope.previewers")

local function get_roles_file()
    local configured = vim.g.vim_ai_roles_config_file
    if configured and configured ~= "" then
        return vim.fn.expand(configured)
    end
    return vim.fn.expand(".roles.ini")
end

local function parse_roles_ini(path)
    if vim.fn.filereadable(path) == 0 then
        vim.notify("roles file not found: " .. path, vim.log.levels.ERROR)
        return {}
    end

    local lines = vim.fn.readfile(path)
    local roles = {}
    local current = nil
    local collecting_prompt = false

    for _, line in ipairs(lines) do
        local section = line:match("^%[([^%]]+)%]$")
        if section then
            current = {
                name = section,
                prompt_lines = {},
                temperature = nil,
            }
            table.insert(roles, current)
            collecting_prompt = false
        elseif current then
            if line:match("^prompt%s*=%s*$") then
                collecting_prompt = true
            elseif collecting_prompt then
                if line:match("^%[([^%]]+)%]$") or line:match("^%S.-%s*=") then
                    collecting_prompt = false

                    local temp = line:match("^options%.temperature%s*=%s*(.+)$")
                    if temp then
                        current.temperature = temp
                    end
                else
                    local content = line:gsub("^%s%s", "", 1)
                    table.insert(current.prompt_lines, content)
                end
            else
                local temp = line:match("^options%.temperature%s*=%s*(.+)$")
                if temp then
                    current.temperature = temp
                end
            end
        end
    end

    for _, role in ipairs(roles) do
        role.prompt = table.concat(role.prompt_lines, "\n")
        if role.prompt == "" then
            role.prompt = "(no prompt found)"
        end
    end

    return roles
end

local function ai_roles_picker()
    local roles = parse_roles_ini(get_roles_file())

    if not roles or vim.tbl_isempty(roles) then
        vim.notify("No roles found", vim.log.levels.WARN)
        return
    end

    pickers.new({
        prompt_title = "AI Roles",
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = {
            width = 0.9,
            height = 0.85,
            preview_width = 0.7,
            prompt_position = "top",
        },
    }, {
        finder = finders.new_table({
            results = roles,
            entry_maker = function(role)
                return {
                    value = role,
                    display = role.name,
                    ordinal = role.name .. " " .. (role.prompt or ""),
                }
            end,
        }),

        sorter = conf.generic_sorter({}),

        previewer = previewers.new_buffer_previewer({
            title = "Role Prompt",
            define_preview = function(self, entry, _)
                local role = entry.value
                local lines = {
                    "[" .. role.name .. "]",
                    "prompt =",
                }

                for _, l in ipairs(role.prompt_lines or {}) do
                    table.insert(lines, "  " .. l)
                end

                if role.temperature then
                    table.insert(lines, "")
                    table.insert(lines, "options.temperature = " .. role.temperature)
                end

                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                vim.bo[self.state.bufnr].filetype = "dosini"
                vim.bo[self.state.bufnr].modifiable = false
            end,
        }),

        attach_mappings = function(prompt_bufnr, map)
            local function run_role()
                local selection = action_state.get_selected_entry()
                if not selection then
                    return
                end
                actions.close(prompt_bufnr)
                vim.cmd("AIC /" .. selection.value.name)
            end

            map("i", "<CR>", run_role)
            map("n", "<CR>", run_role)

            return true
       end,
    }):find()
end

vim.api.nvim_create_user_command("AIRoles", ai_roles_picker, {})

EOF
