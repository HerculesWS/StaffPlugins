// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file
// Sample Hercules Plugin

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "../common/HPMi.h"
#include "../map/atcommand.h"
#include "../map/clif.h"
#include "../map/intif.h"
#include "../map/itemdb.h"
#include "../map/mob.h"
#include "../map/pc.h"
#include "../map/pet.h"
#include "../map/status.h"
#include "../map/storage.h"
#include "../map/unit.h"

#include "../common/HPMDataCheck.h" /* should always be the last file included! (if you don't make it last, it'll intentionally break compile time) */
/* Designed by Beowulf/Nightroad, HPM port by [Ind/Hercules] */

HPExport struct hplugin_info pinfo = {
	"@storeitem",	// Plugin name
	SERVER_TYPE_MAP,// Which server types this plugin works with?
	"0.1",			// Plugin version
	HPM_VERSION,	// HPM Version (don't change, macro is automatically updated)
};
ACMD(storeitem) {
	struct map_session_data *pl_sd;
	struct item item_tmp;
	struct item_data *item_data;
	char item_name[ITEM_NAME_LENGTH];
	char character[NAME_LENGTH];
	int number = 0, item_id;
	int get_count, pet_id, ref = 0;

	memset(item_name, '\0', sizeof(item_name));

	if (!message || !*message || sscanf(message, "%49s %d %d %23[^\n]", item_name, &number, &ref, character) < 4) {
		clif->message(fd, "(usage: @storeitem <item name or ID> <quantity> <refine> <char name>).");
		return false;
	}

	if( ref < 0 || ref > MAX_REFINE ) {
		char output_p[124];
		sprintf(output_p,"<refine> %d is out of bounds, limit is 0~%d. @storeitem failed.",ref,MAX_REFINE);
		clif->message(fd,output_p);
		return false;
	}

	if (number <= 0)
		number = 1;

	item_id = 0;
	if ((item_data = itemdb->search_name(item_name)) != NULL || (item_data = itemdb->exists(atoi(item_name))) != NULL)
			item_id = item_data->nameid;
	else {
		clif->message(fd, atcommand->msg_table[19]); // Invalid item ID or name.
		return false;
	}

	/* only weapon (4) and armors (5) can refine, refineable item db field also applies */
	if( ( item_data->type != 4 && item_data->type != 5 ) || item_data->flag.no_refine )
			ref = 0;

	get_count = number;

	pet_id = pet->search_petDB_index(item_id, PET_EGG);
	if (item_data->type == 4 || item_data->type == 5 || item_data->type == 7 || item_data->type == 8) {
		get_count = 1;
	}

	if ((pl_sd = map->nick2sd(character)) != NULL) {
		if (pc_get_group_level(sd) >= pc_get_group_level(pl_sd)) { // you can add items only to groups of equal or lower level
			int i;
			for (i = 0; i < number; i += get_count) {
					if (pet_id >= 0) {
						pl_sd->catch_target_class = pet->db[pet_id].class_;
						intif->create_pet(pl_sd->status.account_id, pl_sd->status.char_id,
						                  (short)pet->db[pet_id].class_, (short)mob->db(pet->db[pet_id].class_)->lv,
						                  (short)pet->db[pet_id].EggID, 0, (short)pet->db[pet_id].intimate,
						                  100, 0, 1, pet->db[pet_id].jname);
					} else {
						memset(&item_tmp, 0, sizeof(item_tmp));
						item_tmp.nameid = item_id;
						item_tmp.identify = 1;
						item_tmp.refine = ref;
						storage->open(pl_sd);/* without open/close procedure the client requires you to relog to access storage properly */
						storage->additem(pl_sd, &item_tmp, get_count);
						storage->close(pl_sd);
					}
				}
			clif->message(fd, atcommand->msg_table[18]); // Item created.
		} else {
			clif->message(fd, atcommand->msg_table[81]); // Your GM level don't authorise you to do this action on this player.
			return false;
		}
	} else {
		clif->message(fd, atcommand->msg_table[3]); // Character not found.
		return false;
	}

	return true;
}
HPExport void plugin_init (void) {
	atcommand = GET_SYMBOL("atcommand");
	storage = GET_SYMBOL("storage");
	clif = GET_SYMBOL("clif");
	pc = GET_SYMBOL("pc");
	map = GET_SYMBOL("map");
	itemdb = GET_SYMBOL("itemdb");
	intif = GET_SYMBOL("intif");
	pet = GET_SYMBOL("pet");

	addAtcommand("storeitem",storeitem);
}
