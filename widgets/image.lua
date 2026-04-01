local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @alias IUIImageMode "fill" | "aspectFit" | "aspectFill" | "center"

--- @param image any
function iui.image(image)
    local bx, by, bw, bh = iui.layout.getBounds()
    local iw, ih = iui.graphics.getImageDimensions(image)

    local filter = iui.style["imageFilter"] or "linear" --- @type IUIImageFilter
    local mode = iui.style["imageMode"] or "aspectFit"  --- @type IUIImageMode
    local clip = iui.style["imageClip"] or false        --- @type boolean

    local ox, oy, ow, oh = iui.utils.fill(mode, iw, ih, bx, by, bw, bh)

    if clip then
        iui.draw.pushClip(bx, by, bw, bh)
    end

    iui.draw(function()
        iui.graphics.setColor(1, 1, 1)
        iui.graphics.image(image, filter, ox, oy, ow, oh)
    end)

    if clip then
        iui.draw.popClip()
    end

    iui.layout.advance()
end
