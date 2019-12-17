Energy = {}
Energy.__index = Energy

--[[
    Todo:
    - Restore functionality to at least what it was before
    - Change the regen color to the palette, bright when high, dark when low
]]

function Energy:assign()
    self = {}
    setmetatable(self, Energy)
    self.energy = status.resourcePercentage("energy") -- Working with percentages i guess
    self.regenBarAlpha = 1.0
    return self
end

function Energy:update()
    local colorProgress = status.resourcePercentage("energy")
    self.energy = colorProgress*100
    local rgbPalette = {color:rgb(6), color:rgb(1)} -- darkest to lightest
    local currentRegenColor = {}
    for i=1, 3 do
        currentRegenColor[#currentRegenColor+1] = rgbPalette[1][i] - (rgbPalette[1][i]-rgbPalette[2][i])*colorProgress
    end
    dll.setEnergyBarColor(currentRegenColor[1], currentRegenColor[2], currentRegenColor[3], 255, "energyBarRegenColor")
end

function Energy:changeEnergy(amount) -- Yea, working with percentages
    if amount == 0 then return end -- Failsafe for skills with lacking metadata will default to 0, so im making this do nothing in advance
    if status.resourcePercentage("energy") < -amount/100 then
        status.setResourcePercentage("energy", 0.0)
    end
    status.modifyResourcePercentage("energy", amount/100)
end

function Energy:showRegenBar()
    status.setResourcePercentage("energyRegenBlock", self.regenBarAlpha)
end

function Energy:currentEnergy()
    return status.resourcePercentage("energy")*100
end

function Energy:isLocked()
    return status.resourceLocked("energy")
end

function Energy:setEnergyBarUnusableColor()
    local darkest = color:rgb(6)
    dll.setEnergyBarColor(darkest[1], darkest[2], darkest[3], 255, "energyBarUnusableColor")
end

function Energy:uninit()

end