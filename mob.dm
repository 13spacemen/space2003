


/atom/verb/examine()
	set src in oview(1)
	usr << "\blue<B>To be implemented</B>"
	usr << desc

/atom/movable/verb/pull()
	set src in oview(1)
	if(!anchored)
		usr.pulling = src

/obj/proc/alter_health()
	return 1
/obj/proc/relaymove()
/obj/screen
	icon = 'screen.dmi'
	layer = 20
/obj/screen/Click()
	switch(name)
		if("internal")
			usr.removeinternal()
		if("pull")
			usr.removepull()
		if("unequip")
			usr.unequip()

/client/Northeast()
/client/Southeast()
/client/Northwest()
/client/Southwest()
/client/var/moving
/client/Move()
	if(moving) return 0
	moving = 1
	. = ..()
	moving = 0
	return .



/mob/meteorhit(obj/O)
	view(src) << "\red [src] has been hit with by [O]"
	if(health > 0)
		health -= 30
		bruteloss += 30
		if(O:icon_state == "flaming")
			health -= 40
			fireloss += 40
/mob/Move()
	if(buckled) return
	if(pulling && get_dist(src, pulling) <= 1)
		..()
		if(ismob(pulling))
			var/M = pulling
			if(M:pulling == src)
				M:pulling = null
				step_to(pulling, src)
				M:pulling = src
			else step_to(pulling, src)
		else
			if(get_dir(src, pulling) == dir)
				step(pulling, get_dir(src, pulling))
			else step_to(pulling, src)
	else
		pulling = null
		..()
/mob/verb/change_gender()
	var/alone = 1
	for(var/mob/M in oview())
		if(M != src)
			alone = 0
	if(!alone)
		usr << "\blue You can't change when people are watching (it would ruin your disguise)."
	else
		if(gender == "male")
			gender = "female"
		else gender = "male"
	UpdateClothing()
/mob/Login()
	..()
	rname = name
	UpdateClothing()
	if(!main1)
		main1 = new /obj/screen(null)
		main2 = new /obj/screen(null)
		main3 = new /obj/screen(null)
		oxygen = new /obj/screen(null)
		toxin = new /obj/screen(null)
		internals = new /obj/screen(null)
		fire = new /obj/screen(null)
		healths = new /obj/screen(null)
		pullin = new /obj/screen(null)
		unequip = new /obj/screen(null)
		blind = new /obj/screen(null)


		main1:dir = SOUTH
		main2:dir = NORTHWEST
		main3:dir = EAST

		oxygen:icon_state = "oxy0"
		toxin:icon_state = "toxin0"
		internals:icon_state = "internal0"
		fire:icon_state = "fire0"
		healths:icon_state = "health0"
		pullin:icon_state = "pull0"
		unequip:icon_state = "unequip"
		blind:icon_state = "black"

		main1:name = "vitals"
		main3:name = "actions"

		oxygen:name = "oxygen"
		toxin:name = "toxin"
		internals:name = "internal"
		fire:name = "fire"
		healths:name = "health"
		pullin:name = "pull"
		unequip:name = "unequip"
		blind:name = " "

		oxygen:screen_loc = "15,12"
		toxin:screen_loc = "15,10"
		internals:screen_loc = "15,14"
		fire:screen_loc = "15,8"
		healths:screen_loc = "15,5"
		pullin:screen_loc = "12,1"
		unequip:screen_loc = "14,1"
		blind:screen_loc = "1,1 to 15,15"

		main1:screen_loc = "15,1 to 15,15"
		main2:screen_loc = "15,1"
		main3:screen_loc = "1,1 to 14,1"

		blind:layer = 0
		blind:plane = -1
		main1:layer = 19
		main2:layer = 19
		main3:layer = 19
	client:screen -= list(main1, main2, main3, oxygen, toxin, internals, fire, healths, pullin, unequip, blind)
	client:screen += list(main1, main2, main3, oxygen, toxin, internals, fire, healths, pullin, unequip, blind)












/mob/Logout()
	..()
/mob
	var/unequip
	var/pullin
	var/main1
	var/main2
	var/main3
	var/oxygen; var/toxin
	var/internals; var/fire
	var/healths
	var/blind
	var/pulling
	var/buckled = 0
	var/now_pushing; var/rejuv
	var/health = 100
	var/oxyloss = 0
	var/toxloss = 0
