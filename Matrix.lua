local TMatrix = {}
local TMatrixMT = {__index = TMatrix}

function TMatrixMT:__add(Matrix)
	if type(Matrix) == "table" then
		local Matrix2 = TMatrix.new(1)
		for i = 1, #self do
			Matrix2[i] = self[i] + Matrix[i]
		end
		if self.Extended and Matrix.Extended then
			Matrix2.Extended = TMatrix.new(1)
			for i = 1, #self.Extended do
				Matrix2.Extended[i] = self.Extended[i] + Matrix.Extended[i]
			end
		elseif self.Extended then
			Matrix2.Extended = TMatrix.new(1)
			for i = 1, #self.Extended do
				Matrix2.Extended[i] = Vector(unpack(self.Extended[i]))
			end
		elseif Matrix.Extended then
			Matrix2.Extended = TMatrix.new(1)
			for i = 1, #self.Extended do
				Matrix2.Extended[i] = Vector(unpack(Matrix[i]))
			end
		end
		return Matrix2
	end
end

function TMatrixMT:__sub(Matrix)
	if type(Matrix) == "table" then
		local Matrix2 = TMatrix.new(1)
		for i = 1, #self do
			Matrix2[i] = self[i] - Matrix[i]
		end
		if self.Extended and Matrix.Extended then
			Matrix2.Extended = TMatrix.new(1)
			for i = 1, #self.Extended do
				Matrix2.Extended[i] = self.Extended[i] - Matrix.Extended[i]
			end
		elseif self.Extended then
			Matrix2.Extended = TMatrix.new(1)
			for i = 1, #self.Extended do
				Matrix2.Extended[i] = Vector(unpack(self.Extended[i]))
			end
		elseif Matrix.Extended then
			Matrix2.Extended = TMatrix.new(1)
			for i = 1, #self.Extended do
				Matrix2.Extended[i] = -Matrix[i]
			end
		end
		return Matrix2
	end
end

