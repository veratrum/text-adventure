local util = {}

-- http://lua-users.org/wiki/CopyTable
function util.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function util.searchByID(list, id)
	for i = 1, #list do
		local item = list[i]
		
		if item:getID() == id then
			return list[i]
		end
	end
	
	return nil
end

function util.dumpT(list) -- every member must contain either a table or a primitive type
	local output = "["
	
	for i = 1, #list do
		local item = list[i]
		
		if type(list[i]) == "table" then
			output = output .. "[" .. util.dumpT(list[i]) .. "]"
		else
			output = output .. list[i]
		end
		
		if i ~= #list then
			output = output .. ", "
		end
	end
	
	output = output .. "]"
	
	return output
end

function util.padRight(text, lineWidth, spacing) -- right aligns text (95 characters in a line normally, but could have left aligned text on same line)
	local spacing = spacing or "_" -- underscore is rendered as space but does not hover
	local output = ""
	
	for i = 1, (lineWidth - #text) do
		output = output .. spacing
	end
	
	output = output .. text
	
	return output
end

function util.padCenter(text, lineWidth, spacing)
	local spacing = spacing or "_" -- underscore is rendered as space but does not hover
	local output = ""
	
	local numberSpaces = math.floor((lineWidth - #text) / 2)
	for i = 1, numberSpaces do
		output = output .. spacing
	end
	
	output = output .. text
	
	return output
end

return util
