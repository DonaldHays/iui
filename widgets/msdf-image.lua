local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param image any
--- @param color? IUIColor
function iui.msdfImage(image, color)
    color = color or iui.colors.white

    local bx, by, bw, bh = iui.layout.getBounds()
    local iw, ih = iui.graphics.getImageDimensions(image)

    local mode = iui.style["imageMode"] or "aspectFit" --- @type IUIImageMode
    local clip = iui.style["imageClip"] or false       --- @type boolean

    local ox, oy, ow, oh = iui.utils.fill(mode, iw, ih, bx, by, bw, bh)

    if clip then
        iui.draw.pushClip(bx, by, bw, bh)
    end

    color:set()
    iui.graphics.msdfImage(image, ox, oy, ow, oh)

    if clip then
        iui.draw.popClip()
    end

    iui.layout.advance()
end
