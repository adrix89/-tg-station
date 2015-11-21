//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32


var/wordtravel = null
var/wordself = null
var/wordsee = null
var/wordhell = null
var/wordblood = null
var/wordjoin = null
var/wordtech = null
var/worddestr = null
var/wordother = null
//var/wordhear = null
//var/wordfree = null
var/wordhide = null
var/runedec = 0
var/engwords = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")

/client/proc/check_words() // -- Urist
	set category = "Special Verbs"
	set name = "Check Rune Words"
	set desc = "Check the rune-word meaning"
	if(!wordtravel)
		runerandom()
	usr << "[wordtravel] is travel, [wordblood] is blood, [wordjoin] is join, [wordhell] is Hell, [worddestr] is destroy, [wordtech] is technology, [wordself] is self, [wordsee] is see, [wordother] is other, [wordhide] is hide."

/mob/proc/cult_add_comm() //why the fuck does this have its own proc? not removing it because it might be used somewhere but...
	verbs += /mob/living/proc/cult_innate_comm

/mob/living/proc/cult_innate_comm()
	set category = "Cultist"
	set name = "Imperfect Communion"

	if(!iscultist(usr))		//they shouldn't have this verb, but just to be sure...
		return

	if(usr.incapacitated())
		return	//dead men tell no tales

	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input)					// TO-DO: Add some kind of filter to corrupt the inputted text
		return

	if(ishuman(usr) || ismonkey(usr))	//Damage only applies to humans and monkeys, to allow constructs to communicate
		usr.visible_message("<span class='warning'>[usr] starts clawing at \his arms with \his fingernails!</span>", "<span class='warning'>You begin slicing open your arms with your fingernails!</span>")
		apply_damage(10,BRUTE, "l_arm")
		apply_damage(10,BRUTE, "r_arm")
		sleep(50)
		if(usr.incapacitated())
			return	//Hard to drawn intrinsic symbols when you're bleeding out in your cell.
		var/turf/location = loc
		if(istype(location, /turf/simulated))	// tearing your arms apart is going to spill a bit of blood, in fact thats the idea
			location.add_blood(usr)				// TO-DO change this to a badly drawn rune
		apply_damage(10,BRUTE, "l_arm")		// does a metric fuck ton of damage because this meant to be an emergency method of communication.
		apply_damage(10,BRUTE, "r_arm")
		if(usr.incapacitated())
			return
		usr.visible_message("<span class='warning'>[usr] paints strange symbols with their own blood.</span>", "<span class='warning'>You paint a messy rune with your own blood.</span>")
		sleep(20)

	cultist_commune(usr, 0, 1, input)
	return


/proc/runerandom() //randomizes word meaning
	var/list/runewords=list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri") ///"orkan" and "allaq" removed.
	wordtravel=pick(runewords)
	runewords-=wordtravel
	wordself=pick(runewords)
	runewords-=wordself
	wordsee=pick(runewords)
	runewords-=wordsee
	wordhell=pick(runewords)
	runewords-=wordhell
	wordblood=pick(runewords)
	runewords-=wordblood
	wordjoin=pick(runewords)
	runewords-=wordjoin
	wordtech=pick(runewords)
	runewords-=wordtech
	worddestr=pick(runewords)
	runewords-=worddestr
	wordother=pick(runewords)
	runewords-=wordother
//	wordhear=pick(runewords)
//	runewords-=wordhear
//	wordfree=pick(runewords)
//	runewords-=wordfree
	wordhide=pick(runewords)
	runewords-=wordhide


/obj/effect/rune
	desc = "A strange collection of symbols drawn in blood."
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	unacidable = 1
	layer = TURF_LAYER
	var/word_dict

	var/word1
	var/word2
	var/word3
// Places these combos are mentioned: this file - twice in the rune code, once in imbued tome, once in tome's HTML runes.dm - in the imbue rune code. If you change a combination - dont forget to change it everywhere.

// travel self [word] - Teleport to random [rune with word destination matching]
// travel other [word] - Portal to rune with word destination matching - kinda doesnt work. At least the icon. No idea why.
// see blood Hell - Create a new tome
// join blood self - Incorporate person over the rune into the group
// Hell join self - Summon TERROR
// destroy see technology - EMP rune
// travel blood self - Drain blood
// see Hell join - See invisible
// blood join Hell - Raise dead

// hide see blood - Hide nearby runes
// blood see hide - Reveal nearby runes  - The point of this rune is that its reversed obscure rune. So you always know the words to reveal the rune once oyu have obscured it.

// Hell travel self - Leave your body and ghost around
// blood see travel - Manifest a ghost into a mortal body
// Hell tech join - Imbue a rune into a talisman
// Hell blood join - Sacrifice rune
// destroy travel self - Wall rune
// join other self - Summon cultist rune
// travel technology other - Freeing rune    //    other blood travel was freedom join other

// hide other see - Deafening rune     //     was destroy see hear
// destroy see other - Blinding rune
// destroy see blood - BLOOD BOIL

// self other technology - Communication rune  //was other hear blood
// join hide technology - stun rune. Rune color: bright pink.
/obj/effect/rune/New()
	global.runes += src		//add to global list for easier searching
	..()
	var/image/blood = image(loc = src)
	blood.override = 1
	for(var/mob/living/silicon/ai/AI in player_list)
		AI.client.images += blood

/obj/effect/rune/Del()
	global.runes -= src
	..()

/obj/effect/rune/examine(mob/user)
	..()
	if(iscultist(user))
		user << "This spell circle reads: <i>[word1] [word2] [word3]</i>."



/obj/effect/rune/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/weapon/tome) && iscultist(user))
		user << "<span class='notice'>You disrup the power of the rune, leavening only the blood.</span>"
		var/obj/effect/decal/cleanable/blood/B =new(src.loc)
		B.blood_DNA = src.blood_DNA
		qdel(src)
		return
	
	if(istype(I, /obj/item/weapon/nullrod))
		user << "<span class='notice'>You disrupt the vile magic with the deadening field of the null rod!</span>"
		var/obj/effect/decal/cleanable/blood/B =new(src)
		B.blood_DNA = src.blood_DNA
		qdel(src)
		return
	return


