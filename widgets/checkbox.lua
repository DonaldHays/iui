local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

local checkmarkImage

--- @param name string
--- @param checked boolean
--- @return boolean
function iui.checkbox(name, checked)
    if checkmarkImage == nil then
        checkmarkImage = iui.backend.system.getMSDFImage(
            "assets/glyph-checkmark.png"
        )
    end

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

    if iui.hoverID == id and iui.input.mouse.pressed[1] then
        iui.becomeActive()
        iui.becomeFocus()
    end

    if iui.activeID == id then
        if not iui.input.mouse.down[1] then
            if iui.hoverID == id then
                checked = not checked
            end

            iui.activeID = nil
        end
    end

    if iui.isFocused(id) then
        if iui.input.keyboard.pressed["space"] then
            checked = not checked
        end
    end

    local x, y, _, h = iui.layout.getBounds()

    local textY = y + iui.utils.round((h - textH) / 2)
    local boxY = y + iui.utils.round((h - size) / 2)

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
            iui.graphics.rectangle(x, boxY, size, size, 2, 2)
        end

        -- Background
        if (iui.hoverID == id and iui.activeID == id) or disabled then
            iui.colors.sysGray100:set()
        else
            iui.colors.sysGray0:set()
        end
        iui.graphics.rectangle(x + 1, boxY + 1, size - 2, size - 2, 1, 1)

        -- Check
        if checked then
            if disabled then
                iui.colors.sysGray200:set()
            elseif iui.hoverID == id and iui.activeID == id then
                iui.colors.sysGray200:set()
            elseif iui.hoverID == id then
                iui.colors.sysGray400:set()
            else
                iui.colors.sysGray300:set()
            end

            iui.graphics.msdfImage(
                checkmarkImage, x + 2, boxY + 2, size - 4, size - 4
            )
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

    return checked
end
