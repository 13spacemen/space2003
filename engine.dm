/turf/station/engine
	icon = 'engine.dmi'
/turf/station/engine/floor
	icon_state = "floor"
	updatecell = 1
/turf/station/engine/injector
	icon_state = "injector"
	density = 1
	updatecell = 0
/area/engine
/area/decontamination
/area/medical
/area/airintake
/area/engine_access
/area/oxygen_storage
/area/testlab1
/turf/station/engine/injector/verb/inject()
	set src in oview(1)
	var/obj/item/weapon/tank/plasmatank/ptank
	for(ptank in usr) break
	if(!ptank) return
	var/T = get_step(src, get_dir(usr, src))
	ptank:gas:turf_add(T, -1)
	ptank:setsuffix(usr)
/turf/station/engine/igniter
	icon_state = "igniter"
	firelevel = 100
	updatecell = 1
/turf/station/engine/igniter/updatecell()
	..()
	if(firelevel < 100) firelevel = poison
/datum/engine_eject
	var/status = 0
	var/resetting
	var/timeleft
/area/testlab2
/datum/engine_eject/proc/ejectstart()
	if(!status)
		if(timeleft <= 0) timeleft = 60
		world << "\red<B>Alert: Ejection Sequence for Engine Module has been engaged.</B>"
		world << "\red<B>Ejection Time in T-[timeleft] seconds!</B>"
		resetting = 0
		var/engine = locate(/area/engine)
		engine:icon = 'alert.dmi'
		if(!engine:icon_state) engine:icon_state = "red"
		else engine:icon_state = "blue-red"
		status = 1
		for(var/obj/computer/engine/E in world)
			E:icon_state = "engaging"
		spawn(0) countdown()
/datum/engine_eject/proc/resetcount()
	if(!status)
		resetting = 1
	sleep(50)
	if(resetting)
		timeleft = 60
		world << "\red<B>Alert: Ejection Sequence Countdown for Engine Module has been reset.</B>"
/datum/engine_eject/proc/countdone()
	status = -1
	var/engine = locate(/area/engine)
	engine:icon = 'alert.dmi'
	engine:icon_state = null
	var/A = locate(/area/engine)
	for(var/T as turf in A)
		var/S = new T:type(locate(T:x, T:y, 8))
		for(var/atom/movable/AM in T)
			AM:loc = S
		S:oxygen = T:oxygen
		S:poison = T:poison
		A:contents += S
		var/P = new T:type(locate(T:x, T:y, T:z))
		var/D = locate(/area/dummy)
		D:contents += P
		del(T)
	world << "\red<B>Engine Ejected!</B>"
	for(var/obj/computer/engine/E in world)
		E:icon_state = "engaged"
/datum/engine_eject/proc/stopcount()
	if(status > 0)
		status = 0
		world << "\red<B>Alert: Ejection Sequence for Engine Module has been disengaged!</B>"
		var/engine = locate(/area/engine)
		engine:icon = 'alert.dmi'
		if(engine:icon_state == "blue-red") engine:icon_state = "blue"
		else engine:icon_state = null
		for(var/obj/computer/engine/E in world)
			E:icon_state = null
/datum/engine_eject/proc/countdown()
	if(timeleft <= 0)
		spawn(0) countdone()
		return
	if(status > 0)
		timeleft--
		if(timeleft < 15 || timeleft == 30)
			world << "\red<B>[timeleft] seconds until engine ejection.</B>"
		spawn(10) countdown()
/obj/computer/engine
	icon = 'enginecomputer.dmi'
	density = 1
/area/testlab3
/area/testlab4
/area/toolstorage
/obj/computer/engine/New()
	if(!engine_eject_control)
		engine_eject_control = new /datum/engine_eject()
	..()
/area/medicalstorage
/obj/computer/engine/verb/eject()
	set name = "Engine Eject Control"
	set desc = "Toggle Eject Status"
	set src in oview(1)
	if(usr.stat) return
	if(engine_eject_control:status == 0)
		if(alert("Eject Engine Module?", "Eject Confirm", "Confirm", "Deny") != "Confirm") return
		engine_eject_control:ejectstart()
	else if(engine_eject_control:status > 0)
		if(alert("Stop Ejection of Engine Module?", "Eject Confirm", "Confirm", "Deny") != "Confirm") return
		engine_eject_control:stopcount()
/obj/computer/engine/verb/resetcount()
	set src in oview(1)
	if(usr.stat) return
	engine_eject_control:resetcount()

/area/control_room
/area/controlaccess
/area/hallways
/area/hallways/loungehall
/area/hallways/eastairlock
/area/hallways/labaccess
/area/hallways/centralhall
/area/start
/area/supply_station
/area/training
/area/train
/area/train/area1
/area/train/area2
/area/train/area3
