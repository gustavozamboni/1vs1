float g_warfog;
float g_warfog_r;
float g_warfog_g;
float g_warfog_b;
float g_warfog_alpha;
float g_warfog_fade_distance;

var float(entity plr, entity viewer, float dalpha) warfog_PlayerAlphaMod_NextLink;
float(entity plr, entity viewer, float dalpha) warfog_PlayerAlphaMod {
	if (dalpha > 0) {
		float d = vlen(plr.origin - viewer.origin);
		float fade_start = g_warfog - g_warfog_fade_distance;
		float fog_alpha;
		if (d > fade_start) {
			fog_alpha = 1 - min((d - fade_start) / g_warfog_fade_distance, 1);
			if ((team_mode && plr.team == viewer.team) || GameHook_PlayerIsCarrier(plr))
				fog_alpha = 0.5 + 0.5 * fog_alpha;

			dalpha = dalpha * fog_alpha;
		}
	}
	return warfog_PlayerAlphaMod_NextLink(plr, viewer, dalpha);
}

void(void) warfog_init {
	CACHE_CVAR(g_warfog);
	if (g_warfog <= 0)
		return;

	CACHE_CVAR(g_warfog_fade_distance);
	CACHE_CVAR(g_warfog_r);
	CACHE_CVAR(g_warfog_g);
	CACHE_CVAR(g_warfog_b);
	CACHE_CVAR(g_warfog_alpha);
	g_warfog_fade_distance = max(1, g_warfog_fade_distance);
	warfog_PlayerAlphaMod_NextLink = gamehook_chain_player_alpha_mod;
	gamehook_chain_player_alpha_mod = warfog_PlayerAlphaMod;
	string fog_str = strcat(ftos(g_warfog_r), " ", ftos(g_warfog_g), " ", ftos(g_warfog_b), " ", ftos(g_warfog_alpha));
	client_fog = strzone(strcat("0.5 ", fog_str, " ", ftos(g_warfog)));
}
