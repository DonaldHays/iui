local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @alias IUILayoutRowKind "fixed" | "dynamic" | "intrinsic" | "mixed"

--- @class (exact) IUILayoutPanel
--- @field x number
--- @field y number
--- @field w number
--- @field h number
--- @field margin number
--- @field rowHeight number
--- @field rowKind IUILayoutRowKind
--- @field rowData any
--- @field intrinsicDefault? number
--- @field intrinsicLimit? number
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

--- @param panel IUILayoutPanel
local function resetColumnBoundsCache(panel)
    if panel.columnBoundsCache ~= nil then
        iui.pool.put(panel.columnBoundsCache)
        panel.columnBoundsCache = nil
    end
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
    local panel = iui.pool.get("layout_panel")

    panel.x = x
    panel.y = y
    panel.w = w
    panel.h = h
    panel.margin = margin
    panel.rowHeight = rowHeight
    panel.rowY = margin
    panel.columnX = margin
    panel.wantsIntrinsicWidth = false
    panel.wantsIntrinsicHeight = false
    panel.columnIndex = 1
    panel.rowKind = "dynamic"
    panel.rowData = 1
    panel.intrinsicDefault = nil
    panel.intrinsicLimit = nil
    panel.contentWidth = 0
    panel.contentHeight = 0

    panel.intrinsicWidth = nil
    panel.intrinsicHeight = nil
    panel.columnCountCache = nil
    panel.zStackCount = nil

    resetColumnBoundsCache(panel)

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

    iui.pool.put(panel)

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

--- @param rowHeight? number
--- @return IUILayoutPanel
local function beginRowCommon(rowHeight)
    if rowHeight == nil then
        rowHeight = layout.getDefaultRowHeight()
    end

    local panel = layout.getPanel()

    if panel.columnIndex ~= 1 then
        panel.columnIndex = 1
        panel.rowY = panel.rowY + panel.rowHeight + iui.style["spacing"]
    end

    panel.wantsIntrinsicHeight = false
    panel.wantsIntrinsicWidth = false
    panel.intrinsicWidth = nil
    panel.intrinsicHeight = nil
    panel.rowHeight = rowHeight
    panel.columnCountCache = nil
    resetColumnBoundsCache(panel)

    return panel
end

--- @param count? number
--- @param rowHeight? number
function layout.beginDynamicRow(count, rowHeight)
    local panel = beginRowCommon(rowHeight)
    panel.rowKind = "dynamic"
    panel.rowData = count or 1
end

--- @param size number
--- @param rowHeight? number
function layout.beginFixedRow(size, rowHeight)
    local panel = beginRowCommon(rowHeight)
    panel.rowKind = "fixed"
    panel.rowData = size
end

--- @param default? number
--- @param limit? number
--- @param rowHeight? number
function layout.beginIntrinsicRow(default, limit, rowHeight)
    local panel = beginRowCommon(rowHeight)
    panel.rowKind = "intrinsic"
    panel.wantsIntrinsicWidth = true
    panel.intrinsicDefault = default
    panel.intrinsicLimit = limit
end

--- @param columns IUILayoutColumn[]
--- @param rowHeight? number
function layout.beginMixedRow(columns, rowHeight)
    local panel = beginRowCommon(rowHeight)
    panel.rowKind = "mixed"
    panel.rowData = columns
end

--- Begins a row that causes the next widget to fill the remainder of the
--- current panel.
function layout.fillPanel()
    local panel = layout.getPanel()

    if panel.columnIndex ~= 1 then
        panel.columnIndex = 1
        panel.rowY = panel.rowY + panel.rowHeight + iui.style["spacing"]
    end

    local h = panel.h - (panel.rowY + panel.margin)
    layout.beginDynamicRow(1, h)
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
    local rowKind = panel.rowKind
    if rowKind == "fixed" then
        w = panel.rowData
        x = margin + (panel.columnIndex - 1) * (w + spacing)
    elseif rowKind == "dynamic" then
        local count = panel.rowData
        w = (panel.w - (2 * margin + (count - 1) * spacing)) / count
        x = margin + (panel.columnIndex - 1) * (w + spacing)

        local maxX = iui.utils.round(x + w)
        x = iui.utils.round(x)
        w = maxX - x
    elseif rowKind == "intrinsic" then
        local edge = panel.w - panel.margin
        x = panel.columnX
        w = panel.intrinsicWidth or panel.intrinsicDefault or (edge - x)
        if x + w > edge and panel.columnIndex ~= 1 then
            x = panel.margin
            panel.columnIndex = 1
            panel.rowY = panel.rowY + panel.rowHeight + spacing
            y = panel.rowY
        end
        panel.intrinsicWidth = w
    elseif rowKind == "mixed" then
        if panel.columnBoundsCache == nil then
            --- The sum of dynamic column `size` values.
            local dynamicSum = 0

            --- The amount of space available to dynamic columns. This is
            --- whatever's left over after the margin, spacing, and fixed
            --- columns are accounted for.
            local dynamicSpace = panel.w - margin * 2

            --- @type IUILayoutColumn[]
            local columns = panel.rowData

            -- Do a first pass through the columns, calculating the dynamic sum
            -- and space values.
            for idx = 1, #columns do
                if idx > 1 then
                    dynamicSpace = dynamicSpace - spacing
                end

                local column = columns[idx]
                if column.kind == "dynamic" then
                    dynamicSum = dynamicSum + column.size
                elseif column.kind == "fixed" then
                    dynamicSpace = dynamicSpace - column.size
                end
            end

            --- @type IUIColumnXBounds[]
            local bounds = iui.pool.get("layout_column_bounds_cache")
            for index, entry in ipairs(bounds) do
                iui.pool.put(entry)
                bounds[index] = nil
            end

            local head = margin
            for idx = 1, #columns do
                local column = columns[idx]
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
                local value = iui.pool.get("layout_column_bounds_entry")
                value.x = colX
                value.w = colW

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

    local rowKind = panel.rowKind
    local count = panel.columnCountCache

    if count == nil then
        if rowKind == "fixed" then
            local num = panel.w + spacing - panel.margin * 2
            local den = panel.rowData + spacing
            count = math.floor(num / den)
            if count < 1 then
                count = 1
            end
        elseif rowKind == "dynamic" then
            count = panel.rowData
        elseif rowKind == "mixed" then
            count = #panel.rowData
        end

        panel.columnCountCache = count
    end

    if rowKind == "intrinsic" then
        panel.columnIndex = panel.columnIndex + 1
        panel.columnX = panel.columnX + spacing + (panel.intrinsicWidth or 0)
        panel.intrinsicWidth = nil
        panel.intrinsicHeight = nil

        if panel.intrinsicLimit and panel.columnIndex >= panel.intrinsicLimit then
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
