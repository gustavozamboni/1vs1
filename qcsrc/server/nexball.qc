//EF_BRIGHTFIELD|EF_BRIGHTLIGHT|EF_DIMLIGHT|EF_BLUE|EF_RED|EF_FLAME
float ST_NEXBALL_GOALS;
float SP_NEXBALL_GOALS;
float SP_NEXBALL_FAULTS;
#define BALL_EFFECTMASK 1229
#define BALL_MINS '-16 -16 -16'  // The model is 24*24*24
#define BALL_MAXS '16 16 16'
#define BALL_ATTACHORG '10 0 10'
#define BALL_POV '30 0 -16'
#define BALL_SPRITECOLOR '.91 .85 .62'
#define BALL_FOOT   1
#define BALL_BASKET 2
#define BALL_HOCKEY 4
//spawnflags
#define GOAL_TOUCHPLAYER 1
//goal types
#define GOAL_FAULT -1
#define GOAL_OUT -2

float g_nexball_basketball_carrier_speed;
float g_nexball_football_boost_forward;
float g_nexball_football_boost_up;
float g_nexball_football_melee_boost_forward;
float g_nexball_football_melee_boost_up;
float g_nexball_football_physics;
float g_nexball_hockey_boost_forward;
float g_nexball_hockey_bouncefactor;
float g_nexball_hockey_melee_boost_forward;
float g_nexball_hockey_melee_boost_up;
float g_nexball_delay_idle;
float g_nexball_basketball_delay_hold;
float g_nexball_basketball_delay_hold_forteam;
float g_nexball_basketball_effects_default;
float g_nexball_basketball_teamsteal;
float g_nexball_ball_explosive_radius;
float g_nexball_ball_explosive_damage;
float g_nexball_ball_explosive_force;
float g_nexball_ball_scale;
float balls;
float ball_scale;
float nexball_teams;
.float metertime;
.float metertime_stat;
// Nexball
.entity ballcarried;
float g_nexball_meter_period;
float g_nexball_primary_shootatmaxmeter;
float g_nexball_primary_speed;
float g_nexball_basketball_meter;
float g_nexball_basketball_meter_maxpower;
float g_nexball_basketball_meter_minpower;
float g_nexball_delay_collect;
float g_nexball_delay_goal;
float g_nexball_delay_start;
.float teamtime;
.float explosive;
.entity pov_ball;

float() nexball_carrier_think;
var void() nexball_PlayerPreThink_NextLink;
void() nexball_PlayerPreThink;
void() nexball_delayedinit;
void() nexball_ball_reset;
void() nexball_basketball_touch;
void() nexball_football_touch;
void() nexball_hockey_touch;
void(entity ball, vector org, vector vel) nexball_drop_ball;

var void(float killed) nexball_PlayerClear_NextLink;
void(float killed) nexball_PlayerClear {
	if(self.ballcarried)
		nexball_drop_ball(self.ballcarried, self.origin, self.velocity);

	nexball_PlayerClear_NextLink(killed);
}

var float() nexball_SpeedMod_NextLink;
float() nexball_SpeedMod {
	float f = nexball_SpeedMod_NextLink();
	if(self.ballcarried)
		return g_nexball_basketball_carrier_speed * f;

	return f;
}

var float() nexball_weapon_frame_handle_next;
float() nexball_weapon_frame_handle {
	if (self.ballcarried)
		nexball_carrier_think();

	return nexball_weapon_frame_handle_next();
}

float() nexball_ReloadAllowed {
	if (self.ballcarried)
		return FALSE;

	return TRUE;
}

var float(float ignore) nexball_ThrowWeaponAllowed_NextLink;
float(float ignore) nexball_ThrowWeaponAllowed {
	if (self.ballcarried)
		return FALSE;

	return nexball_ThrowWeaponAllowed_NextLink(ignore);
}

float() nexball_RadarShowEnemiesAllowed {
	return TRUE;
}

var void(entity e) nexball_SpectateCopy_NextLink;
void(entity e) nexball_SpectateCopy {
	self.metertime = e.metertime;
}

float(entity plr) nexball_PlayerIsCarrier { return plr.ballcarried != world; }
void(entity plr) nexball_DropCarried { nexball_drop_ball(plr.ballcarried, plr.origin, plr.velocity); }
float(entity e) nexball_TeleportationForbiddenFor { return e.classname == "nexball_football" || e.classname == "nexball_basketball" || e.classname == "nexball_hockey"; }

