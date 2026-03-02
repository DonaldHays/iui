--- @meta _

--- @class IUICursor

--- @alias IUICursorName "ibeam" | "sizewe" | "sizens"

--- @class IUIBackend
--- @field system IUISystemBackend
--- @field graphics IUIGraphicsBackend
local backend = {}

--- @param config IUIConfig
function backend.config(config)
end

--- @param lib IUILib
function backend.load(lib)
end

--- @param dt number
function backend.beginFrame(dt)
end

function backend.endFrame()
end
