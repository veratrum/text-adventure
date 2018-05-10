local page = {}
page.__index = page

page.styles = {}
page.styles["default"] = {
	color = "lgrey";
	colorHover = "lgrey";
}
page.styles["action"] = {
	color = "gblue";
	colorHover = "lblue";
}

function page.new()
	local self = setmetatable({}, page)
	
	self.phrases = {}
	
	return self
end

function page:addPhrase(phrase)
	local color = page.styles.default.color
	local colorHover = page.styles.default.colorHover
	
	table.insert(self.phrases, {
		text = phrase,
		color = color,
		colorHover = colorHover,
		action = "",
		data = ""})
	
	return self
end

function page:addPhraseN(phrase) -- adds phrase then a newline
	self:addPhrase(phrase)
	self:newLine()
	
	return self
end

function page:newLine()
	table.insert(self.phrases, {
		text = "",
		color = "",
		colorHover = "",
		action = "",
		data = ""})
	
	return self
end

function page:pageBottom()
	table.insert(self.phrases, {
		text = "^",
		color = "",
		colorHover = "",
		action = "",
		data = ""})
	
	return self
end

-- must be cast after page:click otherwise click will overwrite it with the default action style
function page:style(name)
	local phrase = self.phrases[#self.phrases]
	
	-- if the previous phrase was "" i.e. a newline, go to the page before that
	if phrase.text == "" then
		phrase = self.phrases[#self.phrases - 1]
	end
	
	local color = page.styles[name].color
	local colorHover = page.styles[name].colorHover
	
	phrase.color = color
	phrase.colorHover = colorHover
	
	return self
end

-- makes the last added phrase clickable upon which action is performed
-- data is optional for example "go"ing to a different room where the room ID is data
function page:click(action, data)
	local data = data or ""
	
	local phrase = self.phrases[#self.phrases]
	
	-- if the previous phrase was "" i.e. a newline, go to the page before that
	if phrase.text == "" then
		phrase = self.phrases[#self.phrases - 1]
	end
	
	local color = page.styles.action.color
	local colorHover = page.styles.action.colorHover
	
	phrase.color = color
	phrase.colorHover = colorHover
	phrase.action = action
	phrase.data = data
	
	return self
end

-- adds either or both previous and next page links to the page depending on the boolean parameters
function page:pageLinks(previousPage, nextPage)
	if previousPage and nextPage then
		self:pageBottom()
		self:addPhrase("<=="):click("previous")
		self:addPhrase(util.padRight("==>", 85)):click("next")
	elseif previousPage and not nextPage then
		self:pageBottom()
		self:addPhrase("<=="):click("previous")
	elseif not previousPage and nextPage then
		self:pageBottom()
		self:addPhrase(util.padRight("==>", 88)):click("next")
	end
	
	return self
end

function page:removeLast(n) -- at this stage only used to overwrite pageLinks with a different form
	for i = 1, n do
		table.remove(self.phrases, #self.phrases)
	end
end

function page:getPhrases()
	return self.phrases
end

function page:dumpT() -- debug
	print(util.dumpT(self.phrases))
end

-- static method. defines text styles to be used later
-- special values:
-- default: normal text
-- action: normal action text
function page.defineStyle(name, color, colorHover)
	local style = {
		color = color;
		colorHover = colorHover;
	}
	
	page.styles[name] = style
end

return page