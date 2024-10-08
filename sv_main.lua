lib.locale()

ESX.RegisterCommand(Config.refillCommand, 'admin', function(xPlayer, args, showError)
    if args.value > 100 then
        return xPlayer and xPlayer.showNotification('Max value is 100') or print('Max value is 100')
    end
	args.playerId.triggerEvent('ed_scuba:oxygenHandle', 'refill', args.value)
end, true, {help = 'Refill oxygen tank', validate = true, arguments = {
	{name = 'playerId', help = 'The player id', type = 'player'},
	{name = 'value', help = 'Value percentage of refill capacity', type = 'number'}
}})

ESX.RegisterCommand(Config.checkCommand, 'user', function(xPlayer, args, showError)
	xPlayer.triggerEvent('ed_scuba:oxygenHandle', 'check', args.value)
end, false, {help = 'Refill oxygen tank', validate = true, arguments = {}})

if Config.OxInventory then
	local current_scuba = {}
	local hookId = exports["ox_inventory"]:registerHook('swapItems', function(payload)
        -- print(json.encode(payload, { indent = true }))
		if payload.fromType == "player" then
			if current_scuba[payload.source] and current_scuba[payload.source] == payload.fromSlot.slot then
				local newSlot = nil
				if payload.fromInventory == payload.toInventory then
					newSlot = payload.toSlot
				end
				current_scuba[payload.source] = newSlot
				TriggerClientEvent("ed_scuba:updateCurrent", payload.source, {slot = newSlot})
			end
		end
        return true
    end, {})

	AddEventHandler("onResourceStop", function(resource)
		if GetCurrentResourceName() ~= resource then
			return
		end
		if hookId ~= nil then
			exports["ox_inventory"]:removeHooks(hookId)
		end
	end)

	RegisterNetEvent("ed_scuba:equip", function(data)
		local source = source
		if data.slot == nil then
			return
		end
		current_scuba[source] = data.slot
	end)

	RegisterNetEvent('ed_scuba:updateMetadata', function(data)
		local source = source
		if data.oxy == nil or data.slot == nil then
			return
		end
		if current_scuba[source] == nil then
			return
		end
		if current_scuba[source] ~= data.slot then
			return
		end
		local metadata = {
			oxy = data.oxy,
			description = ("Oxy Capacity: %s%%"):format(ESX.Round(data.oxy, 2))
		}
		exports["ox_inventory"]:SetMetadata(source, current_scuba[source], metadata)
	end)
else
	ESX.RegisterUsableItem(Config.scubaItemName, function(source)
		local source = source
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then
			return
		end
		xPlayer.triggerEvent('ed_scuba:useItem', Config.scubaItemName)
	end)

	ESX.RegisterUsableItem(Config.finsItemName, function(source)
		local source = source
		local xPlayer = ESX.GetPlayerFromId(source)
		if not xPlayer then
			return
		end
		xPlayer.triggerEvent('ed_scuba:useItem', Config.finsItemName)
	end)
end

RegisterNetEvent('ed_scuba:oxygenRefillPay', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return
	end
	local canPay = xPlayer.getMoney() >= Config.refillPrice
	if not canPay then
		return xPlayer.showNotification(locale('no_money'))
	end
	xPlayer.removeMoney(Config.refillPrice)
	xPlayer.triggerEvent('ed_scuba:oxygenHandle', 'refill', 100)
	xPlayer.showNotification(locale('push_refill_pay').. Config.Currency .. Config.refillPrice)
end)


RegisterNetEvent('ed_scuba:prixtenuesplongee', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return
	end
	local canPay = xPlayer.getMoney() >= Config.refillPrice
	if not canPay then
		return xPlayer.showNotification(locale('no_money'))
	end
	xPlayer.removeMoney(Config.prixTenuedeplongee)
	xPlayer.addInventoryItem(Config.scubaItemName, 1)
end)

RegisterNetEvent('ed_scuba:prixpalmesplongee', function()
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return
	end
	local canPay = xPlayer.getMoney() >= Config.refillPrice
	if not canPay then
		return xPlayer.showNotification(locale('no_money'))
	end
	xPlayer.removeMoney(Config.prixpalmesplongee)
	xPlayer.addInventoryItem(Config.finsItemName, 1)
end)