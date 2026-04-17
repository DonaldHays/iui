local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

function iui.clipView()
    local x, y, w, h = iui.layout.getBounds()
    iui.draw.pushClip(x, y, w, h)
    iui.layout.beginPanel(x, y, w, h)
end

function iui.endClipView()
    iui.layout.endPanel()
    iui.draw.popClip()
end
