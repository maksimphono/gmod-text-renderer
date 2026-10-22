include("assets/symbols_table.lua")
include("vector.lua")

CUBE_SIZE = 11.85
CUBE_MODEL = "models/hunter/blocks/cube025x025x025.mdl"
CUBE_NAME_FORMAT = "rt:%s:%s:cube:%f.%f.%f"

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"


-- The name that appears in the spawnmenu.
ENT.PrintName   = "Text"

ENT.Information = "Render text using cubes"

ENT.Author      = "maksimphono"


ENT.Spawnable = true

-- The category the entity is located in within the spawnmenu.
ENT.Category = "Other"


-- These are custom entity variables, feel free to change them!
ENT.ExplosionDamage = 100
ENT.ExplosionRadius = 250

-- This custom variable prevents the entity from infinitely exploding.
ENT.HasExploded = false

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

function setCubeName(cube, letter, text)
	local pos = cube:GetPos()
	cube:SetName(string.format(CUBE_NAME_FORMAT, string.sub(text, 1, 9), letter, pos.x, pos.y, pos.z))
end

function spawnCube(pos, angle)
	local cube = ents.Create("prop_physics")

	cube:SetModel(CUBE_MODEL)
	cube:SetPos(pos)
	cube:SetAngles(angle)
	cube:Spawn()
	cube:GetPhysicsObject():EnableMotion(true)
	cube:GetPhysicsObject():Wake()

	return cube
end

function getTextDirectionVector(eyeTrace)
	return Vector(eyeTrace.y, -eyeTrace.x, 0):GetNormalized() * CUBE_SIZE
end

function renderText(pos, text, eyeTrace, angle, anchor)
	local dirVec = getTextDirectionVector(eyeTrace)
	local verticalVector = Vector(0, 0, -CUBE_SIZE)
	local textHeight = 0
	local textWidth = 0

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
			setCubeName(cube, sym, text)
			table.insert(cubes, 1, cube)
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
	
end

-- This code runs whenever the entity is created.
function ENT:Initialize()
	local name = "models/hunter/plates/plate025x025.mdl"
	local ply = Entity(1)

	local hitPos = ply:GetEyeTrace().HitPos
	local startPos = ply:GetPos()
	local eyeTraceVec = ply:GetEyeTrace().Normal

	local pos = startPos + eyeTraceVec * (distance(startPos, hitPos) / 2) + Vector(0,0,1) * CUBE_SIZE * 5

	local faceAngle = nil

	self:SetModel(name)

	-- Only set up physics on the server since it tends to create weird issues if you do it on the client.
	if SERVER then
    	self:PhysicsInit(SOLID_VPHYSICS)
    	self:SetMoveType(MOVETYPE_VPHYSICS)
    	self:SetSolid(SOLID_VPHYSICS)
		self:SetPos(pos)

		faceAngle = getFaceAngle(eyeTraceVec)
		self:SetAngles(faceAngle)

		renderText(pos, "I love You", eyeTraceVec, faceAngle, self)
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
        print("Removed")
    end
end