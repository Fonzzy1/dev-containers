function Str(el)
  local citekey = el.text:match("%[%[([%a%d_.-]+)%]%]")
  if citekey then
    local s = string.gsub(citekey, "[%[%]@]", "")
    local citation
    if el.text:match("^%-") then
      citation = pandoc.Citation(s, 'AuthorInText')
    else
      citation = pandoc.Citation(s, 'NormalCitation')
    end
    return pandoc.Cite({pandoc.Str(s)}, {citation})
  else
    return el
  end
end
