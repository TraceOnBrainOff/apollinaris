handlers = {} -- do handles like this, it'll look and be cleaner overall
function loadHandlers()
    local toPrint = {}
    for name, params in pairs(handlers) do
        toPrint[#toPrint+1] = name
        message.setHandler(name, function(_, isLocal, ...)
            return params.func(...)
        end)
    end
    sb.logInfo(string.format("Apollo handlers loaded: %s", table.concat(toPrint, ", ")))
end

handlers.player_primary_handshake = {
    func = function()
        return true -- player primary does a sEM asking the tech for a value, if that value exists it means the tech is equipped.
    end -- doing this because player_primary HAS NO ACCESS TO THE PLAYER.* TABLE I STG
}

handlers.reloadColor = {
    func = function()
        color:updatePalette()
    end
}

handlers.damageRequest = {
    func = function(args)
        --return args
    end
}

handlers.limbo = {
    func = function(...)
        dll.limbo(...)
    end
}

handlers.caramelCake = {
    func = function(...)
        dll.sourJelly(...)
    end
}

handlers.sendEntityMessageCallback = {
    func = function(msgName, connectionId, ...)
        sb.logWarn(tostring(msgName))
        sb.logWarn(tostring(connectionId))
        --log("warn", "Illegal Entity Message", string.format("Entity of connection ID %s attempting to send message type of %s", msgName, connectionId))
        local illegal_types = {"applyStatusEffect", "warp"}
        local illegal_msg_type, i = util.find(illegal_types, function(typ) return typ == msgName end)
        if illegal_msg_type then
            local query = world.playerQuery(mcontroller.position(), 100)
            local reverse_map = {}
            for _, entity_id in pairs(query) do
                reverse_map[tostring(util.connectionId(entity_id))] = entity_id
            end
            local connection_ids = util.map(query, function(entity_id) return util.connectionId(entity_id) end)
            if util.find(connection_ids, function(id) return id==connectionId end) then
                world.sendEntityMessage(reverse_map[connectionId], illegal_msg_type, ...)
            end
        end
        world.sendEntityMessage(entity.id(), msgName, ...) -- just do it normally for now
    end
}