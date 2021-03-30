-- Bezier
-- https://github.com/nshafer/Bezier

-- The MIT License (MIT)

-- Copyright (c) 2013 Nathan Shafer

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

Bezier = {}
Bezier.__index = Bezier

function Bezier:init()
    local self = {}
    setmetatable(self, Bezier)
	self.points = {}
	self.autoStepScale = 0.1
    return self
end

function Bezier:getPoints()
	return self.points
end

function Bezier:setPoints(points)
	self.points = points
end

function Bezier:setAutoStepScale(scale)
	self.autoStepScale = scale
end

function Bezier:getAutoStepScale()
	return self.autoStepScale
end

function Bezier:pointDistance(p1, p2)
	local dx = p2[1] - p1[1]
	local dy = p2[2] - p1[2]
	return math.sqrt(dx*dx + dy*dy)
end

function Bezier:getLength()
	local length = 0
	local last = nil
	
	for i,point in ipairs(self.points) do
		if last then
			length = length + self:pointDistance(point, last)
		end
		last = point
	end
	
	return(length)
end

-- Estimate number of steps based on the distance between each point/control
-- Inspired by http://antigrain.com/research/adaptive_bezier/
function Bezier:estimateSteps(p1, p2, p3, p4)
	local distance = 0
	if p1 and p2 then
		distance = distance + self:pointDistance(p1, p2)
	end
	if p2 and p3 then
		distance = distance + self:pointDistance(p2, p3)
	end
	if p3 and p4 then
		distance = distance + self:pointDistance(p3, p4)
	end

	return math.max(1, math.floor(distance * self.autoStepScale))
end

-- Bezier functions from Paul Bourke
-- http://paulbourke.net/geometry/bezier/
function Bezier:createQuadraticCurve(p1, p2, p3, steps)
	self.points = {}
	steps = steps or self:estimateSteps(p1, p2, p3)
	for i = 0, steps do
		table.insert(self.points, self:bezier3(p1, p2, p3, i/steps))
	end
end

function Bezier:createCubicCurve(p1, p2, p3, p4, steps)
	self.points = {}
	steps = steps or self:estimateSteps(p1, p2, p3, p4)
	for i = 0, steps do
		table.insert(self.points, self:bezier4(p1, p2, p3, p4, i/steps))
	end
end

function Bezier:bezier3(p1,p2,p3,mu)
	local mum1,mum12,mu2
	local p = {}
	mu2 = mu * mu
	mum1 = 1 - mu
	mum12 = mum1 * mum1
	p[1] = p1[1] * mum12 + 2 * p2[1] * mum1 * mu + p3[1] * mu2
	p[2] = p1[2] * mum12 + 2 * p2[2] * mum1 * mu + p3[2] * mu2
	--p[3] = p1[3] * mum12 + 2 * p2[3] * mum1 * mu + p3[3] * mu2
	
	return p
end

function Bezier:bezier4(p1,p2,p3,p4,mu)
	local mum1,mum13,mu3;
	local p = {}

	mum1 = 1 - mu
	mum13 = mum1 * mum1 * mum1
	mu3 = mu * mu * mu

	p[1] = mum13*p1[1] + 3*mu*mum1*mum1*p2[1] + 3*mu*mu*mum1*p3[1] + mu3*p4[1]
	p[2] = mum13*p1[2] + 3*mu*mum1*mum1*p2[2] + 3*mu*mu*mum1*p3[2] + mu3*p4[2]
	--p[3] = mum13*p1[3] + 3*mu*mum1*mum1*p2[3] + 3*mu*mu*mum1*p3[3] + mu3*p4[3]

	return p	
end

-- Reduce nodes based on Ramer-Douglas-Peucker algorithm
-- http://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
-- Additional help from http://quangnle.wordpress.com/2012/12/30/corona-sdk-curve-fitting-1-implementation-of-ramer-douglas-peucker-algorithm-to-reduce-points-of-a-curve/
function Bezier:reduce(epsilon)
	epsilon = epsilon or .1

	if #self.points > 1 then
		-- Keep first and last
		self.points[1].keep = true
		self.points[#self.points].keep = true

		-- Figure out the rest
		self:douglasPeucker(1, #self.points, epsilon)
	end

	-- Replace point list with only those that are marked to keep
	local old = self.points
	self.points = {}

	for i,point in ipairs(old) do
		if point.keep then
			table.insert(self.points, {point[1], point[2]})
		end
	end
end

function Bezier:douglasPeucker(first, last, epsilon)
	local dmax = 0
	local index = 0

	for i=first+1, last-1 do
		local d = self:pointLineDistance(self.points[i], self.points[first], self.points[last])

		if d > dmax then
			index = i
			dmax = d
		end
	end

	if dmax >= epsilon then
		self.points[index].keep = true

		-- Recursive call
		self:douglasPeucker(first, index, epsilon)
		self:douglasPeucker(index, last, epsilon)
	end
end

function Bezier:pointLineDistance(p, a, b)
	-- calculates area of the triangle
	local area = math.abs(0.5 * (a[1] * b[2] + b[1] * p[2] + p[1] * a[2] - b[1] * a[2] - p[1] * b[2] - a[1] * p[2]))
	-- calculates the length of the bottom edge
	local dx = a[1] - b[1]
	local dy = a[2] - b[2]
	local bottom = math.sqrt(dx*dx + dy*dy)
	-- the triangle's height is also the distance found
	return area / bottom
end

--[[
local bezier = Bezier:init()

local p1 = {50,50}
local p2 = {200,50}
local p3 = {50,200}
local p4 = {200,200}

bezier:createCubicCurve(p1, p2, p3, p4)
bezier:reduce()
local result = bezier:getPoints()
]]