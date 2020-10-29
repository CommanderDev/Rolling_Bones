local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--[[
    Author: Spynaz
    Description: Library of uncategorized but useful functions
--]]

local Misc = {}

local floor = math.floor

--[[
    Description: Recursively searches for a child

    Parameters:
        instance [Instance]: The instance to search in
        name [string]: The name of the child to find
        (optional) className [string]: The name of the child's class
--]]
function Misc.recursiveFindFirstChild(instance, name, className)
	local chosenOne
	for _, child in ipairs(instance:GetDescendants()) do
		if child.Name == name then
			if className then
				if child:IsA(className) then
					chosenOne = child
					break
				end
			else
				chosenOne = child
				break
			end
		end
	end
	return chosenOne
end

-- Returns the time in minute format (minutes:seconds)
function Misc.minuteFormat(seconds)
	local minutes = floor(seconds / 60)
	seconds = floor(seconds % 60)
	
	if minutes < 10 and seconds >= 10 then
		return "0"..minutes..":"..seconds
	elseif minutes >= 10 and seconds < 10 then
		return minutes..":0"..seconds
	elseif minutes < 10 and seconds < 10 then
		return "0"..minutes..":0"..seconds
	else
		return minutes..":"..seconds
	end
end

-- Returns the time in hour format (hours:minutes:seconds)
function Misc.hourFormat(seconds)
	local hours = floor(seconds / 3600)
	local minutes = floor((seconds % 3600) / 60)
	seconds = floor(seconds % 60)
	
	local hoursText = hours
	local minutesText = minutes
	local secondsText = seconds
	
	if hours < 10 then
		hoursText = "0"..hours
	end
	
	if minutes < 10 then
		minutesText = "0"..minutes
	end
	
	if seconds < 10 then
		secondsText = "0"..seconds
	end
	
	return hoursText..":"..minutesText..":"..secondsText
end

function Misc.createThread(callback)
	return coroutine.wrap(callback)()
end

function Misc.fastSpawn(callback)
	local event = Instance.new("BindableEvent")
	event.Event:Connect(callback)
	event:Fire()
	event:Destroy()
end;

local function isValidObject(object)
	local validClassNames = {
		"UnionOperation", 
		"MeshPart",
		"SpecialMesh",
		"Sound",
		"Decal",
		"Texture",
		"ImageButton",
		"ImageLabel",
		"ParticleEmitter",
		"Animation"
	}
	return table.find(object.ClassName, validClassNames) ~= nil
end

local function getValidObjects(directory, existingList)
	local list = existingList or {}
	for _, object in ipairs(directory:GetChildren()) do
		if isValidObject(object) then 
			table.insert(list, object)
		end
		getValidObjects(object, list)
	end
	return #list, list 
end

