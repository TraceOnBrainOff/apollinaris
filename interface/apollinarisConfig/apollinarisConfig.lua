require "/scripts/util.lua"
require "/scripts/interp.lua"
require "/scripts/easingExpressions.lua"

function init()
	debug = true
	allWidgets = {"buttono1","buttono2","buttono3","buttono4", "settingsButton1", "settingsButton2", "settingsButton3", "settingsButton4", "contactLabel", "charButton1", "charButton2", "charButton3", "charButton4","setupButton1", "setupButton2","setupButton3", "colorSlider1","colorSlider2","colorSlider3", "colorUIAdapt", "colorLookup", "colorUIAdapt", "colorHexImage", "colorHexText", "colorAccept", "routeButton1","routeButton2","routeButton3", "routePane1", "routePane2", "routePane3", "routeSubButton1", "routeSubButton2", "routeSubButton3", "routeText1", "routeText2", "routeText3", "noClipSlider1", "noClipLabel1", "noClipLabelText1", "noClipSlider2", "noClipLabel2", "noClipLabelText2", "noClipAccept", "introCanvas"} -- Leave actualHeader, actualFooter, purple, purpleLabel, close, titleLabel and settings, out of this, because they are universal
	widgetLayout = {
		["mainMenu"] = {
			buttono1 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "Skill Tree^reset;"},
			buttono2 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "Character^reset;"},
			buttono3 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "Memory^reset;"},
			buttono4 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "Quests^reset;"}
		},
		["settings"] = {
			settingsButton1 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "No-Clip^reset;"},
			settingsButton2 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "Setup^reset;"},
			settingsButton3 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "Contact^reset;"},
			settingsButton4 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "Help^reset;"}
		},
		["contact"] = {
			contactLabel = {typo = "label", text = "If you want to get in touch with me to report a bug, ask for help or just to chat, message me here:\n\nDiscord: Sev#8954\n\nSteam: steamcommunity.com/id/ThatCorruptBoy/"}
		},
		["character"] = {
			charButton1 = {typo = "button", img = "/interface/apollinarisConfig/verticalButton.png", text = "Passive"},
			charButton2 = {typo = "button", img = "/interface/apollinarisConfig/verticalButton.png", text = "Ultimate"},
			charButton3 = {typo = "button", img = "/interface/apollinarisConfig/verticalButton.png", text = "Ability 1"},
			charButton4 = {typo = "button", img = "/interface/apollinarisConfig/verticalButton.png", text = "Ability 2"}
		},
		["setup"] = {
			setupButton1 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "Color"},
			setupButton2 = {typo = "button", img = "/interface/apollinarisConfig/button.png", text = "Route"},
			setupButton3 = {typo = "button", img = "/interface/apollinarisConfig/bigButton.png", text = "Accept"}
		},
		["color"] = {
			colorSlider1 = {typo = "ignore"},
			colorSlider2 = {typo = "ignore"},
			colorSlider3 = {typo = "ignore"},
			colorUIAdapt = {typo = "switch", img = "/interface/apollinarisConfig/colorButton.png", text = "Adapt UI to Color?", checked = status.statusProperty("apolloAdaptUI") or true},
			colorLookup = {typo = "ignore"},
			colorHexImage = {typo = "image", img = "/interface/apollinarisConfig/hex.png"},
			colorHexText = {typo = "ignore"},
			colorAccept = {typo = "button", img = "/interface/apollinarisConfig/acceptColor.png", text = "Accept"}
		},
		["route"] = {
			routeButton1 = {typo = "button", img = "/interface/apollinarisConfig/routeButton.png", text = "Offense"},
			routeButton2 = {typo = "button", img = "/interface/apollinarisConfig/routeButton.png", text = "Defense"},
			routeButton3 = {typo = "button", img = "/interface/apollinarisConfig/routeButton.png", text = "Support"},
			routePane1 = {typo = "image", img = "/interface/apollinarisConfig/routePane.png"},
			routePane2 = {typo = "image", img = "/interface/apollinarisConfig/routePane.png"},
			routePane3 = {typo = "image", img = "/interface/apollinarisConfig/routePane.png"},
			routeSubButton1 = {typo = "button", img = "/interface/apollinarisConfig/acceptRouteButton.png", text = "Accept"},
			routeSubButton2 = {typo = "button", img = "/interface/apollinarisConfig/acceptRouteButton.png", text = "Accept"},
			routeSubButton3 = {typo = "button", img = "/interface/apollinarisConfig/acceptRouteButton.png", text = "Accept"},
			routeText1 = {typo = "label", text = ""}, -- These are set by the route script so there's no point in setting these here.
			routeText2 = {typo = "label", text = ""}, -- These are set by the route script so there's no point in setting these here.
			routeText3 = {typo = "label", text = ""} -- These are set by the route script so there's no point in setting these here.
		},
		["noClip"] = {
			noClipSlider1 = {typo = "ignore"},
			noClipLabel1 = {typo = "image", img = "/interface/apollinarisConfig/noClipLabel.png"},
			noClipLabelText1 =  {typo = "label", text = "Top Speed"},
			noClipSlider2 = {typo = "ignore"},
			noClipLabel2 = {typo = "image", img = "/interface/apollinarisConfig/noClipLabel.png"},
			noClipLabelText2 =  {typo = "label", text = "Control"},
			noClipAccept = {typo = "button", img = "/interface/apollinarisConfig/acceptNoClip.png", text = "Accept"}
		},
		["intro"] = {
			introCanvas = {typo = "ignore"}
		},
		["open"] = {
			animatedIntroCanvas = {typo = "ignore"}
		}
	}
	switches = {}
	transitionT = {0,0.4} -- Current/Max
	widget.setText("titleLabel", "")
	currentENV = "open"
	historyENV = {}
	paneSetup()
	diff = -40
	if colorLogic(status.statusProperty("apolloSetup")~=nil, status.statusProperty("apolloAdaptUI") or false) then
		lineHex = checkColorTamper(status.statusProperty("apolloColor"))
	else
		lineHex = "9E9E9E"
	end
	darkerLineHex = rgbToHex({hexToRGB(lineHex)[1]+diff,hexToRGB(lineHex)[2]+diff,hexToRGB(lineHex)[3]+diff})
	contrast = -100
	colorPickSetup()
	setupIntro()
	for i=1, #allWidgets, 1 do
		widget.setVisible(allWidgets[i], false)
	end
	--widget.playSound("/interface/apollinarisConfig/menuTheme.ogg", 1, 0.75)
	setBaseColors("full")
	world.sendEntityMessage(player.id(), "canEnableCheck")
	nCSSetup()
	setupAi()
