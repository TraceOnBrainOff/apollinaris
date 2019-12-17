Cursor = {
    position = {0,0},
    isHeld = false
}

function Cursor:new()
    self._index = self
    return self
end

function Cursor:setPosition(pos)
    self.position = pos
end

function Cursor:registerClick(position, button, isButtonDown)
    sb.logInfo("Pos ".. sb.printJson(position))
    sb.logInfo("button ".. button)
    sb.logInfo("isButtonDown ".. tostring(isButtonDown))
    self.isHeld = isButtonDown
    self.click = {position = position, button = button}
end

function Cursor:resetClick()
    self.click = nil
end