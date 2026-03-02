local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

function iui.label(text)
    local intrinsicW, intrinsicH = iui.layout.getWantsIntrinsic()

    local disabled = iui.isDisabled()
    local font = iui.style["font"]
    local padding = iui.style["padding"]

    local textW = math.ceil(font:getWidth(text))
    local textH = font:getHeight()

    if intrinsicW then
        iui.layout.setIntrinsicWidth(textW + padding * 2)
    end

    if intrinsicH then
        iui.layout.setIntrinsicHeight(math.ceil(textH))
    end

    local x, y, w, h = iui.layout.getBounds()

    iui.draw(function()
        if disabled then
            iui.colors.sysGray300:set()
        else
            iui.colors.sysGray900:set()
        end
        iui.graphics.setFont(font)
        local textX = x + iui.utils.round((w - textW) / 2)
        local textY = y + iui.utils.round((h - textH) / 2)
        iui.graphics.print(text, textX, textY)
    end)

    iui.layout.advance()
end
