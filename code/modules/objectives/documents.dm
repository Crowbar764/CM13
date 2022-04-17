// --------------------------------------------
// *** Find a document and read it ***
// These are intended as the initial breadcrumbs that lead to more objectives such as data retrieval
// --------------------------------------------
/datum/cm_objective/document
	name = "Document Clue"
	var/obj/item/document_objective/document
	var/area/initial_area
	var/static/completed_instances = 0
	var/static/total_instances = 0
	var/static/total_points_earned = 0
	value = OBJECTIVE_LOW_VALUE
	objective_flags = OBJ_PROCESS_ON_DEMAND
	display_flags = OBJ_DISPLAY_HIDDEN
	controller = TREE_MARINE
	prerequisites_required = PREREQUISITES_NONE
	display_category = "Documents"

/datum/cm_objective/document/New(var/obj/item/document_objective/D)
	. = ..()
	document = D
	initial_area = get_area(document)
	total_instances++

/datum/cm_objective/document/Destroy()
	document.objective = null
	document = null
	initial_area = null
	return ..()

/datum/cm_objective/document/get_related_label()
	return document.label

/datum/cm_objective/document/complete()
	. = ..()

	var/datum/techtree/tree = GET_TREE(controller)
	tree.add_points(value)
	total_points_earned += value

	for(var/datum/cm_objective/child_objective in enables_objectives)
		if(child_objective.state & OBJECTIVE_INACTIVE)
			child_objective.state = OBJECTIVE_ACTIVE

/datum/cm_objective/document/get_clue()
	return SPAN_DANGER("[document.name] in <u>[initial_area]</u>")

// Paper scrap
/datum/cm_objective/document/get_tgui_data()
	if(..())
		return
	var/list/clue = list()

	clue["text"] = "Paper scrap"
	clue["location"] = initial_area.name

	return clue

// Folder
/datum/cm_objective/document/folder
	value = OBJECTIVE_MEDIUM_VALUE
	prerequisites_required = PREREQUISITES_ONE
	display_flags = 0
	var/color // Text name of the color
	var/display_color // Color of the sprite
	number_of_clues_to_generate = 2

/datum/cm_objective/document/folder/get_tgui_data()
	if(..())
		return
	var/list/clue = list()

	clue["text"] = "folder"
	clue["itemID"] = document.label
	clue["color"] = color
	clue["color_name"] = display_color
	clue["location"] = initial_area.name

	return clue

/datum/cm_objective/document/folder/get_clue()
	return SPAN_DANGER("A <font color=[display_color]><u>[color]</u></font> folder <b>[document.label]</b> in <u>[initial_area]</u>.")

// Progress report
/datum/cm_objective/document/progress_report
	value = OBJECTIVE_MEDIUM_VALUE
	prerequisites_required = PREREQUISITES_NONE
	display_flags = 0

/datum/cm_objective/document/progress_report/get_tgui_data()
	if(..())
		return
	var/list/clue = list()

	clue["text"] = "Progress report"
	clue["location"] = initial_area.name

	return clue

// Technical manual
/datum/cm_objective/document/technical_manual
	value = OBJECTIVE_HIGH_VALUE
	prerequisites_required = PREREQUISITES_NONE
	display_flags = 0

/datum/cm_objective/document/technical_manual/get_tgui_data()
	if(..())
		return
	var/list/clue = list()

	clue["text"] = "Technical manual"
	clue["itemID"] = document.label
	clue["location"] = initial_area.name

	return clue

// --------------------------------------------
// *** Mapping objects ***
// --------------------------------------------

/obj/item/document_objective
	var/datum/cm_objective/document/objective
	var/reading_time = 10
	var/objective_type = /datum/cm_objective/document
	unacidable = TRUE
	indestructible = 1
	var/label // label on the document
	var/renamed = FALSE //Once someone reads a document the item gets renamed based on the objective they are linked to)

/obj/item/document_objective/Initialize(mapload, ...)
	. = ..()
	label = "[pick(alphabet_uppercase)][rand(100,999)]"
	objective = new objective_type(src)
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)

/obj/item/document_objective/Destroy()
	objective.document = null
	objective = null
	return ..()

