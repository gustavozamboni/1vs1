.float spawntime;
.vector trail_oldorigin;
.float trail_oldtime;
.vector server_angles;
.float use_server_angles;

void(void) projectile_touch_stop {
	self.move_velocity = self.move_avelocity = '0 0 0';
	self.move_movetype = MOVETYPE_NONE;
}

.float count; // set if clientside projectile
.float cnt; // sound index
.float gravity;
.float snd_looping;
.float silent;

void projectile_colormap_setup(float default_team) {
    if not(team_mode)
        self.team = default_team;

    self.colormap = 1024 + (self.team - 1) * 17;
}

.float nextparticle;
void(vector to) projectile_trail_draw {
	vector from;
	float t0;
	from = self.trail_oldorigin;
	t0 = self.trail_oldtime;
	self.trail_oldorigin = to;
	self.trail_oldtime = time;
	if (from == to) {
		switch (self.cnt) {
		case PROJECTILE_HG_NAPALMSHARD:
			goto flame;
		case PROJECTILE_HG_NAPALM:
		case PROJECTILE_FIREMINE:
			to_z += 1;
			break;
		case PROJECTILE_HG_TRANSLOC:
			to = from = self.origin;
			to_z += 1;
			break;
		case PROJECTILE_ELECTRO:
			trailparticles(self, particleeffectnum("TR_NEXUIZPLASMA"), from, to);
			return;
		case PROJECTILE_HG_PLASMA_SHARD:
			trailparticles(self, particles_rm_effectnum_team("RM_HG_PLASMA", self.team, 2), from, to);
			return;
		case PROJECTILE_HG_RAZE:
		case PROJECTILE_HG_PLASMA:
			break;
		default:
			return;
		}
	}
	switch (self.cnt) {
	case PROJECTILE_ROCKET:
		trailparticles(self, particleeffectnum("TR_ROCKET"), from, to);
		break;
	case PROJECTILE_CRYLINK:
		trailparticles(self, particleeffectnum("TR_CRYLINKPLASMA"), from, to);
		break;
	case PROJECTILE_CRYLINK_BOUNCING:
		trailparticles(self, particleeffectnum("TR_CRYLINKPLASMA"), from, to);
		break;
	case PROJECTILE_ELECTRO:
		trailparticles(self, particleeffectnum("TR_NEXUIZPLASMA"), from, to);
		break;
	case PROJECTILE_HG_PLASMA_SHARD:
		trailparticles(self, particles_rm_effectnum_team("RM_HG_PLASMA", self.team, 2), from, to);
		break;
	case PROJECTILE_ELECTRO_BEAM:
		trailparticles(self, particleeffectnum("TR_NEXUIZPLASMA"), from, to);
		break;
	case PROJECTILE_RM_LASER:
		switch (self.team) {
		case COLOR_TEAM2:
			trailparticles(self, particleeffectnum("TE_TEI_G3BLUE_HIT"), from, to);
			break;
		case COLOR_TEAM3:
			trailparticles(self, particleeffectnum("TE_TEI_G3YELLOW_HIT"), from, to);
			break;
		case COLOR_TEAM4:
			trailparticles(self, particleeffectnum("TE_TEI_G3PINK_HIT"), from, to);
			break;
		default:
			trailparticles(self, particleeffectnum("TE_TEI_G3RED_HIT"), from, to);
			break;
		}
		break;
	case PROJECTILE_GRENADE:
		trailparticles(self, particleeffectnum("TR_KNIGHTSPIKE"), from, to);
		break;
	case PROJECTILE_GRENADE_BOUNCING:
		trailparticles(self, particleeffectnum("TR_KNIGHTSPIKE"), from, to);
		break;
	case PROJECTILE_PORTO_RED:
		trailparticles(self, particleeffectnum("TR_WIZSPIKE"), from, to);
		break;
	case PROJECTILE_PORTO_BLUE:
		trailparticles(self, particleeffectnum("TR_WIZSPIKE"), from, to);
		break;
	case PROJECTILE_HOOKBOMB:
		trailparticles(self, particleeffectnum("TR_KNIGHTSPIKE"), from, to);
		break;
	case PROJECTILE_HAGAR:
		trailparticles(self, particleeffectnum("TR_GRENADE"), from, to);
		break;
	case PROJECTILE_HAGAR_BOUNCING:
		trailparticles(self, particleeffectnum("TR_GRENADE"), from, to);
		break;
	case PROJECTILE_BULLET:
		trailparticles(self, particleeffectnum("tr_bullet"), from, to);
		break;
	case PROJECTILE_BULLET_GLOWING:
		trailparticles(self, particleeffectnum("tr_rifle"), from, to);
		break;
	case PROJECTILE_FIREMINE:
		trailparticles(self, particleeffectnum("firemine"), from, to);
		break;
	case PROJECTILE_FIREBALL:
		trailparticles(self, particleeffectnum("fireball"), from, to);
		break;
	case PROJECTILE_HG_PLASMA:
		trailparticles(self, particles_rm_effectnum_team("RM_HG_PLASMA", self.team, 2), from, to);
		break;
	case PROJECTILE_HG_LASER: case PROJECTILE_HG_RAZE:
		trailparticles(self, particles_rm_effectnum_team("RM_HG_PLASMA", self.team, 1), from, to);
		break;
	case PROJECTILE_HG_TRANSLOC:
		switch (self.team) {
			case COLOR_TEAM1:           trailparticles(self, particleeffectnum("TE_TEI_G3RED_HIT"),     from, to); break;
			case COLOR_TEAM2:           trailparticles(self, particleeffectnum("TE_TEI_G3BLUE_HIT"),    from, to); break;
			case COLOR_TEAM3:           trailparticles(self, particleeffectnum("TE_TEI_G3YELLOW_HIT"),  from, to); break;
			case COLOR_TEAM4: default:  trailparticles(self, particleeffectnum("TE_TEI_G3PINK_HIT"),    from, to); break;
		}
		break;
	case PROJECTILE_HG_NAPALMSHARD:
		trailparticles(self, particles_rm_effectnum_team("RM_HG_NAPALM_TRAIL", self.team, 1), from, to);
:flame
		vector v = randomvec();
		v_z = (v_z + 1) * 0.25;
		if (time >= self.nextparticle) {
			pointparticles(particles_rm_effectnum_team("RM_HG_NAPALM_FIRE", self.team, 1), self.origin + v/* * self.extradata * 0.7 */, '0 0 0', 1);
			self.nextparticle = time + 0.15 + random() * 0.10;
		}
		break;
	default:
		break;
	}
}

