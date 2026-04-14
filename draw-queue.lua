local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

local backend --- @type IUIGraphicsBackend

--- @class IUIDrawQueue: IUIGraphicsBackend
local drawQueue = {}

--- @class (exact) IUIClipDrawCommand: IUIDrawCommand
--- @field x? number
--- @field y? number
--- @field w? number
--- @field h? number

--- @param cmd IUIClipDrawCommand
local function commitClip(cmd)
    backend.clip(cmd.x, cmd.y, cmd.w, cmd.h)
end

function drawQueue.clip(x, y, w, h)
    --- @type IUIClipDrawCommand
    local cmd = iui.pool.get("clip_draw_command")

    cmd.x = x
    cmd.y = y
    cmd.w = w
    cmd.h = h
    cmd.commit = commitClip

    iui.draw.enqueue(cmd)
end

--- @class (exact) IUISetColorDrawCommand: IUIDrawCommand
--- @field r number
--- @field g number
--- @field b number
--- @field a? number

--- @param cmd IUISetColorDrawCommand
local function commitSetColor(cmd)
    backend.setColor(cmd.r, cmd.g, cmd.b, cmd.a)
end

function drawQueue.setColor(r, g, b, a)
    --- @type IUISetColorDrawCommand
    local cmd = iui.pool.get("set_color_draw_command")

    cmd.r = r
    cmd.g = g
    cmd.b = b
    cmd.a = a
    cmd.commit = commitSetColor

    iui.draw.enqueue(cmd)
end

--- @class (exact) IUIRectangleDrawCommand: IUIDrawCommand
--- @field x number
--- @field y number
--- @field w number
--- @field h number
--- @field rx? number
--- @field ry? number

--- @param cmd IUIRectangleDrawCommand
local function commitRectangle(cmd)
    backend.rectangle(cmd.x, cmd.y, cmd.w, cmd.h, cmd.rx, cmd.ry)
end

function drawQueue.rectangle(x, y, w, h, rx, ry)
    --- @type IUIRectangleDrawCommand
    local cmd = iui.pool.get("rectangle_draw_command")

    cmd.x = x
    cmd.y = y
    cmd.w = w
    cmd.h = h
    cmd.rx = rx
    cmd.ry = ry
    cmd.commit = commitRectangle

    iui.draw.enqueue(cmd)
end

--- @class (exact) IUICircleDrawCommand: IUIDrawCommand
--- @field x number
--- @field y number
--- @field r number

--- @param cmd IUICircleDrawCommand
local function commitCircle(cmd)
    backend.circle(cmd.x, cmd.y, cmd.r)
end

function drawQueue.circle(x, y, r)
    --- @type IUICircleDrawCommand
    local cmd = iui.pool.get("circle_draw_command")

    cmd.x = x
    cmd.y = y
    cmd.r = r
    cmd.commit = commitCircle

    iui.draw.enqueue(cmd)
end

--- @class (exact) IUISetFontDrawCommand: IUIDrawCommand
--- @field f any

--- @param cmd IUISetFontDrawCommand
local function commitSetFont(cmd)
    backend.setFont(cmd.f)
end

function drawQueue.setFont(f)
    --- @type IUISetFontDrawCommand
    local cmd = iui.pool.get("set_font_draw_command")

    cmd.f = f
    cmd.commit = commitSetFont

    iui.draw.enqueue(cmd)
end

--- @class (exact) IUIPrintDrawCommand: IUIDrawCommand
--- @field s string
--- @field x number
--- @field y number

--- @param cmd IUIPrintDrawCommand
local function commitPrint(cmd)
    backend.print(cmd.s, cmd.x, cmd.y)
end

function drawQueue.print(s, x, y)
    --- @type IUIPrintDrawCommand
    local cmd = iui.pool.get("print_draw_command")

    cmd.s = s
    cmd.x = x
    cmd.y = y
    cmd.commit = commitPrint

    iui.draw.enqueue(cmd)
end

--- @class (exact) IUIImageDrawCommand: IUIDrawCommand
--- @field image any
--- @field filter IUIImageFilter
--- @field x number
--- @field y number
--- @field w number
--- @field h number

--- @param cmd IUIImageDrawCommand
local function commitImage(cmd)
    backend.image(cmd.image, cmd.filter, cmd.x, cmd.y, cmd.w, cmd.h)
end

function drawQueue.image(image, filter, x, y, w, h)
    --- @type IUIImageDrawCommand
    local cmd = iui.pool.get("image_draw_command")

    cmd.image = image
    cmd.filter = filter
    cmd.x = x
    cmd.y = y
    cmd.w = w
    cmd.h = h
    cmd.commit = commitImage

    iui.draw.enqueue(cmd)
end

--- @class (exact) IUIMSDFImageDrawCommand: IUIDrawCommand
--- @field image any
--- @field x number
--- @field y number
--- @field w number
--- @field h number

--- @param cmd IUIMSDFImageDrawCommand
local function commitMSDFImage(cmd)
    backend.msdfImage(cmd.image, cmd.x, cmd.y, cmd.w, cmd.h)
end

function drawQueue.msdfImage(image, x, y, w, h)
    --- @type IUIMSDFImageDrawCommand
    local cmd = iui.pool.get("msdf_image_draw_command")

    cmd.image = image
    cmd.x = x
    cmd.y = y
    cmd.w = w
    cmd.h = h
    cmd.commit = commitMSDFImage

    iui.draw.enqueue(cmd)
end

--- @class (exact) IUINineSliceDrawCommand: IUIDrawCommand
--- @field nineSlice IUIImage9Slice
--- @field filter IUIImageFilter
--- @field x number
--- @field y number
--- @field w number
--- @field h number

--- @param cmd IUINineSliceDrawCommand
local function commitNineSlice(cmd)
    backend.nineSlice(cmd.nineSlice, cmd.filter, cmd.x, cmd.y, cmd.w, cmd.h)
end

function drawQueue.nineSlice(nineSlice, filter, x, y, w, h)
    --- @type IUINineSliceDrawCommand
    local cmd = iui.pool.get("nine_slice_draw_command")

    cmd.nineSlice = nineSlice
    cmd.filter = filter
    cmd.x = x
    cmd.y = y
    cmd.w = w
    cmd.h = h
    cmd.commit = commitNineSlice

    iui.draw.enqueue(cmd)
end

--- @class (exact) IUIMSDFNineSliceDrawCommand: IUIDrawCommand
--- @field nineSlice IUIImage9Slice
--- @field x number
--- @field y number
--- @field w number
--- @field h number

--- @param cmd IUIMSDFNineSliceDrawCommand
local function commitMSDFNineSlice(cmd)
    backend.msdfNineSlice(cmd.nineSlice, cmd.x, cmd.y, cmd.w, cmd.h)
end

function drawQueue.msdfNineSlice(nineSlice, x, y, w, h)
    --- @type IUIMSDFNineSliceDrawCommand
    local cmd = iui.pool.get("msdf_nine_slice_draw_command")

    cmd.nineSlice = nineSlice
    cmd.x = x
    cmd.y = y
    cmd.w = w
    cmd.h = h
    cmd.commit = commitMSDFNineSlice

    iui.draw.enqueue(cmd)
end

--- @param graphicsBackend IUIGraphicsBackend
function drawQueue.setBackend(graphicsBackend)
    backend = graphicsBackend
    setmetatable(drawQueue, {
        __index = graphicsBackend
    })
end

iui.drawQueue = drawQueue
