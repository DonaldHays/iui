local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @class IUISubMenuController
--- @field isMenuBar boolean
--- @field subMenuIDs number[]
--- @field currentSubMenuIndex number
--- @field hoveredSubMenuIndex? number
--- @field panelClaimedMouseDown boolean
--- @field beginSubMenu fun(): number?
--- @field endSubMenu fun()
--- @field setSubMenu fun(id: number)
--- @field activate fun()
--- @field deactivate fun()

--- @class (exact) IUISubMenuStackItem
--- @field state { panelW: number, panelH: number }

--- @type IUISubMenuStackItem[]
local subMenuStack = {}

local disclosureImage

--- @param name string
--- @return boolean isOpen
function iui.subMenu(name)
    if disclosureImage == nil then
        disclosureImage = iui.backend.system.getMSDFImage(
            "assets/glyph-disclosure.png"
        )
    end

    local id = iui.beginID(name, false)
    local state = iui.state(id)

    local intrinsicW, intrinsicH = iui.layout.getWantsIntrinsic()

    local font = iui.style["font"]
    local padding = iui.style["padding"]
    local spacing = iui.style["menuItemSpacing"]

    --- @type IUISubMenuController
    local controller = iui.style["subMenuController"]
    local isPanelSubMenu = iui.style["isPanelSubMenu"] or false

    local textW = math.ceil(font:getWidth(name))
    local textH = math.ceil(font:getHeight())
    local discSize = textH - 2

    if intrinsicW then
        if isPanelSubMenu then
            iui.layout.setIntrinsicWidth(
                textW + padding * 2 + spacing + discSize
            )
        else
            iui.layout.setIntrinsicWidth(textW + padding * 2)
        end
    end

    if intrinsicH then
        iui.layout.setIntrinsicHeight(textH + padding * 2)
    end

    if iui.layout.containsPoint() then
        iui.becomeHover()
    end

    local isShowingPanel = false
    local subMenuID = controller.beginSubMenu()
    if subMenuID == id then
        if iui.hoverID == id and iui.input.mouse.pressed:has(1) then
            if not isPanelSubMenu then
                controller.deactivate()
            else
                isShowingPanel = true
            end
            iui.input.mouse.pressed:remove(1)
        else
            isShowingPanel = true
        end
    end

    if iui.hoverID == id then
        local clicked = false
        if iui.input.mouse.pressed:has(1) then
            if not isPanelSubMenu then
                controller.activate()
            end
            iui.input.mouse.pressed:remove(1)
            clicked = true
        end

        state.hoverTime = (state.hoverTime or 0) + iui.dt

        if state.hoverTime > 0.2 or clicked or not isPanelSubMenu then
            controller.setSubMenu(id)
        end

        if (controller.hoveredSubMenuIndex or 0) < controller.currentSubMenuIndex - 1 then
            controller.hoveredSubMenuIndex = controller.currentSubMenuIndex - 1
        end
    else
        state.hoverTime = nil
    end

    local x, y, w, h = iui.layout.getBounds()

    iui.draw(function()
        -- Background
        if isPanelSubMenu then
            if iui.hoverID == id or subMenuID == id then
                iui.colors.sysGray200:set()
                iui.graphics.rectangle(x + 4, y, w - 8, h, 2, 2)
            end
        else
            if iui.hoverID == id or subMenuID == id then
                iui.colors.sysGray200:set()
                iui.graphics.rectangle(x, y + 2, w, h - 4, 2, 2)
            end
        end

        iui.colors.sysGray900:set()
        iui.graphics.setFont(font)
        local textX
        local textY = y + iui.utils.round((h - textH) / 2)
        if isPanelSubMenu then
            textX = x + padding
            local discY = y + iui.utils.round((h - discSize) / 2)
            iui.graphics.msdfImage(
                disclosureImage, x + w - padding - discSize, discY, discSize, discSize
            )
        else
            textX = x + iui.utils.round((w - textW) / 2)
        end
        iui.graphics.print(name, textX, textY)
    end)

    iui.endID()

    if isShowingPanel then
        local panelX, panelY
        if isPanelSubMenu then
            panelX = x + w
            panelY = y - 5
        else
            panelX = x
            panelY = y + h - 2
        end
        local panelW = state.panelW or 200
        local panelH = state.panelH or 400

        local mx, my = iui.input.mouse.x, iui.input.mouse.y
        if mx >= panelX and my >= panelY and mx < panelX + panelW and my < panelY + panelH then
            if iui.input.mouse.pressed:has(1) then
                controller.panelClaimedMouseDown = true
            end

            if (controller.hoveredSubMenuIndex or 0) < controller.currentSubMenuIndex - 1 then
                controller.hoveredSubMenuIndex = controller.currentSubMenuIndex - 1
            end
        end

        if state.panelH == nil then
            iui.draw.beginHiding()
        end

        -- Panel background
        iui.draw(function()
            iui.colors.sysGray300:set()
            iui.graphics.rectangle(panelX, panelY, panelW, state.panelH, 4, 4)

            iui.colors.sysGray100:set()
            iui.graphics.rectangle(panelX + 1, panelY + 1, panelW - 2, state.panelH - 2, 3, 3)
        end)

        iui.layout.beginPanel(panelX, panelY, panelW, panelH, 1)
        iui.style.push()
        iui.style["subMenuController"] = controller
        iui.style["isPanelSubMenu"] = true
        iui.layout.beginRow({ kind = "dynamic", count = 1 }, 4)
        iui.layout.spacer()

        if state.panelW then
            iui.layout.beginRow({ kind = "dynamic", count = 1 })
        else
            iui.layout.beginRow({ kind = "intrinsic", limit = 1, default = 10 })
        end

        --- @type IUISubMenuStackItem
        local stackItem = {
            state = state
        }
        table.insert(subMenuStack, stackItem)
    else
        controller.endSubMenu()
    end

    return isShowingPanel
end

function iui.endSubMenu()
    --- @type IUISubMenuStackItem
    local stackItem = table.remove(subMenuStack)

    local state = stackItem.state

    if state.panelH == nil then
        iui.draw.endHiding()
    end

    state.panelW, state.panelH = iui.layout.getContentSize()
    state.panelW = math.max(state.panelW, 100)
    state.panelH = state.panelH + 4

    --- @type IUISubMenuController
    local controller = iui.style["subMenuController"]
    controller.endSubMenu()

    iui.style.pop()
    iui.layout.endPanel(false)
end
