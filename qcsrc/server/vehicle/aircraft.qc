float g_vehicle_aircraft_pushfactor;
float g_vehicle_aircraft_laser_refire;
float g_vehicle_aircraft_laser_damage;
float g_vehicle_aircraft_laser_edgedamage;
float g_vehicle_aircraft_laser_force;
float g_vehicle_aircraft_laser_speed;
float g_vehicle_aircraft_laser_radius;
float g_vehicle_aircraft_laser_heat;
float g_vehicle_aircraft_laser_cooldown;
float g_vehicle_aircraft_laser_spread;

float(entity to, float sf) vehicle_aircraft_physics_send;
void(float eject) vehicle_aircraft_exit;
void(void) vehicle_aircraft_enter;

void(void) vehicle_aircraft_engine_on {
	if not(self.cnt) {
		self.modelflags |= MF_ROCKET;
		sound_to_at(MSG_ALL, self, '0 0 0', CHAN_PLAYER, "misc/jetpack_fly.wav", VOL_BASE, ATTN_NORM); 
		self.cnt = 1;
	}
}

void(void) vehicle_aircraft_engine_off {
	if (self.cnt) {
		self.modelflags &~= MF_ROCKET;
		sound_stop_to(MSG_ALL, self, CHAN_PLAYER);
		self.cnt = 0;
	}
}

