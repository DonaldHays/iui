local currentPath = (...):gsub('%.init$', '') .. "."
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @class IUIInput
local input = require(currentPath .. "input")

--- @class (exact) IUIInputRootContext
--- @field textBuffer string?
--- @field isActive boolean

--- @type IUIInputRootContext
local ctx

function input.load()
    ctx = {
        textBuffer = nil,
        isActive = true,
    }

    input.keyboard.load()
end

function input.text(s)
    if ctx.textBuffer then
        ctx.textBuffer = ctx.textBuffer .. s
    else
        ctx.textBuffer = s
    end

    if ctx.isActive then
        input.textBuffer = ctx.textBuffer
    else
        input.textBuffer = nil
    end
end

function input.endFrame()
    input.mouse.endFrame()
    input.keyboard.endFrame()

    ctx.textBuffer = nil
    input.textBuffer = nil
end

--- @param active boolean
function input.setActive(active)
    ctx.isActive = active
    input.mouse.setActive(active)
    input.keyboard.setActive(active)

    if active then
        input.textBuffer = ctx.textBuffer
    else
        input.textBuffer = nil
    end
end

iui.input = input
