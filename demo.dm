

/atom/proc/meteorhit(obj/meteor)
	return
/atom/proc/allow_drop() return 1


/area/New()
	..()
	icon = 'alert.dmi'
	layer = 10



/area
	layer = 1
	var/fire
/area/escapezone
/area/dummy
/area/aircontrol
/area/shuttle_airlock
/area/toxinlab
/area/proc/firealert()
	if(!fire)
		if(icon_state == "red" || icon_state == "blue-red") icon_state = "blue-red"
		else icon_state = "blue"
		fire = 1
		for(var/obj/door/firedoor/D in src)
			if(!D:density)
				spawn(0) D:closefire()
/atom/proc/CheckPass(O as mob|obj|turf|area)
	return !O:density || !src.density
/atom/proc/CheckExit()
	return 1

/turf/New()
	..()
	for(var/atom/movable/AM in src)
		spawn(0) Entered(AM)
/turf/Enter(O as mob|obj)
	if(density)
		spawn(0) if(O) O:Bump(src)
		return 0
	if(!isturf(O:loc)) return 1
	for(var/atom/A in O:loc)
		if(!A:CheckExit(O, src) && O != A)
			spawn(0) if(O) O:Bump(A)
			return 0
	for(var/atom/A in src)
		if(!A:CheckPass(O, src) && A != src)
			spawn(0) if(O) O:Bump(A)
			return 0
	return 1
/obj/meteor
	icon = 'meteor.dmi'
	var/steps
	var/life = 50
	var/hits = 3
/obj/meteor/New()
	..()
	sleep(1)
	step(src, WEST)
/obj/meteor/density = 1
/obj/meteor/anchored = 1

/obj/meteor/Move()
	if(steps < 7)
		steps++
		if(steps >= 7)
			icon_state = "flaming"
	else
		var/T = loc
		if(istype(T, /turf))
			T:firelevel = T:poison + 5
	..()
	if(--life <= 0) del(src)
	spawn(3)
		step(src, WEST)
		if(prob(30))
			step(src, pick(NORTH, SOUTH))

/obj/meteor/Bump(A as mob|obj|turf|area)
	if(A) A:meteorhit(src)
	if(--hits <= 0) del(src)


/obj/emcloset/meteorhit(obj/O)
	if(O:icon_state == "flaming")
		for(var/obj/item/I in src)
			I:loc = loc
		for(var/mob/M in src)
			M:loc = loc
			if(M:client)
				M:client:eye = M:client:mob
				M:client:perspective = MOB_PERSPECTIVE
		icon_state = "emcloset1"
		del(src)
/obj/stool/chair/icon_state = "chair"
/obj/emcloset
	name = "Emergency Closet"
	icon_state = "emcloset0"
	var/opened = 0
	var/welded
/obj/emcloset/attackby(obj/W, mob/user)
	if(W:damtype != "fire")
		user:equipped = null
		W:setsuffix(user)
		W:loc = loc
	else
		welded = !welded
		view(user) << "\red [src] has been [welded ? "welded shut" : "unwelded"] by [usr]."
/obj/emcloset/New()
	new /obj/item/weapon/tank/oxygentank(src)
	new /obj/item/weapon/clothing/mask/gasmask(src)
/obj/emcloset/relaymove(mob/user)
	if(!welded)
		for(var/obj/item/I in src)
			I:loc = loc
		for(var/mob/M in src)
			M:loc = loc
			if(M:client)
				M:client:eye = M:client:mob
				M:client:perspective = MOB_PERSPECTIVE
		icon_state = "emcloset1"
		opened = 1
	else
		user << "\blue It's welded shut!"
		for(var/mob/M in oview(src))
			M << "<FONT size=[max(0, 5 - get_dist(src, M))]>BANG, bang!</FONT>"

/obj/emcloset/verb/stuff()
	set src in oview(1)
	if(usr.pulling && !usr.pulling:anchored)
		usr.pulling:loc = loc
		view() << "\red [usr] stuffs [usr.pulling] into [src]!"
		usr.pulling = null
/obj/emcloset/verb/open()
	set src in oview(1)
	if(usr.stat) return
	if(!welded)
		for(var/obj/item/I in src)
			I:loc = loc
		for(var/mob/M in src)
			M:loc = loc
			if(M:client)
				M:client:eye = M:client:mob
				M:client:perspective = MOB_PERSPECTIVE
		icon_state = "emcloset1"
		opened = 1
	else
		usr << "\blue It's welded shut!"