/obj/effect/rune/attack_hand(mob/living/user)		// OH GOD this is horrible
	if(!iscultist(user))
		user << "<span class='warning'>You can't mouth the arcane scratchings without fumbling over them!</span>"
		return
	var/message = "<span class='warning'>You are unable to speak the words of the rune!</span>"
	if(!user.can_speak(message) && (user.mind && !user.mind.miming))
		user << message
		return
	if(!word1 || !word2 || !word3 || prob(user.getBrainLoss()))
		return fizzle(user)
	switch(src.type)
		if(/obj/effect/rune/emp)
			return invoke(src.loc,3)
		if(/obj/effect/rune/obscure)
			return invoke(4)
		if(/obj/effect/rune/revealrunes)
			return invoke(6,src)
		if(/obj/effect/rune/itemport)
			invoke(src.word3)
		if(/obj/effect/rune/teleport)
			invoke(src.word3)
		else
			return invoke()
	return


/obj/effect/rune/proc/fizzle(mob/living/cultist = null)
	var/gibberish = pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP")

	if(cultist)
		if(istype(src,/obj/effect/rune))
			cultist.say(gibberish)
		else
			cultist.whisper(gibberish)
	visible_message("<span class='danger'>The markings pulse with a small burst of light, then fall dark.</span>", 3, "<span class='italics'>You hear a faint fizzle.</span>", 2)
	return

/*
/obj/effect/rune/proc/check_icon()
	src.color = rgb(255, 0, 0)
	if(word1 == wordtravel && word2 == wordself)	//teleport
		icon_state = "2"
		color = rgb(0, 0, 255)
		return
	if(word1 == wordjoin && word2 == wordblood && word3 == wordself)	//covert
		icon_state = "3"
		return
	if(word1 == wordhell && word2 == wordjoin && word3 == wordself)		//narsie
		icon_state = "4"
		return
	if(word1 == wordsee && word2 == wordblood && word3 == wordhell)		//tome
		icon_state = "5"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == worddestr && word2 == wordsee && word3 == wordtech)		//emp
		icon_state = "5"
		return
	if(word1 == wordtravel && word2 == wordblood && word3 == wordself)	//drain
		icon_state = "2"
		return
	if(word1 == wordsee && word2 == wordhell && word3 == wordjoin)		//seer
		icon_state = "4"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == worddestr && word2 == wordjoin && word3 == wordother)	//raise
		icon_state = "1"
		return
	if(word1 == wordhide && word2 == wordsee && word3 == wordblood)		//hide
		icon_state = "1"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == wordhell && word2 == wordtravel && word3 == wordself)	//ajourn
		icon_state = "6"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == wordblood && word2 == wordsee && word3 == wordtravel)	//mainfest
		icon_state = "6"
		return
	if(word1 == wordhell && word2 == wordtech && word3 == wordjoin)		//talisman
		icon_state = "3"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == wordhell && word2 == wordblood && word3 == wordjoin)	//SAC
		icon_state = "[rand(1,6)]"
		src.color = rgb(255, 255, 255)
		return
	if(word1 == wordblood && word2 == wordsee && word3 == wordhide)		//reveal
		icon_state = "4"
		src.color = rgb(255, 255, 255)
		return
	if(word1 == worddestr && word2 == wordtravel && word3 == wordself)	//wall
		icon_state = "1"
		src.color = rgb(255, 0, 0)
		return
	if(word1 == wordtravel && word2 == wordtech && word3 == wordother)	//free
		icon_state = "4"
		src.color = rgb(255, 0, 255)
		return
	if(word1 == wordjoin && word2 == wordother && word3 == wordself)	//summon cult
		icon_state = "2"
		src.color = rgb(0, 255, 0)
		return
	if(word1 == wordhide && word2 == wordother && word3 == wordsee)		//silence
		icon_state = "4"
		src.color = rgb(0, 255, 0)
		return
	if(word1 == worddestr && word2 == wordsee && word3 == wordother)	//blind
		icon_state = "4"
		src.color = rgb(0, 0, 255)
		return
	if(word1 == worddestr && word2 == wordsee && word3 == wordblood)	//boil
		icon_state = "4"
		src.color = rgb(255, 0, 0)
		return
	if(word1 == wordself && word2 == wordother && word3 == wordtech)	//comms
		icon_state = "3"
		src.color = rgb(200, 0, 0)
		return
	if(word1 == wordtravel && word2 == wordother)	//teelport other
		icon_state = "1"
		src.color = rgb(200, 0, 0)
		return
	if(word1 == wordjoin && word2 == wordhide && word3 == wordtech)		//stun
		icon_state = "2"
		src.color = rgb(100, 0, 100)
		return
	if(word1 == wordhide && word2 == wordsee && word3 == wordtech)		//shadow
		icon_state = "4"
		src.color += rgb(1, 1, 1)
		return
	if(word1 == wordhell && word2 == worddestr && word3 == wordother)	//armor
		icon_state="[rand(1,6)]"
		src.color = rgb(rand(1,255),rand(1,255),rand(1,255))
		return
	icon_state="[rand(1,6)]" //random shape and color for dummy runes
	src.color = rgb(rand(1,255),rand(1,255),rand(1,255))
*/


/obj/item/weapon/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister looking cover."
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = 2
	var/notedat = ""
	var/tomedat = ""
	var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")

