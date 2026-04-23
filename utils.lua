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

--- @param rx number
--- @param ry number
--- @param rw number
--- @param rh number
--- @param px number
--- @param py number
--- @return boolean isInside
function utils.rectContains(rx, ry, rw, rh, px, py)
    if px < rx or py < ry then
        return false
    end

    if px >= rx + rw or py >= ry + rh then
        return false
    end

    return true
end

--- @param iw number
--- @param ih number
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @return number x, number y, number w, number h
function utils.aspectFit(iw, ih, x, y, w, h)
    local aspectBounds = w / h
    local aspectImage = iw / ih

    local ox, oy, ow, oh = x, y, w, h

    if aspectImage > aspectBounds then
        oh = iui.utils.round(w / aspectImage)
        oy = y + iui.utils.round((h - oh) / 2)
    else
        ow = iui.utils.round(h * aspectImage)
        ox = x + iui.utils.round((w - ow) / 2)
    end

    return ox, oy, ow, oh
end

--- @param iw number
--- @param ih number
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @return number x, number y, number w, number h
function utils.aspectFill(iw, ih, x, y, w, h)
    local aspectBounds = w / h
    local aspectImage = iw / ih

    local ox, oy, ow, oh = x, y, w, h

    if aspectImage < aspectBounds then
        oh = iui.utils.round(ow / aspectImage)
        oy = y + iui.utils.round((h - oh) / 2)
    else
        ow = iui.utils.round(oh * aspectImage)
        ox = x + iui.utils.round((w - ow) / 2)
    end

    return ox, oy, ow, oh
end

--- @param iw number
--- @param ih number
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @return number x, number y, number w, number h
function utils.center(iw, ih, x, y, w, h)
    local ox, oy, ow, oh = x, y, w, h

    ow, oh = iw, ih
    ox = x + iui.utils.round((w - ow) / 2)
    oy = y + iui.utils.round((h - oh) / 2)

    return ox, oy, ow, oh
end

--- @param mode IUIImageMode
--- @param iw number
--- @param ih number
--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @return number x, number y, number w, number h
function utils.fill(mode, iw, ih, x, y, w, h)
    if mode == "fill" then
        return x, y, w, h
    elseif mode == "aspectFit" then
        return iui.utils.aspectFit(iw, ih, x, y, w, h)
    elseif mode == "aspectFill" then
        return iui.utils.aspectFill(iw, ih, x, y, w, h)
    elseif mode == "center" then
        return iui.utils.center(iw, ih, x, y, w, h)
    else
        error("unrecognized fillmode")
    end
end

iui.utils = utils
