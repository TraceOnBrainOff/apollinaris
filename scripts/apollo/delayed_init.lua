intlize = {
    timer = 2
}
tempLock = true
intlize.main = function()
    intlize.timer = intlize.timer - 1
    if intlize.timer == 0 then
        tempLock = false
        pcall(intlize.tocall)
        if not util.isVanillaRace() then
            tempLock = true
        end
        intlize = nil
    end
end

intlize.tocall = function()
    dll.setActionBarPosition({0,0})
	dll.setTeamBarPosition({0,0})
    energy:setEnergyBarUnusableColor()
    portBridge({"player", "localAnimator", "playerPrimary"}) -- player and localAnimator are from the deployment script, playerPrimary is from player_primary.lua
end