/obj/emcloset/verb/close()
	set src in oview(1)
	if(usr.stat) return
	if(opened)
		for(var/obj/item/I in src.loc)
			I:loc = src
		for(var/mob/M in loc)
			if(M:client)
				M:client:perspective = EYE_PERSPECTIVE
				M:client:eye = src
			M:loc = src
		icon_state = "emcloset0"
		opened = 0
/obj/stool/chair/anchored = 1
/obj/emcloset
	icon = 'stationobjs.dmi'
	density = 1



/obj/stool/chair/New()
	verbs -= /atom/movable/verb/pull
	if(dir == NORTH)
		layer = FLY_LAYER
	..()

/obj/stool/chair/verb/rotate()
	dir = turn(dir, 90)
	if(dir == NORTH)
		layer = FLY_LAYER
	else layer = OBJ_LAYER
/obj/stool/chair/verb/buckle()
	set src in usr.loc
	if(!ismob(usr)) return
	if(usr.stat) return
	view() << "[usr] buckles in!"
	usr.anchored = 1
	usr.buckled = 1
	usr.loc = loc
/obj/stool/chair/verb/unbuckle()
	set src in view(1)
	if(!ismob(usr)) return
	if(usr.stat) return
	for(var/mob/M in loc)
		if(M:buckled)
			if(M != usr) view() << "[M] is unbuckled by [src]."
			else view() << "[M] is unbuckleas."
			M:anchored = 0
			M:buckled = 0
/obj/stool
	icon = 'Icons.dmi'
	icon_state = "stool"
/obj/item/weapon/clothing/verb/wear()
	usr.UpdateClothing()
/obj/item/weapon/clothing/verb/remove()
	usr.UpdateClothing()

/obj/item/weapon/clothing/suit/wear()
	if(usr.canmove)
		if(usr.wear_suit) usr.wear_suit:suffix = null
		usr.wear_suit = src
		usr.wear_suit:suffix = "wearing"
	..()
/obj/item/weapon/clothing/suit/remove()
	if(usr.canmove)
		usr.wear_suit:suffix = null
		usr.wear_suit = null
	..()

/obj/item/weapon/clothing/suit/firesuit
	icon_state = "firesuit"
/obj/item/weapon/clothing/suit/attack(mob/target, mob/user)
	if(!target:canmove)
		if(target:wear_suit) target:wear_suit:suffix = null
		target:wear_suit = src
		target:wear_suit:suffix = "wearing"
		target:UpdateClothing()
		user:equipped = null
		loc = target
		oview() << "\red<B>[user] puts a [src] on [target].</B>"
	else
		user << "\green you can't do that while [target] is conscious!"


/obj/item/weapon/clothing/mask/wear()
	if(usr.canmove)
		if(usr.wear_mask) usr.wear_mask:suffix = null
		usr.wear_mask = src
		usr.wear_mask:suffix = "wearing"
	..()
/obj/item/weapon/clothing/mask/remove()
	if(usr.canmove)
		usr.wear_mask:suffix = null
		usr.wear_mask = null
	..()
/obj/item/weapon/clothing/mask/gasmask
	icon = 'turfs2.dmi'
	icon_state = "mask"
/obj/item/weapon/clothing/mask/gasmask/drop()
	set src in usr
	if(usr.internal)
		usr.internal = null
	else
		..()
/obj/item/weapon/clothing/mask/attack(mob/target, mob/user)
	if(!target:canmove)
		if(target:wear_mask) target:wear_mask:suffix = null
		target:wear_mask = src
		target:wear_mask:suffix = "wearing"
		target:UpdateClothing()
		user:equipped = null
		loc = target
		oview() << "\red<B>[user] puts a [src] on [target].</B>"
	else
		user << "\green you can't do that while [target] is conscious!"
/obj/item/weapon/tank
	var/maximum
	var/gas
	icon = 'turfs2.dmi'
/obj/item/weapon/tank/attack(mob/M, mob/user)
	..()
	if(prob(60) && M:stat < 2)
		var/time = rand(10, 120)
		if(M:paralysis < time)
			M:paralysis = time
		M:stat = 1
		view() << "\red<B>[M] has been knocked unconscious!</B>"
		M << "\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>"
/obj/item/weapon/tank/New()
	..()
	gas = new /obj/substance/gas(src)
	gas:maximum = maximum
/obj/item/weapon/tank/Del()
	del(gas)
	return




/obj/item/weapon/tank/setsuffix(mob/user)
	if(user && user:equipped == src)
		suffix = "equipped \[[gas:plasma + gas:oxygen]\]"
	else suffix = "\[[gas:plasma + gas:oxygen]\]"
