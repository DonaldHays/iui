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

    sysGray0 = iui.newColor(5 / 255, 5 / 255, 6 / 255),
    sysGray50 = iui.newColor(20 / 255, 20 / 255, 24 / 255),
    sysGray100 = iui.newColor(28 / 255, 28 / 255, 33 / 255),
    sysGray200 = iui.newColor(58 / 255, 58 / 255, 67 / 255),
    sysGray300 = iui.newColor(88 / 255, 88 / 255, 102 / 255),
    sysGray400 = iui.newColor(113 / 255, 113 / 255, 130 / 255),
    sysGray500 = iui.newColor(128 / 255, 128 / 255, 146 / 255),
    sysGray600 = iui.newColor(149 / 255, 149 / 255, 164 / 255),
    sysGray700 = iui.newColor(176 / 255, 176 / 255, 187 / 255),
    sysGray800 = iui.newColor(205 / 255, 205 / 255, 212 / 255),
    sysGray900 = iui.newColor(232 / 255, 232 / 255, 235 / 255),
    sysGray950 = iui.newColor(243 / 255, 243 / 255, 245 / 255),
    sysGray1000 = iui.newColor(252 / 255, 252 / 255, 254 / 255),
}
