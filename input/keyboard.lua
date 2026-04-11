local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @alias IUIKeyEvent "down" | "up"

--- @alias IUIKeyPressed { isRepeat: boolean }

--- @class (exact) IUIKeyboardState
--- @field down IUISet<string>
--- @field pressed table<string, IUIKeyPressed>
--- @field released IUISet<string>

--- @class (exact) IUIKeyboardRootContext
--- @field storage IUIKeyboardState
--- @field disabledStorage IUIKeyboardState

--- @return IUIKeyboardState
local function makeKeyboardState()
    return {
        down = iui.set.new(),
        pressed = {},
        released = iui.set.new()
    }
end

local ctx --- @type IUIKeyboardRootContext

local keyboard = {
    --- @param event IUIKeyEvent
    --- @param keycode string
    --- @param isRepeat boolean
    __call = function(_, event, keycode, isRepeat)
        if event == "down" then
            ctx.storage.down:put(keycode)
            ctx.storage.pressed[keycode] = { isRepeat = isRepeat }
        elseif event == "up" then
            ctx.storage.down:remove(keycode)
            ctx.storage.released:put(keycode)
        end
    end
}
setmetatable(keyboard, keyboard)

--- @return IUIKeyboardRootContext
function keyboard.newRootContext()
    --- @type IUIKeyboardRootContext
    return {
        storage = makeKeyboardState(),
        disabledStorage = makeKeyboardState()
    }
end

--- @param rootContext IUIRootContext
function keyboard.setRootContext(rootContext)
    ctx = rootContext.input.keyboard

    keyboard.__index = ctx.storage
end

function keyboard.endFrame()
    local pressed = ctx.storage.pressed
    for k, _ in pairs(pressed) do
        pressed[k] = nil
    end

    ctx.storage.released:removeAll()
end

--- @param active boolean
function keyboard.setActive(active)
    keyboard.__index = active and ctx.storage or ctx.disabledStorage
end

return keyboard --[[@as IUIKeyboard]]
