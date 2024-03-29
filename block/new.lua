blockNew = function(x, y, type, damage, ghost, glow, translucent, mossy, chunk, yr, idoffset)
	local xp, yp = getTruePosMatrix(chunk, x, y)
	yp = worldHeight - yp
	
	
	local tang = (not ghost)
	local meta = objectMetadata[type]
	
	local id = ((x-1) * blockSize) + y
	local block = {
		x = xp,
		y = yp,
		rx = x,
		ry = y,
		
		id = id,
		gid = idoffset + id,
		act = tang and -1 or 0,
		chunk = chunk,

		type = type,
		ghost = ghost,
		glow = glow,
		translucent = translucent,
		mossy = mossy,
		
		isTangible = tang,
		
		damage = damage or 0,
		damagePhase = 0,
		durability = meta.durability,
		
		shadowness = (ghost and not translucent) and 0.33 or 0,
		sprite = {},
		alpha = 1.0,
		dx = xp * blockSize,
		dy = ((yr-1) * blockSize) + worldVerticalOffset,
		
		hardness = meta.hardness,
		drop = meta.drop,
		
		timestamp = 0,
		event = 0,
		
		interact = meta.interact,
		handle = meta.handle,
		
		onInteract = meta.onInteract,
		onDestroy = meta.onDestroy,
		onCreate = meta.onCreate,
		onPlacement = meta.onPlacement,
		onHit = meta.onHit,
		onUpdate = meta.onUpdate,
		onDamage = meta.onDamage,
		onContact = meta.onContact,
		onAwait = meta.onAwait
	}
	
	--[[if type ~= 0 then
		local chunkk = map.chunk[chunk]
		block.shadowness = (distance(0, yp, 0, surfacePoint)/8)*0.67--128
		if block.shadowness > 0.67 then block.shadowness = 0.67 end
	end]]
	block.sprite = {
		[1] = {
			block.type ~= 0 and meta.sprite or nil,
			nil, --block.type >= 1 and mossSprites[--[[map.chunk[chunk].biome]]1] or nil,
			shadowSprite,
			nil,
		},
		[2] = {
		}
	}
	
	return block
end