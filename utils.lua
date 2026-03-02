local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class IUIUtils
local utils = {}

--- Returns 1 if `n` is positive, -1 if negative, and 0 if zero.
--- @param n number
--- @return number
function utils.sign(n)
    if n > 0 then
        return 1
    elseif n == 0 then
        return 0
    else
        return -1
    end
end

--- Returns `n` rounded to the nearest integer, with 0.5 rounding up.
--- @param n number
--- @return number
function utils.round(n)
    return math.floor(n + 0.5)
end

--- Returns the closest value to `n` that is neither below `low` nor above
--- `high`.
--- @param n number
--- @param low number
--- @param high number
--- @return number
function utils.clamp(n, low, high)
    if n < low then
        return low
    elseif n > high then
        return high
    end

    return n
end

iui.utils = utils
