-- LOCAL
local CloudFrameShared = require(game.ReplicatedStorage.CloudFrameShared.Main)

local players = game:GetService("Players")
local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")
local localPlayer = runService:IsClient() and players.LocalPlayer
local Signal = CloudFrameShared.loadLibrary("Signal")
local Maid = CloudFrameShared.loadLibrary("Maid")
local Zone = {}
Zone.__index = Zone

-- CONSTRUCTOR
function Zone.new(group, additionalHeight)
	local self = {}
	setmetatable(self, Zone)
	
	local maid = Maid.new()
	self._maid = maid
	self._updateConnections = Maid.new()
	self.autoUpdate = true
	self.respectUpdateQueue = true
	self.group = group
	self.additionalHeight = additionalHeight or 0
	self.previousPlayers = {}
	self.playerAdded = maid:give(Signal.new())
	self.playerRemoving = maid:give(Signal.new())
	self.updated = maid:give(Signal.new())
	self.zoneId = httpService:GenerateGUID()
	
	self:update()
	
	return self
end



-- METHODS
function Zone:update()
	local clusters = {}
	local totalVolume = 0
	local groupParts = {}
	local updateQueue = 0
	self._updateConnections:clean()
	for _, part in pairs(self.group:GetDescendants()) do
		if part:isA("BasePart") then
			table.insert(groupParts, part)
			local partProperties = {"Size", "Position"}
			local groupEvents = {"ChildAdded", "ChildRemoved"}
			local function update()
				if self.autoUpdate then
					coroutine.wrap(function()
						if self.respectUpdateQueue then
							updateQueue = updateQueue + 1
							wait(0.1)
							updateQueue = updateQueue - 1
						end
						if updateQueue == 0 and self.zoneId then
							self:update()
						end
					end)()
				end
			end
			for _, prop in pairs(partProperties) do
				self._updateConnections:give(part:GetPropertyChangedSignal(prop):Connect(update))
			end
			for _, event in pairs(groupEvents) do
				self._updateConnections:give(self.group[event]:Connect(update))
			end
		end
	end
	
	local scanned = {}
	local function getTouchingParts(part) -- This is to create clusters for getRandomPoint, *not* player detection
		local connection = part.Touched:Connect(function() end)
		local results = part:GetTouchingParts()
		connection:Disconnect()
		local whitelistResult = {}
		for _, touchingPart in pairs(results) do
			if table.find(groupParts, touchingPart) then
				table.insert(whitelistResult, touchingPart)
			end
		end
		return whitelistResult
	end
	for _, part in pairs(groupParts) do
		if not scanned[part] then
			scanned[part] = true
			local parts = {}
			local function formCluster(partToScan)
				table.insert(parts, partToScan)
				local touchingParts = getTouchingParts(partToScan)
				for _, touchingPart in pairs(touchingParts) do
					if not scanned[touchingPart] then
						scanned[touchingPart] = true
						formCluster(touchingPart)
					end
				end
			end
			formCluster(part)
			local region = self:getRegion(parts)
			local size = region.Size
			local volume = size.X * size.Y * size.Z
			totalVolume = totalVolume + volume
			table.insert(clusters, {
				region = region,
				parts = parts,
				volume = volume,
			})
		end
	end
	for _, details in pairs(clusters) do
		details.weight = details.volume/totalVolume
	end
	self.clusters = clusters
	
	local extra = Vector3.new(4, 4, 4)
	local _, boundMin, boundMax = self:getRegion(groupParts)
	self.region = Region3.new(boundMin-extra, boundMax+extra)
	self.boundMin = boundMin
	self.boundMax = boundMax
	self.regionHeight = boundMax.Y - boundMin.Y
	self.groupParts = groupParts
	
	self.updated:Fire()
end

function Zone:displayBounds()
	if not self.displayBoundParts then
		self.displayBoundParts = true
		local boundParts = {BoundMin = self.boundMin, BoundMax = self.boundMax}
		for boundName, boundCFrame in pairs(boundParts) do
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 0.5
			part.Size = Vector3.new(4,4,4)
			part.Color = Color3.fromRGB(255,0,0)
			part.CFrame = CFrame.new(boundCFrame)
			part.Name = boundName
			part.Parent = workspace
			self._maid:give(part)
		end
	end
end

function Zone:castRay(origin, parts)
	local startVector = origin + Vector3.new(0, self.regionHeight, 0)
	local lookDirection = startVector + Vector3.new(0, -1, 0)
	local endVector = (lookDirection - startVector).unit * (self.additionalHeight + self.regionHeight)
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = parts
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	local raycastResult = workspace:Raycast(startVector, endVector, raycastParams)
	if raycastResult then
		local hitPart = raycastResult.Instance
		local intersection = raycastResult.Position
		local intersectionY = intersection.Y
		local pointY = origin.Y
		if pointY + hitPart.Size.Y > intersectionY then
			return hitPart, intersection
		end
	end

	return false
end

