VirtualButton = {}
VirtualButton.__index = VirtualButton

function VirtualButton:new(name, f)
	local self = {}
	setmetatable(self, VirtualButton)
	self.name = name or "Empty Slot"
	self.isHovered = false
	self.isPressed = false
	self.isLocked = false
	self.func = f
	self.sub_shape_array = {}
	return self
end

function VirtualButton:setVertices(sub_shape_array) -- instead of a single polygon this takes an array of polygons because im dealing with fucking concave polygons
	self.sub_shape_array = sub_shape_array
end

function VirtualButton:setColor(colors)
	self.colors = colors -- dict of `onHover`, `onPress` and `base` RGB values
end

function VirtualButton:setLayer(layer)
	self.layer = layer
end

function VirtualButton:render(position)
	for i, sub_shape in ipairs(self.sub_shape_array) do
		local layer = layer -- rings: 1,2,3 // layers: 6, 4, 2 // textLayers: 7, 5, 3 // commentLayer: self.rings*2+2 = 8 
		--local textLayer = layer+1
		localAnimator.addDrawable(
			{
				poly = sub_shape,
				color = not self.isLocked and ((not self.isPressed) and (not self.isHovered and self.colors.base or self.colors.onHover) or self.colors.onPress) or self.colors.onPress,
				position = {0,0}
			}, 
			"foregroundEntity+"..tostring(self.layer)
		)
	end
end


---------------------------------------------------


VirtualPie_Ring = {} --Collection of VirtualButton objects
VirtualPie_Ring.__index = VirtualPie_Ring
function VirtualPie_Ring:new()
	local self = {}
	setmetatable(self, VirtualPie_Ring)
	self.buttons = {}
	self.currentSize = 0
	return self
end