var float(float f) nexball_SwitchWeaponMod_NextLink;
float(float f) nexball_SwitchWeaponMod {
	if (Akimbo_Owner(self).ballcarried)
		return 0;

	return nexball_SwitchWeaponMod_NextLink(f);
}

void() nexball_init {
	CACHE_CVAR(g_nexball_meter_period); //sent with the client init entity
	if (g_nexball_meter_period <= 0)
		g_nexball_meter_period = 2; // avoid division by zero etc. due to silly users

	g_nexball_meter_period = rint(g_nexball_meter_period * 32) / 32; //Round to 1/32ths to send as a byte multiplied by 32
	addstat(STAT_NB_METERSTART, AS_FLOAT, metertime_stat);
	// General settings
	CACHE_CVAR(g_nexball_football_boost_forward);   //100
	CACHE_CVAR(g_nexball_football_boost_up);        //200
	CACHE_CVAR(g_nexball_football_melee_boost_forward);
	CACHE_CVAR(g_nexball_football_melee_boost_up);
	CACHE_CVAR(g_nexball_hockey_boost_forward);   //100
	CACHE_CVAR(g_nexball_hockey_bouncefactor);   //0.9
	CACHE_CVAR(g_nexball_hockey_melee_boost_forward);   //300
	CACHE_CVAR(g_nexball_hockey_melee_boost_up);   //100
	CACHE_CVAR(g_nexball_delay_idle);               //10
	CACHE_CVAR(g_nexball_football_physics);         //0
	CACHE_CVAR(g_nexball_ball_scale);
	CACHE_CVAR(g_nexball_ball_explosive_radius);
	CACHE_CVAR(g_nexball_ball_explosive_damage);
	CACHE_CVAR(g_nexball_ball_explosive_force);
	CACHE_CVAR(g_nexball_primary_shootatmaxmeter);
	CACHE_CVAR(g_nexball_primary_speed);
	CACHE_CVAR(g_nexball_basketball_meter);
	CACHE_CVAR(g_nexball_basketball_meter_maxpower);
	CACHE_CVAR(g_nexball_basketball_meter_minpower);
	CACHE_CVAR(g_nexball_delay_collect);
	CACHE_CVAR(g_nexball_delay_goal);
	CACHE_CVAR(g_nexball_delay_start);
	CACHE_CVAR(g_nexball_basketball_carrier_speed);
	nexball_PlayerClear_NextLink = gamehook_chain_player_clear;
	gamehook_chain_player_clear = nexball_PlayerClear;
	nexball_SwitchWeaponMod_NextLink = GameHookChain_SwitchWeaponMod;
	GameHookChain_SwitchWeaponMod = nexball_SwitchWeaponMod;
	nexball_PlayerPreThink_NextLink = gamehook_chain_player_think;
	gamehook_chain_player_think = nexball_PlayerPreThink;
	nexball_SpeedMod_NextLink = gamehook_chain_physics_max_speed_mod;
	gamehook_chain_physics_max_speed_mod = nexball_SpeedMod;
	nexball_weapon_frame_handle_next = gamehook_chain_weapon_frame_handle;
	gamehook_chain_weapon_frame_handle = nexball_weapon_frame_handle;
	GameHook_ReloadAllowed = nexball_ReloadAllowed;
	nexball_ThrowWeaponAllowed_NextLink = GameHookChain_ThrowWeaponAllowed;
	GameHookChain_ThrowWeaponAllowed = nexball_ThrowWeaponAllowed;
	nexball_SpectateCopy_NextLink = gamehook_chain_spectator_copy;
	gamehook_chain_spectator_copy = nexball_SpectateCopy;
	GameHook_PlayerIsCarrier = nexball_PlayerIsCarrier;
	GameHook_DropCarried = nexball_DropCarried;
	GameHook_TeleportationForbiddenFor = nexball_TeleportationForbiddenFor;
	entity_initialize(world, nexball_delayedinit, INITPRIO_GAMETYPE);
	precache_model ("models/elaser.mdl");
	precache_sound ("nexball/shoot1.wav");
	precache_sound ("nexball/shoot2.wav");
}

//works only if there are two teams on the map!
float(float t) nexball_other_team {
	entity e;
	e = find(world, classname, "nexball_team");
	if (e.team == t)
		e = find(e, classname, "nexball_team");

	return e.team;
}

