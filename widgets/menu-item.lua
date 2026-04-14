local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @param name string
--- @param command? string
--- @return boolean
function iui.menuItem(name, command)
    if iui.idiom ~= "desktop" then
        command = nil
    end

    local id = iui.beginID(name, false)

    local intrinsicW, intrinsicH = iui.layout.getWantsIntrinsic()

    local disabled = iui.isDisabled()
    local pressed = false

    local font = iui.style["font"]
    local padding = iui.style["padding"]
    local spacing = iui.style["menuItemSpacing"]

    local nameW = math.ceil(font:getWidth(name))
    local commandW = command and math.ceil(font:getWidth(command))
    local textH = math.ceil(font:getHeight())

    if intrinsicW then
        if command then
            iui.layout.setIntrinsicWidth(nameW + spacing + commandW + padding * 2)
        else
            iui.layout.setIntrinsicWidth(nameW + padding * 2)
        end
    end

    if intrinsicH then
        iui.layout.setIntrinsicHeight(textH + padding * 2)
    end

    if iui.layout.containsPoint() then
        iui.becomeHover()
    end

    if iui.input.mouse.released:has(1) then
        if iui.hoverID == id then
            pressed = true
            --- @type IUISubMenuController
            local controller = iui.style["subMenuController"]
            controller.deactivate()
        end
    end

    local x, y, w, h = iui.layout.getBounds()
    -- Background
    if iui.hoverID == id then
        iui.colors.sysGray200:set()
        iui.graphics.rectangle(x + 4, y, w - 8, h, 2, 2)
    end

    if disabled then
        iui.colors.sysGray300:set()
    else
        iui.colors.sysGray900:set()
    end
    iui.graphics.setFont(font)
    local textX = x + padding
    local textY = y + iui.utils.round((h - textH) / 2)
    iui.graphics.print(name, textX, textY)

    if command and commandW then
        local commandX = x + w - padding - commandW
        iui.graphics.print(command, commandX, textY)
    end

    iui.endID()

    return pressed
end
