function createApollinarisLogo(size, color, t)
	if size ~= nil and t ~= nil then
		if type(size) == "number" and type(t) == "table" then
			local fullT = {attack = nil, defense=nil, support=nil}
			local a = {}
			local b = {}
			local c = {}
			local baseOffset = -30
			if inTable(t, "attack") then -- inner triangle
				local angleRef = 360 / 3
				for i=1, 3, 1 do
					table.insert(a, lineActionPeriodHex(circle({0,0}, size, i*angleRef+baseOffset),circle({0,0}, size, i*angleRef+baseOffset), circle({0,0}, size, (i+1)*angleRef+baseOffset), 0.75, color, "front", 0.01, 0.02, "shrink", 0,0,0))
				end
			end
			if inTable(t, "defense") then -- outer triangle
				local angleRef = 360 / 3
				for i=1, 3, 1 do
					table.insert(b, lineActionPeriodHex(circle({0,0}, size*2, i*angleRef+baseOffset-180),circle({0,0}, size*2, i*angleRef+baseOffset-180), circle({0,0}, size*2, (i+1)*angleRef+baseOffset-180), 0.75, color, "front", 0.01, 0.02, "shrink", 0,0,0))
				end
			end
			if inTable(t, "support") then -- details triangle
				local angleRef = 360 / 3
				for i=1, 3, 1 do
					table.insert(c, lineActionPeriodHex(circle({0,0}, size*2.5, i*angleRef+baseOffset),circle({0,0}, size*2.5, i*angleRef+baseOffset), circle({0,0}, size*2, i*angleRef+baseOffset), 0.75, color, "front", 0.01, 0.02, "shrink", 0,0,0))
				end
				local angleRef = 360 / 3
				for i=1, 3, 1 do
					table.insert(c, lineActionPeriodHex(circle({0,0}, size*2, i*angleRef+baseOffset),circle({0,0}, size*2, i*angleRef+baseOffset), circle({0,0}, size*2.5, i*angleRef+baseOffset+(angleRef/8)), 0.75, color, "front", 0.01, 0.02, "shrink", 0,0,0))
					table.insert(c, lineActionPeriodHex(circle({0,0}, size*2, i*angleRef+baseOffset),circle({0,0}, size*2, i*angleRef+baseOffset), circle({0,0}, size*2.5, i*angleRef+baseOffset-(angleRef/8)), 0.75, color, "front", 0.01, 0.02, "shrink", 0,0,0))
				end
			end
			local circleAngleRef = 360 / 24
			for i=1, 24, 1 do
				table.insert(a, lineActionPeriodHex(circle({0,0}, size, i*circleAngleRef+baseOffset),circle({0,0}, size, i*circleAngleRef+baseOffset), circle({0,0}, size, (i+1)*circleAngleRef+baseOffset), 0.4, "333333", "front", 0.01, 0.01, "fade", 0,0,0))
			end
			for i=1, 24, 1 do
				table.insert(b, lineActionPeriodHex(circle({0,0}, 2.5*size, i*circleAngleRef+baseOffset),circle({0,0}, 2.5*size, i*circleAngleRef+baseOffset), circle({0,0}, 2.5*size, (i+1)*circleAngleRef+baseOffset), 0.4, "333333", "front", 0.01, 0.01, "fade", 0,0,0))
			end
			local circleAngleRef = 360 / 6
			for i=1, 6, 1 do
				table.insert(c, lineActionPeriodHex(circle({0,0}, 2*size, i*circleAngleRef+baseOffset),circle({0,0}, 2*size, i*circleAngleRef+baseOffset), circle({0,0}, 2*size, (i+1)*circleAngleRef+baseOffset), 0.4, "333333", "front", 0.01, 0.01, "fade", 0,0,0))
			end
			if a == {} then a = nil end -- Failsafe to check if something was even inputted, because periodic actions may mess the fuck up if you give it an empty table
			if b == {} then b = nil end
			if c == {} then c = nil end
			fullT.attack = a
			fullT.defense = b
			fullT.support = c
			return fullT
		end
	end
end