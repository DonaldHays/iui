local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param image any
function iui.image(image)
    local bx, by, bw, bh = iui.layout.getBounds()
    local iw, ih = iui.graphics.getImageDimensions(image)

    local aspectBounds = bw / bh
    local aspectImage = iw / ih

    local ox, oy, ow, oh = bx, by, bw, bh

    if true then
        if aspectImage > aspectBounds then
            ox = bx
            ow = bw
            oh = iui.utils.round(ow / aspectImage)
            oy = by + iui.utils.round((bh - oh) / 2)
        else
            oy = by
            oh = bh
            ow = iui.utils.round(oh * aspectImage)
            ox = bx + iui.utils.round((bw - ow) / 2)
        end
    end

    iui.draw(function()
        iui.colors.sysGray0:set()
        iui.graphics.rectangle(bx, by, bw, bh)

        iui.graphics.setColor(1, 1, 1)
        iui.graphics.image(image, ox, oy, ow, oh)
    end)
    iui.layout.advance()
end
