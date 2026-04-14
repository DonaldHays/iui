local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

local radius = 8

--- @param name string
--- @param value number
--- @param min number
--- @param max number
--- @return number
function iui.slider(name, value, min, max)
    local id = iui.beginID(name)

    local _, intrinsicH = iui.layout.getWantsIntrinsic()

    local disabled = iui.isDisabled()

    local x, y, w, h = iui.layout.getBounds()
    local percent = (value - min) / (max - min)
    local thumb = x + radius + iui.utils.round((w - radius * 2) * percent)

    if intrinsicH then
        iui.layout.setIntrinsicHeight(radius * 2)
    end

    if iui.layout.containsPoint() then
        iui.becomeHover()
    end

    if iui.hoverID == id and iui.input.mouse.pressed:has(1) then
        iui.becomeActive()
        iui.becomeFocus()
    end

    if iui.activeID == id then
        local mousePercent = (iui.input.mouse.x - x - radius) / (w - radius * 2)
        mousePercent = math.max(math.min(1, mousePercent), 0)

        value = min + mousePercent * (max - min)

        if not iui.input.mouse.down:has(1) then
            iui.activeID = nil
        end
    end

    if iui.isFocused(id) and iui.activeID ~= id then
        local increment = (max - min) / 10
        local base = iui.utils.round((value - min) / increment)
        if iui.input.keyboard.pressed["left"] then
            value = math.max(min, min + (base - 1) * increment)
        elseif iui.input.keyboard.pressed["right"] then
            value = math.min(max, min + (base + 1) * increment)
        end
    end

    percent = (value - min) / (max - min)
    thumb = x + radius + iui.utils.round((w - radius * 2) * percent)

    -- Track
    if disabled then
        iui.colors.sysGray100:set()
    else
        iui.colors.sysGray200:set()
    end
    iui.graphics.rectangle(
        x + radius, y + iui.utils.round(h / 2) - 2,
        w - radius * 2, 4,
        2, 2
    )

    iui.colors.sysGray50:set()
    iui.graphics.rectangle(
        x + radius + 1, y + iui.utils.round(h / 2) - 1,
        w - radius * 2 - 2, 2,
        1, 1
    )

    -- Thumb
    if disabled then
        iui.colors.sysGray100:set()
    elseif iui.isFocused(id) and iui.idiom ~= "vr" then
        iui.colors.sysAccent500:set()
    elseif iui.activeID == id then
        iui.colors.sysGray200:set()
    elseif iui.hoverID == id then
        iui.colors.sysGray400:set()
    else
        iui.colors.sysGray300:set()
    end
    iui.graphics.circle(thumb, y + iui.utils.round(h / 2), radius)

    if not disabled then
        if iui.activeID == id then
            iui.colors.sysGray50:set()
        elseif iui.hoverID == id then
            iui.colors.sysGray200:set()
        else
            iui.colors.sysGray100:set()
        end
        iui.graphics.circle(thumb, y + iui.utils.round(h / 2), radius - 1.5)
    end

    iui.endID()

    return value
end
