/obj/canister
	density = 1
	var/maximum = 100000
	var/gas
	var/health = 20
	var/destroyed
	weight = 50
/obj/canister/New()
	..()
	gas = new /obj/substance/gas(src)
	gas:maximum = maximum

/obj/canister
	icon = 'turfs2.dmi'
/obj/canister/proc/setdestroystate()
/obj/canister/examine()
	usr << "\blue Oxygen in tank:[gas:oxygen] Plasma in tank:[gas:plasma] Co2 in tank:[gas:co2]"
	usr << "This can store tremendously large amounts of gases at any temperature."
/obj/canister/meteorhit(obj/O)
	health = 0
	healthcheck()

/obj/canister/attackby(obj/W, mob/user)
	if(!istype(W, /obj/item/weapon/tank))
		switch(W:damtype)
			if("fire")
				health -= W:force
			if("brute")
				health -= W:force * 0.5
		healthcheck()
		..()
	else
		var/T = W
		T:gas:transfer_to(gas, -1)
/obj/canister/proc/healthcheck()
	if(health <= 10)
		var/T = loc
		if(!istype(T, /turf)) return
		gas:turf_add(T, -1)
		destroyed = 1
		density = 0
		setdestroystate()

/obj/canister/proc/refill_tank(obj/O)
	if(!istype(O, /obj/item/weapon/tank)) return
	if(destroyed)
		var/T = loc
		if(!istype(T, /turf)) return
		O:gas:turf_add(T, -1)
		O:setsuffix(usr)
		return
	var/amount = gas:maximum - (gas:oxygen + gas:co2 + gas:plasma)
	if(O:gas:co2 + O:gas:plasma + O:gas:oxygen < amount)
		amount = O:gas:co2 + O:gas:plasma + O:gas:oxygen
	gas:transfer_to(O:gas, amount)

/obj/canister/verb/release(number as num)
	set name = "Release:Amount"
	set desc = "Release number units of chemicals from canister"
	set src in oview(1)
	if(usr.stat) return
	if(number <= 0) return
	if(number > gas:plasma + gas:oxygen) number = gas:plasma + gas:oxygen
	if(istype(loc, /turf))
		var/location = loc
		gas:turf_add(location, number)







/obj/canister/verb/releaseall()
	set name = "Release:All"
	set desc = "Release all stored chemicals"
	set src in oview(1)
	if(usr.stat) return
	if(istype(loc, /turf))
		var/location = loc
		gas:turf_add(location, -1)
/obj/canister/poisoncanister
	name = "Canister \[Plasma (Bio)\]"
	icon_state = "poisoncanister"
/obj/canister/poisoncanister/New()
	..()
	gas:plasma = 50000
/obj/canister/poisoncanister/setdestroystate()
	icon_state = "poisoncanister-1"


/obj/canister/oxygencanister
	name = "Canister: \[O2\]"
	icon_state = "oxygencanister"
/obj/canister/oxygencanister/New()
	..()
	gas:oxygen = 75000
/obj/canister/oxygencanister/setdestroystate()
	icon_state = "oxygencanister-1"















/obj/computer/atmosphere
	icon = 'turfs.dmi'
	density = 1
/obj/computer/atmosphere/proc/returnarea()
/obj/computer/atmosphere/anchored = 1
/obj/computer/atmosphere/siphonswitch/returnarea()
	var/T = loc
	if(!istype(T, /turf)) return
	return T:loc:contents

/obj/computer/atmosphere/siphonswitch
	icon_state = "switch"
/obj/computer/atmosphere/siphonswitch/verb/engageall()
	set src in oview(1)
	if(usr.stat) return
	usr << "Starting siphon systems."
	for(var/obj/station/atmoalter/S in returnarea())
		S:engage()
/obj/computer/atmosphere/siphonswitch/verb/disengageall()
	set src in oview(1)
	if(usr.stat) return
	usr << "Stopping all siphon systems."
	for(var/obj/station/atmoalter/S in returnarea())
		S:disengage()
/obj/computer/atmosphere/siphonswitch/verb/releaseall()
	set src in oview(1)
	if(usr.stat) return
	usr << "Releasing unused stored oxygen reserves."
	for(var/obj/station/atmoalter/S in returnarea())
		S:releaseall()
/obj/computer/atmosphere/siphonswitch/verb/engagescrubbers()
	set src in oview(1)
	if(usr.stat) return
	usr << "Starting siphon systems."
	for(var/obj/station/atmoalter/scrubbers/S in returnarea())
		S:engage()
/obj/computer/atmosphere/mastersiphonswitch
	icon_state = "switch"
/obj/computer/atmosphere/mastersiphonswitch/returnarea()
	return world

/obj/computer/atmosphere/mastersiphonswitch/verb/engageall()
	set src in oview(1)
	if(usr.stat) return
	usr << "Starting siphon systems."
	for(var/obj/station/atmoalter/S in returnarea())
		S:engage()
/obj/computer/atmosphere/mastersiphonswitch/verb/disengageall()
	set src in oview(1)
	if(usr.stat) return
	usr << "Stopping all siphon systems."
	for(var/obj/station/atmoalter/S in returnarea())
		S:disengage()
/obj/computer/atmosphere/mastersiphonswitch/verb/releaseall()
	set src in oview(1)
	if(usr.stat) return
	usr << "Releasing unused stored oxygen reserves."
	for(var/obj/station/atmoalter/S in returnarea())
		S:releaseall()
/obj/computer/atmosphere/mastersiphonswitch/verb/engagescrubbers()
	set src in oview(1)
	if(usr.stat) return
	usr << "Starting siphon systems."
	for(var/obj/station/atmoalter/scrubbers/S in returnarea())
		S:engage()
