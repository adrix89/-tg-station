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
	name = "Jack's katana"
	desc = "The sword of a samurai from the past that was sent to the future where he was slained by Nar-Sie. Goes throght metal like butter."
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT | USEDELAY
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 10
	throwforce = 10
	w_class = 4
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slashed", "sliced", "torn", "ripped", "diced", "cut")
	
/obj/item/weapon/melee/ironslayer/preattack(atom/target, mob/user, click_parameters)
	if(target.Adjacent(user))
		var/name = target.name
		var/capture = 0
		if(istype(target,/obj/mecha))
			var/obj/mecha/mech = target
			mech.take_damage(120)	//mech slayer
			capture = 1
		else if(isrobot(target))
			var/mob/living/silicon/S = target
			S.gib()		//robot slayer
			capture = 1
		else if(istype(target,/mob/living/silicon/ai))
			target.ex_act(1)
			capture = 1
		else if(istype(target,/obj/machinery/bot))
			var/obj/machinery/bot/B = target
			B.explode()		//bot slayer
			capture = 1
		else if(istype(target,/obj/machinery/turret))
			var/obj/machinery/turret/T = target
			T.die()
			capture = 1
		else if(istype(target, /turf/simulated/wall/r_wall))
			if(prob(12))
				var/turf/simulated/wall/W = target
				playsound(user.loc, 'sound/items/Deconstruct.ogg', 80, 1)
				W.dismantle_wall(0,1)
			capture = 1
		else if(istype(target, /turf/simulated/wall))
			if(prob(30))
				var/turf/simulated/wall/W = target
				playsound(user.loc, 'sound/items/Deconstruct.ogg', 80, 1)
				W.dismantle_wall(0,1)
			capture = 1
			
		else if(istype(target,/obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/D = target
			if(!D.glass && !(D.doortype in list(9,26,28,29,30,33)))		//only destroy metal doors,and no vault/AI
				if(prob(25))
					playsound(user.loc, 'sound/items/Deconstruct.ogg', 80, 1)
					del D
				capture = 1
		else if(target.type in typesof(/obj/machinery/door/poddoor/shutters,/obj/machinery/portable_atmospherics/canister,/obj/structure/rack,/obj/structure/table,/obj/structure/girder,/obj/structure/grille,/obj/structure/closet))
			target.ex_act(2)
			capture = 1
			
		if(capture)
			var/showname
			if(user)
				showname = " by [user]"
			if(attack_verb.len)
				user.visible_message("\red <B>[name] has been [pick(attack_verb)] with [src][showname]. </B>")
			else
				user.visible_message("\red <B>[name] has been attacked with [src][showname]. </B>")
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
				user.visible_message("<span class='telepath'> \i [msg]</span>")
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
		
/obj/item/weapon/gun/magic/wand/reincarnate
	name = "wand of reincarnate"
	desc = "This wand will reincarnate a construct or a shade back to life, it might work on a corpse."
	ammo_type = "/obj/item/ammo_casing/magic/incar"
	icon_state = "polywand"
	max_charges = 3
	
/obj/item/ammo_casing/magic/incar
	projectile_type = /obj/item/projectile/magic/incar
	
/obj/item/projectile/magic/incar
	name = "bolt of cult reincarnate"
	icon_state = "ice_1"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/incar/on_hit(var/atom/change)
	var/mob/living/L = change
	if(is_support(L) && L.stat != DEAD)		// 20 percent to convert to cult on change on available mobs
		ticker.mode.remove_cultist(L.mind,0)
		var/mob/living/new_mob = reincarnate(L,1)
		if(!new_mob)
			return
		ticker.mode.add_cultist(new_mob.mind)
	else if(L.client && L.stat == DEAD && prob(80))		//reincarnate when dead
		ticker.mode.remove_cultist(L.mind,0)
		var/mob/living/new_mob = reincarnate(L,2)
		if(!new_mob)
			return
		ticker.mode.add_cultist(new_mob.mind)
		
		
/obj/item/projectile/magic/proc/reincarnate(mob/living/M,type = 1)
	if(ticker.mode.name == "cult" && M.mind == ticker.mode:sacrifice_target)
		return
	if(istype(M, /mob/living))
		if(M.notransform)	return
		M.notransform = 1
		M.canmove = 0
		M.icon = null
		M.overlays.Cut()
		M.invisibility = 101
		if(type == 1 || prob(50))
			var/mob/living/carbon/human/new_mob = new /mob/living/carbon/human(M.loc)
			
			var/datum/preferences/A = new()	//Randomize appearance for the human
			A.copy_to(new_mob)
			
			ready_dna(new_mob)
			if(new_mob.dna)
				new_mob.dna.mutantrace = pick("lizard","golem","slime","shadow","adamantine","skeleton","")
				new_mob.update_body()
			new_mob.attack_log = M.attack_log
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>[M.real_name] ([M.ckey]) became [new_mob.real_name].</font>")
	
			new_mob.a_intent = "harm"
			if(M.mind)
				M.mind.transfer_to(new_mob)
			else
				new_mob.key = M.key
	
			new_mob << "<B>You reincarnate into a human.</B>"
			del(M)
			return new_mob
		else if(type == 2)
			var/mob/living/simple_animal/corgi/Ian/NarIan/new_mob = new /mob/living/simple_animal/corgi/Ian/NarIan(M.loc)
			new_mob.attack_log = M.attack_log
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>[M.real_name] ([M.ckey]) became [new_mob.real_name].</font>")
	
			new_mob.a_intent = "harm"
			if(M.mind)
				M.mind.transfer_to(new_mob)
			else
				new_mob.key = M.key
	
			new_mob << "<B>You reincarnate into NarIan. KILL IAN!</B>"
			del(M)
			return new_mob

/mob/living/simple_animal/corgi/Ian/NarIan
	name = "NarIan"
	real_name = "NarIan"
	desc = "It's NarIan, Ian's dark brother from the pits of hell."
	icon = 'icons/mob/NarIan.dmi'
	icon_state = "nar_ian"
	icon_living = "nar_ian"
	icon_dead = "nar_ian_dead"
	maxHealth = 80
	health = 80
	speak = list("Foolish mortal!","DIE!","Join the dark side!","KILL IAN!","YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("rages","screams","barks", "woofs")
	emote_hear = list("barks", "woofs", "yaps","pants","screams","rages")
	emote_see = list("shakes its head", "shivers","spasms","ravages")
	
/mob/living/simple_animal/corgi/Ian/NarIan/New()
	..()
	//spell_list += new /obj/effect/proc_holder/spell/targeted/mind_transfer	//No spell until spells are in mind
	//Unleash the chaos,unleash the horror that is NarIan!

/obj/item/clothing/head/cult
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


/obj/item/clothing/head/cult/alt
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/suit/cult/alt
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"

/obj/item/clothing/suit/cult
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

/obj/item/clothing/head/cult/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 20, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/suit/cult/magusred
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
	armor = list(melee = 30, bullet = 20, laser = 30,energy = 20, bomb = 15, bio = 50, rad = 30)
	
/obj/item/clothing/suit/space/cult
	name = "cult armour"
	icon_state = "cult_armour"
	item_state = "cult_armour"
	desc = "A bulky suit of armour, bristling with spikes. It looks space proof."
	w_class = 3
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/tank/emergency_oxygen)
	slowdown = 0
	armor = list(melee = 30, bullet = 20, laser = 30,energy = 20, bomb = 15, bio = 50, rad = 30)
	
//New robust cult rig, it will let you space walk like constructs
/obj/item/clothing/head/helmet/space/cult/construct
	name = "construct styled hardsuit helmet"
	desc = "A space helmet enchanted with Nar-Sie's wisdom."
	icon_state = "cult_rig_helm"
	item_state = "cult_rig_helm"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 30, bomb = 30, bio = 100, rad = 60)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	
/obj/item/clothing/suit/space/cult/construct
	name = "construct styled hardsuit"
	icon_state = "cult_rig"
	item_state = "cult_rig"
	desc = "A powerful suit enchanted with Nar-Sie's wisdom. It can thread throgh space with no fear."
	w_class = 4
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/tank)
	slowdown = 1
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 30, bomb = 30, bio = 100, rad = 60)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT