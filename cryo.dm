


/obj/computer/sleep_console
	icon = 'Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	density = 1
	var/obj/machinery/sleeper/connected
	anchored = 1
/obj/computer/sleep_console/New()
	..()
	spawn(5)
		connected = locate(/obj/machinery/sleeper) in get_step(src, WEST)
/obj/overlay
/obj/computer/sleep_console/verb/check()
	set src in oview(1)
	if(connected)
		connected:check(usr)
/obj/computer/sleep_console/verb/rejuvenate()
	set src in oview(1)
	if(connected)
		connected:inject(usr)
/obj/item/weapon/flasks
	icon = 'Cryogenic2.dmi'
	var/oxygen = 0
	var/plasma = 0
	var/coolant = 0
/obj/item/weapon/flasks/name = "flask"
/obj/item/weapon/flasks/examine()
	usr << "The flask is [(oxygen + plasma + coolant) * 100 / 500]% full"
	usr << "The flask can ONLY store liquids."



/obj/machinery/pipes/high_capacity

	capacity = 90000
/obj/item/weapon/flasks/oxygen
	name = "blue flask"
	icon_state = "oxygen"
	oxygen = 500
/obj/item/weapon/flasks/plasma
	name = "orange flask"
	icon_state = "plasma"
	plasma = 500
/obj/machinery/proc/orient_pipe(obj/pipes)
/obj/machinery/proc/receive_substance(obj/substance, obj/machinery)
/obj/machinery/pipes/flexipipe
	icon = 'wire.dmi'
	icon_state = "12"
	var/line1
	var/line2
	capacity = 10
/obj/machinery/pipes/flexipipe/receive_substance(obj/S, obj/source)
	if(source == line2)
		spawn(1) if(line1) line1:receive_substance(S, src)
	else if(source == line1)
		spawn(1) if(line2) line2:receive_substance(S, src)
	else
		S:leak(loc)
/obj/machinery/pipes/flexipipe/orient_pipe(obj/P)
	if(!line1) line1 = P
	else if(!line2) line2 = P
	else
		return 0
	return 1
/obj/machinery/pipes/flexipipe/New()
	..()
	spawn(5)
		var/M1 = locate(/obj/machinery) in get_step(src, WEST)
		var/M2 = locate(/obj/machinery) in get_step(src, EAST)
		var/temp = 0
		if(M1) temp += 4
		if(M2) temp += 8
		icon_state = "[temp]"
		if(M1)
			if(M1:orient_pipe(src))
				line1 = M1
		if(M2)
			if(M2:orient_pipe(src))
				line2 = M2
/obj/machinery/freezer
	icon = 'Cryogenic2.dmi'
	icon_state = "freezer_0"
	density = 1
	var/connector
	var/line_out
	anchored = 1
/obj/machinery/freezer/New()
	..()
	spawn(5) cycle()

/obj/machinery/freezer/verb/toggle_switch()
	set src in oview(1)
	status = !status
	if(status)
		usr << "\blue Now cooling using trying to use [c_used] unit\s coolant per second."
	else
		usr << "\blue No longer cooling."
	icon_state = "freezer_[status]"
/obj/machinery/freezer/verb/turn_valve()
	set src in oview(1)
	transfer = !transfer
	if(transfer)
		usr << "\blue Attempting to transfer 1 unit of oxygen bound with 1 unit of plasma. (cooled)"
	else
		usr << "\blue No longer attempting transfer."
/obj/machinery/freezer/verb/alter_coolant(number as num)
	set src in oview(1)
	number = round(number)
	number = max(0, number)
	number = min(number, 10)
	c_used = number
	usr << "\blue Amount changed to [c_used]!"
/obj/machinery/freezer/verb/alter_stat()
	set src in oview(1)
	if(flags >= 3) flags = 0
	else
		flags++
	if(flags == 1) usr << "\blue Using chemical: Oxygen"
	else if(flags == 2) usr << "\blue Using chemical: Plasma"
	else if(flags == 3) usr << "\blue Using chemicals: Oxygen and Plasma"
	else usr << "\blue Not using any chemicals."