end

function checkColorTamper(color)
	local color = hexToRGB(color)
	for i=1, #color, 1 do
		if checkBoundry({math.abs(diff), 255+diff}, color[i]) == 0 then
			color[i] = math.abs(diff)
			sb.logWarn("Underflow at "..i..", changing to "..math.abs(diff))
		end
		if checkBoundry({math.abs(diff), 255+diff}, color[i]) == 2 then
			color[i] = 255+diff
			sb.logWarn("Overflow at "..i..", changing to "..(255+diff))
		end
	end
	return rgbToHex(color)
end

function setPermInterfaceColors(directives, contrast)
	directives = directives or "FFFFFF"
	contrast = contrast or 0
	--actualHeader, actualFooter, purple, purpleLabel, close, titleLabel and settings
	local img = "/interface/apollinarisConfig/header.png"
	widget.setImage("actualHeader", img.."?setcolor="..lineHex.."?multiply="..directives.."?saturation="..contrast)
	widget.setImage("actualFooter", img.."?setcolor="..lineHex.."?multiply="..directives.."?saturation="..contrast)
	widget.setImage("transition", "/interface/apollinarisConfig/transition.png?setcolor="..darkerLineHex.."?multiply="..directives.."?saturation="..contrast)
	widget.setImage("purple", img.."?setcolor="..darkerLineHex.."?multiply="..directives.."?saturation="..contrast)
	local smallButton = createButtonColors("/interface/apollinarisConfig/quit.png", darkerLineHex, directives, contrast)
	widget.setButtonImages("close", smallButton)
	widget.setButtonImages("settings", smallButton)
	widget.setButtonImages("homeButton", createButtonColors("/interface/apollinarisConfig/quit.png", lineHex, directives, contrast))
end

function tableSearch(t, target)
	local keyStorage = {}
	for key, value in pairs(t) do
		if tostring(key) ~= target and type(value) == "table" then
			table.insert(keyStorage, tostring(key))
		elseif tostring(key) == target then
			return t[key]
		end
	end
	for i=1, #keyStorage, 1 do
		local result = tableSearch(t[keyStorage[i]], target)
		if result ~= nil then return result end
	end
end

function handleSwitches() -- Chucklefish fucked the fucking switches up so hard I had to make my own function
	for widgetName, bool in pairs(switches) do
		local widgetConfig = tableSearch(widgetLayout, widgetName)
		if switches[widgetName] == true then
			widget.setButtonImages(widgetName, createButtonColors(widgetConfig.img, darkerLineHex, altColor))
		else
			widget.setButtonImages(widgetName, createButtonColors(widgetConfig.img, lineHex, altColor))
		end
	end
end

function setBaseColors(method, altColor) -- "full" or "background"
	local function parseLayoutItemConfig(widgetName, t, darkerColor, altColor)
		altColor = altColor or "FFFFFF"
		darkerColor = rgbToHex({hexToRGB(darkerColor)[1]-(255-hexToRGB(altColor)[1]),hexToRGB(darkerColor)[2]-(255-hexToRGB(altColor)[2]),hexToRGB(darkerColor)[3]-(255-hexToRGB(altColor)[3])})
		if t.typo ~= nil and widgetName ~= nil then
			if t.typo == "button" then
				widget.setButtonImages(widgetName, createButtonColors(t.img, lineHex, altColor))
				if t.text ~= nil then
					widget.setFontColor(widgetName,hexToRGB(darkerColor))
					widget.setText(widgetName, t.text)
				end
			elseif t.typo == "image" then
				widget.setImage(widgetName, t.img.."?setcolor="..lineHex.."?multiply="..altColor)
			elseif t.typo == "label" then
				if t.text ~= nil then
					widget.setFontColor(widgetName, hexToRGB(darkerColor))
					widget.setText(widgetName, t.text)
				end
			elseif t.typo == "switch" then
				if switches[widgetName] == nil then
					switches[widgetName] = t.checked
				end
				if switches[widgetName] == true then
					widget.setButtonImages(widgetName, createButtonColors(t.img, lineHex, altColor))
				else
					widget.setButtonImages(widgetName, createButtonColors(t.img, darkerLineHex, altColor))
				end
				if t.text ~= nil then
					widget.setFontColor(widgetName, hexToRGB(darkerColor))
					widget.setText(widgetName, t.text)
				end
			elseif t.typo == "ignore" then
				-- obviously do nothing, dummy
			end
		else
			sb.logError("Invalid layout item config for "..widgetName)
		end
	end
	if method == "full" then
		local darkerLineHex = rgbToHex({hexToRGB(lineHex)[1]-diff,hexToRGB(lineHex)[2]-diff,hexToRGB(lineHex)[3]-diff})
		for layoutName, layoutItemTable in pairs(widgetLayout) do
			for widgetName, widgetConfig in pairs(layoutItemTable) do
				parseLayoutItemConfig(widgetName, widgetConfig, darkerLineHex)
			end
		end
	elseif method == "effects" and altColor ~= nil then
		local darkerLineHex = rgbToHex({math.floor(hexToRGB(altColor)[1]-diff),math.floor(hexToRGB(altColor)[2]-diff),math.floor(hexToRGB(altColor)[3]-diff)})
		for layoutName, layoutItemTable in pairs(widgetLayout) do
			if layoutName == currentENV then
				for widgetName, widgetConfig in pairs(layoutItmeTable) do
					parseLayoutItemConfig(widgetName, widgetConfig, darkerLineHex, altColor)
				end
			end
		end
	else
		sb.logError("Method invalid.: "..method)
	end
