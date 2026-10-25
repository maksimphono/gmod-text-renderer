AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

DEFAULT_CUBE_NAME = "__cube__"

-- The name that appears in the spawnmenu.
ENT.PrintName   = "move_push_cube"

ENT.Information = "Render text using cubes"

ENT.Autho	= "maksimphono"


ENT.Spawnable = true

-- The category the entity is located in within the spawnmenu.
ENT.Category = "Other"

-- This code runs whenever the entity is created.
function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_PUSH)
	self:SetAngles(Angle(0,0,0))
	self:SetName(DEFAULT_CUBE_NAME)
	local phys = self:GetPhysicsObject()
	phys:SetMass(9999)
	phys:EnableMotion(true)
	phys:Wake()

	-- Only set up physics on the server since it tends to create weird issues if you do it on the client.
	if SERVER then
		if self.SpawnArgument == nil then
			self.SpawnArgument = {}
		end
		self.SpawnArgument.pos = self.SpawnArgument.pos or Vector(0,0,0)
		self.SpawnArgument.model = self.SpawnArgument.model or "models/hunter/blocks/cube025x025x025.mdl"

		self:SetPos(self.SpawnArgument.pos)
		self:SetModel(self.SpawnArgument.model)

	end
end

function ENT:OnRemove()
	if ( SERVER ) then
		print("Removed")
	end
end