/obj/machinery/freezer/verb/check()
	set src in oview(1)
	var/F1
	var/F2
	var/F3
	if(contents:len >= 3)
		F3 = contents[3]
	if(contents:len >= 2)
		F2 = contents[2]
	if(contents:len >= 1)
		F1 = contents[1]

	usr << "\blue<B>Temperature:</B> [temperature]"
	usr << "\blue Valve Status: [transfer ? "Flowing" : "Stopped"]"
	if(transfer) usr << "\blue\t Chemicals: [flags & 1 ? "Oxygen" : ""], [flags & 2 ? "Plasma" : ""]"
	usr << "\blue Cooling Status: [status ? "Cooling" : "Not Cooling"]"
	if(status) usr << "\blue\t Trying to use [c_used] unit\s of coolant."
	if(F1)
		usr << "\blue<B>Flask 1's status:</B>\n\t (L)Oxygen: [F1:oxygen]\n\t (L)Plasma: [F1:plasma]\n\t Coolant: [F1:coolant]"
	if(F2)
		usr << "\blue<B>Flask 2's status:</B>\n\t (L)Oxygen: [F2:oxygen]\n\t (L)Plasma: [F2:plasma]\n\t Coolant: [F2:coolant]"
	if(F3)
		usr << "\blue<B>Flask 3's status:</B>\n\t (L)Oxygen: [F3:oxygen]\n\t (L)Plasma: [F3:plasma]\n\t Coolant: [F3:coolant]"
/obj/machinery/sleeper/icon_state = "sleeper_0"
/obj/machinery/freezer
	var/c_used = 1
	var/status = 0
	var/flags = 3
	var/transfer = 0
	var/temperature = 60
/obj/machinery/freezer/proc/cycle()
	var/F1
	var/F2
	var/F3
	if(contents:len >= 3)
		F3 = contents[3]
	if(contents:len >= 2)
		F2 = contents[2]
	if(contents:len >= 1)
		F1 = contents[1]
	var/u_cool = 0
	if(status)
		u_cool = c_used
		if(F2 && F2:coolant)
			if(F2:coolant >= u_cool)
				F2:coolant -= u_cool
			else
				u_cool = F2:coolant
				F2:coolant = 0
		else if(F1 && F1:coolant)
			if(F1:coolant >= u_cool)
				F1:coolant -= u_cool
			else
				u_cool = F1:coolant
				F1:coolant = 0
		else if(F3 && F3:coolant)
			if(F3:coolant >= u_cool)
				F3:coolant -= u_cool
			else
				u_cool = F3:coolant
				F3:coolant = 0
		else u_cool = 0
	if(u_cool)
		temperature = max(-100, temperature - u_cool * 5)
	temperature = min(temperature + 5, 60)
	if(transfer)
		var/u_oxy = 0
		var/u_pla = 0
		if(flags & 1)
			u_oxy = 1
			if(F1 && F1:oxygen)
				if(F1:oxygen >= u_oxy)
					F1:oxygen -= u_oxy
				else
					u_oxy = F1:oxygen
					F1:oxygen = 0
			else if(F2 && F2:oxygen)
				if(F2:oxygen >= u_oxy)
					F2:oxygen -= u_oxy
				else
					u_oxy = F2:oxygen
					F2:oxygen = 0
			else if(F3 && F3:oxygen)
				if(F3:oxygen >= u_oxy)
					F3:oxygen -= u_oxy
				else
					u_oxy = F3:oxygen
					F3:oxygen = 0
			else u_oxy = 0
		if(flags & 2)
			u_pla = 1
			if(F3 && F3:plasma)
				if(F3:plasma >= u_pla)
					F3:plasma -= u_pla
				else
					u_pla = F3:plasma
					F3:plasma = 0
			else
				if(F2 && F2:plasma)
					if(F2:plasma >= u_pla)
						F2:plasma -= u_pla
					else
						u_pla = F2:plasma
						F2:plasma = 0
				else if(F1 && F1:plasma)
					if(F1:plasma >= u_pla)
						F1:plasma -= u_pla
					else
						u_pla = F1:plasma
						F1:plasma = 0
				else u_pla = 0
		if(u_oxy + u_pla > 0)
			var/G = new /obj/substance/gas(null)
			G:oxygen = u_oxy
			G:plasma = u_pla
			G:temperature = temperature
			spawn(3)
				if(line_out) line_out:receive_substance(G, src)
	spawn(10) cycle()
