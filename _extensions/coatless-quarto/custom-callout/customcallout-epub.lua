-- Styles custom callouts in EPUB output, after Quarto has rendered them.
-- Quarto doesn't put a filter's stylesheet into an EPUB, so customcallout.lua
-- marks each custom callout with attributes that hold its styles. Quarto
-- moves those to a Div around the callout, which it renders as
--
--   <div class="callout callout-TYPE ..."><div class="callout-body">
--     <div class="callout-title"><div class="callout-icon-container">
--       <i class='callout-icon'></i></div><p><strong>Title</strong></p></div>
--     <div class="callout-content">...</div></div></div>
--
-- This filter turns the attributes into inline styles on that markup and
-- removes the Div again.

-- The attributes customcallout.lua sets
local BORDER = "custom-callout-border"
local TITLE_BACKGROUND = "custom-callout-title-background"
local ICON = "custom-callout-icon"

---Gets a Div's first block if it is a Div with a class
---@param div pandoc.Div|nil The Div
---@param class string The class
---@return pandoc.Div|nil first The first block, or nil if it is something else
local function firstDiv(div, class)
  local first = div and div.content[1]
  if first and first.t == "Div" and first.classes:includes(class) then
    return first --[[@as pandoc.Div]]
  end
  return nil
end

---Moves a custom callout's styles from the Div around it onto the callout
---@param div pandoc.Div A Div that may hold a custom callout's styles
---@return pandoc.Div|pandoc.Blocks|nil styled The styled callout, or nil to leave the Div alone
local function styleCallout(div)
  local border = div.attributes[BORDER]
  local titleBackground = div.attributes[TITLE_BACKGROUND]
  local icon = div.attributes[ICON]
  if border == nil and titleBackground == nil and icon == nil then
    return nil
  end
  div.attributes[BORDER] = nil
  div.attributes[TITLE_BACKGROUND] = nil
  div.attributes[ICON] = nil

  local callout = firstDiv(div, "callout")
  if callout then
    -- Quarto also gives the Div the callout's id, which must be unique
    if callout.identifier == div.identifier then
      div.identifier = ""
    end
    if border then
      -- Quarto's own callout types set their border color with !important
      callout.attributes["style"] = "border-left-color: " .. border .. " !important;"
    end
    local title = firstDiv(firstDiv(callout, "callout-body"), "callout-title")
    if title and titleBackground then
      title.attributes["style"] = "background-color: " .. titleBackground .. ";"
    end
    local iconContainer = firstDiv(title, "callout-icon-container")
    local placeholder = iconContainer and iconContainer.content[1]
    if icon and placeholder and placeholder.t == "Plain" then
      ---@cast placeholder pandoc.Plain
      placeholder.content = pandoc.Inlines({ pandoc.RawInline("html", icon) })
    end
  end

  -- Keep the Div only if it still has the callout's id, classes or attributes
  if div.identifier == "" and #div.classes == 0 and #div.attributes == 0 then
    return pandoc.Blocks(div.content)
  end
  return div
end

if not quarto.doc.is_format("epub") then
  return {}
end

return {
  Div = styleCallout
}
