float mouse_enabled;
var float mouse_not_centered = TRUE;
vector mouse_pos;

vector(void) mouse_position {
	if (mouse_enabled)
		return getmousepos();
	else
		return mouse_pos;
}

void Mouse_Draw() {
	if (mouse_enabled) {
		mouse_pos = getmousepos();
		drawpic(mouse_pos, strcat("gfx/menu/", cvar_string("menu_skin"), "/cursor"), '32 32 0', '1 1 1', 1, DRAWFLAG_NORMAL);
		mouse_not_centered = TRUE;
		mouse_enabled = FALSE;
	} else if (mouse_not_centered) {
		mouse_pos = '0.5 0 0' * CVAR(vid_conwidth) + '0 0.5 0' * CVAR(vid_conheight);
		mouse_not_centered = FALSE;
		setcursormode(0);
	}
}

void Mouse_Enable() {
	if not(mouse_enabled)
	if (CVAR(_menu_alpha) <= 0) {
		setcursormode(1);
		mouse_enabled = TRUE;
	}
}
