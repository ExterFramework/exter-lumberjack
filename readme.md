# NPC Contact
```lua
{
	name = "Axel Woodstone",
	text = "Hey there, I don't believe we've met before. My name's Axel, and I run this lumberyard. Are you interested in joining our team or just here to track your progress as a lumberjack?",
	domain = "Lumberjack",
	ped = "a_m_m_hillbilly_01",
	scenario = "WORLD_HUMAN_BUM_STANDING",
	police = true,
	coords = vector4(-580.5613, 5368.8198, 69.3830, 340.4991),
	options = {
		{
			label = "I want to work",
			requiredrep = 0,
			type = "add",
			event = "",
			data = {
				text = "Ready for a day of hard work?",
				options = {
					{
						label = "Sign In/Out",
						requiredrep = 0,
						event = "exter-lumberjack:Sign",
						type = "client",
						args = {} 
					},
					{
						label = "Leave conversation",
						event = "",
						type = "none",
						args = {} 
					},
					
				}
			},
			args = {} 		
		},
		{
			label = "Open Shop", 
			requiredrep = 0,
			type = "shop", 
			items = {
				{
					name = "axe",
					description = "Tools",
					requiredrep = 0,
					price = 350
				},		
			},
			event = "",
			args = {}
		},
		{
			label = "Rent Bison",
			requiredrep = 0,
			event = "exter-lumberjack:rentBison",
			type = "client",
			args = {} 
		},
		{
			label = "Sell",
			requiredrep = 0,
			event = "exter-lumberjack:sellWood",
			type = "server",
			args = {} 
		},
		{
			label = "Leave conversation",
			requiredrep = 0,
			type = "none",
			args = {} 
		},
		
	}
},
```

# Item

```lua
axe = { name = 'axe', label = 'Axe', weight = 500, type = 'item', image = 'np_axe.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'A sharp axe.' },

log = { name = 'log', label = 'Log', weight = 500, type = 'item', image = 'np_log.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'A fresh cut tree log.' },

cleanlog = { name = 'cleanlog', label = 'Clean Log', weight = 500, type = 'item', image = 'np_log.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'A clean log.' },

rawplank = { name = 'rawplank', label = 'Raw Wodden Plank', weight = 500, type = 'item', image = 'np_wood.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'A raw wodden plank.' },

sandedplank = { name = 'sandedplank', label = 'Sanded Wooden Plank', weight = 500, type = 'item', image = 'np_wood.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },

finishwood = { name = 'finishwood', label = 'Wood', weight = 500, type = 'item', image = 'np_wood.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = '' },
```

# Add this change in the server side script if you're using a qb-inventory or an edit of it!   !!! VERY IMPORANT !!!

```lua
local function SaveStashItems(stashId, items)
	if (Stashes[stashId] and Stashes[stashId].label == "Stash-None") or not items then return end

	for _, item in pairs(items) do
		item.description = nil
	end

	MySQL.insert('INSERT INTO stashitems (stash, items) VALUES (:stash, :items) ON DUPLICATE KEY UPDATE items = :items', {
		['stash'] = stashId,
		['items'] = json.encode(items)
	})

	if Stashes[stashId] then
		Stashes[stashId].isOpen = false
	end
end

RegisterNetEvent('inventory:server:SetStashItems', function(stashId, items)
	SaveStashItems(stashId, items)
end)

````