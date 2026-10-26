



/turf/space
	icon_state = "space"
	updatecell = 1
	oxygen = 0
	oldoxy = 0
	oldpoison = 0
/turf/space/updatecell()
	return
/turf/space/Entered(A as mob|obj)
	..()
	if(z == 1)
		if(x == 1)
			if(2 >= world.maxz)
				world.maxz++
				A:z = 3
			else
				A:z = 3
			A:x = world.maxx - 1
			A:loc:Entered(A)
		else
			spawn(5)
				if(A && (!A:anchored && A:loc == src))
					step(A, WEST)
					if(prob(30)) step(A, pick(NORTH, SOUTH))
	else
		if(x == 1)
			if(z >= world.maxz)
				if(world.maxz < 10)
					world.maxz++
					A:z++
				else
					A:z = 8
			else
				A:z++
			A:x = world.maxx - 1
			A:loc:Entered(A)
		else if(x == world.maxx)
			if(A:z > 3)
				A:z--
			else
				A:z = 1
			A:x = 3
			A:loc:Entered(A)
		else
			spawn(5)
				if(A && (!A:anchored && A:loc == src))
					step(A, WEST)
					if(prob(30)) step(A, pick(NORTH, SOUTH))
/obj/computer
	anchored = 1
	anchored = 1


/obj/door/icon_state = "door1"
/obj/door/poddoor
	icon = 'Door1.dmi'
	var/id = 1
/obj/pod
	var/id = 1
/obj/door/poddoor/open()
	usr << "This is a remote pod door!"
/obj/door/poddoor/close()
	usr << "This is a remote pod door!"
/obj/door/poddoor/proc/openpod()
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
/obj/door/poddoor/proc/closepod()
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
	sleep(15)
	operating = 0

/obj/computer/meteorhit(obj/O)
	for(var/x in verbs)
		verbs -= x
	icon_state = "broken"
/obj/computer/card/icon_state = "id_computer"
/obj/computer/card/name = "Identification Computer"


/obj/computer/card
	var/in_computer
	var/operating = 0
/obj/computer/card/verb/eject()
	set src in oview(1)
	if(operating)
		usr << "\blue Failure: System already being accessed."
		return
	if(in_computer)
		in_computer:loc = loc
		in_computer = null

/obj/computer/card/attackby(obj/I, mob/user)
	if(!istype(I, /obj/item/weapon/card/id)) return
	if(operating)
		user << "\blue Failure: System already being accessed."
		return
	if(alert(user, "Would you like to insert your card for modification or scan it for authorization?", "ID system", "Insert", "Scan") == "Scan")
		if(I:assignment == "Captain" || I:assignment == "Head of Personell")
			if(in_computer)
				operating = 1
				if(in_computer) in_computer:registered = input(user, "Who will this card be registered to?", "ID system", in_computer:registered) as text
				if(in_computer) in_computer:access_level = input(user, "What will be their general access level? 1-5", "ID system", in_computer:access_level) as num
				if(in_computer) in_computer:lab_access = input(user, "What will be their lab access level? 1-5", "ID system", in_computer:lab_access) as num
				if(in_computer) in_computer:engine_access = input(user, "What will be their engineering access level? 1-5", "ID system", in_computer:engine_access) as num
				if(in_computer) in_computer:air_access = input(user, "What will be their systems access level? 1-5", "ID system", in_computer:air_access) as num
				if(in_computer) in_computer:assignment = input(user, "What will be their assignment", "ID system", in_computer:assignment) in list("Researcher's Assistant", "Engineer", "Research Technician", "Medical Doctor", "Captain", "Security Officer", "Medical Researcher", "Toxin Researcher", "Head of Research", "Head of Personell", "Station Technician", "Atmospheric Technician")
				if(in_computer) in_computer:name = "[in_computer:registered]'s ID Card ([in_computer:access_level]>[in_computer:lab_access]-[in_computer:engine_access]-[in_computer:air_access])"
				if(in_computer) in_computer:loc = loc
				if(in_computer) in_computer = null
				operating = 0
			else
				user << "\blue Failure: No card detected."
		else
			user << "\blue Failure: You are not authorized to do this."
	else
		if(!in_computer)
			I:loc = src
			in_computer = I
			user:unequip()
		else
			user << "\blue Failure: Card already detected."

/obj/computer/pod/icon_state = "computer"
/obj/computer/pod/name = "Pod Launch Control"
/obj/computer/pod
	var/id = 1
/obj/computer/card
	icon = 'stationobjs.dmi'
	density = 1
/obj/computer/pod/verb/Launch(number as num)
	set src in oview(1)
	number = min(max(number, 50), 600)
	world << "\red<B>Alert: Launching Escape Pod #[id] in [number] milliseconds!"
	sleep(number)
	var/obj/door/poddoor/poddoor
	var/obj/pod/escapepod
	var/zone = locate(/area/escapezone)
	for(poddoor in zone)
		if(poddoor:id == id)
			break
		else poddoor = null

	for(escapepod in zone)
		if(escapepod:id == id)
			break
		else escapepod = null

	if(!poddoor)
		view() << "\red<B>Door Failure!</B>"
		return
	if(!escapepod)
		view() << "\red<B>Launch delayed! No Escape Pod found!</B>"
		return
	view() << "\red<B>Opening Pod door [id]!</B>"

	poddoor:openpod()
	sleep(20)
	view() << "\red<B>Launching Escape Pod #[id]!</B>"
	escapepod:density = 1
	escapepod:speed = 5
	walk(escapepod, escapepod:dir, escapepod:speed)
	sleep(20)
	poddoor:closepod()


/obj/pod/Bump()
	..()
	speed = 0
/obj/pod/relaymove(mob/user, direction)
	if(user in src)
		if(direction & 1)
			speed = max(speed - 1, 1)
			walk(src, dir, speed)
		else if(direction & 2)
			speed++
			if(speed > 10)
				speed = 10
				walk(src, 0)
		if(direction & 4)
			walk(src, turn(dir, -90), speed)
		else if(direction & 8)
			walk(src, turn(dir, 90), speed)

/obj/computer/pod
	icon = 'escapepod.dmi'

	density = 1
/obj/pod
	var/speed = 10
	name = "Escape Pod"
	icon_state = "pod"
/obj/pod/verb/eject()
	set src = usr.loc
	if(usr.stat) return
	var/M = usr
	M:loc = loc
	if(M:client)
		M:client:eye = M:client:mob
		M:client:perspective = MOB_PERSPECTIVE

/obj/pod/verb/pickup(obj/O in src)
	set src = usr.loc
	if(!usr.stat) O:loc = usr
	else usr << "Your dead!"
/obj/pod/verb/board()
	set src in oview(1)
	if(usr.stat) return



	var/M = usr
	if(M:client)
		M:client:perspective = EYE_PERSPECTIVE
		M:client:eye = src
	M:loc = src
/obj/pod/verb/load()
	set src in oview(1)
	if(usr.pulling && !usr.pulling:anchored)
		usr.pulling:loc = loc
		view() << "\green<B> [usr] loads [usr.pulling] into [src]!</B>"
		usr.pulling = null
/obj/pod/verb/unload(A as mob|obj in src)
	set src in oview(1)
	if(istype(A, /atom/movable))
		A:loc = loc
		view() << "\green<B> [usr] unloads [A] from [src]!</B>"

/obj/pod
	icon = 'escapepod.dmi'
	dir = 8
	density = 1
	var/capacity
	anchored = 1