/obj/item/document_objective/proc/display_read_message(mob/living/user)
	if(user && user.mind)
		user.mind.store_objective(objective)
	var/related_labels = ""
	for(var/datum/cm_objective/D in objective.enables_objectives)
		to_chat(user, SPAN_NOTICE("You make out something about [D.get_clue()]."))
		if (related_labels != "")
			related_labels+=","
		related_labels+=D.get_related_label()
	to_chat(user, SPAN_INFO("You finish reading \the [src]."))

	// Our first time reading this successfully, add the clue labels.
	if(!(objective.state & OBJECTIVE_COMPLETE))
		src.name+= " ([related_labels])"
		renamed = TRUE

/obj/item/document_objective/attack_self(mob/living/carbon/human/user)
	. = ..()

	to_chat(user, SPAN_NOTICE("You start reading \the [src]."))

	if(!do_after(user, reading_time * user.get_skill_duration_multiplier(SKILL_INTEL), INTERRUPT_INCAPACITATED|INTERRUPT_NEEDHAND, BUSY_ICON_GENERIC)) // Can move while reading intel
		to_chat(user, SPAN_WARNING("You get distracted and lose your train of thought, you'll have to start over reading this."))
		return

	// Prerequisit objective not complete.
	if(objective.state & OBJECTIVE_INACTIVE)
		to_chat(user, SPAN_NOTICE("You don't notice anything useful. You probably need to find its instructions on a paper scrap."))
		return

	display_read_message(user)

	// Our first time reading this successfully.
	if(!(objective.state & OBJECTIVE_COMPLETE))
		objective.complete()
		objective.completed_instances++
		objective.state = OBJECTIVE_COMPLETE

	to_chat(user, SPAN_NOTICE("STATIC: [objective.completed_instances] / [objective.total_instances]"))

/obj/item/document_objective/paper
	name = "Paper scrap"
	desc = "A scrap of paper, you think some of the words might still be readable."
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "paper_words"
	w_class = SIZE_TINY

/obj/item/document_objective/paper/Initialize(mapload, ...)
	. = ..()
	objective.state = OBJECTIVE_ACTIVE

/obj/item/document_objective/report
	name = "Progress report"
	desc = "A written report from someone for their supervisor about the status of some kind of project."
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "paper_p_words"
	w_class = SIZE_TINY
	reading_time = 60
	objective_type = /datum/cm_objective/document/progress_report

/obj/item/document_objective/report/Initialize(mapload, ...)
	. = ..()
	objective.state = OBJECTIVE_ACTIVE

/obj/item/document_objective/folder
	name = "intel folder"
	desc = "A folder with some documents inside."
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "folder"
	var/folder_color = "white" //display color
	reading_time = 40
	objective_type = /datum/cm_objective/document/folder
	w_class = SIZE_TINY

/obj/item/document_objective/folder/Initialize(mapload, ...)
	. = ..()
	var/datum/cm_objective/document/folder/F = objective
	var/col = pick("Red", "Black", "Blue", "Yellow", "White")
	switch(col)
		if ("Red")
			folder_color = "#ed5353"
		if ("Black")
			folder_color = "#8f9494" //can't display black on black!
		if ("Blue")
			folder_color = "#5296e3"
		if ("Yellow")
			folder_color = "#e3cd52"
		if ("White")
			folder_color = "#e8eded"
	icon_state = "folder_[lowertext(col)]"
	F.color = col
	F.display_color = folder_color
	name = "[initial(name)] ([label])"

/obj/item/document_objective/folder/examine(mob/living/user)
	..()
	if(get_dist(user, src) < 2 && ishuman(user))
		to_chat(user, SPAN_INFO("\The [src] is labelled [label]."))

/obj/item/document_objective/technical_manual
	name = "Technical Manual"
	desc = "A highly specified technical manual, may be of use to someone in the relevant field."
	icon = 'icons/obj/items/books.dmi'
	icon_state = "book"
	reading_time = 200
	objective_type = /datum/cm_objective/document/technical_manual

/obj/item/document_objective/technical_manual/Initialize(mapload, ...)
	. = ..()
	name = "[initial(name)] ([label])"