function TMatrixMT:__mul(Matrix)
	if type(Matrix) == "number" then
		local Matrix2 = TMatrix.new(1)
		for i = 1, #self do
			Matrix2[i] = self[i] * Matrix
		end
		if self.Extended then
			Matrix2.Extended = self.Extended * Matrix
		end
		return Matrix2
	elseif type(Matrix) == "table" then
		local Matrix2 = TMatrix.new(1)
		for y = 1, #self do
			Matrix2[y] = Vector()
			for x = 1, #self[1] do
				local xOffset = math.min(x + 1, #self[1]) - 1
				local yOffset = math.min(y + 1, #self) - 1

				Matrix2[y][x] = Matrix[yOffset][x] * self[y][xOffset] + Matrix[yOffset + 1][x] * self[y][xOffset + 1]
			end
		end
		return Matrix2
	end
end

function TMatrixMT:__eq(Matrix)
	if type(Matrix) == "table" then
		for i = 1, #self do
			if Matrix[i] ~= self[i] then
				return false
			end
		end
		return true
	end
end

function TMatrixMT:__pow(n)
	if type(n) == "number" then
		local Matrix = self
		for i = 1, n - 1 do
			Matrix = Matrix * self
		end
		return Matrix
	end
end

function TMatrixMT:__unm()
	return self * -1
end

function TMatrixMT:__tostring()
	local String = ""
	for i = 1, #self do
		if self.Extended then
			String = String .. tostring(self[i]).."|"..tostring(self.Extended[i]).."\n"
		else
			String = String .. tostring(self[i]).."\n"
		end
	end
	return String:sub(1, -2)
end

function TMatrix.new(Dimension, ...)
	local Matrix = {}
	if type(Dimension) == "table" then
		Matrix = {Dimension, ...}
	elseif type(Dimension) == "number" then
		local VectorDim = {}
		for i = 1, Dimension do
			VectorDim[i] = 0
		end

		for i = 1, Dimension do
			Matrix[i] = Vector(unpack(VectorDim))
		end
	end
	return setmetatable(Matrix, TMatrixMT)
end

function TMatrix.Identity(Width, Height)
	if type(Width) == "table" then
		Height = #Width[1]
		Width = #Width
	elseif not Height then
		Height = Width
	end
	local Matrix = {}
	for y = 1, Height do
		Matrix[y] = Vector()
		for x = 1, Width do
			Matrix[y][x] = 0
		end
	end
	for i = 1, Height do
		if Matrix[i][i] then
			Matrix[i][i] = 1
		else
			break
		end
	end
	return setmetatable(Matrix, TMatrixMT)
end

function TMatrix:Extend(Matrix)
	self.Extended = Matrix
end

function TMatrix:Stagger(Operations)
	local Stagger = TMatrix.new(1)
	for i = 1, #self do
		Stagger[i] = Vector(unpack(self[i]))
	end

	if self.Extended then
		Stagger.Extended = TMatrix.new(1)
		for i = 1, #self.Extended do
			Stagger.Extended[i] = Vector(unpack(self.Extended[i]))
		end
	end

	local Operations = Operations or {}

	for NullNumber = #Stagger, 1, -1 do
		if Stagger[NullNumber][NullNumber] == 0 then
			for i = #Stagger, 1, -1 do
				if Stagger[i][NullNumber] ~= 0 then
					table.insert(Operations, "L"..NullNumber..i)
					local Vector = Stagger[i]
					Stagger[i] = Stagger[NullNumber]
					Stagger[NullNumber] = Vector

					if Stagger.Extended then
						local ExtendedVector = Stagger.Extended[i]
						Stagger.Extended[i] = Stagger.Extended[NullNumber]
						Stagger.Extended[NullNumber] = ExtendedVector
					end

					break
				end
			end
		end
	end

	for i = 1, #Stagger do
		if Stagger[i][i] ~= 0 and Stagger[i][i] ~= 1 and Stagger[i][i] then
			local Divisor = Stagger[i][i]
			if type(Divisor) == "table" then
				Divisor = Divisor:tostring()
			end
			table.insert(Operations, "L"..i.."(1/"..Divisor..")")

			if Stagger.Extended then
				Stagger.Extended[i] = Stagger.Extended[i] / Stagger[i][i]
			end
			Stagger[i] = Stagger[i] / Stagger[i][i]
		end
	end

	for x = 1, #Stagger do
		for y = 1, #Stagger do
			if Stagger[y][x] ~= 0 and Stagger[y][x] and Stagger[x][x] == 1 and x ~= y then
				table.insert(Operations, "L"..y..x.."("..-Stagger[y][x]..")")
				if Stagger.Extended then
					Stagger.Extended[y] = Stagger.Extended[y] - Stagger.Extended[x] * Stagger[y][x]
				end
				Stagger[y] = Stagger[y] - Stagger[x] * Stagger[y][x]
			end
		end
	end

	for i = 1, #Stagger do
		if Stagger[i][i] ~= 0 and Stagger[i][i] ~= 1 and Stagger[i][i] then
			return Stagger:Stagger(Operations)
		end
	end

	return Stagger, Operations
end

function TMatrix:Determinant()
	if #self ~= #self[1] then
		return 0
	elseif #self == 2 then
		return self[1][1] * self[2][2] - self[1][2] * self[2][1]
	end

	local Determinant = 0
	local Sign = 1
	for i = 1, #self do
		local Matrix = TMatrix.new(0)
		local yCount = 0
		for y = 1, #self do
			if y ~= i then
				yCount = yCount + 1
				local MatrixPoints = {}
				for x = 2, #self do
					table.insert(MatrixPoints, self[y][x])
				end
				Matrix[yCount] = Vector(unpack(MatrixPoints))
			end
		end
		Determinant = Determinant + Sign * self[i][1] * Matrix:Determinant()
		Sign = -Sign
	end

	return Determinant
end

function TMatrix:IsInvertible()
	local Determinant = self:Determinant()
	return Determinant ~= 0 and math.abs(Determinant) ~= 1/0
end

function TMatrix:Inverse(Operations, Inverse)
	local Stagger = TMatrix.new(1)
	for i = 1, #self do
		Stagger[i] = Vector(unpack(self[i]))
	end

	if not Inverse then
		Inverse = TMatrix.Identity(#Stagger)
	end

	local Operations = Operations or {}

	for NullNumber = #Stagger, 1, -1 do
		if Stagger[NullNumber][NullNumber] == 0 then
			for i = #Stagger, 1, -1 do
				if Stagger[i][NullNumber] ~= 0 then
					table.insert(Operations, "L"..NullNumber..i)
					local Vector = Stagger[i]
					Stagger[i] = Stagger[NullNumber]
					Stagger[NullNumber] = Vector

					local InverseVector = Inverse[i]
					Inverse[i] = Inverse[NullNumber]
					Inverse[NullNumber] = InverseVector
					break
				end
			end
		end
	end

	for i = 1, #Stagger do
		if Stagger[i][i] ~= 0 and Stagger[i][i] ~= 1 and Stagger[i][i] then
			table.insert(Operations, "L"..i.."(1/"..Stagger[i][i]..")")
			Inverse[i] = Inverse[i] / Stagger[i][i]
			Stagger[i] = Stagger[i] / Stagger[i][i]
		end
	end

	for x = 1, #Stagger do
		for y = 1, #Stagger do
			if Stagger[y][x] ~= 0 and Stagger[y][x] and Stagger[x][x] == 1 and x ~= y then
				table.insert(Operations, "L"..y..x.."("..-Stagger[y][x]..")")
				Inverse[y] = Inverse[y] - Inverse[x] * Stagger[y][x]
				Stagger[y] = Stagger[y] - Stagger[x] * Stagger[y][x]
			end
		end
	end

	for i = 1, #Stagger do
		if Stagger[i][i] ~= 0 and Stagger[i][i] ~= 1 and Stagger[i][i] then
			return Stagger:Inverse(Operations, Inverse)
		end
	end

	return Inverse, Operations
end

function TMatrix:Transpose()
	local Matrix = TMatrix.new(1)
	for x = 1, #self[1] do
		Matrix[x] = Vector()
		for y = 1, #self do
			Matrix[x][y] = self[y][x]
		end
	end
	return Matrix
end

function TMatrix:IsIdempotent()
	return self == self ^ 2
end

function TMatrix:IsInvolutive()
	return self == self:Inverse()
end

function TMatrix:IsSimetric()
	return self:Transpose() == self
end

function TMatrix:IsAntisimetric()
	return self:Transpose() == -self
end

function TMatrix:IsOrtogonal()
	return self:Transpose() == self:Inverse()
end

--[[
Definición 4.5.9 Sea A = (ai,j) ∈ Mn(K). Llamaremos traza de
A, denotada por Tr(A), al n´umero
Pn
i=1 aii, es decir, a la suma de los
elementos de la diagonal principal.
]]
function TMatrix:Traza()
	local Traza = 0
	for i = 1, #self do
		if self[i][i] then
			Traza = Traza + self[i][i]
		else
			break
		end
	end
	return Traza
end

Matrix = TMatrix.new
