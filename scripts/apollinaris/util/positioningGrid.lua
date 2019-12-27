PositioningGrid = {}
PositioningGrid.__index = PositioningGrid
PositioningCell = {}
PositioningCell.__index = PositioningCell
PositioningLine = {}
PositioningLine.__index = PositioningLine
PositioningCircle = {}
PositioningCircle.__index = PositioningCircle

-- Used for giving abilities a frame of reference where to start, end, if a combo extender can be cast in that position, etc

PositioningGrid.openAnimation = function(self)
    local time = self.transitionDuration
    local maxRadius = self.maxRadius -- it's still ^2
    for i=0, time do
        local currentRadius = maxRadius/time * i
        self.currentRadius = currentRadius
        self.progressCircle:setVisible(true)
        for i, line in ipairs(self.lines) do
            line:changeHypotenuse(currentRadius)
            --line:changeWidth(math.random(1,3)) cool effect
        end
        self.progressCircle:changeSize(math.sqrt(currentRadius))
        --self.progressCircle:changeWidth(math.random(1,3)) ditto
        coroutine.yield()
    end
    return
end

function PositioningCell:assign(rectangle)
    local self = {}
    setmetatable(self, PositioningCell)
    self.rect = rectangle
    self.center = rect.center(rectangle)
    return self
end

function PositioningCell:render()
    world.debugPoint(vec2.add(mcontroller.position(), self.center), {255,0,0,255})
end

function PositioningCell:checkValidity(hypotenuse)
    local funcs = {"ul", "ur", "ll", "lr"} -- just a quick way of looping through all rect. corner functions
    for i, func in ipairs(funcs) do
        local vertice = rect[func](self.rect)
        local currentHypotenuse = vertice[1]^2 + vertice[2]^2 -- don't sqrt it
        if currentHypotenuse > hypotenuse then -- if any of the vertices is outside of the maximum radius given to the positioningGrid, this means the entire cell is invalid
            return false
        end
    end
    return true
end

function PositioningLine:assign(center, mode)
    local self = {}
    setmetatable(self, PositioningLine)
    self.center = center
    self.mode = mode
    self.isVisible = false
    self.line = {{0,0}, {0,0}}
    self.lineWidth = 1
    self.lineColor = {255,0,0,255}
    return self
end

function PositioningLine:changeWidth(a)
    self.lineWidth = a
end

function PositioningLine:vertical(hypotenuse)
    if self.center[1] >= hypotenuse then -- if the lines are vertical, it means the X coordinate changes from line to line
        self.isVisible = false
        self.line = {{0,0}, {0,0}} -- it's actually half of the width but whatev
        return
    end
    local lineWidth = math.sqrt(hypotenuse - self.center[1]^2) -- floating points more like astral points
    self.line = {{0, -lineWidth}, {0, lineWidth}}
    self.isVisible = true
end

function PositioningLine:horizontal(hypotenuse)
    if self.center[2] >= hypotenuse then -- same as above but the other way around
        self.isVisible = false
        self.line = {{0,0}, {0,0}} -- it's actually half of the width but whatev
        return
    end
    local lineWidth = math.sqrt(hypotenuse - self.center[2]^2)
    self.line = {{-lineWidth, 0}, {lineWidth, 0}}
    self.isVisible = true
end

function PositioningLine:changeHypotenuse(hypotenuse)
    self.hypotenuse = hypotenuse
    self[self.mode](self, hypotenuse) -- self
end

function PositioningLine:setColor(newColor)
    self.lineColor = newColor
end

function PositioningLine:render()
    if self.isVisible then
        localAnimator.addDrawable({line = self.line, width = self.lineWidth, color = self.lineColor, position = self.center, fullbright = true}, "Overlay+3")
    end
end

function PositioningCircle:assign(radius)
    self = {}
    setmetatable(self, PositioningCircle)
    self.smoothness = 24
    self.radius = radius
    self.isVisible = false
    self.lineWidth = 1
    self:changeSize(radius) -- sets self.lineSet
    return self
