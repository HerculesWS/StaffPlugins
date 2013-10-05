// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file
// Sample Hercules Plugin

#include <stdio.h>
#include <string.h>
#include "../common/HPMi.h"
#include "../common/db.h"
#include "../map/pc.h"
#include "../map/skill.h"
#include "../map/clif.h"
#include "../map/map.h"

HPExport struct hplugin_info pinfo = {
	"@debugcd",		// Plugin name
	SERVER_TYPE_MAP,// Which server types this plugin works with?
	"0.1",			// Plugin version
	HPM_VERSION,	// HPM Version (don't change, macro is automatically updated)
};

ACMD(debugcd) {
	struct map_session_data *pl_sd;
	struct skill_cd *cd;
	char pout[99];
	int i;
	
	if( !message || !*message ) {
		clif->message(fd,"Usage: @debugcd <char_name>");
		return false;
	}
	
	if( !(pl_sd = map->nick2sd(message)) ) {
		clif->message(fd,"Character name not found");
		return false;
	}
	
	if( !(cd = idb_get(skill->cd_db,pl_sd->status.char_id)) ) {
		clif->message(fd,"Character has no saved cooldowns");
		return false;
	}

	for( i = 0; i < cd->cursor; i++ ) {
		sprintf(pout,"[%d] '%s' (ID %d) %d",i,skill->get_name(cd->nameid[i]),cd->nameid[i],cd->duration[i]);
		clif->message(fd,pout);
	}
	
	return true;
}

HPExport void plugin_init (void) {
	skill = GET_SYMBOL("skill");
	map = GET_SYMBOL("map");
	DB = GET_SYMBOL("DB");
	clif = GET_SYMBOL("clif");

	if( HPMi->addCommand != NULL ) {
		HPMi->addCommand("debugcd",ACMD_A(debugcd));
	}
}