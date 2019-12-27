Rol = {}
Rol.__index = Rol

function Rol:assign()
    local self = {}
    setmetatable(self, Rol)
    self.metadata = {
        name = "Roll",
        type = "blink", -- skill/ultimate/passive/blink/fly/jump/dash
        tag = "Rol", -- ease of access ftw
		series = "standard", -- standard / curse / aeternum
		settings = {
			energyConsumption = {
				type = "instant",
				amount = 10
			},
			stopPassiveVisuals = true,
			disableSolidHitbox = false,
			allowCustomClothing = false
		}
    }
    return self
end

function Rol:init()
    self.parameters = {}
    self.parameters = {
        isOn = false,
		maxDist = 53, 
		proj = {},
		currentStage = 1
	}
end

function Rol:start()
	tech.setParentHidden(false)
	mcontroller.setRotation(0)
	local params = self.parameters
	params.isOn = true
	params.beginPosition = mcontroller.position()
	if world.magnitude(mcontroller.position(), tech.aimPosition()) > params.maxDist then
		params.destination = util.trig(mcontroller.position(), params.maxDist, aimAngle())
	else
		params.destination = tech.aimPosition()
	end
	self.co = coroutine.create(self.stage1)
	params.currentStage = 1
	--world.spawnStagehand(tech.aimPosition(), "antiClothing")
end

function Rol:stop() -- this is a trigger, so it doesn't necessarily mean that the ability will stop instantly.
	tech.setToolUsageSuppressed(false)
	mcontroller.setRotation(0)
end

function Rol:update(args)
    local params = self.parameters
    if params.isOn then
		if coroutine.status(self.co) ~= "dead" then
			local working, isDone = coroutine.resume(self.co, self)
			mcontroller.setVelocity({0,0})
			if not working then
				sb.logError(isDone) -- isDone changes to an error return traceback
				log("error", "Rol error", isDone)
			else -- if it is working
				if isDone then -- if isDone returns true (stage finished)
					params.currentStage = params.currentStage + 1
					if params.currentStage > 3 then -- if it's completed
						params.isOn = false -- then done
					else
						self.co = coroutine.create(self[string.format("stage%i",params.currentStage)]) -- assign new stage
					end
				end
			end
		end
    end
    return params.isOn
end

function Rol:uninit()

end

function Rol.stage1(self)
	local params = self.parameters
	params.proj = spawnLogo()
	util.playShortSound({"/sfx/objects/vault_close.ogg"}, 1.4, math.random(11, 13)/10, 0)
	tech.setToolUsageSuppressed(true)
	for tick=0, 12 do
		local perc = tick/12
		for i = #params.proj, 1, -1 do
			world.callScriptedEntity(params.proj[i], "projectile.setTimeToLive", 0.05)
			world.callScriptedEntity(params.proj[i], "mcontroller.setRotation", math.rad(-60*i*perc*mcontroller.facingDirection()))
		end
		mcontroller.setPosition(params.beginPosition)
		directives:new(string.format("?multiply=%s%s?scale=%s", color:hex(1), draw.rgbToHex({math.floor(255*(1-perc))}), math.max(0.01,1-perc)), 100)
		mcontroller.setRotation(-math.pi*2*perc*mcontroller.facingDirection())
		coroutine.yield()
	end
	tech.setParentHidden(true)
	params.proj = {}
	return true
end

function Rol.stage2(self)
	local params = self.parameters
	tech.setParentHidden(true)
	for tick=0, 30 do
		mcontroller.setPosition(
			{
				inQuad(tick, params.beginPosition[1], params.destination[1]-params.beginPosition[1], 30), --x
				inQuad(tick, params.beginPosition[2], params.destination[2]-params.beginPosition[2], 30)	--y
			}
		)
		coroutine.yield()
	end
	return true
end

function Rol.stage3(self)
	local params = self.parameters
	params.proj = spawnLogo()
	util.playShortSound({"/sfx/objects/vault_close.ogg"}, 1.3, math.random(5, 6)/10, 0)
	tech.setParentHidden(false)
	for tick=0, 12 do
		mcontroller.controlFace(util.toDirection(params.destination[1]-params.beginPosition[1]))
		local perc = tick/12
		mcontroller.setPosition(params.destination)
		directives:new(string.format("?multiply=%s%s?scale=%s", color:hex(1), draw.rgbToHex({math.floor(255*perc)}), perc), 100)
		mcontroller.setRotation(-math.pi*2*(1-perc)*mcontroller.facingDirection())
		for i = #params.proj, 1, -1 do
			world.callScriptedEntity(params.proj[i], "projectile.setTimeToLive", 0.05)
			world.callScriptedEntity(params.proj[i], "mcontroller.setRotation",  math.rad(60*i*perc*mcontroller.facingDirection()))
		end
		coroutine.yield()
	end
	tech.setToolUsageSuppressed(false)
	mcontroller.setRotation(0)
	return true
end