/obj/item/weapon/tome/examine(mob/user)
	..()
	if(iscultist(user))
		user << "The scriptures of the Geometer. Allows the scribing of runes and access of knowledge archives."

	tomedat = {"<html>
				<head>
				<style>
				h1 {font-size: 25px; margin: 15px 0px 5px;}
				h2 {font-size: 20px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h1>The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood.</h1>

				<i>The book is written in an unknown dialect, there are lots of pictures of various complex geometric shapes. You find some notes in english that give you basic understanding of the many runes written in the book. The notes give you an understanding what the words for the runes should be. However, you do not know how to write all these words in this dialect.</i><br>
				<i>Below is the summary of the runes.</i> <br>

				<h2>Contents</h2>
				<p>
				<b>Teleport self: </b>Travel Self (word)<br>
				<b>Teleport other: </b>Travel Other (word)<br>
				<b>Summon new tome: </b>See Blood Hell<br>
				<b>Convert a person: </b>Join Blood Self<br>
				<b>Summon Nar-Sie: </b>Hell Join Self<br>
				<b>Disable technology: </b>Destroy See Technology<br>
				<b>Drain blood: </b>Travel Blood Self<br>
				<b>Raise dead: </b>Destroy Join Other<br>
				<b>Hide runes: </b>Hide See Blood<br>
				<b>Reveal hidden runes: </b>Blood See Hide<br>
				<b>Leave your body: </b>Hell Travel Self<br>
				<b>Ghost Manifest: </b>Blood See Travel<br>
				<b>Imbue a talisman: </b>Hell Technology Join<br>
				<b>Sacrifice: </b>Hell Blood Join<br>
				<b>Create a wall: </b>Destroy Travel Self<br>
				<b>Summon cultist: </b>Join Other Self<br>
				<b>Free a cultist: </b>Travel Technology Other<br>
				<b>Deafen: </b>Hide Other See<br>
				<b>Blind: </b>Destroy See Other<br>
				<b>Blood Boil: </b>Destroy See Blood<br>
				<b>Communicate: </b>Self Other Technology<br>
				<b>Stun: </b>Join Hide Technology<br>
				<b>Summon Cultist Armor: </b>Hell Destroy Other<br>
				<b>See Invisible: </b>See Hell Join<br>
				</p>
				<h2>Rune Descriptions</h2>
				<h3>Teleport self</h3>
				Teleport rune is a special rune, as it only needs two words, with the third word being destination. Basically, when you have two runes with the same destination, invoking one will teleport you to the other one. If there are more than 2 runes, you will be teleported to a random one. Runes with different third words will create separate networks. You can imbue this rune into a talisman, giving you a great escape mechanism.<br>
				<h3>Teleport other</h3>
				Teleport other allows for teleportation for any movable object to another rune with the same third word. <br>
				<h3>Summon new tome</h3>
				Invoking this rune summons a new arcane tome.
				<h3>Convert a person</h3>
				This rune opens target's mind to the realm of Nar-Sie, which usually results in this person joining the cult. However, some people (mostly the ones who posess high authority) have strong enough will to stay true to their old ideals.<br>
				You will need 3 people chanting the invocation to convert a person <b>or an enchanted cultist armor and sword.</b><br>
				<h3>Summon Nar-Sie</h3>
				The ultimate rune. It summons the Avatar of Nar-Sie himself, tearing a huge hole in reality and consuming everything around it. Summoning it is the final goal of any cult.<br>
				<h3>Disable Technology</h3>
				Invoking this rune creates a strong electromagnetic pulse in a small radius, making it basically analogic to an EMP grenade.<br>
				You can imbue this rune into a talisman, <b>in this form you can attack object directly,</b>you can hurt cyborgs and bots,destroy cameras <b>and even destory apc when fully charged,</b>it can trigger an electromagnetic pulse based on charge left in the talisman.<br>
				<h3>Drain Blood</h3>
				This rune instantly heals you of some brute damage at the expense of a person placed on top of the rune. Whenever you invoke a drain rune, ALL drain runes on the station are activated, draining blood from anyone located on top of those runes. This includes yourself, though the blood you drain from yourself just comes back to you. This might help you identify this rune when studying words. One drain gives up to 25HP per each victim, but you can repeat it if you need more. Draining only works on living people, so you might need to recharge your "Battery" once its empty. Drinking too much blood at once might cause blood hunger.<br>
				<h3>Raise Dead</h3>
				This rune allows for the resurrection of any dead person.<br>
				You will need a dead human body and a living human sacrifice.<br>
				Make 2 raise dead runes.<br>
				Put a living non-braindead human on top of one, and a dead body on the other one.<br>
				When you invoke the rune, the life force of the living human will be transferred into the dead body, allowing a ghost standing on top of the dead body to enter it, instantly and fully healing it. Use other runes to ensure there is a ghost ready to be resurrected.<br>
				<h3>Hide runes</h3>
				This rune makes all nearby runes completely invisible. They are still there and will work if activated somehow, but you cannot invoke them directly if you do not see them.<br>
				<h3>Reveal runes</h3>
				This rune is made to reverse the process of hiding a rune. It reveals all hidden runes in a rather large area around it.
				<h3>Leave your body</h3>
				This rune gently rips your soul out of your body, leaving it intact. You can observe the surroundings as a ghost as well as communicate with other ghosts. <br>
				Your body takes damage while you are there, so ensure your journey is not too long, or you might never come back.<br>
				<h3>Manifest a ghost</h3>
				Unlike the Raise Dead rune, this rune does not require any special preparations or vessels.<br>
				Instead of using full lifeforce of a sacrifice, it will drain YOUR lifeforce. Stand on the rune and invoke it. If theres a ghost standing over the rune, it will materialise, and will live as long as you dont move off the rune or die. You can put a paper with a name on the rune to make the new body look like that person.<br>
				<h3>Imbue a talisman</h3>
				This rune allows you to imbue the magic of some runes into paper talismans. <br>
				Create an imbue rune, then an appropriate rune beside it. <br>
				Put an empty piece of paper on the imbue rune and invoke it. <br>
				You will now have a talisman with the power of the target rune. Using a talisman drains some health, so be careful with it. You can imbue a talisman with power of the following runes: summon tome, reveal, conceal, teleport, tisable technology, communicate, silence, blind and stun.<br>
				<h3>Sacrifice</h3>
				Sacrifice rune allows you to sacrifice a living thing or a body to the Geometer of Blood. Monkeys and dead humans are the most basic sacrifices, they might or might not be enough to gain His favor.<br>
				A living human is what a real sacrifice should be, however, you will need 3 people chanting the invocation to sacrifice a living person <b>or an enchanted cultist armor and sword. <br><br>
				If you collect all words throught this he will reward you generously.</b>
				<h3>Create a wall</h3>
				Invoking this rune solidifies the air above it, creating an an invisible wall. To remove the wall, simply invoke the rune again.
				<h3>Summon cultist</h3>
				This rune allows you to summon a fellow cultist to your location. The target cultist must be unhandcuffed ant not buckled to anything.<br>
				You also need to have 2 people chanting at the rune to successfully invoke it <b>or an enchanted cultist armor and sword.</b> Invoking it takes a strain on the bodies of all chanting cultists.<br>
				<h3>Free a cultist</h3>
				This rune unhandcuffs and unbuckles any cultist of your choice, no matter where he is.<br>
				You also need to have 2 people chanting at the rune to successfully invoke it <b>or an enchanted cultist armor and sword.</b> Invoking it takes a light strain on the bodies of all chanting cultists.<br>
				<h3>Silence</h3>
				This rune temporarily silence and deafen all non-cultists around you.<br>
				<h3>Blind</h3>
				This rune temporarily blinds all non-cultists around you. Very robust. Use together with the silence rune to leave your enemies completely helpless.<br>
				<h3>Blood boil</h3>
				This rune boils the blood all non-cultists in visible range. The damage is enough to instantly critically hurt any person.<br>
				You need 3 cultists invoking the rune for it to work. This rune is unreliable and may cause unpredicted effect when invoked. It also drains significant amount of your health when successfully invoked.<br>
				<h3>Communicate</h3>
				Invoking this rune allows you to relay a message to all cultists on the station and nearby space objects.
				<h3>Stun</h3>
				Unlike other runes, this ons is supposed to be used in talisman form. When invoked directly, it simply releases some dark energy, briefly stunning everyone around. When imbued into a talisman, you can force all of its energy into one person, stunning him so hard he cant even speak. However, effect wears off rather fast.<br>
				<h3>Equip Armor</h3>
				When this rune is invoked, either from a rune or a talisman, it will equip the user with the armor of the followers of Nar-Sie. To use this rune to its fullest extent, have helmet, armor or rig equipped and it will be transmuted to the cult equivalent. <br>
				<b>You need hood,robes,boots or cult transmuted equivalent and sword to utilize the sacrifice and convert runes freely.<br><br>
				<i>Recepies for transmutaion are as follows: </i></b><br>
				Any rig suit/helmet for the cult hardsuit; <br>
				Captain's Carapace,HoS coat,ablative armor for reflective cult armor; <br>
				Any thick suit like firsuit,bomb suit,bio suit for a space worthy cult suit; <br>
				A helmet for cult helmet; <br>
				A headgear that covers the whole head like welder mask or bio,rad,space,bomb hood for a space worthy helmet; <br>
				Footwear that doesn't slip for special boots.<br>
				<h3>See Invisible</h3>
				When invoked when standing on it, this rune allows the user to see the the world beyond as long as he does not move.<br>
				</body>
				</html>
				"}


/obj/item/weapon/tome/Topic(href,href_list[])
	if (src.loc == usr)
		var/number = text2num(href_list["number"])
		if (usr.stat|| usr.restrained())
			return
		switch(href_list["action"])
			if("clear")
				words[words[number]] = words[number]
			if("read")
				if(usr.get_active_hand() != src)
					return
				usr << browse("[tomedat]", "window=Arcane Tome")
				return
			if("change")
				words[words[number]] = input("Enter the translation for [words[number]]", "Word notes") in engwords
				for (var/entry in words)
					if ((words[entry] == words[words[number]]) && (entry != words[number]))
						words[entry] = entry
		notedat = {"
					<br><b>Word translation notes</b> <br>
					[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
					[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
					[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
					[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
					[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
					[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
					[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
					[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
					[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
					[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
					"}
		usr << browse("[notedat]", "window=notes")
//	call(/obj/item/weapon/tome/proc/edit_notes)()
	else
		usr << browse(null, "window=notes")
		return


//	proc/edit_notes()     FUCK IT. Cant get it to work properly. - K0000
//		world << "its been called! [usr]"
//		notedat = {"
//		<br><b>Word translation notes</b> <br>
//			[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
//			[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
//			[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
//			[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
//			[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
//			[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
//			[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
//			[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
//			[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
//			[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
//					"}
//		usr << "whatev"
//		usr << browse(null, "window=tank")


var/list/rune_dict = list(
	"convert" = list("join","blood","self"),
	"wall" = list("destroy","travel","self"),
	"blood boil" = list("destroy","see","blood"),
	"blood drain" = list("travel","blood","self"),
	"raise dead" = list("destroy","join","other"),
	"summon narsie" = list("hell","join","self"),
	"communicate" = list("self","other","technology"),
	"emp" = list("destroy","see","technology"),
	"manifest" = list("blood","see","travel"),
	"summon tome" = list("see","blood","hell"),
	"see invisible" = list("see","hell","join"),
	"hide" = list("hide","see","blood"),
	"reveal" = list("blood","see","hide"),
	"astral journey" = list("hell","travel","self"),
	"imbue" = list("hell","technology","join"),
	"sacrifice" = list("hell","blood","join"),	//SAC
	"summon cultist" = list("join","other","self"),
	"free cultist" = list("travel","technology","other"),
	"silence" = list("hide","other","see"),
	"blind" = list("destroy","see","other"),
	"shadow" = list("hide","see","technology"),
	"stun" = list("join","hide","technology"),
	"armor" = list("hell","destroy","other"),
	"teleport" = list("travel","self"),
	"teleport other" = list("travel","other")
	)
var/list/rune_dict_paths = list(
	"convert" = /obj/effect/rune/convert,
	"wall" = /obj/effect/rune/wall,
	"blood boil" = /obj/effect/rune/bloodboil,
	"blood drain" = /obj/effect/rune/drain,
	"raise dead" = /obj/effect/rune/raise,
	"summon narsie" = /obj/effect/rune/tearreality,
	"communicate" = /obj/effect/rune/communicate,
	"emp" = /obj/effect/rune/emp,
	"manifest" = /obj/effect/rune/manifest,
	"summon tome" = /obj/effect/rune/tomesummon,
	"see invisible" = /obj/effect/rune/seer,
	"hide" = /obj/effect/rune/obscure,
	"reveal" = /obj/effect/rune/revealrunes,
	"astral journey" = /obj/effect/rune/ajourney,
	"imbue" = /obj/effect/rune/talisman,
	"sacrifice" = /obj/effect/rune/sacrifice,	//SAC
	"summon cultist" = /obj/effect/rune/cultsummon,
	"free cultist" = /obj/effect/rune/freedom,
	"silence" = /obj/effect/rune/silence,
	"blind" = /obj/effect/rune/blind,
	"shadow" = /obj/effect/rune/shadow,
	"stun" = /obj/effect/rune/runestun,
	"armor" = /obj/effect/rune/armor,
	"teleport" = /obj/effect/rune/teleport,
	"teleport other" = /obj/effect/rune/itemport)



/obj/item/weapon/tome/New()
	..()
	var/word_dict = list("travel" = wordtravel, "blood" = wordblood, "join" = wordjoin, "hell" = wordhell, "destroy" = worddestr, "technology" = wordtech, "self" = wordself, "see" = wordsee, "other" = wordother, "hide" = wordhide)
	for(var/W in ticker.mode.globalwords)
		words[word_dict[W]] = W

/obj/item/weapon/tome/attack(mob/living/M, mob/living/user)
	if(istype(M,/mob/dead/observer))
		M.invisibility = 0
		user.visible_message("<span class='warning'>[user] strikes the air with [src], and a spirit appears!</span>", \
							 "<span class='danger'>You drag the ghost to your plane of reality!</span>")
		add_logs(user, M, "smacked", src)
		return
	if(!istype(M))
		return
	if(!iscultist(user))
		return ..()
	if(iscultist(M))
		if(M.reagents && M.reagents.has_reagent("holywater")) //allows cultists to be rescued from the clutches of ordained religion
			user << "<span class='notice'>You remove the taint from [M].</span>"
			var/holy2unholy = M.reagents.get_reagent_amount("holywater")
			M.reagents.del_reagent("holywater")
			M.reagents.add_reagent("unholywater",holy2unholy)
			add_logs(user, M, "smacked", src, " removing the holy water from them")
		return
	M.take_organ_damage(0, 15) //Used to be a random between 5 and 20
	playsound(M, 'sound/weapons/sear.ogg', 50, 1)
	M.visible_message("<span class='danger'>[user] strikes [M] with the arcane tome!</span>", \
					  "<span class='userdanger'>[user] strikes you with the tome, searing your flesh!</span>")
	flick("tome_attack", src)
	user.do_attack_animation(M)
	add_logs(user, M, "smacked", src)

/obj/item/weapon/tome/attack_self(mob/user)
	if(!iscultist(user))
		user << "<span class='warning'>[src] seems full of unintelligible shapes, scribbles, and notes. Is this some sort of joke?</span>"
	if(!usr.canmove || usr.stat || usr.restrained())
		return
	open_tome(user)

/obj/item/weapon/tome/proc/open_tome(mob/user)
	var/choice = alert(user,"You open the tome...",,"Commune","Scribe Rune","(More...)")
	switch(choice)
		if("(More...)")
			var/choice2 = alert(user,"You open the tome...",,"(Back...)", "Information")
			switch(choice2)
				if("(Back...)")
					return open_tome(user)
				if("Information")
					read_tome(user)
		if("Scribe Rune")
			scribe_rune(user)
		if("Commune")
			var/input = stripped_input(usr, "Please enter a message to tell to the other acolytes.", "Voice of Blood", "")
			if(!input)
				return
			cultist_commune(user, 1, 0, input)

/obj/item/weapon/tome/proc/read_tome(mob/user)
	var/text = ""
	text += "<center><font color='red' size=3><b><i>Archives of the Dark One</i></b></font></center><br><br><br>"
	text += "As a member of the cult, your goals are almost or entirely impossible to complete without special aid from the Geometer's plane. The primary method of doing this are <b>runes</b>. These \
	scribings, drawn in blood, are concentrated nodes of the magic within Nar-Sie's realm and will allow the performance of many tasks to aid you and the rest of the cult in your objectives. Runes \
	have many different names, and almost all of them are known as Rites. The only rune that is not a Rite is the Ritual of Dimensional Rending, which can only be performed with nine cultists and calls \
	forth the avatar of the Geometer itself (so long as it consents). A small description of each rune can be found below.<br><br>Do note that sometimes runes can be drawn incorrectly. Runes such as these \
	will be colorful and written in gibberish. They are malformed, and invoking them serves only to ignite the Geometer's wrath. Be cautious in your scribings.<br><br>A rune's name and effects can be \
	revealed by examining the rune.<br><br><br>"/*In order to write a rune, you must know the combination of words required for the rune. These words are in the tongue of the Geometer and must be written as such. \
	A rune will always have a specific combination, and the combination for runes may be revealed by perfomring actions such as conversion or sacrifice. Once a rune has been written, any cultists can \
	examine it to find out its \"grammar\", or the words required to scribe it. To scribe the rune, the words must be entered in lowercase and separated by exactly one space. For instance, to draw a \
	Rite of Enlightenment, one would enter the sentence \"certum nahlizet ego\", which means \"join blood self\". You may guess at combinations or perform actions to discover them.<br><br>A full list of \
	the Words of Power as well as their meanings in plain English are listed below, although a more complete archive may be accessed at a research desk.<br><br>\
	<b>The Words of Power</b><br>\
	\"ire\" is Travel<br>\
	\"ego\" is Self<br>\
	\"nahlizet\" is Blood<br>\
	\"certum\" is Join<br>\
	\"veri\" is Hell<br>\
	\"jatkaa\" is Other<br>\
	\"mgar\" is Destroy<br>\
	\"balaq\" is Technology<br>\
	\"karazet\" is See<br>\
	\"geeri\" is Hide<br><br>\
	<b>A few basic runes</b><br>\
	<i>Rite of Translocation:</i> \"ire ego\"<br>\
	<i>Rite of Enlightenment:</i> \"certum nahlizet ego\"<br>\
	<i>Rite of Tribute:</i> \"veri nahlizet certum\"<br>\
	<i>Rite of Knowledge:</i> \"karazet nahlizet ego\"<br>\
	<br><br><br>"*/

	text += "<font color='red'><b>Teleport</b></font><br>The Rite of Translocation is a unique rite in that it requires a keyword before the scribing can begin. When invoked, the rune will \
	search for other Rites of Translocation with the same keyword. Assuming one is found, the user will be instantaneously transported to the location of the other rune. If more than two runes are scribed \
	with the same keyword, it will choose randomly between all eligible runes and send the invoker to one of them.<br><br>"

	text += "<font color='red'><b>Teleport Other</b></font><br>The Rite of Forced Translocation, like the Rite of Translocation, works by teleporting the person on the rune to one of the \
	same keyword. However, this rune will only work on people other than the user, allowing the user to send any living creature somewhere else.<br><br>"

	text += "<font color='red'><b>Summon Tome</b></font><br>The Rite of Knowledge is a simplistic rune. When invoked, it will summon a single arcane tome to the rune's location before vanishing. \
	<br><br>"

	text += "<font color='red'><b>Convert</b></font><br>The Rite of Enlightment is paramount to the success of the cult. It will allow you to convert normal crew members into cultists. \
	To do this, simply place the crew member upon the rune and invoke it. This rune requires two acolytes to use. If the target to be converted is loyalty-implanted or a certain assignment, they will \
	be unable to be converted. People the Geometer wishes sacrificed will also be ineligible for conversion, and anyone with a shielding presence like a null rod will not be converted.<br><br>"

	text += "<font color='red'><b>Sacrifice</b></font><br>The Rite of Tribute is used to offer sacrifice to the Geometer. Simply place any living creature upon the rune and invoke it (this will not \
	target cultists!). If this creature has a mind, a soul shard will be created and the creature's soul transported to it. This rune is required if the cult's objectives include the sacrifice of a crew \
	member.<br><br>"

	text += "<font color='red'><b>Raise Dead</b></font><br>The Rite of Resurrection is a delicate rite that requires two corpses. To perform the ritual, place the corpse you wish to revive onto \
	the rune and the offering body adjacent to it. When the rune is invoked, the body to be sacrificed will turn to ashes, the life force flowing into the revival target. Assuming the target is not moved \
	within a few seconds, they will be brought back to life, healed of all ailments.<br><br>"

	text += "<font color='red'><b>Veil Runes</b></font><br>The Rite of Obscurity is a rite that will cause all nearby runes to become invisible. The runes will still be considered by other rites \
	(such as the Rite of Translocation) but is unusuable directly.<br><br>"

	text += "<font color='red'><b>Reveal Runes</b></font><br>The Rite of True Sight is the foil of the Rite of Obscurity. It will turn all invisible runes visible once more, in addition to causing \
	all spirits nearby to become partially corporeal.<br><br>"

	text += "<font color='red'><b>Disguise Runes</b></font><br>Many crew men enjoy drawing runes in crayon that resemble spell circles in order to play pranks on their fellow crewmen. The Rite of \
	False Truths takes advantage of this very joke. When invoked, all nearby runes will appear dull, precisely resembling those drawn in crayon. They still cannot be cleaned by conventional means, so \
	anyone trying to clean up the rune may become suspicious as it does not respond.<br><br>"

	text += "<font color='red'><b>Electromagnetic Disruption</b></font><br>Robotic lifeforms have time and time again been the downfall of fledgling cults. The Rite of Disruption may allow you to gain the upper \
	hand against these pests. By using the rune, a large electromagnetic pulse will be emitted from the rune's location.<br><br>"

	text += "<font color='red'><b>Astral Communion</b></font><br>The Rite of Astral Communion is perhaps the most ingenious rune that is usable by a single person. Upon invoking the rune, the \
	user's spirit will be ripped from their body. In this state, the user's physical body will be locked in place to the rune itself - any attempts to move it will result in the rune pulling it back. \
	The body will also take constant damage while in this form, and may even die. The user's spirit will contain their consciousness, and will allow them to freely wander the station as a ghost. This may \
	also be used to commune with the dead.<br><br>"

	text += "<font color='red'><b>Form Shield</b></font><br>While simple, the Rite of the Corporeal Shield serves an important purpose in defense and hindering passage. When invoked, the \
	rune will draw a small amount of life force from the user and make the space above the rune completely dense, rendering it impassable to all but the most complex means. The rune may be invoked again to \
	undo this effect and allow passage again.<br><br>"

	text += "<font color='red'><b>Deafen</b></font><br>The Rite of the Unheard Whisper is simple. When invoked, it will cause all non-cultists within a radius of seven tiles to become \
	completely deaf for a large amount of time.<br><br>"

	text += "<font color='red'><b>Blind</b></font><br>Much like the Rite of the Unheard Whisper, the Rite of the Unseen Glance serves a single purpose. Any non-cultists who can see \
	the rune will instantly be blinded for a substantial amount of time.<br><br>"

	text += "<font color='red'><b>Stun</b></font><br>A somewhat empowered version of the Rite of the Unseen Glance, this rune will cause any non-cultists that can see the rune to become \
	disoriented, disabling them for a short time.<br><br>"

	text += "<font color='red'><b>Summon Cultist</b></font><br>The Rite of Joined Souls requires two acolytes to use. When invoked, it will allow the user to summon a single cultist to the rune from \
	any location. This will deal a moderate amount of damage to all invokers.<br><br>"

	text += "<font color='red'><b>Imbue Talisman</b></font><br>The Rite of Binding is the only way to create talismans. A blank sheet of paper must be on top of the rune, with a valid rune nearby. After \
	invoking it, the paper will be converted into a talisman, and the rune inlaid upon it.<br><br>"

	text += "<font color='red'><b>Fabricate Shell</b></font><br>The Rite of Fabrication is the main way of creating construct shells. To use it, one must place five sheets of plasteel on top of the rune \
	and invoke it. The sheets will them be twisted into a construct shell, ready to recieve a soul to occupy it.<br><br>"

	text += "<font color='red'><b>Summon Arnaments</b></font><br>The Rite of Arming will equip the user with invoker's robes, a backpack, a Nar-Sian longsword, and a pair of boots. Any items that cannot \
	be equipped will instead not be summoned regardless.<br><br>"

	text += "<font color='red'><b>Drain Life</b></font><br>The Rite of Leeching will drain the life of any non-cultist above the rune and heal the invoker for the same amount.<br><br>"

	text += "<font color='red'><b>Boil Blood</b></font><br>The Rite of Boiling Blood may be considered one of the most dangerous rites composed by the Nar-Sian cult. When invoked, it will do a \
	massive amount of damage to all non-cultist viewers, but it will also emit an explosion upon invocation. Use with caution<br><br>"

	text += "<font color='red'><b>Manifest Spirit</b></font><br>If you wish to bring a spirit back from the dead with a wish for vengeance and desire to serve, the Rite of Spectral \
	Manifestation can do just that. When invoked, any spirits above the rune will be brought to life as a human wearing nothing that seeks only to serve you and the Geometer. However, the spirit's link \
	to reality is fragile - you must remain on top of the rune, and you will slowly take damage. Upon stepping off the rune, the spirits will dissipate, dropping their items to the ground. You may manifest \
	multiple spirits with one rune, but you will rapidly take damage in doing so.<br><br>"

	text += "<font color='red'><b><i>Call Forth The Geometer</i></b></font><br>There is only one way to summon the avatar of Nar-Sie, and that is the Ritual of Dimensional Rending. This ritual, in \
	comparison to other runes, is very large, requiring a 3x3 space of empty tiles to create. To invoke the rune, nine cultists must stand on the rune, so that all of them are within its circle. Then, \
	simply invoke it. A brief tearing will be heard as the barrier between dimensions is torn open, and the avatar will come forth.<br><br><br>"

	text += "While runes are excellent for many tasks, they lack portability. The advent of <b>talismans</b> has, to a degree, solved this inconvenience. Simply put, a talisman is a piece of paper with a \
	rune inlaid within it. The words of the rune can be whispered in order to invoke its effects, although usually to a lesser extent. To create a talisman, simply use a Rite of Binding as described above. \
	Unless stated otherwise, talismans are invoked by activating them in your hand. A list of valid rites, as well as the effects of their talisman form, can be found below.<br><br><br>"

	text += "<font color='red'><b>Talisman of Teleportation</b></font><br>The talisman form of the Rite of Translocation will transport the invoker to a randomly chosen rune of the same keyword, then \
	disappear.<br><br>"

	text += "<font color='red'><b>Talisman of Tome summoning</b></font><br>This talisman functions identically to the rune. It can be used once, then disappears.<br><br>"

	text += "<font color='red'><b>Talismans of Veiling, Revealing, and Disguising</b></font><br>These talismans all function identically to their rune counterparts, but with less range. In addition, \
	the Talisman of True Sight will not reveal spirits. They will disappear after one use.<br><br>"

	text += "<font color='red'><b>Talisman of Electromagnets</b></font><br>This talisman functions like the Rite of Disruption. It disappears after one use.<br><br>"

	text += "<font color='red'><b>Talisman of Stunning</b></font><br>Without this talisman, the cult would have no way of easily acquiring targets to convert. Commonly called \"stunpapers\", this \
	talisman functions differently from others. Rather than simply reading the words, the target must be attacked directly with the talisman. The talisman will then knock down the target for a long \
	duration in addition to rendering them incapable of speech. Robotic lifeforms will suffer the effects of a heavy electromagnetic pulse instead."

	var/datum/browser/popup = new(user, "tome", "", 800, 600)
	popup.set_content(text)
	popup.open()
	return 1

/obj/item/weapon/tome/proc/scribe_rune(mob/user)
	var/chosen_keyword
	var/rune_to_scribe
	var/entered_rune_name
	var/list/possible_runes = list()
	for(var/T in subtypesof(/obj/effect/rune) - /obj/effect/rune/malformed)
		var/obj/effect/rune/R = T
		if(initial(R.cultist_name))
			possible_runes.Add(initial(R.cultist_name)) //This is to allow the menu to let cultists select runes by name rather than by object path. I don't know a better way to do this
	if(!possible_runes.len)
		return
	entered_rune_name = input(user, "Choose a rite to scribe.", "Sigils of Power") as null|anything in possible_runes
	for(var/T in typesof(/obj/effect/rune))
		var/obj/effect/rune/R = T
		if(initial(R.cultist_name) == entered_rune_name)
			rune_to_scribe = R
			if(initial(R.req_keyword))
				var/the_keyword = stripped_input(usr, "Please enter a keyword for the rune.", "Enter Keyword", "")
				if(!the_keyword)
					return
				chosen_keyword = the_keyword
			break
	if(!rune_to_scribe)
		return
	user.visible_message("<span class='warning'>[user] cuts open their arm and begins writing in their own blood!</span>", \
						 "<span class='danger'>You slice open your arm and begin drawing a sigil of the Geometer.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(0.1, BRUTE, pick("l_arm", "r_arm"))
	if(!do_after(user, 50, target = get_turf(user)))
		return
	user.visible_message("<span class='warning'>[user] creates a strange circle in their own blood.</span>", \
						 "<span class='danger'>You finish drawing the arcane markings of the Geometer.</span>")
	var/obj/effect/rune/R = new rune_to_scribe(get_turf(user))
	if(chosen_keyword)
		R.keyword = chosen_keyword


//BREAK POINT


	if(!wordtravel)
		runerandom()
	if(iscultist(user))
		/*
		var/C = 0
		for(var/obj/effect/rune/N in global.runes)
			C++
		*/
		if (!istype(user.loc,/turf))
			user << "<span class='danger'>You do not have enough space to write a proper rune.</span>"
			return

		
		if(istype(get_turf(usr),/turf/space))		//space
			usr << "\red \i You can't write in space."
			return

		/*No more Rune limit
		if (0)//C>=26+runedec+ticker.mode.cult.len) //including the useless rune at the secret room, shouldn't count against the limit of 25 runes - Urist
			alert("The cloth of reality can't take that much of a strain. Remove some runes first!")
			return
		else
		*/
		
		switch(alert("You open the tome",,"Commune","Scribe a rune", "Notes")) //Fuck the "Cancel" option. Rewrite the whole tome interface yourself if you want it to work better. And input() is just ugly. - K0000
			if("Cancel")
				return
			if("Commune")
				if(usr.get_active_hand() != src)
					return
				var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
				if(!input)
					return
				cultist_commune(user, 1, 0, input)
				return
			if("Notes")
				if(usr.get_active_hand() != src)
					return
				notedat = {"
					<a href='byond://?src=\ref[src];action=read'>Read the Arcane Tome.</A></BR>
					<br><b>Word translation notes</b> <br>
					[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
					[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
					[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
					[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
					[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
					[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
					[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
					[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
					[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
					[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
					"}	// whoever screwed the tabbing on this originally is an asshole.
//					call(/obj/item/weapon/tome/proc/edit_notes)()
				user << browse("[notedat]", "window=notes")
				return
			if("Scribe a rune")		//fixed more assbackward tabbing
				if(usr.get_active_hand() != src)
					return
				if (C>=26+runedec+ticker.mode.cult.len) //including the useless rune at the secret room, shouldn't count against the limit of 25 runes - Urist
					alert("The cloth of reality can't take that much of a strain. Remove some runes first!")
					return
				var/list/dictionary = list(
					"convert" = list("join","blood","self"),
					"wall" = list("destroy","travel","self"),
					"blood boil" = list("destroy","see","blood"),
					"blood drain" = list("travel","blood","self"),
					"raise dead" = list("blood","join","hell"),
					"summon narsie" = list("hell","join","self"),
					"communicate" = list("self","other","technology"),
					"emp" = list("destroy","see","technology"),
					"manifest" = list("blood","see","travel"),
					"summon tome" = list("see","blood","hell"),
					"see invisible" = list("see","hell","join"),
					"hide" = list("hide","see","blood"),
					"reveal" = list("blood","see","hide"),
					"astral journey" = list("hell","travel","self"),
					"imbue" = list("hell","technology","join"),
					"sacrifice" = list("hell","blood","join"),
					"summon cultist" = list("join","other","self"),
					"free cultist" = list("travel","technology","other"),
					"deafen" = list("hide","other","see"),
					"blind" = list("destroy","see","other"),
					"stun" = list("join","hide","technology"),
					"armor" = list("hell","destroy","other"),
					"teleport" = list("travel","self"),
					"teleport other" = list("travel","other"),
					"summon shell" = list("travel","hell","technology")
					)


				var/list/scribewords = list("none")

				var/list/english = list()

				for (var/entry in words)
					if (words[entry] != entry)
						english+=list(words[entry] = entry)
				
				for (var/entry in rune_dict)
					var/list/required = rune_dict[entry]
					if (length(english&required) == required.len)
						scribewords += entry

				var/chosen_rune = null


				if(usr)
					chosen_rune = input ("Choose a rune to scribe.") in scribewords
					if (!chosen_rune)
						return
					if (chosen_rune == "none")
						user << "<span class='danger'>You decide against scribing a rune, perhaps you should take this time to study your notes.</span>"
						return
					if (chosen_rune == "teleport")
						last_word += input ("Choose a destination word") in english
					if (chosen_rune == "teleport other")
						last_word += input ("Choose a destination word") in english

				if(user.get_active_hand() != src)
					return

				for (var/mob/V in viewers(src))
					V.show_message("<span class='danger'>[user] slices open a finger and begins to chant and paint symbols on the floor.</span>", 3, "<span class='italics'>You hear chanting.</span>", 2)
				user << "<span class='userdanger'>You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world.</span>"
				user.take_overall_damage((rand(9)+1)/10) // 0.1 to 1.0 damage
				if(do_after(user, 50, target = user))
					if(usr.get_active_hand() != src)
						return
					var/mob/living/carbon/human/H = user
					var/obj/effect/rune/R = new /obj/effect/rune(user.loc)
					user << "<span class='danger'>You finish drawing the arcane markings of the Geometer.</span>"
					var/list/required = rune_dict[chosen_rune]
					var/path
					for(var/key in rune_dict)
						if(english[required[1]] == word_dict[rune_dict[key][1]] && english[required[2]] == word_dict[rune_dict[key][2]])
							if(key == "teleport" || key == "teleport other")
								path = rune_dict_paths[key]
								R = new path(user.loc)
								break
							else if(rune_dict[key][3] && english[required[3]] == word_dict[rune_dict[key][3]])
								path = rune_dict_paths[key]
								R = new path(user.loc)
								break
						
					if(!R)
						R = new /obj/effect/rune/dummy(user.loc)
						if(prob(15))		//Punish blind research, Nar-Sie wants blood
							user << "<span class='userdanger'>Lord Nar-Sie is furious!</span>"
							user.take_overall_damage(120, 0)
						else
							user.take_overall_damage(30, 0)
							user << "<span class='danger'>You feel the life draining from you, as if Lord Nar-Sie is displeased with you.</span><span class='userdanger'>You dread what could have happened to you.</span>"
					R.word1 = english[required[1]]
					R.word2 = english[required[2]]
					if(last_word)
						R.word3 = english[last_word]
					else
						R.word3 = english[required[3]]
					//R.check_icon()
					R.blood_DNA = list()
					R.blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type
				return
	else
		user << "The book seems full of illegible scribbles. Is this a joke?"
		return

/obj/item/weapon/tome/attackby(obj/item/weapon/tome/T, mob/living/user, params)
	if(istype(T, /obj/item/weapon/tome)) // sanity check to prevent a runtime error
		switch(alert("Copy the runes from your tome?",,"Copy", "Cancel"))
			if("cancel")
				return
	//	var/list/nearby = viewers(1,src) //- Fuck this as well. No clue why this doesnt work. -K0000
	//		if (T.loc != user)
	//			return
	//	for(var/mob/M in nearby)
	//		if(M == user)
		for(var/entry in words)
			words[entry] = T.words[entry]
		user << "<span class='notice'>You copy the translation notes from your tome.</span>"


/obj/item/weapon/tome/examine(mob/user)
	..()
	if(iscultist(user))
		user << "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of."

/obj/item/weapon/tome/imbued //admin tome, spawns working runes without waiting
	w_class = 2
	var/cultistsonly = 1
	attack_self(mob/user as mob)
		if(src.cultistsonly && !iscultist(usr))
			return
		if(!wordtravel)
			runerandom()
		if(user)
			var/r
			if (!istype(user.loc,/turf))
				user << "<span class='danger'>You do not have enough space to write a proper rune.</span>"
			
			var/word_dict = list("travel" = wordtravel, "blood" = wordblood, "join" = wordjoin, "hell" = wordhell, "destroy" = worddestr, "technology" = wordtech, "self" = wordself, "see" = wordsee, "other" = wordother, "hide" = wordhide)
			var/list/unkwords = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
			var/chosen_rune = null
			var/last_word = null
			chosen_rune = input("Choose a rune to scribe", "Rune Scribing") in rune_dict //not cancellable.
			
			if (chosen_rune == "teleport")
				last_word += input ("Choose a destination word") in unkwords
			if (chosen_rune == "teleport other")
				last_word += input ("Choose a destination word") in unkwords
			
			var/path = rune_dict_paths[chosen_rune]
			var/obj/effect/rune/R = new path(user.loc)
			if(istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = user
				R.blood_DNA = list()
				R.blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type
			R.word1 = word_dict[rune_dict[chosen_rune][1]]
			R.word2 = word_dict[rune_dict[chosen_rune][2]]
			if(last_word)
				R.word3 = last_word
			else
				R.word3 = word_dict[rune_dict[chosen_rune][3]]
			//check_icon()
