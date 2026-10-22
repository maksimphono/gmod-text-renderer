include("vector.lua")

CUBE_SIZE = 11.85
CUBE_MODEL = "models/hunter/blocks/cube025x025x025.mdl"

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

function spawnCube(pos)
	local cube = ents.Create("prop_physics")

	cube:SetModel(CUBE_MODEL)
	cube:SetPos(pos)
	cube:Spawn()
end

function renderText(pos, text)

	for i, sym in ipairs(text) do
		repr = symbols_table[sym]

		for j = 0,repr.height-1,1 do
			spawnCube(pos + Vector(0,0,CUBE_SIZE) * i)
		end
		break
	end
	
end

-- This code runs whenever the entity is created.
function ENT:Initialize()
	local name = "models/hunter/plates/plate1x1.mdl"
	local ply = Entity(1)

	local hitPos = ply:GetEyeTrace().HitPos
	local startPos = ply:GetPos()
	local eyeTraceVec = ply:GetEyeTrace().Normal

	local pos = startPos + eyeTraceVec * (distance(startPos, hitPos) / 2)

	renderText(pos, "Q")

	self:SetModel(name)

	-- Only set up physics on the server since it tends to create weird issues if you do it on the client.
	if SERVER then
    	self:PhysicsInit(SOLID_VPHYSICS)
    	self:SetMoveType(MOVETYPE_VPHYSICS)
    	self:SetSolid(SOLID_VPHYSICS)
		self:SetPos(pos)

		local faceAngle = getFaceAngle(eyeTraceVec)
		self:SetAngles(faceAngle)
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