void(void) projectile_draw {
	vector rot;
	vector trailorigin;
	float f;
	float drawn;
	float t;
	f = self.move_flags;
	if (self.count & 0x80) {
		//self.move_flags &~= FL_ONGROUND;
		Movetype_Physics_MatchServer();
		if (!(self.move_flags & FL_ONGROUND))
			self.angles = vectoangles(self.velocity);
	} else {
		InterpolateOrigin_Do();
		if (self.use_server_angles) {
			self.angles = self.server_angles;
		} else if (self.cnt == PROJECTILE_HG_RAZE) {
			self.angles_x = -90;
		}
	}
	if (self.count & 0x80) {
		drawn = (time >= self.spawntime - 0.02);
		t = max(time, self.spawntime);
	} else {
		drawn = (self.iflags & IFLAG_VALID);
		t = time;
	}
	if ((!(f & FL_ONGROUND) || self.cnt == PROJECTILE_HG_RAZE) && !self.use_server_angles) {
		rot = '0 0 0';
		switch (self.cnt) {
		/*
		case PROJECTILE_GRENADE:
			rot = '-2000 0 0'; // forward
			break;
		*/
		case PROJECTILE_GRENADE_BOUNCING:
			rot = '0 -1000 0'; // sideways
			break;
		case PROJECTILE_HG_GENERIC:
		case PROJECTILE_HG_NAPALM:
			rot = '0 1000 0'; // sideways
			break;
		case PROJECTILE_HOOKBOMB:
			rot = '1000 0 0'; // forward
			break;
		case PROJECTILE_HG_TRANSLOC:
			rot = '700 643 721';
			break;
		case PROJECTILE_HG_RAZE:
		case PROJECTILE_HG_PLASMA:
			rot = '0 0 -1000';
			break;
		default:
			break;
		}
		self.angles = AnglesTransform_Multiply(self.angles, rot * (t - self.spawntime));
	}
	makevectors(self.angles);
	trailorigin = self.origin;
	switch (self.cnt) {
	case PROJECTILE_GRENADE:
	case PROJECTILE_GRENADE_BOUNCING:
		trailorigin += v_right * 1 + v_forward * -10;
		break;
	default:
		break;
	}
	if (drawn)
		projectile_trail_draw(trailorigin);
	else {
		self.trail_oldorigin = trailorigin;
		self.trail_oldtime = time;
	}
	if (!drawn)
		return;

	self.renderflags = 0;
	R_AddEntity(self);
}

