local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class IUIState
--- @overload fun(id: number): table
local state = {}

--- @class (exact) IUIStateRootContext
--- @field previousStates? table<number, table>
--- @field currentStates? table<number, table>

local ctx --- @type IUIStateRootContext

setmetatable(state --[[@as any]], {
    --- @param id number
    --- @return table
    __call = function(_, id)
        local out = (ctx.previousStates and ctx.previousStates[id]) or {}
        ctx.currentStates[id] = out
        return out
    end
})

--- @return IUIStateRootContext
function state.newRootContext()
    --- @type IUIStateRootContext
    return {}
end

--- @param rootContext IUIRootContext
function state.setRootContext(rootContext)
    ctx = rootContext.state
end

function state.beginFrame()
    ctx.currentStates = {}
end

function state.endFrame()
    ctx.previousStates = ctx.currentStates
    ctx.currentStates = nil
end

iui.state = state
