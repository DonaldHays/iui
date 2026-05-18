local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class IUIWindowManager
--- @field draw IUIDrawRootContext
--- @field layer IUILayerRootContext
--- @field state IUIStateRootContext
--- @field disabledCount number
--- @field hoverID? number The ID of the widget a pointer is hovering over.
--- @field activeID? number The ID of the widget that's being actively used.
--- @field cursor? IUICursorName The desired mouse cursor to display.
--- @field hadActiveID boolean Internal flag for detecting widget deactivation.
local IUIWindowManager = {}
IUIWindowManager.__index = IUIWindowManager

--- @return IUIWindowManager
function iui.newWindowManager()
    --- @type IUIWindowManager
    local manager = {
        draw = iui.draw.newRootContext(),
        layer = iui.layer.newRootContext(),
        state = iui.state.newRootContext(),
        disabledCount = 0,
        hadActiveID = false,
    }
    setmetatable(manager, IUIWindowManager)

    return manager
end

function IUIWindowManager:beginFrame()
    iui.disabledCount = 0
    iui.hoverID = nil
    iui.cursor = nil

    iui.resetIDCheck()
    iui.state.beginFrame()
    iui.draw.beginFrame()
    iui.layout.beginFrame()
    iui.style.beginFrame()
    iui.layer.beginFrame()
end

function IUIWindowManager:endFrame()
    if iui.disabledCount ~= 0 then
        error("Unbalanced control disable count")
    end

    if self.activeID == nil and self.hadActiveID == true then
        self.hadActiveID = false

        if iui.widgetDeactivated then
            iui.widgetDeactivated()
        end
    end

    iui.layout.endFrame()
    iui.draw.endFrame()
    iui.layer.endFrame()
    iui.style.endFrame()
    iui.state.endFrame()
end
