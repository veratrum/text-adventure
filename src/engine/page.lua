local Page = Object:extend()

Page.styles = {}
Page.styles["default"] = {
	color = "lgrey";
	colorHover = "lgrey";
}
Page.styles["action"] = {
	color = "gblue";
	colorHover = "lblue";
}

function Page:new()
	self.phrases = {}
end

function Page:addPhrase(phrase)
	local color = Page.styles.default.color
	local colorHover = Page.styles.default.colorHover
	
	table.insert(self.phrases, {
		text = phrase,
		color = color,
		colorHover = colorHover,
		action = "",
		data = ""})
	
	return self
end

function Page:addPhraseN(phrase) -- adds phrase then a newline
	self:addPhrase(phrase)
	self:newLine()
	
	return self
end

function Page:newLine()
	table.insert(self.phrases, {
		text = "",
		color = "",
		colorHover = "",
		action = "",
		data = ""})
	
	return self
end

function Page:pageBottom()
	table.insert(self.phrases, {
		text = "^",
		color = "",
		colorHover = "",
		action = "",
		data = ""})
	
	return self
end

-- must be cast after Page:click otherwise click will overwrite it with the default action style
function Page:style(name)
	local phrase = self.phrases[#self.phrases]
	
	-- if the previous phrase was "" i.e. a newline, go to the Page before that
	if phrase.text == "" then
		phrase = self.phrases[#self.phrases - 1]
	end
	
	local color = Page.styles[name].color
	local colorHover = Page.styles[name].colorHover
	
	phrase.color = color
	phrase.colorHover = colorHover
	
	return self
end

-- makes the last added phrase clickable upon which action is performed
-- data is optional for example "go"ing to a different room where the room ID is data
function Page:click(action, data)
	local data = data or ""
	
	local phrase = self.phrases[#self.phrases]
	
	-- if the previous phrase was "" i.e. a newline, go to the Page before that
	if phrase.text == "" then
		phrase = self.phrases[#self.phrases - 1]
	end
	
	local color = Page.styles.action.color
	local colorHover = Page.styles.action.colorHover
	
	phrase.color = color
	phrase.colorHover = colorHover
	phrase.action = action
	phrase.data = data
	
	return self
end

-- adds either or both previous and next pageLinks to the Page depending on the boolean parameters
function Page:pageLinks(previousPage, nextPage)
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

function Page:removeLast(n) -- at this stage only used to overwrite pageLinks with a different form
	for i = 1, n do
		table.remove(self.phrases, #self.phrases)
	end
end

function Page:getPhrases()
	return self.phrases
end

function Page:dumpT() -- debug
	print(util.dumpT(self.phrases))
end

-- static method. defines text styles to be used later
-- special values:
-- default: normal text
-- action: normal action text
function Page.defineStyle(name, color, colorHover)
	local style = {
		color = color;
		colorHover = colorHover;
	}
	
	Page.styles[name] = style
end

return Page
