-- @Author: Extuls

--[[Services]]--
local RobloxGroupService = game:GetService("GroupService")

--ExtendedGroupService table
local GroupService = {}

--Set up proxy to return
local ProxyGroupService = {}
local MetaProxyGroupService = {}
setmetatable(ProxyGroupService, MetaProxyGroupService)

--Redirect indexing the proxy to the ExtendedGroupService table
--Trigger an error if the index does not exist in the ExtendedGroupService table
MetaProxyGroupService.__index = function(tab, ind)
	if not GroupService[ind] then
		error(tostring(ind).." is not a valid member of ExtendedGroupService")
	end
	return GroupService[ind]
end

--Trigger an error when a script attempts to write values to the proxy
MetaProxyGroupService.__newindex = function(tab, ind, val)
	if not GroupService[ind] then
		error("cannot write to ExtendedGroupService")
	end
end

--[[Internal Functions]]--
--Used to get the group which a function of ExtendedGroupService is looking for
local function GetUserGroup(UserId, GroupId)
	local UserGroups = RobloxGroupService:GetGroupsAsync(UserId)
	
	for i = 1, #UserGroups do
		if UserGroups[i].Id == GroupId then
			return UserGroups[i]
		end
	end
	
	return nil
end

--[[ExtendedGroupService Functions]]--
--Returns the rank of a user in a group, returns 0 if they aren't in the group
function GroupService:GetUserRankInGroup(UserId, GroupId)
	if type(UserId) ~= "number" then
		error("bad argument #1 to 'GetUserRankInGroup' (number expected, got "..typeof(UserId)..")")
	end
	
	if type(GroupId) ~= "number" then
		error("bad argument #2 to 'GetUserRankInGroup' (number expected, got "..typeof(GroupId)..")")
	end
	
	local Group = GetUserGroup(UserId, GroupId)
	if Group then
		return Group.Rank
	end
	
	return 0
end

--Returns the role of a user in a group, returns "Guest" if they aren't in the group
function GroupService:GetUserRoleInGroup(UserId, GroupId)
	if type(UserId) ~= "number" then
		error("bad argument #1 to 'GetUserRoleInGroup' (number expected, got "..typeof(UserId)..")")
	end
	
	if type(GroupId) ~= "number" then
		error("bad argument #2 to 'GetUserRoleInGroup' (number expected, got "..typeof(GroupId)..")")
	end
	
	local Group = GetUserGroup(UserId, GroupId)
	if Group then
		return Group.Role
	end
	
	return "Guest"
end

--Return the proxy for use
return ProxyGroupService