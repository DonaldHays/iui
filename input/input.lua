local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUIInput
local input = {
    --- @type string?
    textBuffer = nil
}

--- @alias IUIMouseEvent "move" | "down" | "up" | "scroll"

--- @class IUIMouse
--- @field x number
--- @field y number
--- @field dx number
--- @field dy number
--- @field scrollX number
--- @field scrollY number
--- @field down table<number, true>
--- @field pressed table<number, true>
--- @field released table<number, true>
--- @field newRootContext fun(): IUIMouseRootContext
--- @field setRootContext fun(rootContext: IUIRootContext)
--- @field endFrame fun()
--- @field resetVelocity fun()
--- @field getVelocity fun(): number, number
--- @field setActive fun(active: boolean)
--- @overload fun(event: IUIMouseEvent, button: number, x: number, y: number, dx: number, dy: number)

--- @class IUIKeyboard
--- @field down table<string, true>
--- @field pressed table<string, IUIKeyPressed>
--- @field released table<string, true>
--- @field newRootContext fun(): IUIKeyboardRootContext
--- @field setRootContext fun(rootContext: IUIRootContext)
--- @field endFrame fun()
--- @field setActive fun(active: boolean)
--- @overload fun(event: IUIKeyEvent, keycode: string, isRepeat: boolean)

--- @type IUIMouse
input.mouse = require(currentPath .. "mouse")

--- @type IUIKeyboard
input.keyboard = require(currentPath .. "keyboard")

return input
