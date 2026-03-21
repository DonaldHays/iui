local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @alias IUIImageMode "fill" | "aspectFit" | "aspectFill" | "center"

--- @param image any
function iui.image(image)
    local bx, by, bw, bh = iui.layout.getBounds()
    local iw, ih = iui.graphics.getImageDimensions(image)

    local aspectBounds = bw / bh
    local aspectImage = iw / ih

    local ox, oy, ow, oh = bx, by, bw, bh

    local mode = iui.style["imageMode"] or "aspectFit" --- @type IUIImageMode
    local clip = iui.style["imageClip"] or false       --- @type boolean

    if mode == "fill" then
        -- No changes necessary
    elseif mode == "aspectFit" then
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
    elseif mode == "aspectFill" then
        if aspectImage < aspectBounds then
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
    elseif mode == "center" then
        ow, oh = iw, ih
        ox = bx + iui.utils.round((bw - ow) / 2)
        oy = by + iui.utils.round((bh - oh) / 2)
    end

    if clip then
        iui.draw.pushClip(bx, by, bw, bh)
    end

    iui.draw(function()
        iui.colors.sysGray0:set()
        iui.graphics.rectangle(bx, by, bw, bh)

        iui.graphics.setColor(1, 1, 1)
        iui.graphics.image(image, ox, oy, ow, oh)
    end)

    if clip then
        iui.draw.popClip()
    end

    iui.layout.advance()
end
