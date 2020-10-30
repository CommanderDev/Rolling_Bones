--[[
	Author: ChipioIndustries
	Description: Create a developer-friendly interface for generating rich text styles
	
	API

	RichText.new(string/RichText text, Dictionary parameters) | creates a new RichText object
	string RichText:get() | returns the tagged text, ready to be assigned to a textlabel
	function RichText:iterate() | returns an iterator for use in a for loop to make a typewriter effect
	self RichText:addParameters(Dictionary parameters) | assigns new parameters

	string RichText.text | unedited text

	Signal RichText.changed(self) | fires when parameters are changed

	PARAMETERS
	Individual parameters have their own functions, which can be used to quickly assign
	new styles to existing RichText objects. These functions return themselves, allowing
	them to be chained together easily. 

	boolean parameters can just be set to true, but complex parameters (e.g. font) should be
	a dictionary of the desired styling.

	bold()
	strikethrough()
	italic()
	underline()
	font({
		size = "32";
		color = Color3.fromRGB(255,170,0);
	})

	OPERATORS
	RichText supports a number of native operators, including:
	concatenation (..)
	character length (#) (currently broken, thanks Roblox)
	equality (==) (takes styles into account, doesn't work against normal strings)
	tostring()
	addition (+)
	multiplication (*) (why though)

	USAGE

	local richText = RichText.new("Hello ",{
		font = {
			color = Color3.new(1,0,0)
		};
		italic = true;
		underline = true;
	})

	local richText2 = RichText.new("World")

	richText2:bold():strikethrough():font({
		size = "64"
	})

	local richText3 = richText..richText2.."!"

	textLabel.Text = richText3:get()

	--OR

	for text in richText3:iterate() do
		textLabel.Text = text
		wait()
	end
--]]

local Main = require(game.ReplicatedStorage.FrameShared.Main)
local Signal = Main.loadLibrary("Signal")

local RichText = {}
RichText.__index = RichText

local tagLUT = {
	["bold"] = "b";
	["strikethrough"] = "s";
	["italic"] = "i";
	["underline"] = "u";
	["font"] = "font";
}

function makeTag(contents,isEnd)
	local starting = "<"
	if isEnd then
		starting = "</"
	end
	return starting..contents..">"
end

function addTag(text,tag)
	local contents = tagLUT[tag]
	return makeTag(contents)..text..makeTag(contents,true)
end

function addQuotes(text)
	return [["]]..text..[["]]
end

function tagFromDictionary(tagName,dictionary)
	local tag = "<"..tagLUT[tagName]
	for key,value in pairs(dictionary) do
		if typeof(value) == "string" or typeof(value) == "number" then
			value = addQuotes(value)
		elseif typeof(value) == "Color3" then
			value = addQuotes("rgb("..tostring(math.floor(value.R*255))..","..tostring(math.floor(value.G*255))..","..tostring(math.floor(value.B*255))..")")
		end
		tag = tag.." "..key.."="..value
	end
	return tag..">"
end

function richTextToString(richText)
	if typeof(richText) == "table" and richText.isRichText then
		return richText:get()
	end
	return richText
end

function getTag(str,isEnd)
	isEnd = isEnd or false
	if str:sub(1,1) == "<" and (isEnd == (str:sub(2,2) == "/")) then
		local index = 2
		if isEnd then
			index = 3
		end
		local result = ""
		while str:sub(index,index)~=">" do
			if index>#str or str:sub(index,index)=="<" then
				--there'll never be a valid tag with an extra < in it
				return nil
			end
			result = result..str:sub(index,index)
			index+=1
		end
		return result
	end
end

function RichText.new(text,parameters)
	--allow passing rich text as text argument
	local oldParameters = {}
	if typeof(text) == "table" and text.isRichText then
		oldParameters = text.parameters
		text = text.text
	end

	local self = setmetatable({
		text = text;
		isRichText = true;
		parameters = oldParameters;
		changed = Signal.new();
	},RichText)

	parameters = parameters or {}
	self:addParameters(parameters)

	return self
end

function RichText:addParameters(parameters)
	for key,value in pairs(parameters) do
		if tagLUT[key] then
			self.parameters[key] = value
		else
			error("unknown text style: "..tostring(key))
		end
	end
	self.changed:fire(self)
	return self
end

function RichText:get()
	return self:_render()
end

function RichText:iterate()
	local raw = self:get()
	local progress = ""
	local openTags = {}

	return function()
		if progress == raw then
			return nil
		end

		local tag = getTag(raw:sub(#progress+1))
		while tag do
			progress = progress..makeTag(tag)
			table.insert(openTags,1,tag:split(" ")[1])
			tag = getTag(raw:sub(#progress+1))
		end

		progress = raw:sub(1,#progress+1)

		local tag = getTag(raw:sub(#progress+1),true)
		while tag do
			table.remove(openTags,1)
			progress = progress..makeTag(tag,true)
			tag = getTag(raw:sub(#progress+1),true)
		end

		local result = progress
		for index,tag in pairs(openTags) do
			result = result..makeTag(tag,true)
		end

		return result
	end
end

function RichText:_render()
	local modified = self.text
	for parameter,value in pairs(self.parameters) do
		if value == true then
			modified = addTag(modified,parameter)
		elseif typeof(value) == "table" then
			modified = tagFromDictionary(parameter,value)..modified.."</"..tagLUT[parameter]..">"
		end
	end
	return modified
end

for tag,_ in pairs(tagLUT) do
	RichText[tag] = function(self,value)
		self:addParameters({
			[tag] = value or true;
		})
		return self
	end
end

--metamethods

function RichText.__concat(segment1,segment2)
	segment1 = richTextToString(segment1)
	segment2 = richTextToString(segment2)
	return RichText.new(segment1..segment2,{})
end

--apparently __len gets ignored for tables so this doesn't work.
function RichText.__len()
	return #self.text
end

function RichText.__eq(segment1,segment2)
	segment1 = richTextToString(segment1)
	segment2 = richTextToString(segment2)
	return segment1 == segment2
end

function RichText.__tostring(self)
	return self:get()
end

function RichText.__mul(self,amount)
	self.text = string.rep(self.text,amount)
	self.changed:fire(self)
	return self
end

function RichText.__add(segment1,segment2)
	return RichText.__concat(segment1,segment2)
end

return RichText