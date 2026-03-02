local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param content fun()
function iui.clipView(content)
    local x, y, w, h = iui.layout.getBounds()
    iui.draw.pushClip(x, y, w, h)
    iui.layout.beginPanel(x, y, w, h)
    content()
    iui.layout.endPanel()
    iui.draw.popClip()
end
