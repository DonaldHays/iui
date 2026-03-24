--- @meta _

--- @class IUISystemBackend
local system = {}

--- @return number timestamp
function system.getTimestamp()
end

--- @param name IUICursorName
--- @return IUICursor
function system.getSystemCursor(name)
end

--- @param cursor IUICursor
function system.setCursor(cursor)
end

--- @return number dpi
function system.getDPI()
end

function system.quit()
end
