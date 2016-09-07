-- I should be writing LiteLib right now.
Controller = {}
MoonUtil = _G.Valkyrie.GetComponent "MoonUtil"
r = newproxy true
extract = MoonUtil.ExtractWrapper r

-- Body
Controller.CompileSelector = extract (Selector) ->
	assert type(Selector) == 'string',
		'[Error][Selectors] (in CompileSelector): You need to supply a string as #1',
		2
	-- Start with primitive matching.
	combination = {}
	for section in Selector\gmatch "[^,]+"
		-- Every single section.
		nestSequence = {}
		for selection in section\gmatch "%S+"
			-- Every single selection.
			oName, oClass = selection\match "([%w_]*)%.?(%a*)"
			nestSequence[#nestSequence+1] = {
				oName
				oClass
			}
		-- Make the combinations
		combination[#combination+1] = nestSequence
	-- Do the selector dance
	-- Do do do selector dance
	-- fml

Controller.Select = extract (Selector, Source = workspace) ->
	if type Selector == 'string'
		Selector = Controller.CompileSelector Selector


with getmetatable r
	.__index = Controller
	.__metatable = "Locked Metatable: Valkyrie"
	.__tostring = -> "Valkyrie Selectors Controller"

return r
