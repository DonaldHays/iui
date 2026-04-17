local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @class (exact) IUIListViewStackItem
--- @field maxIndex number
--- @field panel IUILayoutPanel
--- @field spacing number
--- @field margin number
--- @field rowHeight number
--- @field yOffset number

--- @type IUIListViewStackItem[]
local listStack = {}

--- @class IUIListManager: IUIScrollManager
--- @field rowHeight? number
local ListManager = {}
ListManager.__index = ListManager
setmetatable(ListManager, iui.ScrollManager)

--- @param state IUIListViewStackItem
--- @param idx number
local function listViewStep(state, idx)
    idx = idx + 1
    if idx <= state.maxIndex then
        local panel = state.panel
        local spacing = state.spacing
        local margin = state.margin
        local rowHeight = state.rowHeight
        local yOffset = state.yOffset

        local spaced = rowHeight + spacing

        panel.rowY = (idx - 1) * spaced + margin - yOffset
        iui.layout.beginDynamicRow(1, rowHeight)

        return idx
    end
end

--- @param index number
function ListManager:scrollToIndex(index)
    local rowHeight = self.rowHeight
    if rowHeight == nil then
        return
    end

    local margin = iui.style["margin"]
    local spacing = iui.style["spacing"]

    local top = margin + (index - 1) * (rowHeight + spacing)

    self:scrollTo(0, top, nil, rowHeight)
end

--- @return IUIListManager
function iui.newListManager()
    local super = iui.newScrollManager()

    --- @type IUIListManager
    local out = setmetatable(super --[[@as any]], ListManager)

    return out
end

--- @param name string
---@param count number
---@param rowHeight? number
---@param manager? IUIListManager
function iui.listView(name, count, rowHeight, manager)
    rowHeight = rowHeight or iui.layout.getDefaultRowHeight()
    local id = iui.beginID(name, false)
    local state = iui.state(id)

    local margin = iui.style["margin"]
    local spacing = iui.style["spacing"]

    local spaced = rowHeight + spacing

    if not manager then
        manager = state.manager

        if not manager then
            manager = iui.newListManager()
            state.manager = manager
        end
    end

    manager.rowHeight = rowHeight

    iui.scrollView("ScrollView", manager)

    --- @type IUIListViewStackItem
    local item = iui.pool.get("list_view_stack_item")
    table.insert(listStack, item)

    if count > 0 then
        local panel = iui.layout.getPanel()
        local yOffset = iui.utils.round(manager.y)

        panel.contentHeight = math.max(
            panel.contentHeight, count * spaced - spacing + margin * 2 - yOffset
        )

        local minIndex = math.max(
            math.floor((yOffset - margin) / spaced) + 1, 1
        )

        local maxIndex = math.min(
            math.ceil((yOffset + panel.h - margin) / spaced), count
        )

        item.panel = panel
        item.margin = margin
        item.spacing = spacing
        item.rowHeight = rowHeight
        item.yOffset = yOffset
        item.maxIndex = maxIndex

        return listViewStep, item, minIndex - 1
    end
end

function iui.endListView()
    iui.endScrollView()

    iui.endID(false)

    iui.pool.put(table.remove(listStack))
end
