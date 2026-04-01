--- @meta _

--- @alias IUIImageFilter "nearest" | "smooth" | "linear"

--- @class IUIImage9Slice
--- @field image any
--- @field l number
--- @field t number
--- @field r number
--- @field b number

--- @class IUIGraphicsBackend
local graphics = {}

--- @param width number
--- @param height number
function graphics.beginDraw(width, height)
end

function graphics.endDraw()
end

function graphics.newFont(size, hinting, dpiscale)
end

--- @return number w, number h
function graphics.getImageDimensions(image)
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
function graphics.clip(x, y, w, h)
end

function graphics.clip()
end

--- @param r number
--- @param g number
--- @param b number
--- @param a? number
function graphics.setColor(r, g, b, a)
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param rx? number
--- @param ry? number
function graphics.rectangle(x, y, w, h, rx, ry)
end

--- @param x number
--- @param y number
--- @param r number
function graphics.circle(x, y, r)
end

function graphics.setFont(f)
end

--- @param s string
--- @param x number
--- @param y number
function graphics.print(s, x, y)
end

--- @param image any
--- @param filter IUIImageFilter
--- @param x number
--- @param y number
--- @param w number
--- @param h number
function graphics.image(image, filter, x, y, w, h)
end

--- @param image any
--- @param x number
--- @param y number
--- @param w number
--- @param h number
function graphics.msdfImage(image, x, y, w, h)
end

--- @param nineSlice IUIImage9Slice
--- @param filter IUIImageFilter
--- @param x number
--- @param y number
--- @param w number
--- @param h number
function graphics.nineSlice(nineSlice, filter, x, y, w, h)
end
