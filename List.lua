local TLink = {}
local TLinkMT = {__index = TLink}

function TLink.new(List, Value, Prev, Next)
	local Link = {
		List = List,
		Value = Value,
		Previous = Prev,
		Next = Next,
	}
	if Prev then
		Prev.Next = Link
	end
	if Next then
		Next.Prev = Link
	end
	return setmetatable(Link, TLinkMT)
end

function TLink:Remove()
	if self.List.First == self then
		if self.List.Last == self then
			self.List.First = nil
			self.List.Last = nil
		else
			self.List.First = self.Next
			self.List.First.Previous = nil
		end
	elseif self.List.Last == self then
		self.List.Last = self.Previous
		self.List.Last.Next = nil
	else
		local Next = self.Next
		local Previous = self.Previous
		
		if Next then
			Next.Previous = Previous
		end
		if Previous then
			Previous.Next = Next
		end
	end
end

function TLink:AddRight(Item)
	return TLink.new(self.List, Item, self, self.Next)
end

local TList = {}
local TListMT = {__index = TList}

function TList.new(...)
	local List = setmetatable({}, TListMT)
	local Args = {...}

	for Index, Item in pairs(Args) do
		List:Add(Item)
	end
	
	return List
end

function TList:Add(Item)
	if self.First and self.Last then
		local Link = TLink.new(self, Item, self.Last)
		self.Last = Link
		return Link
	else
		local Link = TLink.new(self, Item)
		self.First = Link
		self.Last = Link
		return Link
	end
end

function TList:RemoveLink(Link)
	if self.First == Link then
		if self.Last == Link then
			self.First = nil
			self.Last = nil
		else
			self.First = self.First.Next
			self.First.Previous = nil
		end
	elseif self.Last == Link then
		self.Last = Link.Previous
		self.Last.Next = nil
	else
		local Next = Link.Next
		local Previous = Link.Previous
		
		Next.Previous = Previous
		Previous.Next = Next
	end
end

function TList:ForEach()
	local Link = {Next = self.First}
	
	return function ()
		Link = Link.Next
		if Link then
			return Link, Link.Value
		end
	end
end

List = TList.new