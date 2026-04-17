local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @alias IUISplitViewDirection "horiz" | "vert"
--- @alias IUISplitViewSide "min" | "max"

--- @class (exact) IUISplitStackItem
--- @field direction IUISplitViewDirection
--- @field current number
--- @field x number
--- @field y number
--- @field w number
--- @field h number

--- @type IUISplitStackItem[]
local splitStack = {}

--- @param name string
--- @param direction IUISplitViewDirection
--- @param current number
--- @return number
function iui.splitView(name, direction, current)
    local id = iui.beginID(name, false)
    local state = iui.state(id)

    local x, y, w, h = iui.layout.getPanelBounds()

    local mx = iui.input.mouse.x
    local my = iui.input.mouse.y
    local spacing = iui.style["spacing"]
    local splitMinEdge = iui.style["splitMinEdge"] or 8
    local splitMaxEdge = iui.style["splitMaxEdge"] or 8
    local splitSide = iui.style["splitSide"] or "min" --- @type IUISplitViewSide

    if splitSide == "max" then
        current = w - current
    end

    local handleWidth = math.ceil(spacing * 0.75)
    local handleMin = current - handleWidth
    local handleMax = current + handleWidth + 1

    if direction == "horiz" then
        if mx >= x + handleMin and mx <= x + handleMax then
            if my >= y and my < y + h then
                iui.becomeHover()
            end
        end

        if iui.hoverID == id then
            if iui.input.mouse.pressed:has(1) then
                iui.becomeActive()
                state.offset = (mx - x) - current
            end
        end

        if iui.activeID == id then
            current = (mx - x) - state.offset

            if not iui.input.mouse.down:has(1) then
                iui.activeID = nil
            end
        end

        if iui.hoverID == id or iui.activeID == id then
            iui.cursor = "sizewe"
        end
    elseif direction == "vert" then
        if my >= y + handleMin and my <= y + handleMax then
            if mx >= x and mx < x + w then
                iui.becomeHover()
            end
        end

        if iui.hoverID == id then
            if iui.input.mouse.pressed:has(1) then
                iui.becomeActive()
                state.offset = (mx - x) - current
            end
        end

        if iui.activeID == id then
            current = (my - y) - state.offset

            if not iui.input.mouse.down:has(1) then
                iui.activeID = nil
            end
        end

        if iui.hoverID == id or iui.activeID == id then
            iui.cursor = "sizens"
        end
    end

    current = iui.utils.round(current)

    if current < splitMinEdge then
        current = splitMinEdge
    end

    if direction == "horiz" then
        if current > w - (splitMaxEdge + 1) then
            current = w - (splitMaxEdge + 1)
        end
    elseif direction == "vert" then
        if current > h - (splitMaxEdge + 1) then
            current = h - (splitMaxEdge + 1)
        end
    end

    iui.panelBackground()

    local pos = current
    iui.colors.sysGray0:set()
    if direction == "horiz" then
        iui.graphics.rectangle(x + pos, y, 1, h)
    elseif direction == "vert" then
        iui.graphics.rectangle(x, y + pos, w, 1)
    end

    if direction == "horiz" then
        iui.layout.beginPanel(x, y, current, h)
    elseif direction == "vert" then
        iui.layout.beginPanel(x, y, w, current)
    end

    --- @type IUISplitStackItem
    local item = iui.pool.get("split_view_stack_item")
    item.direction = direction
    item.current = current
    item.x, item.y, item.w, item.h = x, y, w, h

    table.insert(splitStack, item)

    if splitSide == "max" then
        current = w - current
    end

    return current
end

function iui.splitViewDivider()
    --- @type IUISplitStackItem
    local item = table.remove(splitStack)
    local direction = item.direction
    local x, y, w, h = item.x, item.y, item.w, item.h
    local current = item.current

    iui.layout.endPanel()

    if direction == "horiz" then
        iui.layout.beginPanel(x + current + 1, y, w - (current + 1), h)
    elseif direction == "vert" then
        iui.layout.beginPanel(x, y + current + 1, w, h - (current + 1))
    end

    iui.pool.put(item)
end

function iui.endSplitView()
    iui.layout.endPanel()

    iui.endID()
end
