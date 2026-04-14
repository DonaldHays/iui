local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class IUIPool
local pool = {}

--- @class (exact) IUIPoolStack
--- @field top number
--- @field items any[]

--- @type table<string, IUIPoolStack>
local entries = {}

--- @param typename string
--- @return IUIPoolStack
local function getPool(typename)
    local out = entries[typename]

    if not out then
        out = { top = 0, items = {} }
        entries[typename] = out
    end

    return out
end

--- @generic T
--- @param typename string
--- @return T object
function pool.get(typename)
    local stack = getPool(typename)

    if stack.top == 0 then
        return {
            _typename = typename
        }
    else
        local value = stack.items[stack.top]
        stack.top = stack.top - 1
        return value
    end
end

--- @generic T
--- @param obj T
function pool.put(obj)
    local stack = getPool(obj["_typename"])
    stack.top = stack.top + 1
    stack.items[stack.top] = obj
end

iui.pool = pool
