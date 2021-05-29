--ASF uses this function to set the wear.
--It will pull the settings from ASF automatically then call the handler to actually set the wear.
function NewRaycastWeaponBase:update_wear(wear_tear_value, increment)
	local skin_id = self:get_cosmetics_id()
	if not skin_id then
		return
	end
	
	--Get max/min values from ASF
	local asf_data = AnimatedSkinFramework and AnimatedSkinFramework.skin_data and AnimatedSkinFramework.skin_data[skin_id] or {}
	local max_q = asf_data.max_quality or 1
	local min_q = asf_data.min_quality or 0
	
	--Get whitelist/blacklist from ASF
	local blacklist_type = asf_data.blacklist_type or nil
	local blacklist_id = asf_data.blacklist_id or nil
	local type_is_whitelist = asf_data.type_is_whitelist or false
	local id_is_whitelist = asf_data.id_is_whitelist or false
	
	--Actually set the wear
	self:_update_wear(wear_tear_value, increment, min_q, max_q, blacklist_type, blacklist_id, type_is_whitelist, id_is_whitelist)
end

--Handle the wear setting.
--Generally speaking don't call this directly, just use NewRaycastWeaponBase:update_wear(wear_tear_value, increment) to fill in the arguments automatically.
--wear_tear_value will be clamped to the range [min_q, max_q].
--I'm not going to validate anything else, if you call this manually I assume you know what you're doing.
function NewRaycastWeaponBase:_update_wear(wear_tear_value, increment, min_q, max_q, blacklist_type, blacklist_id, type_is_whitelist, id_is_whitelist)
	--Do the same checks from NewRaycastWeaponBase:_apply_cosmetics()
	self:_update_materials()
	local cosmetics_data = self:get_cosmetics_data()
	if not self._parts or not cosmetics_data or not self._materials or table.size(self._materials) == 0 then
		return
	end
	
	--Initialize the wear
	if not self.wear_tear_value then
		local real_wear = self._cosmetics_quality and tweak_data.economy.qualities[self._cosmetics_quality] and tweak_data.economy.qualities[self._cosmetics_quality].wear_tear_value or 1
		self.wear_tear_value = real_wear
	end
	--If not incrementing, set wear directly
	if not increment then
		self.wear_tear_value = wear_tear_value
	else
		--Increment wear value
		self.wear_tear_value = self.wear_tear_value + wear_tear_value
	end
	
	--Clamp wear. Probably don't need to round.
	if self.wear_tear_value > max_q then
		self.wear_tear_value = max_q
	elseif self.wear_tear_value < min_q then
		self.wear_tear_value = min_q
	end
	
	--Set new wears. Based NewRaycastWeaponBase:_apply_cosmetics()
	for part_id, materials in pairs(self._materials) do
		local part_type = tweak_data.weapon.factory.parts[part_id].type
		
		--jfc never doing this again
		local part_okay
		if not blacklist_type and not blacklist_id then
			--No tables, everything is okay.
			part_okay = true
		elseif blacklist_type and not blacklist_id then
			--Only type table.
			part_okay = not type_is_whitelist
			if table.contains(blacklist_type, part_type) then
				part_okay = not part_okay
			end
		elseif not blacklist_type and blacklist_id then
			--Only part table.
			part_okay = not id_is_whitelist
			if table.contains(blacklist_id, part_id) then
				part_okay = not part_okay
			end
		else
			--Both tables.
			if type_is_whitelist == id_is_whitelist then
				--Both using same type of list. Check if in one of the lists.
				part_okay = not type_is_whitelist
				if table.contains(blacklist_type, part_type) or table.contains(blacklist_id, part_id) then
					part_okay = not part_okay
				end
			else
				--Using different types of list. Part overrides type.
				part_okay = not type_is_whitelist
				--Type check failed
				if table.contains(blacklist_type, part_type) then
					if table.contains(blacklist_id, part_id) then
						--ID check passed
					else
						--No override
						part_okay = not part_okay
					end
				end
			end
		end
		
		--Set wear if part okay
		if part_okay then
			for _, material in pairs(materials) do
				material:set_variable(Idstring("wear_tear_value"), self.wear_tear_value)
			end
		end
	end
	
	--Set wear for akimbo
	if self.AKIMBO and self._second_gun and alive(self._second_gun) then
		self._second_gun:base():_update_wear(wear_tear_value, increment, min_q, max_q, blacklist_type, blacklist_id, type_is_whitelist, id_is_whitelist)
	end
end
