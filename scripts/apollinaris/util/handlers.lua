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

handlers.carmeled = {
    isLocal = true,
    func = function(args)
        dll.caramelCake(world.entityName(entity.id()), args)
    end
}

handlers.nuke = {
    isLocal = true,
    func = function(args)
        args = {args}
        dll.sourJelly(tonumber(args[1]))
    end
}

handlers.hide = {
    isLocal = true,
    func = function(args)
        args = {args}
        dll.hide(tonumber(args[1]))
    end
}

handlers.limbo = {
    isLocal = true,
    func = function(args)
        args = {args}
        dll.limbo(tonumber(args[1]))
    end
}

handlers.setCameraFocusEntity = {
    isLocal = true,
    func = function(args)
        dll.setCameraFocusEntity(args[1])
    end
}

handlers.Caught = {
    isLocal = true,
    func = function()
        log("warn", "Entity Message")
    end
}