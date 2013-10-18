// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file
// Sample Hercules Plugin

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "../common/HPMi.h"
#include "../common/mmo.h"
#include "../common/socket.h"
#include "../common/malloc.h"
#include "../map/map.h"
#include "../map/pc.h"
#include "../map/skill.h"
#include "../map/script.h"
#include "../map/status.h"

/* works like bDelayRate */
/* example: cooldown is 10000 (10s) */
/* 'bonus bCoolDownRate,50;'  = 15000 (15s) (+50%) */
/* 'bonus bCoolDownRate,-50;' = 5000 (5s) (-50%) */

HPExport struct hplugin_info pinfo = {
	"bCoolDownRate",// Plugin name
	SERVER_TYPE_MAP,// Which server types this plugin works with?
	"0.1",          // Plugin version
	HPM_VERSION,    // HPM Version (don't change, macro is automatically updated)
};

int bCoolDownRateID = -1;

struct s_cooldown_rate {
	int rate;
};

/* to check for the bonus */
int skill_blockpc_start_preHook(struct map_session_data *sd, uint16 *skill_id, int *tick, bool *load) {
	struct s_cooldown_rate *data;
	
	if( *tick > 1 && sd && (data = HPMi->getFromMSD(sd,HPMi->pid,0)) ) {
		if( data->rate != 100 )
			*tick = *tick * data->rate / 100;
	}
	return 1;/* doesn't matter */
}

/* to set the bonus */
int pc_bonus_preHook(struct map_session_data *sd,int *type,int *val) {
	
	if( *type == bCoolDownRateID ) {
		struct s_cooldown_rate *data;

		if( !(data = HPMi->getFromMSD(sd,HPMi->pid,0)) ) {/* don't have, create */
			CREATE(data,struct s_cooldown_rate,1);/* alloc */
			data->rate = 100;/* 100% -- default */
			HPMi->addToMSD(sd,data,HPMi->pid,0,true);/* link to sd */
		}

		data->rate += *val;
		
		hookStop();/* don't need to run the original */
	}
	
	return 0;
}
/* to reset the bonus on recalc */
int status_calc_pc_preHook(struct map_session_data* sd, bool *first) {
	struct s_cooldown_rate *data;
	
	if( (data = HPMi->getFromMSD(sd,HPMi->pid,0)) ) {
		data->rate = 100;//100% -- default
	}
	
	return 1;/* doesn't matter */
}

HPExport void plugin_init (void) {
	/* need those interfaces */
	iMalloc = GET_SYMBOL("iMalloc");
	map = GET_SYMBOL("map");
	script = GET_SYMBOL("script");
	status = GET_SYMBOL("status");

	/* grab a unique bonus ID for us */
	bCoolDownRateID = map->get_new_bonus_id();
	/* set constant 'bCoolDownRate', and set value to bCoolDownRateID */
	script->set_constant("bCoolDownRate", bCoolDownRateID, false);

	/* hook */
	addHookPre("skill->blockpc_start",skill_blockpc_start_preHook);
	addHookPre("pc->bonus",pc_bonus_preHook);
	addHookPre("status->calc_pc_",status_calc_pc_preHook);

}