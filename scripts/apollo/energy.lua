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
    return self
end

function Energy:update()
end

function Energy:changeEnergy(amount) -- Yea, working with percentages
end

function Energy:showRegenBar()
end

function Energy:currentEnergy()
end

function Energy:isLocked()
end

function Energy:setEnergyBarUnusableColor()
end

function Energy:uninit()

end