/mob/Bump(AM as mob|obj)
	..()
	if(!istype(AM, /atom/movable)) return
	if(!now_pushing)
		now_pushing = 1
		if(!AM:anchored)
			step(AM, get_dir(src, AM))
		now_pushing = 0
/mob/New()
	..()
	spawn(5) Life()



/mob
	var/fireloss = 0
	var/bruteloss = 0
	var/stat
	var/paralysis
/mob/proc/death()
	for(var/obj/O in src)
		if(O != wear_mask && O != wear_suit)
			O:loc = loc
	equipped = null
	healths:icon_state = "health5"
	stat = 2
	canmove = 0
	blind:layer = 0
	blind:plane = -1
	icon_state = "dead"
	var/cancel
	for(var/mob/M in world)
		if(M:client && !M:stat)
			cancel = 1
	if(!cancel)
		world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"
		ticker:shuttle_entered = 1
		ticker:timeleft = 1
	return
/mob/proc/Life()
	set background = 1
	var/T = loc
	var/plcheck
	var/oxcheck
	var/ficheck
	if(istype(T, /turf))
		plcheck = poisoncheck(T)
		oxcheck = oxycheck(T)
		ficheck = firecheck(T)
	else
		if(istype(T, /obj))
			var/O = T
			O:alter_health(src)
	if(plcheck && health >= 0)
		if(paralysis <= 0)
			health -= plcheck * 5
			toxloss += plcheck * 5
		else
			health -= plcheck
			toxloss += plcheck
	if(oxcheck && health >= 0)
		if(paralysis <= 0)
			health -= oxcheck * 5
			oxyloss += oxcheck * 5
		else
			health -= oxcheck
			oxyloss += oxcheck
	else if(istype(T, /turf) && health >= 0)
		if(oxyloss >= 10)
			var/amount = max(0.15, 1)
			health += amount
			oxyloss -= amount
		else
			health += oxyloss
			oxyloss = 0
	if(internal) internal:setsuffix(src)

	if(ficheck)
		health -= ficheck * 10
		fireloss += ficheck * 10

	if(stat < 2)
		if(health >= 100) healths:icon_state = "health0"
		else if(health >= 75) healths:icon_state = "health1"
		else if(health >= 50) healths:icon_state = "health2"
		else if(health > 20) healths:icon_state = "health3"
		else healths:icon_state = "health4"
	else
		healths:icon_state = "health5"

	if(pulling) pullin:icon_state = "pull1"
	else pullin:icon_state = "pull0"


	if(health <= -10)
		if(stat != 2)
			death()
	else if(health <= 20)
		if(health < 0)
			if(rejuv <= 0)
				health--
				oxyloss++
		stat = 1
		if(paralysis < 2) paralysis = 2

	if(rejuv > 0)
		rejuv--
	if(stat != 2)
		if(paralysis > 0)
			paralysis--
			canmove = 0
			stat = 1
			blind:layer = 18
			blind:plane = 0
		else
			stat = 0
			canmove = 1
			blind:layer = 0
			blind:plane = -1
	density = canmove
	icon_state = !canmove ? "dead" : "alive"
	UpdateClothing()

/mob/verb/removeinternal()
	internal = null
/mob/verb/removepull()
	pulling = null

/mob/proc/firecheck(turf/T)
	if(istype(wear_suit, /obj/item/weapon/clothing/suit/firesuit))
		if(T:firelevel > 100000)
			fire:icon_state = "fire1"
			return 1
		else
			if(T:firelevel > 100)
				if(istype(wear_mask, /obj/item/weapon/clothing/mask/gasmask))
					fire:icon_state = "fire0"
					return 0
				else
					fire:icon_state = "fire1"
					return 0.25
			else
				fire:icon_state = "fire0"
				return 0
	else


		if(T:firelevel > 100)
			fire:icon_state = "fire1"
			return 1
		fire:icon_state = "fire0"
		return 0
