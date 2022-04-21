// --------------------------------------------
// *** Get a mob to an area/level ***
// --------------------------------------------
#define MOB_CAN_COMPLETE_AFTER_DEATH 1
#define MOB_FAILS_ON_DEATH 2

/datum/cm_objective/move_mob
	var/mob/living/target
	var/mob_can_die = MOB_CAN_COMPLETE_AFTER_DEATH
	objective_flags = OBJ_DO_NOT_TREE

/datum/cm_objective/move_mob/New(var/mob/living/H)
	if(istype(H, /mob/living))
		target = H
	. = ..()

/datum/cm_objective/move_mob/Destroy()
	target = null
	return ..()

/datum/cm_objective/move_mob/check_completion()
	. = ..()
	if(target.stat == DEAD && mob_can_die & MOB_FAILS_ON_DEATH)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(!H.check_tod() || !H.is_revivable()) // they went unrevivable
				//Synths can (almost) always be revived, so don't fail their objective...
				// if(!isSynth(H))
					// CASPERTODO
					// fail()
				return FALSE
		else
			// fail()
			return FALSE

	if(target.stat != DEAD || mob_can_die & MOB_CAN_COMPLETE_AFTER_DEATH)
		if(validate_destination())
			complete()
			return TRUE

/datum/cm_objective/proc/validate_destination()
	return TRUE

/datum/cm_objective/move_mob/almayer
	controller = TREE_MARINE
/datum/cm_objective/move_mob/validate_destination()
	if(istype(get_area(target), /area/almayer))
		return TRUE

/datum/cm_objective/move_mob/almayer/survivor
	name = "Rescue the Survivor"
	mob_can_die = MOB_FAILS_ON_DEATH
	value = OBJECTIVE_EXTREME_VALUE
	display_category = "Rescue the Survivors"

// --------------------------------------------
// *** Recover the dead ***
// --------------------------------------------
/datum/cm_objective/recover_corpses
	name = "Recover corpses"
	objective_flags = OBJ_DO_NOT_TREE
	display_flags = OBJ_DISPLAY_AT_END | OBJ_DISPLAY_UBIQUITOUS
	state = OBJECTIVE_ACTIVE
	/// List of list of active corpses per tech-faction ownership
	var/list/corpses = list()
	var/list/scored_corpses = list()

/datum/cm_objective/recover_corpses/New()
	. = ..()
	// RegisterSignal(SSdcs, list(
	// 	COMSIG_GLOB_CORPSE_POOLED,
	// 	COMSIG_GLOB_CORPSE_MORPHED
	// ), .proc/handle_corpse_consumption)

	RegisterSignal(SSdcs, list(
		COMSIG_GLOB_MARINE_DEATH,
		COMSIG_GLOB_XENO_DEATH
	), .proc/handle_mob_deaths)

/datum/cm_objective/recover_corpses/Destroy()
	corpses = null
	. = ..()

/datum/cm_objective/recover_corpses/proc/generate_corpses(numCorpsesToSpawn)
	var/list/obj/effect/landmark/corpsespawner/objective_spawn_corpse = GLOB.corpse_spawns.Copy()
	while(numCorpsesToSpawn--)
		if(!length(objective_spawn_corpse))
			break
		var/obj/effect/landmark/corpsespawner/spawner = pick(objective_spawn_corpse)
		var/turf/spawnpoint = get_turf(spawner)
		if(spawnpoint)
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(spawnpoint)
			M.create_hud() //Need to generate hud before we can equip anything apparently...
			arm_equipment(M, "Corpse - [spawner.name]", TRUE, FALSE)
		objective_spawn_corpse.Remove(spawner)

/datum/cm_objective/recover_corpses/post_round_start()
	activate()
	// Populate list at round start with survivors
	// for(var/mob/living/carbon/human/H as anything in GLOB.human_mob_list)
	// 	var/turf/T = get_turf(H)
	// 	if(is_ground_level(T?.z) && H.stat == DEAD && !H.spawned_corpse)
	// 		LAZYADD(corpses, H)


/datum/cm_objective/recover_corpses/proc/handle_mob_deaths(datum/source, mob/living/carbon/dead_mob, gibbed)
	SIGNAL_HANDLER

	message_admins("New corpse dead1 [dead_mob.type]")
	message_admins("New corpse dead2 [dead_mob.name]")



	// if(gibbed || !istype(dead_mob, /mob/living/carbon))
	// 	message_admins("Gibbed or not type")
	// 	return

	if(!iscarbon(dead_mob))
		message_admins("Gibbed or not type")
		return

	// This mob has already been scored before
	if(LAZYISIN(scored_corpses, dead_mob))
		message_admins("corpse already scored.")
		return

	LAZYDISTINCTADD(corpses, dead_mob)
	RegisterSignal(dead_mob, COMSIG_PARENT_QDELETING, .proc/handle_corpse_deletion)
	RegisterSignal(dead_mob, COMSIG_LIVING_REJUVENATED, .proc/handle_mob_revival)

	if (isXeno(dead_mob))
		RegisterSignal(dead_mob, COMSIG_XENO_REVIVED, .proc/handle_mob_revival)
	else
		RegisterSignal(dead_mob, COMSIG_HUMAN_REVIVED, .proc/handle_mob_revival)


/datum/cm_objective/recover_corpses/proc/handle_mob_revival(mob/living/carbon/revived_mob)
	SIGNAL_HANDLER

	message_admins("Corpse being revived")

	UnregisterSignal(revived_mob, list(COMSIG_LIVING_REJUVENATED, COMSIG_PARENT_QDELETING))

	if (isXeno(revived_mob))
		UnregisterSignal(revived_mob, COMSIG_XENO_REVIVED)
	else
		UnregisterSignal(revived_mob, COMSIG_HUMAN_REVIVED)

	LAZYREMOVE(corpses, revived_mob)


