local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

local barHeight = 16

--- @param value number The progress value.
--- @param min? number The lower bound. Defaults to 0.
--- @param max? number The upper bound. Defaults to 1.
function iui.progress(value, min, max)
    min = min or 0
    max = max or 1

    local _, intrinsicH = iui.layout.getWantsIntrinsic()

    local disabled = iui.isDisabled()

    local x, y, w, h = iui.layout.getBounds()
    y = math.floor(y + (h - barHeight) * 0.5)
    h = barHeight

    local bx, by, bw, bh = x + 2, y + 2, w - 4, h - 4

    if intrinsicH then
        iui.layout.setIntrinsicHeight(barHeight)
    end

    iui.draw(function()
        -- Border
        iui.colors.sysGray200:set()
        iui.graphics.rectangle(x, y, w, h, 4, 4)

        -- Background
        if disabled then
            iui.colors.sysGray100:set()
        else
            iui.colors.sysGray0:set()
        end
        iui.graphics.rectangle(x + 1, y + 1, w - 2, h - 2, 3, 3)

        -- Bar
        local shouldClip = value > min and value < max
        if shouldClip then
            local percent = (value - min) / (max - min)
            percent = iui.utils.clamp(percent, 0, 1)

            -- Force at least one full pixel and one empty pixel
            local width = iui.utils.clamp(
                iui.utils.round(bw * percent), 1, bw - 1
            )
            iui.graphics.clip(bx, by, width, bh)
        end

        if value > min then
            if disabled then
                iui.colors.sysGray200:set()
            else
                iui.colors.sysAccent500:set()
            end
            iui.graphics.rectangle(bx, by, bw, bh, 2, 2)
        end

        if shouldClip then
            iui.graphics.clip()
        end
    end)

    iui.layout.advance()
end
