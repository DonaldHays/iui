local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @class IUIMenuBarStackItem
--- @field state any
--- @field controller IUISubMenuController
--- @field isShowingPanel boolean
--- @field x number
--- @field w number
--- @field h number
--- @field barHeight number

--- @type IUIMenuBarStackItem[]
local itemStack = {}

function iui.menuBar()
    local x, y, w, h = iui.layout.getPanelBounds()

    local barHeight = iui.layout.getDefaultRowHeight() + 1

    -- Draw bar
    iui.graphics.clip(x, y, w, barHeight)

    iui.colors.sysGray100:set()
    iui.draw.panelBackground(x, y, w, barHeight - 1)

    iui.colors.sysGray200:set()
    iui.graphics.rectangle(x, barHeight - 1, w, 1)

    iui.graphics.clip()

    local id = iui.beginID("__menuBar", false)
    local state = iui.state(id)

    if state.controller == nil then
        --- @type IUISubMenuController
        local subMenuController

        subMenuController = {
            subMenuIDs = {},
            isMenuBar = true,
            currentSubMenuIndex = 1,
            panelClaimedMouseDown = false,
            beginSubMenu = function()
                local subMenuID = subMenuController.subMenuIDs[subMenuController.currentSubMenuIndex]
                subMenuController.currentSubMenuIndex = subMenuController.currentSubMenuIndex + 1
                return subMenuID
            end,
            endSubMenu = function()
                subMenuController.currentSubMenuIndex = subMenuController.currentSubMenuIndex - 1
            end,
            setSubMenu = function(menuID)
                local subMenuIDs = subMenuController.subMenuIDs
                local idx = subMenuController.currentSubMenuIndex - 1
                if state.showingSubMenuController and menuID ~= subMenuIDs[idx] then
                    for i = idx, #subMenuIDs do
                        table.remove(subMenuIDs, i)
                    end
                    table.insert(subMenuIDs, menuID)
                end
            end,
            activate = function()
                state.showingSubMenuController = true
            end,
            deactivate = function()
                state.showingSubMenuController = false
            end
        }
        state.controller = subMenuController
    end

    local controller = state.controller

    iui.style.push()
    iui.style["menuItemSpacing"] = iui.style["spacing"] * 4
    iui.style["spacing"] = 0
    iui.style["subMenuController"] = controller
    controller.currentSubMenuIndex = 1
    controller.panelClaimedMouseDown = false
    controller.hoveredSubMenuIndex = nil

    local isShowingPanel = state.showingSubMenuController
    if isShowingPanel then
        iui.beginLayer("__menuBar")
    end

    if iui.idiom == "vr" then
        local radius = iui.style["vrWindowCornerRadius"]
        iui.layout.beginPanel(x + radius, y, w - radius * 2, barHeight - 1, 0)
    else
        iui.layout.beginPanel(x, y, w, barHeight - 1, 0)
    end

    iui.layout.beginIntrinsicRow(nil, nil, barHeight - 1)

    --- @type IUIMenuBarStackItem
    local item = iui.pool.get("menu_bar_stack_item")
    item.state = state
    item.controller = controller
    item.isShowingPanel = isShowingPanel
    item.barHeight = barHeight
    item.x = x
    item.w = w
    item.h = h

    table.insert(itemStack, item)
end

function iui.menuBarDivider()
    --- @type IUIMenuBarStackItem
    local item = table.remove(itemStack)
    local state = item.state
    local controller = item.controller
    local isShowingPanel = item.isShowingPanel
    local barHeight = item.barHeight
    local x, w, h = item.x, item.w, item.h

    iui.pool.put(item)

    iui.layout.endPanel()

    iui.style.pop()

    iui.endID(false)

    if controller.hoveredSubMenuIndex and controller.hoveredSubMenuIndex < #controller.subMenuIDs then
        state.vanishTimer = (state.vanishTimer or 0) + iui.dt
        if state.vanishTimer > 0.35 then
            for idx = controller.hoveredSubMenuIndex + 1, #controller.subMenuIDs do
                table.remove(controller.subMenuIDs, idx)
            end
        end
    else
        state.vanishTimer = nil
    end

    if not state.showingSubMenuController and #controller.subMenuIDs > 0 then
        controller.subMenuIDs = {}
    end

    if isShowingPanel then
        if iui.input.mouse.pressed:has(1) and not controller.panelClaimedMouseDown then
            iui.input.mouse.pressed:remove(1)
            controller.deactivate()
        end

        iui.endLayer()
    end

    -- Content panel
    iui.layout.beginPanel(x, barHeight, w, h - barHeight)
end

function iui.endMenuBar()
    iui.layout.endPanel()
end