end

function paneSetup()
	rTr = {
		timer = {0,0.5}, 
		currState = "0", 
		halfWay = true, 
		beginPos = {0,0,0}, 
		states = {
			["1"] = {["1"] = 5, ["2"] = 350, ["3"] = 350}, 
			["2"] = {["1"] = -110, ["2"] = 5, ["3"] = 350}, 
			["3"] = {["1"] = -110, ["2"] = -110, ["3"] = 5}, 
			["0"] = {["1"] = 5, ["2"] = 120, ["3"] = 235}
		},
		panes = {
			["1"] = 0,
			["2"] = 0,
			["3"] = 0,
			["maxValue"] = 0.3,
		},
		buttonOffset = 65,
		text = {["1"] = "This route focuses on offensive skills\nSkill points are earned for slaying various entities\nranging from monsters to players and worlds\nAre you sure you want to conitnue?\n(Press the name of the route to go back)\nWarning: This change cannot be undone!", ["2"] = "This route focuses on defensive skills.\nSkill points are earned for building various structures\nranging from shields to fortresses\nAre you sure you want to conitnue?\n(Press the name of the route to go back)\nWarning: This change cannot be undone!", ["3"] = "Idfk\nI'm too lazy to write this rn\nstop bugging me\nAre you sure you want to conitnue?\n(Press the name of the route to go back)\nWarning: This change cannot be undone!"},
		textOffset = 115
	}
end

function colorPickSetup()
	if status.statusProperty("apolloColor") == nil then
		colorPickerRGB = {128,128,128}
		colorPick = {done = false, color = {128,128,128}, adaptUI = nil}
		for i=1, 3, 1 do
			widget.setSliderValue("colorSlider"..i, colorPickerRGB[i])
		end
	else
		colorPickerRGB = hexToRGB(status.statusProperty("apolloColor"))
		colorPick = {done = false, color = hexToRGB(status.statusProperty("apolloColor")), adaptUI = nil}
		for i=1, 3, 1 do
			widget.setSliderValue("colorSlider"..i, colorPickerRGB[i])
		end
	end
end

function nCSSetup()
	nCS = {speed = status.statusProperty("apolloSpeed") or 50, control = status.statusProperty("apolloControl") or 50}
	if 100 - nCS.speed ~= nCS.control then
		sb.logInfo("Tamper at noClip parameters")
	end
	widget.setSliderValue("noClipSlider1", nCS.speed)
	widget.setSliderValue("noClipSlider2", nCS.control)
end

function uninit()
	sb.logInfo("Calling uninit!") -- Safe to use upon quitting!!!
end

function update(dt)
	setPermInterfaceColors(altColor, contrast)
	handleSwitches()
	transition(dt)
	routeTransition(dt)
	animatedIntro(dt)
	intro(dt)
	purpleLabelF()
end

function purpleLabelF()
	widget.setText("purpleLabel", "^#"..lineHex..";"..table.concat(historyENV, " / "))
end

function transition(dt)
	if queueTransition ~= "" and queueTransition ~= nil then
		if transitionT[1] < transitionT[2] then
			transitionT[1] = transitionT[1] + dt
		end
		widget.setPosition("transition", {0,inQuad(transitionT[1], 220, -210, transitionT[2])})
		if transitionT[1] > transitionT[2]-0.02 then
			for i=1, #allWidgets, 1 do
				widget.setVisible(allWidgets[i], false)
			end
			for widgetName, widgetConfig in pairs(widgetLayout[queueTransition]) do
				widget.setVisible(widgetName, true)
			end
			currentENV = queueTransition
			queueTransition = ""
			setBaseColors("full")
		end
	else
		widget.setPosition("transition", {0,inQuad(transitionT[1], 220, -210, transitionT[2])})
		if transitionT[1] > 0 then
			transitionT[1] = transitionT[1] - dt
		end
	end
end

function routeTransition(dt)
	for i=1, 3, 1 do
		--sb.logInfo(rTr.panes[tostring(i)]/rTr.panes.maxValue)
		widget.setImage("routePane"..i, "/interface/apollinarisConfig/routePane.png".."?setcolor="..darkerLineHex.."?scalenearest="..(rTr.panes[tostring(i)]/rTr.panes.maxValue)..";1")
		widget.setPosition("routeSubButton"..i, {widget.getPosition("routeButton"..i)[1]+((110+rTr.buttonOffset)*(rTr.panes[tostring(i)]/rTr.panes.maxValue)),60})
		widget.setPosition("routeText"..i, {widget.getPosition("routeButton"..i)[1]+((110+rTr.textOffset)*(rTr.panes[tostring(i)]/rTr.panes.maxValue)),190})
		routeTextF("routeText"..i, (rTr.panes[tostring(i)]/rTr.panes.maxValue), rTr.text[tostring(i)])
		widget.setButtonImages("routeSubButton"..i, createFadingButton("/interface/apollinarisConfig/acceptRouteButton.png", lineHex, rTr.panes[tostring(i)]/rTr.panes.maxValue))
		widget.setText("routeSubButton"..i, "^"..rgbToHex({255,255,255,math.floor(255*(rTr.panes[tostring(i)]/rTr.panes.maxValue))})..";Accept^reset;")
		widget.setPosition("routePane"..i, widget.getPosition("routeButton"..i))
	end
	if rTr.halfWay == false then
		for i=1, 3, 1 do
			rTr.panes[tostring(i)] = math.max(0,rTr.panes[tostring(i)] - dt)
		end
		if rTr.timer[1] < rTr.timer[2] then
			rTr.timer[1] = rTr.timer[1] + dt
			for key, value in pairs(rTr.states[rTr.currState]) do
				widget.setPosition("routeButton"..key, {outSine(rTr.timer[1], rTr.beginPos[tonumber(key)], rTr.states[rTr.currState][key]-rTr.beginPos[tonumber(key)], rTr.timer[2]), 15})
			end
		else
			for key, value in pairs(rTr.states[rTr.currState]) do
				widget.setPosition("routeButton"..key, {rTr.states[rTr.currState][key], 15})
			end
			rTr.halfWay = true
		end
	else
		if rTr.currState ~= "0" then
			for i=1, 3, 1 do
				if tostring(i) == rTr.currState then
					if rTr.panes[rTr.currState] < rTr.panes.maxValue then
						rTr.panes[tostring(i)] = math.min(rTr.panes.maxValue,rTr.panes[tostring(i)] + dt)
					end
				else
					rTr.panes[tostring(i)] = math.max(0,rTr.panes[tostring(i)] - dt)
				end
			end
		end
	end
