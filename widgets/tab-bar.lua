local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param items fun()
--- @param content fun()
function iui.tabBar(items, content)
    local x, y, w, h = iui.layout.getPanelBounds()

    local barHeight = iui.layout.getDefaultRowHeight() + 1

    iui.draw(function()
        iui.colors.sysGray100:set()
        iui.draw.panelBackground(x, y, w, barHeight - 1)

        iui.colors.sysGray200:set()
        iui.graphics.rectangle(x, y + barHeight - 1, w, 1)
    end)

    iui.layout.beginPanel(x + 1, y, w - 2, barHeight, 0)
    iui.layout.beginRow({ kind = "intrinsic" }, barHeight)
    iui.style.push()
    iui.style["spacing"] = 0
    items()
    iui.style.pop()
    iui.layout.endPanel()

    iui.layout.beginPanel(x, y + barHeight, w, h - barHeight)
    content()
    iui.layout.endPanel()
end

--- @generic T
--- @param name string
--- @param current T
--- @param value T
--- @return T
function iui.tabItem(name, current, value)
    local id = iui.beginID(name)
    local out = current

    local intrinsicW, intrinsicH = iui.layout.getWantsIntrinsic()

    local font = iui.style["font"]
    local padding = iui.style["padding"]

    local textH = math.ceil(font:getHeight())
    local size = textH + 2

    if intrinsicW then
        local textW = math.ceil(font:getWidth(name))
        iui.layout.setIntrinsicWidth(textW + padding * 4)
    end

    if intrinsicH then
        iui.layout.setIntrinsicHeight(size)
    end

    if iui.layout.containsPoint() then
        iui.becomeHover()
    end

    if iui.hoverID == id and iui.input.mouse.pressed[1] then
        out = value
        iui.becomeFocus()
    end

    if iui.isFocused(id) then
        if iui.input.keyboard.pressed["space"] then
            out = value
        end
    end

    local x, y, w, h = iui.layout.getBounds()

    local textX = x + padding * 2
    local textY = y + iui.utils.round((h - textH) / 2)

    iui.draw(function()
        local top = y + 1
        local fh = h - 9

        --- @type IUIColor
        local backgroundColor

        if out == value then
            iui.graphics.clip(x, y, w + 1, h)
            backgroundColor = iui.colors.sysGray50
            textY = textY
            fh = fh + 2
        else
            iui.graphics.clip(x, y, w + 1, h - 1)
            top = top + 2
            textY = textY + 1

            if iui.hoverID == id then
                backgroundColor = iui.colors.sysGray200
            else
                backgroundColor = iui.colors.sysGray100
            end
        end

        -- Outline
        iui.colors.sysGray200:set()
        iui.graphics.rectangle(x, top, w + 1, h + 6, 6, 6)

        -- Background
        backgroundColor:set()
        iui.graphics.rectangle(x + 1, top + 1, w - 1, h + 5, 5, 5)

        if iui.idiom ~= "vr" and iui.isFocused(id) then
            iui.colors.sysAccent500:set()
            iui.graphics.rectangle(x + padding, y + h - 6, w - padding * 2, 2, 1, 1)
        end

        -- Label
        iui.colors.sysGray900:set()
        iui.graphics.setFont(font)
        iui.graphics.print(name, textX, textY)

        iui.graphics.clip()
    end)

    iui.endID()

    return out
end
