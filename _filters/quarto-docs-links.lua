--- quarto-docs-links.lua
--- Adds the class `quarto-docs` to links that point at the Quarto
--- documentation (https://quarto.org/docs/...), so they can be styled
--- and identified programmatically.
---
--- Currently only applied to HTML output.

local DOCS_CLASS = "quarto-docs"

local function is_quarto_docs(href)
  return href:match("^https?://quarto%.org/docs/") ~= nil
    or href:match("^https?://quarto%.org/docs$") ~= nil
    or href:match("^https?://www%.quarto%.org/docs/") ~= nil
end

local function has_class(el, class)
  for _, c in ipairs(el.classes) do
    if c == class then
      return true
    end
  end
  return false
end

if not quarto.doc.is_format("html") then
  return {}
end

return {
  {
    Link = function(el)
      if is_quarto_docs(el.target) and not has_class(el, DOCS_CLASS) then
        el.classes:insert(DOCS_CLASS)
        return el
      end
    end,
  },
}
