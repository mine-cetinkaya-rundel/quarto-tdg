---@alias CustomCallout.Appearance "default"|"simple"|"minimal"

---A custom callout definition from the `custom-callout` metadata, with its values normalized
---@class CustomCallout.Definition
---@field type string The type/identifier of the callout (its key under `custom-callout`)
---@field title string|pandoc.Inlines The title of the callout (defaults to the capitalized type)
---@field icon boolean|nil Whether to show an icon (nil uses Quarto's default)
---@field appearance CustomCallout.Appearance|nil The appearance style (Quarto treats other values as "default")
---@field collapse boolean|pandoc.Inlines|nil Whether the callout is collapsible, as written in the YAML (false becomes nil)
---@field icon_symbol string|nil Custom icon symbol, or a known FontAwesome icon name ("fa-...")
---@field color string|nil The color of the callout

-- Custom callout definitions by type
---@type table<string, CustomCallout.Definition>
local customCallouts = {}

-- Callout types in sorted order, so the generated styles are the same on every render
---@type string[]
local calloutTypes = {}

-- Whether any callout uses a FontAwesome icon
local needsFontAwesome = false

---Raw code placed before and after each callout of a type, outside HTML
---@class CustomCallout.Wrapper
---@field format string The raw format, such as "latex"
---@field open string Code before the callout
---@field close string Code after the callout

-- Wrappers that give each custom callout type its color and icon, by type
---@type table<string, CustomCallout.Wrapper>
local calloutWrappers = {}

local fa = require("fa")
local colors = require("colors")

-- Chevron for the collapse toggle
local CHEVRON_ICON = "url('data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"16\" height=\"16\" fill=\"rgb(33, 37, 41)\" class=\"bi bi-chevron-down\" viewBox=\"0 0 16 16\"><path fill-rule=\"evenodd\" d=\"M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z\"/></svg>')"

-- Default icon, a warning triangle; %s is the fill color (with '#' escaped as
-- %23 in the stylesheet)
local DEFAULT_ICON_SVG = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="%s" class="bi bi-exclamation-triangle" viewBox="0 0 16 16"><path d="M7.938 2.016A.13.13 0 0 1 8.002 2a.13.13 0 0 1 .063.016.146.146 0 0 1 .054.057l6.857 11.667c.036.06.035.124.002.183a.163.163 0 0 1-.054.06.116.116 0 0 1-.066.017H1.146a.115.115 0 0 1-.066-.017.163.163 0 0 1-.054-.06.176.176 0 0 1 .002-.183L7.884 2.073a.147.147 0 0 1 .054-.057zm1.044-.45a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566z"/></svg>'
local DEFAULT_ICON = "url('data:image/svg+xml," .. DEFAULT_ICON_SVG .. "')"

-- Quarto's callout cross-reference prefixes, as in #nte-my-note
local calloutCrossrefTypes = { nte = true, wrn = true, cau = true, tip = true, imp = true }

-- The alert types GitHub recognizes, as in > [!NOTE]
local githubAlertTypes = { note = true, tip = true, important = true, warning = true, caution = true }

-- Div attributes that set this extension's options, so they aren't passed on to the callout
local OPTION_ATTRIBUTES = { "title", "icon", "appearance", "collapse" }

---Returns the digits of a hex color, expanding the short forms #RGB and #RGBA
---@param color string The color string
---@return string|nil digits The 6 or 8 hex digits without '#', or nil if not a hex color
local function hexDigits(color)
  local digits = color:match("^#(%x+)$")
  if digits and (#digits == 3 or #digits == 4) then
    digits = digits:gsub("%x", "%0%0")
  end
  if digits and (#digits == 6 or #digits == 8) then
    return digits
  end
  return nil
end

---Converts a valid CSS color string or hexadecimal to RGBA format
---@param color string The color in hex (#RGB, #RRGGBB) or named format
---@param alpha number The alpha value between 0 and 1
---@return string rgba The color in rgba() or rgb(from color) format
local function colorToRgba(color, alpha)
  local digits = hexDigits(color)
  if digits then
    local r = tonumber(digits:sub(1,2), 16)
    local g = tonumber(digits:sub(3,4), 16)
    local b = tonumber(digits:sub(5,6), 16)
    return string.format("rgba(%d, %d, %d, %.2f)", r, g, b, alpha)
  else
    -- For named colors, we use the functional notation of rgba()
    return string.format("rgb(from %s r g b / %.0f%%)", color, alpha * 100)
  end
end

---Converts a color to hex digits for formats other than HTML: hex colors
---(without their alpha channel), CSS color names, and rgb() or rgba() with
---values from 0 to 255
---@param color string The color string
---@return string|nil hex Six hex digits without '#', or nil for other CSS colors
local function colorHex(color)
  local digits = hexDigits(color)
  if digits then
    return digits:sub(1, 6):upper()
  end
  local named = colors.css_color_hex(color)
  if named then
    return named
  end
  local r, g, b = color:match("^rgba?%(%s*(%d+)[%s,]+(%d+)[%s,]+(%d+)%s*[,/)]")
  if r then
    return string.format("%02X%02X%02X",
      math.min(tonumber(r) or 0, 255), math.min(tonumber(g) or 0, 255), math.min(tonumber(b) or 0, 255))
  end
  return nil
end

---Adds HTML dependency for the bundled FontAwesome 7 Free Solid and Brands fonts
local function ensureFontAwesomeDeps()
  quarto.doc.add_html_dependency({
    name = "fontawesome-7-free",
    version = "7.2.0",
    stylesheets = {"assets/css/fontawesome.css"},
    resources = {
      { name = "fa-solid-900.woff2", path = "assets/webfonts/fa-solid-900.woff2" },
      { name = "fa-brands-400.woff2", path = "assets/webfonts/fa-brands-400.woff2" }
    }
  })
end

---Checks if a string represents a Font Awesome icon
---@param icon string|nil The icon string to check
---@return boolean is_fa True if the string starts with "fa-"
local function isFontAwesomeIcon(icon)
  return icon ~= nil and icon:sub(1, 3) == "fa-"
end

---Reads a YAML true/false option, also accepting the strings "true" and "false"
---@param value any The metadata value
---@return boolean|nil bool The boolean value, or nil if unset or not a boolean
local function toBoolean(value)
  if type(value) == "boolean" or value == nil then
    return value
  end
  local str = pandoc.utils.stringify(value)
  if str == "true" then
    return true
  elseif str == "false" then
    return false
  end
  return nil
end

---Reads a YAML string option
---@param value any The metadata value
---@return string|nil str The value as plain text, or nil if unset
local function toString(value)
  if value == nil then
    return nil
  end
  return pandoc.utils.stringify(value)
end

---Generates the CSS declarations for a callout's icon
---@param callout CustomCallout.Definition The callout definition
---@return string|nil declarations The declarations, or nil if the icon keeps Quarto's styling
local function iconDeclarations(callout)
  local symbol = callout.icon_symbol
  if isFontAwesomeIcon(symbol) then
    ---@cast symbol string
    -- Font Awesome icon, from the brands font for brand logos
    local family, weight = "Font Awesome 7 Free", 900
    if fa.fa_is_brand(symbol) then
      family, weight = "Font Awesome 7 Brands", 400
    end
    return string.format(
      "  font-family: '%s';\n  font-weight: %d;\n  font-style: normal;\n  content: '%s' !important;\n  background-image: none;\n",
      family, weight, fa.fa_unicode(symbol)
    )
  elseif symbol then
    -- Custom icon symbol
    return string.format("  content: '%s';\n  background-image: none;\n", symbol)
  elseif callout.color then
    -- The fallback case: the default icon in the callout's color
    local escapedColor = callout.color:gsub("#", "%%23")
    return string.format("  background-image: %s;\n", DEFAULT_ICON:format(escapedColor))
  end
  return nil
end

---Generates CSS for all defined custom callouts
---@param isRevealJS boolean Whether the output format is RevealJS
---@return string css The generated CSS rules
local function generateCustomCSS(isRevealJS)
  ---@type string[]
  local css = {}
  -- RevealJS uses `.reveal div.callout...` selectors with higher specificity,
  -- so we need to match that prefix. It also uses `.callout-title` instead
  -- of `.callout-header` for the header element.
  local prefix = isRevealJS and ".reveal " or ""
  local headerClass = isRevealJS and ".callout-title" or ".callout-header"

  for _, type in ipairs(calloutTypes) do
    local callout = customCallouts[type]
    local selector = prefix .. "div.callout-" .. type
    local color = callout.color

    if color then
      -- Base color and header background
      css[#css + 1] = string.format("%s.callout {\n  border-left-color: %s;\n}\n", selector, color)
      css[#css + 1] = string.format("%s.callout-style-default %s {\n  background-color: %s;\n}\n",
        selector, headerClass, colorToRgba(color, 0.13))

      -- Collapse icon (not supported in RevealJS)
      if not isRevealJS then
        css[#css + 1] = string.format("%s .callout-toggle::before {  background-image: %s;}\n", selector, CHEVRON_ICON)
      end
    end

    local icon = iconDeclarations(callout)
    if icon then
      css[#css + 1] = string.format("%s.callout-style-default .callout-icon::before, %s.callout-titled .callout-icon::before {\n%s}\n",
        selector, selector, icon)
    end
  end
  return table.concat(css)
end

---Warns that a callout's color or icon symbol can't be used in an output format
---@param format string The format's name, such as "PDF"
---@param what string "color" or "icon symbol"
---@param value string The color or icon symbol
---@param callout CustomCallout.Definition The callout definition
---@param fallback string What is used instead
local function warnUnsupported(format, what, value, callout, fallback)
  quarto.log.warning(string.format(
    "custom-callout: %s output can't use the %s '%s' for the '%s' callout; using %s",
    format, what, value, callout.type, fallback
  ))
end

-- PDF output. Quarto draws callouts with tcolorbox and colors them with
-- per-type LaTeX colors, which unknown types share: quarto-callout-color and
-- quarto-callout-color-frame, with the \faInfo icon from the fontawesome5
-- package (callout_attrs in Quarto's share/filters/modules/callouts.lua). A
-- custom callout redefines those inside a group, so the change ends with the
-- callout.

-- Icon commands of Quarto's own callout types, which also have their own color names
local LATEX_TYPE_ICONS = {
  note = "faInfo",
  warning = "faExclamationTriangle",
  important = "faExclamation",
  caution = "faFire",
  tip = "faLightbulb"
}

---Gets the fontawesome5 command for a FontAwesome icon class: "fa-thumbs-up" becomes "faThumbsUp"
---@param class string The icon class
---@return string command The command name, without the backslash
local function latexIconCommand(class)
  local words = class:sub(4):gsub("%-(%w)", string.upper)
  return "fa" .. words:gsub("^%l", string.upper)
end

---Generates the LaTeX for a callout's icon. fontawesome5 has Font Awesome 5
---icons, so a FontAwesome icon tries each of its names, which include its
---Font Awesome 5 name, and falls back to the default icon
---@param callout CustomCallout.Definition The callout definition
---@return string|nil latex The icon, or nil to keep Quarto's icon
local function latexIcon(callout)
  -- The default icon, as in HTML: a warning triangle for a colored callout,
  -- or else Quarto's icon, saved as \customcalloutquartoicon
  local default = callout.color and "\\faExclamationTriangle" or "\\customcalloutquartoicon"
  local symbol = callout.icon_symbol

  if isFontAwesomeIcon(symbol) then
    ---@cast symbol string
    local latex, closing = "", ""
    for _, class in ipairs(fa.fa_aliases(symbol)) do
      local command = latexIconCommand(class)
      -- fontawesome5's \faH takes an argument, so calling it here would break
      if command ~= "faH" then
        latex = latex .. "\\ifcsname " .. command .. "\\endcsname\\" .. command .. "\\else"
        closing = closing .. "\\fi"
      end
    end
    return latex .. default .. closing
  elseif symbol then
    -- LaTeX's default fonts only have the ASCII characters for sure
    if symbol:match("^[\32-\126]+$") then
      return (pandoc.write(pandoc.Pandoc({ pandoc.Plain({ pandoc.Str(symbol) }) }), "latex"):gsub("%s+$", ""))
    end
    warnUnsupported("PDF", "icon symbol", symbol, callout, "the default icon")
    return callout.color and default or nil
  elseif callout.color then
    return default
  end
  return nil
end

---Generates the LaTeX wrapper that gives a callout its color and icon
---@param callout CustomCallout.Definition The callout definition
---@return CustomCallout.Wrapper|nil wrapper The wrapper, or nil if Quarto's styling is kept
local function latexWrapper(callout)
  local isQuartoType = LATEX_TYPE_ICONS[callout.type] ~= nil
  local colorName = isQuartoType and ("quarto-callout-" .. callout.type .. "-color") or "quarto-callout-color"
  local iconCommand = LATEX_TYPE_ICONS[callout.type] or "faInfo"
  ---@type string[]
  local lines = {}

  if callout.color then
    local hex = colorHex(callout.color)
    if hex then
      lines[#lines + 1] = string.format("\\definecolor{%s}{HTML}{%s}", colorName, hex)
      lines[#lines + 1] = string.format("\\definecolor{%s-frame}{HTML}{%s}", colorName, hex)
    else
      warnUnsupported("PDF", "color", callout.color, callout, "the default color")
    end
  end

  -- The icon is set even with icon: false, which a callout can override
  local icon = latexIcon(callout)
  if icon then
    lines[#lines + 1] = "\\let\\customcalloutquartoicon\\" .. iconCommand
    lines[#lines + 1] = "\\protected\\def\\" .. iconCommand .. "{" .. icon .. "}"
  end

  if #lines == 0 then
    return nil
  end
  return { format = "latex", open = "\\begingroup\n" .. table.concat(lines, "\n"), close = "\\endgroup" }
end

-- Typst output. Quarto draws each callout with the `callout` function from
-- its Typst template (share/formats/typst/pandoc/quarto/definitions.typ):
--   callout(body: [], title: "Callout", background_color: rgb("#dddddd"),
--     icon: none, icon_color: black, body_background_color: white)
-- Unknown types get a gray background and fa-info() from the fontawesome
-- package Quarto imports, which has Font Awesome 6. A custom callout goes in
-- a content block that shadows `callout` with a function that passes on its
-- colors and icon, so other callouts keep their own.

---Quotes a string for Typst code
---@param str string The string
---@return string quoted The Typst string literal
local function typstString(str)
  return '"' .. str:gsub('[\\"]', '\\%0') .. '"'
end

---Generates the Typst expression for a callout's icon. A FontAwesome icon
---tries each of its names, as Font Awesome 6 may know it under another
---one, and falls back to the default icon. `quarto-icon` is Quarto's icon
---@param callout CustomCallout.Definition The callout definition
---@return string|nil typst The icon expression, or nil to keep Quarto's icon
local function typstIcon(callout)
  -- The default icon, as in HTML: a warning triangle for a colored callout
  local default = callout.color and 'fa-icon("triangle-exclamation", solid: true)' or "quarto-icon"
  local symbol = callout.icon_symbol

  if isFontAwesomeIcon(symbol) then
    ---@cast symbol string
    -- Brand icons are in the regular-weight brands font, the others in the solid font
    local solid = fa.fa_is_brand(symbol) and "" or ", solid: true"
    local typst = ""
    for _, class in ipairs(fa.fa_aliases(symbol)) do
      local name = typstString(class:sub(4))
      typst = typst .. "if " .. name .. " in fa-icon-map { fa-icon(" .. name .. solid .. ") } else "
    end
    return typst .. "{ " .. default .. " }"
  elseif symbol then
    return typstString(symbol)
  elseif callout.color then
    return default
  end
  return nil
end

---Generates the Typst wrapper that gives a callout its color and icon
---@param callout CustomCallout.Definition The callout definition
---@return CustomCallout.Wrapper|nil wrapper The wrapper, or nil if Quarto's styling is kept
local function typstWrapper(callout)
  ---@type string[]
  local args = {}

  if callout.color then
    local hex = colorHex(callout.color)
    if hex then
      -- The title background is the color at 13%, as in HTML
      args[#args + 1] = string.format('background_color: rgb("#%s").lighten(87%%)', hex)
      args[#args + 1] = string.format('icon_color: rgb("#%s")', hex)
    else
      warnUnsupported("Typst", "color", callout.color, callout, "the default color")
    end
  end

  -- Quarto passes icon: none for icon: false
  local icon = typstIcon(callout)
  if icon then
    args[#args + 1] = 'icon: { let quarto-icon = quarto-args.named().at("icon", default: none); '
      .. 'if quarto-icon == none { none } else { ' .. icon .. ' } }'
  end

  if #args == 0 then
    return nil
  end
  return {
    format = "typst",
    open = "#[\n#let custom-callout-quarto = callout\n"
      .. "#let callout(..quarto-args) = custom-callout-quarto(..quarto-args, " .. table.concat(args, ", ") .. ")",
    close = "]"
  }
end

-- EPUB output. Quarto doesn't put a filter's stylesheet or HTML dependencies
-- into an EPUB, so a custom callout carries its styles in attributes, which
-- customcallout-epub.lua turns into inline styles once Quarto has rendered
-- the callout. Without the Font Awesome fonts, FontAwesome icons can't show.

---EPUB styles for one callout type
---@class CustomCallout.EpubStyles
---@field border string|nil The left border color
---@field title string|nil The title background color
---@field icon string|nil HTML for the icon

-- Attributes that carry a callout's EPUB styles to customcallout-epub.lua,
-- as {style field, attribute name}
local EPUB_ATTRIBUTES = {
  { "border", "custom-callout-border" },
  { "title", "custom-callout-title-background" },
  { "icon", "custom-callout-icon" }
}

-- EPUB styles by callout type
---@type table<string, CustomCallout.EpubStyles>
local epubStyles = {}

---Generates the EPUB styles of a callout
---@param callout CustomCallout.Definition The callout definition
---@return CustomCallout.EpubStyles|nil styles The styles, or nil if Quarto's styling is kept
local function epubCalloutStyles(callout)
  ---@type CustomCallout.EpubStyles
  local styles = {}
  local hex = callout.color and colorHex(callout.color)
  if hex then
    styles.border = "#" .. hex
    -- The title background is the color at 13%, as in HTML (the default appearance only)
    if callout.appearance == nil or callout.appearance == "default" then
      styles.title = colorToRgba("#" .. hex, 0.13)
    end
  elseif callout.color then
    warnUnsupported("EPUB", "color", callout.color, callout, "the default color")
  end

  -- The icon sits where Quarto's icon would, with the same spacing
  local iconStyle = "display: inline-block; margin-top: 0.5rem; padding-right: 0.5rem; font-style: normal;"
  local triangle = '<span style="' .. iconStyle .. '">'
    .. DEFAULT_ICON_SVG:format(hex and ("#" .. hex) or "#909090")
      :gsub("^<svg ", '<svg style="width: 0.9rem; height: 0.9rem;" ')
    .. "</span>"
  local symbol = callout.icon_symbol
  if isFontAwesomeIcon(symbol) then
    ---@cast symbol string
    warnUnsupported("EPUB", "icon symbol", symbol, callout, "the default icon")
    styles.icon = callout.color and triangle or nil
  elseif symbol then
    local text = symbol:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    styles.icon = '<span style="' .. iconStyle .. '">' .. text .. "</span>"
  elseif callout.color then
    styles.icon = triangle
  end

  if next(styles) == nil then
    return nil
  end
  return styles
end

---Reads one custom callout definition from its metadata
---@param key string The callout type (its key under `custom-callout`)
---@param options table The callout's metadata map
---@return CustomCallout.Definition definition The normalized definition
local function readDefinition(key, options)
  local icon_symbol = toString(options['icon-symbol'])

  -- An unknown FontAwesome name falls back to the default icon
  if isFontAwesomeIcon(icon_symbol) and fa.fa_unicode(icon_symbol --[[@as string]]) == nil then
    quarto.log.warning(string.format(
      "custom-callout: unknown FontAwesome icon '%s' for the '%s' callout; using the default icon",
      icon_symbol, key
    ))
    icon_symbol = nil
  end

  return {
    type = key,
    title = options.title or key:gsub("^%l", string.upper),
    icon = toBoolean(options.icon),
    appearance = toString(options.appearance) --[[@as CustomCallout.Appearance|nil]],
    collapse = options.collapse or nil,
    icon_symbol = icon_symbol,
    color = toString(options.color)
  }
end

---Parses custom callout definitions from document metadata
---@param meta pandoc.Meta The document metadata
local function parseCustomCallouts(meta)
  local definitions = meta['custom-callout']
  if type(definitions) ~= "table" then return end

  for k, v in pairs(definitions) do
    if type(k) == "string" and type(v) == "table" then
      local callout = readDefinition(k, v)
      customCallouts[k] = callout
      table.insert(calloutTypes, k)
      needsFontAwesome = needsFontAwesome or isFontAwesomeIcon(callout.icon_symbol)
    end
  end
  table.sort(calloutTypes)

  -- HTML and RevealJS get a stylesheet. PDF and Typst wrap each callout in
  -- code that sets its color and icon, and EPUB callouts carry their styles.
  -- Other formats use Quarto's styling for unknown callout types.
  if quarto.doc.is_format("epub") then
    for _, type in ipairs(calloutTypes) do
      epubStyles[type] = epubCalloutStyles(customCallouts[type])
    end
  elseif quarto.doc.is_format("html") then
    local customCSS = generateCustomCSS(quarto.doc.is_format("revealjs"))
    if customCSS ~= "" then
      quarto.doc.include_text('in-header', '<style>\n' .. customCSS .. '</style>')
    end
    if needsFontAwesome then
      ensureFontAwesomeDeps()
    end
  elseif quarto.doc.is_format("latex") then
    for _, type in ipairs(calloutTypes) do
      calloutWrappers[type] = latexWrapper(customCallouts[type])
    end
  elseif quarto.doc.is_format("typst") then
    for _, type in ipairs(calloutTypes) do
      calloutWrappers[type] = typstWrapper(customCallouts[type])
    end
  end
end

---Puts a callout between its type's wrapper code, if it has one
---@param type string The callout type
---@param block pandoc.Block The callout
---@return pandoc.Block|pandoc.Blocks blocks The callout with its wrapper code
local function wrapCallout(type, block)
  local wrapper = calloutWrappers[type]
  if wrapper == nil then
    return block
  end
  return pandoc.Blocks({
    pandoc.RawBlock(wrapper.format, wrapper.open),
    block,
    pandoc.RawBlock(wrapper.format, wrapper.close)
  })
end

---Converts a div to a custom callout if it matches a defined custom callout
---@param div pandoc.Div The div to potentially convert
---@return pandoc.Block|pandoc.Blocks converted The converted callout or original div
local function convertToCustomCallout(div)
  for _, class in ipairs(div.classes) do
    local callout = customCallouts[class]

    if callout then
      -- Use the default title if not provided
      local title = callout.title

      -- Check to see if the title is specified in the div content
      -- (a title attribute wins, and the header then stays in the content).
      -- The title is the header's text, as in Quarto's own callouts; the
      -- Header itself would become a real section heading in PDF and Typst
      local first = div.content[1]
      if div.attributes.title == nil and first ~= nil and first.t == "Header" then
        ---@cast first pandoc.Header
        title = first.content
        div.content:remove(1)
      end

      -- Keep the div's id, other classes and attributes, minus this extension's options
      local attr = div.attr:clone()
      attr.classes = attr.classes:filter(function(c) return c ~= class end)
      for _, option in ipairs(OPTION_ATTRIBUTES) do
        attr.attributes[option] = nil
      end

      -- Create a new Callout with the custom callout parameters
      local calloutParams = {
        type = callout.type,
        content = div.content,
        title = div.attributes.title or title,
        icon = div.attributes.icon or callout.icon,
        appearance = div.attributes.appearance or callout.appearance,
        collapse = div.attributes.collapse or callout.collapse,
        attr = attr
      }

      -- EPUB styles go in attributes, which Quarto moves to a Div around the callout
      local styles = epubStyles[callout.type]
      if styles then
        for _, field in ipairs(EPUB_ATTRIBUTES) do
          attr.attributes[field[2]] = styles[field[1]]
        end
      end

      -- GitHub Markdown shows an alert type it doesn't know as plain text, so
      -- other types become a note, which keeps the callout's title
      if quarto.doc.is_format("gfm") and not githubAlertTypes[callout.type] then
        calloutParams.type = "note"
      end

      -- Outside HTML, Quarto's callouts drop an ID that isn't a cross-reference ID,
      -- so the ID goes on a wrapping Div, which every writer turns into an anchor
      local id = attr.identifier
      local idPrefix = id:match("^(%a+)%-")
      local isCrossref = idPrefix ~= nil and calloutCrossrefTypes[idPrefix:lower()] ~= nil
      if id ~= "" and not isCrossref and not quarto.doc.is_format("html") then
        attr.identifier = ""
        return wrapCallout(callout.type, pandoc.Div({ (quarto.Callout(calloutParams)) }, pandoc.Attr(id)))
      end

      return wrapCallout(callout.type, (quarto.Callout(calloutParams)) --[[@as pandoc.Block]])
    end
  end

  return div
end

---Walks the document body and converts divs to custom callouts
---@param doc pandoc.Pandoc The Pandoc document
---@return pandoc.Pandoc doc The processed document
local function customCalloutFilter(doc)
  doc.blocks = doc.blocks:walk({
    Div = convertToCustomCallout
  }) --[[@as pandoc.Blocks]]
  return doc
end

-- Return the Pandoc filter
return {
  Meta = parseCustomCallouts,
  Pandoc = customCalloutFilter
}
