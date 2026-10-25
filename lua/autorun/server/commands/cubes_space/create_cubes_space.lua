include("include/cubes_space.lua")

function createCubesSpace(ply, cmd, args)
	cubeSize = CUBE_PARAMETERS["24"].size
	cubeModel = CUBE_PARAMETERS["24"].model
	local hitPos = ply:GetEyeTrace().HitPos

	--fillSpace(hitPos + Vector(0,0,cubeSize), 8, 0.15)
end