/datum/cm_objective/recover_corpses/proc/handle_corpse_deletion(mob/living/carbon/deleted_mob)
	SIGNAL_HANDLER

	message_admins("Corpse being deleted")

	UnregisterSignal(deleted_mob, list(
		COMSIG_LIVING_REJUVENATED,
		COMSIG_PARENT_QDELETING
	))

	if (isXeno(deleted_mob))
		UnregisterSignal(deleted_mob, COMSIG_XENO_REVIVED)
	else
		UnregisterSignal(deleted_mob, COMSIG_HUMAN_REVIVED)

	LAZYREMOVE(corpses, deleted_mob)

/// Get score value for a given corpse
/datum/cm_objective/recover_corpses/proc/score_corpse(mob/target)
	var/value = 0

	if(isYautja(target))
		value = OBJECTIVE_ABSOLUTE_VALUE

	else if(isXeno(target))
		var/mob/living/carbon/Xenomorph/X = target
		switch(X.tier)
			if(1)
				if(isXenoPredalien(X))
					value = OBJECTIVE_ABSOLUTE_VALUE
				else value = OBJECTIVE_LOW_VALUE
			if(2)
				value = OBJECTIVE_MEDIUM_VALUE
			if(3)
				value = OBJECTIVE_EXTREME_VALUE
			else
				if(isXenoQueen(X)) //Queen is Tier 0 for some reason...
					value = OBJECTIVE_ABSOLUTE_VALUE

	else if(isHumanSynthStrict(target))
		return OBJECTIVE_LOW_VALUE

	return value

/// Handle consumption of a corpse by a spawn pool or eggmorpher and addition to base point pool
// /datum/cm_objective/recover_corpses/proc/handle_corpse_consumption(datum/source, mob/target, target_hive)
// 	var/datum/techtree/T = GET_TREE(TREE_XENO)
// 	if(ishuman(target))
// 		var/mob/living/carbon/human/H = target
// 		if(!H.spawned_corpse) // Gives points for pooled marines/survivors/monkey reskins, but not roundstart corpses
// 			T.add_points(TECH_POINTS_PER_CORPSE)
// 	else if(isYautja(target))
// 		T.add_points(TECH_POINTS_PER_CORPSE * 3) // Gives more points in the event a pred gets captured
// 	current += score_corpse(target)
// 	LAZYSET(points_base, TREE_XENO, current)
// 	for(var/F as anything in corpses)
// 		LAZYREMOVE(corpses[F], target)

/datum/cm_objective/recover_corpses/process()
	message_admins("Corpse process:")

	for(var/mob/target as anything in corpses)
		if(QDELETED(target))
			LAZYREMOVE(corpses, target)
			continue

		// Get the corpse value
		var/corpse_val = score_corpse(target)

		// Add points depending on who controls it
		var/turf/T = get_turf(target)
		var/area/A = get_area(T)
		message_admins("Checking Corpse '[target]'.")
		if(istype(A, /area/almayer/medical/morgue) || istype(A, /area/almayer/medical/containment))
			award_points(corpse_val)
			SSobjectives.statistics["corpses_recovered"]++

			message_admins("Corpse '[target]' in ship, awarding points.")
			corpses -= target
			scored_corpses += target

/// Update awarded points to the controlling tech-faction
/datum/cm_objective/recover_corpses/award_points(points)
	message_admins("Awarding points: [points].")
	var/datum/techtree/tree = GET_TREE(TREE_MARINE)
	tree.add_points(points)
	SSobjectives.statistics["corpses_total_points_earned"] += points

// /datum/cm_objective/contain
// 	name = "Contain alien specimens"
// 	objective_flags = OBJ_DO_NOT_TREE
// 	display_flags = OBJ_DISPLAY_AT_END
// 	controller = TREE_MARINE
// 	var/area/recovery_area = /area/almayer/medical/containment/cell
// 	var/contained_specimen_points = 0

// 	var/points_per_specimen_tier_0 = 10
// 	var/points_per_specimen_tier_1 = 50
// 	var/points_per_specimen_tier_2 = 100
// 	var/points_per_specimen_tier_3 = 150
// 	var/points_per_specimen_tier_4 = 200

// /datum/cm_objective/contain/process()
// 	contained_specimen_points = 0
// 	for(var/mob/living/carbon/Xenomorph/X as anything in GLOB.living_xeno_list)
// 		if(istype(get_area(X),recovery_area))
// 			switch(X.tier)
// 				if(1)
// 					if(isXenoPredalien(X))
// 						contained_specimen_points += points_per_specimen_tier_4
// 					else
// 						contained_specimen_points += points_per_specimen_tier_1
// 				if(2)
// 					contained_specimen_points += points_per_specimen_tier_2
// 				if(3)
// 					contained_specimen_points += points_per_specimen_tier_3
// 				else
// 					if(isXenoQueen(X)) //Queen is Tier 0 for some reason...
// 						contained_specimen_points += points_per_specimen_tier_4
// 					else
// 						contained_specimen_points += points_per_specimen_tier_0


// 	for(var/mob/living/carbon/human/Y in GLOB.yautja_mob_list)
// 		if(Y.stat == DEAD) continue
// 		if(istype(get_area(Y),recovery_area))
// 			contained_specimen_points += points_per_specimen_tier_4

// /datum/cm_objective/contain/get_readable_progress()
// 	return "[get_point_value()]pts Contained"
