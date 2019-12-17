VirtualButtons = {}
VirtualButtons.__index = VirtualButtons

function VirtualButtons:new(args) -- Table: {focusPoint = {0,0}, buttonDatabase = {...}, rings = 3, quarters = 4, innerRadius = 2, outerRadius = 6, smoothing = 4, closeAfterPress = true, color = {255,255,255} OR { {0,0,0}, {255,255,255} } for gradients}
	local self = {}
	setmetatable(self, VirtualButtons)
	if type(args) == "table" then
		for key, value in pairs(args) do
			self[key] = value
		end
		if type(self.focusPoint) == "number" then
			self.boundEntity = self.focusPoint
			self.focusPoint = world.entityPosition(self.boundEntity) or {0,0}
		end
		self:createQuickSelectButtons()
	else
		sb.logError("virtualButton creation failed")
		log("error", "virtualButton creation failed")
	end
	self.originInnerRadius = self.innerRadius
	self.originOuterRadius = self.outerRadius
	self.radiusTransition = 1
	self.transitionTimer = {0,30}
	self.boundryTable, self.transitionTimer[2] = overlappingBoundries(self.transitionTimer[2], self.rings, self.overlap or 0.5)
	self.lastCursorPos = tech.aimPosition()
	self.buttonHoverTime = {0,30}
	self.pressFailsafe = false
	self.popUp = {
		currentPos = {0,0},
		textSize = 0.75,
		active = false,
		timer = {0,15},
		--ToDisplay, not adding it here since it gets nulled anyway
		shape = {}, -- width will have to be determined by the longest string in all lines * character width, height will be determined by the number of lines * character height 
		shapeColor = #self.color == 2 and self.color[1] or {255,255,255},
		textColor = {0,0,0},
		currentText = "",
		lastText = ""
	}
	return self
end

function VirtualButtons:update(args)
	if self.transition then
		local difference = self.opening and 1 or -1
		self.transitionTimer[1] = self.transitionTimer[1] + difference
		for i=1, #self.ringLengths do
			local currTimer = math.max(0,self.transitionTimer[1]-self.boundryTable[i][1])
			local ending = self.boundryTable[i][2]
			self.ringLengths[i] = outQuart(currTimer, 0, 1, ending)
		end
		self.innerRadius = inOutQuart(self.transitionTimer[1], self.originInnerRadius, self.radiusTransition, self.transitionTimer[2])
		self.outerRadius = inOutQuart(self.transitionTimer[1], self.originOuterRadius, self.radiusTransition, self.transitionTimer[2])
		self:updateVertices()
		if self.transitionTimer[1] == 0  or self.transitionTimer[1] == self.transitionTimer[2] then
			self.innerRadius = self.opening and self.originInnerRadius+self.radiusTransition or self.originInnerRadius
			self.outerRadius = self.opening and self.originOuterRadius+self.radiusTransition or self.originOuterRadius
			for i=1, #self.ringLengths do -- failsaving just to be sure cos I'm pretty certain using my standard easing expressions will fuck shit up.
				self.ringLengths[i] = self.opening and 1 or 0
			end
			self:updateVertices()
			self.transition = false
		end
	end
	if self.boundEntity then
		local exists, pos = pcall(world.entityPosition, self.boundEntity)
		if exists then
			self.focusPoint = pos
		else
			self.boundEntity = nil
			self:close()
		end
	end
	if not self:isClosed() and self.focusPoint then
		self:highlightCheck(args)
		self:render()
	end
	self:popUpUpdate()
	self.lastCursorPos = tech.aimPosition()
end

