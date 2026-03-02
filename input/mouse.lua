local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @class (exact) IUIMouseVelocityEntry
--- @field dx number
--- @field dy number
--- @field timestamp number
--- @field dt number

--- @class (exact) IUIMouseState
--- @field x number
--- @field y number
--- @field dx number
--- @field dy number
--- @field scrollX number
--- @field scrollY number
--- @field down table<number, true>
--- @field pressed table<number, true>
--- @field released table<number, true>

--- @class (exact) IUIMouseRootContext
--- @field velocityBuffer IUIMouseVelocityEntry[]
--- @field storage IUIMouseState
--- @field disabledStorage IUIMouseState

local ctx --- @type IUIMouseRootContext

local function limitMouseVelocityEvents()
    local limit = iui.backend.system.getTimestamp() - 0.1

    while #ctx.velocityBuffer > 0 and ctx.velocityBuffer[1].timestamp < limit do
        table.remove(ctx.velocityBuffer, 1)
    end
end

local function addMouseVelocityEvent(dx, dy)
    local timestamp = iui.backend.system.getTimestamp()

    --- @type IUIMouseVelocityEntry
    local entry = { dx = dx, dy = dy, timestamp = timestamp, dt = iui.dt }

    table.insert(ctx.velocityBuffer, entry)

    limitMouseVelocityEvents()
end

--- @return IUIMouseState
local function makeMouseState()
    --- @type IUIMouseState
    return {
        x = -100,
        y = -100,
        dx = 0,
        dy = 0,
        scrollX = 0,
        scrollY = 0,
        down = {},
        pressed = {},
        released = {}
    }
end

local mouse = {
    --- @param event IUIMouseEvent
    --- @param button number
    --- @param x number
    --- @param y number
    --- @param dx number
    --- @param dy number
    __call = function(_, event, button, x, y, dx, dy)
        local storage = ctx.storage

        if event == "move" then
            storage.x = x
            storage.y = y
            storage.dx = storage.dx + dx
            storage.dy = storage.dy + dy
            addMouseVelocityEvent(dx, dy)
        elseif event == "down" then
            storage.x = x
            storage.y = y
            storage.down[button] = true
            storage.pressed[button] = true
        elseif event == "up" then
            storage.x = x
            storage.y = y
            storage.down[button] = nil
            storage.released[button] = true
        elseif event == "scroll" then
            storage.scrollX = storage.scrollX + dx
            storage.scrollY = storage.scrollY + dy
        end
    end,
}
setmetatable(mouse, mouse)

--- @return IUIMouseRootContext
function mouse.newRootContext()
    --- @type IUIMouseRootContext
    return {
        velocityBuffer = {},
        storage = makeMouseState(),
        disabledStorage = makeMouseState()
    }
end

--- @param rootContext  IUIRootContext
function mouse.setRootContext(rootContext)
    ctx = rootContext.input.mouse

    mouse.__index = ctx.storage
end

function mouse.endFrame()
    local storage = ctx.storage

    storage.dx = 0
    storage.dy = 0
    storage.scrollX = 0
    storage.scrollY = 0
    storage.pressed = {}
    storage.released = {}
end

function mouse.resetVelocity()
    ctx.velocityBuffer = {}
end

--- @return number vx, number vy
function mouse.getVelocity()
    local vx, vy = 0, 0

    local weightSum = 0
    local now = iui.backend.system.getTimestamp()

    for _, entry in ipairs(ctx.velocityBuffer) do
        local weight = math.exp((entry.timestamp - now) * 20)
        weightSum = weightSum + weight
        vx = vx + (entry.dx / entry.dt) * weight
        vy = vy + (entry.dy / entry.dt) * weight
    end

    if weightSum ~= 0 then
        vx, vy = vx / weightSum, vy / weightSum
    end

    return -vx, -vy
end

--- @param active boolean
function mouse.setActive(active)
    mouse.__index = active and ctx.storage or ctx.disabledStorage
end

return mouse --[[@as IUIMouse]]
