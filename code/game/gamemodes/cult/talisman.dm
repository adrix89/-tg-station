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
					call(/obj/effect/rune/tomesummon/invoke)()
				if("armor")
					call(/obj/effect/rune/armor/invoke)()
				if("emp")
					call(/obj/effect/rune/emp/invoke)(usr.loc,1+uses)
					uses = 0
				if("conceal")
					call(/obj/effect/rune/obscure/invoke)(2)
				if("revealrunes")
					call(/obj/effect/rune/revealrunes/invoke)(3,src)
				if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
					call(/obj/effect/rune/teleport/invoke)(imbue)
				if("sumcult")
					//If the user cancels the talisman this var will be set to 0
					delete = call(/obj/effect/rune/cultsummon/invoke)()
				if("communicate")
					//If the user cancels the talisman this var will be set to 0
					delete = call(/obj/effect/rune/communicate/invoke)()
				if("silence")
					call(/obj/effect/rune/silence/invoke)()
				if("blind")
					call(/obj/effect/rune/blind/invoke)()
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
						usr << "\red There is nothing left of the talisman!"
						user.drop_item(src)
						del(src)
					else
						usr << "\red Your [src.imbue] talisman has [uses] uses."
			return
		else
			user << "You see strange symbols on the paper. Are they supposed to mean something?"
			return


	attack(mob/living/T as mob, mob/living/user as mob)
		if(iscultist(user))
			if(imbue == "runestun")
				add_logs(user,T, "stunned", admin=0,object=src,addition=" stun talisman")
				user.take_organ_damage(5, 0)
				call(/obj/effect/rune/runestun/invoke)(T)
				user.drop_item(src)
				del(src)
			else if(imbue == "drain")
				add_logs(user,T, "drained", admin=0,object=src,addition=" drain talisman")
				if(call(/obj/effect/rune/drain/invoke)(T))
					uses--
					if(uses <=0)
						user.drop_item(src)
						del(src)
					else
						usr << "\red Your drain talisman has [uses] uses left."
				else 
					..()
			else
				..()   ///If its some other talisman, use the generic attack code, is this supposed to work this way?
		else
			..()
			
	preattack(atom/O as obj|mob, mob/living/user as mob, proximity_flag, click_parameters)
		. = 1	//Return 1 on delete
		if(proximity_flag && iscultist(user))
			if(imbue == "emp")
				var/location = O.loc
				
				if(isrobot(O))
					var/mob/living/T = O
					add_logs(user,O, "attacked", admin=0,object=src,addition=" emp talisman")
					T.emp_act(1)
					T.take_organ_damage(30)	//emp act + this = 50 damage total)
				else if(istype(O, /obj/machinery/camera))
					var/obj/machinery/camera/cam = O
					cam.deactivate(user,2)
					cam.visible_message("\blue The camera has blown up!")
					location = O.loc
					del cam
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
				else if(isturf(location))
					O.emp_act(1)	//emp the rest
				else
					return 0
				var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
				spark_system.set_up(5, 0,location)
				spark_system.start()
				playsound(location, "sparks", 50, 1)
				uses--
				if(uses <=0)
					user.drop_item(src)
					del(src)
				else
					usr << "\red Your emp talisman has [uses] charge left."
				return 1
		return 0

	proc/supply(var/key)
		if (!src.uses)
			var/mob/living/user = usr
			user.drop_item(src)
			del(src)
			return

		var/dat = "<B>There are [src.uses] bloody runes on the parchment.</B><BR>"
		dat += "Please choose the chant to be imbued into the fabric of reality.<BR>"
		dat += "<HR>"
		dat += "<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Summon a new arcane tome.<BR>"
		dat += "<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a rune with the same last word.<BR>"
		dat += "<A href='?src=\ref[src];rune=sumcult'>N'ath reth sh'yro eth d'rekkathnor!</A> - Allows you to summon one of your cult brothers at a cost. (2 uses)<BR>"
		dat += "<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.You can also attack directly. (3 charge)<BR>"
		dat += "<A href='?src=\ref[src];rune=conceal'>Kla'atu barada nikt'o!</A> - Allows you to conceal the runes you placed on the floor. (2 uses)<BR>"
		dat += "<A href='?src=\ref[src];rune=reveal'>Nikt'o barada kla'atu!</A> - Allows you to reveal the runes in a short range. (2 uses)<BR>"
		dat += "<A href='?src=\ref[src];rune=communicate'>O bidai nabora se'sma!</A> - Allows you to coordinate with others of your cult. (4 uses)<BR>"
		dat += "<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin</A> - Allows you to stun a person by attacking them with the talisman.<BR>"
		dat += "<A href='?src=\ref[src];rune=drain'>Yu'gular faras desdae</A> - Allows you to drain a person of life and healing your own.(5 uses)<BR>"
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
				if("sumcult")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "sumcult"
					T.uses = 2
				if("emp")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "emp"
					T.uses = 3
				if("conceal")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "conceal"
					T.uses = 2
				if("reveal")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "revealrunes"
					T.uses = 2
				if("communicate")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "communicate"
					T.uses = 4
				if("runestun")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "runestun"
				if("drain")
					var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(usr)
					usr.put_in_hands(T)
					T.imbue = "drain"
					T.uses = 5
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