/obj/item/weapon/tank/drop()
	set src in usr
	if(usr.internal == src)
		usr.internal = null
	..()

/obj/item/weapon/tank/verb/setinternal()
	set src in usr
	if(usr.internal) return
	if(!usr.wear_mask) return
	usr.internal = src
	usr << "Now running on internals!"
/obj/item/weapon/tank/verb/removeinternal()
	set src in usr
	usr.internal = null
/obj/item/weapon/tank
	weight = 25
	force = 5
	throwforce = 10
/obj/item/weapon/tank/oxygentank/suffix = "100000"
/obj/item/weapon/tank/oxygentank/New()
	..()
	gas:oxygen = maximum
/obj/item/weapon/tank/oxygentank
	icon_state = "oxygen"
	maximum = 20000
/obj/item/weapon/tank/plasmatank/suffix = "75000"
/obj/item/weapon/tank/plasmatank/New()
	..()
	gas:plasma = maximum


/obj/item/verb/get()
	set src in oview(1)
	if(!usr.stat) loc = usr
	else usr << "Your dead!"
/obj/item/verb/drop()
	set src in usr
	if(!loc:allow_drop(src)) return
	if(usr.internal == src || usr.wear_mask == src) usr.internal = null
	loc = usr.loc
/obj/item/weapon/tank/plasmatank
	icon_state = "plasma"
	maximum = 10000
/obj/item/weapon/tank/throwspeed = 4
/obj/firealarm
	icon = 'items.dmi'
	icon_state = "firealarm"
	var/detecting = 1
	var/working = 1
	anchored = 1
/obj/firealarm/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wirecutters))
		detecting = !detecting
		if(detecting)
			view(user) << "\red [user] has reconnected [src]'s detecting unit!"
		else
			view(user) << "\red [user] has disconnected [src]'s detecting unit!"
	..()
/obj/firealarm/verb/reset()
	set src in oview(1)
	if(usr.stat) return
	if(!working) return
	var/A = loc
	A = A:loc
	if(!istype(A, /area)) return
	A:fire = 0
	if(A:icon_state == "blue-red") A:icon_state = "red"
	else A:icon_state = null
	for(var/obj/door/firedoor/D in A)
		if(D:density)
			spawn(0) D:openfire()
/obj/firealarm/verb/alarm()
	set src in oview(1)
	if(usr.stat) return
	if(!working) return
	var/A = loc
	A = A:loc
	if(!istype(A, /area)) return
	A:firealert()
/obj/firealarm/verb/timelock(timeto as num)
	set name = "Timer Lock"
	set desc = "Milliseconds please. Timelock: 0-600 milliseconds"
	set src in oview(1)
	if(usr.stat) return
	if(!working) return
	timeto = min(max(timeto, 0), 600)
	view(2) << "\blue Locking in [timeto] milliseconds!"
	sleep(timeto)
	var/A = loc
	A = A:loc
	if(!istype(A, /area)) return
	A:firealert()
/obj/door
	opacity = 1
	density = 1
	var/visible = 1
	var/r_air = 0
	var/r_engine = 0
	var/r_access = 0
	var/r_lab = 0
	anchored = 1
/obj/door/meteorhit(obj/M)
	open()
/obj/door/Move()
	..()
	if(density)
		var/location = loc
		if(istype(location, /turf))
			location:updatecell = 0
/obj/door/attackby(obj/I, mob/user)
	if(operating) return
	var/card = user:wear_id
	if(istype(I, /obj/item/weapon/card/id))
		card = I
	if(!istype(card, /obj/item/weapon/card/id))
		return 0
	if(card:air_access >= r_air && (card:lab_access >= r_lab && (card:engine_access >= r_engine && card:access_level >= r_access)))
		if(density) open()
		else close()
	else
		user << "\blue [card] does not have the sufficient access level."

/obj/door/window/close()
	..()
	var/T = loc
	if(T) T:updatecell = 1
/obj/door/window/New()
	..()
	var/T = loc
	if(T) T:updatecell = 1
	if(r_air || (r_engine || (r_access || r_lab)))
		icon = 'security.dmi'
/obj/door/window
	name = "interior door"
	icon = 'windoor.dmi'
	opacity = 0
	visible = 0
/obj/door/window/Bumped(AM as mob|obj)
	if(operating) return
	if(istype(AM, /mob))
		var/mob/M = AM
		var/card = M:wear_id
		if(istype(M:equipped, /obj/item/weapon/card/id))
			card = M:equipped
		if(istype(card, /obj/item/weapon/card/id)) attackby(M:equipped, M)
		else if(r_air == 0 && (r_engine == 0 && (r_lab == 0 && r_access == 0)))
			open()
			sleep(50)
			close()
		else M << "\blue You need an access card with the appropriate access level."
