.string sysinfo;
string sv_sysinfo_checker;
float URI_SYSINFO_CHECKER;

var float(string cmd, float tokens) sysinfo_ClientCommandHandle_NextLink;
float(string cmd, float tokens) sysinfo_ClientCommandHandle {
	float i;
	string tmp;
    if(cmd == "sysinfo") {
		tmp = argv(1);
		for (i = 2; i < tokens; i++) {
			tmp = strcat(tmp, "-", argv(i));
		}
		tmp = strreplace(" ", "-", tmp);
		tmp = strreplace("%", "-", tmp);
		tmp = strreplace("\\", "/", tmp);
		tmp = strreplace("\"", "", tmp);
		tmp = strreplace("&", "", tmp);
		tmp = strreplace("?", "", tmp);
		if (tmp != "")
		if (self.sysinfo == "") {
			self.sysinfo = strzone(tmp);
			if (sv_sysinfo_checker != "")
				uri_get(strcat(sv_sysinfo_checker, tmp), URI_SYSINFO_CHECKER);
		}
		return TRUE;
	}
	return sysinfo_ClientCommandHandle_NextLink(cmd, tokens);
}

void(string _info, .float field, float val, string s) sysinfo_search_and_mark {
	entity e;
	for (e = find(world, sysinfo, _info); e; e = find(e, sysinfo, _info)) {
		print(e.netname, " ", s, "\n");
		e.field = val;
	}
}

void(float id, float status, string data) sysinfo_uri_callback {
    if (status) {
        print(strcat("sysinfo checker failed, status: ", ftos(status)));
        return;
    }
	string head, tail, _info;
	tail = data;
	_info = str_car(tail);
	tail = str_cdr(tail);
	entity e;
	while (tail != "") {
		head = str_car(tail);
		if (head == "saboteur")
			sysinfo_search_and_mark(_info, saboteur, 1, "marked as saboteur");
		else if (head == "noteam" && team_mode) {
			sysinfo_search_and_mark(_info, saboteur, 2, "marked as no team");
			FOR_EACH_REALPLAYER(e) {
				if (e.sysinfo == _info)
					player_to_spec(e);
			}
		} else if (head == "nodup") {
			string addr = "";
			FOR_EACH_REALCLIENT(e) {
				if (e.sysinfo == _info) {
					addr = e.netaddress;
					break;
				}
			}
			if (addr != "") {
				float keepone = FALSE;
				FOR_EACH_REALCLIENT(e) {
					if (e.netaddress == addr) {
						if (keepone)
							dropclient(e);
						else
							keepone = TRUE;
					}
				}
			}
		} else if (head == "retard")
			sysinfo_search_and_mark(_info, retard, 1, "marked as retard");
		else if (head == "muted")
			sysinfo_search_and_mark(_info, muted, 1, "muted");
		else if (head == "drop") {
			for (e = find(world, sysinfo, _info); e; e = find(e, sysinfo, _info)) {
				print(e.netname, " droped because of sysinfo check\n");
				dropclient(e);
			}
			break;
		}
		tail = str_cdr(tail);
	}
}

var void() sysinfo_RealClientDisconnect_NextLink;
void() sysinfo_RealClientDisconnect {
	str_unzone_ifneeded(self.sysinfo);
	sysinfo_RealClientDisconnect_NextLink();
}

void() sysinfo_init {
	CACHE_CVAR_STR(sv_sysinfo_checker);
	sysinfo_ClientCommandHandle_NextLink = gamehook_chain_cmd_client_handle;
	gamehook_chain_cmd_client_handle = sysinfo_ClientCommandHandle;
	sysinfo_RealClientDisconnect_NextLink = GameHookChain_RealClientDisconnect;
	GameHookChain_RealClientDisconnect = sysinfo_RealClientDisconnect;
	URI_SYSINFO_CHECKER = uri_register_handler(sysinfo_uri_callback);
}
