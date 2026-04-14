local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param image IUILayeredImage
function iui.msdfLayeredImage(image)
    local bx, by, bw, bh = iui.layout.getBounds()
    local iw, ih = iui.graphics.getImageDimensions(image[1].image)

    local mode = iui.style["imageMode"] or "aspectFit" --- @type IUIImageMode
    local clip = iui.style["imageClip"] or false       --- @type boolean

    local ox, oy, ow, oh = iui.utils.fill(mode, iw, ih, bx, by, bw, bh)

    if clip then
        iui.draw.pushClip(bx, by, bw, bh)
    end

    for _, item in ipairs(image) do
        item.color:set()
        iui.graphics.msdfImage(item.image, ox, oy, ow, oh)
    end

    if clip then
        iui.draw.popClip()
    end

    iui.layout.advance()
end
