local currentQuickbarSlot = 0;

local function createOrUpdateBarPointer(currentQuickbarSlot, event)
	local player = game.players[event.player_index]
	local guiElement = player.gui.screen["bar-pointer"]
	
	if guiElement == nil then
		player.gui.screen.add{type="label", name="bar-pointer", caption="v"}
		guiElement = player.gui.screen["bar-pointer"]
	end
	
	local xLocation = (.40 * player.display_resolution.width) + (40 * ((currentQuickbarSlot - 1) % 10))
	local yLocation = .82 * player.display_resolution.height + (math.floor((currentQuickbarSlot - 1) / 10) * 60)
	guiElement.location = {xLocation, yLocation}
end


local function updateQuickbar(increasing, event)
    local player = game.players[event.player_index]
	local updatedQuickbar = false
	local noValidQuickbarSlots = false;
	local initialQuickbarSlot = currentQuickbarSlot
	if initialQuickbarSlot == 0 then
		initialQuickbarSlot = 1
	end
	local increment = -1
	if increasing then
		increment = 1
	end
	
	while not updatedQuickbar and not noValidQuickbarSlots do
		currentQuickbarSlot = currentQuickbarSlot + increment
		if currentQuickbarSlot > 20 then
			currentQuickbarSlot = 1
		end
		if currentQuickbarSlot < 1 then
			currentQuickbarSlot = 20
		end
		if currentQuickbarSlot == initialQuickbarSlot then
			noValidQuickbarSlots = true
		end
		
		local itemType = player.get_quick_bar_slot(currentQuickbarSlot)
		if itemType ~= nil then
			local inventoryStack = player.get_main_inventory().find_item_stack(itemType.name)
			if inventoryStack ~= nil then
				player.cursor_stack.swap_stack(inventoryStack)
				updatedQuickbar = true
				createOrUpdateBarPointer(currentQuickbarSlot, event)
			end
		end
	end
end

script.on_event("next-quickbar-hotkey", function(event)
	updateQuickbar(true, event)
end)

script.on_event("previous-quickbar-hotkey", function(event) 
	updateQuickbar(false, event)
end)

script.on_event("set-quickbar-from-cursor-stack", function(event) 
	local player = game.players[event.player_index]
	local updatedQuickbar = false
	local quickbarSlotToCheck = 0
	
	while not updatedQuickbar and quickbarSlotToCheck < 20 do
		quickbarSlotToCheck = quickbarSlotToCheck + 1
		local itemType = player.get_quick_bar_slot(quickbarSlotToCheck)
		if itemType == nil then
			player.set_quick_bar_slot(quickbarSlotToCheck, player.cursor_stack)
			updatedQuickbar = true
		end
	end
end)

script.on_event("clear-current-quickbar-slot", function(event) 
	local player = game.players[event.player_index]
	
	if currentQuickbarSlot ~= 0 then
		player.set_quick_bar_slot(currentQuickbarSlot, nil)
	end
end)