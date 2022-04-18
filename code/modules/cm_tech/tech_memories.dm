/datum/objective_memory_interface
	var/datum/techtree/holder

/datum/objective_memory_interface/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TechMemories", "[holder.name] Objectives")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/objective_memory_interface/proc/get_clues(mob/user)
	var/datum/objective_memory_storage/memories = user.mind.objective_memory
	var/list/clue_categories = list()


	// Progress reports
	var/list/clue_category = list()
	clue_category["name"] = "Reports"
	clue_category["icon"] = "scroll"
	clue_category["clues"] = list()
	for (var/datum/cm_objective/document/progress_report/report in memories.progress_reports)
		if (report.state == OBJECTIVE_ACTIVE)
			clue_category["clues"] += list(report.get_tgui_data())
	clue_categories += list(clue_category)


	// Folders
	clue_category = list()
	clue_category["name"] = "Folders"
	clue_category["icon"] = "folder"
	clue_category["clues"] = list()
	for (var/datum/cm_objective/document/folder/folder in memories.folders)
		if (folder.state == OBJECTIVE_ACTIVE)
			clue_category["clues"] += list(folder.get_tgui_data())
	clue_categories += list(clue_category)


	// Technical manuals
	clue_category = list()
	clue_category["name"] = "Manuals"
	clue_category["icon"] = "book"
	clue_category["clues"] = list()
	for (var/datum/cm_objective/document/technical_manual/manual in memories.technical_manuals)
		if (manual.state == OBJECTIVE_ACTIVE)
			clue_category["clues"] += list(manual.get_tgui_data())
	clue_categories += list(clue_category)


	// Data (disks + terminals)
	clue_category = list()
	clue_category["name"] = "Data"
	clue_category["icon"] = "save"
	clue_category["clues"] = list()
	for (var/datum/cm_objective/retrieve_data/disk/disk in memories.disks)
		if (disk.state == OBJECTIVE_ACTIVE)
			clue_category["clues"] += list(disk.get_tgui_data())
	for (var/datum/cm_objective/retrieve_data/terminal/terminal in memories.terminals)
		if (terminal.state == OBJECTIVE_ACTIVE)
			clue_category["clues"] += list(terminal.get_tgui_data())
	clue_categories += list(clue_category)


	// Retrieve items (devices + documents)
	clue_category = list()
	clue_category["name"] = "Retrieve"
	clue_category["icon"] = "box"
	clue_category["compact"] = TRUE
	clue_category["clues"] = list()
	for (var/datum/cm_objective/retrieve_item/objective in memories.retrieve_items)
		if (objective.state == OBJECTIVE_ACTIVE)
			clue_category["clues"] += list(objective.get_tgui_data())
	clue_categories += list(clue_category)


	// Other (safes)
	clue_category = list()
	clue_category["name"] = "Other"
	clue_category["icon"] = "ellipsis-h"
	clue_category["clues"] = list()
	for (var/datum/cm_objective/objective in memories.other)

		// Safes
		if(istype(objective, /datum/cm_objective/crack_safe))
			var/datum/cm_objective/crack_safe/safe = objective
			if (safe.state == OBJECTIVE_ACTIVE)
				clue_category["clues"] += list(safe.get_tgui_data())
			continue

	clue_categories += list(clue_category)

	return clue_categories

// Get our progression for each objective.
/datum/objective_memory_interface/proc/get_objectives(mob/user)
	var/list/objectives = list()

	// Documents (papers + reports + folders + manuals)
	var/list/objective = list()
	objective["label"] = "Documents"
	objective["content_credits"] = "([SSobjectives.statistics["documents_total_points_earned"]])"
	objective["content"] = "[SSobjectives.statistics["documents_completed"]] / [SSobjectives.statistics["documents_total_instances"]]"
	if (!SSobjectives.statistics["documents_completed"])
		objective["content_color"] = "red"
	else if (SSobjectives.statistics["documents_completed"] == SSobjectives.statistics["documents_total_instances"])
		objective["content_color"] = "green"
	else
		objective["content_color"] = "orange"
	objectives += list(objective)

	// Data (disks + terminals)
	objective = list()
	objective["label"] = "Upload data"
	objective["content_credits"] = "([SSobjectives.statistics["data_retrieval_total_points_earned"]])"
	objective["content"] = "[SSobjectives.statistics["data_retrieval_completed"]] / [SSobjectives.statistics["data_retrieval_total_instances"]]"
	if (!SSobjectives.statistics["data_retrieval_completed"])
		objective["content_color"] = "red"
	else if (SSobjectives.statistics["data_retrieval_completed"] == SSobjectives.statistics["data_retrieval_total_instances"])
		objective["content_color"] = "green"
	else
		objective["content_color"] = "orange"
	objectives += list(objective)

	// Chemicals
	objective = list()
	objective["label"] = "Analyze chemicals"
	objective["content_credits"] = "([SSobjectives.statistics["chemicals_total_points_earned"]])"
	objective["content"] = "[SSobjectives.statistics["chemicals_completed"]] / ∞"
	objectives += list(objective)

	// Miscellaneous (safes)
	objective = list()
	objective["label"] = "Miscellaneous"
	objective["content_credits"] = "([SSobjectives.statistics["miscellaneous_total_points_earned"]])"
	objective["content"] = "[SSobjectives.statistics["miscellaneous_completed"]] / [SSobjectives.statistics["miscellaneous_total_instances"]]"
	if (!SSobjectives.statistics["miscellaneous_completed"])
		objective["content_color"] = "red"
	else if (SSobjectives.statistics["miscellaneous_completed"] == SSobjectives.statistics["miscellaneous_total_instances"])
		objective["content_color"] = "green"
	else
		objective["content_color"] = "orange"
	objectives += list(objective)

	return objectives

/datum/objective_memory_interface/ui_data(mob/user)
	. = list()

	var/datum/techtree/tree = GET_TREE(TREE_MARINE)

	.["tech_points"] = holder.points
	.["total_tech_points"] = tree.total_points
	.["passive_tech_points"] = tree.resources_per_second * 60
	.["objectives"] = get_objectives(user)
	.["clue_categories"] = get_clues(user)

/datum/objective_memory_interface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	switch(action)
		if("enter_techtree")
			var/datum/techtree/tree = GET_TREE(TREE_MARINE)
			tree.enter_mob(usr, FALSE)

/datum/objective_memory_interface/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE
