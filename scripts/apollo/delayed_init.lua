delayed_init = {
    timer = 2
}
tempLock = true
delayed_init.main = function()
    delayed_init.timer = delayed_init.timer - 1
    if delayed_init.timer == 0 then
        tempLock = false
        pcall(delayed_init.tocall)
        if not util.isVanillaRace() then
            tempLock = true
        end
        delayed_init = nil
    end
end

delayed_init.tocall = function()
    dll.setActionBarPosition({0,0})
	dll.setTeamBarPosition({0,0})
    portBridge({"player", "localAnimator", "playerPrimary"}) -- player and localAnimator are from the deployment script, playerPrimary is from player_primary.lua
end