void(void) nexball_ball_restart {
	if(self.owner)
		nexball_drop_ball(self, self.owner.origin, '0 0 0');

	nexball_ball_reset();
}

void(void) nexball_PlayerPreThink {
	entity oldself;
	self.items &~= IT_KEY1;
	if (self.ballcarried) {
		if (self.ballcarried.teamtime && (self.ballcarried.teamtime < time)) {
			bprint("The ", team_colored_name(self.team), " held the ball for too long.\n");
			oldself = self;
			self = self.ballcarried;
			nexball_drop_ball(self, self.owner.origin, '0 0 0');
			nexball_ball_reset();
			self = oldself;
		} else
			self.items |= IT_KEY1;
	}
	nexball_PlayerPreThink_NextLink();
}

void(void) nexball_relocate {
	trace_box(self.origin, BALL_MINS * g_nexball_ball_scale, BALL_MAXS * g_nexball_ball_scale, self.origin, TRUE, self);
	if (trace_startsolid) {
		vector o;
		o = self.origin;
		if(!entity_move_out_of_solid(self))
			entity_abort("could not get out of solid at all!");

		print("^1NOTE: this map needs FIXING. ", self.classname, " at ", vtos(o - '0 0 1'));
		print(" needs to be moved out of solid, e.g. by '", ftos(self.origin_x - o_x));
		print(" ", ftos(self.origin_y - o_y));
		print(" ", ftos(self.origin_z - o_z), "'\n");
		self.origin = o;
	}
}

void(void) nexball_drop_owner {
	entity ownr;
	ownr = self.owner;
	nexball_drop_ball(self, ownr.origin, ownr.velocity);
	makevectors(ownr.v_angle_y * '0 1 0');
	ownr.velocity += ('0 0 0.75' - v_forward) * 1000;
	ownr.flags &~= FL_ONGROUND;
}

void(entity plyr, entity ball) nexball_give_ball {
	entity ownr;
	if ((ownr = ball.owner)) {
		ownr.effects &~= g_nexball_basketball_effects_default;
		ownr.ballcarried = world;
		if (ownr.metertime)
			ownr.metertime_stat = ownr.metertime = 0;

		WaypointSprite_Kill(ownr.waypointsprite_attachedforcarrier);
	} else {
		WaypointSprite_Kill(ball.waypointsprite_attachedforcarrier);
	}
	float tag_found;
	if((tag_found = gettagindex(plyr, "tag_weapon"))) {
		ball.tag_index = tag_found;
		ball.tag_entity = self.owner;
	} else
		setattachment(ball, plyr, "bip01 r hand");

	setorigin(ball, BALL_ATTACHORG);
	plyr.pov_ball = spawn();
	plyr.pov_ball.owner = plyr;
	plyr.pov_ball.solid = SOLID_NOT;
	plyr.pov_ball.classname = "pov_ball";
	plyr.pov_ball.customizeentityforclient = weapon_model_customize;
	plyr.pov_ball.viewmodelforclient = plyr;
	setmodel(plyr.pov_ball, ball.model);
	setorigin(plyr.pov_ball, BALL_POV);
	if (ball.team != plyr.team)
		ball.teamtime = time + g_nexball_basketball_delay_hold_forteam;

	ball.owner = ball.pusher = plyr; //"owner" is set to the player carrying, "pusher" to the last player who touched it
	ball.team = plyr.team;
	plyr.ballcarried = ball;
	ball.dropperid = plyr.playerid;
	plyr.effects |= g_nexball_basketball_effects_default;
	ball.effects &~= g_nexball_basketball_effects_default;
	ball.velocity = '0 0 0';
	ball.movetype = MOVETYPE_NONE;
	ball.touch = stdproc_nothing;
	ball.effects |= EF_NOSHADOW;
	ball.scale = 1; // scale down.
	WaypointSprite_AttachCarrier("nb-ball", plyr);
	WaypointSprite_UpdateRule(plyr.waypointsprite_attachedforcarrier, 0, SPRITERULE_DEFAULT);
	WaypointSprite_UpdateTeamRadar(plyr.waypointsprite_attachedforcarrier, RADARICON_FLAGCARRIER, BALL_SPRITECOLOR);
	if (g_nexball_basketball_delay_hold) {
		ball.think = nexball_drop_owner;
		ball.nextthink = time + g_nexball_basketball_delay_hold;
	}
}