end

function queueRouteTransition(state)
	--rTr = {timer = {0,1}, currState = "0", halfWay = true, beginPos = {0,0,0}, states = {["1"] = {["1"] = 5, ["2"] = 350, ["3"] = 350}, ["2"] = {["1"] = {["1"] = -110, ["2"] = 5, ["3"] = 350}, ["3"] = {["1"] = -110, ["2"] = -110, ["3"] = 5}, ["0"] = {["1"] = 5, ["2"] = 120, ["3"] = 235}}}}
	if type(state) == "number" or type(state) == "string" then
		rTr.currState= tostring(state)
		rTr.timer[1] = 0
		rTr.halfWay = false
		for i=1, 3, 1 do
			rTr.beginPos[i] = widget.getPosition("routeButton"..i)[1]
		end
	else
		sb.logWarn("Route transition invalid type")
	end
end

function routeTextF(widgetName, perc, text)
	local s = string.split(text, "\n")
	local sT = ""
	for i=1, #s, 1 do
		if i ~= #s then
			sT = sT..string.sub(s[i], 0, math.ceil(string.len(s[i])*perc)).."\n"
		else
			sT = sT..string.sub(s[i], 0, math.ceil(string.len(s[i])*perc))
		end
	end
	widget.setText(widgetName, sT)
end

function createFadingButton(img, color, perc) -- Give this a value between 0 and 1 for perc!!!
	local thing = {
		base = img.."?setcolor="..color.."?multiply=FF"..rgbToHex({255,255,math.floor(255*perc)}),
		hover = img.."?setcolor="..color.."?brightness=10".."?multiply=FF"..rgbToHex({255,255,math.floor(255*perc)}),
		pressed = img.."?setcolor="..color.."?brightness=-10".."?multiply=FF"..rgbToHex({255,255,math.floor(255*perc)}),
		disabled = img.."?setcolor="..color.."?brightness=-40".."?multiply=FF"..rgbToHex({255,255,math.floor(255*perc)})
	}
	return thing
end

function createButtonColors(img, color, multiply, saturation)
	multiply = multiply or "FFFFFF"
	saturation = saturation or 0
	local thing = {
		base = img.."?setcolor="..color.."?multiply="..multiply.."?saturation="..saturation,
		hover = img.."?setcolor="..color.."?brightness=8".."?multiply="..multiply.."?saturation="..saturation,
		pressed = img.."?setcolor="..color.."?brightness=-8".."?multiply="..multiply.."?saturation="..saturation,
		disabled = img.."?setcolor="..color.."?brightness=-40".."?multiply="..multiply.."?saturation="..saturation
	}
	return thing
end

