var/datum/engine_eject/engine_eject_control
/mob
	var/equipped
/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return 1
		if("SOUTH")
			return 2
		if("EAST")
			return 4
		if("WEST")
			return 8
		if("NORTHEAST")
			return 5
		if("NORTHWEST")
			return 9
		if("SOUTHEAST")
			return 6
		if("SOUTHWEST")
			return 10



/obj/item/weapon/table_parts
	icon_state = "table_parts"
/obj/item/weapon/table_parts/verb/assemble()
	set src in usr
	var/state = input("What type of table?", "Assembling Table") in list("sides", "corners", "alone")
	var/direct = SOUTH
	if(state == "corners")
		direct = input("Direction?", "Assembling Table") in list("northwest", "northeast", "southwest", "southeast")
	else if(state == "sides")
		direct = input("Direction?", "Assembling Table") in list("north", "east", "south", "west")
	var/T = new /obj/table(usr.loc)
	T:icon_state = state
	T:dir = text2dir(direct)
	del(src)

/obj/item/weapon/rack_parts
	icon_state = "rack_parts"
/obj/item/weapon/rack_parts/verb/assemble()
	set src in usr
	new /obj/rack(usr.loc)
	del(src)
/obj/table
	icon = 'table.dmi'
	icon_state = "Table2"
	density = 1
	anchored = 1
