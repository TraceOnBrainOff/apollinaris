Display = {}

function Display:new()
    self._index = self

    local interfaceJsonConfig = root.assetJson("/interface/apollinarisInterface/conf.config") -- widget. functions fucking suck dude
    local size = {0,0}
    local parts = {"fileHeader", "fileBody", "fileFooter"}
    for i, name in ipairs(parts) do
        local imgSize = root.imageSize(interfaceJsonConfig.gui.background[name])
        size[1] = imgSize[1]
        size[2] = size[2] + imgSize[2]
    end
    self.size = size
    return self
end