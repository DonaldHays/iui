local currentPath = (...):gsub('%.init$', '') .. "."
local resourcePath = currentPath:gsub("%.", "/")

--- @type IUILib
local iui = require(currentPath .. "iui")

iui.resourcePath = resourcePath

require(currentPath .. "utils")
require(currentPath .. "set")
require(currentPath .. "root-context")
require(currentPath .. "color")
require(currentPath .. "input")
require(currentPath .. "id")
require(currentPath .. "draw")
require(currentPath .. "layout")
require(currentPath .. "style")
require(currentPath .. "state")
require(currentPath .. "layer")

require(currentPath .. "widgets")

return iui
