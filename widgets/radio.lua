local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @generic T
--- @param name string
--- @param current T
--- @param value T
--- @return T
function iui.radio(name, current, value)
    local id = iui.beginID(name)

    local intrinsicW, intrinsicH = iui.layout.getWantsIntrinsic()

    local disabled = iui.isDisabled()

    local font = iui.style["font"]
    local padding = iui.style["padding"]

    local textH = math.ceil(font:getHeight())
    local size = textH + 2
    local textX = size + padding

    if intrinsicW then
        local textW = math.ceil(font:getWidth(name))
        iui.layout.setIntrinsicWidth(textX + textW)
    end

    if intrinsicH then
        iui.layout.setIntrinsicHeight(size)
    end

    if iui.layout.containsPoint() then
        iui.becomeHover()
    end

    if iui.hoverID == id and iui.input.mouse.pressed:has(1) then
        iui.becomeActive()
        iui.becomeFocus()
    end

    if iui.activeID == id then
        if not iui.input.mouse.down:has(1) then
            if iui.hoverID == id then
                current = value
            end

            iui.activeID = nil
        end
    end

    if iui.isFocused(id) then
        if iui.input.keyboard.pressed["space"] then
            current = value
        end
    end

    local x, y, _, h = iui.layout.getBounds()

    local textY = y + iui.utils.round((h - textH) / 2)

    local radius = math.ceil(size / 2)
    local radioY = y + iui.utils.round((h - size) / 2)

    iui.draw(function()
        -- Outline
        if not disabled then
            if iui.isFocused(id) and iui.idiom ~= "vr" then
                iui.colors.sysAccent500:set()
            elseif iui.hoverID == id then
                iui.colors.sysGray300:set()
            else
                iui.colors.sysGray200:set()
            end
            iui.graphics.circle(x + radius, radioY + radius, radius)
        end

        -- Background
        if (iui.hoverID == id and iui.activeID == id) or disabled then
            iui.colors.sysGray100:set()
        else
            iui.colors.sysGray0:set()
        end
        iui.graphics.circle(x + radius, radioY + radius, radius - 1.5)

        -- Check
        if current == value then
            if disabled then
                iui.colors.sysGray200:set()
            elseif iui.hoverID == id and iui.activeID == id then
                iui.colors.sysGray200:set()
            elseif iui.hoverID == id then
                iui.colors.sysGray400:set()
            else
                iui.colors.sysGray300:set()
            end

            iui.graphics.circle(x + radius, radioY + radius, radius - 4)
        end

        -- Label
        if disabled then
            iui.colors.sysGray300:set()
        else
            iui.colors.sysGray900:set()
        end
        iui.graphics.setFont(font)
        iui.graphics.print(name, x + textX, textY)
    end)

    iui.endID()

    return current
end
