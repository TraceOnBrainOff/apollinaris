local Rol = newAbility()
TEMP_HOLDER = Rol --REQUIRED PLEASE DON'T TOUCH

function Rol:assign()
    local self = {}
    setmetatable(self, Rol)
    return self
end

function Rol:init()
    self.parameters = {
		maxDist = 53, 
		proj = {},
		currentStage = 1
	}
	tech.setParentHidden(false)
	mcontroller.setRotation(0)
	local params = self.parameters
	params.beginPosition = mcontroller.position()
	if world.magnitude(mcontroller.position(), tech.aimPosition()) > params.maxDist then
		params.destination = util.trig(mcontroller.position(), params.maxDist, aimAngle())
	else
		params.destination = tech.aimPosition()
	end

	self:precompileProjectiles()

	self.coroutines = {self.stage1, self.stage2, self.stage3}
	self.coroutine = coroutine.create(self.coroutines[1])
	--sb.logInfo(util.tableToString(self.chain))
end

function Rol:precompileProjectiles()
	local projectiles = {
		ParticleSpawner:new(), --inner_hex
		ParticleSpawner:new(), --outer_triangle
		ParticleSpawner:new() --outer_hex
	}
	for tick=1, self.metadata.settings.projectileStagesDuration do
		local perc = easing[self.metadata.settings.easing](tick, 0, 1, self.metadata.settings.projectileStagesDuration)
		for i, projectile in ipairs(projectiles) do
			local shape_params = self.metadata.settings.shape_params[i]
			local line_overrides = self.metadata.settings.lineConfigOverride
			for j=1, 2 do --adding the shapes and inverted shapes
				util.each(
					ParticleSpawner.regularPolygon(
						shape_params.sides, 
						shape_params.size, 
						(j-1)*(math.pi)+(math.pi/6)*perc*i*(i%2==0 and 1 or -1), 
						2, 
						color:rgb(1+(i-1)*2),
						line_overrides
					), 
					function(k,v) 
						projectile:addParticle(v, tick/60, false) 
					end
				)
			end
		end
	end
	self.projectiles = projectiles
end

function Rol:spawnProjectiles()
	util.each(self.projectiles, function(k,v) v:spawnProjectile(mcontroller.position(), {0,0}) end)
end

function Rol:coroutineCallback(index)
	if index > #self.coroutines then
		self:stop()
		return
	end
	self.coroutine = coroutine.create(self.coroutines[index])
end

function Rol:stop() -- this is a trigger, so it doesn't necessarily mean that the ability will stop instantly.
	mcontroller.setRotation(0)
end

function Rol:update(args)
	if coroutine.status(self.coroutine) ~= "dead" then
		coroutine.update(self.coroutine, self, args)
		mcontroller.setVelocity({0,0})
		mcontroller.controlFace(util.toDirection(self.parameters.destination[1]-self.parameters.beginPosition[1]))
	end
end

function Rol:uninit()
end

function Rol.stage1(self)
	self:spawnProjectiles()
	util.playShortSound({"/sfx/objects/vault_close.ogg"}, 1.4, math.random(11, 13)/10, 0)
	for tick=0, self.metadata.settings.projectileStagesDuration do
		local perc = easing[self.metadata.settings.easing](tick, 0, 1, self.metadata.settings.projectileStagesDuration)
		mcontroller.setPosition(self.parameters.beginPosition)
		directives:new(string.format("?multiply=%s%s?scale=%s", color:hex(1), draw.rgbToHex({math.floor(255*(1-perc))}), math.max(0.01,1-perc)), 100)
		mcontroller.setRotation(-math.pi*2*perc*mcontroller.facingDirection())
		util.each(self.projectiles, function(k,v) v:keepProjectileAlive() end)
		self, args = coroutine.yield()
	end
	tech.setParentHidden(true)
	self:coroutineCallback(2)
	return
end

function Rol.stage2(self)
	tech.setParentHidden(true)
	for tick=0, 30 do
		mcontroller.setPosition(
			{
				easing.inQuad(tick, self.parameters.beginPosition[1], self.parameters.destination[1]-self.parameters.beginPosition[1], 30), --x
				easing.inQuad(tick, self.parameters.beginPosition[2], self.parameters.destination[2]-self.parameters.beginPosition[2], 30)	--y
			}
		)
		self, args = coroutine.yield()
	end
	self:coroutineCallback(3)
	return
end

function Rol.stage3(self)
	self:spawnProjectiles()
	util.playShortSound({"/sfx/objects/vault_close.ogg"}, 1.3, math.random(5, 6)/10, 0)
	tech.setParentHidden(false)
	for tick=0, self.metadata.settings.projectileStagesDuration do
		local perc = easing[self.metadata.settings.easing](tick, 0, 1, self.metadata.settings.projectileStagesDuration)
		mcontroller.setPosition(self.parameters.destination)
		directives:new(string.format("?multiply=%s%s?scale=%s", color:hex(1), draw.rgbToHex({math.floor(255*perc)}), perc), 100)
		mcontroller.setRotation(-math.pi*2*(1-perc)*mcontroller.facingDirection())
		util.each(self.projectiles, function(k,v) v:keepProjectileAlive() end)
		self, args = coroutine.yield()
	end
	self:coroutineCallback(4)
	return
end