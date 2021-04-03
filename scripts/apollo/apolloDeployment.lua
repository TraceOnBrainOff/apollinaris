local oldInit = init
local oldUpdate = update
local oldUninit = uninit

function init()
	if oldInit then
		oldInit()
	end
	localAnimator.clearDrawables()
	setAutoHandlers({"player", "localAnimator"})
	status.clearPersistentEffects("mechDeployment") -- unfuck the starbound mech deployment locking up techs
end

function update(dt)
	if oldUpdate then
		oldUpdate(dt)
	end
end

function uninit()
	if oldUninit then
		oldUninit()
	end
end

function setAutoHandlers(t)
	for i, stringT in ipairs(t) do
		local keyArray = {}
		for key, value in pairs(_ENV[stringT]) do
			table.insert(keyArray, key)
			message.setHandler(stringT.."."..key, function(_, sameClient, ...)
				if sameClient then
					return value(...)
				end
			end)
		end
		message.setHandler(stringT.."KeyArrayHandler", function(_, sameClient, _)
			if sameClient then
				return keyArray
			end
		end)
	end
end