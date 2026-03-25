local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param image IUIImage9Slice
function iui.image9Slice(image)
    local x, y, w, h = iui.layout.getBounds()
    local filter = iui.style["imageFilter"] or "linear" --- @type IUIImageFilter

    iui.draw(function()
        iui.graphics.setColor(1, 1, 1)
        iui.graphics.nineSlice(image, filter, x, y, w, h)
    end)

    iui.layout.advance()
end
