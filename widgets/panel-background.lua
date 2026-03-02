local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param color? IUIColor
function iui.panelBackground(color)
    color = color or iui.colors.sysGray50
    local x, y, w, h = iui.layout.getPanelBounds()
    iui.draw(function()
        color:set()
        iui.draw.panelBackground(x, y, w, h)
    end)
end
