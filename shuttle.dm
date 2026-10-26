
/turf/station/shuttle
	icon = 'shuttle.dmi'
/obj/computer/shuttle
	icon = 'shuttle.dmi'
	icon_state = "shuttlecom"
	density = 1
	var/mob/authorized = list()
	var/auth_need = 3
/area/shuttle
/obj/computer/shuttle/verb/restabalize()
	set src in oview(1)
	world << "\red<B>Restabalizing shuttle atmosphere!</B>"
	var/A = locate(/area/shuttle)
	for(var/T as turf in A)
		T:oxygen = 1000
		T:poison = 0
		T:firelevel = 0
		T:co2 = 0
	world << "\red<B>Shuttle Restabalized!</B>"
/obj/computer/shuttle/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/card/id) || (!ticker || (!ticker:shuttle_entered || !user)))
		return
	if(W:access_level < 1)
		user << "The access level ([W:access_level]) of [W:registered] card is not high enough. (It must be at least level 1.)"
		return
	var/choice = alert(user, "Would you like to (un)authorize a shortened launch time? [auth_need - authorized:len] authorization\s are still needed. Use abort to cancel all authorizations.", "Shuttle Launch", "Authorize", "Repeal", "Abort")
	switch(choice)
		if("Authorize")
			authorized -= W:registered
			authorized += W:registered
			if(auth_need - authorized:len > 0)
				world << "\blue<B>Alert: [auth_need - authorized:len] authorizations needed until shuttle is launched early</B>"
			else
				world << "\blue<B>Alert: Shuttle launch time shortened to 10 seconds!</B>"
				ticker:timeleft = 10
				del(authorized)
		if("Repeal")
			authorized -= W:registered
			world << "\blue<B>Alert: [auth_need - authorized:len] authorizations needed until shuttle is launched early</B>"
		if("Abort")
			world << "\blue<B>All authorizations to shorting time for shuttle launch have been revoked!</B>"
			del(authorized)


/turf/station/shuttle/wall
	icon_state = "wall"
	opacity = 1
	density = 1
	updatecell = 0
/turf/station/shuttle/floor
	icon_state = "floor"
	updatecell = 1
/obj/shuttle/door
	icon = 'shuttle.dmi'
	icon_state = "door1"
	opacity = 1
	density = 1
	var/visible = 1
	var/operating
	anchored = 1
/obj/laser
	var/damage = 0
	var/range = 10
/obj/shuttle/door/New()
	..()
	var/T = loc
	if(istype(T, /turf))
		if(density) T:updatecell = 0
/obj/shuttle/door/Move(turf/NewLoc)
	. = ..()
	if(density)
		var/location = loc
		if(istype(location, /turf))
			location:updatecell = 0
/obj/shuttle/door/verb/open()
	set src in oview(1)
	if(operating) return
	operating = 1
	flick("doorc0", src)
	icon_state = "door0"
	sleep(15)
	density = 0
	opacity = 0
	var/T = loc
	if(istype(T, /turf))
		T:updatecell = 1
	verbs -= /obj/shuttle/door/verb/open
	verbs += /obj/shuttle/door/proc/close
	operating = 0
/obj/shuttle/door/proc/close()
	set src in oview(1)
	if(operating) return
	operating = 1
	flick("doorc1", src)
	icon_state = "door1"
	density = 1
	if(visible) opacity = 1
	var/T = loc
	if(istype(T, /turf))
		T:updatecell = 0
	sleep(15)
	verbs += /obj/shuttle/door/verb/open
	verbs -= /obj/shuttle/door/proc/close
	operating = 0
