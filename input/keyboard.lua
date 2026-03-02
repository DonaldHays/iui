--- @alias IUIKeyEvent "down" | "up"

--- @alias IUIKeyPressed { isRepeat: boolean }

--- @class (exact) IUIKeyboardState
--- @field down table<string, true>
--- @field pressed table<string, IUIKeyPressed>
--- @field released table<string, true>

--- @class (exact) IUIKeyboardRootContext
--- @field storage IUIKeyboardState
--- @field disabledStorage IUIKeyboardState

--- @return IUIKeyboardState
local function makeKeyboardState()
    return {
        down = {},
        pressed = {},
        released = {}
    }
end

local ctx --- @type IUIKeyboardRootContext

local keyboard = {
    --- @param event IUIKeyEvent
    --- @param keycode string
    --- @param isRepeat boolean
    __call = function(_, event, keycode, isRepeat)
        if event == "down" then
            ctx.storage.down[keycode] = true
            ctx.storage.pressed[keycode] = { isRepeat = isRepeat }
        elseif event == "up" then
            ctx.storage.down[keycode] = nil
            ctx.storage.released[keycode] = true
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
    ctx.storage.pressed = {}
    ctx.storage.released = {}
end

--- @param active boolean
function keyboard.setActive(active)
    keyboard.__index = active and ctx.storage or ctx.disabledStorage
end

return keyboard --[[@as IUIKeyboard]]