void(entity ball, vector org, vector vel) nexball_drop_ball {
	ball.effects |= g_nexball_basketball_effects_default;
	ball.effects &~= EF_NOSHADOW;
	ball.owner.effects &~= g_nexball_basketball_effects_default;
	setattachment(ball, world, "");
	setorigin (ball, org);
	ball.movetype = MOVETYPE_BOUNCE;
	ball.flags &~= FL_ONGROUND;
	ball.scale = ball_scale;
	ball.velocity = vel;
	ball.ctf_droptime = time;
	ball.touch = nexball_basketball_touch;
	ball.think = nexball_ball_reset;
	ball.nextthink = min(time + g_nexball_delay_idle, ball.teamtime);
	if (ball.owner.metertime)
		ball.owner.metertime_stat = ball.owner.metertime = 0;

	WaypointSprite_Kill(ball.owner.waypointsprite_attachedforcarrier);
	WaypointSprite_AttachCarrier("nb-ball", ball);
	WaypointSprite_UpdateRule(ball.waypointsprite_attachedforcarrier, 0, SPRITERULE_DEFAULT);
	WaypointSprite_UpdateTeamRadar(ball.waypointsprite_attachedforcarrier, RADARICON_FLAGCARRIER, BALL_SPRITECOLOR);
	remove(ball.owner.pov_ball);
	ball.owner.pov_ball = world;
	ball.owner.ballcarried = world;
	ball.owner = world;
}

void(void) nexball_ball_init {
	if (map_finished) return;
	self.flags &~= FL_ONGROUND;
	if (self.classname == "nexball_hockey")
		self.movetype = MOVETYPE_BOUNCEMISSILE;
	else
		self.movetype = MOVETYPE_BOUNCE;
	if (self.classname == "nexball_basketball")
		self.touch = nexball_basketball_touch;
	else if (self.classname == "nexball_football")
		self.touch = nexball_football_touch;
	else if (self.classname == "nexball_hockey")
	{
		self.touch = nexball_hockey_touch;
	}
	self.solid = SOLID_TRIGGER;
	setmodel(self, self.mdl);
	setsize(self, BALL_MINS * g_nexball_ball_scale, BALL_MAXS * g_nexball_ball_scale);
	self.cnt = 0;
	self.think = nexball_ball_reset;
	self.nextthink = time + g_nexball_delay_idle + 3;
	self.teamtime = 0;
	self.pusher = world;
	self.team = FALSE;
	sound (self, CHAN_PROJECTILE, self.noise1, VOL_BASE, ATTN_NORM);
	WaypointSprite_Ping(self.waypointsprite_attachedforcarrier);
}

void(void) nexball_ball_reset {
	if (self.cnt < 2) { // step 1
		if (time == self.teamtime)
			bprint("The ", team_colored_name(self.team), " held the ball for too long.\n");
		self.touch = stdproc_nothing;
		self.movetype = MOVETYPE_NOCLIP;
		self.velocity = '0 0 0'; // just in case?
		self.cnt = 2;
		self.nextthink = time;
	} else if (self.cnt < 4) { // step 2 and 3
		self.velocity = (self.spawnorigin - self.origin) * (self.cnt - 1); // 1 or 0.5 second movement
		self.nextthink = time + 0.5;
		self.cnt += 1;
	} else { // step 4
		self.velocity = '0 0 0';
		setorigin(self, self.spawnorigin); // make sure it's positioned correctly anyway
		self.movetype = MOVETYPE_NONE;
		self.think = nexball_ball_init;
		self.nextthink = max(time, map_starttime) + g_nexball_delay_start;
	}
}

