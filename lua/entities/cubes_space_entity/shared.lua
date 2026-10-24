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

CUBE_NAME_FORMAT = "rt:%s:%s:cube:%f,%f,%f"
TEXT_CUBES_FINDING_PATTERN = "rt:NAME:%a:cube:.*"
ANCHOR_MODEL = "models/hunter/plates/plate025x025.mdl"

DEFAULT_ARG_SIZE = "1"

DEFAULT_ARG_TEXT_NAME = "justtext"
DEFAULT_ARG_TEXT = "I love You"

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


-- This code runs whenever the entity is created.
function ENT:Initialize()
	local model = ANCHOR_MODEL
	local ply = Entity(1)

	local hitPos = ply:GetEyeTrace().HitPos
	local startPos = ply:GetPos()
	local eyeTraceVec = ply:GetEyeTrace().Normal

	local pos = startPos + eyeTraceVec * (distance(startPos, hitPos) / 2) + Vector(0,0,1) * cubeSize * 5

	self:SetModel(model)

	-- Only set up physics on the server since it tends to create weird issues if you do it on the client.
	if SERVER then
		local name = DEFAULT_ARG_TEXT_NAME
		local text = DEFAULT_ARG_TEXT
		if self.SpawnArgument then
			name = self.SpawnArgument.name or DEFAULT_ARG_TEXT_NAME
			text = self.SpawnArgument.text or DEFAULT_ARG_TEXT
			self.SpawnArgument.size = self.SpawnArgument.size or DEFAULT_ARG_SIZE
			cubeSize = CUBE_PARAMETERS[self.SpawnArgument.size].size
			cubeModel = CUBE_PARAMETERS[self.SpawnArgument.size].model
		end

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetPos(pos)
		self:SetName(name)

		local faceAngle = getFaceAngle(eyeTraceVec)
		self:SetAngles(faceAngle)

		self.cubes = renderText(pos, text, name, eyeTraceVec, faceAngle, self)
	end

	local phys = self:GetPhysicsObject()

	-- This will make the entity fall instead of being stuck in the air when spawned.
	if ( IsValid(phys) ) then
		phys:EnableMotion(false)
		phys:Wake()
	end

	-- This is required to allow the entity to be gibbed.
	if ( SERVER ) then self:PrecacheGibs() end
end

function ENT:OnThink()
end

function ENT:OnRemove()
	if ( SERVER ) then
		for i, cube in ipairs(self.cubes) do
			applyRandomMomentum(cube)
		end
		print("Removed")
	end
end