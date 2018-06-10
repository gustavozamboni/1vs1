#ifdef INTERFACE
CLASS(NexuizVoteList) EXTENDS(NexuizListBox)
	METHOD(NexuizVoteList, configureNexuizVoteList, void(entity))
	METHOD(NexuizVoteList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizVoteList, setSelected, void(entity, float))
	METHOD(NexuizVoteList, resizeNotify, void(entity, vector, vector, vector, vector))
	ATTRIB(NexuizVoteList, textBox, entity, NULL)
	ATTRIB(NexuizVoteList, realUpperMargin, float, 0)
	ATTRIB(NexuizCvarList, columnNameOrigin, float, 0)
	ATTRIB(NexuizCvarList, voteArgsList, entity, NULL)
ENDCLASS(NexuizVoteList)
entity makeNexuizVoteList();
#endif

#ifdef IMPLEMENTATION

entity makeNexuizVoteList(void)
{
	entity me;
	me = spawnNexuizVoteList();
	me.configureNexuizVoteList(me);
	return me;
}

void configureNexuizVoteListNexuizVoteList(entity me)
{
    me.nItems = vote_commands_count;
	me.configureNexuizListBox(me);
}

void setSelectedNexuizVoteList(entity me, float i)
{
	setSelectedListBox(me, i);
	me.voteArgsList.setVoteType(me.voteArgsList, vote_commands[i]);
    string s = strcat(vote_commands[i], " ");
    me.textBox.setText(me.textBox, s);
    me.textBox.cursorPos = strlen(s);
}

void resizeNotifyNexuizVoteList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}

void drawListBoxItemNexuizVoteList(entity me, float i, vector absSize, float isSelected)
{
	string s;
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
	s = vote_commands[i];
	draw_Text(me.realUpperMargin * eY + (me.columnNameOrigin) * eX, s, me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);
}

#endif