void(void) nexball_football_touch {
	if (other.solid == SOLID_BSP) {
		if (time > self.lastground + 0.1)
		{
			sound (self, CHAN_PROJECTILE, self.noise, VOL_BASE, ATTN_NORM);
			self.lastground = time;
		}
		if (vlen(self.velocity) && !self.cnt)
			self.nextthink = time + g_nexball_delay_idle;
		return;
	}
	if (other.classname != "player")
		return;
	if (other.health < 1)
		return;
	if (!self.cnt)
		self.nextthink = time + g_nexball_delay_idle;

	self.pusher = other;
	self.team = other.team;

	if (g_nexball_football_physics == -1) { // MrBougo try 1, before decompiling Rev's original
		if (vlen(other.velocity))
			self.velocity = other.velocity * 1.5 + '0 0 1' * g_nexball_football_boost_up;
	} else if (g_nexball_football_physics == 1) { // MrBougo's modded Rev style: partially independant of the height of the aiming point
		makevectors(other.v_angle);
		self.velocity = other.velocity + v_forward * g_nexball_football_boost_forward + '0 0 1' * g_nexball_football_boost_up;
	} else if (g_nexball_football_physics == 2) { // 2nd mod try: totally independant. Really playable!
		makevectors(other.v_angle_y * '0 1 0');
		self.velocity = other.velocity + v_forward * g_nexball_football_boost_forward + v_up * g_nexball_football_boost_up;
	} else { // Revenant's original style (from the original mod's disassembly, acknowledged by Revenant)
		makevectors(other.v_angle);
		self.velocity = other.velocity + v_forward * g_nexball_football_boost_forward + v_up * g_nexball_football_boost_up;
	}
	if (other.weaponentity.wframe == WFRAME_MELEE || other.weaponentity.wframe == WFRAME_MELEE2 || (other.weapon == WEP_MELEE && other.weaponentity.wframe == WFRAME_FIRE1))
	{
		makevectors(other.v_angle);
		self.velocity = self.velocity + v_forward * g_nexball_football_melee_boost_forward + v_up * g_nexball_football_melee_boost_up;
	}
	self.avelocity = -250 * v_forward;  // maybe there is a way to make it look better?
}

void(void) nexball_hockey_touch {
	if (other.solid == SOLID_BSP) {
		self.velocity_z = 0;
		self.velocity_x = self.velocity_x * g_nexball_hockey_bouncefactor;
		self.velocity_y = self.velocity_y * g_nexball_hockey_bouncefactor;
		if (time > self.lastground + 0.1)
		{
			sound (self, CHAN_PROJECTILE, self.noise, VOL_BASE, ATTN_NORM);
			self.lastground = time;
		}
		return;
	}
	if (other.classname != "player")
		return;
	if (other.health < 1)
		return;
	if (!self.cnt)
		self.nextthink = time + g_nexball_delay_idle;

	self.pusher = other;
	self.team = other.team;

	makevectors(other.v_angle_y * '0 1 0');
	self.velocity = other.velocity + v_forward * g_nexball_hockey_boost_forward;
	self.velocity_z = 0;
	if (other.weaponentity.wframe == WFRAME_MELEE || other.weaponentity.wframe == WFRAME_MELEE2 || (other.weapon == WEP_MELEE && other.weaponentity.wframe == WFRAME_FIRE1))
	{
		self.velocity = self.velocity + v_forward * g_nexball_hockey_melee_boost_forward;
		self.velocity_z = g_nexball_hockey_melee_boost_up;
	}
	self.avelocity = '0 -180 0' + ('0 360 0' * random());
}

void(void) nexball_basketball_touch {
	if (other.ballcarried || !GameHookChain_PlayerCanBeCarrier(other)) {
		nexball_football_touch();
		return;
	}
	if (!self.cnt && other.classname == "player" && (other.playerid != self.dropperid || time > self.ctf_droptime + g_nexball_delay_collect)) {
		if (other.health <= 0)
			return;
		nexball_give_ball(other, self);
	} else if (other.solid == SOLID_BSP) {
		sound (self, CHAN_PROJECTILE, self.noise, VOL_BASE, ATTN_NORM);
		if (vlen(self.velocity) && !self.cnt)
			self.nextthink = min(time + g_nexball_delay_idle, self.teamtime);
	}
}

