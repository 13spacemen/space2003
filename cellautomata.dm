/atom/layer = 2
/atom/movable/Bump(A as mob|obj|turf|area)
	spawn(0) A:Bumped(src)
	..()
var/cellcontrol
/atom/proc/Bumped(AM as mob|obj)
/atom/movable
	var/anchored = 0
	var/weight = 0
var/ticker
var/plmaster
var/master_mode = "secret"
/turf/proc/updatecell()
/turf/proc/cachecell()
/world/name = "Space Station 13"
/world/hub = "Exadv1.spacestation13"
/world/New()
	..()
	sleep(50)
	plmaster = image(icon = 'plasma.dmi', icon_state = "onturf", layer = FLY_LAYER)
	cellcontrol = new /datum/control/cellular()
	cellcontrol:process()
	sleep(600)
	ticker = new /datum/control/gameticker()
	ticker:process()
/world/view = "15x15"
/datum/control
	var/processing = 1
/datum/control/proc/process()
/datum/control/gameticker
	var/timeleft
	var/killer
	var/shuttle_entered
	var/mode = "secret"
/datum/control/gameticker/proc/meteor_process()
	timeleft -= 10
	if(timeleft < 5400)
		spawn(0) new /obj/meteor(pick(block(locate(world.maxx, 1, 1), locate(world.maxx, world.maxy, 1))))
	if(timeleft <= 0) timeup()
	else spawn(10) if(processing) meteor_process()
/datum/control/gameticker/proc/traitor_process()
	timeleft -= 10
	if(timeleft < 4800)
		if(prob(1))
			spawn(0) new /obj/meteor(pick(block(locate(world.maxx, 1, 1), locate(world.maxx, world.maxy, 1))))
	if(timeleft <= 0) timeup()
	else spawn(10) if(processing) traitor_process()
/datum/control/gameticker/proc/extend_process()
	timeleft -= 10
	if(prob(2))
		spawn(0) new /obj/meteor(pick(block(locate(world.maxx, 1, 1), locate(world.maxx, world.maxy, 1))))
	if(timeleft <= 0) timeup()
	else spawn(10) if(processing) extend_process()
/datum/control/gameticker/process()
	label1
	world << "<B>Welcome to the Space Station 13!</B>"
	mode = master_mode
	switch(mode)
		if("secret")
			mode = pick("traitor", "meteor")
			world << "<B>The current game mode is - Secret!</B>"
			world << "<B>The game will pick between meteor attack and traitor mode</B>"
		if("traitor")
			world << "<B>The current game mode is - Traitor!</B>"
			world << "<B>There is a traitor among the researchers. You can't let him escape alone!&lt;/B>"
		if("extended")
			world << "<B>The current game mode is - Extended Role-Playing!</B>"
			world << "<B>Just have fun for 40 minutes and role-play!</B>"
		if("meteor")
			world << "<B>The current game mode is - Meteor!</B>"
			world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"
	world << "<B>Now dispensing all identification cards.</B>"
	var/jobs = list("Engineer", "Engineer", "Research Technician", "Medical Doctor", "Captain", "Security Officer", "Medical Researcher", "Toxin Researcher", "Toxin Researcher", "Head of Research", "Head of Personell", "Security Officer", "Station Technician", "Atmospheric Technician")
	var/mobs1 = list()
	for(var/mob/M in world)
		if(M:client) mobs1 += M
	if(!mobs1:len)
		sleep(600)
		goto label1
	while(mobs1:len > 0)
		var/mob/M = pick(mobs1)
		mobs1 -= M
		if(M:client)
			var/C = new /obj/item/weapon/card/id(M)
			C:registered = M:name
			if(!jobs)
				C:assignment = "Researcher's Assistant"
				C:access_level = 1
				C:lab_access = 1
				C:engine_access = 0
				C:air_access = 0
			else
				if(jobs:Find("Captain"))
					C:assignment = "Captain"
					world << "<B>[M] is your captain!</B>"
				else
					C:assignment = pick(jobs)
				jobs -= C:assignment
			switch(C:assignment)
				if("Engineer")
					C:access_level = 2
					C:lab_access = 1
					C:engine_access = 2
					C:air_access = 0
				if("Research Technician")
					C:access_level = 2
					C:lab_access = 3
					C:engine_access = 0
					C:air_access = 0
				if("Medical Doctor")
					C:access_level = 2
					C:lab_access = 0
					C:engine_access = 0
					C:air_access = 0
				if("Captain")
					C:access_level = 5
					C:air_access = 5
					C:engine_access = 5
					C:lab_access = 5
				if("Security Officer")
					C:access_level = 3
					C:lab_access = 0
					C:engine_access = 0
					C:air_access = 0
				if("Medical Researcher")
					C:access_level = 2
					C:lab_access = 5
					C:engine_access = 0
					C:air_access = 0
				if("Toxin Researcher")
					C:access_level = 2
					C:lab_access = 5
					C:engine_access = 0
					C:air_access = 0
				if("Head of Research")
					C:access_level = 4
					C:air_access = 2
					C:engine_access = 2
					C:lab_access = 5
				if("Head of Personell")
					C:access_level = 3
					C:air_access = 2
					C:engine_access = 2
					C:lab_access = 4
				if("Station Technician")
					C:access_level = 2
					C:lab_access = 0
					C:engine_access = 2
					C:air_access = 3
				if("Atmospheric Technician")
					C:access_level = 3
					C:lab_access = 0
					C:engine_access = 0
					C:air_access = 4
			C:name = "[C:registered]'s ID Card ([C:access_level]>[C:lab_access]-[C:engine_access]-[C:air_access])"
			M << "<B>You are the [C:assignment].</B>"
	switch(mode)
		if("traitor")
			world << "T-10:00 before emergency shuttle arrives!"
			var/mob/mobs = list()
			for(var/mob/M in world)
				if(M:client)
					mobs += M
			ticker:killer = pick(mobs)
			ticker:killer << "<B>You are the traitor.</B>"
			ticker:timeleft = 6000
			spawn(0) traitor_process()
		if("meteor")
			world << "T-10:00 before emergency shuttle arrives!"
			ticker:timeleft = 6000
			spawn(0) meteor_process()
		if("extended")
			world << "T-40:00 before the shuttle arrives!"
			ticker:timeleft = 24000
			spawn(0) extend_process()

