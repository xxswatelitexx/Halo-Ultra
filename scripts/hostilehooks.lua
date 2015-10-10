function init() end
function main() end
function die() 
	world.spawnNpc(entity.position(), "elite", "HostileCombatelite", 1)
end
function damage(args) end
function shouldDie()
	return true
end