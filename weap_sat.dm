/atom/proc/laserhit(obj/L)
	return 1











/obj/computer/data/weapon/log/New()
	..()
	topics["Super-heater"] = "This turns a can of semi-liquid plasma into a super-heated ball of plasma."
	topics["Amplifier"] = "This increases the intensity of a laser."
	topics["Class 11 Laser"] = "This Creates a very slow laser that is capable of penetrating most objects."
	topics["Plasma Energizer"] = "This combines super-heated plkasma with a laser beam."
	topics["Generator"] = "This controls the entire power grid."
	topics["Mirror"] = "this can reflect LOW power lasers. HIGH power goes through it!"
	topics["Targetting Prism"] = "This focuses a laser comming from any direction forward."
/obj/computer/data/weapon/log/name = "Log Computer"
/obj/computer/data/weapon/log/display()
	usr << "<B>Research Log:</B>"
	..()
/obj/computer/data/weapon/log/read()
	..()

/obj/computer/data/wepaon/info/New()
	..()
	topics["LOG(001)"] = "System: Deployment successful"
	topics["LOG(002)"] = "System: Safe orbit at inclination .003 established"
	topics["LOG(003)"] = "CenCom: Attempting test fire...ALERT(001)"
	topics["ALERT(001)"] = "System: Cannot attempt test fire"
	topics["LOG(004)"] = "System: Airlock accessed..."
	topics["LOG(005)"] = "System: System successfully reset...Generator engaged"
	topics["LOG(006)"] = "Physical: Super-heater (W005) added to power grid"
	topics["LOG(007)"] = "Physical: Amplifier (W007) added to power grid"
	topics["LOG(008)"] = "Physical: Plasma Energizer (W006) added to power grid"
	topics["LOG(009)"] = "Physical: Laser (W004) added to power grid"
	topics["LOG(010)"] = "Physical: Laser test firing"
	topics["LOG(011)"] = "Physical: Plasma added to Super-heater"
	topics["LOG(012)"] = "Physical: Orient N12.525,E22.124"
	topics["LOG(013)"] = "System: Location N12.525,E22.124"
	topics["LOG(014)"] = "Physical: Test fire...successful"
	topics["LOG(015)"] = "Physical: Airlock accessed..."
	topics["LOG(016)"] = "******: Disalbe locater systems"
	topics["LOG(017)"] = "System: Locater Beacon-Disengaged,CenCom link-Cut...ALERT(002)"
	topics["ALERT(002)"] = "System: Cannot seem to establish contact with Central Command"
	topics["LOG(018)"] = "******: Shutting down all systems...ALERT(003)"
	topics["ALERT(003)"] = "System: Power grid failure-Activating back-up power...ALERT(004)"
	topics["ALERT(004)"] = "System: Engine failure...All systems deactivated."
/obj/computer/data/wepaon/info/name = "Research Computer"
/obj/computer/data/wepaon/info/display()
	usr << "<B>Research Information:</B>"
	..()
/obj/computer/data/wepaon/info/read()
	..()
/obj/computer/data/var/topics = list()

/obj/computer/data/verb/display()
	set src in oview(1)
	for(var/x in topics)
		usr << "[x], \..."
	usr << ""
/obj/computer/data/verb/read(topic as text)
	set src in oview(1)
	if(topics["[topic]"])
		usr << "<B>[topic]</B>\n\t [topics["[topic]"]]"
	else
		usr << "Unable to find- [topic]"
/obj/computer/data
	icon = 'weap_sat.dmi'
	icon_state = "computer"
	density = 1
/obj/laser/Bump()
	range--
/obj/laser/Move()
	range--

/obj/door
	var/operating
/obj/laser
	icon = 'weap_sat.dmi'
