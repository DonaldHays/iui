local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @alias IUIScrollBarDirection "horiz" | "vert"

--- @param name string
--- @param dir IUIScrollBarDirection
--- @param value number
--- @param length number
--- @param min number
--- @param max number
--- @return number
function iui.scrollBar(name, dir, value, length, min, max)
    local id = iui.beginID(name, false)
    local state = iui.state(id)

    local x, y, w, h = iui.layout.getBounds()
    local mx = iui.input.mouse.x
    local my = iui.input.mouse.y

    local pixelToValue = (max - min) / h
    local mousePos = (my - y) * pixelToValue

    local isScrollable = length < (max - min)

    if isScrollable then
        if iui.layout.containsPoint() then
            iui.becomeHover()
        end

        if iui.hoverID == id and iui.input.mouse.pressed:has(1) then
            iui.becomeActive()

            if (mousePos < value) or (mousePos >= (value + length)) then
                state.offset = length / 2
            else
                state.offset = mousePos - value
            end
        end
    end

    if iui.activeID == id then
        value = math.min(math.max(mousePos - state.offset, min), max - length)

        if not iui.input.mouse.down:has(1) then
            iui.activeID = nil
        end
    end

    if isScrollable then
        iui.colors.sysGray0:set()
        iui.graphics.rectangle(x, y, w, h)

        local bx, by = x, y + (value / (max - min)) * h
        local bw, bh = w, (length / (max - min)) * h
        local by2 = by + bh
        by = iui.utils.round(by)
        bh = iui.utils.round(by2) - by

        if iui.hoverID == id or iui.activeID == id then
            iui.colors.sysGray200:set()
        else
            iui.colors.sysGray100:set()
        end
        iui.graphics.rectangle(bx, by, bw, bh)

        iui.colors.sysGray200:set()
        iui.graphics.rectangle(bx, by - 1, bw, 1)
        iui.graphics.rectangle(bx, by + bh, bw, 1)
    else
        iui.colors.sysGray50:set()
        iui.graphics.rectangle(x, y, w, h)
    end

    iui.endID()

    return value
end
