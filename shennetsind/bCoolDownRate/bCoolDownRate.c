// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file
// Sample Hercules Plugin

#include "common/hercules.h"
#include "common/memmgr.h"
#include "common/mmo.h"
#include "common/socket.h"
#include "map/map.h"
#include "map/pc.h"
#include "map/script.h"
#include "map/skill.h"
#include "map/status.h"

#include "plugins/HPMHooking.h"
#include "common/HPMDataCheck.h" /* should always be the last file included! (if you don't make it last, it'll intentionally break compile time) */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* works like bDelayRate */
/* example: cooldown is 10000 (10s) */
/* 'bonus bCoolDownRate,50;'  = 15000 (15s) (+50%) */
/* 'bonus bCoolDownRate,-50;' = 5000 (5s) (-50%) */

HPExport struct hplugin_info pinfo = {
	"bCoolDownRate", // Plugin name
	SERVER_TYPE_MAP, // Which server types this plugin works with?
	"0.1",           // Plugin version
	HPM_VERSION,     // HPM Version (don't change, macro is automatically updated)
};

int bCoolDownRateID = -1;

struct s_cooldown_rate {
	int rate;
};

/* to check for the bonus */
int skill_blockpc_start_preHook(struct map_session_data **sd, uint16 *skill_id, int *tick)
{
	const struct s_cooldown_rate *data;

	if (*tick > 1 && sd != NULL && (data = getFromMSD(*sd, 0)) != NULL) {
		if (data->rate != 100)
			*tick = *tick * data->rate / 100;
	}
	return 1;/* doesn't matter */
}

/* to set the bonus */
int pc_bonus_preHook(struct map_session_data **sd, int *type, int *val)
{
	if (*type == bCoolDownRateID) {
		struct s_cooldown_rate *data;

		if ((data = getFromMSD(*sd, 0)) == NULL) {/* don't have, create */
			CREATE(data, struct s_cooldown_rate, 1);/* alloc */
			data->rate = 100;/* 100% -- default */
			addToMSD(*sd, data, 0, true);/* link to sd */
		}
		data->rate += *val;

		hookStop();/* don't need to run the original */
	}

	return 0;
}
/* to reset the bonus on recalc */
int status_calc_pc_preHook(struct map_session_data **sd, enum e_status_calc_opt *opt)
{
	struct s_cooldown_rate *data;

	if ((data = getFromMSD(*sd,0)) != NULL) {
		data->rate = 100;//100% -- default
	}
	return 1;/* doesn't matter */
}

HPExport void plugin_init(void)
{
	/* grab a unique bonus ID for us */
	bCoolDownRateID = map->get_new_bonus_id();
	/* set constant 'bCoolDownRate', and set value to bCoolDownRateID */
	script->set_constant("bCoolDownRate", bCoolDownRateID, false, false);

	/* hook */
	addHookPre(skill, blockpc_start, skill_blockpc_start_preHook);
	addHookPre(pc, bonus, pc_bonus_preHook);
	addHookPre(status, calc_pc_, status_calc_pc_preHook);
}