function queueTransitionF(state)
	if type(state) == "string" then
		queueTransition= state
		transitionT[1] = 0
		if historyENV[#historyENV] ~= nil then 
			if historyENV[#historyENV] ~= state then
				if inNormalTable(historyENV, state) == nil then
					table.insert(historyENV, state)
				else
					for i=#historyENV, inNormalTable(historyENV, state)+1, -1 do
						table.remove(historyENV, i)
					end
				end
			end
		else
			table.insert(historyENV, state)
		end
	end
end

function inNormalTable(t, itemo)
	if type(t) == "table" then
		for i=1, #t, 1 do
			if t[i] == itemo then
				return i
			end
		end
	end
end

function colorLogic(arg1, arg2)
	if arg1 == true then
		return arg2
	else
		return false
	end
end
-- RGB utils 

function hexToRGB(_hex)
	if type(_hex) == "string" then
		local h = _hex
		local r, g, b = 0, 0, 0
		if h:len() == 6 then
			local red = h:sub(1, 2)
			local green = h:sub(3, - 3)
			local blue = h:sub( - 2, - 1)
			r = rawHexToDec(red)
			g = rawHexToDec(green)
			b = rawHexToDec(blue)
			return {r, g, b}
		elseif h:len() == 8 then
			return {0, 0, 0}
		end
	else
		return {0, 0, 0}
	end
end

function rawHexToDec(_hex)
	if type(_hex) == "string" then
		local h = _hex:lower()
		local charray = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
		local total = 0
		for i = 1, h:len(), 1 do
			local c = h:sub(h:len() - i + 1, - 1 * i)
			for v, x in ipairs(charray) do
				if c == x then
					total = total + ((v - 1) * 16 ^ (i - 1))
				end
			end
		end
		return total
	else
		return 0
	end
end

function rgbToHex(rgb)
	local stringo = ""
	local function hexConverter(input)
		local hexCharacters = '0123456789abcdef'
		local output = ''
		while input > 0 do
			local mod = math.fmod(input, 16)
			output = string.sub(hexCharacters, mod+1, mod+1) .. output
			input = math.floor(input / 16)
		end
		if output == '' then
			output = '0'
		end
		if string.len(output) == 1 then 
			output = "0"..output
		end
		return output
	end
	for i=1, #rgb, 1 do
		stringo = stringo..hexConverter(math.max(0,math.min(rgb[i],255)))
	end
	return stringo
end

function string.split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end







-- Callbacks








function button1Open()
	sb.logInfo("You pressed the 1")
end

function button2Open()
	--sb.logInfo("You pressed the 2")
	queueTransitionF("character")
end

function button3Open()
	sb.logInfo("You pressed the 3")
end

function button4Open()
	sb.logInfo("You pressed the 4")
end

function homeButtonOpen()
	if currentENV ~= "tutorial" then
		queueTransitionF("mainMenu")
	end
end

function settingsButton()
	queueTransitionF("settings")
end

function settingsButton1Open()
	sb.logInfo("You pressed the 1")
	queueTransitionF("noClip")
end

function noClipSlider1Callback()
	nCS.speed = widget.getSliderValue("noClipSlider1")
	widget.setSliderValue("noClipSlider2", 100-nCS.speed)
	nCS.control = widget.getSliderValue("noClipSlider2")
end

function noClipSlider2Callback()
	nCS.control = widget.getSliderValue("noClipSlider2")
	widget.setSliderValue("noClipSlider1", 100-nCS.control)
	nCS.speed = widget.getSliderValue("noClipSlider1")
end

function noClipAcceptCallback()
	if (100 - nCS.speed == nCS.control) and (100- nCS.control == nCS.speed) then
		status.setStatusProperty("apolloSpeed", nCS.speed)
		status.setStatusProperty("apolloControl", nCS.control)
		world.sendEntityMessage(player.id(), "reloadNCS")
		queueTransitionF("settings")
	else
		sb.logInfo("Tamper at accept noClip")
	end
end

function settingsButton2Open()
	queueTransitionF("setup")
end

function setupButton1Open()
	queueTransitionF("color")
end

function setupButton2Open()
	queueTransitionF("route")
end

function setupButton3Open()
	if colorPick.done then
		for i=1, #colorPick.color, 1 do
			if checkBoundry({math.abs(diff), 255+diff}, colorPick.color[i]) == 0 then
				colorPick.color[i] = math.abs(diff)
				sb.logWarn("Underflow at "..i..", changing to "..math.abs(diff))
			end
			if checkBoundry({math.abs(diff), 255+diff}, colorPick.color[i]) == 2 then
				colorPick.color[i] = 255+diff
				sb.logWarn("Overflow at "..i..", changing to "..(255+diff))
			end
		end
		status.setStatusProperty("apolloColor", rgbToHex(colorPick.color))
		status.setStatusProperty("apolloAdaptUI", switches.colorUIAdapt)
		world.sendEntityMessage(player.id(), "reloadColors")
		init()
	else
		queueTransitionF("mainMenu")
	end
end

function colorUIAdaptOpen()
	simpleSwitch("colorUIAdapt")
end

function simpleSwitch(widgetName)
	if switches[widgetName] ~= nil then
		if switches[widgetName] == true then
			switches[widgetName] = false
		else
			switches[widgetName] = true
		end
	else
		sb.logError("Simple switch error: "..widgetName.." is not in the \"switches\" database.")
	end
end

function colorAcceptOpen()
	colorPick.done = true
	colorPick.color = colorPickerRGB
	if status.statusProperty("apolloSetup") == nil then
		queueTransitionF("route")
	else
		queueTransitionF("setup")
	end
	sb.logInfo(sb.printJson(colorPick))
end

function colorSlider1Callback()
	colorPickerRGB[1] = widget.getSliderValue("colorSlider1")
	widget.setImage("colorLookup", "/interface/apollinarisConfig/colorPick.png".."?setcolor="..rgbToHex(colorPickerRGB))
end

function colorSlider2Callback()
	colorPickerRGB[2] = widget.getSliderValue("colorSlider2")
	widget.setImage("colorLookup", "/interface/apollinarisConfig/colorPick.png".."?setcolor="..rgbToHex(colorPickerRGB))
end

function colorSlider3Callback()
	colorPickerRGB[3] = widget.getSliderValue("colorSlider3")
	widget.setImage("colorLookup", "/interface/apollinarisConfig/colorPick.png".."?setcolor="..rgbToHex(colorPickerRGB))
end

function setHexColor()
	if string.len(widget.getText("colorHexText")) == 6 then
		widget.setImage("colorLookup", "/interface/apollinarisConfig/colorPick.png".."?setcolor="..widget.getText("colorHexText"))
		local colorT = hexToRGB(widget.getText("colorHexText"))
		colorPickerRGB = colorT
		widget.setSliderValue("colorSlider1", colorT[1])
		widget.setSliderValue("colorSlider2", colorT[2])
		widget.setSliderValue("colorSlider3", colorT[3])
		widget.setText("colorHexText", "")
	end
end

function routeButton1Callback()
	if rTr.currState == "1" then
		queueRouteTransition(0)
	else
		queueRouteTransition(1)
	end
end

function routeButton2Callback()
	if rTr.currState == "2" then
		queueRouteTransition(0)
	else
		queueRouteTransition(2)
	end
end

function routeButton3Callback()
	if rTr.currState == "3" then
		queueRouteTransition(0)
	else
		queueRouteTransition(3)
	end
end

function routeSubButton1Callback()
	if status.statusProperty("apolloSetup") == nil or debug then
		if colorPick.done then
			status.setStatusProperty("apolloColor", rgbToHex(colorPick.color))
			status.setStatusProperty("apolloAdaptUI", colorPick.adaptUI)
			status.setStatusProperty("apolloSetup", "attack")
		else
			status.setStatusProperty("apolloColor", "9E9E9E")
			status.setStatusProperty("apolloAdaptUI", true)
		end
		init()
	end
end

function routeSubButton2Callback()
	if status.statusProperty("apolloSetup") == nil or debug then
		if colorPick.done then
			status.setStatusProperty("apolloColor", rgbToHex(colorPick.color))
			status.setStatusProperty("apolloAdaptUI", colorPick.adaptUI)
			status.setStatusProperty("apolloSetup", "defense")
		else
			status.setStatusProperty("apolloColor", "9E9E9E")
			status.setStatusProperty("apolloAdaptUI", true)
		end
		init()
	end
end

function routeSubButton3Callback()
	if status.statusProperty("apolloSetup") == nil or debug then
		if colorPick.done then
			status.setStatusProperty("apolloColor", rgbToHex(colorPick.color))
			status.setStatusProperty("apolloAdaptUI", colorPick.adaptUI)
			status.setStatusProperty("apolloSetup", "support")
		else
			status.setStatusProperty("apolloColor", "9E9E9E")
			status.setStatusProperty("apolloAdaptUI", true)
		end
		init()
	end
end

function settingsButton3Open()
	queueTransitionF("contact")
end

function settingsButton4Open()
	sb.logInfo("You pressed the 4")
end


-- Letters, fuck me this is gonna take a while

function setupIntro()
	cd = {
		done = false,
		x = outCubic,
		title = "AETERNUM APOLLINARIS VO.2",
		interfaceTitle = "Aeternum Apollinaris",
		displayTitle = "",
		indents = {},
		timer = 0,
		currLetter = 1,
		ratio = {1,1.5},
		size = 12,
		basePos = {5,195},
		basePosRef = 0,
		space = 5,
		stageTime = 0.07,
		lineWidth = 1,
		lineColor = {255, 255, 255, 255},
		lineColorRef = 0,
		set = {
			["A"] = {{0.5,1}, {1,0}},
			["E"] = {{1,0}, {0,0}, {0,0.5}, {1, 0.5}, {0,0.5}, {0,1}, {1,1}}, 
			["T"] = {{0.5,0,"hid"},{0.5, 1}, {0,1}, {1,1}}, 
			["R"] = {{0,1}, {1,0.75}, {0,0.5}, {1,0}},
			["N"] = {{0,1}, {1,0}, {1,1}},
			["U"] = {{0,1}, {0,0}, {1,0}, {1,1}},
			["M"] = {{0,1}, {0.5,0.5}, {1,1}, {1,0}},
			["P"] = {{0,1}, {1,0.75}, {0,0.5}},
			["O"] = {{0,1}, {1,1}, {1,0}, {0,0}},
			["L"] = {{0,1}, {0,0}, {1,0}},
			["I"] = {{0.5,0,"hid"},{0.5,1}},
			["S"] = {{1,0}, {1,0.5}, {0,0.5}, {0,1}, {1,1}},
			["V"] = {{0,1,"hid"}, {0.5,0}, {1,1}},
			["1"] = {{0,0.75,"hid"}, {0.5,1}, {0.5,0}},
			["2"] = {{0,1,"hid"}, {1,1}, {1,0.5}, {0, 0.5}, {0,0}, {1,0}},
			["."] = {{0.25,0,"hid"},{0.5,0}, {0.5,0.25}, {0.25,0.25}, {0.25,0}}
		},
		laserVec = {0,0},
		textComplete = false,
		textShiftTimer = {0,0.75},

		center = {175, 105},
		radius = 95,
		geometryTimer = {constant = {0,1}, modular = {0,1}},
		shockwave = {
			pos = {0,0}, 
			minSize = 0, 
			maxSize = 0, 
			t = {}, 
			velocity = 20, 
			timer = 0, 
			interval = math.pi
		}
	}
	cd.title, cd.indents = handleSpaceDel(cd.title)
	cd.basePos[2] = cd.basePos[2] - cd.ratio[2]*cd.size
	cd.basePosRef = cd.basePos[1]
	cd.lineColorRef = cd.lineColor[4]
	introCanvas = widget.bindCanvas("introCanvas")
	local canvSize = introCanvas:size()
	cd.shockwave.pos = {canvSize[1]/2, canvSize[2]/2-5} -- have to take into accounts the headers on the top
	cd.shockwave.minSize = calculateMaxSize((canvSize[2]/2-5)/4, 1.33, canvSize[2]/2-5)
	cd.shockwave.maxSize = math.sqrt((canvSize[1]/2)^2+(canvSize[2]/2)^2)
	sb.logInfo(sb.printJson(cd.shockwave))
end

-- Laser engraving effect

function introCanvasClickEvent(position, button, isButtonDown)
	cd.done = true
	if status.statusProperty("apolloSetup") ~= nil then
		queueTransitionF("mainMenu")
	else
		queueTransitionF("color")
	end
end

function intro(dt)
	if currentENV == "intro" and cd.done == false then
		introCanvas:clear()
		widget.setText("titleLabel", "^#"..darkerLineHex..";".. cd.displayTitle)
		if cd.textComplete == false then
			if cd.currLetter - 1 ~= 0 then
				for i=1, cd.currLetter-1, 1 do
					local indent = checkBoundry(cd.indents, i)
					local nrIndents= 0
					if cd.indents[indent] ~= nil then
						nrIndents = cd.indents[indent]-1
					else
						nrIndents = 0
					end
					drawLetter(
						{
							cd.basePos[1]+(cd.size*cd.ratio[1]+cd.space)*(math.max(0,i-1-(nrIndents or 0))),
							cd.basePos[2]-(cd.size*cd.ratio[2]+cd.space)*indent
						},
						true,
						cd.set[cd.title:sub(i,i)]--[[ or sb.logError("No set for "..cd.title:sub(i,i)) ]],
						0,
						{stageTime = cd.stageTime, x = cd.x, ratio = cd.ratio, size = cd.size, lineColor = cd.lineColor, lineWidth = cd.lineWidth, canvas = introCanvas}
					)
				end
			end
			local indent = checkBoundry(cd.indents, cd.currLetter)
			local nrIndents= 0
			if cd.indents[indent] ~= nil then
				nrIndents = cd.indents[indent]-1
			else
				nrIndents = 0
			end
			if drawLetter(
				{
					cd.basePos[1]+(cd.size*cd.ratio[1]+cd.space)*(math.max(0,cd.currLetter-1-(nrIndents or 0))),
					cd.basePos[2]-(cd.size*cd.ratio[2]+cd.space)*indent
				},
				false,
				cd.set[cd.title:sub(cd.currLetter,cd.currLetter)]--[[  or sb.logError("No set for "..cd.title:sub(cd.currLetter,cd.currLetter)) ]],
				cd.timer,
				{stageTime = cd.stageTime, x = cd.x, ratio = cd.ratio, size = cd.size, lineColor = cd.lineColor, lineWidth = cd.lineWidth, canvas = introCanvas}
			) == true then
				cd.timer = 0
				cd.currLetter = cd.currLetter + 1
			end
			cd.timer = cd.timer + dt
			cd.displayTitle = cd.interfaceTitle:sub(0,math.ceil(cd.interfaceTitle:len()*cd.currLetter/cd.title:len()))
			if cd.title:sub(cd.currLetter,cd.currLetter) ~= "" then
				introCanvas:drawLine({0,200}, cd.laserVec, cd.lineColor, cd.lineWidth*0.8)
				introCanvas:drawLine({350,200}, cd.laserVec, cd.lineColor, cd.lineWidth*0.8)
				introCanvas:drawLine({0,10}, cd.laserVec, cd.lineColor, cd.lineWidth*0.8)
				introCanvas:drawLine({350,10}, cd.laserVec, cd.lineColor, cd.lineWidth*0.8)
			else
				cd.basePos[1] = cd.x(cd.textShiftTimer[1], cd.basePosRef, cd.basePosRef*3-cd.basePosRef, cd.textShiftTimer[2])
				cd.lineColor[4] = cd.x(cd.textShiftTimer[1], cd.lineColorRef, -cd.lineColorRef, cd.textShiftTimer[2])
				cd.textShiftTimer[1] = math.min(cd.textShiftTimer[1]+dt,cd.textShiftTimer[2])
				if cd.textShiftTimer[1] == cd.textShiftTimer[2] then
					cd.textComplete = true
					cd.timer = 0
				end
			end
		else
			-- Supa geometry
			cd.timer = cd.timer + dt
			recursiveMadness(cd.shockwave.pos, 25, (introCanvas:size()[2]/2-5)/3, 1.33, (introCanvas:size()[2]/2-5), cd.timer, math.pi/4, introCanvas, {255,255,255}, cd.lineWidth)
			handleShockwaves(dt,cd.shockwave, cd)
		end
	end
end

function drawLetter(pos, isComplete, set, timer, params) -- requires stageTime, x, ratio (x,y), size, lineColor, lineWidth, canvas
	if pos ~= nil and isComplete ~= nil and set ~= nil then
		if isComplete == false then
			local boundry = {}
			for i=1, #set, 1 do
				table.insert(boundry, i*params.stageTime)
			end
			local r = checkBoundry(boundry, timer)
			for i=1, #set, 1 do
				if r>=i then
					if r==i then
						local lastPos = set[i-1] or {0,0}
						local updatePos = {
							params.x(
								timer - (r*params.stageTime), 
								pos[1]+lastPos[1]*(params.ratio[1]*params.size), 
								pos[1]+set[i][1]*(params.ratio[1]*params.size)-(pos[1]+lastPos[1]*(params.ratio[1]*params.size)), 
								params.stageTime
							),
							params.x(
								timer - (r*params.stageTime), 
								pos[2]+lastPos[2]*(params.ratio[2]*params.size), 
								pos[2]+set[i][2]*(params.ratio[2]*params.size)-(pos[2]+lastPos[2]*(params.ratio[2]*params.size)), 
								params.stageTime
							)
						}
						cd.laserVec = updatePos
						local color = {}
						if #set[i] == 3 then
							color = {255,255,255,0}
						else
							color = params.lineColor
						end
						params.canvas:drawLine({pos[1]+lastPos[1]*(params.ratio[1]*params.size),pos[2]+lastPos[2]*(params.ratio[2]*params.size)}, updatePos, color, params.lineWidth)
					else
						local lastPos = set[i-1] or {0,0}
						local finishPos = {
							pos[1]+set[i][1]*(params.ratio[1]*params.size),
							pos[2]+set[i][2]*(params.ratio[2]*params.size)
						}
						local color = {}
						if #set[i] == 3 then
							color = {255,255,255,0}
						else
							color = params.lineColor
						end
						params.canvas:drawLine({pos[1]+lastPos[1]*(params.ratio[1]*params.size),pos[2]+lastPos[2]*(params.ratio[2]*params.size)}, finishPos, color, params.lineWidth)
					end
				end
			end
			if timer > boundry[#boundry]+params.stageTime then
				return true
			end
		else
			for i=1, #set, 1 do
				local lastPos = set[i-1] or {0,0}
				local finishPos = {
					pos[1]+set[i][1]*(params.ratio[1]*params.size),
					pos[2]+set[i][2]*(params.ratio[2]*params.size)
				}
				local color = {}
				if #set[i] == 3 then
					color = {255,255,255,0}
				else
					color = params.lineColor
				end
				params.canvas:drawLine({pos[1]+lastPos[1]*(params.ratio[1]*params.size),pos[2]+lastPos[2]*(params.ratio[2]*params.size)}, finishPos, color, params.lineWidth)
			end
		end
	end
end

function makeRegularShape(t) -- needs radius, color, width, sides, offsetAngle, perc, offset, canvas
	if t.offsetAngle == nil then t.offsetAngle = 0 end
	if t.perc == nil then t.perc = 1 end
	local angleRef = 360 / t.sides
	local baseOffset = -30
	t.perc = math.min(t.perc,1)
	for i=1, t.sides, 1 do
		t.canvas:drawLine(circle(t.offset, t.radius, i*angleRef+baseOffset+t.offsetAngle), circle(t.offset, t.radius, (i+t.perc)*angleRef+baseOffset+t.offsetAngle), t.color, t.width)
	end
end

function circle(refPoint, radius, angle)
	return {refPoint[1]+(radius*math.sin(math.rad(angle))), refPoint[2]+(radius*math.cos(math.rad(angle)))}
end

function recursiveMadness(pos, sides, size, sizeMultiplier, sizeLimit, baseAngle, angleDelayOffset, canvas, color, width)
	if size < sizeLimit then
		local angleRef = 360/sides
		for i=1, sides, 1 do
			canvas:drawLine(
				circle(pos,size,baseAngle*angleRef*i*angleDelayOffset), 
				circle(pos,size,baseAngle*angleRef*(i+1)*angleDelayOffset), 
				color, 
				width
			)
		end
		recursiveMadness(pos, sides, size*sizeMultiplier, sizeMultiplier, sizeLimit,baseAngle, angleDelayOffset^2, canvas, color, width)
	else
		return
	end
end

function handleShockwaves(dt,t, adT)
	for i=#t.t,1,-1 do
		if t.t[i] > t.maxSize then
			table.remove(t.t, i)
		else
			t.t[i] = t.t[i] + 1
		end
	end
	if t.timer == 0 then
		table.insert(t.t, t.minSize)
		t.timer = t.interval
	else
		t.timer = math.max(0, t.timer-dt)
	end
	for i, value in ipairs(t.t) do
		recursiveShockwave(t.pos, value, {255,255,255}, adT.lineWidth, introCanvas)
	end
end

function recursiveShockwave(pos, size, color, width, canvas)
	if width == 0 then
		return -- needs radius, color, width, sides, offsetAngle, perc, offset, canvas
	else
		makeRegularShape({offset = pos, sides = 50, radius = size, color = color, width = width, canvas = canvas})
		recursiveShockwave(pos, size-1, color, math.max(0,width-0.2), canvas)
	end
end

function calculateMaxSize(baseSize, multiplier, maxSize)
	while baseSize >= maxSize do
		baseSize = baseSize*multiplier
	end
	return baseSize
end

-- End of intro shit

function checkBoundry(t, num)
	if type(t) == "table" and type(num) == "number" then
		if #t > 0 then
			local r = 0
			for i=1, #t, 1 do
				if num >= t[i] then
					r = r+1
				else
					return r
				end
			end
			return r
		else
			return 0
		end
	else
		sb.logError("boundry check failed")
		return false
	end
end

function handleSpaceDel(str)
	local t = {}
	for i=1, str:len(), 1 do
		if str:sub(i,i) == " " then
			table.insert(t,i)
		end
	end
	str = str:gsub(" ", "")
	for i=1, #t, 1 do
			t[i] = t[i] - (i-1)
	end
	return str, t
end

-- Do the initial opening of the interface and the zigzak line thing

function setupAi()
	ai = {
		x = outQuad,
		timer = 0,
		stageTimers = {0.75,1.25,3.5},
		stage = 0,
		widgetPositions = {
			["actualHeader"] = {120,210},
			["actualFooter"] = {100,0},
			["purple"] = {110, 200},
			["purpleLabel"] = {111, 201},
			["titleLabel"] = {121, 211},
			["close"] = {122, 212},
			["settings"] = {122, 212},
			["homeButton"] = {112, 202},
		},
		desiredLineWidth = 300,
		lineTimeOffset = 0.3,
		done = false
	}
	animatedIntroCanvas = widget.bindCanvas("animatedIntroCanvas")
end

function animatedIntro(dt)
	if currentENV == "open" and ai.done == false then
		animatedIntroCanvas:clear()
		ai.stage = checkBoundry(ai.stageTimers, ai.timer)
		local properTimer = ai.timer - (ai.stageTimers[ai.stage] or 0)
		local properEnd = (ai.stageTimers[ai.stage+1] or 0) - (ai.stageTimers[ai.stage] or 0)
		if ai.stage == 0 then
			widget.setImage("actualBody", "/interface/apollinarisConfig/thingy.png?setcolor=616161?multiply=FFFFFF00")
			for name, set in pairs(ai.widgetPositions) do
				widget.setPosition(name, {
					widget.getPosition(name)[1],
					set[1]
				})
			end
			local hex = math.floor(ai.x(properTimer, 0, 255, properEnd))
			altColor = rgbToHex({255,255,255,hex})
		elseif ai.stage == 1 then
			for name, set in pairs(ai.widgetPositions) do
				widget.setPosition(name, {
					widget.getPosition(name)[1],
					ai.x(properTimer, set[1], set[2]-set[1], properEnd)
				})
			end
		elseif ai.stage == 2 then
			for name, set in pairs(ai.widgetPositions) do
				widget.setPosition(name, {
					widget.getPosition(name)[1],
					set[2]
				})
			end
			contrast = ai.x(properTimer, -100, 100, properEnd)
			local ar = {{0.125,1}, {0.25, 0}, {0.375, 1}, {0.5, 0}, {0.625, 1}, {0.75, 0}, {0.875, 1}, {0.999,0}}
			drawLetter({0,10}, false, ar, properTimer, {stageTime = properEnd/#ar*ai.lineTimeOffset, x = linear, ratio = {1.9444,1}, size = 190, lineColor = {255,255,255}, lineWidth = properTimer*(ai.desiredLineWidth/properEnd), canvas = animatedIntroCanvas}) -- requires stageTime, x, ratio (x,y), size, lineColor, lineWidth,
			widget.setImage("actualBody", "/interface/apollinarisConfig/thingy.png?setcolor=616161?multiply=FFFFFF"..rgbToHex({math.floor(ai.x(properTimer, 0, 255, properEnd))}))
		elseif ai.stage == 3 then
			queueTransitionF("intro")
			ai.done = true
			cd.laserVec = {0,0}
			widget.setImage("actualBody", "/interface/apollinarisConfig/thingy.png?setcolor=616161")
			altColor = nil
			contrast = 0
		end
		ai.timer = ai.timer + dt
	end
end