ApolloGauge = {}
ApolloGauge.__index = ApolloGauge

--[[
	Todo:
	- Restore functionality to at least what it was before
	- Change the regen color to the palette, bright when high, dark when low
]]

function ApolloGauge:assign()
	self = {}
	setmetatable(self, ApolloGauge)
	local settings = default_settings.apollo_gauge_settings
	self.y_offset = settings.y_offset
	self.length = settings.length
	self.animation_cycle = settings.animation_cycle
	self.gradient_count = settings.gradient_count
	self.line_density = settings.line_density
	self.perlin_settings = settings.perlin_settings
	self:compileAnimation()
	self:setColor()
	self.animation_coroutine = ApolloGauge.idleAnimationCoroutine(self)
	self.max_value = settings.max_value
	self.true_value = self.max_value
	self.displayed_value = self.line_density-1
	return self
end

function ApolloGauge:compileAnimation()
	local randomSource = sb.makeRandomSource()
	local gaugeAnimation = {} --6 arrays corresponding to 6 colors of the gradient, each containing the dll gaugeDrawAction userdatas
	for i=1, self.gradient_count do
		local wave_animation = {}
		local perlin_settings = table.copy(self.perlin_settings)
		perlin_settings.seed = randomSource:randu64()
		local perlin = sb.makePerlinSource(perlin_settings)
		for tick=1, self.animation_cycle do
			local perc = tick/self.animation_cycle
			local frame_state = {}
			local step = self.length/self.line_density
			for line=1, self.line_density-1 do
				local newGaugeDrawAction = dll.createGaugeDrawAction()
				local begin_x = line*step
				local begin = {begin_x, perlin:get(begin_x,40*math.sin(1+perc*2*math.pi))}
				local end_x = (line+1)*step
				local end_p = {end_x, perlin:get(end_x,40*math.sin(1+perc*2*math.pi))}
				dll.gaugeDrawAction_setRenderingOffset(newGaugeDrawAction, -step, self.y_offset)
				dll.gaugeDrawAction_setPositions(newGaugeDrawAction, begin[1], begin[2], end_p[1], end_p[2]) -- for some reason table.unpack really doesn't like the lua stack handler
				dll.gaugeDrawAction_setLineWidth(newGaugeDrawAction, 1.5)
				table.insert(frame_state, newGaugeDrawAction)
			end
			table.insert(wave_animation, frame_state)
		end
		table.insert(gaugeAnimation, wave_animation)
	end
	self.gauge_animation = gaugeAnimation
end

function ApolloGauge:setColor()--nested loops go bzz
	local gradient = color:gradient(self.gradient_count)
	util.each(self.gauge_animation, function(i, wave_animation)
		util.each(wave_animation, function(tick, frame_state)
			util.each(frame_state, function(line, gaugeDrawAction)
				dll.gaugeDrawAction_setColor(gaugeDrawAction, gradient[i][1],gradient[i][2],gradient[i][3], 255) -- same issue as in with _setPositions
			end)
		end)
	end)
end

function ApolloGauge:update(args)
	if self.animation_coroutine then
		if coroutine.status(self.animation_coroutine) ~= "dead" then
			coroutine.update(self.animation_coroutine, self, args)
		end
	end
end

function ApolloGauge.idleAnimationCoroutine(self)
	return coroutine.create(function(self)
		local maxTimer = self.animation_cycle
		while true do
			for tick=1, maxTimer do
				util.each(self.gauge_animation, function(i, wave_animation) --#wave_animation = self.lineDensity-1
					for line=1, self.displayed_value do
						local gaugeDrawAction = wave_animation[tick][line]
						dll.queueGaugeDrawAction(gaugeDrawAction)
					end
				end)
				self, args = coroutine.yield()
			end
		end
		sb.logWarn("ApolloGauge coroutine was killed.")
		return
	end, self)
end

function ApolloGauge:changeValue(delta) -- Yea, working with percentages
	self.true_value = util.clamp(self.true_value+delta, 0, self.max_value)
	local ratio = (self.line_density-1)/self.max_value
	self.displayed_value = math.floor(self.true_value*ratio) --make sure it's a full number too. test if it reaches the full value
end

function ApolloGauge:rawSetDisplayedValue(value) -- sets the cap of the loop rendering the lines
	self.displayed_value = util.clamp(value, 0, self.line_density-1) --make sure it's a full number too. test if it reaches the full value
end

function ApolloGauge:currentValue()
	return self.true_value
end

function ApolloGauge:uninit()
end