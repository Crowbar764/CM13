/datum/objective_memory_interface
	var/datum/techtree/holder

/datum/objective_memory_interface/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TechMemories", "[holder.name] Objectives")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/objective_memory_interface/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE

/datum/objective_memory_interface/ui_data(mob/user)
	// var/total_points = 0
	// holder
	// if(holder)
		// total_points = holder.points

	. = list()

	// . = list(
	// 	"total_points" = total_points,
	// 	"can_buy" = holder.can_use_points(required_points) && check_tier_level(),
	// 	"unlocked" = tech_flags & TECH_FLAG_MULTIUSE? FALSE: unlocked,
	// 	"cost" = required_points
	// )

/datum/objective_memory_interface/ui_static_data(mob/user)
	. = list(
		"theme" = holder.ui_theme,
		"name" = "I am a name",
		"desc" = "I am a desc",
	)

	.["testData"] = "Works!"

	// if(tech_flags & TECH_FLAG_MULTIUSE)
	// 	.["stats"] += list(list(
	// 		"content" = "Repurchasable",
	// 		"color" = "grey",
	// 		"icon" = "cart-plus",
	// 		"tooltip" = "Can be purchased multiple times."
	// 	))

/datum/objective_memory_interface/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	message_admins("Act")

	// switch(action)
	// 	if("purchase")
	// 		holder.purchase_node(usr, src)
	// 		. = TRUE
