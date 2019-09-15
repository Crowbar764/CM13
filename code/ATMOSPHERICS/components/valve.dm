/obj/structure/machinery/atmospherics/valve
	icon = 'icons/obj/pipes/valve.dmi'
	icon_state = "map_valve0"

	name = "manual valve"
	desc = "A pipe valve"

	level = 1
	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	var/open = 0
	var/openDuringInit = 0

	var/obj/structure/machinery/atmospherics/node1
	var/obj/structure/machinery/atmospherics/node2

	var/datum/pipe_network/network_node1
	var/datum/pipe_network/network_node2

/obj/structure/machinery/atmospherics/valve/open
	open = 1
	icon_state = "map_valve1"

/obj/structure/machinery/atmospherics/valve/update_icon(animation)
	if(animation)
		flick("valve[src.open][!src.open]",src)
	else
		icon_state = "valve[open]"

/obj/structure/machinery/atmospherics/valve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, get_dir(src, node1))
		add_underlay(T, node2, get_dir(src, node2))

/obj/structure/machinery/atmospherics/valve/hide(var/i)
	update_underlays()

/obj/structure/machinery/atmospherics/valve/New()
	switch(dir)
		if(NORTH || SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST
	..()

/obj/structure/machinery/atmospherics/valve/network_expand(datum/pipe_network/new_network, obj/structure/machinery/atmospherics/pipe/reference)
	if(reference == node1)
		network_node1 = new_network
		if(open)
			network_node2 = new_network
	else if(reference == node2)
		network_node2 = new_network
		if(open)
			network_node1 = new_network

	if(new_network.normal_members.Find(src))
		return 0

	new_network.normal_members += src

	if(open)
		if(reference == node1)
			if(node2)
				return node2.network_expand(new_network, src)
		else if(reference == node2)
			if(node1)
				return node1.network_expand(new_network, src)

	return null

/obj/structure/machinery/atmospherics/valve/Dispose()
	if(node1)
		node1.disconnect(src)
		del(network_node1)
	if(node2)
		node2.disconnect(src)
		del(network_node2)
	node1 = null
	node2 = null
	. = ..()

/obj/structure/machinery/atmospherics/valve/proc/open()
	if(open) return 0

	open = 1
	update_icon()

	if(network_node1&&network_node2)
		network_node1.merge(network_node2)
		network_node2 = network_node1

	return 1

/obj/structure/machinery/atmospherics/valve/proc/close()
	if(!open)
		return 0

	open = 0
	update_icon()

	if(network_node1)
		del(network_node1)
	if(network_node2)
		del(network_node2)

	build_network()

	return 1

/obj/structure/machinery/atmospherics/valve/proc/normalize_dir()
	if(dir==3)
		dir = 1
	else if(dir==12)
		dir = 4

/obj/structure/machinery/atmospherics/valve/attack_ai(mob/user as mob)
	return

/obj/structure/machinery/atmospherics/valve/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	update_icon(1)
	sleep(10)
	if (src.open)
		src.close()
	else
		src.open()

/obj/structure/machinery/atmospherics/valve/process()
	..()
	//. = PROCESS_KILL
	stop_processing()

	return

/obj/structure/machinery/atmospherics/valve/initialize()
	normalize_dir()

	var/node1_dir
	var/node2_dir

	for(var/direction in cardinal)
		if(direction&initialize_directions)
			if (!node1_dir)
				node1_dir = direction
			else if (!node2_dir)
				node2_dir = direction

	for(var/obj/structure/machinery/atmospherics/target in get_step(src,node1_dir))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node1 = target
				break
	for(var/obj/structure/machinery/atmospherics/target in get_step(src,node2_dir))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if (c)
				target.connected_to = c
				src.connected_to = c
				node2 = target
				break

	build_network()

	update_icon()
	update_underlays()

	if(openDuringInit)
		close()
		open()
		openDuringInit = 0

/obj/structure/machinery/atmospherics/valve/build_network()
	if(!network_node1 && node1)
		network_node1 = new /datum/pipe_network()
		network_node1.normal_members += src
		network_node1.build_network(node1, src)

	if(!network_node2 && node2)
		network_node2 = new /datum/pipe_network()
		network_node2.normal_members += src
		network_node2.build_network(node2, src)

/obj/structure/machinery/atmospherics/valve/return_network(obj/structure/machinery/atmospherics/reference)
	build_network()

	if(reference==node1)
		return network_node1

	if(reference==node2)
		return network_node2

	return null

/obj/structure/machinery/atmospherics/valve/reassign_network(datum/pipe_network/old_network, datum/pipe_network/new_network)
	if(network_node1 == old_network)
		network_node1 = new_network
	if(network_node2 == old_network)
		network_node2 = new_network

	return 1

/obj/structure/machinery/atmospherics/valve/return_network_air(datum/network/reference)
	return null

/obj/structure/machinery/atmospherics/valve/disconnect(obj/structure/machinery/atmospherics/reference)
	if(reference==node1)
		del(network_node1)
		node1 = null

	else if(reference==node2)
		del(network_node2)
		node2 = null

	update_underlays()
	start_processing()
	return null

/obj/structure/machinery/atmospherics/valve/digital		// can be controlled by AI
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon = 'icons/obj/pipes/digital_valve.dmi'

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

/obj/structure/machinery/atmospherics/valve/digital/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/machinery/atmospherics/valve/digital/attack_hand(mob/user as mob)
	if(!powered())
		return
	if(!src.allowed(user))
		to_chat(user, SPAN_DANGER("Access denied."))
		return
	..()

/obj/structure/machinery/atmospherics/valve/digital/open
	open = 1
	icon_state = "map_valve1"

/obj/structure/machinery/atmospherics/valve/digital/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/structure/machinery/atmospherics/valve/digital/update_icon()
	..()
	if(!powered())
		icon_state = "valve[open]nopower"

/obj/structure/machinery/atmospherics/valve/digital/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/structure/machinery/atmospherics/valve/digital/initialize()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/structure/machinery/atmospherics/valve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id))
		return 0

	switch(signal.data["command"])
		if("valve_open")
			if(!open)
				open()

		if("valve_close")
			if(open)
				close()

		if("valve_toggle")
			if(open)
				close()
			else
				open()

/obj/structure/machinery/atmospherics/valve/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(!iswrench(W))
		return ..()
	if(istype(src, /obj/structure/machinery/atmospherics/valve/digital))
		to_chat(user, SPAN_WARNING("You cannot unwrench [src], it's too complicated."))
		return 1

	playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
	user.visible_message(SPAN_NOTICE("[user] begins unfastening [src]."),
	SPAN_NOTICE("You begin unfastening [src]."))
	if(do_after(user, 40, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD))
		playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
		user.visible_message(SPAN_NOTICE("[user] unfastens [src]."),
		SPAN_NOTICE("You unfasten [src]."))
		new /obj/item/pipe(loc, make_from = src)
		qdel(src)
