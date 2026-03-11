" Opencode configuration (Vimscript)

" Options
set autoread
let g:opencode_opts = {}

" Toggle Opencode panel
nnoremap sc <cmd>lua require('opencode').toggle()<CR>
tnoremap sc <cmd>lua require('opencode').toggle()<CR>

" Ask Opencode about current context
nnoremap <leader>oa <cmd>lua require('opencode').ask("@this: ", { submit = true })<CR>
xnoremap <leader>oa <cmd>lua require('opencode').ask("@this: ", { submit = true })<CR>

" Select from prompts/commands
nnoremap <leader>os <cmd>lua require('opencode').select()<CR>
xnoremap <leader>os <cmd>lua require('opencode').select()<CR>

" Operator: send range/motion to Opencode
nnoremap <expr> go luaeval('require("opencode").operator("@this ")')
xnoremap <expr> go luaeval('require("opencode").operator("@this ")')
nnoremap <expr> goo luaeval('require("opencode").operator("@this ")') .. "_"

" Scroll Opencode panel
nnoremap <leader>ou <cmd>lua require('opencode').command('session.half.page.up')<CR>
nnoremap <leader>od <cmd>lua require('opencode').command('session.half.page.down')<CR>