/obj/door/window/CheckPass(O as mob|obj, turf/target)
	if(density)
		var/mob/direct = get_dir(O, target)
		if(direct == NORTH && dir & 12)
			return 0
		else if(direct == WEST && dir == SOUTH) return 0
	return 1
/obj/door/window/CheckExit(O as mob|obj, turf/target)
	if(density)
		var/mob/direct = get_dir(O, target)
		if(direct == SOUTH && dir & 12)
			return 0
		else if(direct == EAST && dir == SOUTH) return 0
	return 1
/obj/door/window/attack_to(mob/attacker, target as mob|obj|turf|area)
	return CheckPass(attacker, target)
/obj/door/window/attack_from(mob/attacker, target as mob|obj|turf|area)
	return CheckExit(attacker, target)
/obj/door/airlock
	icon = 'Door1.dmi'
/obj/door/airlock/close()
	..()
	var/T = loc
	if(T) T:firelevel = 0
/obj/door/firedoor
	icon = 'Door1.dmi'
	icon_state = "door0"
	opacity = 0
	density = 0
/obj/door/firedoor/open()
	usr << "This is a remote firedoor!"
/obj/door/firedoor/close()
	usr << "This is a remote firedoor!"
/obj/door/firedoor/proc/openfire()
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
	operating = 0
/obj/door/firedoor/proc/closefire()
	set src in oview(1)
	if(operating) return
	operating = 1
	flick("doorc1", src)
	icon_state = "door1"
	density = 1
	opacity = 1
	var/T = loc
	if(istype(T, /turf))
		T:updatecell = 0
		T:firelevel = 0
	sleep(15)
	operating = 0





/obj/door
	icon = 'doors.dmi'
/obj/door/New()
	..()
	var/T = loc
	if(istype(T, /turf))
		if(density) T:updatecell = 0
/obj/door/proc/open()
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
	operating = 0
/obj/door/proc/close()
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
	operating = 0
/obj/grille
	icon = 'turfs2.dmi'
	icon_state = "grille"
	density = 1
	var/health = 10
	var/destroyed = 0
	anchored = 1
/obj/grille/meteorhit()
	if(icon_state == "flaming")
		health--
		healthcheck()
/obj/grille/CheckPass()
	return !density
/obj/grille/attackby(obj/W, mob/user)
	if(!destroyed)
		if(istype(W, /obj/item/weapon/wirecutters))
			health = 0
		else if(istype(W, /obj/item/weapon/screwdriver) && (istype(loc, /turf/station) || anchored))
			anchored = !anchored
			user << (anchored ? "You have fastened the grille to the floor." : "You have unfastened the grill.")
		else
			switch(W:damtype)
				if("fire")
					health -= W:force
				if("brute")
					health -= W:force * 0.05
		healthcheck()
		..()
/obj/grille/proc/healthcheck()
	if(health <= 0)
		icon_state = "brokengrille"
		density = 0
		destroyed = 1
		new /obj/item/weapon/rods(loc)
/obj/window
	icon = 'turfs2.dmi'
	icon_state = "window"
	density = 1
	var/health = 14
	weight = 25
	anchored = 1
/obj/window/CheckPass(O as mob|obj, turf/target)
	if(dir == SOUTHWEST) return 0
	else if(get_dir(target, O:loc) == dir) return 0
	return 1
/obj/window/CheckExit(O as mob|obj, turf/target)
	if(get_dir(O:loc, target) == dir) return 0
	return 1
/obj/window/meteorhit()
	health = 0
	for(var/index, index < rand(3, 6), index++)
		new /obj/item/weapon/shard(loc)
	del(src)
/obj/window/attack_to(mob/attacker, target as mob|obj|turf|area)
	return CheckPass(attacker, target)
/obj/window/attack_from(mob/attacker, target as mob|obj|turf|area)
	return CheckExit(attacker, target)
/obj/window/hitby(obj/W)
	..()
	health = max(0, health - W:throwforce)
	if(health <= 7)
		anchored = 0
		step(src, get_dir(W, src))
	if(health <= 0)
		for(var/index, index < rand(3, 6), index++)
			new /obj/item/weapon/shard(loc)
		del(src)
	..()
