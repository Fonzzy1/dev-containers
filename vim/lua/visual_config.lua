require('csvview')

require('vimade').setup{
  recipe = {'duo', {animate = false}},
  fadelevel = function(style, state)
    if style.win.buf_opts.syntax == 'nerdtree' or 
       style.win.buf_opts.filetype == 'aeriel' then
      return 0.9
    else
      return 0.4
    end
  end
}
