// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file
// Sample Hercules Plugin

#include "common/hercules.h"
#include "common/db.h"
#include "map/clif.h"
#include "map/map.h"
#include "map/pc.h"
#include "map/skill.h"

#include "common/HPMDataCheck.h" /* should always be the last file included! (if you don't make it last, it'll intentionally break compile time) */

#include <stdio.h>
#include <string.h>

HPExport struct hplugin_info pinfo = {
	"@debugcd",      // Plugin name
	SERVER_TYPE_MAP, // Which server types this plugin works with?
	"0.1",           // Plugin version
	HPM_VERSION,     // HPM Version (don't change, macro is automatically updated)
};

ACMD(debugcd)
{
	const struct map_session_data *pl_sd;
	const struct skill_cd *cd;
	char pout[99];
	int i;

	if (*message == '\0') {
		clif->message(fd,"Usage: @debugcd <char_name>");
		return false;
	}

	if ((pl_sd = map->nick2sd(message)) == NULL) {
		clif->message(fd,"Character name not found");
		return false;
	}

	if ((cd = idb_get(skill->cd_db,pl_sd->status.char_id)) == NULL) {
		clif->message(fd,"Character has no saved cooldowns");
		return false;
	}

	for (i = 0; i < cd->cursor; i++) {
		sprintf(pout,"[%d] '%s' (ID %d) %d",i,skill->get_name(cd->entry[i]->skill_id),cd->entry[i]->skill_id,cd->entry[i]->total);
		clif->message(fd,pout);
	}

	return true;
}

HPExport void plugin_init (void)
{
	addAtcommand("debugcd",debugcd);
}
