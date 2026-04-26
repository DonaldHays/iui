local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @class (exact) IUIListViewStackItem
--- @field manager IUIListManager
--- @field isMouseInBounds boolean
--- @field maxIndex number
--- @field panel IUILayoutPanel
--- @field spacing number
--- @field margin number
--- @field rowHeight number
--- @field yOffset number
--- @field lastX number
--- @field lastY number
--- @field lastW number
--- @field lastH number

--- @type IUIListViewStackItem[]
local listStack = {}

--- @class IUIListManager: IUIScrollManager
--- @field rowHeight? number
--- @field margin? number
--- @field spacing? number
--- @field selection IUISet<number>
--- @field allowsSelection boolean
--- @field allowsMultipleSelection boolean
--- @field allowsEmptySelection boolean
local ListManager = {}
ListManager.__index = ListManager
setmetatable(ListManager, iui.ScrollManager)

--- @return boolean
local function isHoldingMeta()
    local keyboard = iui.input.keyboard
    local down = keyboard.down
    local primary = keyboard.getPrimaryModifierKeycode()

    return down:has("lshift") or down:has(primary)
end

--- @param state IUIListViewStackItem
--- @param idx number
local function updateSelection(state, idx)
    local manager = state.manager

    -- Selection can only change if the list allows selection at all, and the
    -- pointer is inside the widget.
    if not manager.allowsSelection or not state.isMouseInBounds then
        return
    end

    -- Did the mouse begin being pressed this frame, and has no widget
    -- claimed the pointer?
    --
    -- This `if` clause here is why we do all the selection change logic at
    -- the beginning of `listViewStep`. The *previous* row will have been
    -- generated, and any widgets inside them will have been given the
    -- opportunity to claim the active id.
    if iui.activeID ~= nil or not iui.input.mouse.pressed:has(1) then
        return
    end

    -- As a base case, this method will be called before the first row has been
    -- generated, and we need to exit out of that case. The "last" row bounds
    -- will not exist yet, because there hasn't been a "last" row yet.
    local x, y, w, h = state.lastX, state.lastY, state.lastW, state.lastH
    if not x then
        return
    end

    -- We already know the mouse is in the list view's bounds, now we just need
    -- to make sure it's in the row's bounds.
    local mx, my = iui.input.mouse.x, iui.input.mouse.y
    if not iui.utils.rectContains(x, y, w, h, mx, my) then
        return
    end

    local selection = manager.selection

    -- Is this row already part of the selection?
    if selection:has(idx) then
        local count = selection:getCount()

        -- Do we have multiple items already selected?
        if count > 1 then
            -- If the user's holding the modifier key, remove only this item
            -- from the selection. Otherwise, remove every item *but* this one.
            if isHoldingMeta() then
                selection:remove(idx)
            else
                selection:removeAll()
                selection:put(idx)
            end
        elseif manager.allowsEmptySelection then
            -- If this row is selected, and it's the only item in the selection,
            -- we can only remove it if we're allowed to have an empty
            -- selection.
            selection:remove(idx)
        end
    else
        -- This row is not selected, so we need to add it to the selection.

        -- In general, clicking a row should remove every row from the
        -- selection, and then select the new row. But if multiple selection is
        -- allowed, and the user's holding an appropriate modifier key, the new
        -- row should be added to the existing selection instead.
        if not manager.allowsMultipleSelection or not isHoldingMeta() then
            selection:removeAll()
        end

        selection:put(idx)
    end
end

--- @param state IUIListViewStackItem
--- @param idx number
local function listViewStep(state, idx)
    updateSelection(state, idx)

    idx = idx + 1
    if idx <= state.maxIndex then
        local manager = state.manager
        local panel = state.panel
        local spacing = state.spacing
        local margin = state.margin
        local rowHeight = state.rowHeight
        local yOffset = state.yOffset

        local spaced = rowHeight + spacing

        panel.rowY = (idx - 1) * spaced + margin - yOffset
        iui.layout.beginDynamicRow(1, rowHeight)

        local x, y, w, h = iui.layout.getBounds()
        x = x - margin
        w = w + margin * 2

        state.lastX, state.lastY, state.lastW, state.lastH = x, y, w, h

        if manager.selection:has(idx) then
            iui.colors.sysAccent500:set()
            iui.graphics.rectangle(x, y, w, h)
        end

        return idx
    end
end

--- @param index number
function ListManager:scrollToIndex(index)
    local rowHeight = self.rowHeight
    local margin = self.margin
    local spacing = self.spacing
    if rowHeight == nil then
        return
    end

    local top = margin + (index - 1) * (rowHeight + spacing)

    self:scrollTo(0, top, nil, rowHeight)
end

--- @return IUIListManager
function iui.newListManager()
    local super = iui.newScrollManager()

    --- @type IUIListManager
    local out = setmetatable(super --[[@as any]], ListManager)

    out.selection = iui.set.new()
    out.allowsSelection = true
    out.allowsEmptySelection = true
    out.allowsMultipleSelection = false

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
    local isMouseInBounds = iui.layout.containsPoint()

    if not manager then
        manager = state.manager

        if not manager then
            manager = iui.newListManager()
            state.manager = manager
        end
    end

    manager.rowHeight = rowHeight
    manager.margin = margin
    manager.spacing = spacing

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

        item.manager = manager
        item.isMouseInBounds = isMouseInBounds
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
