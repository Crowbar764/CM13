// XENOMORPH TREE
// Default hive only for now
/datum/techtree/xenomorph
	name = TREE_XENO
	flags = TREE_FLAG_XENO

	var/hivenumber = XENO_HIVE_NORMAL
	var/heal_per_second = 5

	var/xeno_heal_amount = 30
	var/last_heal = 0

	var/bonus_wall_health = 100

	ui_theme = "hive_status"
	background_icon = "xeno_background"
	background_icon_locked = "xeno"

/datum/techtree/xenomorph/ui_state(mob/user)
	return GLOB.hive_state[hivenumber]

/datum/techtree/xenomorph/has_access(var/mob/M, var/access_required)
	if(!isXeno(M))
		return FALSE

	var/mob/living/carbon/Xenomorph/X = M

	if(X.hivenumber != hivenumber)
		return FALSE

	if(access_required == TREE_ACCESS_VIEW)
		return TRUE

	return isXenoQueenLeadingHive(X)


/datum/techtree/xenomorph/can_attack(var/mob/living/carbon/H)
	return !(H.hivenumber == hivenumber)

/datum/techtree/xenomorph/proc/remove_heal_overlay(var/mob/living/carbon/Xenomorph/X, var/image/I)
	X.overlays -= I

// /datum/techtree/xenomorph/on_process(var/obj/structure/resource_node/RN, delta_time)
// 	RN.take_damage(-heal_per_second * delta_time)

// 	if(last_heal > world.time)
// 		return

// 	var/area/A = RN.controlled_area
// 	if(!A)
// 		return

// 	for(var/mob/living/carbon/Xenomorph/X in A)
// 		if(!X.resting)
// 			continue

// 		if(X.health >= X.maxHealth)
// 			continue

// 		X.visible_message(SPAN_HELPFUL("\The [X] glows as a warm aura envelops them."), \
// 					SPAN_HELPFUL("You feel a warm aura envelop you."))

// 		X.flick_heal_overlay(2 SECONDS, "#00FF00")
// 		X.gain_health(xeno_heal_amount)
// 	last_heal = world.time + 3 SECONDS // Every 3 second

/datum/techtree/xenomorph/on_tier_change(datum/tier/oldtier)
	if(tier.tier < 2)
		return //No need to announce tier updates for tier 1
	xeno_message(SPAN_XENOANNOUNCE("The hive is growing and thriving! Tech nodes of tier [tier.tier] are now available!"), 3)
	var/datum/techtree/MT = GET_TREE(TREE_MARINE)
	MT.points_mult += (0.25 * oldtier.tier)