function VirtualButtons:render()
	for quarterI, rings in ipairs(self.buttons) do
		for ringI, button in ipairs(rings) do
			for i, v in ipairs(button.vertices) do
				local layer = (self.rings-(ringI-1))*2 -- rings: 1,2,3 // layers: 6, 4, 2 // textLayers: 7, 5, 3 // commentLayer: self.rings*2+2 = 8 
				local textLayer = layer+1
				localAnimator.addDrawable({poly = v, color = (not button.isHighlighted or not button.isPressed) and (not button.isHighlighted and button.color or {255,255,255}) or {0,0,0}, position = button.focusPoint}, "foregroundEntity+"..tostring(layer))
				if button.image then
					local quarterAngleRange = 360/self.quarters
					local rotation = quarterAngleRange + quarterAngleRange*quarterI
					local distance = (button.innerRadius + button.outerRadius)/2
					for i=1, type(button.image)=="table" and #button.image or 1 do
						local particle = {
							type = "textured",
							image = type(button.image)=="table" and button.image[i] or button.image,
							fullbright = true,
							timeToLive = 0,
							destructionTime = 0,
							destructionAction = "fade",
							position = circle(self.focusPoint or {0,0}, distance, rotation),
							rotation = rotation-90,
							size = (self.imageSize or 1)*self.imageSize[ringI],
							layer = "front"
						}
						localAnimator.spawnParticle(particle)
					end
				end
			end
		end
	end
	if self:activePopUp() then
		local alpha = 255*(self.popUp.timer[1]/self.popUp.timer[2])
		local color = {0,0,0, alpha}
		local pos = vec2.sub(self.popUp.currentPos,mcontroller.position())
		localAnimator.addDrawable({poly = self.popUp.shape, color = color, position = pos}, "foregroundEntity+"..(self.rings*2+2))
		local particle = {
			type = "text",
			text = self.popUp.currentText,
			color = {255,255,255, alpha},
			fullbright = true,
			timeToLive = 0,
			destructionTime = 0,
			destructionAction = "fade",
			position = vec2.add(self.popUp.currentPos, {self.popUp.check and self.popUp.shapeLength/2 or -self.popUp.shapeLength/2,self.popUp.shapeHeight/2}),
			size = self.popUp.textSize,
			layer = "front"
		}
		localAnimator.spawnParticle(particle)
	end
end