void(entity e, float ch, string samp, float vol, float attn) projectile_loopsound {
	if (self.silent)
		return;

	sound(e, ch, samp, vol, attn);
	e.snd_looping = 1;
}

void(void) projectile_remove {
	if (self.snd_looping)
		sound(self, CHAN_PROJECTILE, "misc/null.wav", VOL_BASE, ATTN_NORM);

	if (self.count & 0x80) {
		tracebox(self.origin, self.mins, self.maxs, self.origin + self.velocity * 0.05, MOVE_NORMAL, self);
		projectile_trail_draw(trace_endpos);
	}
}

void(float ignore) projectile_read {
	float f;
	// projectile properties:
	//   kind (interpolated, or clientside)
	//
	//   modelindex
	//   origin
	//   scale
	//   if clientside:
	//     velocity
	//     gravity
	//   soundindex (hardcoded list)
	//   effects
	//
	// projectiles don't send angles, because they always follow the velocity
	f = ReadByte();
	self.count = (f & 0x80);
	self.iflags = (self.iflags & IFLAG_INTERNALMASK);
    if (!self.use_server_angles)
        self.iflags |= IFLAG_ANGLES | IFLAG_AUTOANGLES;

	self.solid = SOLID_TRIGGER;
	//self.effects = EF_NOMODELFLAGS;
	// this should make collisions with bmodels more exact, but it leads to
	// projectiles no longer being able to lie on a bmodel
	self.move_nomonsters = MOVE_WORLDONLY;
	if (f & 0x40)
		self.move_flags |= FL_ONGROUND;
	else
		self.move_flags &~= FL_ONGROUND;

	if (!self.move_time) {
		// for some unknown reason, we don't need to care for
		// sv_gameplayfix_delayprojectiles here.
		self.move_time = time;
		self.spawntime = time;
	} else
		self.move_time = max(self.move_time, time);

	if (!(self.count & 0x80))
		InterpolateOrigin_Undo();

	if (f & 1) {
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		if (self.count & 0x80) {
			self.velocity_x = ReadCoord();
			self.velocity_y = ReadCoord();
			self.velocity_z = ReadCoord();
			self.gravity = ReadCoord();

			self.move_origin = self.origin;
			self.move_velocity = self.velocity;
		}
		if (time == self.spawntime || (self.count & 0x80)) {
			self.trail_oldorigin = self.origin;
		}
		if (f & 0x20)
		if not(f & 0x80) {
			self.trail_oldorigin = self.origin;
			InterpolateOrigin_Note();
		}
	}
	if (f & 2) {
		self.cnt = ReadByte();
		if (f & 16) {
			self.team = ReadChar();
		} else {
			self.team = 0;
		}
		self.silent = (self.cnt & 0x80);
		self.cnt = (self.cnt & 0x7F);
		self.scale = 1;
		switch (self.cnt) {
		case PROJECTILE_ELECTRO: setmodel(self, "models/ebomb.mdl"); break;
		case PROJECTILE_ROCKET: setmodel(self, "models/rocket.md3"); self.scale = 2; break;
		case PROJECTILE_BULLET: setmodel(self, "models/tracer.mdl"); break;
		case PROJECTILE_BULLET_GLOWING: setmodel(self, "models/tracer.mdl"); break;
		case PROJECTILE_CRYLINK: setmodel(self, "models/plasmatrail.mdl"); break;
		case PROJECTILE_CRYLINK_BOUNCING: setmodel(self, "models/plasmatrail.mdl"); break;
		case PROJECTILE_ELECTRO_BEAM:
		case PROJECTILE_RM_LASER:
			setmodel(self, "models/elaser.mdl"); break;
		case PROJECTILE_GRENADE:
		case PROJECTILE_GRENADE_BOUNCING: setmodel(self, "models/grenademodel.md3"); break;
		case PROJECTILE_LASER: setmodel(self, "models/laser.mdl"); break;
		case PROJECTILE_HLAC: setmodel(self, "models/hlac_bullet.md3"); break;
		case PROJECTILE_PORTO_RED: setmodel(self, "models/grenademodel.md3"); self.scale = 4; break;
		case PROJECTILE_PORTO_BLUE: setmodel(self, "models/grenademodel.md3"); self.scale = 4; break;
		case PROJECTILE_HOOKBOMB: setmodel(self, "models/grenademodel.md3"); break;
		case PROJECTILE_HAGAR: setmodel(self, "models/hagarmissile.mdl"); self.scale = 0.4; break;
		case PROJECTILE_HAGAR_BOUNCING: setmodel(self, "models/hagarmissile.mdl"); self.scale = 0.4; break;
		case PROJECTILE_FIREBALL: self.model = ""; self.modelindex = 0; break; // particle effect is good enough
		case PROJECTILE_FIREMINE: self.model = ""; self.modelindex = 0; break; // particle effect is good enough
		case PROJECTILE_BULLET_BIG: setmodel(self, "models/tracer.mdl"); self.scale = 3; break;
		case PROJECTILE_HG_NAPALMSHARD: self.model = ""; self.modelindex = 0; break;
		case PROJECTILE_HG_GENERIC: case PROJECTILE_HG_NAPALM:
			setmodel(self, "models/handgrenade.iqm");
			projectile_colormap_setup(COLOR_TEAM1);
			break;
		case PROJECTILE_HG_PLASMA:
			setmodel(self, "models/plasmabomb.iqm");
			projectile_colormap_setup(COLOR_TEAM2);
			break;
		case PROJECTILE_HG_REMOTE:
			setmodel(self, "models/mine.md3");
			self.skin = team_index(self.team);
			break;
		case PROJECTILE_HG_LASER: setmodel(self, "models/elaser.mdl"); break;
		case PROJECTILE_HG_TRANSLOC:
			setmodel(self, "models/translocator.iqm");
			self.skin = team_index(self.team);
			projectile_colormap_setup(COLOR_TEAM4);
			//self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
			break;
		case PROJECTILE_HG_PLASMA_SHARD:
			setmodel(self, "models/ebomb.mdl");
			projectile_colormap_setup(COLOR_TEAM2);
			self.skin = 2;
			//plasma_chain = findchainfloat_tofield(cnt, PROJECTILE_HG_PLASMA_SHARD, plasma_next);
			break;
		case PROJECTILE_HG_RAZE:
			setmodel(self, "models/raze.md3");
			projectile_colormap_setup(COLOR_TEAM1);
			break;
		default:
			error("Received invalid CSQC projectile, can't work with this!");
			break;
		}
		self.colormod = '0 0 0';
		self.move_touch = projectile_touch_stop;
		self.move_movetype = MOVETYPE_TOSS;
		switch (self.cnt) {
		case PROJECTILE_HG_PLASMA_SHARD:
		case PROJECTILE_ELECTRO:
			// only new engines support sound moving with object
			projectile_loopsound(self, CHAN_PROJECTILE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = stdproc_nothing;
			break;
		case PROJECTILE_ROCKET:
			projectile_loopsound(self, CHAN_PROJECTILE, "weapons/rocket_fly.wav", VOL_BASE, ATTN_NORM);
			break;
		case PROJECTILE_GRENADE:
			break;
		case PROJECTILE_GRENADE_BOUNCING:
		case PROJECTILE_HG_GENERIC:
		case PROJECTILE_HG_PLASMA:
		case PROJECTILE_HG_NAPALM:
		case PROJECTILE_HG_TRANSLOC:
		case PROJECTILE_HG_REMOTE:
		case PROJECTILE_HG_RAZE:
		case PROJECTILE_HG_LASER:
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = stdproc_nothing;
			break;
		case PROJECTILE_PORTO_RED:
			self.colormod = '2 1 1';
			self.alpha = 0.5;
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = stdproc_nothing;
			break;
		case PROJECTILE_PORTO_BLUE:
			self.colormod = '1 1 2';
			self.alpha = 0.5;
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = stdproc_nothing;
			break;
		case PROJECTILE_HAGAR_BOUNCING:
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = stdproc_nothing;
			break;
		case PROJECTILE_CRYLINK_BOUNCING:
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = stdproc_nothing;
			break;
		case PROJECTILE_FIREBALL:
			projectile_loopsound(self, CHAN_PROJECTILE, "weapons/fireball_fly2.wav", VOL_BASE, ATTN_NORM);
			break;
		case PROJECTILE_HG_NAPALMSHARD:
		case PROJECTILE_FIREMINE:
			projectile_loopsound(self, CHAN_PROJECTILE, "weapons/fireball_fly.wav", VOL_BASE, ATTN_NORM);
			self.move_movetype = MOVETYPE_BOUNCE;
			self.move_touch = stdproc_nothing;
			break;
		case PROJECTILE_BULLET_BIG:
			self.move_movetype = MOVETYPE_BOUNCEMISSILE;
			self.move_touch = stdproc_nothing;
			break;
		default:
			break;
		}
		projectile_set_size(self, self.cnt);
	}
	if (f & 4) {
		self.server_angles_x = ReadCoord();
		self.server_angles_y = ReadCoord();
		self.server_angles_z = ReadCoord();
		self.iflags &~= IFLAG_ANGLES | IFLAG_AUTOANGLES;
		self.use_server_angles = TRUE;
	}
	if (self.gravity) {
		if (self.move_movetype == MOVETYPE_FLY)
			self.move_movetype = MOVETYPE_TOSS;
		if (self.move_movetype == MOVETYPE_BOUNCEMISSILE)
			self.move_movetype = MOVETYPE_BOUNCE;
	} else {
		if (self.move_movetype == MOVETYPE_TOSS)
			self.move_movetype = MOVETYPE_FLY;
		if (self.move_movetype == MOVETYPE_BOUNCE)
			self.move_movetype = MOVETYPE_BOUNCEMISSILE;
	}
	if (!(self.count & 0x80))
		InterpolateOrigin_Note();

	self.draw = projectile_draw;
	self.entremove = projectile_remove;
}

void(void) projectile_precache {
	precache_model("models/ebomb.mdl");
	precache_model("models/elaser.mdl");
	precache_model("models/grenademodel.md3");
	precache_model("models/hagarmissile.mdl");
	precache_model("models/hlac_bullet.md3");
	precache_model("models/laser.mdl");
	precache_model("models/plasmatrail.mdl");
	precache_model("models/rocket.md3");
	precache_model("models/tracer.mdl");
	precache_sound("weapons/electro_fly.wav");
	precache_sound("weapons/rocket_fly.wav");
	precache_sound("weapons/fireball_fly.wav");
	precache_sound("weapons/fireball_fly2.wav");
}

void(void) projectile_info_read {
	float phighest = ReadByte();
	float i;
	for (i = 0; i < phighest; ++i) {
		float type = ReadByte();
		switch (type) {
		case PROJINFO_TYPE_UNREGISTERED:
		case PROJINFO_TYPE_POINT_000:
			projectile_register(i + 1, type, '0 0 0');
			break;
		case PROJINFO_TYPE_POINT_00n3:
			projectile_register(i + 1, type, '0 -3 -3');
			break;
		case PROJINFO_TYPE_POINT:
		case PROJINFO_TYPE_CENTERED:
		case PROJINFO_TYPE_UNCENTERED:
			projinfo_type[i] = type;
			projinfo_sizes[i] = ReadCoord();
			break;
		default:
			error(strcat("Invalid ProjInfo type ", ftos(type)));
		}
	}
}
