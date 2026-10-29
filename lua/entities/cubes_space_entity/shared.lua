local cos = math.cos
local sin = math.sin

cubeSize = 11.85
cubeModel = "models/hunter/blocks/cube025x025x025.mdl"
dimension = 16
material = "models/debug/debugwhite"

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

MOVEMENT_SPEED_COEFFICIENT = 2

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"


-- The name that appears in the spawnmenu.
ENT.PrintName   = "Cube"

ENT.Information = "Render text using cubes"

ENT.Autho	= "maksimphono"


ENT.Spawnable = true

ENT.Category = "Other"


local function spawnCube(pos, internalPos)
	local cube = ents.Create("movepush_cube_entity")

	cube.SpawnArgument = {
		["pos"] 	= pos,
		["model"] 	= cubeModel,
		["internalPos"] = internalPos,
		["material"] 	= material
	}

	cube:Spawn()

	return cube
end

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

		-- for cubes movements
		self.directions = {
			[0] = Vector(1, 0, 0), 
			[1] = Vector(0, 1, 0), 
			[2] = Vector(0, 0, 1), 
			[3] = Vector(-1, 0, 0), 
			[4] = Vector(0, -1, 0), 
			[5] = Vector(0, 0, -1)
		}

		self.vacantMatrix = {} -- matrix of boolean values, representing which position in the cube space are vacant
		

		-- parameters
		cubeSize = CUBE_PARAMETERS["24"].size
		cubeModel = CUBE_PARAMETERS["24"].model
		dimension = 16

		self.movementChance = 1 / math.pow(dimension, 3)

		self:SetNoDraw(true)
		self:DrawShadow(false)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetName(DEFAULT_CUBE_SPACE_NAME)

		self:FillSpace(hitPos + Vector(0,0,cubeSize), dimension, 0.17)
	end
end

function ENT:FillSpace(startPos, size, density)
	self.cubes = {}
	self.vacantMatrix = {}

	for i = 1,size,1 do
		self.vacantMatrix[i] = {}
		for j = 1,size,1 do
			self.vacantMatrix[i][j] = {}
			for k = 1,size,1 do
				self.vacantMatrix[i][j][k] = true

				if math.random() < density then
					table.insert(self.cubes, 1, spawnCube(startPos + Vector(i * cubeSize, j * cubeSize, k * cubeSize), Vector(i, j, k)))
					self.vacantMatrix[i][j][k] = false
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

function ENT:CanMove(cube, id)
	local switch = {
		[0] = function(targetPos) return targetPos.x < dimension end,
		[1] = function(targetPos) return targetPos.y < dimension end,
		[2] = function(targetPos) return targetPos.z < dimension end,
		[3] = function(targetPos) return targetPos.x >= 1 end,
		[4] = function(targetPos) return targetPos.y >= 1 end,
		[5] = function(targetPos) return targetPos.z >= 1 end
	}
	local newPos = cube.movementState.internalPos + self.directions[id]

	return (switch[id](newPos) and self.vacantMatrix[newPos.x][newPos.y][newPos.z])
end

function ENT:Think()

	if not SERVER then
		self:NextThink(CurTime())
    		return true
	end

	for i, cube in ipairs(self.cubes) do
		local pos = cube:GetPos()
		local phys = cube:GetPhysicsObject()

		if not cube.movementState.isMoving then
			if math.random() < self.movementChance then
				-- start moving
				local id = math.random(0, 5)
				local dir = self.directions[id]

				for _ = 1,6,1 do
					if self:CanMove(cube, id) then
						-- start moving
						cube.movementState.isMoving = true
						cube.movementState.target = cube:GetPos() + dir * cubeSize
						cube.movementState.targetPos = cube.movementState.targetPos + dir

						phys:EnableMotion(true)
						phys:SetVelocity((cube.movementState.target - cube:GetPos()):GetNormalized() * cubeSize * MOVEMENT_SPEED_COEFFICIENT)
						phys:Wake()

						-- locks target space so it won't be taken
						self.vacantMatrix[cube.movementState.targetPos.x][cube.movementState.targetPos.y][cube.movementState.targetPos.z] = false

						break
					end
					-- try different direction
					id = (id + 1) % 6
					dir = self.directions[id]
				end
			end
		else
			-- moving already
			if cube:GetPos():Distance(cube.movementState.target) < 0.05 * cubeSize then
				-- arrived
				self.vacantMatrix[cube.movementState.internalPos.x][cube.movementState.internalPos.y][cube.movementState.internalPos.z] = true

				cube.movementState.isMoving = false
				cube.movementState.internalPos = cube.movementState.targetPos
				cube:SetPos(cube.movementState.target)
				phys:SetPos(cube.movementState.target)
				phys:EnableMotion(false)
				phys:Sleep()
			else
				-- not arived yet, keep going
				phys:SetVelocity((cube.movementState.target - cube:GetPos()):GetNormalized() * cubeSize * MOVEMENT_SPEED_COEFFICIENT)
				cube:SetPos(phys:GetPos())
			end
		end

		--cube:SetAngles(phys:GetAngles())

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