function Zone:getRegion(tableOfParts)
	local bounds = {["Min"] = {}, ["Max"] = {}}
	for boundType, details in pairs(bounds) do
		details.Values = {}
		function details.parseCheck(v, currentValue)
			if boundType == "Min" then
				return (v <= currentValue)
			elseif boundType == "Max" then
				return (v >= currentValue)
			end
		end
		function details:parse(valuesToParse)
			for i,v in pairs(valuesToParse) do
				local currentValue = self.Values[i] or v
				if self.parseCheck(v, currentValue) then
					self.Values[i] = v
				end
			end
		end
	end
	for _, part in pairs(tableOfParts) do
		local sizeHalf = part.Size * 0.5
		local corners = {
			part.CFrame * CFrame.new(-sizeHalf.X, -sizeHalf.Y, -sizeHalf.Z),
			part.CFrame * CFrame.new(-sizeHalf.X, -sizeHalf.Y, sizeHalf.Z),
			part.CFrame * CFrame.new(-sizeHalf.X, sizeHalf.Y, -sizeHalf.Z),
			part.CFrame * CFrame.new(-sizeHalf.X, sizeHalf.Y, sizeHalf.Z),
			part.CFrame * CFrame.new(sizeHalf.X, -sizeHalf.Y, -sizeHalf.Z),
			part.CFrame * CFrame.new(sizeHalf.X, -sizeHalf.Y, sizeHalf.Z),
			part.CFrame * CFrame.new(sizeHalf.X, sizeHalf.Y, -sizeHalf.Z),
			part.CFrame * CFrame.new(sizeHalf.X, sizeHalf.Y, sizeHalf.Z),
		}
		for _, cornerCFrame in pairs(corners) do
			local x, y, z = cornerCFrame:GetComponents()
			local values = {x, y, z}
			bounds.Min:parse(values)
			bounds.Max:parse(values)
		end
	end
	local boundMin = Vector3.new(unpack(bounds.Min.Values))
	local boundMax = Vector3.new(unpack(bounds.Max.Values)) + Vector3.new(0, self.additionalHeight, 0)
	local region = Region3.new(boundMin, boundMax)
	return region, boundMin, boundMax
end

function Zone:getPlayersInRegion()
	local playersArray = players:GetPlayers()
	local playerCharacters = {}
	for _, player in pairs(playersArray) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			table.insert(playerCharacters, hrp)
		end
	end
	local partsInRegion = workspace:FindPartsInRegion3WithWhiteList(self.region, playerCharacters, #playersArray)
	local charsChecked = {}
	local playersInRegion = {}
	if #partsInRegion > 0 then
		for _, part in pairs(partsInRegion) do
			local char = part.Parent
			if not charsChecked[char] then
				charsChecked[char] = true
				local player = players:GetPlayerFromCharacter(char)
				if player then
					table.insert(playersInRegion, player)
				end
			end
		end
	end
	return playersInRegion
end

function Zone:getPlayer(player)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return false
	end
	local charOffset = hrp.Size.Y * -1.4
	local hum = char and char:FindFirstChild("Humanoid");
	if hum and hum:IsA("Humanoid") then
		charOffset = -hrp.Size.Y/2 - hum.HipHeight + 0.5
	end
	local origin = hrp.Position + Vector3.new(0, charOffset, 0)
	local hitValidPart, intersection = self:castRay(origin, self.groupParts)
	local originallyInZone = self.previousPlayers[player]
	local nowInZone = false
	if hitValidPart then
		-- Player entered zone
		if not originallyInZone then
			self.previousPlayers[player] = true
			self.playerAdded:Fire(player)
		end
		nowInZone = true
	end
	if originallyInZone and not nowInZone then
		-- Player exited zone
		self.previousPlayers[player] = nil
		self.playerRemoving:Fire(player)
	end
	return hitValidPart, intersection
end

function Zone:getPlayers()
	local playersInRegion = self:getPlayersInRegion()
	local playersInZone = {}
	local playersScanned = {}
	for _, player in pairs(playersInRegion) do
		playersScanned[player] = true
		if self:getPlayer(player) then
			table.insert(playersInZone, player)
		end
	end
	for player, _ in pairs(self.previousPlayers) do
		if not playersScanned[player] then -- This fires and removes players not registered in region check
			self:getPlayer(player)
		end
	end
	return playersInZone
end

function Zone:initLoop(loopDelay, limitToLocalPlayer)
	loopDelay = tonumber(loopDelay) or 0.5
	local loopId = httpService:GenerateGUID(false)
	self.currentLoop = loopId
	if not self.loopInitialized then
		self.loopInitialized = true
		coroutine.wrap(function()
			local nextUpdate = tick()
			while self.currentLoop == loopId do
				local thisTick = tick()
				if thisTick >= nextUpdate then
					nextUpdate = thisTick + loopDelay
					if limitToLocalPlayer and localPlayer then
						self:getPlayer(localPlayer)
					else
						self:getPlayers()
					end
				end
				runService.Heartbeat:Wait()
			end
		end)()
	end
end

function Zone:initClientLoop(loopDelay)
	self:initLoop(loopDelay, true)
end

function Zone:endLoop()
	self.currentLoop = nil
	self.loopInitialized = nil
end

function Zone:getRandomPoint()
	local pointCFrame, hitPart, hitIntersection
	repeat
		local parts, region 
		local randomWeight = math.random()
		local totalWeight = 0.01
		for _, details in pairs(self.clusters) do
			totalWeight = totalWeight + details.weight
			if totalWeight >= randomWeight then
				parts, region = details.parts, details.region
				break
			end
		end
		local size = region.Size
		local cframe = region.CFrame
		local random = Random.new()
		local randomCFrame = cframe * CFrame.new(random:NextNumber(-size.X/2,size.X/2), random:NextNumber(-size.Y/2,size.Y/2), random:NextNumber(-size.Z/2,size.Z/2))
		local origin = randomCFrame.p
		local hitValidPart, hitValidIntersection = self:castRay(origin, parts)
		if hitValidPart then
			pointCFrame, hitPart, hitIntersection = randomCFrame, hitValidPart, hitValidIntersection
		end
	until pointCFrame
	return pointCFrame, hitPart, hitIntersection
end

function Zone:destroy()
	self:endLoop()
	self._maid:clean()
	self._updateConnections:clean()
	self.zoneId = nil
end
	


return Zone