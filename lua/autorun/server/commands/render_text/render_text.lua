function renderText(ply, cmd, args)
	local ent = ents.Create("text_entity")
	if not IsValid(ent) then return end
	ent.SpawnArgument = {["text"] = args[1], ["name"] = args[2]}
	ent:Spawn()
	print("Spawned " .. args[1])
end