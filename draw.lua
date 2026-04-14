local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- @class IUIDraw
--- @overload fun()
local draw = {}

--- @class (exact) IUIDrawCommand
--- @field commit fun(command: IUIDrawCommand)

--- @class (exact) IUIDrawContext
--- @field commands IUIDrawCommand[]
--- @field currentClip? number[]
--- @field clipStack number[][]
--- @field hideCount number

--- @class (exact) IUIDrawRootContext
--- @field width number
--- @field height number
--- @field drawContexts IUIDrawContext[]
--- @field contextIndex number

local ctx --- @type IUIDrawRootContext

--- @param idx? number
--- @return IUIDrawContext
local function getDrawContext(idx)
    return ctx.drawContexts[idx or ctx.contextIndex]
end

setmetatable(draw --[[@as any]], {
    __call = function(_, onDraw)
        if onDraw then
            error("IUI no longer takes draw blocks")
        else
            iui.graphics.beginDraw(ctx.width, ctx.height)
            for index, context in ipairs(ctx.drawContexts) do
                iui.layer.willDrawLayer(index)
                for _, command in ipairs(context.commands) do
                    command.commit(command)
                    iui.pool.put(command)
                end
            end
            iui.graphics.endDraw()
        end
    end
})

--- @param command IUIDrawCommand
--- @overload fun(f: function)
function draw.enqueue(command)
    local drawContext = getDrawContext()
    if drawContext.hideCount == 0 then
        if type(command) == "function" then
            --- @type IUIDrawCommand
            local cmd = iui.pool.get("function_draw_command")

            cmd.commit = command

            table.insert(drawContext.commands, cmd)
        else
            table.insert(drawContext.commands, command)
        end
    end
end

--- @return IUIDrawRootContext
function draw.newRootContext()
    --- @type IUIDrawRootContext
    return {
        width = 0,
        height = 0,
        drawContexts = {},
        contextIndex = 0
    }
end

--- @param rootContext IUIRootContext
function draw.setRootContext(rootContext)
    ctx = rootContext.draw
end

function draw.beginFrame()
    ctx.drawContexts = {}
end

function draw.endFrame()
    if getDrawContext().currentClip ~= nil then
        error("Clip stack was not empty at end of frame")
    end
end

function draw.setWindowSize(width, height)
    ctx.width, ctx.height = width, height
end

function draw.beginContext()
    --- @type IUIDrawContext
    local drawContext = {
        clipStack = {},
        commands = {},
        hideCount = 0
    }
    table.insert(ctx.drawContexts, drawContext)
    ctx.contextIndex = #ctx.drawContexts
end

function draw.endContext()
    if getDrawContext().hideCount ~= 0 then
        error("Hide count was not 0 at end of context")
    end

    ctx.contextIndex = ctx.contextIndex - 1
end

function draw.beginHiding()
    getDrawContext().hideCount = getDrawContext().hideCount + 1
end

function draw.endHiding()
    getDrawContext().hideCount = getDrawContext().hideCount - 1
end

--- @param x number The x coordinate of the clip region
--- @param y number The y coordinate of the clip region
--- @param w number The width of the clip region
--- @param h number The height of the clip region
function draw.pushClip(x, y, w, h)
    local drawContext = getDrawContext()
    local currentClip = drawContext.currentClip
    if currentClip then
        table.insert(drawContext.clipStack, currentClip)

        local maxX, maxY = x + w, y + h
        local cx, cy = currentClip[1], currentClip[2]
        local cMaxX, cMaxY = cx + currentClip[3], cy + currentClip[4]

        x = math.max(x, cx)
        y = math.max(y, cy)
        maxX = math.min(maxX, cMaxX)
        maxY = math.min(maxY, cMaxY)

        w = math.max(0, maxX - x)
        h = math.max(0, maxY - y)
    end

    drawContext.currentClip = { x, y, w, h }
    iui.graphics.clip(x, y, w, h)
end

function draw.popClip()
    local drawContext = getDrawContext()
    if drawContext.currentClip == nil then
        error("Attempt to pop empty clip stack")
    end

    if #drawContext.clipStack > 0 then
        drawContext.currentClip = table.remove(drawContext.clipStack)
    else
        drawContext.currentClip = nil
    end

    iui.graphics.clip()
end

--- @return number? x, number? y, number? w, number? h
function draw.getClipBounds()
    local currentClip = getDrawContext().currentClip
    if currentClip then
        return currentClip[1], currentClip[2], currentClip[3], currentClip[4]
    else
        return
    end
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
function draw.panelBackground(x, y, w, h)
    if iui.idiom ~= "vr" then
        iui.graphics.rectangle(x, y, w, h)
        return
    end

    local ww, wh = iui.layout.windowWidth, iui.layout.windowHeight
    local radius = iui.style["vrWindowCornerRadius"]
    local bx, by, bw, bh = x, y, w, h
    local insetCount = 0

    if x > 0 then
        insetCount = insetCount + 1
        bx = bx - radius
        bw = bw + radius
    end

    if y > 0 then
        insetCount = insetCount + 1
        by = by - radius
        bh = bh + radius
    end

    if x + w < ww then
        insetCount = insetCount + 1
        bw = bw + radius
    end

    if y + h < wh then
        insetCount = insetCount + 1
        bh = bh + radius
    end

    if insetCount == 4 then
        iui.graphics.rectangle(x, y, w, h)
    else
        iui.graphics.clip(x, y, w, h)
        iui.graphics.rectangle(bx, by, bw, bh, radius, radius)
        iui.graphics.clip()
    end
end

iui.draw = draw