-- Returns n random amount of objects from a table
function Misc.getRandom(Table, n)
	local t = {}
	
	for _ = 1, n do
		-- Pick a random object
		local obj = Table[math.random(1, #Table)]
		
		-- Keep picking a random object until it's one that hasn't been already chosen
		while table.find(t, obj) do 
			obj = Table[math.random(1, #Table)] 
		end
		
		-- Add it to the new table
		table.insert(t, obj)
	end
	
	return t
end

-- Returns a copy of a given table
function Misc.copyTable(Table)
	local t = {}
	
	-- Copy table contents
	for i, v in pairs(Table) do
		t[i] = v
	end
	
	-- Return copied table
	return t
end

-- Reverses the order of objects in a table
function Misc.reverseTable(Table)
	local new = table.create(#Table, "")
	
	for i = #Table, 1, -1 do
		new[i] = Table[i]
	end
	
	return new
end

-- Creates an inverse of the table to be able to access the index using the value
function Misc.inverseTable(Table)
	for i, v in pairs(Table) do
		Table[v] = i
	end
end

-- Returns the parent of an object who's 
function Misc.getOutermostParent(obj)
	local path = string.split(obj:GetFullName(), ".")

	return (#path > 1 and game[path[1]][path[2]]) or game[path[1]] 
end

-- Returns all the children (exluding the ignore list) of a parent
function Misc.getChildren(Parent, Ignore)
	local children = {}
	
	for _, child in pairs(Parent:GetChildren()) do
		if not table.find(Ignore, child.Name) then
			table.insert(children, child)
		end
	end
	
	return children
end

-- Returns all the children of a certain class
function Misc.getChildrenOfClass(Parent, ClassName)
	local children = {}
	
	for _, child in ipairs(Parent:GetChildren()) do
		if child:IsA(ClassName) then
			table.insert(children, child)
		end
	end
	
	return children
end

-- Creates a region3 using the given starting point and ending point
function Misc.createRegion3(StartPoint, EndPoint)
	return Region3.new(
	    Vector3.new(
	       	math.min(StartPoint.X, EndPoint.X),
			math.min(StartPoint.Y, EndPoint.Y),
	       	math.min(StartPoint.Z, EndPoint.Z)
	    ),
	    Vector3.new(
	       	math.max(StartPoint.X, EndPoint.X),
	        math.max(StartPoint.Y, EndPoint.Y),
	        math.max(StartPoint.Z, EndPoint.Z)
	    )
	)
end

-- Creates a Region3 based on the given position and size
function Misc.createRegion3FromLocAndSize(Position, Size)
	local SizeOffset = Size/2
	local Point1 = Position - SizeOffset
	local Point2 = Position + SizeOffset
	
	return Region3.new(Point1, Point2)
end


-- Returns the matterial of the terrain at the given position and returns nil if no terrain found
function Misc.getTerrainMaterial(Position)
	local offset = Vector3.new(0.5, 0.5, 0.5)
	local region = Misc.CreateRegion3(Position + offset, Position - offset):ExpandToGrid(4)
	
	local material = game.Terrain:ReadVoxels(region, 4)
	
	return material[1][1][1]
end

-- Searches through contents of the specified parent and returns the child
function Misc.findDescendant(parent, childName)
	local chosenOne
	for _, child in ipairs(parent:GetDescendants()) do
		if child.Name ~= childName then
			continue
		end
		chosenOne = child
		break
	end
	return chosenOne
end

-- Returns the average velocity of a model
function Misc.getModelVelocity(Model)
	local sum = Vector3.new(0, 0, 0)
	local numParts = 0
	
	local function findPart(m)
		for _, obj in pairs(m:GetChildren()) do
			if obj:IsA("BasePart") then
				sum = sum + obj.Velocity
				numParts = numParts + 1
			elseif #obj:GetChildren() > 0 then
				findPart(obj)
			end
		end
	end
	
	findPart(Model)
	
	if sum == Vector3.new(0, 0, 0) then
		return Vector3.new(0, 0, 0)
	end
	
	return sum / numParts
end

-- Waits until the given animation reaches the specified keyframe
function Misc.waitForKeyframe(animation, keyframeName)
	local reached = false

	local doesKeyframeExist = pcall(function()
		return animation:GetTimeOfKeyframe(keyframeName)
	end)
	if not doesKeyframeExist then
		warn("[Misc module warning] waitForKeyframe aborted, Keyframe name [ " .. tostring(keyframeName) .. " does not exist in animation [ " .. animation .. " ]")
		return
	end

	local connection = animation.KeyframeReached:Connect(function(keyframe)
		if keyframe == keyframeName then 
			reached = true
		end
	end)

	-- Waits until the animation reaches a certain keyframe
	repeat 
		RunService.Heartbeat:wait()
	until reached
	
	-- Disconnect event
	connection:Disconnect()
end

-- Runs the given function when a certain keyframe is rechead
function Misc.runOnKeyframe(animation, keyframeName, func)
	
	local connection
	local doesKeyframeExist = pcall(function()
		return animation:GetTimeOfKeyframe(keyframeName)
	end)

	if doesKeyframeExist then
		connection = animation.KeyframeReached:Connect(function(keyframe)
			if keyframe == keyframeName then 
				func()
				
				connection:Disconnect()
			end
		end)
	end
	
	return connection
end

function Misc.getNextLevelXP(Level)
	local multiplier = 300
	
	if Level == 1 then
		return multiplier
	elseif Level < 50 then
		return math.floor(300 + ((Level * 0.24) ^ 2) * multiplier)
	else
		return math.floor(((math.log10(Level) * 300) - 366) * multiplier)
	end
end

-- Returns a comma format string of the given number (ex: converts 1000 to 1,000)
function Misc.commaFormat(Number)
	local _, _, minus, int, fraction = tostring(Number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

-- Converts a comma formatted number into a regular number
function Misc.removeCommaFormat(String)
	local commasRemoved = string.gsub(String, ",", "")
	
	return tonumber(commasRemoved)
end

-- Randomly shuffles objects table
function Misc.shuffle(a)
	local c = #a
	for i = 1, c do
		local ndx0 = math.random( 1, c )
		a[ ndx0 ], a[ i ] = a[ i ], a[ ndx0 ]
	end
	return a
end

-- Tweens a model's primary part cframe
function Misc.tweenModelCFrame(model, goal, info, newThread)
	if not model.PrimaryPart then
		warn("[Misc module warning] tweenModelCFrame: Model provided does not have a PrimaryPart")
		return
	end

	local cfValue = Instance.new("CFrameValue")
	
	cfValue.Value = model:GetPrimaryPartCFrame()
	
	local connection = cfValue.Changed:Connect(function(newValue)
		model:SetPrimaryPartCFrame(newValue)
	end)
	
	local tween = TweenService:Create(cfValue, info, {Value = goal})
	tween.Completed:Connect(function()
		connection:Disconnect()
		cfValue:Destroy()
	end)

	tween:Play()
	
	
	if not newThread then
		wait(info.Time)
	end
end

-- Returns touching parts (even if the part has CanCollide set to false)
function Misc.getTouchingParts(part)
   local connection = part.Touched:Connect(function() end)
   local results = part:GetTouchingParts()

   connection:Disconnect()

   return results
end

-- Returns the mass of a model
function Misc.getModelMass(model)
	local totalMass = 0
	
    for _ , obj in ipairs(model:GetChildren()) do
    	if obj:IsA("BasePart") then
	    	totalMass += obj:GetMass()
		elseif #obj:GetChildren() > 1 then
			totalMass += Misc.GetModelMass(obj)
	    end
    end

	return totalMass
end


--[[
    Description: Returns the first child with the specified name and class

    Parameters:
        instance [Instance]: The instance to search in
        name [string]: The name of the child to find
        className [string]: The name of the child's class
--]]
function Misc.firstFindChildOfNameAndClass(instance, name, className)
	local chosenOne
    for _, child in ipairs(instance:GetChildren()) do
        if child.Name == name and child:IsA(className) then
			chosenOne = child
			break
        end
	end
	return chosenOne
end

return Misc