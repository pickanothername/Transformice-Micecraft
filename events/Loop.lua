local _os_time = os.time
onEvent("Loop", function(elapsed, remaining)
	if modulo.loading then
    if timer == 0 then
      tfm.exec.removeImage(modulo.loadImg[2][3])
      ui.addTextArea(999,
      "", nil,
      50, 200,
      700, 0,
      0x000000,
      0x000000,
      1.0, true
    )
		elseif timer <= awaitTime then
			ui.updateTextArea(999, string.format("<font size='48'><p align='center'><D><font face='Wingdings'>6</font>\n%s</D></p></font>", ({'.', '..', '...'})[((timer/500)%3)+1]), nil) -- Finishing
		else
			eventLoadFinished()
		end
	end
end)

onEvent("Loop", function(elapsed, remaining)
	if timer --[[>=]]% 10000 == 0 and modulo.loading then
		--error("Script loading failed.", 2)
		print(timer)
	end
	
	do
		for _, player in next, room.player do
			if player.isAlive then
				playerLoopUpdate(player)
				
				if modulo.loading then
					if map.chunk[player.currentChunk].activated then
						awaitTime = -1000
					else
						if timer >= awaitTime - 1000 then
							awaitTime = awaitTime + 500
						end
					end
				end
				
				if player.static and _os_time() > player.static then
					playerStatic(player, false)
				end
			end
			
			playerCleanAlert(player)
		end
	
		if _os_time() > map.timestamp + 4000 then
			if modulo.runtimeLapse > 1 then
				print(("<O><b>Runtime reset:</b></O> <D>%d ms</D>"):format(modulo.runtimeLapse))
				modulo.timeout = false
			end
			modulo.runtimeLapse = 0
		end
		
		do
			if modulo.runtimeLapse < modulo.runtimeLimit then
				handleChunksRefreshing()
			end
			
			if modulo.runtimeLapse >= modulo.runtimeLimit then
				for _, player in next, room.player do
					if not player.static then
						playerStatic(player, true)
						playerAlert(player, "<b>Module Timeout", nil, "CEP", 48, 3900)
					end
				end
				modulo.timeout = true
			end
		end
			--[[if tt >= 3 then
			map.loadingTotalTime = map.loadingTotalTime + tt
			map.totalLoads = map.totalLoads + 1
			map.loadingAverageTime = _math_round(map.loadingTotalTime / map.totalLoads, 2)
			if room.isTribe then
				local color
				if tt < 10 then color = "VP" elseif tt >= 10 and tt < 20 then color = "CEP" else color = "R" end
				print(string.format("<V>[Event Loop]</V> Chunks updated in <%s>%d ms</%s> (avg. %f ms)", color, tt, color, map.loadingAverageTime))
			end
		end]]
	end
end)

onEvent("Loop", function(elapsed, remaining)
	local HNDL = actionsHandle
	local lenght = #HNDL
	
	local i, action = 1
	local ok, result
	
	local _table_unpack = table.unpack
	
	while i <= lenght do
		action = HNDL[i]
		if _os_time() >= action[1] then
			if modulo.runtimeLapse < modulo.runtimeLimit then
				local tt = _os_time()
				ok, result = pcall(action[2], _table_unpack(action[3]))
				if not ok then 
					print(("[<D>Warning</D>] %s"):format(result))
				end
				table.remove(HNDL, i)
				lenght = lenght - 1
				
				modulo.runtimeLapse = modulo.runtimeLapse + (_os_time() - tt)
				print(modulo.runtimeLapse)
			else
				break
			end
		else
			i = i + 1
		end
	end
end)

onEvent("Loop", function(elapsed, remaining)
	if globalGrounds > 512 then
		--print("<CEP> Warning! <R>" .. globalGrounds .. "</R> is above the safe physic objects count!")--worldRefreshChunks()
		if globalGrounds >= 712 then -- 512
			error(string.format("Physic system destroyed: <CEP>Limit of physic objects reached:</CEP> <R>%d/512", globalGrounds), 2)
		end
	end
	
	timer = timer + 500
end)