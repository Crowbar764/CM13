#define MINIMUM_POWER_OUTPUT 300000

// Parent objective for power-related objectives, tracks APCs and such
// Tracks APCs/SMESes here so we don't have to check every APC/SMES every time we want to score an objective
/datum/cm_objective/power
	name = "Something power-related"
	objective_flags = OBJ_DO_NOT_TREE
	display_flags = OBJ_DISPLAY_HIDDEN
	value = 0
	state = OBJECTIVE_ACTIVE
	var/list/power_objects
	var/uses_smes = FALSE
	var/uses_apc = FALSE
	var/total_apcs = 0 // For APC objectives
	var/total_points = 0 // Also for APC objectives

/datum/cm_objective/power/Destroy()
	power_objects = null
	..()

/datum/cm_objective/power/pre_round_start()
	if(uses_smes)
		for(var/obj/structure/machinery/power/smes/colony_smes in machines)
			if(!is_ground_level(colony_smes.loc.z))
				continue
			LAZYADD(power_objects, colony_smes)
			RegisterSignal(colony_smes, COMSIG_PARENT_QDELETING, .proc/remove_machine)
	if(uses_apc)
		for(var/obj/structure/machinery/power/apc/colony_apc in machines)
			if(!is_ground_level(colony_apc.z))
				continue
			total_apcs++
			LAZYADD(power_objects, colony_apc)
			RegisterSignal(colony_apc, COMSIG_PARENT_QDELETING, .proc/remove_machine)

// Used for objectives that track APCs
/datum/cm_objective/power/proc/check_apc_status()
	var/total_functioning = 0
	if(!uses_apc)
		return 0
	for(var/obj/structure/machinery/power/apc/colony_apc as anything in power_objects)
		if(colony_apc.stat & (BROKEN|MAINT))
			continue
		if(colony_apc.equipment < 2)
			continue
		total_functioning++
	return total_functioning

/datum/cm_objective/power/proc/remove_machine(obj/structure/machinery/power/machine)
	SIGNAL_HANDLER
	LAZYREMOVE(power_objects, machine)
	UnregisterSignal(machine, COMSIG_PARENT_QDELETING)

// --------------------------------------------
// *** Basic power up the colony objective ***
// --------------------------------------------

/datum/cm_objective/power/establish_power
	var/minimum_power_required = MINIMUM_POWER_OUTPUT
	var/last_power_output = 0 // for displaying progress
	objective_flags = OBJ_DO_NOT_TREE
	display_flags = OBJ_DISPLAY_AT_END | OBJ_DISPLAY_WHEN_COMPLETE
	value = OBJECTIVE_ABSOLUTE_VALUE
	controller = TREE_MARINE
	uses_smes = TRUE

/datum/cm_objective/power/establish_power/post_round_start()
	activate()

/datum/cm_objective/power/establish_power/get_readable_progress()
	if(!SSobjectives.first_drop_complete)
		return "Unable to remotely interface with powernet"
	return "[last_power_output]W, [minimum_power_required]W required"

/datum/cm_objective/power/establish_power/check_completion()
	if(!SSobjectives.first_drop_complete)
		return
	var/total_power_output = 0
	for(var/obj/structure/machinery/power/smes/colony_smes in power_objects)
		if(colony_smes.charge <= 0)
			continue
		if(!colony_smes.online)
			continue
		if(colony_smes.output <= 0)
			continue
		if(colony_smes.charging == 2 && colony_smes.chargelevel >= colony_smes.output)
			total_power_output += colony_smes.output
	last_power_output = total_power_output
	if(total_power_output >= minimum_power_required)
		complete()

/datum/cm_objective/power/establish_power/complete()
	award_points()
	state = OBJECTIVE_COMPLETE

// --------------------------------------------
// *** Restore the apcs to working order ***
// --------------------------------------------
/datum/cm_objective/power/repair_apcs
	name = "Repair APCs"
	objective_flags = OBJ_DO_NOT_TREE
	display_flags = OBJ_DISPLAY_AT_END | OBJ_DISPLAY_WHEN_COMPLETE
	value = OBJECTIVE_EXTREME_VALUE
	controller = TREE_MARINE
	uses_apc = TRUE
	var/score_interval = APC_SCORE_INTERVAL
	var/next_score_time = 0
	var/last_functioning = 0

// /datum/cm_objective/power/repair_apcs/on_marine_landing()
// 	..()
// 	next_score_time = world.time + score_interval
// 	ai_silent_announcement("Remote link established with colony powernet. Current status: [check_apc_status()]/[total_apcs] APCs online and recieving power.", ":v", TRUE)

/datum/cm_objective/power/repair_apcs/process(delta_time)
	. = ..()
	last_functioning = check_apc_status()
	if(!SSobjectives.first_drop_complete)
		return
	if(next_score_time > world.time)
		return
	next_score_time = world.time + score_interval
	total_points += value * (last_functioning / max(total_apcs, 1))

/datum/cm_objective/power/repair_apcs/check_completion()
	if(!SSobjectives.first_drop_complete)
		return
	last_functioning = check_apc_status()

// /datum/cm_objective/power/repair_apcs/get_completion_status()
// 	if(!SSobjectives.first_drop_complete)
// 		return "UNKNOWN/[total_apcs] APCs online, [get_point_value()]pts achieved"
// 	return "[last_functioning]/[total_apcs] APCs online, [get_point_value()]pts achieved"

// --------------------------------------------
// *** Disable APCs to disable the powernet ***
// --------------------------------------------
/datum/cm_objective/power/destroy_apcs
	name = "Disable APCs"
	objective_flags = OBJ_DO_NOT_TREE
	display_flags = OBJ_DISPLAY_AT_END | OBJ_DISPLAY_WHEN_COMPLETE
	value = OBJECTIVE_EXTREME_VALUE * 2
	controller = TREE_XENO
	uses_apc = TRUE
	var/score_interval = APC_SCORE_INTERVAL
	var/next_score_time = 0
	var/last_disabled = 0

/datum/cm_objective/power/destroy_apcs/process(delta_time)
	. = ..()
	last_disabled = total_apcs - check_apc_status()
	if(!SSobjectives.first_drop_complete)
		return
	if(next_score_time > world.time)
		return
	next_score_time = world.time + score_interval
	total_points += value * (last_disabled / max(total_apcs, 1))

// /datum/cm_objective/power/destroy_apcs/on_marine_landing()
// 	..()
// 	next_score_time = world.time + score_interval

// /datum/cm_objective/power/destroy_apcs/get_completion_status()
// 	return "[last_disabled]/[total_apcs] APCs disabled, [get_point_value()]pts achieved"
