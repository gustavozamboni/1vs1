var void(float) csqc_entity_parsers[ENT_CLIENT_COUNT];

void (float ignore) csqc_entity_error {
	error(strcat("unknown entity type in CSQC_Ent_Update: ", ftos(self.enttype), "\n"));
}

void(void) csqc_entity_clean {
	if (self.entremove)
		self.entremove();

	self.enttype = 0;
	self.classname = "";
	self.draw = NULL;
	self.entremove = NULL;
}

void CSQC_Ent_Remove() { //called by engine
	if (self.enttype)
		csqc_entity_clean();

	remove(self);
}

// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void(float bIsNewEntity) CSQC_Ent_Update { //called by engine
	float t;
	float savetime;
	t = ReadByte();
	// set up the "time" global for received entities to be correct for interpolation purposes
	savetime = time;
	if (servertime) {
		time = servertime;
	} else {
		serverprevtime = time;
		serverdeltatime = getstatf(STAT_MOVEVARS_TICRATE) * getstatf(STAT_MOVEVARS_TIMESCALE);
		time = serverprevtime + serverdeltatime;
	}
	if (self.enttype)
		if (t != self.enttype) {
			//print("A CSQC entity changed its type!\n");
			csqc_entity_clean();
			bIsNewEntity = 1;
		}
	if (t >= ENT_CLIENT_COUNT)
		csqc_entity_error(0);

	self.enttype = t;
	csqc_entity_parsers[t](bIsNewEntity);
	time = savetime;
}

void(void) csqc_entity_init {
	float i;
	for (i = 0; i < ENT_CLIENT_COUNT; i++) {
		csqc_entity_parsers[i] = csqc_entity_error;
	}
	csqc_entity_parsers[ENT_CLIENT_ENTCS] = entcs_read;
	csqc_entity_parsers[ENT_CLIENT_SCORES_INFO] = score_info_read;
	csqc_entity_parsers[ENT_CLIENT_SCORES] = score_player_read;
	csqc_entity_parsers[ENT_CLIENT_TEAMSCORES] = score_team_read;
	csqc_entity_parsers[ENT_CLIENT_POINTPARTICLES] = particles_point_read;
	csqc_entity_parsers[ENT_CLIENT_RAINSNOW] = particles_rain_or_snow_read;
	csqc_entity_parsers[ENT_CLIENT_LASER] = laser_read;
	csqc_entity_parsers[ENT_CLIENT_NAGGER] = ready_read;
	csqc_entity_parsers[ENT_CLIENT_WAYPOINT] = waypointsprite_read;
	csqc_entity_parsers[ENT_CLIENT_RADARLINK] = teamradar_link_read;
	csqc_entity_parsers[ENT_CLIENT_PROJECTILE] = projectile_read;
	csqc_entity_parsers[ENT_CLIENT_GIBSPLASH] = gib_read;
	csqc_entity_parsers[ENT_CLIENT_DAMAGEINFO] = damage_info_read;
	csqc_entity_parsers[ENT_CLIENT_CASING] = casing_read;
	csqc_entity_parsers[ENT_CLIENT_INIT] = main_init_read;
	csqc_entity_parsers[ENT_CLIENT_MAPVOTE] = mapvote_read;
	csqc_entity_parsers[ENT_CLIENT_RANDOMSEED] = prandom_seed_read;
	csqc_entity_parsers[ENT_CLIENT_WALL] = wall_read;
	csqc_entity_parsers[ENT_CLIENT_MODELEFFECT] = effect_model_read;
	csqc_entity_parsers[ENT_CLIENT_PHYSICS] = physics_read;
	csqc_entity_parsers[ENT_CLIENT_PHYSICS_SPIDERBOT] = physics_spiderbot_read;
	csqc_entity_parsers[ENT_CLIENT_PHYSICS_AIRCRAFT] = physics_aircraft_read;
	csqc_entity_parsers[ENT_CLIENT_PHYSICS_CAR] = physics_car_read;
	csqc_entity_parsers[ENT_CLIENT_GAMESTATUS] = gamestatus_read;
	csqc_entity_parsers[ENT_CLIENT_MENU] = menu_read;
	csqc_entity_parsers[ENT_CLIENT_PROGRESSBAR] = progressbar_read;
	csqc_entity_parsers[ENT_CLIENT_LOCATION_REQUEST] = locationrequest_read;
	csqc_entity_parsers[ENT_CLIENT_DLC_LIST] = dlc_read;
	csqc_entity_parsers[ENT_CLIENT_ZAPPER] = zapper_beam_read;
	csqc_entity_parsers[ENT_CLIENT_ZAPPER_SHIELD] = zapper_shield_read;
	csqc_entity_parsers[ENT_CLIENT_DMG_INDICATOR] = damage_indicator_read;
	csqc_entity_parsers[ENT_CLIENT_WARPZONE] = warpzone_read;
	csqc_entity_parsers[ENT_CLIENT_FUNC_CAMERA] = func_camera_read;
	csqc_entity_parsers[ENT_CLIENT_WARPZONE_TELEPORTED] = warpzone_teleported_read;
	csqc_entity_parsers[ENT_CLIENT_NOTELINE] = noteline_read;
	csqc_entity_parsers[ENT_CLIENT_HOOK] = hook_read;
	csqc_entity_parsers[ENT_CLIENT_PHYSICS_HOOK] = hook_physics_read;
	csqc_entity_parsers[ENT_CLIENT_DLC_SOUND] = dlc_sound_read;
	csqc_entity_parsers[ENT_CLIENT_PHYSICS_JETPACK] = jetpack_read;
	csqc_entity_parsers[ENT_CLIENT_LMS_SPHERE] = sphere_read;
	csqc_entity_parsers[ENT_CLIENT_ICE] = ice_read;
}

