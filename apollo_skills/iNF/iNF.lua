local iNF = newAbility()
TEMP_HOLDER = iNF --REQUIRED PLEASE DON'T TOUCH

function iNF:assign()
	local self = {}
    setmetatable(self, iNF)
    return self
end

function iNF:init()
    self.parameters = {
		storm = {
			currXPos = 0,
			inaccuracy = 3,
			movespeed = 0.1,
			range = 50,
			timer = {0,5},
			cloudProj = {
				id = nil,
				yDist = 25
			},
			lightningCooldown = {0,0.1}
		}
	}
	self.coroutines = {self.stage1, self.stage2}
	self.coroutine = coroutine.create(self.coroutines[1])
	self.spawnOffset = vec2.add(mcontroller.position(), self.metadata.settings.spawnOffset)
	self.cloud = {}
end

function iNF:coroutineCallback(index)
	if index > #self.coroutines then
		self:stop()
		return
	end
	self.coroutine = coroutine.create(self.coroutines[index])
end


function iNF:stop()
	tech.setParentState()
	self.cloud = nil
	self.projectiles = nil
	if self.lightning then
		self.lightning:kill()
		self.lightning = nil
	end
end

function iNF:update(args)
	if self.coroutine then
		coroutine.update(self.coroutine, self, args)
	end
end

function iNF:uninit()

end

function iNF:precompileProjectiles()
	local r = self.metadata.settings.projectile.radius --this is also used to offset all the outer right/left vertices' x position
	local R = r*2 --outer hexagon, only used for the initial hexagon
	local H = (math.sqrt(3)/2)*R --necessary to get all initial 12 outer vertices
	local smaller_hexagon_offset = math.pi/6 --1/12 of a full rotation
	local vertices = {}
	table.insert(vertices, {0,0}) --origin point
	for i=1,6 do table.insert(vertices, util.trig({0,0}, r, i*math.pi/3)) end --inner hexagon
	for i=1,6 do table.insert(vertices, util.trig({0,0}, R, i*math.pi/3)) end --outer hexagon
	for i=1,6 do table.insert(vertices, util.trig({0,0}, H, i*math.pi/3+smaller_hexagon_offset)) end --outer hexagon with R's height used as the radius offset by 30 degrees
	if self.metadata.settings.projectile.horizontal_size>0 then --horizontal extension
		local left_side = { --these are the 5 vertices on the left of the outer hexagon that get the offsets added onto them
			util.trig({0,0}, R, math.pi/2+math.pi/6),
			util.trig({0,0}, H, math.pi/2+math.pi/3),
			util.trig({0,0}, R, math.pi),
			util.trig({0,0}, H, math.pi+math.pi/6),
			util.trig({0,0}, R, math.pi+math.pi/3)
		}
		local right_side = {-- same for the right side
			util.trig({0,0}, R, math.pi/2-math.pi/6),
			util.trig({0,0}, H, math.pi/2-math.pi/3),
			util.trig({0,0}, R, 0),
			util.trig({0,0}, H, 0-math.pi/6),
			util.trig({0,0}, R, 0-math.pi/3)
		}
		for a=1, self.metadata.settings.projectile.horizontal_size do
			local ls_cp = copy(left_side)
			util.each(ls_cp, function(i,v) table.insert(vertices, {v[1]-a*r, v[2]}) end)
			local rs_cp = copy(right_side)
			util.each(rs_cp, function(i,v) table.insert(vertices, {v[1]+a*r, v[2]}) end)
		end
	end
	local projectiles = {}
	local gradient = color:gradient(self.metadata.settings.projectile.horizontal_size) -- the 19 is the initial origin point + 3 hexagons. 10 is the amount of vertices per side extension
	util.each(vertices, function(i, vector) --for every origin point, make a high resolution poly
		local projectile = ParticleSpawner:new()
		local index = math.ceil((i-19)/10)
		util.each(ParticleSpawner.regularPolygon(self.metadata.settings.projectile.resolution, r, 0, 1, (i<=19 and color:rgb(1) or gradient[index]), self.metadata.settings.projectile.overrides), function(j, action)
			projectile:addParticle(action, 0.3, true)
		end)
		local fog_copy = copy(self.metadata.settings.fogParticleSpecification)
		fog_copy.position = {0,0}
		projectile:addParticle(fog_copy, math.random(10,20)/10, true)
		projectile.vector = vector
		table.insert(projectiles, copy(projectile))
	end)
	self.projectiles = projectiles
