local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class IUIRootContext
--- @field input IUIInputRootContext
--- @field draw IUIDrawRootContext
--- @field layer IUILayerRootContext
--- @field state IUIStateRootContext
--- @field disabledCount number
--- @field hoverID? number The ID of the widget a pointer is hovering over.
--- @field activeID? number The ID of the widget that's being actively used.
--- @field cursor? IUICursorName The desired mouse cursor to display.
local IUIRootContext = {}
IUIRootContext.__index = IUIRootContext

--- @return IUIRootContext
function iui.newRootContext()
    --- @type IUIRootContext
    local context = {
        input = iui.input.newRootContext(),
        draw = iui.draw.newRootContext(),
        layer = iui.layer.newRootContext(),
        state = iui.state.newRootContext(),
        disabledCount = 0,
    }
    setmetatable(context, IUIRootContext)

    return context
end

function IUIRootContext:beginFrame()
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

function IUIRootContext:endFrame()
    if iui.disabledCount ~= 0 then
        error("Unbalanced control disable count")
    end

    iui.input.endFrame()
    iui.layout.endFrame()
    iui.draw.endFrame()
    iui.layer.endFrame()
    iui.style.endFrame()
    iui.state.endFrame()
end
