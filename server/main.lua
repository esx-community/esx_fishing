ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_fishing:caughtFish')
AddEventHandler('esx_fishing:caughtFish', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addInventoryItem('fish', 1)
end)

ESX.RegisterUsableItem('fishingrod', function(source)
	local xPlayer  = ESX.GetPlayerFromId(source)
	local baitquantity = xPlayer.getInventoryItem('bait').count
	if baitquantity > 0 then
		TriggerClientEvent('esx_fishing:startFishing', source)
		-- xPlayer.removeInventoryItem('bait', 1)
	else 
		TriggerClientEvent('esx:showNotification', source, "Tu n'as pas assez de appats de poissons.")
	end
end)

ESX.RegisterUsableItem('fish', function(source)

	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('fish', 1)

	TriggerClientEvent('esx_status:add', source, 'hunger', 50000)
	TriggerClientEvent('esx_basicneeds:onEat', source)
	TriggerClientEvent('esx_fishing:onEatFish', source)
	TriggerClientEvent('esx:showNotification', source, 'Vous avez utilisé 1x ~b~Poisson~s~')

end)


RegisterServerEvent('esx_fishing:removeInventoryItem')
AddEventHandler('esx_fishing:removeInventoryItem', function(item, quantity)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem(item, quantity)
end)
