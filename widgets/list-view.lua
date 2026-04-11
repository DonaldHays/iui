local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @class IUIListManager: IUIScrollManager
local ListManager = {}
ListManager.__index = ListManager
setmetatable(ListManager, iui.ScrollManager)

--- @return IUIListManager
function iui.newListManager()
    local super = iui.newScrollManager()

    --- @type IUIListManager
    local out = setmetatable(super --[[@as any]], ListManager)

    return out
end

--- @param name string
---@param count number
---@param rowHeight number
---@param itemBuilder fun(index: number)
---@param manager? IUIListManager
function iui.listView(name, count, rowHeight, itemBuilder, manager)
    local id = iui.beginID(name, false)
    local state = iui.state(id)

    local margin = iui.style["margin"]

    if not manager then
        manager = state.manager

        if not manager then
            manager = iui.newListManager()
            state.manager = manager
        end
    end

    iui.scrollView("ScrollView", function()
        local panel = iui.layout.getPanel()
        panel.contentHeight = math.max(
            panel.contentHeight, count * rowHeight + margin * 2 - manager.y
        )

        local minIndex = math.max(
            math.floor((manager.y - margin) / rowHeight) + 1, 1
        )

        local maxIndex = math.min(
            math.ceil((manager.y + panel.h - margin) / rowHeight), count
        )

        for index = minIndex, maxIndex do
            panel.rowY = (index - 1) * rowHeight + margin - manager.y
            iui.layout.beginRow({ kind = "dynamic", count = 1 }, rowHeight)
            itemBuilder(index)
        end
    end, manager)

    iui.endID(false)
end
