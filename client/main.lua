ESX                    = nil
local SuccessLimit     = 0.09 -- Maxim 0.1 (high value, low success chances)
local AnimationSpeed   = 0.0015
local ShowChatMSG      = true -- or false

local IsFishing, CFish = false, false
local BarAnimation, Faketimer = 0, 0
local RunCodeOnly1Time = true
local PosX = 0.5
local PosY, TimerAnimation = 0.1, 0.1

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function GetCar() return GetVehiclePedIsIn(GetPlayerPed(-1), false) end


-- Init playerdata & job
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

-- end init playerdata & job

function GetPed() return GetPlayerPed(-1) end

function text(x,y,scale,text)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(255,255,255,255)
    SetTextDropShadow(0,0,0,0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function FishGUI(bool)
	if not bool then return end
	DrawRect(PosX,PosY+0.005,TimerAnimation,0.005,255,255,0,255)
	DrawRect(PosX,PosY,0.1,0.01,0,0,0,255)
	TimerAnimation = TimerAnimation - 0.0001025
	if BarAnimation >= SuccessLimit then
		DrawRect(PosX,PosY,BarAnimation,0.01,102,255,102,150)
	else
		DrawRect(PosX,PosY,BarAnimation,0.01,255,51,51,150)
	end
	if BarAnimation <= 0 then
		up = true
	end
	if BarAnimation >= PosY then
		up = false
	end
	if not up then
		BarAnimation = BarAnimation - AnimationSpeed
	else
		BarAnimation = BarAnimation + AnimationSpeed
	end
	text(0.4,0.05,0.35, "Vous en avez un, ferrez-le en appuyant sur [E]")
end

function PlayAnim(ped,base,sub,nr,time) 
	Citizen.CreateThread(function() 
		RequestAnimDict(base) 
		while not HasAnimDictLoaded(base) do 
			Citizen.Wait(1) 
		end
		if IsEntityPlayingAnim(ped, base, sub, 3) then
			ClearPedSecondaryTask(ped) 
		else 
			for i = 1,nr do 
				TaskPlayAnim(ped, base, sub, 8.0, -8, -1, 16, 0, 0, 0, 0) 
				Citizen.Wait(time) 
			end 
		end 
	end) 
end

function AttachEntityToPed(prop,bone_ID,x,y,z,RotX,RotY,RotZ)
	BoneID = GetPedBoneIndex(GetPed(), bone_ID)
	obj = CreateObject(GetHashKey(prop),  1729.73,  6403.90,  34.56,  true,  true,  true)
	vX,vY,vZ = table.unpack(GetEntityCoords(GetPed()))
	xRot, yRot, zRot = table.unpack(GetEntityRotation(GetPed(),2))
	AttachEntityToEntity(obj,  GetPed(),  BoneID, x,y,z, RotX,RotY,RotZ,  false, false, false, false, 2, true)
	return obj
end

RegisterNetEvent('esx_fishing:startFishing')
AddEventHandler('esx_fishing:startFishing', function()
	if PlayerData.job ~= nil and PlayerData.job.name == 'fisherman' then
		if not IsPedInAnyVehicle(GetPed(), false) then
			if not IsPedSwimming(GetPed()) then
				if IsEntityInWater(GetPed()) then
					TriggerServerEvent('esx_fishing:removeInventoryItem','bait', 1)
					if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
						ESX.UI.Menu.Close('default', 'es_extended', 'inventory')
					end

					if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory_item') then
						ESX.UI.Menu.Close('default', 'es_extended', 'inventory_item')
					end

					IsFishing = true
					if ShowChatMSG then ESX.ShowNotification("Vous avez lancé votre appât, attendez qu'un poisson morde ...") end
					RunCodeOnly1Time = true
					BarAnimation = 0

				else
					ESX.ShowNotification('Action impossible, vous devez être dans l\'eau')
				end
			else
				ESX.ShowNotification('Action impossible')
			end
		else
			ESX.ShowNotification('Action impossible')
		end
	else
		ESX.ShowNotification("Vous devez etre poissonier pour pêcher.")
	end
end)

RegisterNetEvent('esx_fishing:onEatFish')
AddEventHandler('esx_fishing:onEatFish', function()
	
	local playerPed = GetPlayerPed(-1)
	local health    = GetEntityHealth(playerPed) + 25

	SetEntityHealth(playerPed,  health)

end)

Citizen.CreateThread(function()
	while true do Citizen.Wait(1)

		while IsFishing do
			local time = 4*3000
			TaskStandStill(GetPed(), time+7000)
			FishRod = AttachEntityToPed('prop_fishing_rod_01',60309, 0,0,0, 0,0,0)
			PlayAnim(GetPed(),'amb@world_human_stand_fishing@base','base',4,3000)
			Citizen.Wait(time)
			CFish = true
			IsFishing = false
		end

		while CFish do
			Citizen.Wait(1)
			FishGUI(true)
			if RunCodeOnly1Time then
				Faketimer = 1
				PlayAnim(GetPed(),'amb@world_human_stand_fishing@idle_a','idle_c',1,0) -- 10sec
				RunCodeOnly1Time = false
			end
			if TimerAnimation <= 0 then
				CFish = false
				TimerAnimation = 0.1
				StopAnimTask(GetPed(), 'amb@world_human_stand_fishing@idle_a','idle_c',2.0)
				Citizen.Wait(200)
				DeleteEntity(FishRod)
				if ShowChatMSG then ESX.ShowNotification("Le poisson s'est échappé ...") end
			end
			if IsControlJustPressed(1, 38) then
				if BarAnimation >= SuccessLimit then
					CFish = false
					TimerAnimation = 0.1
					if ShowChatMSG then ESX.ShowNotification("Vous avez attrapé un poisson !") end
					StopAnimTask(GetPed(), 'amb@world_human_stand_fishing@idle_a','idle_c',2.0)
					Citizen.Wait(200)
					DeleteEntity(FishRod)

					TriggerServerEvent('esx_fishing:caughtFish')

				else
					CFish = false
					TimerAnimation = 0.1
					StopAnimTask(GetPed(), 'amb@world_human_stand_fishing@idle_a','idle_c',2.0)
					Citizen.Wait(200)
					DeleteEntity(FishRod)
					if ShowChatMSG then ESX.ShowNotification("Le poisson s'est échappé !") end
				end
			end
		end
	end
end)

Citizen.CreateThread(function() -- Thread for  timer
	while true do 
		Citizen.Wait(1000)
		Faketimer = Faketimer + 1 
	end 
end)
