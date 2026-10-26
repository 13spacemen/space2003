



/turf/station/floor/maintain
	var/pmlevel
	var/omlevel
/turf/station/floor/grid
	icon = 'weap_sat.dmi'
	icon_state = "grid"
/turf/station/floor/maintain/New()
	..()
	name = "floor"
/turf/station/floor/maintain/updatecell()
	..()
	poison = pmlevel
	oxygen = omlevel
/obj/station/alerter
	name = "Technician"
	icon = 'turfs.dmi'
	icon_state = "mob0"
	density = 1
/obj/station/alerter/verb/talk()
	set src in oview(1)
	view(2, src) << "\blue<B>[src]</B>:[desc]\n"
