/obj/effect/decal/cleanable
	var/list/random_icon_states = list()

/obj/effect/decal/cleanable/New()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	var/area/A = get_area_master(src)
	if(A.shadow)	//find if we are in shdow rune
		var/obj/effect/rune/rune = A.shadow_rune
		rune.shadow_stuff += src
		invisibility = 55
	..()