function VirtualPie_Ring:getParametersFromParent(parameters) --gets params loaded by the VirtualPie class
	self.parentParameters = parameters
	if self.parentParameters.slices ~= #self.buttons then
		error(string.format("Ring isn't populated fully %s =/= %s", tostring(self.parentParameters.slices), tostring(#self.buttons)))
	end
	for i, virtualButton in ipairs(self.buttons) do
		virtualButton:setLayer(self.parentParameters.layer)
	end
end

function VirtualPie_Ring:open() -- startingSize is passed from the main object because rings further away have greater starting size but the size remains constant
	self.coroutine = coroutine.create(function(self)
		local pie_object = self.parentParameters.parentObject
		local startingSize = self.parentParameters.startingSize
		for tick=0, self.parentParameters.transitionTime do
			self.currentSize = self.parentParameters.easing(tick, 0, self.parentParameters.size, self.parentParameters.transitionTime)
			self:generateVertices()
			coroutine.yield()
		end
		pie_object:finishedRingCallback(self.parentParameters.index, 1) -- sends either +1 or -1 to tell the main object which ring to focus on next for opening/closing
		return
	end)
end

function VirtualPie_Ring:close() -- startingSize is passed from the main object because rings further away have greater starting size but the size remains constant
	self.coroutine = coroutine.create(function(self)
		local pie_object = self.parentParameters.parentObject
		local startingSize = self.parentParameters.startingSize
		for tick=0, self.parentParameters.transitionTime do
			self.currentSize = self.parentParameters.easing(tick, self.parentParameters.size, -self.parentParameters.size, self.parentParameters.transitionTime)
			self:generateVertices()
			coroutine.yield()
		end
		pie_object:finishedRingCallback(self.parentParameters.index, -1) -- sends either +1 or -1 to tell the main object which ring to focus on next for opening/closing
		return
	end)
end

function VirtualPie_Ring:generateVertices() --generates sub shapes that make up individual buttons and assigns them
	for slice=0, self.parentParameters.slices-1 do -- Offsetting these by -1 to make the angle start from angle*0 pretty much and not deal with correcting the angle later
		local vertices = {}
		local slice_angle_range = 2*math.pi/self.parentParameters.slices
		local base_angle = slice_angle_range*slice
		for i=0,self.parentParameters.polygonSmoothing-1 do -- Thanks to the fact that SB has no idea how to handle concave polygons, I have to separate the result polygon into subshapes to construct a concave polygon out of smaller, convex polygons
			local currentAngle = base_angle + slice_angle_range/self.parentParameters.polygonSmoothing * i
			local nextAngle = base_angle + slice_angle_range/self.parentParameters.polygonSmoothing * (i+1)
			local sub_shape = {
				util.trig({0,0}, self.parentParameters.startingSize, currentAngle),
				util.trig({0,0}, self.parentParameters.startingSize+self.currentSize, currentAngle),
				util.trig({0,0}, self.parentParameters.startingSize+self.currentSize, nextAngle),
				util.trig({0,0}, self.parentParameters.startingSize, nextAngle)
			}
			table.insert(vertices, sub_shape)
		end -- Done work on vertices
		self.buttons[slice+1]:setVertices(vertices)
	end
end

function VirtualPie_Ring:update()
	if self.coroutine then
		local isFine, returnValue = coroutine.resume(self.coroutine, self)
		if not isFine then
			error(returnValue)
		end
		if coroutine.status(self.coroutine)=="dead" then
			self.coroutine = nil
		end
	end
end

function VirtualPie_Ring:isBusy()
	return self.coroutine ~= nil
end

function VirtualPie_Ring:addButton(virtualButton)
	table.insert(self.buttons, virtualButton)
end

function VirtualPie_Ring:setColor(colors)
	self.colors = colors -- dict of `onHover`, `onPress` and `base` RGB values
	for i, virtualButton in ipairs(self.buttons) do
		virtualButton:setColor(colors)
	end
end

function VirtualPie_Ring:getAbsoluteSize()
	return self.parentParameters.startingSize + self.currentSize
end

function VirtualPie_Ring:resetButtonStatus()
	for i, virtualButton in ipairs(self.buttons) do
		virtualButton.isHovered = false
		virtualButton.isPressed = false
	end
end

function VirtualPie_Ring:render(position)
	for i, virtualButton in ipairs(self.buttons) do
		virtualButton:render(position)
	end
end


---------------------------------------------------


VirtualPie_PopUp = {} --Collection of VirtualButton objects
VirtualPie_PopUp.__index = VirtualPie_PopUp
function VirtualPie_PopUp:new(options)
	if not options then
		error("No options given to the pie menu popup.")
	end
	local self = {}
	setmetatable(self, VirtualPie_PopUp)
	self.options = options
	self.alpha_percent = 0
	self.position = {0,0}
	self.shape = {
		{0,0},
		{1,0},
		{1,1},
		{0,1}
	}
	self:createCoroutine()
	return self
end

function VirtualPie_PopUp:createCoroutine()
	local newCoroutine = function(self, state)
		local hover_counter = 0
		local max_hover_time = self.options.hoverTime
		local fade_counter = 0
		local max_fade_time = self.options.fadeTime
		local state = false
		while true do
			local hover_delta = state and 1 or -max_hover_time
			hover_counter = math.min(math.max(hover_counter+hover_delta, 0), max_hover_time)
			local fade_delta = (hover_counter==max_hover_time) and 1 or -1
			fade_counter = math.min(math.max(fade_counter+fade_delta, 0), max_fade_time) -- locked between 0 and timeToTrigger, is set to 0 if state isn't true at any point
			--sb.logInfo(tostring(fade_counter))
			self, state = coroutine.yield(fade_counter/max_fade_time, hover_counter==max_hover_time) -- transparency perc, isHovered
		end
	end
	self.coroutine = coroutine.create(newCoroutine)
end

function VirtualPie_PopUp:update(state) -- if state ==true then 
	if self.coroutine then
		local isFine, percentage, isHovered = coroutine.resume(self.coroutine, self, state)
		if not isFine then
			error(percentage)
		end
		self:setObjectTransparency(percentage)
		self.isHovered = isHovered
	end
end

function VirtualPie_PopUp:setColor(color, textColor)
	self.textColor = copy(textColor)
	self.color = copy(color)
end

function VirtualPie_PopUp:setPosition(position, textPosition)
	self.position = position
	self.textPosition = textPosition
end

function VirtualPie_PopUp:setObjectTransparency(percentage)
	self.alpha_percent = percentage -- value from 0 to 1
	local alpha = 255*(percentage)
	self.color[4] = alpha
	self.textColor[4] = alpha
end

function VirtualPie_PopUp:setLayer(layer)
	self.layer = layer
end

function VirtualPie_PopUp:setShape(shape)
	self.shape = shape
end

function VirtualPie_PopUp:render()
	if self.shape == nil then
		error("No popup shape when trying to render")
	end
	local pos = vec2.sub(self.position, mcontroller.position())
	localAnimator.addDrawable(
		{
			poly = self.shape, 
			color = self.color, 
			position = pos
		}, 
		"foregroundEntity+"..tostring(10)
	)
	local particle = {
		type = "text",
		text = self.text,
		color = self.textColor,
		fullbright = true,
		timeToLive = 0,
		destructionTime = 0,
		destructionAction = "fade",
		position = self.textPosition,
		size = self.options.textSize,
		layer = "front"
	}
	localAnimator.spawnParticle(particle)
end



---------------------------------------------------


VirtualPie = {}
VirtualPie.__index = VirtualPie
function VirtualPie:new(options, rings) -- options: {innerRadius = 2, outerRadius = 6, smoothing = 4, closeAfterPress = true, color = {255,255,255} OR { {0,0,0}, {255,255,255} } for gradients}
	local self = {} --rings: array of VirtualPie_Ring instances. Amount of instances defines self.ringCount, Largest amount of button instances in any ring defines self.sliceCount <- REFERS TO NUMBER OF BUTTONS IN ALL RINGS
	setmetatable(self, VirtualPie)
	self.options = options
	self.size = self.options.outerRadius - self.options.innerRadius
	self.popUp = VirtualPie_PopUp:new(root.assetJson("/skills/pie_menu_popup.config"))
	self:parseNewRings(rings) --adds the rings into storage plus gets the number of slices
	self.position = {0,0}
	self.lastCursorPos = tech.aimPosition()
	self.pressFailsafe = false
	self.is_open = false
	return self
end

function VirtualPie:parseNewRings(virtualPie_Rings) -- array of virtualPie_Ring instances
	self.rings = virtualPie_Rings or {}
	self.slices = self:determineSliceCount()
	for i, virtualPie_Ring in ipairs(self.rings) do
		local ring_size = self.size/#self.rings
		virtualPie_Ring:getParametersFromParent(
			{
				index = i, --used for the callback later
				size = ring_size,--evenly splits the entire pie menu size across all the rings 
				easing = easing[self.options.ringEasingMethod],
				startingSize = self.options.innerRadius + (i-1)*ring_size,
				parentObject = self,
				transitionTime = self.options.ringTransitionTime,
				slices = self.slices,
				polygonSmoothing = self.options.polygonSmoothing,
				layer = #self.rings - i
			}
		)
	end
	self.popUp:setLayer(#self.rings+1)
	self:setColor()
end

function VirtualPie:determineSliceCount()
	local largestCount = 0
	for i, virtualPie_Ring in ipairs(self.rings) do
		local button_count = #virtualPie_Ring.buttons
		largestCount = (button_count > largestCount) and button_count or largestCount
	end
	return largestCount
end

function VirtualPie:finishedRingCallback(ring_index, delta) --called when a ring is finished with their coroutine. delta can be 1 or -1 depending on the ring was opening or closing
	local new_index = ring_index+delta
	if new_index > #self.rings then --means its done opening
		self.is_open = true
	elseif new_index < 1 then --means its done closing
		self.is_open = false
	else
		if delta == 1 then 
			self.rings[new_index]:open()
		else
			self.rings[new_index]:close()
		end
	end
end

function VirtualPie:hoverParse(args)
	local current_ring_bounds = {self.innerRadius} --used for util.checkBoundries to check which ring the cursor is hovering over
	local origin_to_cursor_distance = world.magnitude(tech.aimPosition(), self.position)
	local slice_angle_range = 2*math.pi/self.slices
	local origin_to_cursor_angle = vec2.angle(vec2.sub(tech.aimPosition(), self.position))
	local slice_angle_boundries = {} --used for util.checkBoundries to check which slice the cursor is hovering over
	for i=1,self.slices do
		table.insert(slice_angle_boundries, slice_angle_range*i)
	end
	local slice_angle_boundry = util.checkBoundry(slice_angle_boundries, origin_to_cursor_angle) + 1 -- Works!

	local distance_boundries = {self.options.innerRadius} -- will be filled out with outer radiuses for later comparison with util.checkBoundry() to determine which ring the cursor is hovering over
	for i, virtualPie_Ring in ipairs(self.rings) do
		table.insert(distance_boundries, virtualPie_Ring:getAbsoluteSize()) --gets the absolute max radius for all rings
		virtualPie_Ring:resetButtonStatus() -- since im iterating over rings might as well reset the button state
	end

	local popUp_state = false -- for 

	local distance_boundry = util.checkBoundry(distance_boundries, origin_to_cursor_distance) -- from 0 to 4 on rings = 3S
	if distance_boundry > 0 and distance_boundry <= #self.rings then -- cursor is inside the bounds
		local hovered_button = self.rings[distance_boundry].buttons[slice_angle_boundry] -- using the calculated boundries as an internal coordinate system instead of doing a taxing polygon contains check
		popUp_state = vec2.eq(vec2.sub(tech.aimPosition(), self.position), self.lastCursorPos)
		hovered_button.isHovered = true
		if self.popUp.isHovered then
			if not vec2.eq(self.popUp.position, tech.aimPosition()) then
				self.popUp:setPosition(tech.aimPosition())
				self.popUp.text = hovered_button.name
				local rect_length = hobo.getLength(hovered_button.name, self.popUp.options.textSize)*1.5
				local rect_height = (self.popUp.options.textSize*1.5)
				local side_sign = tech.aimPosition()[1] >= self.position[1] and 1 or -1 -- determines which side the box is facing
				local padding = self.popUp.options.boxPadding/2
				local shape = {
					{0-padding,0-padding},
					{(rect_length+padding)*side_sign,0-padding},
					{(rect_length+padding)*side_sign,rect_height+padding},
					{0-padding,rect_height+padding}
				}
				self.popUp:setShape(shape)
				self.popUp:setPosition(tech.aimPosition(), vec2.add({((rect_length+padding)*side_sign)/2, rect_height/2}, tech.aimPosition()))
			end
		end
		if args.moves.primaryFire or args.moves.altFire then -- buttons pressed
			if not hovered_button.isLocked then
				hovered_button.isPressed = true
				if not self.pressFailsafe then
					localAnimator.playAudio(self.options.buttonPressSound)
					self.pressFailsafe = true
					self.pressedButton = hovered_button.func ~= nil and hovered_button or nil
				end
			end
		else -- release buttons. note: this implementation might have issues when sliding the cursor across buttons while the buttons are held
			if self.pressFailsafe then
				hovered_button.isPressed = false
				self.pressFailsafe = false
				localAnimator.playAudio(self.options.buttonReleaseSound)
				if self.pressedButton then
					local status, value = pcall(self.pressedButton.func)
					if not status then
						error(value)
					end
					self.pressedButton = nil
				end
				if self.options.closeAfterButtonPress then
					self:close()
				end
			end
		end
	else -- if cursor is out of bounds. should do nothing if you hold a button inside the bounds, drag it off and let go. double check that
		if args.moves.primaryFire or args.moves.altFire then
			self:close()
			self.pressedButton = nil
			self.pressFailsafe = false
		end
	end
	self.popUp:update(popUp_state)
end

function VirtualPie:update(args)
	if self.rings then
		for i, virtualPie_Ring in ipairs(self.rings) do
			virtualPie_Ring:update()
		end
	end
	if self:isBusy() or self:isOpen() then
		self:hoverParse(args)
		self:render()
	end
	self.lastCursorPos = vec2.sub(tech.aimPosition(), self.position)
end

function VirtualPie:render()
	for i, virtualPie_Ring in ipairs(self.rings) do
		virtualPie_Ring:render(self.position)
	end
	self.popUp:render()
end

function VirtualPie:isBusy()
	if not self.rings then
		error("rings not present in main virtual pie object when isBusy was called")
	end
	return not util.all(self.rings, function(virtualPie_Ring) return not virtualPie_Ring:isBusy() end) --maybe not the INTENDED use of util.all but hey im using it to check for a boolean
end

function VirtualPie:open()
	if not self.is_open and not self:isBusy() then
		self.rings[1]:open()
	end
end

function VirtualPie:close()
	if self.is_open and not self:isBusy() then
		self.rings[#self.rings]:close()
	end
end

function VirtualPie:isClosed()
	return (self.is_open==false and self:isBusy()==false) and true or false
end

function VirtualPie:isOpen()
	return (self.is_open==true and self:isBusy()==false) and true or false
end

function VirtualPie:setPosition(vec)
	if vec then
		self.position = vec
	end
end

function VirtualPie:setColor()
	local newGradient = color:gradient(#self.rings+5) -- adding a flat 3 amount to account for highlighting upping the color level by 1 and clicking lowering it. If you tried clicking a ring of index 1 without this +2 it'd do an out of bounds exception. Last one is for the popUp
	for i, virtualPie_Ring in ipairs(self.rings) do
		local index = #newGradient - #self.rings - 3 + i
		virtualPie_Ring:setColor({
			onHover = newGradient[index+2],
			onPress = newGradient[index-2],
			base = newGradient[index]
		})
	end
	self.popUp:setColor(newGradient[1], newGradient[#newGradient])
end