include("assets/symbols_table.lua")
include("vector.lua")

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
ENT.PrintName   = "Text"

ENT.Information = "Render text using cubes"

ENT.Autho	= "maksimphono"


ENT.Spawnable = true

-- The category the entity is located in within the spawnmenu.
ENT.Category = "Other"


function setCubeName(cube, letter, name)
	local pos = cube:GetPos()
	cube:SetName(string.format(CUBE_NAME_FORMAT, name, letter, pos.x, pos.y, pos.z))
end

function spawnCube(pos, angle)
	local cube = ents.Create("prop_physics")

	cube:SetModel(cubeModel)
	cube:SetPos(pos)
	cube:SetAngles(angle * 1)
	cube:Spawn()
	cube:GetPhysicsObject():EnableMotion(true)
	cube:GetPhysicsObject():Wake()

	return cube
end

function getFaceAngle(eyeTraceVec)
	-- Gets angle so created object would face the player by Ox and Oy, not Oz
	local OxyProj = eyeTraceVec
	OxyProj.z = 0
	local n = Vector(0, 1, 0)
	local dir = vecMul(Vector(1, 0, 0), OxyProj)
	local OyAngleDeg = 0

	OyAngleDeg = (dir < 0 and 1 or -1) * 180 / math.pi * math.acos( vecMul(n, OxyProj) / vecLen(OxyProj) )

	return Angle(0, OyAngleDeg, 90)
end

function getTextDirectionVector(eyeTrace)
	return Vector(eyeTrace.y, -eyeTrace.x, 0):GetNormalized() * cubeSize
end

function renderText(pos, text, name, eyeTrace, angle, anchor)
	local dirVec = getTextDirectionVector(eyeTrace)
	local verticalVector = Vector(0, 0, -cubeSize)
	local textHeight = 0
	local textWidth = 0
	local spawnedCubes = {}

	for sym in string.gmatch(text, ".") do
		if symbols_table[sym].height > textHeight then textHeight = symbols_table[sym].height end
		textWidth = textWidth + symbols_table[sym].width
	end

	local symStartPos = pos - dirVec * (textWidth / 2) - verticalVector * textHeight
	for sym in string.gmatch(text, ".") do
		
		local repr = symbols_table[sym]
		local cubes = {}

		-- Spawning and placing cubes
		for i, coords in ipairs(repr.bitmap) do
			local cube = spawnCube(symStartPos + dirVec * coords[1] + verticalVector * coords[2], angle)
			setCubeName(cube, sym, name)
			table.insert(cubes, 1, cube)
			table.insert(spawnedCubes, 1, cube)
		end

		-- Welding cubes to anchor and disabling collision
		for i = 1,#cubes,1 do
			for j = i + 1,#cubes,1 do
				constraint.NoCollide(cubes[i], cubes[j], 0, 0)
			end
			constraint.Weld(anchor, cubes[i], 0, 0, 0, true, false)
		end
		-- Moving to the next symbol
		symStartPos = symStartPos + dirVec * repr.width

	end
	
	return spawnedCubes
end

function applyRandomMomentum(ent)
	local power = 2.7

	local theta = math.random(0, 360)
	local unit = math.pow(cubeSize, power)
	local movementVec = Vector(cos(theta) * unit - sin(theta) * unit, sin(theta) * unit + cos(theta) * unit, 0)

	timer.Simple(0, function()
		local phys = ent:GetPhysicsObject()
		phys:Wake()
		phys:ApplyForceCenter(movementVec)
		phys:Wake()	
	end)

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

function ENT:OnRemove()
	if ( SERVER ) then
		for i, cube in ipairs(self.cubes) do
			applyRandomMomentum(cube)
		end
		print("Removed")
	end
end