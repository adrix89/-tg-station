var/list/sacrificed = list()

/obj/effect/rune
/////////////////////////////////////////FIRST RUNE
	proc
		teleport(var/key)
			var/mob/living/user = usr
			var/allrunesloc[]
			allrunesloc = new/list()
			var/index = 0
		//	var/tempnum = 0
			for(var/obj/effect/rune/R in global.runes)
				if(R == src)
					continue
				if(R.word1 == wordtravel && R.word2 == wordself && R.word3 == key && R.z != 2)
					index++
					allrunesloc.len = index
					allrunesloc[index] = R.loc
			if(index >= 5)
				user << "\red You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric"
				if (istype(user, /mob/living))
					user.take_overall_damage(5, 0)
				del(src)
			if(allrunesloc && index != 0)
				if(istype(src,/obj/effect/rune))
					user.say("Sas[pick("'","`")]so c'arta forbici!")//Only you can stop auto-muting
				else
					user.whisper("Sas[pick("'","`")]so c'arta forbici!")
				user.visible_message("\red [user] disappears in a flash of red light!", \
				"\red You feel as your body gets dragged through the dimension of Nar-Sie!", \
				"\red You hear a sickening crunch and sloshing of viscera.")
				user.loc = allrunesloc[rand(1,index)]
				return
			if(istype(src,/obj/effect/rune))
				return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.
			else
				call(/obj/effect/rune/proc/fizzle)()
				return


		itemport(var/key)
//			var/allrunesloc[]
//			allrunesloc = new/list()
//			var/index = 0
		//	var/tempnum = 0
			var/culcount = 0
			var/runecount = 0
			var/obj/effect/rune/IP = null
			var/mob/living/user = usr
			for(var/obj/effect/rune/R in global.runes)
				if(R == src)
					continue
				if(R.word1 == wordtravel && R.word2 == wordother && R.word3 == key)
					IP = R
					runecount++
			if(runecount >= 2)
				user << "\red You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric"
				if (istype(user, /mob/living))
					user.take_overall_damage(5, 0)
				del(src)
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C) && !C.stat)
					culcount++
			if(user.loc==src.loc)
				return fizzle()
			if(culcount>=1)
				user.say("Sas[pick("'","`")]so c'arta forbici tarem!")
				user.visible_message("\red You feel air moving from the rune - like as it was swapped with somewhere else.", \
				"\red You feel air moving from the rune - like as it was swapped with somewhere else.", \
				"\red You smell ozone.")
				for(var/obj/O in src.loc)
					if(!O.anchored)
						O.loc = IP.loc
				for(var/mob/M in src.loc)
					M.loc = IP.loc
				return

			return fizzle()

/////////////////////////////////////////SECOND RUNE

		tomesummon()
			if(istype(src,/obj/effect/rune))
				usr.say("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
			else
				usr.whisper("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
			usr.visible_message("\red Rune disappears with a flash of red light, and in its place now a book lies.", \
			"\red You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book.", \
			"\red You hear a pop and smell ozone.")
			if(istype(src,/obj/effect/rune))
				new /obj/item/weapon/tome(src.loc)
			del(src)
			return



/////////////////////////////////////////THIRD RUNE

		convert()
			var/culcount = 0
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C) && !C.stat)
					culcount++
					C.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
					
			if(culcount<3 && !check_equip())	//Needs 3 cultists around or have armor to convert
				return fizzle()
			for(var/mob/living/carbon/M in src.loc)
				if(iscultist(M))
					continue
				if(M.stat==2)
					continue
				M.visible_message("\red [M] writhes in pain as the markings below him glow a bloody red.", \
				"\red AAAAAAHHHH!.", \
				"\red You hear an anguished scream.")
				if(is_convertable_to_cult(M.mind))
					ticker.mode.add_cultist(M.mind)
					M.mind.special_role = "Cultist"
					M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
					M << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
					return 1
					/*No words on conversion
					//picking which word to use
					if(usr.mind.cult_words.len != ticker.mode.allwords.len) // No point running if they already know everything
						var/convert_word
						for(var/i=1, i<=3, i++)
							convert_word = pick(ticker.mode.grantwords)
							if(convert_word in usr.mind.cult_words)
								if(i==3) convert_word = null				//NOTE: If max loops is changed ensure this condition is changed to match /Mal
							else
								break
						if(!convert_word)
							usr << "\red This Convert was unworthy of knowledge of the other side!"
						else
							usr << "\red The Geometer of Blood is pleased to see his followers grow in numbers."
							ticker.mode.grant_runeword(usr, convert_word)
						return 1
					*/
				else
					M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
					M << "<font color=\"red\"><b>And not a single fuck was given, exterminate the cult at all costs.</b></font>"
					return 0

			return fizzle()
			
		check_equip()
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				var/obj/item/slot_item = H.get_item_by_slot(slot_head)
				if(slot_item && !(slot_item.type in typesof(/obj/item/clothing/head/culthood,/obj/item/clothing/head/magus,/obj/item/clothing/head/helmet/space/cult)))
					return 0
				slot_item = H.get_item_by_slot(slot_wear_suit)
				if(slot_item && !(slot_item.type in typesof(/obj/item/clothing/suit/cultrobes,/obj/item/clothing/suit/magusred,/obj/item/clothing/suit/space/cult)))
					return 0
				if(!istype(H.get_item_by_slot(slot_shoes),/obj/item/clothing/shoes/cult))
					return 0
				if(istype(H.get_active_hand(),/obj/item/weapon/melee/cultblade))
					return 1
				if(istype(H.get_inactive_hand(),/obj/item/weapon/melee/cultblade))
					return 1
				if(istype(H.get_item_by_slot(slot_s_store),/obj/item/weapon/melee/cultblade))
					return 1
			else return 0



/////////////////////////////////////////FOURTH RUNE

		tearreality()
			var/cultist_count = 0
			for(var/mob/M in range(1,src))
				if(iscultist(M) && !M.stat)
					M.say("Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
					cultist_count += 1
			if(cultist_count >= 9)
				if(ticker.mode.name == "cult")
					var/datum/game_mode/cult/cult_mode = ticker.mode
					if(cult_mode.objectives.Find("eldergod"))
						var/narsie_type = /obj/machinery/singularity/narsie/large
						// Moves narsie if she was already summoned.
						var/obj/her = locate(narsie_type, machines)
						if(her)
							her.loc = get_turf(src)
							return
						// Otherwise...
						new narsie_type(src.loc) // Summon her!
						cult_mode.eldergod = 0
						del(src) // Stops cultists from spamming the rune to summon narsie more than once.
						return
				var/narsie_type = /obj/machinery/singularity/narsie		//Mini-narsie
				// Moves narsie if she was already summoned.
				var/obj/her = locate(narsie_type, machines)
				if(her)
					her.loc = get_turf(src)
					return
				// Otherwise...
				new narsie_type(src.loc) // Summon her!
				world << "<font size='2' color='red'><b>NAR-SIE HAS RISEN</b></font>"	//announce mini-narsie
				del(src) // Stops cultists from spamming the rune to summon narsie more than once.
				return
			else
				return fizzle()

/////////////////////////////////////////FIFTH RUNE

		emp(var/U,var/range_red) //range_red - var which determines by which number to reduce the default emp range, U is the source loc, needed because of talisman emps which are held in hand at the moment of using and that apparently messes things up -- Urist
			if(istype(src,/obj/effect/rune))
				usr.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
			else
				usr.whisper("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
			playsound(U, 'sound/items/Welder2.ogg', 25, 1)
			var/turf/T = get_turf(U)
			if(T)
				T.hotspot_expose(700,125)
			var/rune = src // detaching the proc - in theory
			empulse(U, (range_red - 2), range_red)
			del(rune)
			return

/////////////////////////////////////////SIXTH RUNE

		drain()
			var/drain = 0
			for(var/obj/effect/rune/R in global.runes)
				if(R.word1==wordtravel && R.word2==wordblood && R.word3==wordself)
					for(var/mob/living/carbon/D in R.loc)
						if(D.stat!=2)
							var/bdrain = rand(1,25)
							D << "\red You feel weakened."
							D.take_overall_damage(bdrain, 0)
							drain += bdrain
			if(!drain)
				return fizzle()
			usr.say ("Yu[pick("'","`")]gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
			usr.visible_message("\red Blood flows from the rune into [usr]!", \
			"\red The blood starts flowing from the rune and into your frail mortal body. You feel... empowered.", \
			"\red You hear a liquid flowing.")
			var/mob/living/user = usr
			if(user.bhunger)
				user.bhunger = max(user.bhunger-2*drain,0)
			if(drain>=50)
				user.visible_message("\red [user]'s eyes give off eerie red glow!", \
				"\red ...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within.", \
				"\red You hear a heartbeat.")
				user.bhunger += drain
				src = user
				spawn()
					for (,user.bhunger>0,user.bhunger--)
						sleep(50)
						user.take_overall_damage(3, 0)
				return
			user.heal_organ_damage(drain%5, 0)
			drain-=drain%5
			for (,drain>0,drain-=5)
				sleep(2)
				user.heal_organ_damage(5, 0)
			return






/////////////////////////////////////////SEVENTH RUNE

		seer()
			if(usr.loc==src.loc)
				usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
				var/mob/living/carbon/human/user = usr
				if(user.see_invisible!=25  || (istype(user) && user.glasses))	//check for non humans
					user << "\red The world beyond flashes your eyes but disappears quickly, as if something is disrupting your vision."
				else
					user << "\red The world beyond opens to your eyes."
				var/see_temp = user.see_invisible
				user.see_invisible = SEE_INVISIBLE_OBSERVER
				user.seer = 1
				while(user.loc==src.loc)
					sleep(30)
				user.seer = 0
				user.see_invisible = see_temp
				return
			return fizzle()

/////////////////////////////////////////EIGHTH RUNE

		raise()
			var/mob/living/carbon/human/corpse_to_raise
			var/mob/living/carbon/human/body_to_sacrifice

			var/is_sacrifice_target = 0
			for(var/mob/living/carbon/human/M in src.loc)
				if(M.stat == DEAD)
					if(ticker.mode.name == "cult" && M.mind == ticker.mode:sacrifice_target)
						is_sacrifice_target = 1
					else
						corpse_to_raise = M
						if(M.key)
							M.ghostize(1)	//kick them out of their body
						break
			if(!corpse_to_raise)
				if(is_sacrifice_target)
					usr << "\red The Geometer of blood wants this mortal for himself."
				return fizzle()


			is_sacrifice_target = 0
			find_sacrifice:
				for(var/obj/effect/rune/R in global.runes)
					if(R.word1==wordblood && R.word2==wordjoin && R.word3==wordhell)
						for(var/mob/living/carbon/human/N in R.loc)
							if(ticker.mode.name == "cult" && N.mind && N.mind == ticker.mode:sacrifice_target)
								is_sacrifice_target = 1
							else
								if(N.stat!= DEAD)
									body_to_sacrifice = N
									break find_sacrifice

			if(!body_to_sacrifice)
				if (is_sacrifice_target)
					usr << "\red The Geometer of blood wants that corpse for himself."
				else
					usr << "\red The sacrifical corpse is not dead. You must free it from this world of illusions before it may be used."
				return fizzle()

			var/mob/dead/observer/ghost
			for(var/mob/dead/observer/O in loc)
				if(!O.client)	continue
				if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
				ghost = O
				break

			if(!ghost)
				usr << "\red You require a restless spirit which clings to this world. Beckon their prescence with the sacred chants of Nar-Sie."
				return fizzle()

			for(var/obj/item/organ/limb/affecting in corpse_to_raise.organs)
				affecting.heal_damage(1000, 1000, 0)
			corpse_to_raise.setToxLoss(0)
			corpse_to_raise.setOxyLoss(0)
			corpse_to_raise.SetParalysis(0)
			corpse_to_raise.SetStunned(0)
			corpse_to_raise.SetWeakened(0)
			corpse_to_raise.radiation = 0
//			corpse_to_raise.buckled = null
//			if(corpse_to_raise.handcuffed)
//				del(corpse_to_raise.handcuffed)
//				corpse_to_raise.update_inv_handcuffed(0)
			corpse_to_raise.stat = CONSCIOUS
			corpse_to_raise.updatehealth()
			corpse_to_raise.update_damage_overlays(0)

			corpse_to_raise.key = ghost.key	//the corpse will keep its old mind! but a new player takes ownership of it (they are essentially possessed)
											//This means, should that player leave the body, the original may re-enter
			usr.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
			corpse_to_raise.visible_message("\red [corpse_to_raise]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.", \
			"\red Life... I'm alive again...", \
			"\red You hear a faint, slightly familiar whisper.")
			body_to_sacrifice.visible_message("\red [body_to_sacrifice] is torn apart, a black smoke swiftly dissipating from his remains!", \
			"\red You feel as your blood boils, tearing you apart.", \
			"\red You hear a thousand voices, all crying in pain.")
			body_to_sacrifice.gib()

//			if(ticker.mode.name == "cult")
//				ticker.mode:add_cultist(corpse_to_raise.mind)
//			else
//				ticker.mode.cult |= corpse_to_raise.mind

			corpse_to_raise << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
			corpse_to_raise << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
			return





/////////////////////////////////////////NINETH RUNE

		obscure(var/rad)
			var/S=0
			for(var/obj/effect/rune/R in orange(rad,src))
				if(R!=src)
					R.invisibility=55
				S=1
			if(S)
				if(istype(src,/obj/effect/rune))
					usr.say("Kla[pick("'","`")]atu barada nikt'o!")
					for (var/mob/V in viewers(src))
						V.show_message("\red The rune turns into gray dust, veiling the surrounding runes.", 3)
					del(src)
				else
					usr.whisper("Kla[pick("'","`")]atu barada nikt'o!")
					usr << "\red Part of the talisman turns into gray dust, veiling the surrounding runes."
					for (var/mob/V in orange(1,src))
						if(V!=usr)
							V.show_message("\red Dust emanates from [usr]'s hands for a moment.", 3)

				return
			if(istype(src,/obj/effect/rune))
				return	fizzle()
			else
				call(/obj/effect/rune/proc/fizzle)()
				return

/////////////////////////////////////////TENTH RUNE

		ajourney() //some bits copypastaed from admin tools - Urist
			if(usr.loc==src.loc)
				var/mob/living/carbon/human/L = usr
				usr.say("Fwe[pick("'","`")]sh mah erl nyag r'ya!")
				usr.visible_message("\red [usr]'s eyes glow blue as \he freezes in place, absolutely motionless.", \
				"\red The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this is a great sight, being here strains your mind and body. Hurry...", \
				"\red You hear only complete silence for a moment.")
				usr.ghostize(1)
				L.ajourn = 1
				while(L)
					if(L.key)
						L.ajourn=0
						ticker.mode.update_cult_icons_added(L.mind)
						return
					else
						L.take_organ_damage(7, 0)
					sleep(100)
			return fizzle()




/////////////////////////////////////////ELEVENTH RUNE

		manifest()
			var/obj/effect/rune/this_rune = src
			src = null
			if(usr.loc!=this_rune.loc)
				return this_rune.fizzle()
			var/mob/dead/observer/ghost
			for(var/mob/dead/observer/O in this_rune.loc)
				if(!O.client)	continue
				if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
				ghost = O
				break
			if(!ghost)
				return this_rune.fizzle()

			usr.say("Gal'h'rfikk harfrandid mud[pick("'","`")]gib!")
			var/mob/living/carbon/human/dummy/D = new(this_rune.loc)
			ready_dna(D)
			if(D.dna)
				D.dna.mutantrace = pick("golem","shadow","skeleton","")
				D.update_body()
			usr.visible_message("\red A shape forms in the center of the rune. A shape of... a man, kinda.", \
			"\red A shape forms in the center of the rune. A shape of... a man, kinda.", \
			"\red You hear liquid flowing.")
			D.real_name = "[pick(first_names_male)] [pick(last_names)]"
			D.universal_speak = 1
			D.status_flags &= ~GODMODE

			D.key = ghost.key

			if(ticker.mode.name == "cult")
				ticker.mode:add_cultist(D.mind)
			else
				ticker.mode.cult+=D.mind
			ticker.mode.update_cult_icons_added(D.mind)
			D.mind.special_role = "Cultist"
			D << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
			D << "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"

			var/mob/living/user = usr
			while(this_rune && user && user.stat==CONSCIOUS && user.client && user.loc==this_rune.loc)
				user.take_organ_damage(1, 0)
				sleep(30)
			if(D)
				D.visible_message("\red [D] slowly dissipates into dust and bones.", \
				"\red You feel pain, as bonds formed between your soul and this homunculus break.", \
				"\red You hear faint rustle.")
				D.dust()
			return





/////////////////////////////////////////TWELFTH RUNE

		talisman()//only hide, emp, teleport, silence, blind and tome runes can be imbued atm
			var/obj/item/weapon/paper/newtalisman
			var/unsuitable_newtalisman = 0
			for(var/obj/item/weapon/paper/P in src.loc)
				if(!P.info)
					newtalisman = P
					break
				else
					unsuitable_newtalisman = 1
			if (!newtalisman)
				if (unsuitable_newtalisman)
					usr << "\red The blank is tainted. It is unsuitable."
				return fizzle()

			var/obj/effect/rune/imbued_from
			var/obj/item/weapon/paper/talisman/T
			for(var/obj/effect/rune/R in orange(1,src))
				if(R==src)
					continue
				if(R.word1==wordtravel && R.word2==wordself)  //teleport
					T = new(src.loc)
					T.imbue = "[R.word3]"
					T.info = "[R.word3]"
					imbued_from = R
					break
				if(R.word1==wordsee && R.word2==wordblood && R.word3==wordhell) //tome
					T = new(src.loc)
					T.imbue = "newtome"
					imbued_from = R
					break
				if(R.word1==worddestr && R.word2==wordsee && R.word3==wordtech) //emp
					T = new(src.loc)
					T.imbue = "emp"
					imbued_from = R
					break
				if(R.word1==wordblood && R.word2==wordsee && R.word3==worddestr) //conceal
					T = new(src.loc)
					T.imbue = "conceal"
					imbued_from = R
					break
				if(R.word1==wordhell && R.word2==worddestr && R.word3==wordother) //armor
					T = new(src.loc)
					T.imbue = "armor"
					imbued_from = R
					break
				if(R.word1==wordblood && R.word2==wordsee && R.word3==wordhide) //reveal
					T = new(src.loc)
					T.imbue = "revealrunes"
					imbued_from = R
					break
				if(R.word1==wordhide && R.word2==wordother && R.word3==wordsee) //silence
					T = new(src.loc)
					T.imbue = "silence"
					imbued_from = R
					break
				if(R.word1==worddestr && R.word2==wordsee && R.word3==wordother) //blind
					T = new(src.loc)
					T.imbue = "blind"
					imbued_from = R
					break
				if(R.word1==wordself && R.word2==wordother && R.word3==wordtech) //communicat
					T = new(src.loc)
					T.imbue = "communicate"
					imbued_from = R
					break
				if(R.word1==wordjoin && R.word2==wordhide && R.word3==wordtech) //stun
					T = new(src.loc)
					T.imbue = "runestun"
					imbued_from = R
					break
			if (imbued_from)
				for (var/mob/V in viewers(src))
					V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
				usr.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
				del(imbued_from)
				del(newtalisman)
			else
				return fizzle()

/////////////////////////////////////////THIRTEENTH RUNE

		mend()
			var/mob/living/user = usr
			src = null
			user.say("Uhrast ka'hfa heldsagen ver[pick("'","`")]lot!")
			user.take_overall_damage(200, 0)
			runedec+=10
			user.visible_message("\red [user] keels over dead, his blood glowing blue as it escapes his body and dissipates into thin air.", \
			"\red In the last moment of your humble life, you feel an immense pain as fabric of reality mends... with your blood.", \
			"\red You hear faint rustle.")
			for(,user.stat==2)
				sleep(600)
				if (!user)
					return
			runedec-=10
			return


/////////////////////////////////////////FOURTEETH RUNE

		// returns 0 if the rune is not used. returns 1 if the rune is used.
		communicate()
			. = 1 // Default output is 1. If the rune is deleted it will return 1
			var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
			if(!input)
				if (istype(src))
					fizzle()
					return 0
				else
					return 0
			if(istype(src,/obj/effect/rune))
				usr.say("O bidai nabora se[pick("'","`")]sma!")
			else
				usr.whisper("O bidai nabora se[pick("'","`")]sma!")

			if(istype(src,/obj/effect/rune))
				usr.say("[input]")
			else
				usr.whisper("[input]")
			for(var/datum/mind/H in ticker.mode.cult)
				if (H.current)
					H.current << "<span class='telepath'>\b \i [input] </span>"
			for(var/datum/mind/H in ticker.mode.support)		//now shades can hear messages without messing other stuff.
				if (H.current)
					H.current << "<span class='telepath'>\b \i [input] </span>"
			return 1

/////////////////////////////////////////FIFTEENTH RUNE
	
		sacrifice()
			var/list/mob/living/carbon/human/cultsinrange = list()
			var/list/mob/living/carbon/human/victims = list()
			var/mob/living/user = usr
			var/infuse = 0
			var/target = 0
			//var/obj/item/device/soulstone/soul = check_stone(user)
			for(var/mob/living/carbon/human/V in src.loc)//Checks for non-cultist humans to sacrifice
				if(ishuman(V))
					if(!(iscultist(V)))
						victims += V//Checks for cult status and mob type
			for(var/obj/item/I in src.loc)//Checks for MMIs/brains/Intellicards
				if(istype(I,/obj/item/organ/brain))
					var/obj/item/organ/brain/B = I
					victims += B.brainmob
				else if(istype(I,/obj/item/device/mmi))
					var/obj/item/device/mmi/B = I
					victims += B.brainmob
				else if(istype(I,/obj/item/device/aicard))
					for(var/mob/living/silicon/ai/A in I)
						victims += A
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C) && !C.stat)
					cultsinrange += C
					C.say("Barhah hra zar[pick("'","`")]garis!")
			
			for(var/mob/H in victims)
				if (ticker.mode.name == "cult" && H.mind == ticker.mode:sacrifice_target)
					if(cultsinrange.len >= 3)
						sacrificed += H.mind
						usr << "<span class='telepath'> The Geometer of Blood accepts this sacrifice, your objective is now complete. </span>"
						usr << "<span class='telepath'> He is pleased! </span>"
						sac_grant_word()
						sac_grant_word()
						sac_grant_word()
						greater_reward(H)
						stone_or_gib(H)
						
					else if(check_equip())
						infuse++
						sacrificed += H.mind
						target =1
						sac_grant_word()
						sac_grant_word()
						sac_grant_word()
						greater_reward(H)
						stone_or_gib(H)
					else
						usr << "\red Your target's earthly bonds are too strong. You need more cultists to succeed in this ritual."
				else
					if(H.stat !=2)
						if(cultsinrange.len >= 3)
							usr << "<span class='telepath'> The Geometer of Blood accepts this sacrifice. </span>"
							sac_grant_word()
							if(ticker.mode.globalwords.len == ticker.mode.allwords.len)		//If they have all words Narsie is pleased
								greater_reward(H)
							else lesser_reward(H)
							stone_or_gib(H)
						else if(check_equip())
							infuse++
							sac_grant_word()
							if(ticker.mode.globalwords.len == ticker.mode.allwords.len)		//If they have all words Narsie is pleased
								greater_reward(H)
							else lesser_reward(H)
							stone_or_gib(H)
						else
							usr << "\red The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."
						
					else
						if(prob(70))
							usr << "<span class='telepath'> The Geometer of blood accepts this sacrifice. </span>"
							sac_grant_word()
						else
							usr << "<span class='telepath'> The Geometer of blood accepts this sacrifice. </span>"
							usr << "<span class='telepath'> However, a mere dead body is not enough to satisfy Him. </span>"
						stone_or_gib(H)
			for(var/mob/living/carbon/monkey/H in src.loc)
				if (ticker.mode.name == "cult")
					if(H.mind == ticker.mode:sacrifice_target)
						if(cultsinrange.len >= 3)
							sacrificed += H.mind
							usr << "\red The Geometer of Blood accepts this sacrifice, your objective is now complete."
							usr << "\red He is pleased!"
							sac_grant_word()
							sac_grant_word()
							sac_grant_word()
							greater_reward(H)
							stone_or_gib(H)
						else if(check_equip())
							infuse++
							sacrificed += H.mind
							target =1
							sac_grant_word()
							sac_grant_word()
							sac_grant_word()
							greater_reward(H)
							stone_or_gib(H)
						else
							usr << "\red Your target's earthly bonds are too strong. You need more cultists to succeed in this ritual."
							continue
					else
						if(prob(20))
							usr << "\red The Geometer of Blood accepts your meager sacrifice."
							sac_grant_word()
						else
							usr << "\red The Geometer of blood accepts this sacrifice."
							usr << "\red However, a mere monkey is not enough to satisfy Him."
						stone_or_gib(H)
				else
					usr << "\red The Geometer of Blood accepts your meager sacrifice."
					if(prob(20))
						sac_grant_word()
				if(H)H.gib()
			if(infuse)
				user.visible_message("\red [user] blade shines with a red glow as he plunges it into the helpless [infuse==1 ?"victim":"victims"]!", \
				"\red You take your blade, infuse it with your blood and plunge it into your [infuse==1 ?"victim":"victims"].", \
				"\red A sense of dread assails you.")
				user.take_overall_damage(30, 0)
				if(target)
					usr << "<span class='telepath'> The Geometer of Blood accepts this sacrifice, your objective is now complete. </span>"
					usr << "<span class='telepath'> He is pleased! </span>"
				else
					usr << "<span class='telepath'> The Geometer of Blood accepts this sacrifice. </span>"
			transmit_words()	//transmit to others
/*			for(var/mob/living/carbon/alien/A)
				for(var/mob/K in cultsinrange)
					K.say("Barhah hra zar'garis!")
				A.dust()      /// A.gib() doesnt work for some reason, and dust() leaves that skull and bones thingy which we dont really need.
				if (ticker.mode.name == "cult")
					if(prob(75))
						usr << "\red The Geometer of Blood accepts your exotic sacrifice."
						sac_grant_word()
					else
						usr << "\red The Geometer of Blood accepts your exotic sacrifice."
						usr << "\red However, this alien is not enough to gain His favor."
				else
					usr << "\red The Geometer of Blood accepts your exotic sacrifice."
				return
			return fizzle() */
			
		stone_or_gib(var/mob/T)
			var/obj/item/device/soulstone/stone = new /obj/item/device/soulstone(get_turf(src))
			if(!stone.transfer_soul("FORCE", T, usr))	//if it fails to add soul
				del stone
			if(T)
				if(isrobot(T))
					T.dust()//To prevent the MMI from remaining
				else
					T.gib()
					
		sac_grant_word()	//The proc that which chooses a word rewarded for a successful sacrifice, sacrifices always give a currently unknown word if the normal checks pass
			if(ticker.mode.globalwords.len != ticker.mode.allwords.len) // No point running if they already know everything
				var/convert_word
				var/pick_list = ticker.mode.allwords - ticker.mode.globalwords
				convert_word = pick(pick_list)
				ticker.mode.grant_runeword(usr, convert_word)
				
		transmit_words()	//transmits words to all cultists memory
			for(var/datum/mind/cult_mind in ticker.mode.cult)
				if(cult_mind.cult_words.len != ticker.mode.globalwords.len)
					cult_mind.current << "<span class='warning'>You hear a distant scream, and your blood rages for a moment and then it subsides..</span>"
					ticker.mode.learn_words(cult_mind.current,1)
			
				
		lesser_reward(var/mob/T)
			if(prob(10))		//TEST
				var/reward = pick("construct","talisman")
				switch (reward)
					if("construct")
						new /obj/structure/constructshell(get_turf(src))
					if("talisman")		//one use talisman
						var/obj/item/weapon/paper/talisman/supply/tal = new /obj/item/weapon/paper/talisman/supply(get_turf(src))
						tal.uses = 1
						
		greater_reward(var/mob/T)
			var/reward = pick("fireball","smoke","blind","mindswap","forcewall","knock","charge", "wanddeath", "wandresurrection", "wandpolymorph", "wandteleport", "wanddoor", "wandfireball", "armor", "space", "scrying","vorpal","ironslayer")
			var/obj/item/weapon/gun/magic/wand/W
			switch (reward)
				if("fireball")
					new /obj/item/weapon/spellbook/oneuse/fireball(get_turf(src))
				if("smoke")
					new /obj/item/weapon/spellbook/oneuse/smoke(get_turf(src))
				if("blind")
					new /obj/item/weapon/spellbook/oneuse/blind(get_turf(src))
				if("mindswap")
					new /obj/item/weapon/spellbook/oneuse/mindswap(get_turf(src))
				if("forcewall")
					new /obj/item/weapon/spellbook/oneuse/forcewall(get_turf(src))
				if("knock")
					new /obj/item/weapon/spellbook/oneuse/knock(get_turf(src))
				if("charge")
					new /obj/item/weapon/spellbook/oneuse/charge(get_turf(src))
				if("wanddeath")
					W = new /obj/item/weapon/gun/magic/wand/death(get_turf(src))
					W.charges = 1
				if("wandresurrection")
					W = new /obj/item/weapon/gun/magic/wand/resurrection(get_turf(src))
					W.charges = 1
					W.max_charges = 4
				if("wandpolymorph")
					W = new /obj/item/weapon/gun/magic/wand/reincarnate(get_turf(src))
					W.charges = 4
				if("wandteleport")
					new /obj/item/weapon/gun/magic/wand/teleport(get_turf(src))
				if("wanddoor")
					W = new /obj/item/weapon/gun/magic/wand/door(get_turf(src))
					W.charges = 7
					W.max_charges = 10
				if("wandfireball")
					new /obj/item/weapon/gun/magic/wand/fireball(get_turf(src))
				if("armor")
					new /obj/item/clothing/head/magus(get_turf(src))
					new /obj/item/clothing/suit/magusred(get_turf(src))
					new /obj/item/clothing/shoes/cult/galoshes(get_turf(src))
				if("space")
					new /obj/item/clothing/head/helmet/space/cult(get_turf(src))
					new /obj/item/clothing/suit/space/cult(get_turf(src))
					new /obj/item/clothing/shoes/cult/galoshes(get_turf(src))
				if("vorpal")
					new /obj/item/weapon/melee/cultblade/vorpal(get_turf(src))
				if("ironslayer")
					new /obj/item/weapon/melee/ironslayer(get_turf(src))
				if("scrying")
					new /obj/item/weapon/scrying(get_turf(src))
					var/mob/living/carbon/human/H = null
					if(ishuman(usr))
						H = usr
					if (H && !(XRAY in H.mutations))
						H.mutations.Add(XRAY)
						H.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
						H.see_in_dark = 8
						H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
						H << "<span class='notice'>The walls suddenly disappear.</span>"
		
		check_stone(var/mob/living/carbon/human/H)		//check to see if user has empty soulstone on himself
			if(ishuman(H))
				var/obj/item/device/soulstone/soul
				if(istype(H.get_item_by_slot(slot_l_store),/obj/item/device/soulstone))
					soul = H.get_item_by_slot(slot_l_store)
					if(!soul.contents.len)		//no shades
						return soul
				if(istype(H.get_item_by_slot(slot_r_store),/obj/item/device/soulstone))
					soul = H.get_item_by_slot(slot_r_store)
					if(!soul.contents.len)
						return soul
				if(istype(H.get_inactive_hand(),/obj/item/device/soulstone))
					soul = H.get_inactive_hand()
					if(!soul.contents.len)
						return soul
				if(istype(H.get_active_hand(),/obj/item/device/soulstone))
					soul = H.get_active_hand()
					if(!soul.contents.len)
						return soul
				if(istype(H.get_item_by_slot(slot_belt),/obj/item/device/soulstone))
					soul = H.get_item_by_slot(slot_belt)
					if(!soul.contents.len)
						return soul
				if(istype(H.get_item_by_slot(slot_belt),/obj/item/weapon/storage/belt/soulstone))
					var/obj/item/weapon/storage/belt = H.get_item_by_slot(slot_belt)
					for(var/obj/item/device/soulstone/stone in belt.contents)
						if(!stone.contents.len)
							return stone
			else
				return


/////////////////////////////////////////SIXTEENTH RUNE

		revealrunes(var/rad,var/obj/W as obj)
			var/S=0
			for(var/obj/effect/rune/R in orange(rad,src))
				if(R!=src)
					R.invisibility=0
				S=1
			if(S)
				if(istype(W,/obj/item/weapon/nullrod) || istype(W,/obj/item/weapon/storage/bible))
					usr << "\red Arcane markings suddenly glow from underneath a thin layer of dust!"
					return
				if(istype(W,/obj/effect/rune))
					usr.say("Nikt[pick("'","`")]o barada kla'atu!")
					for (var/mob/V in viewers(src))
						V.show_message("\red The rune turns into red dust, reveaing the surrounding runes.", 3)
					del(src)
					return
				if(istype(W,/obj/item/weapon/paper/talisman))
					usr.whisper("Nikt[pick("'","`")]o barada kla'atu!")
					usr << "\red Part of the talisman turns into red dust, revealing the surrounding runes."
					for (var/mob/V in orange(1,usr.loc))
						if(V!=usr)
							V.show_message("\red Red dust emanates from [usr]'s hands for a moment.", 3)
					return
				return
			if(istype(W,/obj/effect/rune))
				return	fizzle()
			if(istype(W,/obj/item/weapon/paper/talisman))
				call(/obj/effect/rune/proc/fizzle)()
				return

/////////////////////////////////////////SEVENTEENTH RUNE

		wall()
			usr.say("Khari[pick("'","`")]d! Eske'te tannin!")
			src.density = !src.density
			var/mob/living/user = usr
			user.take_organ_damage(2, 0)
			if(src.density)
				usr << "\red Your blood flows into the rune, and you feel that the very space over the rune thickens."
			else
				usr << "\red Your blood flows into the rune, and you feel as the rune releases its grasp on space."
			return

/////////////////////////////////////////EIGHTTEENTH RUNE

		freedom()
			var/mob/living/user = usr
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
			var/list/mob/living/carbon/users = new
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C) && !C.stat)
					users+=C
			if(users.len>=2)
				var/mob/living/carbon/cultist = input("Choose the one who you want to free", "Followers of Geometer") as null|anything in (cultists - users)
				if(!cultist)
					return fizzle()
				if (cultist == user) //just to be sure.
					return
				if(!(cultist.buckled || \
					cultist.handcuffed || \
					istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle) || \
					(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded) || \
					(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked) || \
					(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked) \
				))
					user << "\red The [cultist] is already free."
					return
				cultist.buckled = null
				if (cultist.handcuffed)
					cultist.handcuffed.loc = cultist.loc
					cultist.handcuffed = null
					cultist.update_inv_handcuffed(0)
				if (cultist.legcuffed)
					cultist.legcuffed.loc = cultist.loc
					cultist.legcuffed = null
					cultist.update_inv_legcuffed(0)
				if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
					cultist.u_equip(cultist.wear_mask)
				if(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded)
					cultist.loc:welded = 0
				if(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked)
					cultist.loc:locked = 0
				if(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked)
					cultist.loc:locked = 0
				for(var/mob/living/carbon/C in users)
					user.take_overall_damage(15, 0)
					C.say("Khari[pick("'","`")]d! Gual'te nikka!")
				del(src)
			return fizzle()

/////////////////////////////////////////NINETEENTH RUNE

		cultsummon()
			var/mob/living/user = usr
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
			var/list/mob/living/carbon/users = new
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C) && !C.stat)
					users+=C
			if(users.len>=2)
				var/mob/living/carbon/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - user)
				if(!cultist)
					return fizzle()
				if (cultist == user) //just to be sure.
					return
				if(cultist.buckled || cultist.handcuffed || (!isturf(cultist.loc) && !istype(cultist.loc, /obj/structure/closet)))
					user << "\red You cannot summon the [cultist], for his shackles of blood are strong"
					return fizzle()
				cultist.loc = src.loc
				cultist.lying = 1
				cultist.regenerate_icons()
				for(var/mob/living/carbon/human/C in orange(1,src))
					if(iscultist(C) && !C.stat)
						C.say("N'ath reth sh'yro eth d[pick("'","`")]rekkathnor!")
						C.take_overall_damage(25, 0)
				user.visible_message("\red Rune disappears with a flash of red light, and in its place now a body lies.", \
				"\red You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body.", \
				"\red You hear a pop and smell ozone.")
				del(src)
			return fizzle()

/////////////////////////////////////////TWENTIETH RUNES

		silence()
			if(istype(src,/obj/effect/rune))
				var/affected = 0
				for(var/mob/living/carbon/C in range(7,src))
					if (iscultist(C))
						continue
					var/obj/item/weapon/nullrod/N = locate() in C
					if(N)
						continue
					C.ear_deaf += 50
					C.silent += 50
					C.show_message("\red The world around you suddenly becomes quiet.", 3)
					affected++
					if(prob(1))
						C.sdisabilities |= DEAF
				if(affected)
					usr.say("Sti[pick("'","`")] kaliedir!")
					usr << "\red The world becomes quiet as the silence rune dissipates into fine dust."
					del(src)
				else
					return fizzle()
			else
				var/affected = 0
				for(var/mob/living/carbon/C in range(7,usr))
					if (iscultist(C))
						continue
					var/obj/item/weapon/nullrod/N = locate() in C
					if(N)
						continue
					C.ear_deaf += 30
					C.silent += 30
					//talismans is weaker.
					C.show_message("\red The world around you suddenly becomes quiet.", 3)
					affected++
				if(affected)
					usr.whisper("Sti[pick("'","`")] kaliedir!")
					usr << "\red Your talisman turns into gray dust,your enemies will not hear or speak a thing."
					for (var/mob/V in orange(1,src))
						if(!(iscultist(V)))
							V.show_message("\red Dust flows from [usr]'s hands for a moment, and the world suddenly becomes quiet..", 3)
			return
			
//////////             Rune 21

		blind()
			if(istype(src,/obj/effect/rune))
				var/affected = 0
				for(var/mob/living/carbon/C in viewers(src))
					if (iscultist(C))
						continue
					var/obj/item/weapon/nullrod/N = locate() in C
					if(N)
						continue
					C.eye_blurry += 50
					C.eye_blind += 20
					if(prob(5))
						C.disabilities |= NEARSIGHTED
						if(prob(10))
							C.sdisabilities |= BLIND
					C.show_message("\red Suddenly you see red flash that blinds you.", 3)
					affected++
				if(affected)
					usr.say("Sti[pick("'","`")] kaliesin!")
					usr << "\red The rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust."
					del(src)
				else
					return fizzle()
			else
				var/affected = 0
				for(var/mob/living/carbon/C in view(2,usr))
					if (iscultist(C))
						continue
					var/obj/item/weapon/nullrod/N = locate() in C
					if(N)
						continue
					C.eye_blurry += 30
					C.eye_blind += 10
					//talismans is weaker.
					affected++
					C.show_message("\red You feel a sharp pain in your eyes, and the world disappears into darkness..", 3)
				if(affected)
					usr.whisper("Sti[pick("'","`")] kaliesin!")
					usr << "\red Your talisman turns into gray dust, blinding those who not follow the Nar-Sie."
			return

//////////             Rune 22

		bloodboil() //cultists need at least one DANGEROUS rune. Even if they're all stealthy.
/*
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
*/
			var/culcount = 0 //also, wording for it is old wording for obscure rune, which is now hide-see-blood.
//			var/list/cultboil = list(cultists-usr) //and for this words are destroy-see-blood.
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C) && !C.stat)
					culcount++
			if(culcount>=3)
				for(var/mob/living/carbon/M in viewers(usr))
					if(iscultist(M))
						continue
					var/obj/item/weapon/nullrod/N = locate() in M
					if(N)
						continue
					M.take_overall_damage(51,51)
					M << "\red Your blood boils!"
					if(prob(5))
						spawn(5)
							M.gib()
				for(var/obj/effect/rune/R in view(src))
					if(prob(10))
						explosion(R.loc, -1, 0, 1, 5)
				for(var/mob/living/carbon/human/C in orange(1,src))
					if(iscultist(C) && !C.stat)
						C.say("Dedo ol[pick("'","`")]btoh!")
						C.take_overall_damage(15, 0)
				del(src)
			else
				return fizzle()
			return

//////////             Rune 23 WIP rune, I'll wait for Rastaf0 to add limited blood.

		burningblood()
			var/culcount = 0
			for(var/mob/living/carbon/C in orange(1,src))
				if(iscultist(C) && !C.stat)
					culcount++
			if(culcount >= 5)
				for(var/obj/effect/rune/R in world)
					if(R.blood_DNA == src.blood_DNA)
						for(var/mob/living/M in orange(2,R))
							M.take_overall_damage(0,15)
							if (R.invisibility>M.see_invisible)
								M << "\red Aargh it burns!"
							else
								M << "\red Rune suddenly ignites, burning you!"
							var/turf/T = get_turf(R)
							T.hotspot_expose(700,125)
				for(var/obj/effect/decal/cleanable/blood/B in world)
					if(B.blood_DNA == src.blood_DNA)
						for(var/mob/living/M in orange(1,B))
							M.take_overall_damage(0,5)
							M << "\red Blood suddenly ignites, burning you!"
							var/turf/T = get_turf(B)
							T.hotspot_expose(700,125)
							del(B)
				del(src)

//////////             Rune 24 (counting burningblood, which kinda doesnt work yet.)

		runestun(var/mob/living/T as mob)
			if(istype(src,/obj/effect/rune))   ///When invoked as rune, flash and stun everyone around.
				usr.say("Fuu ma[pick("'","`")]jin!")
				for(var/mob/living/L in viewers(src))

					if(iscarbon(L))
						var/mob/living/carbon/C = L
						flick("e_flash", C.flash)
						if(C.stuttering < 1 && (!(HULK in C.mutations)))
							C.stuttering = 1
						C.Weaken(1)
						C.Stun(1)
						C.show_message("\red The rune explodes in a bright flash.", 3)

					else if(issilicon(L))
						var/mob/living/silicon/S = L
						S.Weaken(5)
						S.show_message("\red BZZZT... The rune has exploded in a bright flash.", 3)
				del(src)
			else                        ///When invoked as talisman, stun and mute the target mob.
				usr.say("Dream sign ''Evil sealing talisman'[pick("'","`")]!")
				var/obj/item/weapon/nullrod/N = locate() in T
				if(N)
					for(var/mob/O in viewers(T, null))
						O.show_message(text("\red <B>[] invokes a talisman at [], but they are unaffected!</B>", usr, T), 1)
				else
					for(var/mob/O in viewers(T, null))
						O.show_message(text("\red <B>[] invokes a talisman at []</B>", usr, T), 1)

					if(issilicon(T))
						T.Weaken(15)

					else if(iscarbon(T))
						var/mob/living/carbon/C = T
						flick("e_flash", C.flash)
						if (!(HULK in C.mutations))
							C.silent += 15
						C.Weaken(25)
						C.Stun(25)
				return

/////////////////////////////////////////TWENTY-FIFTH RUNE

		armor()
			var/mob/living/carbon/human/user = usr
			if(istype(src,/obj/effect/rune))
				usr.say("N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")
			else
				usr.whisper("N'ath reth sh'yro eth d[pick("'","`")]raggathnor!")
			usr.visible_message("\red The rune disappears with a flash of red light, and a set of armor appears on [usr]...", \
			"\red You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.")
			
			var/obj/item/slot_item = user.get_item_by_slot(slot_wear_suit)
			if(slot_item && slot_item.type in typesof(/obj/item/clothing/suit/armor/hos,/obj/item/clothing/suit/armor/vest/capcarapace,/obj/item/clothing/suit/armor/swat,/obj/item/clothing/suit/armor/laserproof))
				user.u_equip(slot_item)
				del slot_item
				user.equip_to_slot_or_del(new /obj/item/clothing/suit/magusred,slot_wear_suit)
			else if(slot_item && slot_item.type in typesof(/obj/item/clothing/suit/space/rig,/obj/item/clothing/suit/space/captain))
				user.u_equip(slot_item)
				del slot_item
				user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/cult,slot_wear_suit)
			else
				user.u_equip(slot_item)
				user.equip_to_slot_if_possible(new /obj/item/clothing/suit/cultrobes/alt(get_turf(user)), slot_wear_suit,0,1,1)
				
			slot_item = user.get_item_by_slot(slot_head)
			if(slot_item && istype(slot_item,/obj/item/clothing/head/helmet/space))
				user.u_equip(slot_item)
				del slot_item
				user.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/cult,slot_head)
			else if(slot_item && istype(slot_item,/obj/item/clothing/head/helmet))
				user.u_equip(slot_item)
				del slot_item
				user.equip_to_slot_or_del(new /obj/item/clothing/head/magus,slot_head)
			else
				user.u_equip(slot_item)
				user.equip_to_slot_if_possible(new /obj/item/clothing/head/culthood/alt(get_turf(user)), slot_head,0,1,1)
				
			slot_item = user.get_item_by_slot(slot_shoes)
			if(slot_item && slot_item.type in typesof(/obj/item/clothing/shoes/galoshes,/obj/item/clothing/shoes/syndigaloshes,/obj/item/clothing/shoes/swat,/obj/item/clothing/shoes/space_ninja,/obj/item/clothing/shoes/cult/galoshes))
				user.u_equip(slot_item)
				del slot_item
				user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/galoshes,slot_shoes)
			else
				user.u_equip(slot_item)
				user.equip_to_slot_if_possible(new /obj/item/clothing/shoes/cult(get_turf(user)), slot_shoes,0,1,1)
				
			user.equip_to_slot_if_possible(new /obj/item/weapon/storage/backpack/cultpack(get_turf(user)), slot_back)
			//the above update their overlay icons cache but do not call update_icons()
			//the below calls update_icons() at the end, which will update overlay icons by using the (now updated) cache
			user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))	//put in hands or on floor

			del(src)
			return
			
//////////             Rune 26

		shadow()
			usr.say("V'etho arba le't nak su[pick("'","`")]likarak!")
			if(active)
				drained = usr	//swap users
				usr << "\red \i The shadow rune recognizes you as its new master."
				return
			var/area/A = get_area_master(src)
			if(A.shadow)	//return if there is already a rune working
				usr << "\red \i The area is already cloaked by another rune."
				return
			var/rune_count
			for(var/obj/effect/rune/R in global.runes)
				if(R.active)
					rune_count++
			var/mob/living/user = usr
			if(rune_count > 3)
				usr << "\red You feel pain, as the rune disappears in reality shift caused by too much wear of space-time fabric."
				
				if (istype(user, /mob/living))
					user.take_overall_damage(5, 0)
				del(src)
			if(A.type == /area)		//space
				usr << "\red \i You can't use the shadow rune in space."
				return
			
			if(A.type in typesof(/area/chapel,/area/hallway,/area/shuttle,/area/centcom,/area/asteroid,/area/tdome,/area/planet,/area/telesciareas,/area/awaymission))
				usr << "\red \i The shadow rune cannot work here."
				return
			
			var/obj/effect/rune/R	=	src
			//src = null	//Not null so it stops on delete
			var/count
			for(var/area/LSA in A.related)
				for(var/turf/T in LSA)
					count++
			//usr << "Area size: [count]"
			if(count <= 200)
				user.visible_message("\red The fabric of reality around shifts and turns.", \
			"\red You power up the shadow rune veiling the area from outside eyes.", \
			"\red You hear a slosh.")
				A.shadow = 1
				A.shadow_rune = R
				R.active = 1
				var/damage = round(count/100,0.5)
				R.drained = usr
				for(var/area/LSA in A.related)
					for(var/mob/living/search in LSA)
						R.shadow_mobs += search
						search.invisibility = 55
						search.see_invisible = 55
						search.see_override = 55
					for(var/obj/effect/search in LSA)
						if(search.type in typesof(/obj/effect/rune,/obj/effect/decal/remains,/obj/effect/decal/cleanable/xenoblood,/obj/effect/decal/cleanable/blood,/obj/effect/decal/cleanable/robot_debris))
							search.invisibility = 55
							R.shadow_stuff += search
				
				while(1)
					/*
					//CHECK FOR TELEPORT OUT
					for(var/mob/living/search in R.shadow_mobs)
						if(get_area_master(search) != A)
							R.shadow_mobs -= search
							search.invisibility = initial(search.invisibility)
							search.see_override = 0
							search.see_invisible =	initial(search.see_invisible)
					*/		
					/*
					for(var/area/LSA in A.related)
						for(var/mob/living/search in LSA)
							R.shadow_mobs += search
							search.invisibility = 55
							search.see_invisible = 55
							search.see_override = 55
					*/
					for(var/mob/living/search in player_list)
						var/area/master = get_area_master(search)
						if(master == A && search.see_override != 55)
							R.shadow_mobs += search
							search.lastarea = get_area(search)
							search.invisibility = 55
							search.see_invisible = 55
							search.see_override = 55
						else if(!master.shadow)
							R.shadow_mobs -= search
							search.invisibility = initial(search.invisibility)
							search.see_override = 0
							search.see_invisible =	initial(search.see_invisible)
					//world << "LAGGING"
					
					if(R && R.drained && R.drained.see_override && R.drained.stat==CONSCIOUS && R.drained.client && R.drained.lastarea.master==A)
						R.drained.take_organ_damage(damage, 0)
						//R.drained << "DAMAGED [damage]"
					else
						//Find replacement
						var/check =0
						if(R)
							for(var/mob/M in R.shadow_mobs)	//find user
								if(iscultist(M) && M.stat==CONSCIOUS && M.client)
									R.drained = M
									R.drained.take_organ_damage(damage, 0)
									check =1
									R.drained << "\red The shadow rune has selected you as its new master"
									break
								//R.drained <<"NOT FOUND "
						//EXIT
						if(!check)
							del(R)
							return
					
					sleep(80)
				return
			else
				usr << "\red \i The area is to expansive for the rune to work!"
			return
			
		shadow_remove()
			var/area/A = get_area_master(src)
			if(A.shadow_rune == src)
				var/obj/effect/rune/R	=	src
				//R.drainedNarIan
				A.shadow = 0
				A.shadow_rune = null
				R.active = 0
				for(var/obj/effect/search in R.shadow_stuff)
					if(istype(search,/obj/effect/rune))
						continue
					search.invisibility =0
				for(var/mob/search in R.shadow_mobs)
					search << "\red \i The forces that cloak you have left."
					search.invisibility = initial(search.invisibility)
					search.see_override = 0
					search.see_invisible =	initial(search.see_invisible)
		

