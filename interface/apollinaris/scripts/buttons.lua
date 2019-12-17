Button = {
    position = {0,0},
    isHighlighted = false,
    isVisible = false,
    layer = 1,
    color = {0,0,0},
    box = rect.zero(),
    pressed = false,
    anchorsT = {
        left = 0.5,
        up = -0.5,
        mid = 0,
        right = -0.5,
        down = 0.5
    }
}

buttons = {}

function Button:newButton(position, size, layer, misc) -- misc contains func, text, anchors(double array)
    self._index = self
    self.layer = layer
    self.position = position
    self.color = color:dark()
    self.size = size
    if misc then
        for name, v in pairs(misc) do
            self[name] = v -- could just do a manual import but i like flexing on the slightest of things
        end
    end
    if not self.anchors then
        self.anchors = {vertical = "mid", horizontal = "mid"}
    else
        self.anchors.vertical = self.anchors.vertical and self.anchors.vertical or "mid"
        self.anchors.horizontal = self.anchors.vertical and self.anchors.horizontal or "mid"
    end

    self.rawBox = rect.fromVec2({-size[1]/2, -size[2]/2}, {size[1]/2, size[2]/2})
    self.box = rect.translate(self.rawBox, vec2.add(self.position, {
        self.anchorsT[self.anchors.horizontal]*size[1],
        self.anchorsT[self.anchors.vertical]*size[2]
    }))

    self.id = #buttons + 1
    buttons[self.id] = self
    return self.id
end

function Button:update()
    if not cursor or not color then
        return
    end
    self.color = color:dark()
    if cursor.click then
        if rect.contains(self.box, cursor.click.position) then
            self.pressed = cursor.isHeld
        end
    end
    if rect.contains(self.box, cursor.position) then
        self.isHighlighted = true
        self.color = color:light()
        if self.pressed then
            self.color = color:lightest()
        end
    else
        self.pressed = false
    end
end

function Button:render(canvas)
    canvas:drawRect(self.box, self.color)
    if self.text then
        canvas:drawText(self.text.str, {
            position = rect.center(self.box),
            horizontalAnchor = "mid",
            verticalAnchor = "mid"
        }, self.text.size, self.text.color)
    end
end

function Button:setPosition(pos)
    self.position = pos
    self.box = rect.translate(self.rawBox, vec2.add(self.position, {
        self.anchorsT[self.anchors.horizontal]*self.size[1],
        self.anchorsT[self.anchors.vertical]*self.size[2]
    }))
end

function Button:setAnchors()

end