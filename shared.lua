AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"


-- The name that appears in the spawnmenu.
ENT.PrintName   = "Plain"

ENT.Information = "Shoot to explode."

ENT.Author      = "You!"


ENT.Spawnable = true

-- The category the entity is located in within the spawnmenu.
ENT.Category = "Other"


-- These are custom entity variables, feel free to change them!
ENT.ExplosionDamage = 100
ENT.ExplosionRadius = 250

-- This custom variable prevents the entity from infinitely exploding.
ENT.HasExploded = false

function sqr(x)
	return x * x
end

function distance(p1, p2)
	return math.abs(math.sqrt(sqr(p1.x - p2.x) + sqr(p1.y - p2.y) + sqr(p1.z - p2.z)))
end

function vecLen(v1, v2)
	return distance(v1, Vector(0,0,0))
end

function vecMul(v1, v2)
	return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
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

-- This code runs whenever the entity is created.
function ENT:Initialize()
	local name = "models/hunter/plates/plate1x1.mdl"

	local hitPos = Entity(1):GetEyeTrace().HitPos
	local startPos = Entity(1):GetPos()
	local eyeTraceVec = Entity(1):GetEyeTrace().Normal

	local pos = startPos + eyeTraceVec * (distance(startPos, hitPos) / 2)

	self:SetModel(name)

	local faceAngle = getFaceAngle(eyeTraceVec)

	-- Only set up physics on the server since it tends to create weird issues if you do it on the client.
	if SERVER then
    		self:PhysicsInit(SOLID_VPHYSICS)
    		self:SetMoveType(MOVETYPE_VPHYSICS)
    		self:SetSolid(SOLID_VPHYSICS)
		self:SetPos(pos)
		self:SetAngles(faceAngle)
	end

    	local phys = self:GetPhysicsObject()

    	-- This will make the entity fall instead of being stuck in the air when spawned.
    	if ( IsValid(phys) ) then
		phys:EnableMotion(false)
        	phys:Wake()
    	end

    	-- This is required to allow the entity to be gibbed.
    	if ( SERVER ) then
        	self:PrecacheGibs()
    	end
end

function ENT:OnRemove()
    if ( SERVER ) then
        print("Removed")
    end
end