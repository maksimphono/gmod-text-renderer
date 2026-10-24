include("include/cubes_space.lua")

cubeSize = 11.85
cubeModel = "models/hunter/blocks/cube025x025x025.mdl"

CUBE_PARAMETERS = {
	["1"] = { ["size"] = cubeSize, ["model"] = "models/hunter/blocks/cube025x025x025.mdl" },
	["2"] = { ["size"] = cubeSize * 2, ["model"] = "models/hunter/blocks/cube05x05x05.mdl" },
	["3"] = { ["size"] = cubeSize * 3, ["model"] = "models/hunter/blocks/cube075x075x075.mdl" },
	["4"] = { ["size"] = cubeSize * 4, ["model"] = "models/hunter/blocks/cube1x1x1.mdl" },
	["8"] = { ["size"] = cubeSize * 8, ["model"] = "models/hunter/blocks/cube2x2x2.mdl" },
	["16"] = { ["size"] = cubeSize * 16, ["model"] = "models/hunter/blocks/cube4x4x4.mdl" },
	["24"] = { ["size"] = cubeSize * 24, ["model"] = "models/hunter/blocks/cube6x6x6.mdl" },
	["32"] = { ["size"] = cubeSize * 32, ["model"] = "models/hunter/blocks/cube8x8x8.mdl" }
}


function spawnCube(pos)
	local cube = ents.Create("prop_physics")

	cube:SetModel(cubeModel)
	cube:SetPos(pos)
	cube:SetAngles(Angle(0,0,0))
	cube:Spawn()
	cube:SetName(DEFAULT_CUBE_NAME)
	cube:GetPhysicsObject():EnableMotion(false)
	cube:GetPhysicsObject():Wake()

	return cube
end


function fillSpace(startPos, size, density)
	local cubes = {}
	for i = 1,size,1 do
		for j = 1,size,1 do
			for k = 1,size,1 do
				if math.random() < density then
					table.insert(cubes, 1, spawnCube(startPos + Vector(i * cubeSize, j * cubeSize, k * cubeSize)))
				end
			end
		end
	end

	for i = 1,#cubes,1 do
		for j = i + 1,#cubes,1 do
			constraint.NoCollide(cubes[i], cubes[j], 0, 0)
		end
	end
end


function createCubesSpace(ply, cmd, args)
	cubeSize = CUBE_PARAMETERS["24"].size
	cubeModel = CUBE_PARAMETERS["24"].model
	local hitPos = ply:GetEyeTrace().HitPos

	fillSpace(hitPos + Vector(0,0,cubeSize), 8, 0.15)
end