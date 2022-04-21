// --------------------------------------------
// *** The core objective interface to allow generic handling of objectives ***
// --------------------------------------------
/datum/cm_objective
	var/name = "An objective to complete"
	var/state = OBJECTIVE_INACTIVE
	var/value = OBJECTIVE_NO_VALUE
	var/list/required_objectives //List of objectives that are required to complete this objectives
	var/list/enables_objectives //List of objectives that require this objective to complete
	var/prerequisites_required = PREREQUISITES_ONE
	var/objective_flags = NO_FLAGS // functionality related flags
	var/display_flags = NO_FLAGS // display related flags
	var/display_category // group objectives for round end display
	var/number_of_clues_to_generate = 1 //how many clues we generate for the objective(aka how many things will point to this objective)

	/// Controlling tree - this is the tree-faction we consider in control of the objective for purpose of objective dependencies
	var/controller = TREE_NONE
	/// Points awarded for the controlling factions so far if using default award behavior
	var/list/awarded_points

/datum/cm_objective/New()
	SSobjectives.add_objective(src)

/datum/cm_objective/Destroy()
	SSobjectives.remove_objective(src)
	for(var/datum/cm_objective/R as anything in required_objectives)
		LAZYREMOVE(R.enables_objectives, src)
	for(var/datum/cm_objective/E as anything in enables_objectives)
		LAZYREMOVE(E.required_objectives, src)
	required_objectives = null
	enables_objectives = null
	awarded_points = null
	return ..()

/datum/cm_objective/proc/Initialize() // initial setup after the map has loaded

/datum/cm_objective/proc/pre_round_start() // called by game mode just before the round starts

/datum/cm_objective/proc/post_round_start() // called by game mode on a short delay after round starts

/datum/cm_objective/proc/on_round_end() // called by game mode when round ends

/datum/cm_objective/proc/on_ground_evac() // called when queen launches dropship

/datum/cm_objective/proc/on_ship_boarding() // called when dropship crashes into almayer

/// True if the objective can be seen by the tech-faction, TREE_NONE meaning global view
/datum/cm_objective/proc/observable_by_faction(tree = TREE_NONE)
	// if(display_flags & OBJ_DISPLAY_UBIQUITOUS)
	// 	return TRUE
	// if(objective_flags & OBJ_CONTROL_EXCLUSIVE)
	// 	if(tree == controller)
	// 		return TRUE
	// 	if(tree == TREE_NONE)
	// 		return TRUE // Basically observer mode
	// 	if((objective_flags & OBJ_CONTROL_FLAG) && controller == TREE_NONE)
	// 		return TRUE // Go gettem
	// 	return FALSE
	return TRUE

/datum/cm_objective/proc/get_tgui_data()

/// Update awarded points to the controlling tech-faction
/datum/cm_objective/proc/award_points()
	var/datum/techtree/controlling_tree = GET_TREE(controller)
	if (!controlling_tree)
		return

	controlling_tree.add_points(value)

/datum/cm_objective/proc/get_readable_progress(tree = TREE_NONE)
	// if (complete)
	// 	return "<b>Completed!</b>"
	// else
	// 	return "<b>Not completed.</b>"

/datum/cm_objective/proc/get_clue() //TODO: change this to an formatted list like above -spookydonut
	return

/datum/cm_objective/proc/get_related_label()
	//For returning labels of related items (folders, discs, etc.)
	return

/datum/cm_objective/proc/complete()

/datum/cm_objective/proc/check_completion()

/datum/cm_objective/proc/activate()
	SSobjectives.start_processing_objective(src)

/datum/cm_objective/proc/is_prerequisites_completed()
	var/prereq_complete = 0
	for(var/datum/cm_objective/O in required_objectives)
		if(O.state == OBJECTIVE_COMPLETE)
			prereq_complete++
	switch(prerequisites_required)
		if(PREREQUISITES_NONE)
			return TRUE
		if(PREREQUISITES_ONE)
			if(prereq_complete || (LAZYLEN(required_objectives) == 0))
				return TRUE
		if(PREREQUISITES_QUARTER)
			if(prereq_complete >= (LAZYLEN(required_objectives) * 0.25)) // quarter or more
				return TRUE
		if(PREREQUISITES_MAJORITY)
			if(prereq_complete >= (LAZYLEN(required_objectives) * 0.5)) // half or more
				return TRUE
		if(PREREQUISITES_ALL)
			if(prereq_complete >= LAZYLEN(required_objectives))
				return TRUE
	return FALSE