end

function PositioningCircle:changeWidth(a)
    self.lineWidth = a
end

function PositioningCircle:changeSize(radius) -- sqrt it!
    local angleDelta = 360/self.smoothness
    local lineSet = {}
    for i=1, (self.smoothness) do
        local previousAngle = angleDelta*(i-1)
        local currentAngle = angleDelta*i
        lineSet[#lineSet+1] = {util.trig({0,0}, radius, math.rad(previousAngle)), util.trig({0,0}, radius, math.rad(currentAngle))}
    end
    self.lineSet = lineSet
    self.radius = radius
end

function PositioningCircle:render()
    if self.isVisible then
        for i, line in ipairs(self.lineSet) do
            localAnimator.addDrawable({line = line, width = self.lineWidth, color = {255,0,0,255}, position = {0,0}, fullbright = true}, "Overlay+3")
        end
    end
end

function PositioningCircle:setVisible(a)
    self.isVisible = a
end

function PositioningGrid:assign()
    local self = {}
    setmetatable(self, PositioningGrid)
    self.size = 5 -- temp debug values
    self.cellNumber = 3 -- ditto
    self.maxRadius = (self.size/2)^2 + ((self.size/2) + self.cellNumber*self.size)^2 -- pythagorean theorem used to get the length, but this value remains ^2 [OK]
    self.currentRadius = 0
    self.transitionDuration = 300 -- frames
    self:newGrid()
    self.progressCircle = PositioningCircle:assign(0)
    return self
end

function PositioningGrid:newGrid()
    local grid = {rows = {}}
    local lines = {}
    local verticesInSide = self.cellNumber*2 + 2
    for yIter=1, verticesInSide do
        local row = {}
        local y = (yIter-(self.cellNumber+1.5))*self.size
        for xIter=1, verticesInSide do
            local x = (xIter-(self.cellNumber+1.5))*self.size
            row[xIter] = {x,y}
        end
        grid.rows[yIter] = row
        if not (yIter==1 or yIter==verticesInSide) then -- Don't allow for the addition of lines on the outer sides to save 4 unnecessary lines from being drawn
            lines[#lines+1] = PositioningLine:assign({y,0}, "vertical") -- y can be reused for line center positions, that's cool
            lines[#lines]:setColor(color:random())
            lines[#lines+1] = PositioningLine:assign({0,y}, "horizontal")
            lines[#lines]:setColor(color:random())
        end -- I don't think i need to check the validity of these (if the center is contained within the center i mean)
    end
    self.lines = lines
    local cells = {rows = {}}
    for yIter=1, (verticesInSide-1) do -- reduced by one, as it's grabbing values from an array + 1
        local row = {}
        for xIter=1, (verticesInSide-1) do
            local upRight = grid.rows[yIter][xIter+1]
            local bottomLeft = grid.rows[yIter+1][xIter]
            local newCell = PositioningCell:assign(rect.fromVec2(bottomLeft, upRight))
            if newCell:checkValidity(self.maxRadius) then -- if it's within the boundries of the most outside rim, it's okay
                row[#row+1] = newCell
            end
        end
        cells.rows[yIter] = row
    end
    self.cells = cells
end

function PositioningGrid:render()
    for i, cellArray in ipairs(self.cells.rows) do
        for j, cell in ipairs(cellArray) do
            cell:render()
        end
    end
    for i, line in ipairs(self.lines) do
        line:render()
    end
    self.progressCircle:render()
end

function PositioningGrid:update()
    if self.co and coroutine.status(self.co) ~= "dead" then
        local working, isDone = coroutine.resume(self.co, self)
        if not working then
            sb.logError(isDone)
        end
    end
    self:render()
end

function PositioningGrid:open()
    if not (self.co and coroutine.status(self.co) ~= "dead") and not self.isOpen then
        self.co = coroutine.create(self.openAnimation)
    end
end

