

/turf/station/airtunnel
	var/activated = 1
/turf/station/airtunnel/floor
	icon_state = "floor"
	updatecell = 1
/turf/station/airtunnel/floor/activate()
	icon_state = "floor"
	name = "floor"
	oxygen = 1000
	activated = 1
/turf/station/airtunnel/wall
	icon_state = "wall"
	opacity = 1
	density = 1
	updatecell = 0
/turf/station/airtunnel/wall/activate()
	icon_state = "wall"
	name = "wall"
	density = 1
	opacity = 1
	updatecell = 0
	activated = 1
	oxygen = 100

/turf/station/airtunnel/proc/deactivate()
	updatecell = 1
	activated = 0
	icon_state = "space"
	name = "space"
	oxygen = 0
	poison = 0
	co2 = 0
	density = 0
	opacity = 0
/turf/station/airtunnel/proc/activate()
/turf/station/airtunnel/updatecell()
	if(activated)
		..()
	else return
/turf/station/airtunnel/Entered(A as mob|obj)
	if(activated)
		..()
	else
		spawn(3)
			if(A && A:loc == src)
				step(A, WEST)



/turf/station/airtunnel
	icon = 'airtunnel.dmi'
/obj/computer/airtunnel
	name = "Air Tunnel Alert"
	icon = 'airtunnel.dmi'
	icon_state = "console1"
	var/status = 1
/obj/computer/airtunnel/primary
	name = "Air Tunnel Controller"
	icon = 'airtunnelcomputer.dmi'
	density = 1
/obj/computer/airtunnel/primary/verb/toggletunnel()
	set src in oview(1)
	if(usr.stat) return
	status = !status
	if(status)
		for(var/turf/station/airtunnel/at in world)
			at:activate()
	else
		for(var/turf/station/airtunnel/at in world)
			at:deactivate()
	for(var/obj/computer/airtunnel/atc in world)
		atc:icon_state = "console[status]"
		atc:status = status
