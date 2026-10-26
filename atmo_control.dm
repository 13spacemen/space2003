
/obj/machinery/meter
	icon = 'pipes.dmi'
	icon_state = "meter"
	var/target
	anchored = 1
/obj/machinery/meter/New()
	..()
	target = locate(/obj/machinery/pipes) in loc
/obj/machinery/meter/Click()
	if(get_dist(usr, src) <= 3)
		if(target)
			usr << "\green<B> o2: [target:gas:oxygen]\n toxin: [target:gas:plasma]\n co2: [target:gas:co2]</B>"
		else
			usr << "\green<B>Results: Connection Error!</B>"
	else
		usr << "\green<B>You are too far away.</B>"



/obj/station/atmoalter
	density = 1
/obj/machinery/pipes/New()
	..()
	gas = new /obj/substance/gas(src)
	gas:maximum = capacity
/obj/machinery/pipes/anchored = 1

/obj/machinery/pipes
	icon = 'pipes.dmi'
	var/gas
	var/capacity = 30000
	var/node1
	var/node2
/obj/machinery/pipes/high_capacity/icon_state = "high_capacity"
/obj/machinery/pipes/proc/explode()
	gas:turf_add(loc, -1)
/obj/machinery/pipes/proc/receive_gas(obj/t_gas, obj/from)
	gas:merge_into(t_gas)

	if(gas:oxygen + gas:plasma + gas:co2 > gas:maximum)
		explode()
	spawn(2)
		if(from == node1)
			spawn(0) node2:receive_gas(gas, src)
			gas:clear()
		else
			spawn(0) node1:receive_gas(gas, src)
			gas:clear()
	return
/obj/station/atmoalter
	var/siphoning = 0
	var/manual = 0
	var/gas
	var/location
	var/maximum = 1000000
	anchored = 1
/obj/station/atmoalter/New()
	..()
	gas = new /obj/substance/gas(src)
	gas:maximum = maximum




/obj/station/atmoalter/DblClick()
	..()
	usr << "\blue Oxygen in tank:[gas:oxygen] Plasma in tank:[gas:plasma] Co2 in tank:[gas:co2]"

/obj/station/atmoalter/New()
	location = loc
	if(isturf(location))

		location:atmoalt = src
	..()
/obj/station/atmoalter/Del()
	if(isturf(src.location))
		location:atmoalt = null
	..()
/obj/station/atmoalter/proc/afterupdate()
	return 1
/obj/station/atmoalter/proc/releaseall()
	manual = 1
	siphoning = -1

/obj/station/atmoalter/proc/engage()
	siphoning = 1
	manual = 1
	icon_state = "siphon:[siphoning ? "1" : "0"]"
/obj/station/atmoalter/proc/disengage()
	siphoning = 0
	manual = 1
	icon_state = "siphon:[siphoning ? "1" : "0"]"


/obj/station/atmoalter/proc/release(amount, flag)
	var/T = loc
	if(!istype(T, /turf)) return
	if(!amount) return
	if(!flag) amount = min(amount, 10000)
	gas:turf_add(T, amount)

/obj/station/atmoalter/proc/siphon(amount)
	var/T = loc
	if(!istype(T, /turf)) return
	if(!amount) return
	gas:turf_take(T, amount)

/obj/station/atmoalter/verb/togglevalve()
	set src in oview(1)
	if(usr.stat) return
	var/position = alert("Please select a position.", "[src]", "Release", "Stop", "Siphon")
	switch(position)
		if("Release")
			siphoning = -1
			manual = 1
		if("Automatic")
			manual = 1
			siphoning = 0
		else
			siphoning = 1
			manual = 1
/obj/station/atmoalter/verb/toggleauto()
	set src in oview(1)
	if(usr.stat) return
	var/position = alert("Air Systems: On or Off?", "[src]", "On", "Off")
	siphoning = 0
	switch(position)
		if("On")
			manual = 0
		else
			manual = 1

/obj/station/atmoalter/fullairsiphon
	icon = 'turfs.dmi'
	icon_state = "siphon:0"
/obj/station/atmoalter/fullairsiphon/New()
	..()
	src.gas:oxygen = 1000
/obj/station/atmoalter/fullairsiphon/afterupdate()
	if(manual)
		if(siphoning > 0)
			siphon(9000)
		else if(siphoning < 0)
			release(10000)
	else
		var/T = loc
		if(!istype(T, /turf)) return
		if(1000 != T:oxygen)
			var/difference = 1000 - T:oxygen
			if(difference > 0)
				release(difference)
			else
				siphon(abs(difference))
/obj/station/atmoalter/fullairsiphon/air_vent
	icon = 'aircontrol.dmi'
	icon_state = "vent"
	density = 0
/obj/station/atmoalter/fullairsiphon/air_vent/New()
	verbs -= /obj/station/atmoalter/verb/togglevalve
	..()



/obj/station/atmoalter/scrubbers/air_filter
	icon = 'aircontrol.dmi'
	icon_state = "vent"
	density = 0
/obj/station/atmoalter/scrubbers/air_filter/New()
	verbs -= /obj/station/atmoalter/verb/togglevalve
	..()
/obj/station/atmoalter/scrubbers/afterupdate()
	if(manual)
		if(siphoning > 0)
			siphon(9000)
		else if(siphoning < 0)
			release(10000)
	else
		var/T = loc
		if(!istype(T, /turf)) return
		T:oxygen += gas:oxygen
		gas:oxygen = 0
		siphon(T:poison + T:co2)
		var/contain = T:poison + T:co2 + T:oxygen
		if(contain > 1000000)
			release(1000000 - contain, 1)

/obj/station/atmoalter/scrubbers
	icon = 'turfs2.dmi'
	icon_state = "siphon:0"
