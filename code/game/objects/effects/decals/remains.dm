/obj/effect/decal/remains
	name = "remains"
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'
	anchored = 1
	
/obj/effect/decal/remains/New()
	var/area/A = get_area_master(src)
	if(A.shadow)	//find if we are in shdow rune
		var/obj/effect/rune/rune = A.shadow_rune
		rune.shadow_stuff += src
		invisibility = 55
	..()

/obj/effect/decal/remains/human
	desc = "They look like human remains. They have a strange aura about them."
	icon_state = "remains"

/obj/effect/decal/remains/xeno
	desc = "They look like the remains of something... alien. They have a strange aura about them."
	icon_state = "remainsxeno"

/obj/effect/decal/remains/robot
	desc = "They look like the remains of something mechanical. They have a strange aura about them."
	icon = 'icons/mob/robots.dmi'
	icon_state = "remainsrobot"