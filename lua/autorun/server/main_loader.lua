include("commands/render_text/render_text.lua")
include("commands/render_text/remove_text.lua")

concommand.Add("render_text", renderText)
concommand.Add("remove_text", removeText)