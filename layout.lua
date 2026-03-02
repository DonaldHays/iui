local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class (exact) IUILayoutPanel
--- @field x number
--- @field y number
--- @field w number
--- @field h number
--- @field margin number
--- @field rowHeight number
--- @field columns IUIColumns
--- @field rowY number
--- @field columnX number
--- @field wantsIntrinsicWidth boolean
--- @field wantsIntrinsicHeight boolean
--- @field intrinsicWidth? number
--- @field intrinsicHeight? number
--- @field columnIndex number
--- @field columnCountCache? number
--- @field columnBoundsCache? IUIColumnXBounds[]
--- @field zStackCount? number
--- @field contentWidth number
--- @field contentHeight number

--- @class (exact) IUIColumnXBounds
--- @field x number
--- @field w number

--- @class (exact) IUIFixedWidthColumns
--- @field kind "fixed"
--- @field size number

--- @class (exact) IUIDynamicWidthColumns
--- @field kind "dynamic"
--- @field count number

--- @class (exact) IUIIntrinsicWidthColumns
--- @field kind "intrinsic"
--- @field default? number
--- @field limit? number

--- @class (exact) IUIMixedWidthColumns
--- @field kind "mixed"
--- @field columns IUILayoutColumn[]

--- @alias IUIColumns
--- | IUIFixedWidthColumns
--- | IUIDynamicWidthColumns
--- | IUIIntrinsicWidthColumns
--- | IUIMixedWidthColumns

--- @class (exact) IUILayoutColumn
--- @field kind "fixed" | "dynamic"
--- @field size number

--- @class IUILayout
--- @field windowWidth number
--- @field windowHeight number
local layout = {}

--- @type IUILayoutPanel[]
local panels = {}

function layout.beginFrame()

end