// CSQC_Parse_TempEntity : Handles all temporary entity network data in the CSQC layer.
// You must ALWAYS first acquire the temporary ID, which is sent as a byte.
// Return value should be 1 if CSQC handled the temporary entity, otherwise return 0 to have the engine process the event.
float() CSQC_Parse_TempEntity { //called by engine
	// Acquire TE ID
	float nTEID = ReadByte();
	switch(nTEID) {
	case TE_CSQC_HIT:
		if (CVAR(cl_hitsound))
			sound(world, CHAN_AUTO, "misc/hit.wav", VOL_BASE, ATTN_NONE);

		if (CVAR(crosshair_hit_time) > 0) {
			view_crosshair_hittime = time + CVAR(crosshair_hit_time);
		}
		return TRUE;
	case TE_CSQC_ZCURVEPARTICLES:
		particles_zcurve_read();
		return TRUE;
	case TE_CSQC_NEXGUNBEAMPARTICLE:
		particles_nex_beam_read();
		return TRUE;
	case TE_CSQC_LIGHTNINGARC:
		effect_lightningarc_read();
		return TRUE;
	case TE_CSQC_BIGLIGHTNINGARC:
		effect_lightningarc_big_read();
		return TRUE;
	case TE_CSQC_ZAPPERLIGHTNING:
		zapper_lightning_read();
		return TRUE;
	case TE_CSQC_BLAST:
		effect_blast_read();
		return TRUE;
	case TE_CSQC_ANNOUNCE_PRINT:
		announce_print();
		return TRUE;
	case TE_CSQC_WEAPONLIST:
		sbar_weapons_time = time;
		return TRUE;
	case TE_CSQC_RADIO:
		radio_read();
		return TRUE;
	case TE_CSQC_NADGETSELECT:
		nadgetselect_read();
		return TRUE;
	case TE_CSQC_WEAPONSELECT:
		weaponselect_read();
		return TRUE;
	case TE_CSQC_PICTURE:
		mapvote_picture_read();
		return TRUE;
	case TE_CSQC_RACE:
		race_read();
		return TRUE;
	case TE_CSQC_TEAMSELECT:
		if not(main_isdemo)
			GUI_Show(GUI_TEAMSELECT);

		return TRUE;
	case TE_CSQC_GAMEOVER:
		if (main_calledhooks & MAIN_HOOK_START) {
			localcmd("\ncl_hook_gameend;");
			main_calledhooks |= MAIN_HOOK_END;
		}
		return TRUE;
	case TE_CSQC_MAPLIST:
		str_unzone_ifneeded(gui_available_maps);
		gui_available_maps = str_zone_ifneeded(ReadString());
		string s = gui_available_maps;
		gui_available_maps_count = 0;
		while (s != "") {
			s = str_cdr(s);
			gui_available_maps_count++;
		}
		return TRUE;
	case TE_CSQC_TRIP:
		trip_net_read();
		return TRUE;
	case TE_CSQC_HINT:
		hint_net_read();
		return TRUE;
	case TE_CSQC_MODELSELECT:
		modelselect_read();
		return TRUE;
	}
	return FALSE;
}
