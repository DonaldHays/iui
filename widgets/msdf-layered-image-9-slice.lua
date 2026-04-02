local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param image IUILayeredImage
function iui.msdfLayeredImage9Slice(image)
    local x, y, w, h = iui.layout.getBounds()

    iui.draw(function()
        for _, item in ipairs(image) do
            item.color:set()
            iui.graphics.msdfNineSlice(item.image, x, y, w, h)
        end
    end)

    iui.layout.advance()
end
