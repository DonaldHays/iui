local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class IUIColor
--- @field r number
--- @field g number
--- @field b number
--- @field a number
local color = {}
color.__index = color

function color:set()
    iui.graphics.setColor(self.r, self.g, self.b, self.a)
end

--- @param r number
--- @param g number
--- @param b number
--- @param a? number
--- @return IUIColor
function iui.newColor(r, g, b, a)
    return setmetatable({ r = r, g = g, b = b, a = a or 1 }, color)
end

iui.colors = {
    sysAccent500 = iui.newColor(14 / 255, 59 / 255, 173 / 255),

    sysGray0 = iui.newColor(0.014, 0.014, 0.016),
    sysGray50 = iui.newColor(0.083, 0.083, 0.097),
    sysGray100 = iui.newColor(0.13, 0.13, 0.15),
    sysGray200 = iui.newColor(0.28, 0.28, 0.32),
    sysGray300 = iui.newColor(0.403, 0.403, 0.457),
    sysGray400 = iui.newColor(0.47, 0.47, 0.53),
    sysGray500 = iui.newColor(0.543, 0.543, 0.597),
    sysGray600 = iui.newColor(0.628, 0.628, 0.672),
    sysGray700 = iui.newColor(0.723, 0.723, 0.757),
    sysGray800 = iui.newColor(0.818, 0.818, 0.842),
    sysGray900 = iui.newColor(0.914, 0.914, 0.926),
    sysGray950 = iui.newColor(0.957, 0.957, 0.963),
    sysGray1000 = iui.newColor(0.989, 0.989, 0.991),

    white = iui.newColor(1, 1, 1)
}
