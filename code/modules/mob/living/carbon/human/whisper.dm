/mob/living/carbon/human/whisper(message as text)
	
	if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
		return

	if (!message || silent)
		return


	var/alt_name = ""
	if (src.name != GetVoice())
		alt_name = " (as [get_id_name("Unknown")])"

	
	if(src.wear_mask)
		message = wear_mask.speechModification(message)
		
	var/critical = InCritical()
		
	var/rendered = ..(message,alt_name,critical)


	// We whispered our final breath, now we die and show the message you have sent
	// since it might have been cut off and it would be annoying not being able to know.
	if(critical)
		src << rendered
		succumb(1)