/datum/control/gameticker/proc/timeup()
	if(!shuttle_entered)
		world << "<B>The emergency shuttle has entered the station! You have 3 minutes to enter the shuttle.</B>"
		var/A = locate(/area/shuttle)
		for(var/T as turf in A)
			if(T:z == 2)
				new T:type(locate(T:x, T:y, 1))
				for(var/atom/movable/AM in T)
					AM:z = 1
		timeleft = 1800
		shuttle_entered = 1
		switch(mode)
			if("traitor")
				spawn(0) traitor_process()
			if("meteor")
				spawn(0) meteor_process()
			else
				spawn(0) extend_process()
	else
		if(mode == "traitor")
			var/traitorwin = 1
			var/A = locate(/area/shuttle)
			for(var/mob/M in world)
				if(M != killer && M:client)
					if(!M:stat)
						var/T = M:loc
						if(!istype(T, /turf))
						else
							if(T in A)
								traitorwin = 0
			if(killer)
				var/T = killer:loc
				if(!istype(T, /turf)) traitorwin = 0
				else
					if(T in A)
						if(killer:stat)
							traitorwin = 0
					else traitorwin = 0
			if(traitorwin)
				world << "The traitor ([src.killer]) wins!"
			else
				world << "The Research Staff has stopped the traitor ([src.killer]) !"

			for(var/T as turf in A)
				if(T:z == 1)
					for(var/atom/movable/AM in T)
						AM:z = 2
					var/U = locate(T:x, T:y, 2)
					U:oxygen = T:oxygen
					U:poison = T:poison
					U:co2 = T:co2
					del(T)
			sleep(300)
			world.Reboot()
		else if(mode == "extended")
			var/L = list()
			var/A = locate(/area/shuttle)
			for(var/mob/M in world)
				if(M:client)
					if(!M:stat)
						var/T = M:loc
						if(T in A)
							L["[M]"] = "shuttle"
						else if(istype(T, /obj/pod))
							L["[M]"] = "pod"
						else
							L["[M]"] = "alive"
			if(L:len)
				world << "\blue<B>The game has ended!</B>"
				for(var/I in L)
					var/tem = L["[I]"]
					switch(tem)
						if("shuttle")
							world << "\t <B><FONT size = 2>[I] has left on the shuttle!</FONT></B>"
						if("pod")
							world << "\t <FONT size = 2>[I] has fled on an escape pod!</FONT>"
						if("alive")
							world << "\t <FONT size = 1>[I] decided to stay on the station.</FONT>"
			else
				world << "\blue<B>No one lived!</B>"
			for(var/T as turf in A)
				if(T:z == 1)
					for(var/atom/movable/AM in T)
						AM:z = 2
					var/U = locate(T:x, T:y, 2)
					U:oxygen = T:oxygen
					U:poison = T:poison
					U:co2 = T:co2
					del(T)
			sleep(300)
			world.Reboot()
		else
			var/L = list()
			var/A = locate(/area/shuttle)
			for(var/mob/M in world)
				if(M:client)
					if(!M:stat)
						var/T = M:loc
						if(T in A)
							L["[M]"] = "shuttle"
						else if(istype(T, /obj/pod))
							L["[M]"] = "pod"
						else
							L["[M]"] = "alive"
			if(L:len)
				world << "\blue<B>The following survived the meteor attack!</B>"
				for(var/I in L)
					var/tem = L["[I]"]
					switch(tem)
						if("shuttle")
							world << "\t <B><FONT size = 2>[I] made it to the shuttle!</FONT></B>"
						if("pod")
							world << "\t <FONT size = 2>[I] at least made it to an escape pod!</FONT>"
						if("alive")
							world << "\t <FONT size = 1>[I] at least is alive.</FONT>"
			else
				world << "\blue<B>No one survived the meteor attack!</B>"
			for(var/T as turf in A)
				if(T:z == 1)
					for(var/atom/movable/AM in T)
						AM:z = 2
					var/U = locate(T:x, T:y, 2)
					U:oxygen = T:oxygen
					U:poison = T:poison
					U:co2 = T:co2
					del(T)
			sleep(300)
			world.Reboot()
/datum/control/cellular
	var/checkfire = 0
	var/var_swap = 1
/datum/control/cellular/process()
	set background = 1
	for(var/turf/station/T in world)
		if(T:updatecell)
			spawn(0)
				sleep(-1)
				T:updatecell()
	var_swap = !var_swap
	sleep(-5)
	for(var/mob/M in world)
		spawn(0) M:Life()
	sleep(-5)
	if(processing) spawn(0) process()
/atom/movable/layer = 3
world
	turf = /turf/space




