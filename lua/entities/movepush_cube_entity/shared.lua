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

-- This code runs whenever the entity is created.
function ENT:Initialize()
	

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
		
		cube:GetPhysicsObject():SetVelocity(Vector(cubeSize, 0, 0) * 10)
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