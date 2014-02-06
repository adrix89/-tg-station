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
	desc = ""
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state="1" //random shape and color for dummy runes
	color = rgb(255, 0, 0)
	unacidable = 1
	layer = TURF_LAYER
	var/word_dict
	var/word1
	var/word2
	var/word3
	var/list/shadow_mobs = list()
	var/list/shadow_stuff = list()
	var/active		//see if a rune is already active
	var/mob/living/drained		//mob that is beeing drained
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
	rand_icon()
	..()
	var/image/blood = image(loc = src)
	blood.override = 1
	for(var/mob/living/silicon/ai/AI in player_list)
		AI.client.images += blood
	var/area/A = get_area_master(usr)	//No idea why it can't fince the area normaly
	if(A && A.shadow)	//find if we are in shadow rune
		var/obj/effect/rune/R = A.shadow_rune
		R.shadow_stuff += src
		invisibility = 55
		
/obj/effect/rune/proc/rand_icon()
	return

/obj/effect/rune/Del()
	global.runes -= src
	..()
	
/obj/effect/rune/proc/invoke()	//Dummy rune,override for real ones
	var/mob/living/user = usr
	user.take_overall_damage(20, 0)
	user << "<span class='danger'>You feel the life draining from you, as if Lord Nar-Sie is displeased with you. Better not mess with it again.</span>"
	return fizzle()

/obj/effect/rune/examine()
	set src in view(2)

	if(!iscultist(usr))
		usr << "A strange collection of symbols drawn in blood."
		return
		/* Explosions... really?
		if(desc && !usr.stat)
			usr << "It reads: <i>[desc]</i>."
			sleep(30)
			explosion(src.loc, 0, 2, 5, 5)
			if(src)
				del(src)
		*/
	if(!desc)
		usr << "A spell circle drawn in blood. It reads: <i>[word1] [word2] [word3]</i>."
	else
		usr << "Explosive Runes inscription in blood. It reads: <i>[desc]</i>."

	return

/obj/effect/rune/attackby(I as obj, user as mob)
	//*No more rune limit, runes are now permanent
	if(istype(I, /obj/item/weapon/tome) && iscultist(user))
		user << "<span class='notice'>You retrace your steps, carefully undoing the lines of the rune.</span>"
		/*
		R.blood_DNA = list()
		R.blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type*/
		del(src)
		return
	
	if(istype(I, /obj/item/weapon/nullrod))
		user << "<span class='notice'>You disrupt the vile magic with the deadening field of the null rod!</span>"
		del(src)
		return
	else if(istype(I, /obj/item/weapon/melee/cultblade) || istype(I, /obj/item/weapon/tome))
		attack_hand(user)
	return

/obj/effect/rune/attack_hand(mob/living/user as mob)
	if(!iscultist(user))
		user << "<span class='notice'>You can't mouth the arcane scratchings without fumbling over them.</span>"
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_mask, /obj/item/clothing/mask/muzzle))
			H << "<span class='notice'>You are unable to speak the words of the rune.</span>"
			return
	if(!word1 || !word2 || !word3 || prob(user.getBrainLoss()))
		return fizzle()
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


