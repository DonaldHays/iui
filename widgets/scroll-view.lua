local currentPath = (...):match('(.-)[^%./]+$')
local parentPath = currentPath:match('(.-)[^%./]+%.$')

--- @class IUILib
local iui = require(parentPath .. "iui")

--- @class (exact) IUIScrollViewState
--- @field manager? IUIScrollManager
--- @field vy? number
--- @field dragOrigin? { x: number, y: number }
--- @field isDragging? boolean

--- @class IUIScrollManager
--- @field x number
--- @field y number
--- @field contentWidth number
--- @field contentHeight number
--- @field clipWidth number
--- @field clipHeight number
local ScrollManager = {}
ScrollManager.__index = ScrollManager

function ScrollManager:fixOffset()
    self.x = math.max(math.min(self.x, self.contentWidth - self.clipWidth), 0)
    self.y = math.max(math.min(self.y, self.contentHeight - self.clipHeight), 0)
end

--- @param x number
--- @param y number
--- @param w? number
--- @param h? number
function ScrollManager:scrollTo(x, y, w, h)
    local minX = self.x
    local maxX = self.x + self.clipWidth
    local targetMinX = x
    local targetMaxX = x + (w or 1)

    local minY = self.y
    local maxY = self.y + self.clipHeight
    local targetMinY = y
    local targetMaxY = y + (h or 1)

    if targetMaxX > maxX then
        maxX = targetMaxX
        minX = maxX - self.clipWidth
    end

    if targetMinX < minX then
        minX = targetMinX
        maxX = minX + self.clipWidth
    end

    if targetMaxY > maxY then
        maxY = targetMaxY
        minY = maxY - self.clipHeight
    end

    if targetMinY < minY then
        minY = targetMinY
        maxY = minY + self.clipHeight
    end

    self.x = minX
    self.y = minY

    self:fixOffset()
end

iui.ScrollManager = ScrollManager

--- @return IUIScrollManager
function iui.newScrollManager()
    --- @type IUIScrollManager
    local out = setmetatable({}, ScrollManager)

    out.x = 0
    out.y = 0
    out.contentWidth = 0
    out.contentHeight = 0
    out.clipWidth = 0
    out.clipHeight = 0

    return out
end

--- @param name string
--- @param content fun()
--- @param manager? IUIScrollManager
function iui.scrollView(name, content, manager)
    local id = iui.beginID(name, false)

    --- @type IUIScrollViewState
    local state = iui.state(id)

    if not manager then
        manager = state.manager

        if not manager then
            manager = iui.newScrollManager()
            state.manager = manager
        end
    end

    local x, y, w, h = iui.layout.getBounds()
    local containsMouse = iui.layout.containsPoint()

    local disabled = iui.isDisabled()

    local scrollSize = iui.style["scrollSize"]

    local innerX, innerY = x + 1, y + 1
    local innerW, innerH = w - (3 + scrollSize), h - 2
    local scrollX, scrollY = innerX + innerW + 1, innerY
    local scrollW, scrollH = scrollSize, innerH

    iui.colors.sysGray200:set()
    iui.graphics.rectangle(x, y, w, h)

    iui.colors.sysGray0:set()
    iui.graphics.rectangle(innerX, innerY, innerW, innerH)

    iui.layout.beginZStack()
    iui.draw.pushClip(innerX, innerY, innerW, innerH)
    local panel = iui.layout.beginPanel(innerX, innerY, innerW, innerH)
    panel.rowY = panel.rowY - iui.utils.round(manager.y)
    content()
    local cw, ch = iui.layout.getContentSize()
    cw, ch = cw + manager.x, ch + iui.utils.round(manager.y)
    iui.layout.endPanel()
    iui.draw.popClip()

    panel = iui.layout.beginPanel(scrollX, scrollY, scrollW, scrollH, 0)
    iui.layout.fillPanel()
    manager.y = iui.scrollBar("scroll", "vert", manager.y, innerH, 0, ch)
    iui.layout.endPanel()
    iui.layout.endZStack()

    if state.vy ~= nil and state.vy ~= 0 then
        manager.y = manager.y + state.vy * iui.dt
        state.vy = state.vy * math.exp(-4 * iui.dt)
        if math.abs(state.vy) * iui.dt < 0.05 then
            state.vy = 0
        end
    end

    local mx, my = iui.input.mouse.x, iui.input.mouse.y

    if not disabled then
        if containsMouse then
            local scrollIncrement = iui.input.mouse.scrollY * 21
            if iui.input.keyboard.down:has("lalt") then
                scrollIncrement = scrollIncrement * 5
            end
            manager.y = manager.y - scrollIncrement

            -- Set up a potential drag event
            if iui.input.mouse.pressed:has(1) then
                -- Terminate any scrolling
                state.vy = 0

                -- The mouse must not be in the scrollbar
                local isOutsideScroll = false
                isOutsideScroll = isOutsideScroll or mx < scrollX
                isOutsideScroll = isOutsideScroll or mx >= scrollX + scrollW
                isOutsideScroll = isOutsideScroll or my < scrollY
                isOutsideScroll = isOutsideScroll or my >= scrollY + scrollH

                local canScroll = ch > innerH
                canScroll = canScroll and iui.idiom == "vr"
                if isOutsideScroll and canScroll then
                    state.dragOrigin = { x = mx, y = my }
                end
            end
        end

        if state.dragOrigin then
            if not iui.input.mouse.down:has(1) then
                state.dragOrigin = nil
            else
                -- local dx = mx - state.dragOrigin.x
                local dy = my - state.dragOrigin.y
                if math.abs(dy) > 15 then
                    state.dragOrigin = nil
                    state.isDragging = true
                    iui.becomeActive(id)
                end
            end
        end

        if state.isDragging then
            if not iui.input.mouse.down:has(1) then
                state.isDragging = false
                iui.activeID = nil
                -- state.vy = -iui.input.mouse.dy / iui.dt
                _, state.vy = iui.input.mouse.getVelocity()
                if math.abs(state.vy) > 2000 then
                    state.vy = iui.utils.sign(state.vy) * 2000
                end
            else
                manager.y = manager.y - iui.input.mouse.dy
            end
        end
    end

    manager.clipWidth = innerW
    manager.clipHeight = innerH
    manager.contentWidth = cw
    manager.contentHeight = ch

    manager:fixOffset()

    iui.endID()
end