/mob/proc/poisoncheck(turf/T)
	if(!internal)
		if(T:poison <= 150)
			toxin:icon_state = "toxin0"
			return 0
		if(T:poison <= 400 && istype(wear_mask, /obj/item/weapon/clothing/mask/gasmask))
			toxin:icon_state = "toxin0"
			return 0.9
		else
			toxin:icon_state = "toxin1"
			return 1
	else
		var/amount = 200









		if(internal:gas:plasma + internal:gas:oxygen > 0)
			var/inpoison = internal:gas:plasma * amount / (internal:gas:plasma + internal:gas:oxygen)
			internal:gas:plasma -= inpoison
			if(internal:gas:plasma + internal:gas:oxygen + inpoison >= amount && inpoison <= 100)
				toxin:icon_state = "toxin0"
				return 0
			else if(!inpoison <= 100)
				toxin:icon_state = "toxin1"
				return 1
			else
				toxin:icon_state = "toxin0"
				return 0
		else
			toxin:icon_state = "toxin0"
			return 0




/mob/proc/oxycheck(turf/T)
	if(!internal)
		internals:icon_state = "internal0"

		if(T:oxygen <= 900)
			oxygen:icon_state = "oxy1"
			return 1
		else
			T:oxygen -= 20
			T:co2 += 10
			if(oxygen:icon_state == "oxy0")
				T:oxygen += 10

			if(T:co2 >= 200)
				oxygen:icon_state = "oxy1"
				return 1
			else
				oxygen:icon_state = "oxy0"
				return 0
	else
		var/amount = 200






		if(internal:gas:plasma + internal:gas:oxygen > 0)
			var/inoxy = internal:gas:oxygen * amount / (internal:gas:plasma + internal:gas:oxygen)
			internal:gas:oxygen -= inoxy
			T:co2 += inoxy / 2
			if(internal:gas:plasma + internal:gas:oxygen + inoxy >= amount && inoxy >= 100)
				internals:icon_state = "internal1"
				oxygen:icon_state = "oxy0"
				return 0
			else if(internal:gas:plasma + internal:gas:oxygen + inoxy < amount)
				oxygen:icon_state = "oxy1"
				internals:icon_state = "internal2"
			else
				internals:icon_state = "internal2"
				oxygen:icon_state = "oxy1"
			return 1
		else
			oxygen:icon_state = "oxy1"
			internals:icon_state = "internal2"
			return 1


/mob
	var/internal
/mob/Stat()
	..()
	statpanel("Status")
	if(client:statpanel == "Status")
		if(ticker)
			var/timel = ticker:timeleft
			stat(, "ETA-[timel / 600 % 60]:[timel / 100 % 6][timel / 10 % 10]")


		if(internal)
			stat(, "Internal Atmosphere: [internal]")
			stat(, "Internal Oxygen: [internal:gas:oxygen]")
			stat(, "Internal Plasma: [internal:gas:plasma]")
	statpanel("Inventory")
	if(client:statpanel == "Inventory") stat(, contents)
/mob
	var/canmove = 1
	var/muted = 0; var/start
/mob/proc/mute(mob/M in world)
	set category = "Admin"
	M:muted = !M:muted
	usr << "[M]'s chat status is now [M:muted ? "muted" : "voiced"]."
/mob/proc/changemessage(txt as text)
	set name = "Change Message"
	set category = "Admin"
	world_message = "[usr]: [txt]"
	world << "\blue<B>[world_message]</B>"
/mob/proc/changemode()
	set name = "Set Game Mode"
	set category = "Admin"
	if(ticker)
		return
	var/temp = input("Please select a mode", "Game Selecter") in list("secret", "traitor", "meteor", "extended")
	master_mode = temp
/mob/proc/boot(txt as text, mob/M in world)
	set category = "Admin"
	if(M && M:client) del(M:client)
/mob/proc/restart()
	set category = "Admin"
	world << "\green<B> Restarting world!"
	sleep(50)
	world.Reboot()





/mob/verb/unequip()
	if(usr.equipped)
		var/oldequip = usr.equipped
		usr.equipped = null
		oldequip:setsuffix(usr)
		usr << "\blue You unequip [oldequip]."
	else usr << "\blue You don't have anything equipped!"
/mob/verb/say(message as text)
	if(!muted)
		for(var/mob/M in world)
			if(M:stat > 1)
				M << "<B>[src]</B> [stat > 1 ? "\[<I>dead</I> \]" : ""]: [message]"
		if(!stat)
			view() << "<B>[src]</B>:[message]"
		else if(stat == 1)
			view() << "<B>[src]</B>:*gasp*"
	else
		usr << "<B>[src]</B>:[message]"
