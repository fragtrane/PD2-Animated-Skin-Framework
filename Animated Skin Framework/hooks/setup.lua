if _G.AnimatedSkinFramework then
	return
end

_G.AnimatedSkinFramework = {}

--Initialize skin_data table
AnimatedSkinFramework.skin_data = {}

--Hook cleanup
AnimatedSkinFramework.hooks = {}
AnimatedSkinFramework.cleaned = false

--Set up the wear calculation functions
dofile(ModPath .. "hooks/asf_wear_functions.lua")

--Clean up hooks that are not being used
function AnimatedSkinFramework:clean_hooks()
	--We already check before calling this function but leave this here just in case
	if self.cleaned then
		return
	end
	for skin_id, data in pairs(self.hooks) do
		if not self:has_animated_skin_equipped(skin_id) then
			for _, hook_id in pairs(data.post or {}) do
				--Clean PostHook
				Hooks:RemovePostHook(hook_id)
				--log("ASF Removed: " .. hook_id)
			end
			for _, hook_id in pairs(data.pre or {}) do
				--Clean PreHook
				Hooks:RemovePreHook(hook_id)
				--log("ASF Removed: " .. hook_id)
			end
		end
	end
	self.cleaned = true
end

--Check if at least one animated skin is equipped, use to remove GameSetup:update() hook
function AnimatedSkinFramework:has_any_animated_skin_equipped()
	--Check playing and not custody
	if managers.platform:presence() == "Playing" and alive(managers.player:player_unit()) then
		--Check weapons, adapted from PlayerStandard:inventory_clbk_listener
		local plr_state = managers.player:player_unit():movement():current_state()
		for id, weapon in pairs(plr_state._ext_inventory:available_selections()) do
			local skin_id = weapon.unit:base():get_cosmetics_id()
			if skin_id and self.skin_data[skin_id] then
				return true
			end
		end
		--No animated skin
		return false
	end
	--Just in case this check is called when not playing
	return true
end

--Check if a specific skin is equipped, use to remove hooks
function AnimatedSkinFramework:has_animated_skin_equipped(skin_id)
	--Check playing and not custody
	if managers.platform:presence() == "Playing" and alive(managers.player:player_unit()) then
		--Check weapons, adapted from PlayerStandard:inventory_clbk_listener
		local plr_state = managers.player:player_unit():movement():current_state()
		for id, weapon in pairs(plr_state._ext_inventory:available_selections()) do
			if weapon.unit:base():get_cosmetics_id() == skin_id then
				return true
			end
		end
		--No animated skin
		return false
	end
	--Just in case this check is called when not playing
	return true
end

--Get weapon base of currently equipped weapon
function AnimatedSkinFramework:get_equipped_weap_base()
	--Check playing and not custody
	if managers.platform:presence() == "Playing" and alive(managers.player:player_unit()) then
		local plr_state = managers.player:player_unit():movement():current_state()
		local weap_base = alive(plr_state._equipped_unit) and plr_state._equipped_unit:base()
		return weap_base
	end
end

--Get current skin ID and weapon ID. Probably won't be using this much.
function AnimatedSkinFramework:get_equipped_ids()
	local weap_base = self:get_equipped_weap_base()
	local skin_id = weap_base and weap_base:get_cosmetics_id()
	local weapon_id = weap_base and weap_base._name_id
	return skin_id, weapon_id
end

--Generally just use this if you want to set the wear manually.
--If your current weapon matches the skin_id, the wear will be set.
--blacklist/whitelist will be pulled
--Set the wear on currently equipped weapon if the skin matches skin_id
function AnimatedSkinFramework:set_wear(skin_id, wear, increment)
	local weap_base = self:get_equipped_weap_base()
	if weap_base and weap_base:get_cosmetics_id() == skin_id then
		weap_base:update_wear(wear, increment)
	end
end
