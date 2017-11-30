ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_fishing:caughtFish')
AddEventHandler('esx_fishing:caughtFish', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addInventoryItem('fish', 1)
end)

ESX.RegisterUsableItem('fishing_rod', function(source)
	TriggerClientEvent('esx_fishing:startFishing', source)
end)

ESX.RegisterUsableItem('fish', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('fish', 1)

	TriggerClientEvent('esx_status:add', source, 'hunger', 50000)
	TriggerClientEvent('esx_basicneeds:onEat', source)
	TriggerClientEvent('esx_fishing:onEatFish', source)
	TriggerClientEvent('esx:showNotification', source, 'Vous avez utilisé 1x ~b~Poisson~s~')

end)
