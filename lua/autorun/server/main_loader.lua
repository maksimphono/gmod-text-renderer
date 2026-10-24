include("commands/render_text/render_text.lua")
include("commands/render_text/remove_text.lua")

concommand.Add("render_text", renderText)
concommand.Add("remove_text", removeText)

include("commands/cubes_space/create_cubes_space.lua")
include("commands/cubes_space/remove_cubes_space.lua")

concommand.Add("create_cubes_space", createCubesSpace)
concommand.Add("remove_cubes_space", removeCubesSpace)