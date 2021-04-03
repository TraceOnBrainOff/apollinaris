local commonMethods = {}
function newAbility(t)
	t = t or {}
	function t:__index(key)
		if commonMethods[key] then 
			local function wrappedMethod(...) 
				if t[key] then 
					commonMethods[key](...) 
					return t[key](...)
				else 
					return commonMethods[key](...) 
				end
			end
			self[key] = wrappedMethod 
			return wrappedMethod
		else 
			return t[key]
		end
	end
	return t
end

function commonMethods:stop()
    self.finished = true
end