/obj/machinery/freezer/receive_substance(obj/S, obj/source)
	del(S)
/obj/machinery/freezer/orient_pipe(obj/P)
	if(!line_out) line_out = P
	else
		return 0
	return 1
/obj/machinery/freezer/New()
	..()
	var/O1 = new /obj/overlay()
	O1:icon = 'Cryogenic2.dmi'
	O1:icon_state = "canister connector_0"
	O1:pixel_y = -16
	overlays += O1
	connector = O1
	new /obj/item/weapon/flasks/oxygen(src)
	new /obj/item/weapon/flasks/coolant(src)
	new /obj/item/weapon/flasks/plasma(src)
	rebuild_overlay()
/obj/machinery/freezer/verb/remove(obj/F in src)
	set src in oview(1)
	F:loc = usr
	rebuild_overlay()
/obj/machinery/freezer/attackby(obj/F, mob/user)
	if(!istype(F, /obj/item/weapon/flasks)) return
	if(contents:len >= 3)
		user << "\blue All slots are full!"
		return
	else
		if(ismob(user)) user:unequip(F)
		F:loc = src
		rebuild_overlay()
/obj/machinery/freezer/proc/rebuild_overlay()
	for(var/x in overlays)
		overlays -= x
	overlays += connector
	var/counter = 0
	for(var/obj/item/weapon/flasks/F in src.contents)
		var/O = new /obj/overlay()
		O:icon = F:icon
		O:icon_state = F:icon_state
		O:pixel_y = -17
		O:pixel_x = counter * 12
		overlays += O
		counter++
		if(counter >= 3) return
/obj/item/weapon/flasks/coolant
	name = "light blue flask"
	icon_state = "coolant"
	coolant = 1000
/obj/machinery/sleeper/allow_drop()
	return 0
/obj/machinery/sleeper/verb/eject()
	set src in oview(1)
	if(usr.stat != 0) return
	go_out()
/obj/machinery/sleeper/verb/place_inside()
	set src in oview(1)
	if(usr.stat != 0) return
	if(occupant)
		usr << "\blue<B>The sleeper is already occupied!</B>"
		return
	if(ismob(usr.pulling))
		var/M = usr.pulling
		usr.pulling = null
		if(M:client)
			M:client:perspective = EYE_PERSPECTIVE
			M:client:eye = src
		M:loc = src
		occupant = M
		icon_state = "sleeper_1"
		for(var/obj/O in src)
			O:loc = loc
/obj/machinery/sleeper/verb/move_inside()
	set src in oview(1)
	if(usr.stat != 0) return
	if(occupant)
		usr << "\blue<B>The sleeper is already occupied!</B>"
		return
	usr.pulling = null
	usr.client:perspective = EYE_PERSPECTIVE
	usr.client:eye = src
	usr.loc = src
	occupant = usr
	icon_state = "sleeper_1"
	for(var/obj/O in src)
		del(O)
/obj/machinery/sleeper/proc/go_out()
	if(!occupant) return
	for(var/obj/O in src)
		O:loc = loc
	if(occupant:client)
		occupant:client:eye = occupant:client:mob
		occupant:client:perspective = MOB_PERSPECTIVE
	occupant:loc = loc
	occupant = null
	icon_state = "sleeper_0"