function VirtualButtons:createQuickSelectButtons()
	--[[
	buttonDatabase = 	{ quarter1
			{ ring1 = button1
				name = "txt", -- reuse names for windows esque highlighting schtick
				image = {"", "", "", ...} or "" !!!
				func = function() end
			}
		}
	]]
	local ringLengths = self.ringLengths or {}
	if #ringLengths == 0 then
		for i=1, self.rings do
			ringLengths[i] = 0
		end
	end

	local templateButton = {
		name = "Empty Button",
		isHighlighted = false,
		func = function(button, boundries) log("warn", "Debug purposes. Boundries:", boundries) end
	}
	local templateDatabase = {}
	for i=1, self.quarters do
		templateDatabase[i] = {}
		for j=1, self.rings do
			templateDatabase[i][j] = templateButton
		end
	end
	local buttonDatabase = {}
	buttonDatabase = self:buttonMerge(templateDatabase, self.buttonDatabase or {})

	local buttonStruct = {}
	local ringDistance = math.abs(self.outerRadius - self.innerRadius)/self.rings -- Maximum distance between each ring
	local quarterAngleRange = 360/self.quarters -- How much a given quarter encompasses in terms of angle. Important for calculations.
	for quarter = 0, self.quarters-1 do
		local baseAngle = quarterAngleRange/2 + quarterAngleRange*quarter
		buttonStruct[#buttonStruct+1] = {}
		local currentQuarter = buttonStruct[#buttonStruct] -- { {} }
		local lastInnerRadius = self.innerRadius -- Important for calculating inner/outer rings
		for ring = 0, self.rings-1 do
			currentQuarter[#currentQuarter+1] = {} -- buttonStruct:{ currentQuarter:{ currentButton:{} } }
			local currentButton = currentQuarter[#currentQuarter] -- button declaration

			currentButton.innerRadius = lastInnerRadius
			currentButton.outerRadius = currentButton.innerRadius + ringLengths[ring+1]*ringDistance
			lastInnerRadius = currentButton.outerRadius

			currentButton.vertices = {}
			for i=0,self.smoothing-1 do -- Thanks to the fact that SB has no idea how to handle concave polygons, I have to separate the result polygon into subshapes to construct a concave polygon out of smaller, convex polygons
				currentButton.vertices[#currentButton.vertices+1] = {}
				local currentSubShape = currentButton.vertices[#currentButton.vertices]
				local currentAngle = baseAngle + quarterAngleRange/self.smoothing * i
				local nextAngle = baseAngle + quarterAngleRange/self.smoothing * (i+1)
				currentSubShape[#currentSubShape+1] = circle({0,0}, currentButton.innerRadius, currentAngle)
				currentSubShape[#currentSubShape+1] = circle({0,0}, currentButton.outerRadius, currentAngle)
				currentSubShape[#currentSubShape+1] = circle({0,0}, currentButton.outerRadius, nextAngle)
				currentSubShape[#currentSubShape+1] = circle({0,0}, currentButton.innerRadius, nextAngle)
			end -- Done work on vertices

			for key, value in pairs(buttonDatabase[quarter+1][ring+1]) do
				currentButton[key] = value
			end -- Adding functions, names, comments, etc to the current button from the template

			local color = {}
			for i=1,3 do
				if #self.color == 2 then
					if self.rings > 1 then
						color[i] = self.color[1][i] + ((self.color[2][i]-self.color[1][i])*(ring/(self.rings-1))) -- Gradients
					else
						color[i] = self.color[1][i]
					end
				else
					color[i] = self.color[i]
				end
			end -- Adding color etc
			currentButton.color = color

		end
	end
	self.buttons = buttonStruct
	self.ringLengths = ringLengths
end

function VirtualButtons:open()
	if not self:isOpen() then
		self.transition = true
		self.opening = true
	end
end

function VirtualButtons:close()
	if not self:isClosed() then
		self.transition = true
		self.opening = false
	end
end

function VirtualButtons:isClosed()
	if self.ringLengths[1] == 0 and self.ringLengths[2] == 0 and self.ringLengths[3] == 0 then
		return true
	else
		return false
	end
end

function VirtualButtons:isOpen()
	if self.ringLengths[1] == 1 and self.ringLengths[2] == 1 and self.ringLengths[3] == 1 then
		return true
	else
		return false
	end
end

function VirtualButtons:updateFocusPoint(vec)
	if vec then
		if type(vec) == "table" then
			self.focusPoint = vec
			self.boundEntity = nil
		else
			self.boundEntity = vec
		end
	end
end

function VirtualButtons:setRings(int)
	self.rings = int>=1 and int or (1 or log("warn", "Defaulting. setRings is invalid: ", int))
	self:createQuickSelectButtons()
end

function VirtualButtons:setQuarters(int)
	self.quarters = int>=1 and int or (4 or log("warn", "Defaulting. setQuarters is invalid: ", int))
	self:createQuickSelectButtons() -- hard recreation required look up
end

function VirtualButtons:setColor(color)
	self.color = type(color)=="table" and color or ({128,128,128} or log("warn", "Defaulting. setColor is invalid: ", color))
	self:createQuickSelectButtons() -- hard recreation required look up
end

function VirtualButtons:setButtons(t)
	self.buttonDatabase = type(t) == "table" and tableMerge(self.buttonDatabase, t) or ({} or log("warn", "Defaulting. setButtons is invalid: ", t)) -- merges the tables so loss of data is unlikely to occur
	self:createQuickSelectButtons() -- hard recreation required look up
end

function VirtualButtons:updateVertices()
	local buttonStruct = {}
	local ringDistance = math.abs(self.outerRadius - self.innerRadius)/self.rings
	local quarterAngleRange = 360/self.quarters -- How much a given quarter encompasses in terms of angle. Important for calculations.
	for quarter = 0, self.quarters-1 do
		local baseAngle = quarterAngleRange/2 + quarterAngleRange*quarter
		buttonStruct[#buttonStruct+1] = {}
		local currentQuarter = buttonStruct[#buttonStruct] -- { {} }
		local lastInnerRadius = self.innerRadius
		for ring = 0, self.rings-1 do
			currentQuarter[#currentQuarter+1] = {} -- buttonStruct:{ currentQuarter:{ currentButton:{} } }
			local currentButton = currentQuarter[#currentQuarter] -- button declaration
			
			currentButton.innerRadius = lastInnerRadius
			currentButton.outerRadius = currentButton.innerRadius + self.ringLengths[ring+1]*ringDistance
			lastInnerRadius = currentButton.outerRadius

			currentButton.vertices = {}
			for i=0,self.smoothing-1 do
				currentButton.vertices[#currentButton.vertices+1] = {}
				local currentSubShape = currentButton.vertices[#currentButton.vertices]
				local currentAngle = baseAngle + quarterAngleRange/self.smoothing * i
				local nextAngle = baseAngle + quarterAngleRange/self.smoothing * (i+1)
				currentSubShape[#currentSubShape+1] = circle({0,0}, currentButton.innerRadius, currentAngle)
				currentSubShape[#currentSubShape+1] = circle({0,0}, currentButton.outerRadius, currentAngle)
				currentSubShape[#currentSubShape+1] = circle({0,0}, currentButton.outerRadius, nextAngle)
				currentSubShape[#currentSubShape+1] = circle({0,0}, currentButton.innerRadius, nextAngle)
			end
			self.buttons[quarter+1][ring+1].innerRadius = currentButton.innerRadius
			self.buttons[quarter+1][ring+1].outerRadius = currentButton.outerRadius
			self.buttons[quarter+1][ring+1].vertices = currentButton.vertices
		end
	end
end

function VirtualButtons:highlightCheck(args)
	local distance = world.magnitude(tech.aimPosition(), self.focusPoint)
	local quarterAngleRange = 360/self.quarters
	local angle = (math.deg(vec2.angle(vec2.sub(tech.aimPosition(), self.focusPoint))) + quarterAngleRange/2 - quarterAngleRange)%360

	local angleT = {}
	for i=1,self.quarters do
		angleT[i] = quarterAngleRange*i
	end
	local angleBoundry = checkBoundry(angleT, angle) + 1 -- Works!

	local distanceT = {self.innerRadius} -- will be filled out with outer radiuses for later comparison with checkBoundry() to determine which ring the cursor is hovering over
	for i=1, self.rings do
		distanceT[#distanceT+1] = self.buttons[1][i].outerRadius -- gets the outer radius of every button from quarter1, because i can assume that's gonna exist all the time... right?
	end
	local distanceBoundry = checkBoundry(distanceT, distance) -- from 0 to 4 on rings = 3
	for iQuarter, rings in ipairs(self.buttons) do
		for iRing, button in ipairs(rings) do
			button.isHighlighted = false
			button.isPressed = false
		end
	end
	if distanceBoundry > 0 and distanceBoundry <= self.rings then -- cursor is inside the bounds
		local currentButton = self.buttons[angleBoundry][distanceBoundry]
		if currentButton.func then -- buttons without functions assigned to them won't be highlighted. At least that's what it's supposed to do. Bugtest!!!
			currentButton.isHighlighted = true
			if vec2.eq(tech.aimPosition(), self.lastCursorPos) then
				self.buttonHoverTime[1] = self.buttonHoverTime[1]<self.buttonHoverTime[2] and self.buttonHoverTime[1]+1 or self.buttonHoverTime[1] -- very convoluted way of doing the usual math.min() shit
				if (self.buttonHoverTime[1] == self.buttonHoverTime[2]) and not vec2.eq(self.popUp.currentPos, tech.aimPosition()) then
					self.popUp.currentPos = tech.aimPosition() -- decl
					self.popUp.currentText = currentButton.name
					local shapeLength = hobo.getLength(self.popUp.currentText, self.popUp.textSize)*1.5
					local shapeHeight = (self.popUp.textSize*1.5)
					local check = tech.aimPosition()[1] >= self.focusPoint[1] -- important for determining which way the "butt" of the shape should be facing X wise. aesthetics
					local shape = {}
					shape[#shape+1] = {0,0}
					shape[#shape+1] = {check and shapeLength or -shapeLength,0}
					shape[#shape+1] = {check and shapeLength or -shapeLength,shapeHeight}
					shape[#shape+1] = {0,shapeHeight}
					self.popUp.shape = shape
					self.popUp.shapeLength = shapeLength
					self.popUp.shapeHeight = shapeHeight
					self.popUp.check = check
				end
			else
				self.buttonHoverTime[1] = 0
			end
			if args.moves.primaryFire or args.moves.altFire then -- buttons pressed
				currentButton.isPressed = true
				if not self.pressFailsafe and not (self.transition and not self.opening) then
					--localAnimator.playAudio(String sound, [int loops], [float volume]) press
					self.pressFailsafe = true
					self.toCall = currentButton.func
				end
			else -- release buttons. note: this implementation might have issues when sliding the cursor across buttons while the buttons are held
				if self.toCall and self.pressFailsafe then
					currentButton.isPressed = false
					self.toCall(currentButton, {angleBoundry = angleBoundry, distanceBoundry = distanceBoundry}) -- pass the entire button. crazy ik
					self.toCall = nil
					self.pressFailsafe = false
					--localAnimator.playAudio(String sound, [int loops], [float volume]) release
					if self.closeAfterPress then
						self:close()
					end
				end
			end
		end
	else -- if cursor is out of bounds. should do nothing if you hold a button inside the bounds, drag it off and let go. double check that
		self.buttonHoverTime[1] = 0
		if args.moves.primaryFire or args.moves.altFire then
			if not self.pressFailsafe then
				self:close()
			end
		else
			if self.toCall or self.pressFailsafe then
				self.toCall = nil
				self.pressFailsafe = false
			end
		end
	end
end

function VirtualButtons:popUpUpdate()
	local struct = self.popUp
	if self:activePopUp() then
		struct.timer[1] = struct.timer[1]<struct.timer[2] and struct.timer[1] + 1 or struct.timer[1]
		if struct.timer[1] > 0 then
		end
	else
		struct.timer[1] = struct.timer[1]>0 and struct.timer[1] - 1 or struct.timer[1]
	end
end

function VirtualButtons:activePopUp()
	if self.buttonHoverTime[1] == self.buttonHoverTime[2] then
		return true
	end
	return false
end

function VirtualButtons:buttonMerge(template, value)
	local new = {}
	for quarter=1, #template do
		new[#new+1] = {}
		local currentQuarter = new[#new] 
		for ring=1, #template[quarter] do
			currentQuarter[#currentQuarter+1] = {}
			new[quarter][ring] = value[quarter][ring] or template[quarter][ring]
		end
	end    
	return new
end