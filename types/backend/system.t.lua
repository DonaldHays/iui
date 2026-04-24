--- @meta _

--- @class IUISystemBackend
local system = {}

--- Returns the name of the host operating system.
---
--- Valid responses include, but are not limited to, "Windows", "macOS",
--- "Linux", "Android", and "iOS".
---
--- @return string
function system.getOS()
end

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

--- @param name string
function system.getMSDFImage(name)
end

--- @return number dpi
function system.getDPI()
end

function system.quit()
end
