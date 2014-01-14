/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "drains the life from"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = 0
	//luminosity = 2
	see_in_dark = 7
	stop_automated_movement = 1
	status_flags = 0
	faction = "cult"
	status_flags = CANPUSH
	
/mob/living/simple_animal/shade/Bump(var/atom/obstacle)
	//if(canmove && !obstacle.CanPass(src,obstacle.loc,1))
	spawn()
		if(canmove)
			canmove = 0
			flick("shadow", src)
			//anim(src.loc,src,'icons/mob/mob.dmi',,"shadow",,src.dir)
			src.loc = get_step(src,src.dir)
			sleep(10)
			canmove = 1
		
/mob/living/simple_animal/shade/UnarmedAttack(var/atom/A, var/proximity_flag)
	if(A == src)
		return
	..()
	if(CanAttack(A))
		src.heal_organ_damage(5,0)		//small heal from drain
	if(istype(A,/obj/effect/rune))
		var/obj/effect/rune/R = A
		R.shade_attack(src)
	if(istype(A,/obj/item/device/soulstone))
		var/obj/item/device/soulstone/S = A
		S.transfer_soul("SHADE", src, src)

		
	
/mob/living/simple_animal/shade/Life()
	..()
	if(stat == 2)
		new /obj/item/weapon/ectoplasm (src.loc)
		for(var/mob/M in viewers(src, null))
			if((M.client && !( M.blinded )))
				M.show_message("\red [src] lets out a contented sigh as their form unwinds. ")
				ghostize()
		del src
		return


/mob/living/simple_animal/shade/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("SHADE", src, user)
	else
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			health -= damage
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with [O] by [user]. ")
		else
			usr << "\red This weapon is ineffective, it does no damage."
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red [user] gently taps [src] with [O]. ")
	return
