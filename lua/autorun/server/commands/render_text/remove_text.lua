local DEFAULT_TEXT_NAME = "justtext"
local TEXT_CUBES_FINDING_PATTERN = "rt:NAME:%a:cube:.*"

function removeText(ply, cmd, args)
	local name = args[1]
	local pattern = TEXT_CUBES_FINDING_PATTERN:gsub("NAME", name)
	for i, ent in ipairs(ents.GetAll()) do
		if string.match(ent:GetName(), pattern) or ent:GetName() == name then
			ent:Remove()
		end
	end
end