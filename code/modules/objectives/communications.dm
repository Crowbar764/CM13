// --------------------------------------------
// *** Get communications up ***
// --------------------------------------------
/datum/cm_objective/communications
	name = "Restore Colony Communications"
	objective_flags = OBJ_DO_NOT_TREE
	display_flags = OBJ_DISPLAY_AT_END
	value = OBJECTIVE_EXTREME_VALUE
	controller = TREE_MARINE

/datum/cm_objective/communications/complete()
	ai_silent_announcement("SYSTEMS REPORT: Colony communications link online.", ":v")
	message_admins("comms online, state now [state]")
	state = OBJECTIVE_COMPLETE
	award_points()
