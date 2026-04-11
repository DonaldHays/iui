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
--- @field down IUISet<number>
--- @field pressed IUISet<number>
--- @field released IUISet<number>
--- @field newRootContext fun(): IUIMouseRootContext
--- @field setRootContext fun(rootContext: IUIRootContext)
--- @field endFrame fun()
--- @field resetVelocity fun()
--- @field getVelocity fun(): number, number
--- @field setActive fun(active: boolean)
--- @overload fun(event: IUIMouseEvent, button: number, x: number, y: number, dx: number, dy: number)

--- @class IUIKeyboard
--- @field down IUISet<string>
--- @field pressed table<string, IUIKeyPressed>
--- @field released IUISet<string>
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
