// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file

/* [Ind/Hercules] - shennetsind */

#include "common/hercules.h"
#include "common/strlib.h"
#include "map/clif.h"
#include "map/pc.h"
#include "common/HPMDataCheck.h" /* should always be the last file included! (if you don't make it last, it'll intentionally break compile time) */

#include <stdio.h>
#include <string.h>

HPExport struct hplugin_info pinfo = {
	"SkillErrorMessages", // Plugin name
	SERVER_TYPE_MAP,      // Which server types this plugin works with?
	"0.1",                // Plugin version
	HPM_VERSION,          // HPM Version (don't change, macro is automatically updated)
};

void (*clif_sk_fail_original) (struct map_session_data *sd, uint16 skill_id, enum useskill_fail_cause cause, int btype, int32 item_id);

void SKM_skill_fail(struct map_session_data *sd, uint16 skill_id, enum useskill_fail_cause cause, int btype, int32 item_id)
{
	if (sd == NULL) { //Since this is the most common nullpo....
		ShowDebug("clif_skill_fail: Error, received NULL sd for skill %d\n", skill_id);
		return;
	}

	if (sd->fd == 0)
		return;

	PRAGMA_GCC46(GCC diagnostic push)
	PRAGMA_GCC46(GCC diagnostic ignored "-Wswitch-enum")
	switch (cause) {
		case USESKILL_FAIL_SPIRITS:
		{
			char output[80];
			snprintf(output, 80, "%s requires a total %d spirit spheres", skill->get_desc(skill_id), btype);
			clif->messagecolor_self(sd->fd,COLOR_RED,output);
		}
			break;
		default:/* we dont handle, throw at the original */
			clif_sk_fail_original(sd, skill_id, cause, btype, item_id);
			break;
	}
	PRAGMA_GCC46(GCC diagnostic pop)
}

HPExport void plugin_init(void)
{
	clif_sk_fail_original = clif->skill_fail;
	clif->skill_fail = SKM_skill_fail;
}
