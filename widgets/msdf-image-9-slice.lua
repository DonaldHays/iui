local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param image IUIImage9Slice
--- @param color? IUIColor
function iui.msdfImage9Slice(image, color)
    color = color or iui.colors.white

    local x, y, w, h = iui.layout.getBounds()

    iui.draw(function()
        color:set()
        iui.graphics.msdfNineSlice(image, x, y, w, h)
    end)

    iui.layout.advance()
end
