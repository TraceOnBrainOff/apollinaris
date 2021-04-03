Color = {}
Color.__index = Color

--[[
    palette:
    {
        Star::Color lightest B
        Star::Color 9
        Star::Color,7
        Star::Color,5
        Star::Color darkest3
        {187,187,187},
        {153,153,153},
        {119,119,119},
        {119,119,119},
        {85,85,85},
        {51,51,51}
    }
]]

function Color:assign()
    self = {}
    setmetatable(self, Color)
    self:updatePalette()
    return self
end

function Color:updatePalette()
    local defaultPalette = table.copy(default_settings.default_color)
    status.setStatusProperty("apolloColor", defaultPalette) -- debug
    self.originalPalette = status.statusProperty("apolloColor", defaultPalette)
    self.palette = {}
    if #defaultPalette == 2 then
        self.palette.rgb = self:gradient(6)
    elseif #defaultPalette == 6 then
        self.palette.rgb = defaultPalette
    else
        error("Incorrect data in default_colors.config")
    end
    self.palette.hex = {}
    for i, rgb in ipairs(self.palette.rgb) do
        table.insert(self.palette.hex, Color.rgb2hex(rgb))
    end
end

function Color:gradient(amount) -- for things having less or more than 6 colors or extrapolating
    local rgbPalette = {self.originalPalette[1], self.originalPalette[2]} -- lightest to darkest
    local gradient = {rgbPalette[1]}
    local steps = {}
    for i, hex in ipairs(self.originalPalette[1]) do -- does for r, g, b
        table.insert(steps, (rgbPalette[2][i]-rgbPalette[1][i])/(amount-1))
    end
    for i=1, amount-2 do --minus 2 as im padding this at the beginning and end 
        local newColor = {}
        for j=1, 3 do
            table.insert(newColor,math.floor(rgbPalette[1][j] + steps[j]*i))
        end
        table.insert(gradient, newColor) 
    end
    table.insert(gradient, rgbPalette[2])
    return gradient
end

function Color.invert(rgb)
    return util.map(rgb, function(v) return v~0xff end)
end

function Color.rgb2hex(rgb) -- also accepts alpha
    local str = ""
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
		str = str..hexConverter(math.max(0,math.min(rgb[i],255)))
	end
    return str
end

function Color.hex2rgb(hex)
    return {tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))}
end

function Color.hex2rgba(hex)
    return {tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)), tonumber("0x"..hex:sub(7,8))}
end

function Color:hex(i)
    if not i then
        return self.palette.hex
    end
    return self.palette.hex[i]
end

function Color:rgb(i)
    if not i then
        return self.palette.rgb
    end
    return self.palette.rgb[i]
end

function Color:random(hex, amount)
    amount = amount or 6
    local gradient = self:gradient(amount)
    if hex then
        return Color.rgb2hex(gradient[math.random(amount)])
    end
    return gradient[math.random(amount)]
end

function Color.hueShift(input, hueshift) -- RGB only!
	local U = math.cos(hueshift*math.pi/180)
	local W = math.sin(hueshift*math.pi/180)
  
	local ret = {r=0, g=0, b=0}

	ret.r = (0.299+0.701*U+0.168*W)*input.r + (0.587-0.587*U+0.330*W)*input.g + (0.114-0.114*U-0.497*W)*input.b
	ret.g = (0.299-0.299*U-0.328*W)*input.r + (0.587+0.413*U+0.035*W)*input.g + (0.114-0.114*U+0.292*W)*input.b
	ret.b = (0.299-0.3*U+1.25*W)*input.r + (0.587-0.588*U-1.05*W)*input.g + (0.114+0.886*U-0.203*W)*input.b
	return ret
end

function Color.hexFromColorName(name)
    local t = {
        red = "fe4942",
        orange = "feb32f",
        yellow = "feee1e",
        green = "4fe546",
        blue = "2660fe",
        indigo = "4b0181",
        violet = "9e76fc",
        black = "010101",
        white = "fefefe",
        magenta = "dc5cf8",
        darkmagenta = "8e2190",
        cyan = "8e2190",
        darkcyan = "0089a5",
        cornflowerblue = "6495ec",
        gray = "a0a0a0",
        lightgray = "bfbfbf",
        darkgray = "808080",
        darkgreen = "008000",
        pink = "fea2ba"
    }
    return t[name]
end