/obj/machinery/sleeper/proc/inject(mob/user)
	if(occupant)
		if(occupant:rejuv < 60)
			occupant:rejuv = 60
		user << "Occupant now has [occupant:rejuv] units of rejuvenation in his/her bloodstream."
	else user << "No occupant!"
/obj/machinery/sleeper/proc/check(mob/user)
	if(occupant)
		user << "\blue<B>Occupant ([occupant]) Statistics:</B>"
		var/t1
		switch(occupant:stat)
			if(0)
				t1 = "Conscious"
			if(1)
				t1 = "Unconscious"
			if(2)
				t1 = "*dead*"
		user << "[occupant:health > 50 ? "\blue" : "\red"]\t Health %: [occupant:health] ([t1])"
		user << "[occupant:oxyloss < 60 ? "\blue" : "\red"]\t -Respiratory Damage %: [occupant:oxyloss]"
		user << "[occupant:toxloss < 60 ? "\blue" : "\red"]\t -Toxin Content %: [occupant:toxloss]"
		user << "[occupant:fireloss < 60 ? "\blue" : "\red"]\t -Burn Severity %: [occupant:fireloss]"
		user << "\blue Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)"
		user << "\blue\t [occupant:paralysis / 5] second\s (if around 1 or 2 the sleeper is keeping them asleep.)"
	else user << "\blue There is no one inside!"
/obj/machinery/sleeper/alter_health(mob/M)
	if(M:health > 0)
		if(M:oxyloss >= 10)
			var/mob/amount = max(0.15, 1)
			M:health += amount
			M:oxyloss -= amount
		else
			M:health += M:oxyloss
			M:oxyloss = 0
	M:paralysis -= 4
	if(M:paralysis <= 1)
		M:paralysis = 3
	if(M:rejuv < 3)
		M:rejuv = 4

/obj/machinery/cryo_cell/icon_state = "celltop"
/obj/machinery/sleeper
	icon = 'Cryogenic2.dmi'

	density = 1
	var/occupant
	anchored = 1
/obj/machinery/cryo_cell/orient_pipe(obj/P)
	if(!line_in) line_in = P
	else
		return 0
	return 1
/obj/machinery/cryo_cell/allow_drop() return 0
/obj/machinery/cryo_cell/var/line_in
/obj/machinery/cryo_cell/New()
	..()
	gas = new /obj/substance/gas(null)
/obj/machinery/cryo_cell/verb/move_eject()
	set src in oview(1)
	if(usr.stat != 0) return
	go_out()
/obj/machinery/cryo_cell/verb/place_inside()
	set src in oview(1)
	if(usr.stat != 0) return
	if(occupant)
		usr << "\blue<B>The cell is already occupied!</B>"
		return
	if(ismob(usr.pulling))
		var/M = usr.pulling
		usr.pulling = null
		if(M:client)
			M:client:perspective = EYE_PERSPECTIVE
			M:client:eye = src
		M:loc = src
		occupant = M
		icon_state = "celltop_1"
		for(var/obj/O in src)
			del(O)
/obj/machinery/cryo_cell/verb/move_inside()
	set src in oview(1)
	if(usr.stat != 0) return
	if(occupant)
		usr << "\blue<B>The cell is already occupied!</B>"
		return
	usr.pulling = null
	usr.client:perspective = EYE_PERSPECTIVE
	usr.client:eye = src
	usr.loc = src
	occupant = usr
	icon_state = "celltop_1"
	for(var/obj/O in src)
		O:loc = loc
