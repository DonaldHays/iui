local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class IUIStyle
local style = {
    default = {
        spacing = 8,
        margin = 8,
        padding = 8,
        scrollSize = 16,
        vrWindowCornerRadius = 16,
    },
}

local stack = {
    style.default
}

function style.load()
    style.default.font = iui.graphics.newFont(12, "normal", iui.dpi)
end

function style.beginFrame()
    table.insert(stack, {})
end

function style.endFrame()
    table.remove(stack)

    if #stack ~= 1 then
        error("Unbalanced style stack: expected 1, got " .. #stack)
    end
end

function style.push()
    table.insert(stack, {})
end

function style.pop()
    table.remove(stack)
end

setmetatable(style, {
    __index = function(_, k)
        for idx = #stack, 1, -1 do
            if stack[idx][k] then
                return stack[idx][k]
            end
        end
        return nil
    end,
    __newindex = function(_, k, v)
        stack[#stack][k] = v
    end
})

iui.style = style