/obj/table/attackby(W as obj, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(alert(user, "Would you like to dismantle the table or place [W] on it", "Attacking", "Dismantle", "Place") == "Dismantle")
			new /obj/item/weapon/table_parts(loc)
			del(src)
			return
	user:equipped = null
	W:setsuffix(user)
	W:loc = loc
/obj/table/meteorhit(obj/O)
	if(O:icon_state == "flaming")
		icon_state = "Table2broken"
		density = 0
/obj/rack
	icon = 'Icons.dmi'
	icon_state = "rack"
	density = 1
	anchored = 1
/obj/rack/attackby(W as obj, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(alert(user, "Would you like to dismantle the rack or place [W] on it", "Attacking", "Dismantle", "Place") == "Dismantle")
			new /obj/item/weapon/rack_parts(loc)
			del(src)
			return
	user:equipped = null
	W:setsuffix(user)
	W:loc = loc
/obj/rack/meteorhit(obj/O)
	if(O:icon_state == "flaming")
		icon_state = "rackbroken"
		density = 0

/mob/attackby(obj/W, mob/user)
	spawn(0) usr.equipped:attack(src, user)


/atom/proc/attack_to(mob/attacker, target as mob|obj|turf|area)
	return 1
/atom/proc/attack_from(mob/attacker, target as mob|obj|turf|area)
	return 1
/atom/proc/hitby(obj/W)
/atom/proc/attackby(obj/W, mob/user)
	view() << "\red<B>[src] has been hit by [user] with [usr.equipped]</B>"
/atom/DblClick()
	..()
	if(usr.stat == 0 && (get_dist(src, usr) <= 1 && isturf(usr.loc)) || usr.stat == 0 && (usr.contents:Find(src) && usr.equipped != src))










		for(var/atom/A in usr.loc)
			if(!A:attack_from(usr, loc))
				usr << "\red [A] blocked your attack!"
				return 0
		var/L
		if(istype(src, /turf))
			L = contents
		else L = loc:contents
		for(var/atom/A in L - src)
			if(!A:attack_to(usr, loc))
				usr << "\red [A] blocked your attack!"
				return 0
		if(usr.equipped)
			attackby(usr.equipped, usr)
			if(usr.equipped) usr.equipped:afterattack(src, usr)



/obj/weldfueltank
	icon = 'items.dmi'
	icon_state = "weldtank"
	density = 1
	weight = 50
/obj/water
	icon = 'water.dmi'
	icon_state = "extinguish"
	var/amount = 50
/obj/water/proc/Life()
	if(amount > 45)
		var/W = new /obj/water(loc)
		W:amount = amount - 1
		W:dir = dir
		spawn(0) W:Life()
	amount--
	if(amount <= 0)
		sleep(50)
		del(src)
	var/T = get_step(src, turn(dir, pick(90, 0, 0, -90)))
	if(T && T:density)
		dir = turn(dir, pick(-90, 90))
	else step_to(src, T)
	spawn(3) Life()


/obj/item/weapon
	icon = 'items.dmi'
	var/force
	var/damtype = "brute"
	var/throwforce
	var/throwspeed = 7
	var/throwing
	weight = 20
/obj/item/weapon/proc/throwing()
	if(throwspeed <= 1) throwing = 0
	step(src, dir)
	throwspeed--
	if(throwing)
		if(throwspeed < 10)
			sleep(10 - throwspeed)
		else sleep(1)
		spawn(0) throwing()
	else density = 0
/obj/item/weapon/verb/throw()
	set src in usr
	if(usr.stat) return
	loc = usr.loc
	view() << "\red [usr] has thrown [src]."
	src.density = 1
	src.throwing = 1
	dir = usr.dir
	src.throwspeed = initial(src.throwspeed)
	if(src == usr.equipped) usr.equipped = null
	setsuffix(usr)
	spawn(0) throwing()


/obj/item/weapon/card/id
	icon_state = "card-id"
	var/access_level
	var/lab_access
	var/engine_access
	var/air_access
	var/registered
	var/assignment
/obj/item/weapon/card/id/verb/show()
	set src in usr
	view(usr) << "[usr] shows you: \icon[src] [name]: assignment: [assignment]"
/obj/item/weapon/card/id/verb/read()
	set src in usr
	usr << "\icon[src] [name]: The current assignment on the card is [assignment]."
	usr << "\blue The rubric for the 4 access numbers is: general>lab-engine-air"
/obj/item/weapon/card/id/verb/wear()
	if(usr.canmove)
		if(usr.wear_suit) usr.wear_suit:suffix = null
		usr.wear_suit = src
		usr.wear_suit:suffix = "wearing"
	usr.UpdateClothing()
	..()
/obj/item/weapon/card/id/verb/remove()
	if(usr.canmove)
		usr.wear_suit:suffix = null
		usr.wear_suit = null
	usr.UpdateClothing()
	..()
/obj/item/weapon/card/id/attack(mob/target, mob/user)
	if(!target:canmove)
		if(target:wear_id) target:wear_id:suffix = null
		target:wear_id = src
		target:wear_id:suffix = "wearing"
		oview() << "\red<B>[user] puts [src] on [target].</B>"
		target:UpdateClothing()
		user:equipped = null
		loc = target
	else
		user << "\green you can't do that while [target] is conscious!"
/obj/item/weapon/rods
	icon_state = "rods"
	throwforce = 20
	throwspeed = 10
/obj/item/weapon/rods/verb/place()
	if(!istype(usr.loc, /turf/station)) return
	switch(alert("Metal rods", "Would you like to repair a grill or construct a new one?", "Repair", "Construct (2 sheets)"))
		if("Repair")
			if(!locate(/obj/grille) in usr.loc) return
			for(var/obj/grille/G in usr.loc)
				if(G:destroyed)
					G:health = 10
					G:density = 1
					G:destroyed = 0
					G:icon_state = "grille"
					break
			del(src)
		if("Construct (2 sheets)")
			var/total
			for(var/obj/item/weapon/sheet/metal/G in usr)
				total++
			if(total < 2)
				usr << "\blue You need more sheets!"
				return
			for(var/obj/item/weapon/sheet/metal/G in usr)
				if(G != src)
					del(G)
					break
			new /obj/grille(usr.loc)
			del(src)
/obj/item/weapon/sheet
	throwforce = 7
	throwspeed = 10
/obj/item/weapon/sheet/metal
	icon_state = "sheet-metal"
	throwforce = 14
/obj/item/weapon/sheet/metal/verb/mold()
	if(!istype(usr.loc, /turf/station))
		usr << "You must build over a floor tile even if you destroy it!."
		return
	switch(input("What would you like to build?", "Metal sheet") in list("metal rods (makes 2)", "stool", "chair (2)", "table parts (2)", "rack parts", "canister (2)", "closet (2)", "floor tiles (makes 4)", "repair wall", "construct wall"))
		if("metal rods (makes 2)")


			new /obj/item/weapon/rods(usr)
			new /obj/item/weapon/rods(usr)
			del(src)
		if("stool")
			new /obj/stool(usr.loc)
			del(src)
		if("chair")
			var/total
			for(var/obj/item/weapon/sheet/metal/G in usr)
				total++
			if(total < 2)
				usr << "\blue You need more sheets!"
				return
			for(var/obj/item/weapon/sheet/metal/G in usr)
				if(G != src)
					del(G)
					break
			new /obj/stool/chair(usr.loc)
			del(src)
		if("table parts (2)")
			var/total
			for(var/obj/item/weapon/sheet/metal/G in usr)
				total++
			if(total < 2)
				usr << "\blue You need more sheets!"
				return
			for(var/obj/item/weapon/sheet/metal/G in usr)
				if(G != src)
					del(G)
					break
			new /obj/item/weapon/table_parts(usr)
			del(src)
		if("rack parts")
			new /obj/item/weapon/rack_parts(usr)
			del(src)
		if("canister (2)")
			var/total
			for(var/obj/item/weapon/sheet/metal/G in usr)
				total++
			if(total < 2)
				usr << "\blue You need more sheets!"
				return
			for(var/obj/item/weapon/sheet/metal/G in usr)
				if(G != src)
					del(G)
					break
			var/ctype = alert("Poisen or Oxygen?", "Canister Creation", "Oxygen", "Poison")
			if(ctype == "Oxygen")
				var/C = new /obj/canister/oxygencanister(usr.loc)
				C:gas:oxygen = 0
			else
				var/C = new /obj/canister/poisoncanister(usr.loc)
				C:gas:plasma = 0
			del(src)
		if("closet (2)")
			var/total
			for(var/obj/item/weapon/sheet/metal/G in usr)
				total++
			if(total < 2)
				usr << "\blue You need more sheets!"
				return
			for(var/obj/item/weapon/sheet/metal/G in usr)
				if(G != src)
					del(G)
					break
			var/C = new /obj/emcloset(usr.loc)
			for(var/obj/item/I in C)
				del(I)
			del(src)
		if("floor tiles (makes 4)")
			new /obj/item/weapon/tile(usr)
			new /obj/item/weapon/tile(usr)
			new /obj/item/weapon/tile(usr)
			new /obj/item/weapon/tile(usr)
			del(src)
		if("construct wall")
			var/F = get_step(usr, usr.dir)
			if(!istype(F, /turf/station/floor))
				usr << "You can only construct over a floor!"
				return
			var/total
			for(var/obj/item/weapon/sheet/metal/G in usr)
				total++
			if(total < 2)
				usr << "\blue You need more sheets!"
				return
			for(var/obj/item/weapon/sheet/metal/G in usr)
				if(G != src)
					del(G)
					break
			var/W = new /turf/station/wall(locate(F:x, F:y, F:z))
			W:icon_state = "girder"
			W:updatecell = 1
			W:opacity = 0
			W:state = 1
			W:density = 1
			del(src)
		else
			var/W = get_step(usr, usr.dir)
			if(!istype(W, /turf/station/wall) || W:state != 1)
				usr << "You must be over wall girders!"
				return
			var/total
			for(var/obj/item/weapon/sheet/metal/G in usr)
				total++
			if(total < 2)
				usr << "\blue You need more sheets!"
				return
			for(var/obj/item/weapon/sheet/metal/G in usr)
				if(G != src)
					del(G)
					break
			W:icon_state = ""
			W:state = 2
			W:density = 1
			W:opacity = 1
			W:updatecell = 0
			del(src)

/obj/item/weapon/sheet/glass
	icon_state = "sheet-glass"
/obj/item/weapon/sheet/glass/verb/place()
	if(!istype(usr.loc, /turf/station)) return
	switch(alert("Sheet-Glass", "Would you like full tile glass or one direction?", "one direct", "full (2 sheets)"))
		if("one direct")
			var/W = new /obj/window(usr.loc)
			W:anchored = 0
			del(src)
		if("full (2 sheets)")
			var/total
			for(var/obj/item/weapon/sheet/glass/G in usr)
				total++
			if(total < 2)
				usr << "\blue You need more sheets!"
				return
			for(var/obj/item/weapon/sheet/glass/G in usr)
				if(G != src)
					del(G)
					break
			var/W = new /obj/window(usr.loc)
			W:dir = SOUTHWEST
			W:ini_dir = SOUTHWEST
			W:anchored = 0
			del(src)
/obj/item/weapon/wirecutters
	icon_state = "cutters"
	throwspeed = 9
/obj/item/weapon/extinguisher
	name = "Fire Extinguisher"
	var/waterleft = 20
	force = 17
/obj/item/weapon/extinguisher/icon_state = "fire_extinguisher"
/obj/item/weapon/extinguisher/setsuffix(mob/user)
	suffix = "[user:equipped == src ? "equipped " : ""][waterleft]"
/obj/item/weapon/extinguisher/Click()
	if(usr.stat) return
	if(usr.equipped == src)
		if(waterleft > 0)
			var/O = new /obj/water(usr.loc)
			O:dir = usr.dir
			spawn(0) O:Life()
			waterleft--
			setsuffix(usr)
		else usr << "It's empty!"
	else return ..()
/obj/item/weapon/extinguisher/verb/extinguish()
	if(usr.stat) return
	if(waterleft > 0)
		var/O = new /obj/water(usr.loc)
		O:dir = usr.dir
		spawn(0) O:Life()
		waterleft--
		setsuffix(usr)
	else usr << "It's empty!"
/obj/item/weapon/paper/icon_state = "paper"
/obj/item/weapon/paper
	name = "Paper"
	var/info
	throwspeed = 15
/obj/item/weapon/paper/New()
	..()
	pixel_y = rand(1, 16)
	pixel_x = rand(1, 16)
/obj/item/weapon/paper/Click()
	if(get_dist(src, usr) <= 2)
		usr << browse(info, "window=[name]")


/obj/item/weapon/paper/jobs
	name = "Job information"
	info = {"<HTML><HEAD></HEAD><BODY><PRE>
Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.
\tThe data will be in the following form.

Job Name   general access>lab access-engine access-systems access (atmosphere control)
\tJob Description
Job Duties (in no particular order)
Tips (where applicable)

Researcher's Assistant 1>1-0-0
\tThis is probably the lowest level position. Anyone who enters the space station after the initial job
assignment will automatically receive this position. Access with this is restricted. Head of Personell should
appropriate the correct level of assistance.
1. Assist the researchers.
2. Clean up the labs
3. Prepare materials

Engineer 2>1-2-0
\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13
work. They are one of the few classes that have unrestricted access to the engine area.
1. Upkeep the engine.
2. Prevent fires in the engine.
3. Maintain a safe orbit.

Research Technician 2>3-0-0
\tThis job is primarily a step up from researchers assistant. These people generally do not get their own lab
but are more hands on in the experimentation process. At this level they are permitted to work as consultants to
the others formally.
1. Inform superiors of research.
2. Perform research alongside of official researchers.

Medical Doctor 2>0-0-0
\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to
the medical bay for treatment and examination. Also they should make sure that medical supplies are kept in
order.
1. Heal wounded people.
2. Perform examinationbs of personell.
3. Moniter usage of medical equipment.

Captain 5>5-5-5 (unrestricted station wide access)
\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the
space station and therefor should protect their ID card. They also have the ability to assign positions
and access levels. They should not abuse their power.
1. Assign all positions on SS13
2. Inspect the station for any problems.
3. Perform administrative duties.

Security Officer 3>0-0-0
\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One
side duty is to assist in repairing the station. They also work like general maintenance personell. They are not
given a weapon and must use their own resources.
1. Maintain order.
2. Assist others.
3. Repair structural problems.

Medical Researcher 2>5-0-0
\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and
to conduct experiments that may help to improve the station. They will be generally idle until a new laboratory
is constructed.
1. Make sure the station is kept safe.
2. Research medical properties of materials studied of Space Station 13.

Toxin Researcher 2>5-0-0
\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.
Technically they can also be called Plasma Technicians as plasma is the material they routinly handle.
1. Research plasma
2. Make sure all plasma is properly handled.

Head of Research 4>5-2-2
\tPeople assigned as head of research should make sure all experiments are conducted efficiently. They should
also carefully moderate the usage of all equipment. All experiment results should be reported to this person.
1. Moderate equipment.
2. Process research results.
3. Coordinate all research.

Head of Personell 3>4-2-2
\tPeople assigned as head of personell will find themselves moderating all actions done by personell. Security
should report to them. Also they have the ability to assign jobs and access levels.
1. Assign duties.
2. Moderate personell.
3. Command Security.

Station Technician 2>0-2-3
\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.
They should primarily work in the computer lab and repairing faulty equipment. They should work with the
atmospheric technician.
1. Maintain SS13 systems.
2. Repair equipment.

Atmospheric Technician 3>0-0-4
\tThese people should primarily work in the atmospheric control center and lab. They have the very important
job of maintaining the delicate atmosphere on SS13.
1. Maintain atmosphere on SS13
2. Research atmospheres on the space station. (safely please!)
</PRE></BODY></HTML>"}
/obj/item/weapon/paper/sop
	name = "Standard Operating Procedure"
	info = {"<HTML><HEAD></HEAD><BODY><PRE>
Alert Levels:
Blue- Emergency
\t1. Caused by fire
\t2. Caused by manual interaction
\tAction:
\t\tClose all fire doors. These can only be opened
\t\t by reseting the alarm
Red- Ejection/Self Destruct
\t1. Caused by module operating computer.
\tAction:
\t\tAfter the specified time the module will eject completely.

Engine Maintenance Instructions:
\tShut off ignition systems:
\tActivate internal power
\tActivate orbital balance matrix
\tRemove volatile liquids from area
\tWear a fire suit

\tAfter
\t\tDecontaminate
\t\tVisit medical examiner

Toxin Laboratory Procedure:
\tWear a gas mask regardless
\tGet an oxygen tank.
\tActivate internal atmosphere

\tAfter
\t\tDecontaminate
\t\tVisit medical examiner

Disaster Procedure:
\tFire:
\t\tActivate sector fire alarm.
\t\tMove to a safe area.
\t\tGet a fire suit
\t\tAfter:
\t\t\tAssess Damage
\t\t\tRepair damages
\t\t\tIf needed, Evacuate
\tMeteor Shower:
\t\tActivate fire alarm
\t\tMove to the back of ship
\t\tAfter
\t\t\tRepair damage
\t\t\tIf needed, Evacuate
\tAccidental Reentry:
\t\tActivate fire alrms in front of ship.
\t\tMove volatile matter to a fire proof area!
\t\tGet a fire suit.
\t\tStay secure until an emergency ship arrives.

\t\tIf ship does not arrive-
\t\t\tEvacuate to a nearby safe area!
</PRE>
</BODY></HTML>"}
/obj/item/weapon/paper/Toxin
	name = "Chemical Information"
	info = {"<HTML><HEAD></HEAD><BODY><PRE>
Known Onboard Toxins:
\tGrade A Semi-Liquid Plasma:
\t\tHighly poisonous. You cannot sustain concentrations above 15 units.
\t\tA gas mask fails to filter plasma after 50 units.
\t\tWill attempt to diffuse like a gas.
\t\tFiltered by scrubbers.
\t\tThere is a bottled version which is very different
\t\t\tfrom the version found in canisters!

\t\tWARNING: Highly Flammable. Keep away from heat sources
\t\texcept in a enclosed fire area!
\t\tWARNING: It is a crime to use this without authorization.
Known Onboard Anti-Toxin:
\tAnti-Toxin Type 01P: Works against Grade A Plasma.
\t\tBest if injected directly into bloodstream.
\t\tA full injection is in every regular Med-Kit.
\t\tSpecial toxin Kits hold around 7.

Known Onboard Chemicals (other):
\tRejuvenation T#001:
\t\tEven 1 unit injected directly into the bloodstream
\t\t\twill cure paralysis and sleep toxins.
\t\tIf administered to a dying patient it will prevent
\t\t\tfurther damage for about units*3 seconds.
\t\t\tit will not cure them or allow them to be cured.
\t\tIt can be administeredd to a non-dying patient
\t\t\tbut the chemicals disappear just as fast.
\tSleep Toxin T#054:
\t\t5 units wilkl induce precisely 1 minute of sleep.
\t\t\tThe effects are cumulative.
\t\tWARNING: It is a crime to use this without authorization
</PRE>
</BODY></HTML>"}
/obj/item/weapon/paper/Internal
	name = "Internal Atmosphere Operating Instructions"
	info = {"<HTML><HEAD></HEAD><BODY><PRE>
Equipment:
\t1+ Tank(s) with appropriate atmosphere
\t1 Gas Mask w regulator (standard issue)

Procedure:
\t1. Wear mask
\t2. Attach oxygen tank pipe to regulater (automatic))
\t3. Set internal!

Notes:
\tDon't forget to stop internal when tank is low by
\tremoving internal!

\tDo not use a tank that has a high concentration of toxins.
\tThe filters shut down on internal mode!

\tWhen exiting a high danger environment it is advised
\tthat you exit through a decontamination zone!

\tRefill a tank at a oxygen canister by equiping the tank (Double Click)
\tthen 'attacking' the canister (Double Click the canister).
</PRE>
</BODY></HTML>"}
/obj/item/weapon/paper/Map
	name = "Station Blueprint"
	info = {"<HTML><HEAD></HEAD><BODY>
<PRE>
First Blueprint
Note: Alterations have been made since this was drafted!
 /==========EA
         SA+|
ENG     MS CR
      /---/
     /--D TL
     +----+
M T\\ |S   |
|----+| OS+
L AC-/\\-/A

L: Lounge
ENG: Engine Area
M: Medical Bay
T: Toxin Laboratory
AC: Air Control
A: Shuttle Airlock
OS: Oxygen Storage
S: Storage
D: Decontamination
TL: Test Lab
MS: Medical Storage
CR: Control Room
SA: Staging Area
EA: Engine Airlock
ENG: Engine
</PRE>
</BODY></HTML>
\t\t\t"}
/obj/item/weapon/healthanalyzer
	icon_state = "healthanalyzer"
/obj/item/weapon/healthanalyzer/name = "Health Analyzer"
/obj/item/weapon/healthanalyzer/attack(mob/M, mob/user)
	view() << "\red [user] has analyzed [M]'s vitals!"
	user << "\blue Analyzing Results for [M]:\n\t Overall Status: [M:stat > 1 ? "dead" : "[M:health]% healthy"]"
	user << "\blue\t Damage Specifics: [M:oxyloss]-[M:toxloss]-[M:fireloss]-[M:bruteloss]"
	user << "\blue Key: Suffocation/Toxin/Burns/Brute"
	if(M:rejuv) user << "\blue Bloodstream Analysis located [M:rejuv] units of rejuvenation chemicals."
	return
/obj/item/weapon/analyzer
	icon_state = "analyzer"
/obj/item/weapon/analyzer/Click()
	if(usr.stat) return
	if(src in usr)
		var/T = usr.loc
		if(!istype(T, /turf)) return
		usr << "\blue<B>Results:"
		usr << "\blue\t Oxygen: [T:oxygen] Toxins: [T:poison] co2: [T:co2]</B>"

/obj/item/weapon/analyzer/verb/use()
	set src in usr
	if(usr.stat) return
	var/T = usr.loc
	if(!istype(T, /turf)) return
	usr << "\blue<B>Results:"
	usr << "\blue\t Oxygen: [T:oxygen] Toxins: [T:poison] co2: [T:co2]</B>"
/obj/item/weapon/toolbox
	icon_state = "toolbox"
	force = 8
	throwspeed = 4
/obj/item/weapon/toolbox/New()
	new /obj/item/weapon/screwdriver(src)
	new /obj/item/weapon/wrench(src)
	new /obj/item/weapon/weldingtool(src)
	new /obj/item/weapon/radio(src)
	new /obj/item/weapon/analyzer(src)
	new /obj/item/weapon/extinguisher(src)
	new /obj/item/weapon/wirecutters(src)
/obj/item/weapon/toolbox/verb/remove(obj/O in contents)
	set src in view(1)
	if(usr.stat) return
	O:loc = usr
	view() << "\blue [usr] takes [O] from [src]!"








/obj/item/weapon/toolbox/attack(mob/M, mob/user)
	..()
	if(prob(30) && M:stat < 2)
		var/time = rand(10, 120)
		if(M:paralysis < time)
			M:paralysis = time
		M:stat = 1
		view() << "\red<B>[M] has been knocked unconscious!</B>"
		M << "\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>"
/obj/item/weapon/toolbox/attackby(obj/W, mob/user)
	user:equipped = null
	W:setsuffix(user)
	W:loc = src
	view() << "\blue [user] has added [W] to [src]!"
/obj/item/weapon/tile
	icon_state = "tile"
	throwspeed = 5
	force = 6
	throwforce = 7
/obj/item/weapon/tile/name = "steel floor tile"
/obj/item/weapon/tile/New()
	pixel_x = rand(1, 14)
	pixel_y = rand(1, 14)
/obj/item/weapon/tile/verb/repair()
	set src in usr
	if(usr.stat) return
	var/T = usr.loc
	if(!istype(T, /turf/station/floor))
		usr << "\blue This is a <I>floor</I> tile!"
		return
	else
		T:health = 100
		T:burnt = 0
		if(T:firelevel >= 100)
			T:icon_state = "burning"
		else
			T:icon_state = "Floor"
		del(src)
/obj/item/weapon/tile/verb/construct()
	set src in usr
	if(usr.stat) return
	var/S = get_step(usr, usr.dir)
	if(!istype(S, /turf/space))
		usr << "You may only build this over a space tile!"
	else
		var/W = new /turf/station/floor(locate(S:x, S:y, S:z))
		for(var/atom/movable/A in src)
			A:loc = W
		var/A = W:loc
		if(istype(A, /area))
			A:contents += W
		W:oxygen = 0
		del(src)
/obj/item/weapon/radio
	icon_state = "radio"
	var/freq = 3
	name = "Station Bounced Radio"
	suffix = "\[3\]"
/obj/item/weapon/radio/setsuffix(mob/user)
	suffix = "[user:equipped == src ? "equipped " : ""]\[[freq]\]"
/obj/item/weapon/radio/proc/send_crackle()
	return view(3, loc)
/obj/item/weapon/radio/proc/sendm(msg)
	return view(1, loc)

/obj/item/weapon/radio
	throwspeed = 9
/obj/item/weapon/radio/intercom
	icon_state = "intercom"
	density = 1
	anchored = 1
/obj/item/weapon/radio/intercom/name = "Station Intercom Radio"
/obj/item/weapon/radio/intercom/send_crackle()
	return list()
/obj/item/weapon/radio/intercom/sendm(msg)
	return view(7, loc)


/obj/item/weapon/radio/intercom/New()
	verbs -= /obj/item/verb/get
/obj/item/weapon/radio/intercom/set_freq()
	set src in view(1)
	..()
/obj/item/weapon/radio/verb/set_freq()
	set name = "Set Frequency"
	set src in usr
	if(usr.stat) return
	var/number = input("Frequency 0 broadcasts to all but receives only 0. 5 broadcasts through PA.You may only chose from between 0 and 5.", "Radio") as num

	number = min(max(number, 0), 5)
	freq = number

	setsuffix(usr)
/obj/item/weapon/radio/verb/send(msg as text)
	set src in view(1)
	if(usr.stat) return
	var/receive = list()
	var/crackle = list()
	for(var/obj/item/weapon/radio/R in world)
		if((freq == 0 || R:freq == freq) && freq != 5)
			for(var/mob/i in R:sendm(msg))
				receive -= i
				receive += i
			for(var/mob/i in R:send_crackle())
				crackle -= i
				crackle += i
	for(var/mob/i in receive)
		crackle -= i
	crackle << "\icon[src] <I>Crackle,Crackle</I>"
	receive << "<B>[usr]-\icon[src]\[[freq]\]-broadcasts: </B><I>[msg]</I>"




	if(freq == 5)
		world << "<B>[usr]-\icon[src]\[[freq]\]-broadcasts (over PA): </B><I>[msg]</I>"

/obj/item/weapon/shard
	icon = 'shards.dmi'
	icon_state = "large"
	force = 4
	damtype = "brute"
	throwforce = 10
/obj/item/weapon/shard/Bump()
	if(prob(20)) force = 15
	else force = 4
	..()
/obj/item/weapon/shard/New()
	icon_state = pick("large", "medium", "small")
	switch(icon_state)
		if("small")
			pixel_x = rand(1, 18)
			pixel_y = rand(1, 18)
		if("medium")
			pixel_x = rand(1, 16)
			pixel_y = rand(1, 16)
		if("large")
			pixel_x = rand(1, 10)
			pixel_y = rand(1, 5)
/obj/item/weapon/shard/attackby(obj/W, mob/user)
	..()
	if(!istype(W, /obj/item/weapon/weldingtool)) return
	new /obj/item/weapon/sheet/glass(user)
	del(src)
/obj/item/weapon/drop()
	if(usr.equipped == src)
		usr.equipped = null
		setsuffix(usr)
	..()
/obj/item/weapon/DblClick()
	if(src in usr)
		if(!usr.equipped)



			usr.equipped = src
			setsuffix(usr)
			usr << "\blue You have equipped [src]"
		else ..()
	else ..()
/obj/item/weapon/verb/unequip()
	set src in usr
	if(usr.equipped)
		var/oldequip = usr.equipped
		usr.equipped = null
		oldequip:setsuffix(usr)
		usr << "\blue You unequip [oldequip]."
	else usr << "\blue You don't have anything equipped!"
/obj/item/weapon/proc/setsuffix(mob/user)
	if(user:equipped == src)
		suffix = "equipped"
	else
		suffix = null
/obj/item/weapon/proc/afterattack()
	return
/obj/item/weapon/proc/attack(mob/M, mob/user)
	view(M) << "\red<B>[M] has been attacked with [src][user ? " by [user]." : "."] </B>"
	if(M:health >= -10)
		switch(damtype)
			if("brute")
				M:health -= force
				M:bruteloss += force
			if("toxin")
				M:health -= force
				M:toxloss += force
			if("fire")
				M:health -= force
				M:fireloss += force
/obj/item/weapon/Bump(mob/M)
	if(throwing)
		throwing = 0
		density = 0
		if(istype(M, /obj))
			var/O = M
			view(M) << "\red [M] has been hit by [src]."
			O:hitby(src)
		if(!istype(M, /mob)) return
		view(M) << "\red [M] has been hit by [src]."
		if(M:health > -10)
			M:health -= throwforce
			M:bruteloss += throwforce
/obj/item/weapon/wrench
	icon_state = "wrench"
	force = 5
	throwforce = 7
/obj/item/weapon/wrench/New()
	if(prob(75))
		pixel_x = rand(0, 16)
/obj/item/weapon/wrench/attack(mob/M, mob/user)
	..()
	if(prob(30) && M:stat < 2)
		var/time = rand(10, 120)
		if(M:paralysis < time)
			M:paralysis = time
		M:stat = 1
		view() << "\red<B>[M] has been knocked unconscious!</B>"
		M << "\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>"
/obj/item/weapon/screwdriver
	icon_state = "screwdriver"
	force = 5
	throwforce = 5
	throwspeed = 15
/obj/item/weapon/screwdriver/New()
	if(prob(75))
		pixel_y = rand(0, 16)
/obj/item/weapon/syringe
	icon_state = "syringe_0"
	var/capacity = 15
	var/toxin = 0
	var/antitoxin = 0
	var/rejuv = 0
	var/s_tox = 0
	throwspeed = 5
/obj/item/weapon/syringe/attackby(obj/B, mob/user)
	if(!istype(B, /obj/item/weapon/bottle)) return ..()
	if(B:toxin + B:antitoxin + B:rejuv + B:s_tox > 0)
		var/amount = capacity - (toxin + antitoxin + rejuv + s_tox)
		if(amount <= 0) return
		if(amount > 5) amount = 5







		var/t_t = B:toxin * amount / (B:toxin + B:antitoxin + B:rejuv + B:s_tox)
		var/t_a = B:antitoxin * amount / (B:toxin + B:antitoxin + B:rejuv + B:s_tox)
		var/t_r = B:rejuv * amount / (B:toxin + B:antitoxin + B:rejuv + B:s_tox)
		var/t_s = B:s_tox * amount / (B:toxin + B:antitoxin + B:rejuv + B:s_tox)
		toxin += t_t
		antitoxin += t_a
		rejuv += t_r
		s_tox += t_s
		B:toxin -= t_t
		B:antitoxin -= t_a
		B:rejuv -= t_r
		B:s_tox -= t_s
		icon_state = "syringe_[toxin + antitoxin + rejuv + s_tox]"
		user << "You draw [amount] units. The syringe contains [toxin + antitoxin + rejuv + s_tox] units."
/obj/item/weapon/syringe/attack(mob/M, mob/user)
	if(!ismob(M)) return
	if(user) view() << "\red [M] has been injected with [src] by [user]"
	if(toxin)
		M:health -= toxin * 4
		M:toxloss += toxin * 4
		toxin = 0
	if(antitoxin)
		sleep(6)
		if(M:health >= 0)
			if(antitoxin * 4 >= M:toxloss)
				M:health += M:toxloss
				M:toxloss = 0
				antitoxin = 0
			else
				M:health += antitoxin * 4
				M:toxloss -= antitoxin * 4
				antitoxin = 0
	if(s_tox)
		M:paralysis += s_tox * 12
		M:stat = 1
		s_tox = 0
	if(rejuv)
		M:rejuv += rejuv * 3
		if(M:paralysis)
			M:paralysis = 3
		rejuv = 0
	icon_state = "syringe_0"

/obj/item/weapon/firstaid
	name = "First-Aid"
	var/fireoint
	var/toxkit
	var/brutepack
	var/hanalyzer = 1
	throwspeed = 8
/obj/item/weapon/firstaid/verb/remove()
	set src in view(1)
	if(usr.stat) return
	var/L = list()
	if(fireoint) L += "Fire Ointment"
	if(toxkit) L += "Toxin Kit"
	if(brutepack) L += "Bruise Pack"
	if(hanalyzer) L += "Health Analyzer"
	var/choice = input("Remove what?", "First Aid") as null|anything in L
	if(!choice) return
	switch(choice)
		if("Fire Ointment")
			if(fireoint > 0)
				new /obj/item/weapon/ointment(usr)
				fireoint--
		if("Bruise Pack")
			if(brutepack > 0)
				new /obj/item/weapon/brutepack(usr)
				brutepack--
		if("Toxin Kit")
			if(toxkit > 0)
				var/S = new /obj/item/weapon/syringe(usr)
				S:antitoxin = S:capacity
				S:icon_state = "syringe_15"
				toxkit--
		if("Health Analyzer")
			if(hanalyzer)
				new /obj/item/weapon/healthanalyzer(usr)
				hanalyzer--
	usr << "You remove a [choice]"


/obj/item/weapon/firstaid/fire
	icon_state = "firstaid-ointment"
	fireoint = 10
/obj/item/weapon/firstaid/regular
	icon_state = "firstaid"
	brutepack = 10
	toxkit = 1
	fireoint = 2
/obj/item/weapon/firstaid/toxin
	icon_state = "firstaid-toxin"
	toxkit = 7
/obj/item/weapon/brutepack
	name = "Bruise Pack"
	icon_state = "brutepack"
	throwspeed = 20
/obj/item/weapon/brutepack/attack(mob/M, mob/user)
	if(M:health < 0) return
	if(user) view() << "\red [M] has been applied with [src] by [user]"
	if(60 >= M:bruteloss)
		M:health += M:bruteloss
		M:bruteloss = 0
	else
		M:health += 60
		M:bruteloss -= 60
	del(src)
/obj/item/weapon/ointment
	icon_state = "ointment"
	throwspeed = 20
/obj/item/weapon/ointment/attack(mob/M, mob/user)
	if(M:health < 0) return
	if(user) view() << "\red [M] has been applied with [src] by [user]"
	if(40 >= M:fireloss)
		M:health += M:fireloss
		M:fireloss = 0
	else
		M:health += 40
		M:fireloss -= 40
	del(src)
/obj/item/weapon/bottle
	var/capacity = 50
	var/toxin
	var/antitoxin
	var/rejuv
	var/s_tox
	throwspeed = 20
/obj/item/weapon/bottle/toxins
	icon_state = "toxinbottle"
	toxin = 50
/obj/item/weapon/bottle/antitoxins
	icon_state = "atoxinbottle"
	antitoxin = 50
/obj/item/weapon/bottle/rejuvenators
	icon_state = "rejuvbottle"
	rejuv = 50
/obj/item/weapon/bottle/s_tox
	name = "sleep toxins"
	icon_state = "toxinbottle"
	s_tox = 50
/obj/item/weapon/bottle/New()
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-8, 8)
/obj/item/weapon/weldingtool
	icon_state = "welder"
	var/welding = 0
	var/weldfuel = 20
	force = 3
	throwforce = 5
	throwspeed = 5
/obj/item/weapon/weldingtool/New()
	suffix = "[20]"
/obj/item/weapon/weldingtool/afterattack(mob/M, mob/user)
	if(welding)
		weldfuel--
		if(weldfuel <= 0)
			usr << "\blue Need more fuel!"
			welding = 0
			force = 3
			damtype = "brute"
			icon_state = "welder"

		setsuffix(user)
		var/location = user:loc
		if(!istype(location, /turf)) return
		location:firelevel = location:poison + 1
/obj/item/weapon/weldingtool/attack(mob/M, mob/user)
	..()
	if(prob(30) && (!welding && M:stat < 2))
		var/time = rand(10, 120)
		if(M:paralysis < time)
			M:paralysis = time
		M:stat = 1
		view() << "\red<B>[M] has been knocked unconscious!</B>"
		M << "\red<B>This was a [time * 100 / 120]% hit. Roleplay it! (personality/memory change if the hit was severe enough)</B>"
/obj/item/weapon/weldingtool/DblClick()
	..()

	setsuffix(usr)
/obj/item/weapon/weldingtool/setsuffix(mob/user) suffix = "[user:equipped == src ? "equipped " : ""][weldfuel]"

/obj/item/weapon/weldingtool/verb/refillfuel()
	set desc = "Use welding fuel from welding tank to refill."
	set src in usr
	if(usr.stat) return
	var/tloc = get_step(usr, usr.dir)
	var/tank = locate(/obj/weldfueltank) in tloc
	if(!tank) return
	else
		weldfuel = 20
		suffix = "[usr.equipped == src ? "equipped " : ""][weldfuel]"
		usr << "\blue Welder refueled"
/obj/item/weapon/weldingtool/verb/weld()
	set src in usr
	if(usr.stat) return
	welding = !welding
	if(welding)
		if(weldfuel <= 0)
			usr << "\blue Need more fuel!"
			welding = 0
			return 0
		usr << "\blue You will now weld when you attack."
		force = 15
		damtype = "fire"
		icon_state = "welder1"
	else
		usr << "\blue Not welding anymore."
		force = 3
		damtype = "brute"
		icon_state = "welder"

/obj/item/weapon/firstaid/fire/name = "Fire First Aid"
/obj/item/weapon/firstaid/toxin/name = "Toxin First Aid"
/mob

	var/wear_suit
	var/wear_mask
