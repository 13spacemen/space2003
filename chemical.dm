
/obj/substance/proc/leak(turf)
/obj/substance/chemical

/obj/substance/gas/leak(turf/T)
	turf_add(T, co2 + oxygen + plasma)


/obj/substance/gas
	var/temperature = 60
	var/co2 = 0
	var/oxygen = 0
	var/plasma = 0
	var/maximum = -1
/obj/substance/gas/proc/transfer_to(obj/target, amount)
	if(!istype(target, /obj/substance/gas) || !amount) return
	var/t1 = target:co2 + target:oxygen + target:plasma
	if(!t1) return
	if(amount > t1) amount = t1
	var/t2 = co2 + oxygen + plasma
	if(amount < 0)
		amount = t1
	if(maximum > 0 && maximum - t2 < amount)
		amount = maximum - t2









	var/t_oxy = amount * target:oxygen / t1
	var/t_pla = amount * target:plasma / t1
	var/t_co2 = amount * target:co2 / t1

	var/t3 = t1 + t2
	var/t4 = t2 * temperature
	var/t5 = t1 * target:temperature
	if(t3 > 0) temperature = (t4 + t5) / t3

	co2 += t_co2
	oxygen += t_oxy
	plasma += t_pla

	target:oxygen -= t_oxy
	target:co2 -= t_co2
	target:plasma -= t_pla
/obj/substance/gas/proc/clear()
	oxygen = 0
	plasma = 0
	co2 = 0
/obj/substance/gas/proc/has_gas()
	return co2 + oxygen + plasma > 0

/obj/substance/gas/proc/turf_add(turf/target, amount)
	if(!istype(target, /turf)) return
	if(!istype(target, /turf) || !amount) return

	var/t2 = co2 + oxygen + plasma
	if(amount < 0)
		amount = plasma + oxygen + co2

	if(!t2) return

	var/t_oxy = amount * oxygen / t2
	var/t_pla = amount * plasma / t2
	var/t_co2 = amount * co2 / t2

	co2 -= t_co2
	oxygen -= t_oxy
	plasma -= t_pla

	target:oxygen += t_oxy
	target:co2 += t_co2
	target:poison += t_pla

/obj/substance/gas/proc/turf_take(turf/target, amount)
	if(!istype(target, /turf) || !amount) return
	var/t1 = target:co2 + target:oxygen + target:poison
	if(!t1) return
	var/t2 = co2 + oxygen + plasma
	if(amount > 0)
		if(maximum > 0 && maximum - t2 < amount)
			amount = maximum - t2
	else
		amount = plasma + oxygen + co2
	if(amount > t1) amount = t1

	var/t_oxy = amount * target:oxygen / t1
	var/t_pla = amount * target:poison / t1
	var/t_co2 = amount * target:co2 / t1

	var/t3 = t1 + t2
	var/t4 = t2 * temperature
	var/t5 = t1 * 60
	if(t3 > 0) temperature = (t4 + t5) / t3

	co2 += t_co2
	oxygen += t_oxy
	plasma += t_pla

	target:oxygen -= t_oxy
	target:co2 -= t_co2
	target:poison -= t_pla
/obj/substance/gas/proc/merge_into(obj/target)
	if(!istype(target, /obj/substance/gas)) return

	var/amount = co2 + oxygen + plasma + target:co2 + target:oxygen + target:plasma
	var/t1 = (co2 + oxygen + plasma) * temperature
	var/t2 = (target:co2 + target:oxygen + target:plasma) * target:temperature
	if(amount > 0) temperature = (t1 + t2) / amount

	co2 += target:co2
	oxygen += target:oxygen
	plasma += target:plasma

	target:oxygen = 0
	target:plasma = 0
	target:co2 = 0
