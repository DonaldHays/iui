local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class IUILayer
--- @field name string
--- @field focusID? number
--- @field lastID? number
local layer = {}

--- @class (exact) IUILayerRootContext
--- @field layers IUILayer[]
--- @field newLayers IUILayer[]
--- @field layerIndex number
--- @field isUnwinding boolean
--- @field isDrawing boolean

local ctx --- @type IUILayerRootContext

local function isInputActive()
    return (#ctx.newLayers == #ctx.layers) and (not ctx.isUnwinding)
end

local function setInputActive()
    iui.input.setActive(isInputActive())
end

--- @return IUILayer
function layer.getCurrentLayer()
    return ctx.newLayers[ctx.layerIndex]
end

--- @return IUILayerRootContext
function layer.newRootContext()
    --- @type IUILayerRootContext
    return {
        layers = {},
        newLayers = {},
        layerIndex = 0,
        isUnwinding = false,
        isDrawing = false
    }
end

--- @param rootContext IUIRootContext
function layer.setRootContext(rootContext)
    ctx = rootContext.layer
end

function layer.beginFrame()
    ctx.isDrawing = false
    ctx.layerIndex = 0
    ctx.newLayers = {}
    iui.beginLayer("__root")
    setInputActive()
end

function layer.endFrame()
    iui.endLayer()
    ctx.layers = ctx.newLayers
    ctx.isUnwinding = false
end

--- @return number? id
function layer.getFocusID()
    if (not ctx.isDrawing) or (ctx.layerIndex == #ctx.newLayers) then
        return layer.getCurrentLayer().focusID
    end
end

--- @param id? number
function layer.setFocusID(id)
    layer.getCurrentLayer().focusID = id
end

--- @return number? id
function layer.getLastID()
    return layer.getCurrentLayer().lastID
end

--- @param id? number
function layer.setLastID(id)
    layer.getCurrentLayer().lastID = id
end

function layer.willDrawLayer(index)
    ctx.isDrawing = true
    ctx.layerIndex = index
end

function iui.beginLayer(name)
    if ctx.isUnwinding then
        error("Attempt to begin layer after having ended layers")
    end

    ctx.layerIndex = ctx.layerIndex + 1

    if #ctx.newLayers < #ctx.layers then
        local existing = ctx.layers[#ctx.newLayers + 1]
        if existing.name == name then
            table.insert(ctx.newLayers, existing)
        else
            ctx.layers = ctx.newLayers

            --- @type IUILayer
            local newLayer = { name = name }
            table.insert(ctx.newLayers, newLayer)
        end
    else
        --- @type IUILayer
        local newLayer = { name = name }
        table.insert(ctx.newLayers, newLayer)
    end

    setInputActive()
    iui.draw.beginContext()
end

function iui.endLayer()
    ctx.isUnwinding = true
    ctx.layerIndex = ctx.layerIndex - 1
    if ctx.layerIndex < 0 then
        error("Layer index underflow")
    end
    setInputActive()
    iui.draw.endContext()
end

iui.layer = layer
