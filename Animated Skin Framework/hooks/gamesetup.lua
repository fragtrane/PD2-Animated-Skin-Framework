--Don't use the BLT hook anymore because we can't remove it
--Hooks:Add("GameSetupUpdate", "AnimatedSkinFramework_hook_GameSetupUpdate", function(t, dt)

--Hook the update function to set wear
Hooks:PostHook(GameSetup, "update", "AnimatedSkinFramework_post_GameSetup_update", function(self, t, dt)
	--Don't do anything if not ingame and alive
	if managers.platform:presence() ~= "Playing" or not alive(managers.player:player_unit()) then
		return
	end
	
	--Clean hooks for skins which are not equipped
	if not AnimatedSkinFramework.cleaned then
		AnimatedSkinFramework:clean_hooks()
	end
	
	--If we don't have any animated skin equipped, unregister this hook as well
	if not AnimatedSkinFramework:has_any_animated_skin_equipped() then
		Hooks:RemovePostHook("AnimatedSkinFramework_post_GameSetup_update")
		return
	end
	
	--Get skin data
	local weap_base = AnimatedSkinFramework:get_equipped_weap_base()
	local skin_id = weap_base and weap_base:get_cosmetics_id()
	local data = skin_id and AnimatedSkinFramework.skin_data[skin_id]
	
	--Skin data, do stuff
	if data then
		--Check if a custom wear function was specified.
		if data.custom_func then
			wear, increment = data.custom_func(t, dt, weap_base)
			--If the custom function does not return a wear, it means that the wear should not be changed.
			if wear then
				weap_base:update_wear(wear, increment)
			end
			return
		end
		
		--If no preset or custom function, then don't animate.
		if not data.preset then
			return
		end
		
		--Check quality range
		local max_q = data.max_quality or 1
		max_q = math.min(1, max_q)
		local min_q = data.min_quality or 0
		min_q = math.max(0, min_q)
		if max_q <= min_q then
			max_q = 1
			min_q = 0
		end
		
		--Check frequency
		local f = data.frequency or 1
		if f <= 0 then
			f = 1
		end
		--So in principle someone could specify math.huge as the frequency.
		--It shouldn't crash, we should just get a nan as the wear.
		--The clamping code in the NewRaycastWeaponBase:_update_wear function should set it to a valid wear.
		--I'm not going to check because to retain my sanity I need to believe that nobody is dumb enough to try to set the frequency to infinity.
		
		--Check preset
		local preset = data.preset or "sine"
		
		--Calculate wear using preset
		local wear
		if preset == "sawtooth_up" then
			wear = AnimatedSkinFramework:calc_wear_sawtooth_up(t, f, min_q, max_q)
		elseif preset == "sawtooth_down" then
			wear = AnimatedSkinFramework:calc_wear_sawtooth_down(t, f, min_q, max_q)
		elseif preset == "breathe" then
			wear = AnimatedSkinFramework:calc_wear_breathe(t, f, min_q, max_q)
		else
			--Default to sine in case of invalid preset
			wear = AnimatedSkinFramework:calc_wear_sine(t, f, min_q, max_q)
		end
		
		--Set wear and exit the loop
		weap_base:update_wear(wear, false)
	end
end)