/obj/effect/rune/proc/fizzle()
	if(istype(src,/obj/effect/rune))
		usr.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
	else
		usr.whisper(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
	for (var/mob/V in viewers(src))
		V.show_message("\red The markings pulse with a small burst of light, then fall dark.", 3, "\red You hear a faint fizzle.", 2)
	return

/obj/effect/rune/proc/shade_attack(mob/user as mob)	//shades can now activate some runes
	if(!is_shade(user))
		return
	if(!word1 || !word2 || !word3)
		return fizzle()
	switch(src.type)
		if(/obj/effect/rune/emp)
			invoke(src.loc,3)
		if(/obj/effect/rune/obscure)
			invoke(4)
		if(/obj/effect/rune/revealrunes)
			invoke(6,src)
		if(/obj/effect/rune/itemport)
			invoke(src.word3)
		if(/obj/effect/rune/teleport)
			invoke(src.word3)
	if(src.type in list(/obj/effect/rune/runestun,/obj/effect/rune/blind,/obj/effect/rune/silence,/obj/effect/rune/communicate,/obj/effect/rune/wall))
		invoke()
	return
	
/obj/effect/rune/convert
	icon_state = "3"
/obj/effect/rune/wall
	icon_state = "1"
/obj/effect/rune/bloodboil
	icon_state = "4"
/obj/effect/rune/drain
	icon_state = "2"
/obj/effect/rune/raise
	icon_state = "1"
/obj/effect/rune/tearreality
	icon_state = "4"
/obj/effect/rune/communicate
	icon_state = "3"
	color = rgb(200, 0, 0)
/obj/effect/rune/emp
	icon_state = "5"
/obj/effect/rune/manifest
	icon_state = "6"
/obj/effect/rune/tomesummon
	icon_state = "5"
	color = rgb(0, 0, 255)
/obj/effect/rune/seer
	icon_state = "4"
	color = rgb(0, 0, 255)
/obj/effect/rune/obscure
	icon_state = "1"
	color = rgb(0, 0, 255)
/obj/effect/rune/revealrunes
	icon_state = "4"
	color = rgb(255, 255, 255)
/obj/effect/rune/ajourney
	icon_state = "6"
	color = rgb(0, 0, 255)
/obj/effect/rune/talisman
	icon_state = "3"
	color = rgb(0, 0, 255)
/obj/effect/rune/sacrifice/rand_icon()
	icon_state="[rand(1,6)]"
	color = rgb(255, 255, 255)
/obj/effect/rune/cultsummon
	icon_state = "2"
	color = rgb(200, 0, 200)
/obj/effect/rune/freedom
	icon_state = "4"
	color = rgb(255, 0, 255)
/obj/effect/rune/silence
	icon_state = "4"
	color = rgb(0, 255, 0)
/obj/effect/rune/blind
	icon_state = "4"
	color = rgb(0, 0, 255)
/obj/effect/rune/shadow
	icon_state = "4"
	color = "#331533"
/obj/effect/rune/runestun
	icon_state = "2"
	color = rgb(100, 0, 100)
/obj/effect/rune/armor/rand_icon()
	icon_state="[rand(1,6)]"
	color = rgb(rand(1,255),rand(1,255),rand(1,255))
/obj/effect/rune/teleport
	icon_state = "2"
	color = rgb(0, 0, 255)
/obj/effect/rune/itemport
	icon_state = "2"
	color = rgb(, 255, 0)
/obj/effect/rune/dummy/rand_icon()
	icon_state="[rand(1,6)]"
	color = rgb(rand(1,255),rand(1,255),rand(1,255))

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
	icon_state ="tome"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	var/notedat = ""
	var/tomedat = ""
	var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")

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
				<b>Shadow: </b>Hide See Technology<br>
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
				<h3>Shadow</h3>
				With this rune you can cloak an area invisible to the outside of that area,only inside can you see.I will cloak any body and the result of slaughter as well as runes.<br>
				It will constantly drain a cultist in that area. To change the cultist that is being drained just invoke the rune again.<br>
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
//		call(/obj/item/weapon/tome/proc/edit_notes)()
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

/obj/item/weapon/tome/attack(mob/living/M as mob, mob/living/user as mob)
	add_logs(user, M, "smacked", object=src)
	if(istype(M,/mob/dead))
		M.invisibility = 0
		user.visible_message( \
			"\red [user] drags the ghost to our plane of reality!", \
			"\red You drag the ghost to our plane of reality!" \
		)
		return
	if(!istype(M))
		return
	if(!iscultist(user))
		return ..()
	if(iscultist(M))
		return
	M.take_organ_damage(0,rand(5,20)) //really lucky - 5 hits for a crit
	for(var/mob/O in viewers(M, null))
		O.show_message(text("\red <B>[] beats [] with the arcane tome!</B>", user, M), 1)
	M << "\red You feel searing heat inside!"

/obj/item/weapon/tome/attack_self(mob/living/user as mob)
	usr = user
	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(!wordtravel)
		runerandom()
	if(iscultist(user))
		/*
		var/C = 0
		for(var/obj/effect/rune/N in global.runes)
			C++
		*/
		if (!istype(user.loc,/turf))
			user << "\red You do not have enough space to write a proper rune."
			return



		//No more Rune limit
		if (0)//C>=26+runedec+ticker.mode.cult.len) //including the useless rune at the secret room, shouldn't count against the limit of 25 runes - Urist
			alert("The cloth of reality can't take that much of a strain. Remove some runes first!")
			return
		else
			switch(alert("You open the tome",,"Read it","Scribe a rune", "Notes")) //Fuck the "Cancel" option. Rewrite the whole tome interface yourself if you want it to work better. And input() is just ugly. - K0000
				if("Cancel")
					return
				if("Read it")
					if(usr.get_active_hand() != src)
						return
					user << browse("[tomedat]", "window=Arcane Tome")
					return
				if("Notes")
					if(usr.get_active_hand() != src)
						return
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
		//						call(/obj/item/weapon/tome/proc/edit_notes)()
					user << browse("[notedat]", "window=notes")
					return
		if(usr.get_active_hand() != src)
			return
		

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
		var/last_word = null

		if(usr)
			chosen_rune = input ("Choose a rune to scribe.") in scribewords
			if (!chosen_rune)
				return
			if (chosen_rune == "none")
				user << "\red You decide against scribing a rune, perhaps you should take this time to study your notes."
				return
			if (chosen_rune == "teleport")
				last_word += input ("Choose a destination word") in english
			if (chosen_rune == "teleport other")
				last_word += input ("Choose a destination word") in english

		if(user.get_active_hand() != src)
			return

		for (var/mob/V in viewers(src))
			V.show_message("\red [user] slices open a finger and begins to chant and paint symbols on the floor.", 3, "\red You hear chanting.", 2)
		user << "\red You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
		user.take_overall_damage((rand(9)+1)/10) // 0.1 to 1.0 damage
		if(do_after(user, 50))
			if(usr.get_active_hand() != src)
				return
			var/word_dict = list("travel" = wordtravel, "blood" = wordblood, "join" = wordjoin, "hell" = wordhell, "destroy" = worddestr, "technology" = wordtech, "self" = wordself, "see" = wordsee, "other" = wordother, "hide" = wordhide)
			var/mob/living/carbon/human/H = user
			var/obj/effect/rune/R
			user << "\red You finish drawing the arcane markings of the Geometer."
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

/obj/item/weapon/tome/attackby(obj/item/weapon/tome/T as obj, mob/living/user as mob)
	if(istype(T, /obj/item/weapon/tome)) // sanity check to prevent a runtime error
		switch(alert("Copy the runes from your tome?",,"Copy", "Cancel"))
			if("cancel")
				return
//		var/list/nearby = viewers(1,src) //- Fuck this as well. No clue why this doesnt work. -K0000
//			if (T.loc != user)
//				return
//		for(var/mob/M in nearby)
//			if(M == user)
		for(var/entry in words)
			words[entry] = T.words[entry]
		user << "You copy the translation notes from your tome."

/obj/item/weapon/tome/examine()
	set src in usr
	..()
	if(!iscultist(usr))
		usr << "An old, dusty tome with frayed edges and a sinister looking cover."
	else
		usr << "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of. Most of these are useless, though."

/obj/item/weapon/tome/imbued //admin tome, spawns working runes without waiting
	w_class = 2.0
	var/cultistsonly = 1

/obj/item/weapon/tome/imbued/attack_self(mob/user as mob)
	if(src.cultistsonly && !iscultist(usr))
		return
	if(!wordtravel)
		runerandom()
	if(user)
		if (!istype(user.loc,/turf))
			user << "\red You do not have enough space to write a proper rune."
			
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
