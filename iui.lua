--- @class IUILib
--- @field dt number The time since the last frame began.
--- @field resourcePath string
--- @field idiom IUIIdiom
--- @field detail IUIDetail
--- @field backend IUIBackend
--- @field graphics IUIGraphicsBackend
--- @field disabledCount number
--- @field hoverID? number The ID of the widget a pointer is hovering over.
--- @field activeID? number The ID of the widget that's being actively used.
--- @field cursor? IUICursorName The desired mouse cursor to display.
--- @field hadActiveID boolean Internal flag for detecting widget deactivation.
--- @field widgetActivated? fun() A callback when a widget becomes active.
--- @field widgetDeactivated? fun() A callback when a widget resigns active.
local iui = {}

--- @type IUICursorName?
local currentCursor = nil

--- @type table<IUICursorName, IUICursor>
local cursors = {}

--- @type IUIRootContext
local rootContext

local rootKeys = {
    disabledCount = true,
    hoverID = true,
    activeID = true,
    hadActiveID = true,
    cursor = true
}

setmetatable(iui, {
    __index = function(t, k)
        if rootKeys[k] then
            return rootContext[k]
        end

        return nil
    end,
    __newindex = function(t, k, v)
        if rootKeys[k] then
            rootContext[k] = v
        else
            rawset(t, k, v)
        end
    end
})

--- @param backend IUIBackend
--- @param config? IUIConfig
function iui.load(backend, config)
    config = config or {}
    backend.config(config)

    iui.idiom = config.idiom or error("No idiom specified")
    iui.detail = config.detail or error("No detail specified")
    iui.dpi = config.dpi or backend.system.getDPI()

    iui.backend = backend
    iui.graphics = iui.drawQueue

    iui.drawQueue.setBackend(backend.graphics)

    backend.load(iui)

    --- @type IUICursorName[]
    local cursorNames = { "ibeam", "sizewe", "sizens" }
    for _, name in ipairs(cursorNames) do
        cursors[name] = iui.backend.system.getSystemCursor(name)
    end

    iui.style.load()
end

--- @param newRootContext IUIRootContext
function iui.setRootContext(newRootContext)
    rootContext = newRootContext

    iui.input.setRootContext(rootContext)
    iui.draw.setRootContext(rootContext)
    iui.layer.setRootContext(rootContext)
    iui.state.setRootContext(newRootContext)
end

--- @param dt number
function iui.beginFrame(dt)
    iui.dt = dt

    iui.backend.beginFrame(dt)
end

--- @param width number
--- @param height number
function iui.beginWindow(width, height)
    iui.layout.windowWidth = width
    iui.layout.windowHeight = height
    iui.draw.setWindowSize(width, height)

    iui.layout.beginPanel(0, 0, width, height)
end

function iui.endWindow()
    iui.layout.endPanel()
end

function iui.endFrame()
    iui.backend.endFrame()

    if currentCursor ~= iui.cursor then
        currentCursor = iui.cursor

        iui.backend.system.setCursor(cursors[currentCursor])
    end
end

function iui.beginDisabled()
    iui.disabledCount = iui.disabledCount + 1
end

function iui.endDisabled()
    if iui.disabledCount == 0 then
        error("Control disable underflow")
    end

    iui.disabledCount = iui.disabledCount - 1
end

--- @return boolean isDisabled
function iui.isDisabled()
    return iui.disabledCount ~= 0
end

--- @param name? IUICursorName
--- @return IUICursor?
function iui.getCursor(name)
    if name then
        return cursors[name]
    end
end

return iui