/obj/window/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver) && istype(loc, /turf/station))
		anchored = !anchored
		user << (anchored ? "You have fastened the window to the floor." : "You have unfastened the window.")
	else
		health = max(0, health - W:force)
		if(health <= 7)
			anchored = 0
			step(src, get_dir(user, src))
		if(health <= 0)
			if(dir == SOUTHWEST)
				for(var/index = 0, index < 2, index++)
					new /obj/item/weapon/shard(loc)
			else
				new /obj/item/weapon/shard(loc)
			del(src)
		..()

/obj/window/verb/rotate()
	set src in oview(1)
	if(anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0
	else if(dir == SOUTHWEST)
		usr << "You can't rotate this! "
		return 0
	dir = turn(dir, 90)
	ini_dir = dir
/obj/window{var/ini_dir}
/obj/window/New()
	..()
	ini_dir = dir
/obj/window/Move()
	..()
	dir = ini_dir
/obj/dispenser
	icon_state = "dispenser"
	name = "Tank Storage Unit"
	var/o2tanks = 10
	var/pltanks = 10
/turf/station/wall
	icon = 'wall.dmi'
	opacity = 1
	density = 1
	var/state = 2
	updatecell = 0
/turf/station/wall/attackby(obj/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && state == 1)
		var/T = user:loc
		user << "\blue Now dissembling the reinforced girders. Please stand still. This is a long process."
		sleep(100)
		if(user:loc == T && state == 1)
			state = 0
			var/F = new /turf/station/floor(locate(x, y, z))
			F:oxygen = 1000
			new /obj/item/weapon/sheet/metal(F)
			new /obj/item/weapon/sheet/metal(F)
	else if(istype(W, /obj/item/weapon/weldingtool) && state == 2)
		var/T = user:loc
		var/WT = W
		if(WT:weldfuel < 5)
			user << "\blue You need more welding fuel to complete this task."
		WT:weldfuel -= 5
		user << "\blue Now dissembling the outer wall plating. Please stand still."
		sleep(50)
		if(user:loc == T && state == 2)
			opacity = 0
			updatecell = 1
			state = 1
			new /obj/item/weapon/sheet/metal(src)
			new /obj/item/weapon/sheet/metal(src)
			icon_state = "girder"

/turf/station/wall/meteorhit(obj/M)
	if(M:icon_state == "flaming")
		icon_state = "girder"
		if(state == 2)
			state = 1
			opacity = 0
			updatecell = 1
			firelevel = 11
			new /obj/item/weapon/sheet/metal(src)
			new /obj/item/weapon/sheet/metal(src)
		else if(prob(20) && state == 1)
			state = 0
			var/F = new /turf/station/floor(locate(x, y, z))
			F:oxygen = 1000
			new /obj/item/weapon/sheet/metal(F)
			new /obj/item/weapon/sheet/metal(F)


/turf/station/alarm
	icon_state = "alarm:0"
	density = 1
	updatecell = 1
/turf/station/alarm/updatecell()
	..()
	icon_state = "alarm:[oxygen < 900 && co2 > 200 ? "1" : "0"]"
/turf/station/brokenwall
	icon_state = "brokenwall"
	updatecell = 1
/turf/station/brokenwall/proc/deleteme(turf/T)
	del(T)


/turf/station/floor
	icon_state = "Floor"
	var/health = 70
	var/burnt
/turf/station/floor/unburn()
	icon_state = "Floor[burnt ? "1" : ""]"
/turf/station/floor/updatecell()
	..()
	if(checkfire)
		if(firelevel >= 300)
			health--
		if(health <= 0)
			burnt = 1
			del(src)
		else if(health <= 35)
			burnt = 1





/turf/station/floor
	name = "floor"
	icon = 'Icons.dmi'
	updatecell = 1
/obj/dispenser/meteorhit()
	for(, o2tanks > 0, o2tanks--)
		new /obj/item/weapon/tank/oxygentank(loc)
	for(, pltanks > 0, pltanks--)
		new /obj/item/weapon/tank/plasmatank(loc)
	del(src)
/obj/dispenser/verb/dispense()
	set src in oview(1)
	if(usr.stat) return
	var/L = list()
	if(o2tanks) L += "Oxygen"
	if(pltanks) L += "Plasma"
	var/choice = input("Dispense what?", "Tank Storage Unit") as null|anything in L
	if(!choice) return
	switch(choice)
		if("Oxygen")
			if(o2tanks > 0)
				new /obj/item/weapon/tank/oxygentank(usr)
				o2tanks--
		if("Plasma")
			if(pltanks > 0)
				new /obj/item/weapon/tank/plasmatank(usr)
				pltanks--

/obj/dispenser

	icon = 'turfs2.dmi'
	density = 1


	anchored = 1
