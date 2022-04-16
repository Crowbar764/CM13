/datum/tech/xeno
	name = "Xeno Tech"

	var/hivenumber = XENO_HIVE_NORMAL
	var/datum/hive_status/hive

/datum/tech/xeno/on_tree_insertion(var/datum/techtree/xenomorph/tree)
	. = ..()
	hivenumber = tree.hivenumber
	hive = GLOB.hive_datum[hivenumber]

/datum/tech/xeno/on_unlock()
	. = ..()

	if(tech_flags & TECH_FLAG_NO_ANNOUNCE)
		message_admins("one")

	if(!(tech_flags & TECH_FLAG_NO_ANNOUNCE))
		message_admins("two")

	message_admins("Flags: [tech_flags]")

	if(!(tech_flags & TECH_FLAG_NO_ANNOUNCE))
		xeno_message("The hive has unlocked the '[name]' evolution.", 3, hivenumber)
		for(var/m in hive.totalXenos)
			var/mob/M = m
			playsound_client(M.client, "queen")
