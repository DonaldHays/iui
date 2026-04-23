local currentPath = (...):match('(.-)[^%./]+$')

--- @class IUILib
local iui = require(currentPath .. "iui")

--- A type that stores an unordered collection of unique values.
--- @class IUISet<T>
--- @field private storage table<T, true>
--- @field new fun(): IUISet<T> Returns a new set.
--- @field put fun(self: self, v: T) Inserts `v`, if not already present.
--- @field remove fun(self: self, v: T) Removes `v`, if present.
--- @field removeAll fun(self: self) Removes all values.
--- @field has fun(self: self, v: T): boolean Returns whether the set has `v`.
--- @field getCount fun(self: self): number Returns the number of values, in O(n) time.
local Set = {}
Set.__index = Set

function Set.new()
    local out = {
        storage = {}
    }

    setmetatable(out, Set)

    return out
end

function Set:put(v)
    self.storage[v] = true
end

function Set:remove(v)
    self.storage[v] = nil
end

function Set:removeAll()
    local storage = self.storage
    for k, _ in pairs(storage) do
        storage[k] = nil
    end
end

function Set:has(v)
    return self.storage[v] == true
end

function Set:getCount()
    local count = 0
    for _ in pairs(self.storage) do
        count = count + 1
    end
    return count
end

iui.set = Set
