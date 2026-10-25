local cos = math.cos
local sin = math.sin

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

DEFAULT_CUBE_NAME = "__cube__"
DEFAULT_CUBE_SPACE_NAME = "__cube_space__"

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"


-- The name that appears in the spawnmenu.
ENT.PrintName   = "Cube"

ENT.Information = "Render text using cubes"

ENT.Autho	= "maksimphono"


ENT.Spawnable = true

-- The category the entity is located in within the spawnmenu.
ENT.Category = "Other"


function __spawnCube(pos)
	local cube = ents.Create("movepush_cube_entity")

	cube.SpawnArgument = {}
	cube.SpawnArgument.pos = pos
	cube.SpawnArgument.model = cubeModel

	cube:Spawn()

	return cube
end

-- This code runs whenever the entity is created.
function ENT:Initialize()
	self.cubes = {}

	local hitPos = Entity(1):GetEyeTrace().HitPos

	-- Only set up physics on the server since it tends to create weird issues if you do it on the client.
	if SERVER then
		if self.SpawnArgument then
			self.SpawnArgument.size = self.SpawnArgument.size or DEFAULT_ARG_SIZE
			cubeSize = CUBE_PARAMETERS[self.SpawnArgument.size].size
			cubeModel = CUBE_PARAMETERS[self.SpawnArgument.size].model
		end

		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetName(DEFAULT_CUBE_SPACE_NAME)

		self:FillSpace(hitPos + Vector(0,0,cubeSize), 8, 0.17)
	end
end

function ENT:FillSpace(startPos, size, density)
	self.cubes = {}
	for i = 1,size,1 do
		for j = 1,size,1 do
			for k = 1,size,1 do
				if math.random() < density then
					table.insert(self.cubes, 1, __spawnCube(startPos + Vector(i * cubeSize, j * cubeSize, k * cubeSize)))
				end
			end
		end
	end

	for i = 1,#self.cubes,1 do
		for j = i + 1,#self.cubes,1 do
			constraint.NoCollide(self.cubes[i], self.cubes[j], 0, 0)
		end
	end

end

function ENT:Think()
	local directions = {Vector(1, 0, 0), Vector(0, 1, 0), Vector(0, 0, 1), Vector(-1, 0, 0), Vector(0, -1, 0), Vector(0, 0, -1)}

	for i, cube in ipairs(self.cubes) do
		local pos = cube:GetPos()
		local phys = cube:GetPhysicsObject()

		if not cube.movementState.isMoving then
			if math.random() < 0.02 then
				-- start moving
				local dir = directions[math.random(1, 6)]
				cube.movementState.isMoving = true
				cube.movementState.target = cube:GetPos() + dir * cubeSize
				phys:SetVelocity((cube.movementState.target - cube:GetPos()):GetNormalized() * cubeSize * 10)
			end
		else
			-- moving already
			if cube:GetPos():Distance(cube.movementState.target) < 5 then
				-- arrived
				cube.movementState.isMoving = false
				cube:SetPos(cube.movementState.target)
				phys:SetPos(cube.movementState.target)
			else
				-- not arived yet, keep going
				phys:SetVelocity((cube.movementState.target - cube:GetPos()):GetNormalized() * cubeSize * 10)
				cube:SetPos(phys:GetPos())
			end
		end

		--cube:SetAngles(phys:GetAngles())
		print(pos)
	end
	
	self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
	if ( SERVER ) then
		for i, ent in ipairs(self.cubes) do
			ent:Remove()
		end
		print("Removed")
	end
end