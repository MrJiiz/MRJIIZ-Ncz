local zones = {
	{ ['x'] = 445.52, ['y'] = -983.71, ['z'] = 30.69},
	{ ['x'] = 225.92, ['y'] = -787.15, ['z'] = 30.19 },
	{ ['x'] = 1105.19, ['y'] = 218.61, ['z'] = -48.99 },
	{ ['x'] = 298.39, ['y'] = -584.43, ['z'] = 43.26 }
}

local inncz = false
local outncz = false
local closestZone = 1

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	for i = 1, #zones, 1 do
		local radius = 60.0
		local mjBlip = AddBlipForRadius(zones[i].x, zones[i].y, zones[i].z, radius)
		SetBlipColour(mjBlip, 48)
		SetBlipAlpha (mjBlip, 128)
		SetBlipAsShortRange(mjBlip, true)
	end
end)

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #zones, 1 do
			dist = Vdist(zones[i].x, zones[i].y, zones[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
		Citizen.Wait(15000)
	end
end)

Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		Citizen.Wait(0)
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, x, y, z)
		local vehicle = GetVehiclePedIsIn(player, false)
	
		if dist <= 60.0 then 
			if not inncz then
				NetworkSetFriendlyFireOption(false)
				--SetEntityAlpha(player, 200, false)
				DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
				DisablePlayerFiring(player,true) -- Disables firing all together if they somehow bypass inzone Mouse Disable
				DisableControlAction(0, 106, true) -- Disable in-game mouse controls
				DisableControlAction(0, 140, true) -- Disable R
				EnableControlAction(0, 163, true)
				if GetVehiclePedIsIn(player, false) then
					local limitsp = 9999.076344490051
					SetEntityMaxSpeed(vehicle, limitsp)
					--SetEntityAlpha(vehicle, 200, false)
				end
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
				inncz = true
				outncz = false
			end
		else
			if not outncz then
				NetworkSetFriendlyFireOption(true)
				--ResetEntityAlpha(player)
				if GetVehiclePedIsIn(player, false) then
					maxSpeed = GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel")
					SetEntityMaxSpeed(vehicle, maxSpeed)
					--ResetEntityAlpha(vehicle)
				end
				outncz = true
				inncz = false
			end
		end
		if inncz then
			DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
			DisablePlayerFiring(player,true) -- Disables firing all together if they somehow bypass inzone Mouse Disable
			DisableControlAction(0, 106, true) -- Disable in-game mouse controls
			DisableControlAction(0, 140, true) -- Disable R
			EnableControlAction(0, 163, true)
			if IsDisabledControlJustPressed(2, 37) then
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
			end
			--SetEntityAlpha(player, 200, false)
			if GetVehiclePedIsIn(player, false) then
				local limitsp = 999.076344490051
				SetEntityMaxSpeed(vehicle, limitsp)
				--SetEntityAlpha(vehicle, 200, false)
			end
			if IsDisabledControlJustPressed(0, 106) then
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
			end
		end
	end
end)