void(void) nexball_goal_touch {
	entity ball;
	float isclient, pscore, otherteam;
	string pname;
	if (map_finished) return;
	if ((self.spawnflags & GOAL_TOUCHPLAYER) && other.ballcarried)
		ball = other.ballcarried;
	else
		ball = other;

	if (ball.classname != "nexball_basketball")
	if (ball.classname != "nexball_football")
	if (ball.classname != "nexball_hockey")
		return;

	if ((!ball.pusher && self.team != GOAL_OUT) || ball.cnt)
		return;

	EXACTTRIGGER_TOUCH;
	if(nexball_teams == 2)
		otherteam = nexball_other_team(ball.team);

	if((isclient = ball.pusher.flags & FL_CLIENT))
		pname = ball.pusher.netname;
	else
		pname = "Someone (?)";

	if (ball.team == self.team) {
		bprint("Boo! ", pname, "^7 scored a goal against his own team!\n");
		pscore = -1;
	} else if (self.team == GOAL_FAULT) {
		if (nexball_teams == 2)
			bprint(team_colored_name(otherteam), " gets a point due to ", pname, "^7's silliness.\n");
		else
			bprint(team_colored_name(ball.team), " loses a point due to ", pname, "^7's silliness.\n");

		pscore = -1;
	} else if (self.team == GOAL_OUT) {
		if ((self.spawnflags & GOAL_TOUCHPLAYER) && ball.owner)
			bprint(pname, "^7 went out of bounds.\n");
		else
			bprint("The ball was returned.\n");

		pscore = 0;
	} else {                           //score
		bprint("Goaaaaal! ", pname, "^7 scored a point for the ", team_colored_name(ball.team), ".\n");
		pscore = 1;
	}
	sound (ball, CHAN_AUTO, self.noise, VOL_BASE, ATTN_NONE);
	if(ball.team && pscore) {
		if (nexball_teams == 2 && pscore < 0) {
			GameStatus_Set(strcat(team_color_code(otherteam), team_color_name(otherteam), " Team^7 scores"), 1);
			score_team_add_to(otherteam, ST_NEXBALL_GOALS, -pscore);
		} else {
			GameStatus_Set(strcat(team_color_code(ball.team), team_color_name(ball.team), " Team^7 scores"), 1);
			score_team_add_to(ball.team, ST_NEXBALL_GOALS, pscore);
		}
	}
	if (isclient) {
		if (pscore > 0)
			score_player_add(ball.pusher, SP_NEXBALL_GOALS, pscore);
		else if (pscore < 0)
			score_player_add(ball.pusher, SP_NEXBALL_FAULTS, -pscore);
	}
	if (ball.owner) // Happens on spawnflag GOAL_TOUCHPLAYER
		nexball_drop_ball(ball, ball.owner.origin, ball.owner.velocity);

	WaypointSprite_Ping(ball.waypointsprite_attachedforcarrier);
	ball.cnt = 1;
	ball.think = nexball_ball_reset;
	if (ball.classname == "nexball_basketball")
		ball.touch = nexball_football_touch; // better than stdproc_nothing: football control until the ball gets reset

	ball.nextthink = time + g_nexball_delay_goal * (self.team != GOAL_OUT);
	if (ball.explosive) {
		float i;
		vector expl_orig;
		entity temp;
		damage_radius(ball, ball.pusher, g_nexball_ball_explosive_damage, 0, g_nexball_ball_explosive_radius, ball, g_nexball_ball_explosive_force, DEATH_HURTTRIGGER, world);
		for (i = 0; i < 16; i++)
		{
			expl_orig = ball.origin + '-100 -100 0' + random() * '200 0 0' + random() * '0 200 0' + random() * '0 0 200';
			pointparticles(particleeffectnum("rocket_explode"), expl_orig, '0 0 0', 1);
			temp = spawn();
			setorigin(temp, expl_orig);
			sound(temp, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
			remove(temp);
		}
		ball.cnt = 4;
		ball.solid = SOLID_NOT;
		setmodel(ball, "");
		ball.velocity = '0 0 0';
	}
}

void(void) spawnfunc_nexball_team {
	if (game != GAME_NEXBALL) {
		remove(self);
		return;
	}
	self.team = self.cnt + 1;
	team_teams_set_allowed(self.team);
}

void(string teamname, float teamcolor) nexball_spawnteam {
	entity e;
	e = spawn();
	e.classname = "nexball_team";
	e.netname = teamname;
	e.cnt = teamcolor;
	entity oldself = self;
	self = e;
	spawnfunc_nexball_team();
	self = oldself;
}

void(void) nexball_spawnteams {
	float t_r, t_b, t_y, t_p;
	entity e;
	for(e = world; (e = find(e, classname, "nexball_goal")); )
	{
		switch(e.team)
		{
			case COLOR_TEAM1: if(!t_r) { nexball_spawnteam ("Red", e.team-1)   ; t_r = 1; } break;
			case COLOR_TEAM2: if(!t_b) { nexball_spawnteam ("Blue", e.team-1)  ; t_b = 1; } break;
			case COLOR_TEAM3: if(!t_y) { nexball_spawnteam ("Yellow", e.team-1); t_y = 1; } break;
			case COLOR_TEAM4: if(!t_p) { nexball_spawnteam ("Pink", e.team-1)  ; t_p = 1; } break;
		}
	}
}

void(void) nexball_delayedinit {
	if (find(world, classname, "nexball_team") == world)
		nexball_spawnteams();

	team_teams_allowed(world);
	nexball_teams = 4 + team1 + team2 + team3 + team4;
	score_basics(0, 0, TRUE);
	ST_NEXBALL_GOALS = score_register_team_score("goals", SFL_SORT_PRIO_PRIMARY);
	SP_NEXBALL_GOALS = score_register("goals", SFL_SORT_PRIO_PRIMARY);
	SP_NEXBALL_FAULTS = score_register("faults", SFL_SORT_PRIO_SECONDARY | SFL_LOWER_IS_BETTER);
}

//=======================//
//      spawnfuncs       //
//=======================//

void(void) nexball_spawn_ball {
	if (game != GAME_NEXBALL) {
		remove(self);
		return;
	}
	if (!self.model) {
		self.model = "models/nexball/ball.md3";
		self.scale = 1.3;
	}
	self.scale *= g_nexball_ball_scale;
	precache_model (self.model);
	setmodel (self, self.model);
	self.mdl = self.model;
	ball_scale = self.scale;
	nexball_relocate();
	self.spawnorigin = self.origin;
	self.effects = self.effects | EF_LOWPRECISION;
	if (cvar(strcat("g_", self.classname, "_trail"))) {
		self.glow_color = cvar("g_nexball_trail_color");
		self.glow_trail = TRUE;
	}
	self.movetype = MOVETYPE_FLY;
	if (!cvar("g_nexball_sound_bounce"))
		self.noise = "";
	else if (!self.noise)
		self.noise = "sound/nexball/bounce.wav";

	if (!self.noise1)
		self.noise1 = "sound/nexball/drop.wav";

	if (!self.noise2)
		self.noise2 = "sound/nexball/steal.wav";

	if (self.noise)
		precache_sound (self.noise);

	precache_sound (self.noise1);
	precache_sound (self.noise2);
	WaypointSprite_AttachCarrier("nb-ball", self); // the ball's team is not set yet, no rule update needed
	WaypointSprite_UpdateTeamRadar(self.waypointsprite_attachedforcarrier, RADARICON_FLAGCARRIER, BALL_SPRITECOLOR);
	self.reset = nexball_ball_restart;
	self.think = nexball_ball_init;
	self.nextthink = map_starttime + g_nexball_delay_start;
	self.bot_pickup = TRUE;
	self.bot_pickupevalfunc = item_generic_pickupevalfunc;
	self.bot_pickupbasevalue = BOT_PICKUP_RATING_HIGH;
}

void(void) spawnfunc_nexball_basketball {
	self.classname = "nexball_basketball";
	if not(balls & BALL_BASKET)
	{
		CACHE_CVAR(g_nexball_basketball_effects_default);
		CACHE_CVAR(g_nexball_basketball_delay_hold);
		CACHE_CVAR(g_nexball_basketball_delay_hold_forteam);
		CACHE_CVAR(g_nexball_basketball_teamsteal);
		g_nexball_basketball_effects_default = g_nexball_basketball_effects_default & BALL_EFFECTMASK;
	}
	if (!self.effects)
		self.effects = g_nexball_basketball_effects_default;
	self.solid = SOLID_TRIGGER;
	balls |= BALL_BASKET;
	self.bouncefactor = cvar("g_nexball_basketball_bouncefactor");
	self.bouncestop = cvar("g_nexball_basketball_bouncestop");
	nexball_spawn_ball();
}

void(void) spawnfunc_nexball_football {
	self.classname = "nexball_football";
	self.solid = SOLID_TRIGGER;
	balls |= BALL_FOOT;
	self.bouncefactor = cvar("g_nexball_football_bouncefactor");
	self.bouncestop = cvar("g_nexball_football_bouncestop");
	nexball_spawn_ball();
}

void(void) hockey_physic_controller_think {
	self.nextthink = time;
	if (self.ballcarried.cnt)
		return;
	trace_box(self.ballcarried.origin, BALL_MINS * g_nexball_ball_scale, BALL_MAXS * g_nexball_ball_scale, self.ballcarried.origin + '0 0 -1', MOVE_WORLDONLY, world);
	if (trace_fraction == 1)
	{
		self.ballcarried.velocity_z -= sv_gravity * frametime;
		setorigin(self.ballcarried, self.ballcarried.origin);
	}
}

.entity hockey_physic_controller;
void(void) spawnfunc_nexball_hockey {
	self.classname = "nexball_hockey";
	self.solid = SOLID_TRIGGER;
	balls |= BALL_HOCKEY;
	self.hockey_physic_controller = spawn();
	self.hockey_physic_controller.ballcarried = self;
	self.hockey_physic_controller.think = hockey_physic_controller_think;
	self.hockey_physic_controller.nextthink = time;
	self.cnt = 4;
	nexball_spawn_ball();
}

void(void) nexball_spawn_goal {
	if (game != GAME_NEXBALL) {
		remove(self);
		return;
	}
	EXACTTRIGGER_INIT;
	self.classname = "nexball_goal";
	if (!self.noise)
		self.noise = "ctf/respawn.wav";
	precache_sound(self.noise);
	self.touch = nexball_goal_touch;
}

void(void) spawnfunc_nexball_redgoal {
	self.team = COLOR_TEAM1;
	nexball_spawn_goal();
}

void(void) spawnfunc_nexball_bluegoal {
	self.team = COLOR_TEAM2;
	nexball_spawn_goal();
}

void(void) spawnfunc_nexball_yellowgoal {
	self.team = COLOR_TEAM3;
	nexball_spawn_goal();
}

void(void) spawnfunc_nexball_pinkgoal {
	self.team = COLOR_TEAM4;
	nexball_spawn_goal();
}

void(void) spawnfunc_nexball_fault {
	self.team = GOAL_FAULT;
	if (!self.noise)
		self.noise = "misc/typehit.wav";
	nexball_spawn_goal();
}

void(void) spawnfunc_nexball_out {
	self.team = GOAL_OUT;
	if (!self.noise)
		self.noise = "misc/typehit.wav";

	nexball_spawn_goal();
}

void(float t) nexball_carrier_attack {
	entity ball;
	float mul, mi, ma;
	if (!(ball = self.ballcarried))
		return;

	weapon_setup_shot (self, 4, "nexball/shoot1.wav",0);
	trace_box(weapon_shotorg, BALL_MINS * g_nexball_ball_scale, BALL_MAXS * g_nexball_ball_scale, weapon_shotorg, MOVE_WORLDONLY, world);
	if(trace_startsolid) {
		if(self.metertime)
			self.metertime = 0; // Shot failed, hide the power meter
		return;
	}
	//Calculate multiplier
	if (t < 0)
		mul = 1;
	else {
		mi = g_nexball_basketball_meter_minpower;
		ma = max(mi, g_nexball_basketball_meter_maxpower); // avoid confusion
		//One triangle wave period with 1 as max
		mul = 2 * math_mod(t, g_nexball_meter_period) / g_nexball_meter_period;
		if (mul > 1)
			mul = 2 - mul;
		mul = mi + (ma - mi) * mul; // range from the minimal power to the maximal power
	}
	nexball_drop_ball (ball, weapon_shotorg, weapon_calculate_projectile_velocity(self.velocity, weapon_shotdir * g_nexball_primary_speed * mul));
	//TODO: use the speed_up cvar too ??
}

float nexball_carrier_think() {
	if (self.BUTTON_ATCK || self.BUTTON_ATCK2)
	{
		if (g_nexball_basketball_meter)
		{
			if (!self.metertime)
				self.metertime = time;
		} else
			nexball_carrier_attack(-1);
	}
	if (self.metertime) {
		self.metertime_stat = (time - self.metertime) / g_nexball_meter_period;
		self.metertime_stat = (self.metertime_stat - floor(self.metertime_stat)) * 2;
		if (!self.BUTTON_ATCK ||
				(g_nexball_primary_shootatmaxmeter && self.metertime + (g_nexball_meter_period / 2) < time))

			nexball_carrier_attack(time - self.metertime);
	}
	// nexball_drop_ball or stealing will set metertime back to 0
	return TRUE;
}

void() spawnfunc_nexball_redbase {
	if (game == GAME_NEXBALL)
		WaypointSprite_SpawnFixed("redbase", self.origin + '0 0 37', self, sprite);
	else
		remove(self);
}

void() spawnfunc_nexball_bluebase {
	if (game == GAME_NEXBALL)
		WaypointSprite_SpawnFixed("bluebase", self.origin + '0 0 37', self, sprite);
	else
		remove(self);
}
