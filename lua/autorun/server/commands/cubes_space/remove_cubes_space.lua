include("include/cubes_space.lua")

function removeCubesSpace(ply, cmd, args)
	local name = DEFAULT_CUBE_NAME
	for i, ent in ipairs(ents.GetAll()) do
		if ent:GetName() == name then
			ent:Remove()
		end
	end
end


