
/turf
	var/firelevel
	var/oxygen = 1000
	var/oldoxy
	var/tmpoxy
	var/oldpoison
	var/tmppoison
	var/poison = 0
	var/co2 = 0
	var/oldco2
	var/tmpco2
	var/airdir
	var/airforce
	var/checkfire = 1
	var/atmoalt
/turf/New()
	if((x & 1) == (y & 1))
		checkfire = 0
	tmpoxy = oxygen
	oldoxy = oxygen
	tmppoison = poison
	oldpoison = poison
	tmpco2 = co2
	oldco2 = co2
	..()
/turf/proc/unburn() icon_state = initial(icon_state)
/turf/proc/Neighbors()
	var/L = list(NORTH, SOUTH, EAST, WEST)
	for(var/obj/door/window/D in src)
		if(!D:density) goto label1
		if(D:dir & 12)
			L -= SOUTH
		else
			L -= EAST
		label1
	for(var/obj/window/D in src)
		if(!D:density) goto label2
		L -= D:dir
		if(D:dir == SOUTHWEST)
			L:len = null
			return L
		label2
	return L
/turf/proc/FindTurfs()
	var/L = list()
	for(var/dir in Neighbors())
		var/T = get_step(src, dir)
		if(!T || !T:updatecell)
			goto label1
		L += T
		for(var/obj/door/window/D in T)
			if(!D:density) goto label2
			var/direct = get_dir(src, T)
			if(D:dir & 12 && direct & 1)
				L -= T
				goto label2
			else if(direct & 8)
				L -= T
				goto label2
			label2
		for(var/obj/window/D in T)
			if(!D:density) goto label3
			var/direct = get_dir(T, src)
			if(D:dir == SOUTHWEST)
				L -= T
				goto label3
			else if(direct == D:dir)
				L -= T
				goto label3
			label3
		label1
	return L
/turf/updatecell()
	checkfire = !checkfire
	if(checkfire)
		if(cellcontrol:var_swap)
			var/divideby = 1
			var/total = oxygen
			var/tpoison = poison
			var/tco2
			var/burn = firelevel >= 10
			for(var/T as turf in src.FindTurfs())
				divideby++
				total += T:oldoxy
				tpoison += T:oldpoison
				tco2 += T:co2
				if(T:firelevel >= 100) burn = 1
			oxygen = total / divideby
			poison = tpoison / divideby
			co2 = tco2 / divideby
			if(poison > 200)
				overlays = list(plmaster)
			else
				overlays = null
			if(burn) firelevel = oxygen + poison
			if(firelevel >= 100)
				icon_state = "burning"
				if(oxygen > 50)
					co2 += 25
					oxygen -= 50
				else
					oxygen = 0
				poison = max(0, poison - 10)
				if(locate(/obj/canister) in src)
					for(var/obj/canister/C in src)
						C:health = max(C:health - firelevel, 0)
						C:healthcheck()
				if(locate(/obj/water) in src)
					firelevel = 0
				var/A = loc
				if(!istype(A, /area)) goto label1
				for(var/obj/firealarm/F in src)
					if(F:working && F:detecting)
						A:firealert()
						break
			else
				firelevel = 0
				if(icon_state == "burning")
					unburn()
			label1
			tmpoxy = oxygen
			tmppoison = poison
			tmpco2 = co2
		else
			var/divideby = 1
			var/total = oxygen
			var/tpoison = poison
			var/tco2 = co2
			var/burn = firelevel >= 10
			for(var/T as turf in src.FindTurfs())
				divideby++
				total += T:tmpoxy
				tpoison += T:tmppoison
				tco2 += T:co2
				if(T:firelevel >= 100) burn = 1
			oxygen = total / divideby
			poison = tpoison / divideby
			co2 = tco2 / divideby
			if(poison > 200)
				overlays = list(plmaster)
			else
				overlays = null
			if(burn) firelevel = oxygen + poison
			if(firelevel >= 100)
				icon_state = "burning"
				if(oxygen > 50)
					co2 += 25
					oxygen -= 50
				else
					oxygen = 0
				poison = max(0, poison - 10)
				co2 += 25
				if(locate(/obj/canister) in src)
					for(var/obj/canister/C in src)
						C:health = max(C:health - firelevel, 0)
						C:healthcheck()
				if(locate(/obj/water) in src)
					firelevel = 0
				var/A = loc
				if(!istype(A, /area)) goto label2
				for(var/obj/firealarm/F in src)
					if(F:working && F:detecting)
						A:firealert()
						break
			else if(icon_state == "burning")
				firelevel = 0
				unburn()
			label2
			oldoxy = oxygen
			oldpoison = poison
			oldco2 = co2
	else
		if(cellcontrol:var_swap)
			var/divideby = 1
			var/total = oxygen
			var/tpoison = poison
			var/tco2 = co2
			airdir = null
			airforce = 0
			var/adiff
			for(var/T as turf in src.FindTurfs())
				divideby++
				total += T:oldoxy
				tpoison += T:oldpoison
				tco2 += T:co2
				adiff = oldoxy + oldco2 - (T:oldoxy + T:oldco2)
				if(adiff > airforce)
					airforce = adiff
					airdir = get_dir(src, T)
			if(airforce >= 20)
				for(var/atom/movable/AM in src)
					if(!AM:anchored && AM:weight <= airforce)
						spawn(0) step(AM, airdir)
			oxygen = total / divideby
			poison = tpoison / divideby
			co2 = tco2 / divideby

			if(co2 >= poison)
				co2 -= poison
				oxygen += poison
				poison = 0
			else
				poison -= co2
				oxygen += co2
				co2 = 0

			tmpoxy = oxygen
			tmppoison = poison
			tmpco2 = co2
		else
			var/divideby = 1
			var/total = oxygen
			var/tpoison = poison
			var/tco2 = co2
			airdir = null
			airforce = 0
			var/adiff
			for(var/T as turf in src.FindTurfs())
				divideby++
				total += T:tmpoxy
				tpoison += T:tmppoison
				tco2 += T:co2
				adiff = tmpoxy + tmpco2 - (T:tmpoxy + T:tmpco2)
				if(adiff > airforce)
					airforce = adiff
					airdir = get_dir(src, T)
			if(airforce >= 20)
				for(var/atom/movable/AM in src)
					if(!AM:anchored && AM:weight <= airforce)
						spawn(0) step(AM, airdir)
			oxygen = total / divideby
			poison = tpoison / divideby
			co2 = tco2 / divideby

			if(co2 >= poison)
				co2 -= poison
				oxygen += poison
				poison = 0
			else
				poison -= co2
				oxygen += co2
				co2 = 0

			oldoxy = oxygen
			oldpoison = poison
			oldco2 = co2
	spawn(1) if(atmoalt) atmoalt:afterupdate()

/turf
	icon = 'turfs.dmi'
	var/updatecell
