shell.run("remoterun.lua", "remoting/identifier.lua")
sleep(1) -- Required to let the workers start
shell.run("identify_workers.lua")

shell.run("remoterun.lua", "remoting/voronoi.lua")
--shell.run("remoterun.lua", "remoting/showpos.lua")
--shell.run("remoterun.lua", "remoting/xor_pattern.lua")
