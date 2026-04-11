local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

local utf8 = require "utf8"

--- @param name string
--- @param s string
--- @return string
function iui.textField(name, s)
    local id = iui.beginID(name)

    local state = iui.state(id)

    local x, y, w, h = iui.layout.getBounds()

    local disabled = iui.isDisabled()

    local font = iui.style["font"]
    local padding = iui.style["padding"]

    if iui.layout.containsPoint() then
        iui.becomeHover()
    end

    if iui.hoverID == id then
        iui.cursor = "ibeam"

        if iui.input.mouse.pressed:has(1) then
            iui.becomeFocus()
        end
    end

    if iui.isFocused(id) then
        state.time = (state.time or 0) + iui.dt
        if state.showCursor == nil then
            state.showCursor = true
        end

        while state.time > 0.5 do
            state.showCursor = not state.showCursor
            state.time = state.time - 0.5
        end

        local changedBuffer = false

        if iui.input.textBuffer ~= nil then
            s = s .. iui.input.textBuffer
            iui.input.textBuffer = nil

            changedBuffer = true
        end

        if iui.input.keyboard.pressed["backspace"] then
            local idx = utf8.offset(s, -1)
            if idx then
                s = string.sub(s, 1, idx - 1)

                changedBuffer = true
            end
        end

        if changedBuffer then
            state.showCursor = true
            state.time = 0
        end
    else
        state.time = nil
        state.showCursor = nil
    end

    iui.draw(function()
        -- Outline
        if iui.isFocused(id) then
            iui.colors.sysAccent500:set()
        elseif iui.hoverID == id then
            iui.colors.sysGray300:set()
        else
            iui.colors.sysGray200:set()
        end
        iui.graphics.rectangle(x, y, w, h, 8, 8)

        -- Background
        if disabled then
            iui.colors.sysGray100:set()
        else
            iui.colors.sysGray0:set()
        end
        iui.graphics.rectangle(x + 1, y + 1, w - 2, h - 2, 7, 7)

        if disabled then
            iui.colors.sysGray300:set()
        else
            iui.colors.sysGray900:set()
        end
        iui.graphics.setFont(font)
        local textW, textH = font:getWidth(s), font:getHeight()
        local textY = y + iui.utils.round((h - textH) / 2)
        iui.graphics.print(s, x + padding, textY)

        if iui.isFocused(id) and state.showCursor then
            iui.colors.sysAccent500:set()
            local radius = (iui.detail == "high" and 1 or nil)
            iui.graphics.rectangle(x + padding + textW, textY, 2, textH, radius, radius)
        end
    end)

    iui.endID()

    return s
end
