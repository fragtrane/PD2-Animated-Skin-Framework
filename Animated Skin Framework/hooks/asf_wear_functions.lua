--Preset "sawtooth_up"
function AnimatedSkinFramework:calc_wear_sawtooth_up(t, f, min_q, max_q)
	local progress = (t * f) % 1
	return (max_q - min_q) * progress + min_q
end

--Preset "sawtooth_down"
function AnimatedSkinFramework:calc_wear_sawtooth_down(t, f, min_q, max_q)
	local progress = (t * f) % 1
	progress = 1 - progress
	return (max_q - min_q) * progress + min_q
end

--Preset "breathe"
function AnimatedSkinFramework:calc_wear_breathe(t, f, min_q, max_q)
	local progress = (t * f) % 1
	if progress < 0.5 then
		--Use cosine so we start at max float and dip
		local amp = 0.5 * (max_q - min_q)
		local offset = min_q + amp
		--Why does payday still use degrees
		--Scale progress by 2 so we go through a full cosine wave in the first half
		progress = progress * 2 * 360
		return amp * math.cos(progress) + offset
	else
		--Stay at max float in second half
		return max_q
	end
end

--Preset "sine"
function AnimatedSkinFramework:calc_wear_sine(t, f, min_q, max_q)
	local amp = 0.5 * (max_q - min_q)
	local offset = min_q + amp
	local progress = (t * f) % 1
	--Why does payday still use degrees
	progress = progress * 360
	return amp * math.sin(progress) + offset
end
