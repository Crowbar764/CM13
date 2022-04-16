/datum/tech/repeatable/req_points
	name = "Requisition Budget Increase"
	icon_state = "budget_req"
	desc = "Distributes resources to requisitions for spending."

	announce_name = "ALMAYER SPECIAL ASSETS AUTHORIZED"
	announce_message = "Additional Supply Budget has been authorised for this operation."

	required_points = 15
	increase_per_purchase = 1

	flags = TREE_FLAG_MARINE
	tier = /datum/tier/one

	var/points_to_give = 7000

/datum/tech/repeatable/req_points/on_unlock()
	. = ..()
	supply_controller.points += points_to_give

/datum/tech/repeatable/dropship_points
	name = "Dropship Budget Increase"
	icon_state = "budget_ds"
	desc = "Distributes resources to the dropship fabricator."

	announce_name = "ALMAYER SPECIAL ASSETS AUTHORIZED"
	announce_message = "Additional Dropship Part Fabricator Points have been authorised for this operation."

	required_points = 15
	increase_per_purchase = 1

	flags = TREE_FLAG_MARINE
	tier = /datum/tier/one

	var/points_to_give = 1600

/datum/tech/repeatable/dropship_points/on_unlock()
	. = ..()
	supply_controller.dropship_points += points_to_give
