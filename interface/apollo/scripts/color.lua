Color = {}

function Color:new()
    self._index = self

    --local savedColor = status.statusProperty("apolloColor", "E9E9E9") <- this shit's bad. Do an array of two color arrays for lightest/darkest color (GRADIENTS!!!) 
    local savedColor = {{200,200,200}, {30,30,30}}
    local a = {}
    for col=0,3 do
        local color = {}
        for i=1,3 do
            color[i] = savedColor[1][i] + ((savedColor[2][i]-savedColor[1][i])*(col/3)) -- Gradients
        end -- Adding color etc
        a[#a+1] = color
    end
    self.colors = a -- quad array of rgb colors
    return self
end

function Color:lightest()
    return self.colors[1]
end

function Color:light()
    return self.colors[2]
end

function Color:dark()
    return self.colors[3]
end

function Color:darkest()
    return self.colors[4]
end