void() vehicle_aircraft_attack_laser {
	if (self.attack_finished_single > time || self.vehicle_heat > 1)
		return;

	self.phase = !self.phase;
	self.angles_x = -self.angles_x;
	makevectors(self.angles);
	self.angles_x = -self.angles_x;
	if (self.phase)
		weapon_shotorg = self.origin + v_forward * 60 + v_right * 15 + v_up * 25;
	else
		weapon_shotorg = self.origin + v_forward * 60 - v_right * 15 + v_up * 25;

	damage_record_fires(self.owner, WEP_HLAC, 1);
	sound(self, CHAN_WEAPON, "weapons/lasergun_fire.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("laser_muzzleflash"), weapon_shotorg, weapon_shotdir * 1000, 1);
	entity proj = projectile(TRUE, PROJECTILE_HLAC, TRUE, self);
	projectile_setup(proj, weapon_shotorg, WEP_HLAC, g_vehicle_aircraft_laser_damage,
			g_vehicle_aircraft_laser_edgedamage, g_vehicle_aircraft_laser_radius, g_vehicle_aircraft_laser_force);

	proj.realowner = self.owner;
	proj.movetype = MOVETYPE_FLY;
	proj.velocity = (v_forward + randomvec() * self.vehicle_heat * g_vehicle_aircraft_laser_spread) * g_vehicle_aircraft_laser_speed;
	weapon_setup_projectile_velocity(proj);
	proj.touch = projectile_touch_explode;
	proj.think = stdproc_remove;
	proj.nextthink = time + 5;
	self.vehicle_heat += g_vehicle_aircraft_laser_heat * g_vehicle_aircraft_laser_refire;
	if(self.vehicle_heat >= 1) {
		self.vehicle_heat = 1;
		self.attack_finished_single = time + (1 / g_vehicle_aircraft_laser_cooldown);
	} else
		self.attack_finished_single = time + g_vehicle_aircraft_laser_refire;
}

void(void) vehicle_aircraft_pull_stop {
	if (self.gun1) {
		remove(self.gun1);
		self.gun1 = world;
		self.aiment = world;
		sound_stop(self, CHAN_TRIGGER);
	}
}

void(void) vehicle_aircraft_pull {
	if not(self.gun1) {
		self.gun1 = spawn();
		setmodel(self.gun1, "models/vhshield.md3");
		self.gun1.angles_x = 90;
		self.gun1.scale = 1.75;
		self.gun1.alpha = 0.5;
		self.gun1.colormod = '1.5 2 0.25';
		setattachment(self.gun1, self, "");
		setorigin(self.gun1, '0 0 -200');
	}
	if (self.gun1.nextstep < time) {
		self.gun1.angles_z += frametime * 180;
		self.gun1.nextstep = time + 1.5;
		sound(self, CHAN_TRIGGER, "ambient/machinerydrone01.wav", VOL_BASE, ATTN_NORM);
	}
	if not(self.aiment) {
		trace_box(self.origin, self.mins, self.maxs, self.origin - '0 0 100', MOVE_NORMAL, self);
		if (trace_ent)
		if (trace_ent.movetype != MOVETYPE_NOCLIP)
		if (trace_ent.movetype != MOVETYPE_NONE)
		if (trace_ent.movetype != MOVETYPE_FOLLOW)
		if (trace_ent.solid == SOLID_SLIDEBOX || trace_ent.solid == SOLID_BBOX) {
			float _volume = (trace_ent.maxs_x - trace_ent.mins_x) * (trace_ent.maxs_y - trace_ent.mins_y) *  (trace_ent.maxs_z - trace_ent.mins_z);
			if (_volume < 3000 || _volume > 3000000) {
				return;
			}
			self.aiment = trace_ent;
			//self.aiment.disableclientprediction = TRUE;
		}
	} else {
		float zdistance = self.origin_z - self.mins_z - self.aiment.origin_z - self.aiment.maxs_z;
		vector center = (self.aiment.mins + self.aiment.maxs) * 0.5 + self.aiment.origin;
		vector delta = center - self.origin;
		float ldelta = vlen(delta);
		if (zdistance > 100 || zdistance < 0 || ldelta > 200 || (self.solid != SOLID_BBOX && self.solid != SOLID_SLIDEBOX)) {
			vehicle_aircraft_pull_stop();
			return;
		} else if (zdistance > 50) {
			self.aiment.velocity_z = self.velocity_z + (zdistance - 50) * 4;
		} else if (zdistance > 25) {
			self.aiment.velocity_z = self.velocity_z;
		} else {
			self.aiment.velocity_z = self.velocity_z - (zdistance - 25) * 2;
		}
		delta_z = 0;
		if (ldelta < 10)
			delta = '0 0 0';

		self.aiment.velocity_x = self.velocity_x - delta_x * 4;
		self.aiment.velocity_y = self.velocity_y - delta_y * 4;
		te_lightning1(self, self.origin, center);
	}
}

float(void) vehicle_aircraft_physics_hook {
    entity player,aircraft;
    player = self;
    aircraft = self.vehicle;
    player.BUTTON_ZOOM = 0;
    player.BUTTON_CROUCH = 0;
    player.switchweapon = 0;
    if (player.BUTTON_HOOK || player.BUTTON_USE || (aircraft.bot_nextthink && aircraft.bot_nextthink < time)) {
		vehicle_extract_player(player, FALSE);
		return 1;
	}
    if (map_finished) {
		aircraft.velocity = '0 0 0';
		return 1;
	}
    //anim_do();
	self = aircraft;
    vehicle_stdproc_regen();
	if (player.BUTTON_ATCK) {
		vehicle_aircraft_attack_laser();
	}
	if (player.BUTTON_ATCK2) {
		vehicle_aircraft_pull();
	} else {
		vehicle_aircraft_pull_stop();
	}
    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
	if (physics_movement != '0 0 0' || physics_button_jump)
		vehicle_aircraft_engine_on();
	else
		vehicle_aircraft_engine_off();

	physics_aircraft();
	vehicle_adjust_player_position(player, aircraft, AIRCRAFT_VIEW_START_OFFSET, AIRCRAFT_VIEW_BACK, AIRCRAFT_VIEW_UP);
	player.angles = aircraft.angles;
	physics_velocity = player.velocity = '0 0 0';
    self = player;
	if (aircraft.player_physic)
		aircraft.player_physic.SendFlags |= 2;

	physics_flags = player.flags;
    return 1;
}

void(void) vehicle_aircraft_think {
	if(self.vehicle_heat > 0)
		self.vehicle_heat = max(self.vehicle_heat - g_vehicle_aircraft_laser_cooldown * sys_ticrate,0);

	if (self.owner) {
		self.owner.vehicle_heat = self.vehicle_heat;
	} else {
		physics_movetype = MOVETYPE_QCWALK;
		physics_flags = self.flags;
		physics_velocity = self.velocity;
		physics_gravity_factor = (self.gravity ? self.gravity : 1);
		physics_update_status(TRUE);
		self.velocity = physics_velocity;
		self.flags = physics_flags;
        movelib_beak_simple(g_vehicle_aircraft_speed_stop * frametime);
		physics_velocity = self.velocity;
		physics_move();
		self.velocity = physics_velocity;
	}
    self.nextthink = time;
}

void(void) vehicle_aircraft_enter {
	if not(vehicle_enter(self.angles, vehicle_aircraft_physics_hook, HUD_SPIDERBOT, vehicle_aircraft_physics_send))
		return;

	self.colormap = self.owner.colormap;
	vehicle_stdproc_setcolormod();
}

void(float eject) vehicle_aircraft_exit {
	vehicle_aircraft_pull_stop();
	vehicle_stdproc_exit(eject, 160, 160);
	vehicle_aircraft_engine_off();
	self.think = vehicle_aircraft_think;
	self.nextthink = time;
	self.colormap = 1024;
	vehicle_stdproc_setcolormod();
}

void(void) vehicle_aircraft_touch {
	push_touch();
	if (self.owner || other.classname != "player")
		return;

	if not(player_can_use_vehicle(other))
		return;

    vehicle_aircraft_enter();
}

void(void) vehicle_aircraft_spawn {
	self.frame = 5;
	self.think = vehicle_aircraft_think;
	self.nextthink = time;
	self.health = self.health_max;
	self.vehicle_shield = self.shield_max;
	self.event_damage = vehicle_stdproc_damage;
	self.iscreature = TRUE;
	self.movetype = MOVETYPE_QCWALK;
	self.solid = SOLID_SLIDEBOX;
	self.takedamage = DAMAGE_AIM;
	self.touch = vehicle_aircraft_touch;
	self.alpha = 1;
	self.colormap = 1024;
	self.deadflag = DEAD_NO;
	self.bot_attack = TRUE;
	self.pushfactor = g_vehicle_aircraft_pushfactor;
	self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
	setsize(self,aircraft_MIN,aircraft_MAX);
	setorigin(self,self.enemy.origin);
	self.angles = self.enemy.angles;
	vehicle_stdproc_setcolormod();
	pointparticles(particleeffectnum("teleport"), self.origin + '0 0 64', '0 0 0', 1);
}

void(void) vehicle_aircraft_blowup {
	damage_radius (self, self, 100, 15, 250, world, 250, WEP_ROCKET_LAUNCHER, world);
	self.alpha = -1;
	self.nextthink = time + 10;
	self.think = vehicle_aircraft_spawn;
	self.velocity = '0 0 0';
	setorigin(self,self.tur_aimpos);
}

void(void) vehicle_aircraft_die {
	vehicle_aircraft_engine_off();
	self.health = 0;
	self.event_damage = stdproc_nothing;
	self.iscreature = FALSE;
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	self.touch = stdproc_nothing;
	self.deadflag = DEAD_DEAD;
	self.frame = 0;
	self.think = vehicle_aircraft_blowup;
	self.nextthink = time;
	float i, f;
	for (i = 0; i < 10; i++) {
		f = random();
		if(f < 0.3)
			onslaught_throwgib(self.origin + '0 0 40', (100 * randomvec() - '1 1 1') * 11 + '0 0 20', "models/onslaught/gen_gib1.md3", 6, TRUE);
		else if(f > 0.7)
			onslaught_throwgib(self.origin + '0 0 40', (100 * randomvec() - '1 1 1') * 12 + '0 0 20', "models/onslaught/gen_gib2.md3", 6, TRUE);
		else
			onslaught_throwgib(self.origin + '0 0 40', (100 * randomvec() - '1 1 1') * 13 + '0 0 20', "models/onslaught/gen_gib3.md3", 6, TRUE);
	}
}

void(void) vehicle_aircraft_dinit {
    self.enemy = spawn();
    self.enemy.angles = self.angles;
    setorigin(self.enemy, self.origin);
    if(self.team && !team_mode)
        self.team = 0;
    else
        self.enemy.team = self.team;

    if (self.netname == "")
		self.netname = "aircraft";

    //self.vehicle_viewport = spawn();
    self.vehicle_flags = VHF_HASSHIELD | VHF_SHIELDREGEN | VHF_HEALTHREGEN | VHF_HIDEPLAYER | VHF_HEAT;
    self.cvar_basename = "g_vehicle_aircraft";
	self.vehicle_heat = 0;
    setmodel(self, "models/racers/waka.dpm");
	self.scale = 0.6;
    self.customizeentityforclient = vehicle_stdproc_customize;
    //setorigin(self.vehicle_viewport,'35 0 -14');
    self.tur_aimpos = self.origin;
    vehicle_aircraft_spawn();
    self.vehicle_die = vehicle_aircraft_die;
    self.vehicle_exit = vehicle_aircraft_exit;
    self.vehicle_spawn = vehicle_aircraft_spawn;
	self.reset = vehicle_reset;
}

float vehicle_aircraft_init_done;
void(void) vehicle_aircraft_init {
	vehicle_init();
	if (vehicle_aircraft_init_done)
		return;

	vehicle_aircraft_init_done = TRUE;
	CACHE_CVAR(g_vehicle_aircraft_movement_inertia);
	CACHE_CVAR(g_vehicle_aircraft_pushfactor);
	CACHE_CVAR(g_vehicle_aircraft_speed);
	CACHE_CVAR(g_vehicle_aircraft_speed_stop);
	CACHE_CVAR(g_vehicle_aircraft_accel_up);
	CACHE_CVAR(g_vehicle_aircraft_turnspeed);
	CACHE_CVAR(g_vehicle_aircraft_laser_force);
	CACHE_CVAR(g_vehicle_aircraft_laser_refire);
	CACHE_CVAR(g_vehicle_aircraft_laser_damage);
	CACHE_CVAR(g_vehicle_aircraft_laser_edgedamage);
	CACHE_CVAR(g_vehicle_aircraft_laser_speed);
	CACHE_CVAR(g_vehicle_aircraft_laser_radius);
	CACHE_CVAR(g_vehicle_aircraft_laser_heat);
	CACHE_CVAR(g_vehicle_aircraft_laser_cooldown);
	CACHE_CVAR(g_vehicle_aircraft_laser_spread);
    precache_model("models/vhshield.md3");
    precache_model("models/racers/waka.dpm");
	precache_sound("weapons/lasergun_fire.wav");
	precache_sound("ambient/machinerydrone01.wav");
	projectile_init(PROJECTILE_LASER);
}

float(entity to, float sf) vehicle_aircraft_physics_send {
	WriteByte(MSG_ENTITY, ENT_CLIENT_PHYSICS_AIRCRAFT);
	WriteShort(MSG_ENTITY, sf);
	if (sf & 1) {
		WriteCoord(MSG_ENTITY, g_vehicle_aircraft_accel_up);
		WriteCoord(MSG_ENTITY, g_vehicle_aircraft_speed);
		WriteCoord(MSG_ENTITY, g_vehicle_aircraft_speed_stop);
		WriteCoord(MSG_ENTITY, g_vehicle_aircraft_turnspeed);
		WriteCoord(MSG_ENTITY, g_vehicle_aircraft_movement_inertia);
		WriteShort(MSG_ENTITY, num_for_edict(self.vehicle));
	}
	if (sf & 2) {
		WriteCoord(MSG_ENTITY, self.vehicle.angles_x);
		WriteCoord(MSG_ENTITY, self.vehicle.angles_y);
		WriteCoord(MSG_ENTITY, self.vehicle.angles_z);
		WriteCoord(MSG_ENTITY, self.vehicle.origin_x);
		WriteCoord(MSG_ENTITY, self.vehicle.origin_y);
		WriteCoord(MSG_ENTITY, self.vehicle.origin_z);
		WriteCoord(MSG_ENTITY, self.vehicle.velocity_x);
		WriteCoord(MSG_ENTITY, self.vehicle.velocity_y);
		WriteCoord(MSG_ENTITY, self.vehicle.velocity_z);
	}
	return TRUE;
}

void(void) spawnfunc_vehicle_aircraft {
	vehicle_aircraft_init();
	vehicle_stdproc_init("aircraft", vehicle_aircraft_dinit);
}
