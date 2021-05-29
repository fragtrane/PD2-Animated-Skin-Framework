--Allow saw blades to take textures/stickers from weapon colors
--Fix scaling on some parts (uv_scale)
local orig_WeaponColorTemplates__setup_color_skin_weapons = WeaponColorTemplates._setup_color_skin_weapons
function WeaponColorTemplates._setup_color_skin_weapons(...)
	local weapons = orig_WeaponColorTemplates__setup_color_skin_weapons(...)
	
	--Let me use patterns on the saw blades dammit
	if weapons and weapons.saw then
		weapons.saw.parts = nil
	end
	
	--Fix scaling on Peacemaker
	if weapons and weapons.peacemaker then
		weapons.peacemaker.uv_scale = nil
	end
	
	--Fix scaling on M16 default stock
	if weapons and weapons.m16 and weapons.m16.parts then
		weapons.m16.parts.wpn_fps_m16_s_solid_vanilla = nil
	end
	
	return weapons
end
