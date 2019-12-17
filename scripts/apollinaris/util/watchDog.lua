WatchDog = {}
WatchDog.__index = WatchDog

function WatchDog:assign()
    local self = {}
    setmetatable(self, WatchDog)
    self.customClothingLimit = 1000
    return self
end

function WatchDog:checkTamperedClothing() -- Todo. Checks if the player has clothing with effects mismatching the vanilla clothing's table. Doing this because edited clothing with increased energy regen will mess up the balancing.

end

function WatchDog:checkCustomClothing()
    local fashionable = true -- \o/
    local slots = {"headCosmetic","head","chestCosmetic","chest","legsCosmetic","legs","backCosmetic","back"}
    for i, slot in ipairs(slots) do
        local cloth = player.equippedItem(slot)
        if cloth then
            if cloth.parameters.directives then
                if cloth.parameters.directives:len() > self.customClothingLimit then
                    fashionable = false
                    break -- end the loop if you found a piece that's bad
                end
            end
        end
    end
    return fashionable
end