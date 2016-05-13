local TEquationV = {Type = "Equation Data"}
local TEquationVMT = {__index = TEquationV}

local TEquationA = {Type = "Equation Arguments"}
local TEquationAMT = {__index = TEquationA}

local TEquation = {Type = "Equation"}
local TEquationMT = {__index = TEquation}

local Create = {}

function Create:__index(Name)
	 return TEquationV.new(Name)
end

TEquation.Operators = {
	["%"] = function (A, B) return A % B end,
	["^"] = function (A, B) return A ^ B end,
	["*"] = function (A, B) return A * B end,
	["/"] = function (A, B) return A / B end,
	["+"] = function (A, B) return A + B end,
	["-"] = function (A, B) if A then return A - B end return -B end,
	["call"] = function (A, B) return A(unpack(B)) end,
}

function TEquationVMT:__call(...)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = TEquationA.new(...)
	Equation.Operation = "call"

	return Equation
end

function TEquationVMT:__add(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "+"

	return Equation
end

function TEquationVMT:__sub(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "-"

	return Equation
end

function TEquationVMT:__unm()
	local Equation = TEquation.new()
	Equation.B = self
	Equation.Operation = "-"

	return Equation
end

function TEquationVMT:__mul(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "*"

	return Equation
end

function TEquationVMT:__div(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "/"

	return Equation
end

function TEquationVMT:__pow(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "^"

	return Equation
end

function TEquationVMT:__mod(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "%"

	return Equation
end

function TEquationVMT:__tostring()
	return self.Name or ""
end

function TEquationVMT:__eq(Object)
	if type(Object) == "table" then
		return self.Name == Object.Name
	end
end

function TEquationV.new(Name)
	return setmetatable({Name = Name}, TEquationVMT)
end

function TEquationV:Evaluate(Table)
	return Table[self.Name]
end

function TEquationA.new(...)
	return setmetatable({...}, TEquationAMT)
end

function TEquationA:Evaluate(Table)
	local Arguments = {}
	for Index, Argument in pairs(self) do
		if type(Argument) == "table" and (getmetatable(Argument) == TEquationAMT or getmetatable(Argument) == TEquationVMT) then
			table.insert(Arguments, Argument:Evaluate(Table))
		else
			table.insert(Arguments, Argument)
		end
	end
	return Arguments
end

function TEquationMT:__call(Object, ...)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = TEquationA.new(...)
	Equation.Operation = "call"

	return Equation
end

function TEquationMT:__add(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "+"

	return Equation
end

function TEquationMT:__sub(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "-"

	return Equation
end

function TEquationMT:__unm()
	local Equation = TEquation.new()
	Equation.B = self
	Equation.Operation = "-"
	if self.Type == "Equation" then
		self.Parenthesis = true
	end

	return Equation
end

function TEquationMT:__mul(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "*"

	if type(self) ~= "table" then
		self = Object
	end

	if self.Operation == "+" or self.Operation == "-" then
		self.Parenthesis = true
	end

	return Equation
end

function TEquationMT:__div(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "/"

	if type(self) ~= "table" then
		self = Object
	end

	if self.Operation == "+" or self.Operation == "-" then
		self.Parenthesis = true
	end

	return Equation
end

function TEquationMT:__pow(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "^"
	self.Parenthesis = true

	return Equation
end

function TEquationMT:__mod(Object)
	local Equation = TEquation.new()
	Equation.A = self
	Equation.B = Object
	Equation.Operation = "%"

	if type(self) ~= "table" then
		self = Object
	end

	if self.Operation == "^" or self.Operation == "-" or self.Operation == "*" or self.Operation == "/" then
		self.Parenthesis = true
	end

	return Equation
end

function TEquationMT:__tostring()
	if self.Parenthesis then
		if self.A then
			return "(" .. tostring(self.A) .. self.Operation .. tostring(self.B) .. ")"
		end
		return "(" .. self.Operation .. tostring(self.B) .. ")"
	end
	if self.A then
		return tostring(self.A) .. self.Operation .. tostring(self.B)
	end
	return self.Operation .. tostring(self.B)
end

function TEquationMT:__eq(Object)
	if type(Object) == "table" then
		if self.Operator ~= Object.Operator or (self.A and not Object.A) or (not self.A and Object.A) then
			return false
		end
		return self.A == Object.A and self.B == Object.B
	end
end

function TEquation.new(Object)
	if type(Object) == "string" then
		local Function, Error = loadstring("return "..Object)
		if Error then
			return nil, Error
		end

		setfenv(Function, setmetatable({}, Create))
		local Success, Equation = pcall(Function)
		if not Success then
			return nil, Equation
		end

		return Equation
	end

	return setmetatable({}, TEquationMT)
end; Equation = TEquation.new

function TEquation:Evaluate(Table)
	local A = self.A
	if type(A) == "table" and (getmetatable(A) == TEquationVMT or getmetatable(A) == TEquationAMT) then
		A = A:Evaluate(Table)
	end

	local B = self.B
	if type(B) == "table" and (getmetatable(B) == TEquationVMT or getmetatable(B) == TEquationAMT) then
		B = B:Evaluate(Table)
	end

	return self.Operators[self.Operation](A, B)
end
