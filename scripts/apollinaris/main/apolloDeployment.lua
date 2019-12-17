require "/scripts/vec2.lua"

local oldInit = init -- unfuck starbound's deployment script init

function init()
	oldInit()
	localAnimator.clearDrawables()
	setAutoHandlers({"player", "localAnimator"})
	--sb.logInfo(string.format("Server UUID: %s", player.serverUuid()))
end

function update(dt)
end

function uninit()
end

function setAutoHandlers(t)
	for i, stringT in ipairs(t) do
		local keyArray = {}
		for key, value in pairs(_ENV[stringT]) do
			table.insert(keyArray, key)
			message.setHandler(stringT.."."..key, function(_, sameClient, args)
				if sameClient then
					if args ~= nil then
						return value(table.unpack(args))
					else
						return value()
					end
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