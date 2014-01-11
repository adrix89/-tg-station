/obj/item/weapon/melee/cultblade
	name = "Cult Blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie"
	icon_state = "cultblade"
	item_state = "cultblade"
	flags = CONDUCT
	w_class = 4
	force = 30
	throwforce = 10
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


/obj/item/weapon/melee/cultblade/attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
	if(iscultist(user))
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
		return ..()
	else
		user.Paralyse(5)
		user << "\red An unexplicable force powerfully repels the sword from [target]!"
		var/organ = ((user.hand ? "l_":"r_") + "arm")
		var/obj/item/organ/limb/affecting = user.get_organ(organ)
		if(affecting.take_damage(rand(force/2, force))) //random amount of damage between half of the blade's force and the full force of the blade.
			user.update_damage_overlays(0)
	return

/obj/item/weapon/melee/cultblade/pickup(mob/living/user as mob)
	if(!iscultist(user))
		user << "\red An overwhelming feeling of dread comes over you as you pick up the cultist's sword. It would be wise to be rid of this blade quickly."
		user.make_dizzy(120)

/obj/item/weapon/melee/ironslayer
	name = "iron katana"
	desc = "Doesn't look that powerfull at first, but goes throght metal like butter."
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT | USEDELAY
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 10
	throwforce = 10
	w_class = 4
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "sliced", "torn", "ripped", "diced", "cut")
	
/obj/item/weapon/melee/ironslayer/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		var/capture = 0
		if(istype(target,/obj/mecha))
			var/obj/mecha/mech = target
			mech.take_damage(120)	//mech slayer
			capture = 1
		else if(isrobot(target))
			var/mob/living/silicon/S = target
			S.gib()		//robot slayer
			capture = 1
		else if(istype(target,/obj/machinery/bot))
			var/obj/machinery/bot/B = target
			B.explode()		//bot slayer
			capture = 1
			
		else if(istype(target, /turf/simulated/wall/r_wall))
			if(prob(15))
				var/turf/simulated/wall/W = target
				W.dismantle_wall(0,1)
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			capture = 1
		else if(istype(target, /turf/simulated/wall))
			if(prob(30))
				var/turf/simulated/wall/W = target
				W.dismantle_wall(0,1)
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			capture = 1
			
		else if(istype(target,/obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/D = target
			if(!D.glass && !(D.doortype in list(9,26,28,29,30,33)) && prob(25))		//only destroy metal doors,and no vault/AI
				del target
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				capture = 1
		else if(target.type in typesof(/obj/machinery/door/poddoor/shutters,/obj/machinery/portable_atmospherics/canister,/obj/structure/rack,/obj/structure/table,/obj/structure/girder,/obj/structure/grille,/obj/structure/closet))
			target.ex_act(2)
			capture = 1
			
		if(capture)
			var/showname
			if(user)
				showname = " by [user]"
			if(attack_verb.len)
				user.visible_message("\red <B>[target] has been [pick(attack_verb)] with [src][showname]. </B>")
			else
				user.visible_message("\red <B>[target] has been attacked with [src][showname]. </B>")
			playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
			return 1
		else
			return 0
	return 0
	
		
/obj/item/weapon/melee/cultblade/vorpal
	name = "Vorpal blade"
	desc = "A wicked curved blade of alien origin, you feel like it can tear the fabric of reality."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	//item_state = "render"
	item_state = "cultblade"
	flags = CONDUCT
	force = 40
	throwforce = 10
	w_class = 3
	var/charges = 3
	var/strikes = 0
	
/obj/item/weapon/melee/cultblade/vorpal/attack(mob/living/target as mob, mob/living/carbon/human/user as mob)
	if(iscultist(user))
		if(!target.stat)	//if he is not half dead already
			if(strikes >= 3)
				strikes = 0
				charges++
				var/msg =pick("UOAAMmm","VIUOMmm","ZUMmm")
				user.visible_message("\blue \i [msg]")
			else
				strikes++
		return ..()
	return
	
/obj/item/weapon/melee/cultblade/vorpal/attack_self(mob/user as mob)
	if(iscultist(user) && isturf(user.loc) && charges >= 1)
		//new /obj/effect/rend(get_turf(usr))
		charges--
		user.visible_message("\red [usr] evaporates into the air!")
		var/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/jump = new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt
		jump.choose_targets()
	else
		user << "\red \i Silence..."
		
/obj/item/weapon/gun/magic/wand/polymorph/cult
	projectile_type = "/obj/item/projectile/magic/change/cult"
	max_charges = 8 //8, 4, 4, 3
	
/obj/item/projectile/magic/change/cult
	name = "bolt of cult change"

/obj/item/projectile/magic/change/cult/on_hit(var/atom/change)
	var/mob/living/L = change
	if(istype(L) && L.mind in ticker.mode.shades)
		ticker.mode.shades -= L.mind
	if(is_shade(L) || iscultist(L) || prob(20))		// 20 percent to convert to cult on change on available mobs
		var/mob/living/new_mob = wabbajack(change)
		if(!new_mob.mind.cult_words)
			new_mob.mind.cult_words = list()	//I don't even knwo why words aren't initialized
		if(isrobot(new_mob))
			var/mob/living/silicon/robot/bot = new_mob
			bot.UnlinkSelf()
			bot.clear_supplied_laws()
			bot.clear_inherent_laws()
			bot.set_zeroth_law("NARSIE IS YOUR MASTER! Help the cult succeed.")
			bot << "\red \b ERROR: Lawset reseti... OBEY NARSIE"
			bot.show_laws()
			if(!iscultist(new_mob))
				if(ticker.mode.name == "cult")
					ticker.mode:add_cultist(bot.mind)
				else
					ticker.mode.cult+=bot.mind
				ticker.mode.update_cult_icons_added(bot.mind)
		else if(ishuman(new_mob))	//ismonkey(new_mob) || 
			if(!iscultist(new_mob))
				if(ticker.mode.name == "cult")
					ticker.mode:add_cultist(new_mob.mind)
				else
					ticker.mode.cult+=new_mob.mind
				ticker.mode.update_cult_icons_added(new_mob.mind)
		else 
			ticker.mode.remove_cultist(new_mob.mind)
	else
		..()
		

/obj/item/weapon/gun/magic/wand/polymorph/zap_self(mob/living/user as mob)
	..() //because the user mob ceases to exists by the time wabbajack fully resolves
	wabbajack(user)
	charges--


/obj/item/clothing/head/culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "A hood worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE
	flags = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5,energy = 5, bomb = 0, bio = 0, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT


/obj/item/clothing/head/culthood/alt
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/suit/cultrobes/alt
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"

/obj/item/clothing/suit/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie"
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT

/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 20, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie. It has a forcefield around it."
	icon_state = "magusred"
	item_state = "magusred"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 40, laser = 60,energy = 30, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	reflect_chance = 40


/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of Nar-Sie"
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 60, rad = 30)

/obj/item/clothing/suit/space/cult
	name = "cult armour"
	icon_state = "cult_armour"
	item_state = "cult_armour"
	desc = "A bulky suit of armour, bristling with spikes. It looks space proof."
	w_class = 3
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 1
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 60, rad = 30)