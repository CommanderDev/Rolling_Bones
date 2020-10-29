-- rotated region3 module 
-- https://www.roblox.com/Rotated-region3-item?id=434885049
-- Ego

--[[
API:

Constructors:
	region.new(cframe, size)
		> Creates a region from a cframe which acts as the center of the region and size which extends to 
		> the corners like a part.
	region.fromPart(part)
		> Creates a region from a part in the game. It can be used on any base part, but the region 
		> will only support boxes (not wedges, cylinders, etc)

Methods:
	region:cast(ignore instance or table (descendants as well), int maxParts)
		> returns a table full of parts that are inside the region
	region:castPart(basePart)
		> returns a boolean as to whether or not a given part is within a region or not
		> also returns minimum translation vector needed to move the part out of collision
		> eg.
		>> local collides, mtv = region:castPart(examplePart);
		>> examplePart.CFrame = examplePart.CFrame + mtv;
	region:castPoint(vector3)
		> returns a boolean as to whether or not a given point is within a region or not
	region:intersectionPoints(basePart)
		> returns a table of points where the part intersects with the region

Properties:
	region.cframe
		> cframe that represents the center of the region
	region.size
		> vector3 that represents the size of the region
	region.planes
		> table holding the 6 planes that make up the region
	region.corners
		> table holding the 8 corners that make up the bounds of the region
	region.surfaceCountsAsCollision - defaults to true
		> adjustable boolean that determines wheter a part laying on the surface of a region is in bounds or not
		> when false and rotated this can be wrong do to float math, can't do much about it :(
--]]

-- debug functions

function drawline(p0, p1)
	local v = (p1 - p0);
	local part = Instance.new("Part");
	part.Anchored = true;
	part.Size = Vector3.new(0.2, 0.2, v.magnitude);
	part.CFrame = CFrame.new(p0 + v/2, p1);
	part.TopSurface = Enum.SurfaceType.Smooth;
	part.BottomSurface = Enum.SurfaceType.Smooth;
	return part;
end;

-- functions related to the module

function shallowcopy(t)
	local nt = {};
	for k, v in next, t do
		nt[k] = v;
	end;
	return nt;
end

function planeIntersect(point, vector, origin, normal)
	local rpoint = point - origin;
	local t = -rpoint:Dot(normal) / vector:Dot(normal);
	return point + t * vector, t;
end;

function getCorners(cf, size)
	local size, corners = size / 2, {};
	for x = -1, 1, 2 do
		for y = -1, 1, 2 do
			for z = -1, 1, 2 do
				table.insert(corners, (cf * CFrame.new(size * Vector3.new(x, y, z))).p);
			end;
		end;
	end;
	return corners;
end;

function getAxis(c1, c2)
	local axis = {};
	axis[1] = (c1[2] - c1[1]).unit;
	axis[2] = (c1[3] - c1[1]).unit;
	axis[3] = (c1[5] - c1[1]).unit;
	axis[4] = (c2[2] - c2[1]).unit;
	axis[5] = (c2[3] - c2[1]).unit;
	axis[6] = (c2[5] - c2[1]).unit;
	axis[7] = axis[1]:Cross(axis[4]).unit;
	axis[8] = axis[1]:Cross(axis[5]).unit;
	axis[9] = axis[1]:Cross(axis[6]).unit;
	axis[10] = axis[2]:Cross(axis[4]).unit;
	axis[11] = axis[2]:Cross(axis[5]).unit;
	axis[12] = axis[2]:Cross(axis[6]).unit;
	axis[13] = axis[3]:Cross(axis[4]).unit;
	axis[14] = axis[3]:Cross(axis[5]).unit;
	axis[15] = axis[3]:Cross(axis[6]).unit;
	return axis;
end;

function testAxis(corners1, corners2, axis, surface)
	if axis.Magnitude == 0 or tostring(axis) == "NAN, NAN, NAN" then
		return true;
	end;
	local adists, bdists = {}, {};
	for i = 1, 8 do
		table.insert(adists, corners1[i]:Dot(axis));
		table.insert(bdists, corners2[i]:Dot(axis));
	end;
	local amax, amin = math.max(unpack(adists)), math.min(unpack(adists));
	local bmax, bmin = math.max(unpack(bdists)), math.min(unpack(bdists));
	local longspan = math.max(amax, bmax) - math.min(amin, bmin);
	local sumspan = amax - amin + bmax - bmin;
	local pass, mtv;
	if surface then
		pass = longspan <= sumspan;
	else
		pass = longspan < sumspan;
	end;
	if pass then
		local overlap = amax > bmax and -(bmax - amin) or (amax - bmin);
		mtv = axis * overlap;
	end;
	return pass, mtv;
end;

-- class

local region = {};

function region.new(cf, size)
	local self = setmetatable({}, {__index = region});
	self.surfaceCountsAsCollision = true;
	self.cframe = cf;
	self.size = size;
	self.planes = {};
	self.corners = getCorners(self.cframe, self.size);
	for _, enum in next, Enum.NormalId:GetEnumItems() do
		local lnormal = Vector3.FromNormalId(enum);
		local wnormal = self.cframe:vectorToWorldSpace(lnormal);
		local distance = (lnormal * self.size/2).magnitude;
		local point = self.cframe.p + wnormal * distance;
		table.insert(self.planes, {
			normal = wnormal;
			point = point;
		});
	end;	
	return self;
