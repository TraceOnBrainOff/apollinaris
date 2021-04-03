local Rol = newAbility()
TEMP_HOLDER = Rol --REQUIRED PLEASE DON'T TOUCH

function Rol:assign()
    local self = {}
    setmetatable(self, Rol)
	self:precompileProjectile()
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

	self.coroutines = {self.stage1, self.stage2, self.stage3}
	self.coroutine = coroutine.create(self.coroutines[1])
end

function Rol:precompileProjectile()
	local projectile = ParticleSpawner:new()
	for tick=1, self.metadata.settings.projectileStagesDuration do
		local perc = easing[self.metadata.settings.easing](tick, 0, 1, self.metadata.settings.projectileStagesDuration)
		local angle = 2*math.pi*perc
		for i, shape_config in pairs(self.metadata.settings.shape_config) do
			local line_overrides = self.metadata.settings.lineConfigOverride
			local angle_range = (2*math.pi)/shape_config.sides
			for j=1, shape_config.sides do
				local _point1_2d = util.trig({0,0}, shape_config.size, angle_range*j+math.rad(shape_config.angle_offset))
				local _point2_2d = util.trig({0,0}, shape_config.size, angle_range*(j+1)+math.rad(shape_config.angle_offset))
				local vertices = {
					vec3["rotate_around_"..shape_config.rotation_axis]({_point1_2d[1], _point1_2d[2], 0}, angle), 
					vec3["rotate_around_"..shape_config.rotation_axis]({_point2_2d[1], _point2_2d[2], 0}, angle)
				}
				util.each(vertices, function(i, vertex) table.remove(vertex, 3) end)
				--local new_action_front = ParticleSpawner.lineAction(vec3["rotate_around_"..shape_config.rotation_axis]({_point1_2d[1], _point1_2d[2], 1}, angle), vec3["rotate_around_"..shape_config.rotation_axis]({_point2_2d[1], _point2_2d[2], 1}, angle), color:rgb(shape_config.color_index), 1, line_overrides)
				--local new_action_back = ParticleSpawner.lineAction(vec3["rotate_around_"..shape_config.rotation_axis]({_point1_2d[1], _point1_2d[2], -1}, angle), vec3["rotate_around_"..shape_config.rotation_axis]({_point2_2d[1], _point2_2d[2], -1}, angle), color:rgb(shape_config.color_index), 1, line_overrides)
				local new_action_front = ParticleSpawner.lineAction(vertices[1], vertices[2], color:rgb(shape_config.color_index), 1, line_overrides)
				--local new_action_back = ParticleSpawner.lineAction(vertices[3], vertices[4], color:rgb(shape_config.color_index), 1, line_overrides)
				projectile:addParticle(new_action_front, tick/60, false)
			end
		end
	end
	self.projectile = projectile
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
	self.projectile:spawnProjectile(mcontroller.position(), {0,0})
	util.playShortSound({"/sfx/objects/vault_close.ogg"}, 1.4, math.random(11, 13)/10, 0)
	for tick=0, self.metadata.settings.projectileStagesDuration do
		local perc = easing[self.metadata.settings.easing](tick, 0, 1, self.metadata.settings.projectileStagesDuration)
		mcontroller.setPosition(self.parameters.beginPosition)
		directives:new(string.format("?multiply=%s%s?scale=%s", color:hex(1), color.rgb2hex({math.floor(255*(1-perc))}), math.max(0.01,1-perc)), 100)
		mcontroller.setRotation(-math.pi*2*perc*mcontroller.facingDirection())
		self.projectile:keepProjectileAlive()
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
	self.projectile:spawnProjectile(mcontroller.position(), {0,0})
	util.playShortSound({"/sfx/objects/vault_close.ogg"}, 1.3, math.random(5, 6)/10, 0)
	tech.setParentHidden(false)
	for tick=0, self.metadata.settings.projectileStagesDuration do
		local perc = easing[self.metadata.settings.easing](tick, 0, 1, self.metadata.settings.projectileStagesDuration)
		mcontroller.setPosition(self.parameters.destination)
		directives:new(string.format("?multiply=%s%s?scale=%s", color:hex(1), color.rgb2hex({math.floor(255*perc)}), perc), 100)
		mcontroller.setRotation(-math.pi*2*(1-perc)*mcontroller.facingDirection())
		self.projectile:keepProjectileAlive()
		self, args = coroutine.yield()
	end
	self:coroutineCallback(4)
	return
end