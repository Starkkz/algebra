local TVector = {}
local TVectorMT = {__index = TVector}

function TVectorMT:__mul(n)
	if type(n) == "number" then
		local V = TVector.new()
		for i = 1, #self do
			if self[i] ~= 0 then
				V[i] = self[i] * n
			else
				V[i] = 0
			end
		end
		return V
	end
end

function TVectorMT:__div(n)
	if type(n) == "number" then
		local V = TVector.new()
		for i = 1, #self do
			if self[i] ~= 0 then
				V[i] = self[i] / n
			else
				V[i] = 0
			end
		end
		return V
	end
end

function TVectorMT:__add(V)
	if type(V) == "table" then
		local V2 = TVector.new()
		for i = 1, math.max(#self, #V) do
			V2[i] = (self[i] or 0) + (V[i] or 0)
		end
		return V2
	end
end

function TVectorMT:__sub(V)
	if type(V) == "table" then
		local V2 = TVector.new()
		for i = 1, math.max(#self, #V) do
			V2[i] = (self[i] or 0) - (V[i] or 0)
		end
		return V2
	end
end

function TVectorMT:__unm()
	local V = TVector.new()
	for i = 1, #self do
		if self[i] ~= 0 then
			V[i] = -self[i]
		else
			V[i] = 0
		end
	end
	return V
end

function TVectorMT:__mod(n)
	if type(n) == "number" then
		local V = TVector.new()
		for i = 1, #self do
			V[i] = self[i] % n
		end
		return V
	end
end

function TVectorMT:__eq(Vector)
	if type(Vector) == "table" then
		for i = 1, #self do
			if self[i] ~= Vector[i] then
				return false
			end
		end
		return true
	end
end

function TVectorMT:__tostring()
	local String = ""
	for i = 1, #self do
		String = String .. tostring(self[i])..","
	end
	return "("..String:sub(1, -2)..")"
end

function TVector.new(...)
	local Vector = {...}
	
	return setmetatable(Vector, TVectorMT)
end

function TVector:length()
	local Component = 0
	for i = 1, #self do
		Component = Component + self[i] ^ 2
	end
	return math.sqrt(Component)
end

Vector = TVector.new