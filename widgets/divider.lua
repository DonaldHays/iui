local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

function iui.divider()
    local panel = iui.layout.getPanel()
    local rowHeight = panel.rowHeight
    panel.rowHeight = iui.utils.round(rowHeight / 4)
    if panel.rowHeight % 2 == 0 then
        panel.rowHeight = panel.rowHeight + 1
    end

    local x, y, w, h = iui.layout.getBounds()

    -- local padding = iui.utils.round(iui.style["padding"] / 2)
    local padding = 0
    local top = math.floor(y + h / 2)

    iui.colors.sysGray200:set()
    local radius = (iui.detail == "high" and 0.5 or nil)
    iui.graphics.rectangle(x + padding, top, w - padding * 2, 1, radius, radius)

    iui.layout.advance()
    panel.rowHeight = rowHeight
end