end

function iNF:callScriptedEntity(...)
	local args = {...}
	util.each(self.cloud, function(i, projectile) projectile:callScriptedEntity(table.unpack(args)) end)
end

function iNF:keepProjectilesAlive()
	util.each(self.cloud, function(i, projectile) projectile:keepProjectileAlive() end)
end

function iNF:stage1(args)
	tech.setParentState("stand")
	self.frozen_position = mcontroller.position()
	initialPosition = copy(self.frozen_position)
	local arm_frames = {"fall.1", "fall.2", "fall.3", "fall.4"}
	self:precompileProjectiles()
	self.lightning = MonsterLightning:new()
	self.lightning:spawnMonster()
	local stage_duration = #self.projectiles
	for tick=1, stage_duration do-- freeze X position, levitate upwards if not already in the air, do lightning passive aura, lift arms up, make clouds projectiles appear
		self.frozen_position[1] = easing[self.metadata.settings.lift_easing](tick, initialPosition[1], self.metadata.settings.lift_displacement[1], stage_duration)
		self.frozen_position[2] = easing[self.metadata.settings.lift_easing](tick, initialPosition[2], self.metadata.settings.lift_displacement[2], stage_duration)
		local projectile = self.projectiles[tick]
		util.each(self.cloud, function(i, v) v:callScriptedEntity("mcontroller.setPosition", vec2.add(self.spawnOffset, v.vector)) end)
		projectile:spawnProjectile(vec2.add(self.spawnOffset, projectile.vector), {0,0})
		table.insert(self.cloud, projectile)
		self:keepProjectilesAlive()
		self.lightning:callScriptedEntity("mcontroller.setPosition", mcontroller.position())
		mcontroller.setPosition(self.frozen_position)
		mcontroller.setVelocity({0,0})
		mcontroller.controlFace(util.toDirection(tech.aimPosition()[1]-self.frozen_position[1]))
		self, args = coroutine.yield()
	end
	local counter = 0
	local currentArmFrame = 1
	local port = portrait:auto(entity.id())
    local bodyPersonality = portrait:getBodyPersonality(port)
	while true do
		util.each(self.cloud, function(i, projectile) projectile:keepProjectileAlive() end)
		mcontroller.setPosition(self.frozen_position)
		mcontroller.setVelocity({0,0})
		mcontroller.controlFace(util.toDirection(tech.aimPosition()[1]-self.frozen_position[1]))
		if counter == self.metadata.settings.nextArmFrame then
			currentArmFrame = currentArmFrame + 1
			if currentArmFrame > #arm_frames then
				self:coroutineCallback(2)
				return
			end
			dll.setPersonality(bodyPersonality, arm_frames[currentArmFrame], -1, 0, 0, 0)
			counter = 0
		end
		counter = counter +1
		coroutine.yield()
	end
end

function iNF:stage2(args)-- fire x amount of bolts at the ground and stop
	for i=1, self.metadata.settings.stage2Duration do
		mcontroller.controlFace(util.toDirection(tech.aimPosition()[1]-self.frozen_position[1]))
		mcontroller.setVelocity({0,0})
		mcontroller.setPosition(self.frozen_position)
		self:keepProjectilesAlive()
		self.lightning:callScriptedEntity("mcontroller.setPosition", mcontroller.position())
		self, args = coroutine.yield()
	end
	self:coroutineCallback(3)
	return
end