/mob/verb/watch()
	if(!stat)
		usr << "\blue You must be dead to use this!"
		return
	client:perspective = EYE_PERSPECTIVE
	client:eye = input("Please, select a player!", "Watch") as mob in world
/mob/verb/abandon_mob()
	if(stat != 2 || (!ticker || ticker:mode != "extended"))
		usr << "\blue<B>You must be dead to use this! It also must be Extended mode.</B>"
		return
	usr << "\blue<B>Please roleplay correctly!</B>"
	var/M = new /mob()
	M:name = client
	M:key = client










/mob/proc/respawn()
	for(var/obj/O in contents)
		O:loc = loc
	internal = null
	health = 100
	canmove = 1
	stat = 0
	toxloss = 0
	oxyloss = 0
	fireloss = 0
	loc = locate(/area/start)

/mob/Login()
	..()
	if(!start)
		if(key == "Thief jack")
			start = 1
			loc = locate(36, 67, 10)
		else
			start = 1
			loc = locate(/area/start)
	world << "<B>[src] has logged in!</B>"
	if((key in list("Exadv1", "Roara", "Thief jack")) || (world.address == client:address || !client:address))
		verbs += /mob/proc/mute
		verbs += /mob/proc/changemessage
		verbs += /mob/proc/boot
		verbs += /mob/proc/changemode
		verbs += /mob/proc/restart
		verbs += /mob/proc/who
	src << "\blue<B>[world_message]</B>"
	src << plmaster
	if(!isturf(loc))
		client:eye = loc
		client:perspective = EYE_PERSPECTIVE
	if(ticker && (ticker:timeleft && !locate(/obj/item/weapon/card/id) in src))
		var/I = new /obj/item/weapon/card/id(src)
		I:assignment = "Researcher's Assistant"
		I:registered = name
		I:access_level = 1
		I:lab_access = 1
		I:engine_access = 0
		I:air_access = 0
		I:name = "[I:registered]'s ID Card (1>1-0-0)"
/mob/Logout()
	world << "<B>[src] has logged out!</B>"
	..()
/mob/proc/who()
	set category = "Admin"
	usr << "<B>Current Players:</B>"
	for(var/mob/M in world)
		if(M:client)
			usr << "\t [M] ([M:client])"


/mob/proc/UpdateClothing()
	..()
	overlays:len = 0
	if(wear_mask)
		if(istype(wear_mask, /obj/item/weapon/clothing/mask/gasmask))
			if(canmove)
				overlays += image(icon = 'mob.dmi', icon_state = "gas_mask", layer = MOB_LAYER)
			else
				overlays += image(icon = 'mob.dmi', icon_state = "gas_mask2", layer = MOB_LAYER)
	if(wear_suit)
		if(istype(wear_suit, /obj/item/weapon/clothing/suit/firesuit))
			if(canmove)
				overlays += image(icon = 'mob.dmi', icon_state = "fire_suit", layer = MOB_LAYER)
			else
				overlays += image(icon = 'mob.dmi', icon_state = "fire_suit2", layer = MOB_LAYER)
	if(wear_id)
		name = wear_id:registered
	else
		name = rname
	if(gender == "female")
		icon = 's13fem.dmi'
	else icon = 'mob.dmi'
/mob/verb/remove(obj/O in contents)
	set src in oview(1)
	if(canmove && client)
		usr << "\blue You can't take from a person while their conscious! (unless they have no client)"
	else
		if(wear_mask == O)
			O:suffix = null
			wear_mask = null
			removeinternal()
		if(wear_suit == O)
			O:suffix = null
			wear_suit = null
		if(wear_id == O)
			O:suffix = null
			wear_id = null
		O:loc = loc
		UpdateClothing()
/mob/verb/countobj()
	var/total
	for(var/obj/O in world)
		total++
	usr << "There are [total] objects in the world!"

















/mob
	icon = 'mob.dmi'
	icon_state = "mob0"
	density = 1
	layer = 4



	var/rname
	var/wear_id
	weight = 35
/client/Move(turf/unneeded, direction)
	if(mob:canmove)
		var/O = mob:loc
		if(istype(O, /obj))
			O:relaymove(mob, direction)
		else
			..()
