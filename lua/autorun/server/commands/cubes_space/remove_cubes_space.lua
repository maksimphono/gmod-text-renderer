include("include/cubes_space.lua")

DEFAULT_CUBE_SPACE_NAME = "__cube_space__"

function removeCubesSpace(ply, cmd, args)
	local name = DEFAULT_CUBE_SPACE_NAME --args[1]
	for i, ent in ipairs(ents.GetAll()) do
		if ent:GetName() == name then
			ent:Remove()
		end
	end
end


