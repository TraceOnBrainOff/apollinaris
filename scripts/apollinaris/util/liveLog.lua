LiveLog = {}
LiveLog.__index = LiveLog

function LiveLog:assign()
    self = {}
    setmetatable(self, LiveLog)
    self.entryTable = {}
	self.textSize = 0.6 -- ratio for the baseOffset = 6*textSize apparently
	--self:wrapLogging() -- fuck this royally dude 
    return self
end

function LiveLog:update()
    for i, currentEntry in ipairs(self.entryTable) do
		local localParticle = currentEntry.particleConfig
		local toPrint = string.format("%s%s", currentEntry.prefix, currentEntry.key)
		if currentEntry.value then -- oh god oh fuck fix this please pronto
			local printType = type(currentEntry.value)
			if printType == "string" or printType == "number" or printType == "boolean" then
				toPrint = string.format("%s %s", toPrint, currentEntry.value)
			elseif printType == "table" then
				toPrint = string.format("%s %s", toPrint, tostring(sb.printJson(currentEntry.value)))
			elseif printType == "function" or printType == "thread" or printType == "userdata" then
				toPrint = string.format("%s: Attempting to print value of an illegal type: %s", currentEntry.key, printType)
			end
		end
		localParticle.position = vec2.add(mcontroller.position(),{0, -self.textSize*6 -self.textSize*(i-1)})
		localParticle.text = toPrint
		localAnimator.spawnParticle(localParticle)
		localParticle.text = "" -- resetting it so that it doesn't keep pasting the same shit over and over to the string, since the particle's text was the storage medium before
		currentEntry.remainingTime = math.max(0, currentEntry.remainingTime-1)
		if currentEntry.remainingTime == 0 then
			table.remove(self.entryTable,i)
		end
	end
end

function LiveLog:log(kind, key, value, time)
    local time = time or 3
	for i=1, #self.entryTable do
		local currentEntry = self.entryTable[i]
		if currentEntry.key == key then
			currentEntry.value = value
			currentEntry.remainingTime = time*60
			return
		end
	end
	local types = {
		["error"] = {prefix = "^shadow;[!!!] ", color = {229,55,53}, func = sb.logError}, --e53735
		["warn"] = {prefix = "^shadow;[..!] ", color = {249,139,0}, func = sb.logWarn},    --f98b00
		["info"] = {prefix = "^shadow;[...] ", color = {27,135,229}, func = sb.logInfo} --1b87e5
	}
	local particleConfig = {
		type = "text",
		color = types[kind].color,
		fullbright = true,
		text = "", -- types[kind].prefix..key
		timeToLive = 0,
		destructionTime = 0,
		destructionAction = "fade",
		position = {0,0},
		size = self.textSize,
		layer = "front"
	}
	self.entryTable[#self.entryTable+1] = {
		key = key,
		remainingTime = time*60,
		particleConfig = particleConfig,
		value = value,
		prefix = types[kind].prefix
	}
	types[kind].func(key)
end

function LiveLog:wrapLogging()
	local oldLogInfo = sb.logInfo
	local oldLogWarn = sb.logWarn
	local oldLogError = sb.logError -- wrapping all three

	function sb.logInfo(formatString, ...)
		oldLogInfo(formatString, ...)
		self:log("info", "Info", string.format(formatString, ...), 3)
	end

	function sb.logWarn(formatString, ...)
		oldLogWarn(formatString, ...)
		self:log("warn", "Warning", string.format(formatString, ...), 3)
	end

	function sb.logError(formatString, ...)
		oldLogError(formatString, ...)
		self:log("error", "Error", string.format(formatString, ...), 3)
	end
end

function LiveLog:uninit()

end