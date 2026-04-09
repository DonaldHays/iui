local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @type table<number, table<string, number>>
local cache = {}
local cacheMetatable = { __mode = "k" }

--- @type number[]
local stack = {}

--- @type table<number, true>
local check = {}

function iui.resetIDCheck()
    check = {}
end

--- @param name string
--- @param canFocus? boolean
--- @return number
function iui.beginID(name, canFocus)
    if canFocus == nil then
        canFocus = true
    end

    if iui.isDisabled() then
        canFocus = false
    end

    -- Initialize the hash to either the current hash, or the default.
    local stackSize = #stack
    local hash = stackSize > 0 and stack[stackSize] or 2166136261

    -- Find the cached ids for the current top id.
    local ids = cache[hash]
    if ids == nil then
        ids = setmetatable({}, cacheMetatable)
        cache[hash] = ids
    end

    -- If there's a cached hash, use it, otherwise calculate it.
    local cached = ids[name]
    if cached then
        hash = cached
    else
        for idx = 1, #name do
            hash = bit.bxor(hash, string.byte(name, idx))
            hash = (hash * 16777619) % 0x100000000
        end
        ids[name] = hash
    end

    if check[hash] then
        print("Warning: duplicate hash for " .. name)
    else
        check[hash] = true
    end

    -- Push the hash onto the stack.
    table.insert(stack, hash)

    -- Take focus if nothing else has it, and we're in the desktop idiom.
    if canFocus and iui.idiom == "desktop" then
        iui.layer.setFocusID(iui.layer.getFocusID() or hash)
    end

    if iui.layer.getFocusID() == hash and iui.input.keyboard.pressed["tab"] then
        if iui.input.keyboard.down["lshift"] then
            iui.layer.setFocusID(iui.layer.getLastID())
        else
            iui.layer.setFocusID(nil)
        end
        iui.input.keyboard.pressed["tab"] = nil
    end

    if canFocus then
        iui.layer.setLastID(hash)
    end

    return hash
end

--- @param advanceLayout? boolean
function iui.endID(advanceLayout)
    table.remove(stack)

    if advanceLayout == nil or advanceLayout then
        iui.layout.advance()
    end
end

--- Attempts to set the current ID as the hover ID.
---
--- An ID won't become the hover ID if another ID is the current active ID, or
--- if the control is disabled.
function iui.becomeHover()
    if iui.isDisabled() then
        return
    end

    local id = stack[#stack]
    if iui.activeID == nil or iui.activeID == id then
        iui.hoverID = id
    end
end

--- @param id? number
function iui.becomeActive(id)
    if not iui.isDisabled() then
        if iui.activeID and iui.widgetDeactivated then
            iui.widgetDeactivated()
        end

        id = id or stack[#stack]
        iui.activeID = id
        iui.hadActiveID = true

        if iui.widgetActivated then
            iui.widgetActivated()
        end
    end
end

function iui.becomeFocus()
    if not iui.isDisabled() then
        iui.layer.setFocusID(stack[#stack])
    end
end

--- @param id number
--- @return boolean
function iui.isFocused(id)
    return iui.layer.getFocusID() == id
end