/obj/machinery/cryo_cell/verb/console_check()
	set src in oview(1)
	usr << "\blue<B>System Statistics:</B>"
	if(gas:temperature > 0)
		usr << "\red\t Temperature (Farenheight): [gas:temperature] (MUST be below 0, add coolant to mixture)"
	else
		usr << "\blue\t Temperature(Farenheight): [gas:temperature] "
	if(gas:plasma < 1)
		usr << "\red\t Plasma Units: [gas:plasma] (Add plasma to mixture!)"
	else
		usr << "\blue\t Plasma Units: [gas:plasma]"
	if(gas:oxygen < 1)
		usr << "\red\t Oxygen Units: [gas:oxygen] (Add oxygen to mixture!)"
	else
		usr << "\blue\t Oxygen Units: [gas:oxygen]"
	if(occupant)
		usr << "\blue<B>Occupant Statistics:</B>"
		var/t1
		switch(occupant:stat)
			if(0)
				t1 = "Conscious"
			if(1)
				t1 = "Unconscious"
			if(2)
				t1 = "*dead*"
		usr << "[occupant:health > 50 ? "\blue" : "\red"]\t Health %: [occupant:health] ([t1])"
		usr << "[occupant:oxyloss < 60 ? "\blue" : "\red"]\t -Respiratory Damage %: [occupant:oxyloss]"
		usr << "[occupant:toxloss < 60 ? "\blue" : "\red"]\t -Toxin Content %: [occupant:toxloss]"
		usr << "[occupant:fireloss < 60 ? "\blue" : "\red"]\t -Burn Severity %: [occupant:fireloss]"
/obj/machinery/cryo_cell/proc/go_out()
	if(!occupant) return
	for(var/obj/O in src)
		O:loc = loc
	if(occupant:client)
		occupant:client:eye = occupant:client:mob
		occupant:client:perspective = MOB_PERSPECTIVE
	occupant:loc = loc
	occupant = null
	icon_state = "celltop"
/obj/machinery/cryo_cell/relaymove()
	go_out()
/obj/machinery/cryo_cell/alter_health(mob/M)
	if(M:health < 0)
		if(gas:temperature > 0 || gas:plasma < 1)
			return
	if(gas:oxygen >= 1)
		gas:oxygen--
		if(M:oxyloss >= 10)
			var/mob/amount = max(0.15, 1)
			M:health += amount
			M:oxyloss -= amount
		else
			M:health += M:oxyloss
			M:oxyloss = 0
	if(gas:temperature < 0 && gas:plasma >= 1)
		gas:plasma--
		if(M:toxloss > 5)
			var/mob/amount = max(0.1, 1)
			M:health += amount
			M:toxloss -= amount
		else
			M:health += M:toxloss
			M:toxloss = 0

		if(M:fireloss > 15)
			var/mob/amount = max(0.3, 1)
			M:health += amount
			M:fireloss -= amount
		else
			M:health += M:fireloss
			M:fireloss = 0


		if(M:bruteloss > 10)
			var/mob/amount = max(0.3, 1)
			M:health += amount
			M:bruteloss -= amount
		else
			M:health += M:bruteloss
			M:bruteloss = 0

		M:paralysis += 5
	if(gas:temperature < 60)
		gas:temperature = min(gas:temperature + 1, 60)
	return
/obj/machinery/cryo_cell/receive_substance(obj/S, obj/source)
	if(!istype(S, /obj/substance/gas))
		del(S)
		return
	else
		gas:merge_into(S)
		del(S)
/obj/machinery/cryo_cell/New()
	..()
	layer = 5
	var/O1 = new /obj/overlay()
	O1:icon = 'Cryogenic2.dmi'
	O1:icon_state = "cellconsole"
	O1:pixel_y = -32
	O1:layer = 4
	var/O2 = new /obj/overlay()
	O2:icon = 'Cryogenic2.dmi'
	O2:icon_state = "cellbottom"
	O2:pixel_y = -32
	pixel_y = 32
	overlays += O2
	overlays += O1

/obj/machinery/cryo_cell
	icon = 'Cryogenic2.dmi'

	density = 1
	var/occupant
	var/gas
	anchored = 1
