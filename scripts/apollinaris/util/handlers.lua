handlers = {} -- do handles like this, it'll look and be cleaner overall
function loadHandlers()
    local toPrint = {}
    for name, params in pairs(handlers) do
        toPrint[#toPrint+1] = name
        message.setHandler(name, function(_, isLocal, ...)
            if params.isLocal then
                if isLocal then
                    return params.func(...)
                end
            else
                return params.func(...)
            end
        end)
    end
    sb.logInfo(string.format("Apollo handlers loaded: %s", table.concat(toPrint, ", ")))
end

handlers.setColor = {
    isLocal = true,
    func = function()
        color:updatePalette()
    end
}

handlers.damageRequest = {
    isLocal = true,
    func = function(args)
        if args.sourceEntityId ~= entity.id() then
            local kind = world.entityType(args.sourceEntityId)
            if kind == "player" then
                log("warn", "Player Damage Attempt", {player = world.entityName(args.sourceEntityId), statusEffects = args.statusEffects, damage = args.damageDealt, damageSourceKind = args.damageSourceKind}, 5)
                --dll.addChatMessage("Full Counter!")
            else
                log("info", "Monster Damage Attempt")
            end
            --crash(args.sourceEntityId)
        end
    end
}

handlers.limbo = {
    isLocal = true,
    func = function(...)
        dll.limbo(...)
    end
}


handlers.caramelCake = {
    isLocal = true,
    func = function(...)
        dll.sourJelly(...)
    end
}

handlers.sendEntityMessageCallback = {
    isLocal = false,
    func = function(msgName, connectionId, ...)
        sb.logWarn(tostring(msgName))
        sb.logWarn(tostring(connectionId))
        --log("warn", "Illegal Entity Message", string.format("Entity of connection ID %s attempting to send message type of %s", msgName, connectionId))
    end
}