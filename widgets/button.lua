local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param name string
--- @return boolean
function iui.button(name)
    local id = iui.beginID(name)

    local intrinsicW, intrinsicH = iui.layout.getWantsIntrinsic()

    local pressed = false
    local disabled = iui.isDisabled()

    local font = iui.style["font"]
    local padding = iui.style["padding"]

    local textW = math.ceil(font:getWidth(name))
    local textH = math.ceil(font:getHeight())

    if intrinsicW then
        iui.layout.setIntrinsicWidth(textW + padding * 4)
    end

    if intrinsicH then
        iui.layout.setIntrinsicHeight(textH + padding * 2)
    end

    if iui.layout.containsPoint() then
        iui.becomeHover()
    end

    if iui.hoverID == id and iui.input.mouse.pressed[1] then
        iui.becomeActive()
        iui.becomeFocus()
    end

    if iui.activeID == id then
        if not iui.input.mouse.down[1] then
            if iui.hoverID == id then
                pressed = true
            end

            iui.activeID = nil
        end
    end

    if iui.isFocused(id) then
        if iui.input.keyboard.pressed["space"] then
            pressed = true
        end
    end

    local x, y, w, h = iui.layout.getBounds()

    iui.draw(function()
        -- Outline
        if not disabled then
            if iui.isFocused(id) and iui.idiom ~= "vr" then
                iui.colors.sysAccent500:set()
            elseif (iui.activeID == id and iui.hoverID == id) or pressed then
                iui.colors.sysGray200:set()
            elseif iui.hoverID == id then
                iui.colors.sysGray400:set()
            else
                iui.colors.sysGray300:set()
            end
            iui.graphics.rectangle(x, y, w, h, 8, 8)
        end

        -- Background
        if (iui.activeID == id and iui.hoverID == id) or pressed then
            iui.colors.sysGray50:set()
        elseif iui.hoverID == id then
            iui.colors.sysGray200:set()
        else
            iui.colors.sysGray100:set()
        end
        iui.graphics.rectangle(x + 1, y + 1, w - 2, h - 2, 7, 7)

        if disabled then
            iui.colors.sysGray300:set()
        else
            iui.colors.sysGray900:set()
        end
        iui.graphics.setFont(font)
        local textX = x + iui.utils.round((w - textW) / 2)
        local textY = y + iui.utils.round((h - textH) / 2)
        iui.graphics.print(name, textX, textY)
    end)

    iui.endID()

    return pressed
end
