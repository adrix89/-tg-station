/obj/item/weapon/paper/talisman
	icon_state = "paper_talisman"
	var/imbue = null
	var/uses = 0


	examine()
		set src in view(2)
		..()
		return


	attack_self(mob/living/user as mob)
		if(iscultist(user))
			var/delete = 1
			switch(imbue)
				if("newtome")
					call(/obj/effect/rune/proc/tomesummon)()
				if("armor")
					call(/obj/effect/rune/proc/armor)()
				if("emp")
					call(/obj/effect/rune/proc/emp)(usr.loc,1+uses)
					uses = 0
				if("conceal")
					call(/obj/effect/rune/proc/obscure)(2)
				if("revealrunes")
					call(/obj/effect/rune/proc/revealrunes)(src)
				if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
					call(/obj/effect/rune/proc/teleport)(imbue)
				if("communicate")
					//If the user cancels the talisman this var will be set to 0
					delete = call(/obj/effect/rune/proc/communicate)()
				if("silence")
					call(/obj/effect/rune/proc/silence)()
				if("blind")
					call(/obj/effect/rune/proc/blind)()
				if("runestun")
					user << "\red To use this talisman, attack your target directly."
					return
				if("supply")
					supply()
//			user.take_organ_damage(5, 0)
			if(src && src.imbue!="supply" && src.imbue!="runestun")
				if(delete)
					uses--
					if(uses <= 0)
						user.drop_item(src)
						del(src)
			return
		else
			user << "You see strange symbols on the paper. Are they supposed to mean something?"
			return


	attack(mob/living/T as mob, mob/living/user as mob)
		if(iscultist(user))
			if(imbue == "runestun")
				user.take_organ_damage(5, 0)
				call(/obj/effect/rune/proc/runestun)(T)
				user.drop_item(src)
				del(src)
			else if(imbue == "emp")
				if(isrobot(T))
					T.emp_act(1)
					T.take_organ_damage(30)	//emp act + this = 50 damage total
					uses--
				if(uses <=0)
					user.drop_item(src)
					del(src)
			else
				..()   ///If its some other talisman, use the generic attack code, is this supposed to work this way?
		else
			..()
			
	preattack(atom/O as obj|mob, mob/living/user as mob, proximity_flag)
		. = 1	//Return 1 on delete
		if(isturf(O))
			return 0
		if(proximity_flag)
			if(iscultist(user) && imbue == "emp")
				if(istype(O, /obj/machinery/camera))
					var/obj/machinery/camera/cam = O
					cam.deactivate(null)
				else if(istype(O, /obj/machinery/bot))
					var/obj/machinery/bot/bot = O
					bot.explode()
				else if(istype(O, /obj/machinery/power/apc) && uses==3)
					var/obj/machinery/power/apc/apc = O
					apc.emp_act(1)
					apc.set_broken()
					apc.visible_message("\blue The apc has blown up!")
					user.drop_item(src)
					uses = 0
				else 
					O.emp_act(1)	//emp the rest
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0, O.loc)
				spark_system.start()
				playsound(O.loc, "sparks", 50, 1)
				uses--
				if(uses <=0)
					user.drop_item(src)
					del(src)
				return 1
		return 0

	proc/supply(var/key)
		if (!src.uses)
			del(src)
			return

		var/dat = "<B>There are [src.uses] bloody runes on the parchment.</B><BR>"
		dat += "Please choose the chant to be imbued into the fabric of reality.<BR>"
		dat += "<HR>"
		dat += "<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Summon a new arcane tome.<BR>"
		dat += "<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a rune with the same last word.<BR>"
		dat += "<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology. (Charge 3)<BR>"
		dat += "<A href='?src=\ref[src];rune=conceal'>Kla'atu barada nikt'o!</A> - Allows you to conceal the runes you placed on the floor.<BR>"
		dat += "<A href='?src=\ref[src];rune=reveal'>Nikt'o barada kla'atu!</A> - Allows you to reveal the runes in a short range.<BR>"
		dat += "<A href='?src=\ref[src];rune=communicate'>O bidai nabora se'sma!</A> - Allows you to coordinate with others of your cult. (4 uses)<BR>"
		dat += "<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin</A> - Allows you to stun a person by attacking them with the talisman.<BR>"
		dat += "<A href='?src=\ref[src];rune=armor'>Sa tatha najin</A> - Allows you to summon armoured robes and an unholy blade<BR>"
		dat += "<A href='?src=\ref[src];rune=construct'>Da A'ig Osk</A> - Summons a construct shell for use with captured souls. It is too large to carry on your person.<BR>"
		usr << browse(dat, "window=id_com;size=350x200")
		return


	Topic(href, href_list)
		if(!src)	return
		if (usr.stat || usr.restrained() || !in_range(src, usr))	return

		if (href_list["rune"])
			switch(href_list["rune"])
				if("newtome")
					usr.put_in_hands(new /obj/item/weapon/tome(usr.loc))
				if("teleport")
					var/dest = input ("Choose a destination word") in list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
					if(!dest)
						return
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = dest
					T.info = "[T.imbue]"
				if("emp")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "emp"
					T.uses = 3
				if("conceal")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "conceal"
				if("reveal")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "revealrunes"
				if("communicate")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "communicate"
					T.uses = 4
				if("runestun")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "runestun"
				if("armor")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "armor"
				if("construct")
					new /obj/structure/constructshell(get_turf(usr))
			src.uses--
			supply()
		return


/obj/item/weapon/paper/talisman/supply
	imbue = "supply"
	uses = 5