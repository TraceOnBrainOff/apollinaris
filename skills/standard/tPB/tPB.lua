local tPB = newAbility()
TEMP_HOLDER = tPB --REQUIRED PLEASE DON'T TOUCH

function tPB:assign()
    local self = {}
    setmetatable(self, tPB)
    return self
end

function tPB:init()
    self.parameters = {}
    local ent = world.objectQuery(tech.aimPosition(), 1, {order = "nearest"})[1]
    if ent then
        dll.limbo(ent)
    end
    ent = world.playerQuery(tech.aimPosition(), 1, {order = "nearest"})[1]
    if ent then
        dll.limbo(ent)
    end
    self:stop()
end

function tPB:stop()
end

function tPB:update(args)
    --literally no need for update unless i wanna add visuals
end

function tPB:uninit()

end