function layout.endFrame()
    if #panels ~= 0 then
        error("Unbalanced panel stack: expected 0, got " .. #panels)
    end
end

--- @return number rowHeight
function layout.getDefaultRowHeight()
    local padding = iui.style["padding"]
    local fontHeight = math.floor(iui.style["font"]:getHeight())
    local rowHeight = fontHeight + padding * 2

    return rowHeight
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param margin? number
--- @return IUILayoutPanel
function layout.beginPanel(x, y, w, h, margin)
    margin = margin or iui.style["margin"]

    local rowHeight = layout.getDefaultRowHeight()

    --- @type IUILayoutPanel
    local panel = {
        x = x,
        y = y,
        w = w,
        h = h,
        margin = margin,
        rowHeight = rowHeight,
        rowY = margin,
        columnX = margin,
        wantsIntrinsicWidth = false,
        wantsIntrinsicHeight = false,
        columnIndex = 1,
        columns = {
            kind = "dynamic",
            count = 1
        },
        contentWidth = 0,
        contentHeight = 0
    }

    table.insert(panels, panel)

    return panel
end

--- @param advance? boolean
function layout.endPanel(advance)
    local panel = layout.getPanel()
    if panel.zStackCount ~= nil and panel.zStackCount ~= 0 then
        error(
            "Unbalanced panel zstack count: expected 0, got " ..
            panel.zStackCount
        )
    end

    table.remove(panels)

    if advance == true or (#panels > 0 and advance ~= false) then
        iui.layout.advance()
    end
end

--- @param index? number
function layout.getPanel(index)
    return panels[index or #panels]
end

--- @return number w, number h
function layout.getContentSize()
    local panel = layout.getPanel()
    return panel.contentWidth, panel.contentHeight
end

--- @return boolean wantsIntrinsicWidth, boolean wantsIntrinsicHeight
function layout.getWantsIntrinsic()
    local panel = layout.getPanel()
    return panel.wantsIntrinsicWidth, panel.wantsIntrinsicHeight
end

--- @param w number
function layout.setIntrinsicWidth(w)
    local panel = layout.getPanel()
    panel.intrinsicWidth = w
end

--- @param h number
function layout.setIntrinsicHeight(h)
    local panel = layout.getPanel()
    panel.intrinsicHeight = h
end

--- @param columns IUIColumns
--- @param rowHeight? number
function layout.beginRow(columns, rowHeight)
    if rowHeight == nil then
        rowHeight = layout.getDefaultRowHeight()
    end

    local panel = layout.getPanel()

    if panel.columnIndex ~= 1 then
        panel.columnIndex = 1
        panel.rowY = panel.rowY + panel.rowHeight + iui.style["spacing"]
    end

    panel.wantsIntrinsicHeight = false
    panel.wantsIntrinsicWidth = columns.kind == "intrinsic"
    panel.intrinsicWidth = nil
    panel.intrinsicHeight = nil
    panel.columns = columns
    panel.rowHeight = rowHeight
    panel.columnCountCache = nil
    panel.columnBoundsCache = nil
end

function layout.beginZStack()
    local panel = layout.getPanel()
    panel.zStackCount = (panel.zStackCount or 0) + 1
end

--- @param advance? boolean
function layout.endZStack(advance)
    local panel = layout.getPanel()
    if panel.zStackCount == nil or panel.zStackCount == 0 then
        error("Attempt to end ZStack without one on panel")
    end
    panel.zStackCount = panel.zStackCount - 1

    if advance then
        iui.layout.advance()
    end
end

--- @return number x, number y, number w, number h
function layout.getBounds()
    local panel = layout.getPanel()
    local y = panel.rowY
    local h = panel.rowHeight

    local margin = panel.margin
    local spacing = iui.style["spacing"]

    local x, w = 0, 0
    local columns = panel.columns
    if columns.kind == "fixed" then
        w = columns.size
        x = margin + (panel.columnIndex - 1) * (w + spacing)
    elseif columns.kind == "dynamic" then
        local count = columns.count
        w = (panel.w - (2 * margin + (count - 1) * spacing)) / count
        x = margin + (panel.columnIndex - 1) * (w + spacing)

        local maxX = iui.utils.round(x + w)
        x = iui.utils.round(x)
        w = maxX - x
    elseif columns.kind == "intrinsic" then
        local edge = panel.w - panel.margin
        x = panel.columnX
        w = panel.intrinsicWidth or columns.default or (edge - x)
        if x + w > edge and panel.columnIndex ~= 1 then
            x = panel.margin
            panel.columnIndex = 1
            panel.rowY = panel.rowY + panel.rowHeight + spacing
            y = panel.rowY
        end
        panel.intrinsicWidth = w
    elseif columns.kind == "mixed" then
        if panel.columnBoundsCache == nil then
            --- The sum of dynamic column `size` values.
            local dynamicSum = 0

            --- The amount of space available to dynamic columns. This is
            --- whatever's left over after the margin, spacing, and fixed
            --- columns are accounted for.
            local dynamicSpace = panel.w - margin * 2

            -- Do a first pass through the columns, calculating the dynamic sum
            -- and space values.
            for idx = 1, #columns.columns do
                if idx > 1 then
                    dynamicSpace = dynamicSpace - spacing
                end

                local column = columns.columns[idx]
                if column.kind == "dynamic" then
                    dynamicSum = dynamicSum + column.size
                elseif column.kind == "fixed" then
                    dynamicSpace = dynamicSpace - column.size
                end
            end

            --- @type IUIColumnXBounds[]
            local bounds = {}
            local head = margin
            for idx = 1, #columns.columns do
                local column = columns.columns[idx]
                local colX = head
                local colW = 0
                if column.kind == "fixed" then
                    colW = column.size
                elseif column.kind == "dynamic" then
                    colW = dynamicSpace * (column.size / dynamicSum)
                end
                head = head + colW + spacing
                local maxX = colX + colW
                colX = iui.utils.round(colX)
                maxX = iui.utils.round(maxX)
                colW = maxX - colX
                --- @type IUIColumnXBounds
                local value = { x = colX, w = colW }
                table.insert(bounds, value)
            end

            panel.columnBoundsCache = bounds
        end

        local bounds = panel.columnBoundsCache[panel.columnIndex]

        x = bounds.x
        w = bounds.w
    end

    x = panel.x + x
    y = panel.y + y

    panel.contentWidth = math.max(panel.contentWidth, x + w + panel.margin - panel.x)
    panel.contentHeight = math.max(panel.contentHeight, y + h + panel.margin - panel.y)

    return x, y, w, h
end

--- @param index? number
--- @return number x, number y, number w, number h
function layout.getPanelBounds(index)
    local panel = layout.getPanel(index)

    return panel.x, panel.y, panel.w, panel.h
end

--- @param x? number
--- @param y? number
--- @return boolean
function layout.containsPoint(x, y)
    x = x or iui.input.mouse.x
    y = y or iui.input.mouse.y

    local bx, by, bw, bh = layout.getBounds()
    if x < bx or y < by then
        return false
    end

    if x >= bx + bw or y >= by + bh then
        return false
    end

    local cx, cy, cw, ch = iui.draw.getClipBounds()
    if cx then
        if x < cx or y < cy then
            return false
        end

        if x >= cx + cw or y >= cy + ch then
            return false
        end
    end

    return true
end

function layout.spacer()
    layout.advance()
end

function layout.advance()
    local panel = layout.getPanel()

    if panel.zStackCount ~= nil and panel.zStackCount ~= 0 then
        return
    end

    local spacing = iui.style["spacing"]

    local columns = panel.columns
    local count = panel.columnCountCache

    if count == nil then
        if columns.kind == "fixed" then
            local num = panel.w + spacing - panel.margin * 2
            local den = columns.size + spacing
            count = math.floor(num / den)
            if count < 1 then
                count = 1
            end
        elseif columns.kind == "dynamic" then
            count = columns.count
        elseif columns.kind == "mixed" then
            count = #columns.columns
        end

        panel.columnCountCache = count
    end

    if columns.kind == "intrinsic" then
        panel.columnIndex = panel.columnIndex + 1
        panel.columnX = panel.columnX + spacing + (panel.intrinsicWidth or 0)
        panel.intrinsicWidth = nil
        panel.intrinsicHeight = nil

        if columns.limit and panel.columnIndex >= columns.limit then
            panel.columnIndex = 1
            panel.columnX = panel.margin
            panel.rowY = panel.rowY + panel.rowHeight + spacing
        end
    elseif panel.columnIndex == count then
        panel.columnIndex = 1
        panel.rowY = panel.rowY + panel.rowHeight + spacing
    else
        panel.columnIndex = panel.columnIndex + 1
    end
end

iui.layout = layout
