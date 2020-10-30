
local Client = {}

local replicatedStorage = game:GetService("ReplicatedStorage")

local sharedFolder = replicatedStorage.FrameShared
local playerScripts = script.Parent.Parent
local sharedLibraries = sharedFolder.Libraries
local clientLibraries = script.Parent.Libraries

local Misc = require(sharedLibraries.Misc)

local moduleCache = {}

function addToModuleCache(target)
    for _,module in ipairs(target:GetDescendants()) do
        if module:IsA("ModuleScript") then
            if not moduleCache[module.Name] then
                moduleCache[module.Name] = module
            end
        end
    end
end

addToModuleCache(replicatedStorage)
addToModuleCache(playerScripts)

function getModule(name)
    return moduleCache[name]
    or Misc.recursiveFindFirstChild(playerScripts, name, "ModuleScript")
    or Misc.recursiveFindFirstChild(replicatedStorage, name, "ModuleScript")
end

--[[
    Description: Requires a library

    Parameters:
        name [string]: The name of the library to require
--]]
function Client.loadLibrary(name)
    local lib = getModule(name)

    if not lib or not (lib:IsDescendantOf(clientLibraries) or lib:IsDescendantOf(sharedLibraries)) then
        warn("Could not find a client or shared library named", name)
    else
        if not moduleCache[lib.Name] then
            moduleCache[lib.Name] = lib
        end
        return require(lib)
    end
end

--[[
    Description: Requires a module

    Parameters:
        name [string]: The name of the module to require
--]]
function Client.require(name)
    local module = getModule(name)

    if not module then
        warn("Could not find a client or shared module named", name)
    else
        if not moduleCache[module.Name] then
            moduleCache[module.Name] = module
        end
        return require(module)
    end
end

--[[
    Description: Requires and calls init() on all modules in the given directory

    Parameters:
        target [Instance]: The directory to require
--]]
function Client.loadAll(directory)
    for index,module in pairs(directory:GetDescendants()) do
        if module:IsA("ModuleScript") then
            coroutine.wrap(function()
                local success,result = pcall(require,module)
                if not success then
                    error("Failed to load "..module:GetFullName()..": "..result)
                else
                    if typeof(result)=="table" and typeof(result.init)=="function" then
                        result:init()
                    end
                end
            end)()
        end
    end
end

--[[
    Description: Builds a tree of folders to the intended destination if it doesn't exist

    Parameters:
        origin [Instance]: The starting point of the path
        path [string]: The path to create. Segments should be separated with periods "."

    Example local roduxReducers = Server.getPath(game.ServerScriptService,"Rodux.Reducers")
--]]
function Client.getPath(origin,path)
    local pathSegments = string.split(path,".")
    for _,segment in pairs(pathSegments) do
        if not origin:FindFirstChild(segment) then
            local folder = Instance.new("Folder")
            folder.Name = segment
            folder.Parent = origin
        end
        origin = origin[segment]
    end
    return origin
end

--[[
    Description: Returns a data stream with the specified name and class

    Parameters:
        name [string]: The name of the data stream
        className [string]: The name of the class
--]]
function Client.getDataStream(name, className)
    if sharedFolder:FindFirstChild("DataStreams") then
        local dataStream = Misc.firstFindChildOfNameAndClass(sharedFolder.DataStreams, name, className)

        if dataStream == nil then
            warn("Could not find a data stream that is called", name, "and is a", className)
        else
            return dataStream
        end
    else
        warn("Could not find a data stream that is called", name, "and is a", className)
    end
end

return Client