end;

function region.fromPart(part)
	return region.new(
		part.CFrame,
		part.Size
	);
end;

function region:castPoint(point)
	for _, plane in next, self.planes do
		local relative = point - plane.point;
		if self.surfaceCountsAsCollision then
			if relative:Dot(plane.normal) >= 0 then
				return false;
			end;
		else
			if relative:Dot(plane.normal) > 0 then
				return false;
			end;
		end;
	end;
	-- was above none of the planes. Point must be in region
	return true;
end;

function region:castPart(part)
	local corners1 = self.corners;
	local corners2 = getCorners(part.CFrame, part.Size);
	local axis, mtvs = getAxis(corners1, corners2), {};
	for i = 1, #axis do
		local intersect, mtv = testAxis(corners1, corners2, axis[i], self.surfaceCountsAsCollision);
		if not intersect then return false, Vector3.new(); end;
		-- the other axis are a bit wonky the surface normals are good tho
		if mtv then table.insert(mtvs, mtv); end;
	end;
	-- must be intersecting
	table.sort(mtvs, function(a, b) return a.magnitude < b.magnitude; end);
	return true, mtvs[1];
end;

function region:intersectionPoints(part)
	local intersections = {};	
	
	-- check part against region
	local corners = getCorners(part.CFrame, part.Size);
	local attach = {
		[corners[1]] = {corners[3], corners[2], corners[5]};
		[corners[4]] = {corners[3], corners[2], corners[8]};
		[corners[6]] = {corners[5], corners[2], corners[8]};
		[corners[7]] = {corners[3], corners[8], corners[5]};
	};
	-- do some plane ray intersections
	for corner, set in next, attach do
		for _, con in next, set do
			local v = con - corner;
			for i, plane in next, self.planes do
				local p, t = planeIntersect(corner, v, plane.point, plane.normal)
				if t >= 0 and t <= 1 then
					local pass = true;
					for i2, plane2 in next, self.planes do
						if i2 ~= i then
							-- underneath every other plane
							local relative = p - plane2.point;
							if relative:Dot(plane2.normal) >= 0 then
								pass = false;
							end;
						end;
					end;
					if pass then table.insert(intersections, p); end;
				end;
			end;
		end;
	end;
	
	-- check region against part	
	local planes = {};
	for _, enum in next, Enum.NormalId:GetEnumItems() do
		local lnormal = Vector3.FromNormalId(enum);
		local wnormal = part.CFrame:vectorToWorldSpace(lnormal);
		local distance = (lnormal * part.Size/2).magnitude;
		local point = part.CFrame.p + wnormal * distance;
		table.insert(planes, {
			normal = wnormal;
			point = point;
		});
	end;
	local corners = self.corners;
	local attach = {
		[corners[1]] = {corners[3], corners[2], corners[5]};
		[corners[4]] = {corners[3], corners[2], corners[8]};
		[corners[6]] = {corners[5], corners[2], corners[8]};
		[corners[7]] = {corners[3], corners[8], corners[5]};
	};
	-- do some plane ray intersections
	for corner, set in next, attach do
		for _, con in next, set do
			local v = con - corner;
			for i, plane in next, planes do
				local p, t = planeIntersect(corner, v, plane.point, plane.normal)
				if t >= 0 and t <= 1 then
					local pass = true;
					for i2, plane2 in next, planes do
						if i2 ~= i then
							-- underneath every other plane
							local relative = p - plane2.point;
							if relative:Dot(plane2.normal) >= 0 then
								pass = false;
							end;
						end;
					end;
					if pass then table.insert(intersections, p); end;
				end;
			end;
		end;
	end;
	
	return intersections;
end;

function region:cast(ignore, maxParts)
	local ignore = type(ignore) == "table" and ignore or {ignore};
	local maxParts = maxParts or 20; -- 20 is default for normal region3
	
	-- kinda hacky, but i think this is the most efficient option
	-- there might be volume bounding errors for very large regions tho?
	
	-- get world bound box? Did I have a brain fart? Is there a better way to do this?
	local rmin, rmax = {}, {};
	local copy = shallowcopy(self.corners);
	for _, enum in next, {Enum.NormalId.Right, Enum.NormalId.Top, Enum.NormalId.Back} do
		local lnormal = Vector3.FromNormalId(enum);
		table.sort(copy, function(a, b) return a:Dot(lnormal) > b:Dot(lnormal); end);
		table.insert(rmin, copy[#copy]);
		table.insert(rmax, copy[1]);
	end;
	rmin, rmax = Vector3.new(rmin[1].x, rmin[2].y, rmin[3].z), Vector3.new(rmax[1].x, rmax[2].y, rmax[3].z);
	
	-- cast non-rotated region first as a probe
	local realRegion3 = Region3.new(rmin, rmax);
	local parts = game.Workspace:FindPartsInRegion3WithIgnoreList(realRegion3, ignore, maxParts);
	
	-- debug stuff
	--game.Workspace.CurrentCamera:ClearAllChildren();
	--drawline(rmin, rmax).Parent = game.Workspace.CurrentCamera;	
	
	-- now do real check!
	local inRegion = {};
	for _, part in next, parts do
		if self:castPart(part) then
			table.insert(inRegion, part);
		end;
	end;
	
	return inRegion;
end;

-- return the class

return region;