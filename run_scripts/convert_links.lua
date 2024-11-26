function Str(el)
  -- Match citation pattern and capture citation key and trailing punctuation optionally.
  local citekey, trailing_punctuation = el.text:match("%[%[([%a%d_.-]+)%]%](%p?)")
  if citekey then
    -- Escape [[ and @ from the citation key
    local s = string.gsub(citekey, "[%[%]@]", "")
    local citation
    -- Determine citation mode
    if el.text:match("^%-") then
      citation = pandoc.Citation(s, 'AuthorInText')
    else
      citation = pandoc.Citation(s, 'NormalCitation')
    end
    
    -- Return the modified element including handling for punctuation
    if trailing_punctuation and trailing_punctuation ~= "" then
      return {pandoc.Cite({pandoc.Str(s)}, {citation}), pandoc.Str(trailing_punctuation)}
    else
      return pandoc.Cite({pandoc.Str(s)}, {citation})
    end
  else
    return el
  end
end
