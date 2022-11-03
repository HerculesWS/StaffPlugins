// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file
// Sample Hercules Plugin

#include "common/hercules.h"
#include "common/mmo.h"
#include "map/atcommand.h"
#include "map/clif.h"
#include "map/intif.h"
#include "map/itemdb.h"
#include "map/mob.h"
#include "map/pc.h"
#include "map/pet.h"
#include "map/refine.h"
#include "map/status.h"
#include "map/storage.h"

#include "common/HPMDataCheck.h" /* should always be the last file included! (if you don't make it last, it'll intentionally break compile time) */

#include <stdlib.h>

/* Designed by Beowulf/Nightroad, HPM port by [Ind/Hercules] */

HPExport struct hplugin_info pinfo = {
	"@storeitem",   // Plugin name
	SERVER_TYPE_MAP,// Which server types this plugin works with?
	"0.1",          // Plugin version
	HPM_VERSION,    // HPM Version (don't change, macro is automatically updated)
};

ACMD(storeitem)
{
	struct map_session_data *pl_sd;
	const struct item_data *item_data;
	char item_name[ITEM_NAME_LENGTH] = { 0 };
	char character[NAME_LENGTH];
	int number = 0, item_id, i;
	int get_count, pet_id, ref = 0;

	if (*message == '\0' || sscanf(message, "%49s %d %d %23[^\n]", item_name, &number, &ref, character) < 4) {
		clif->message(fd, "(usage: @storeitem <item name or ID> <quantity> <refine> <char name>).");
		return false;
	}

	if (ref < 0 || ref > MAX_REFINE) {
		char output_p[124];
		sprintf(output_p,"<refine> %d is out of bounds, limit is 0~%d. @storeitem failed.", ref, MAX_REFINE);
		clif->message(fd, output_p);
		return false;
	}

	if (number <= 0)
		number = 1;

	item_id = 0;
	if ((item_data = itemdb->search_name(item_name)) != NULL || (item_data = itemdb->exists(atoi(item_name))) != NULL) {
		item_id = item_data->nameid;
	} else {
		clif->message(fd, msg_fd(fd, 19)); // Invalid item ID or name.
		return false;
	}

	/* only weapon (4) and armors (5) can refine, refineable item db field also applies */
	if ((item_data->type != IT_WEAPON && item_data->type != IT_ARMOR) || item_data->flag.no_refine)
		ref = 0;

	get_count = number;

	pet_id = pet->search_petDB_index(item_id, PET_EGG);
	if (item_data->type == IT_WEAPON || item_data->type == IT_ARMOR || item_data->type == IT_PETEGG || item_data->type == IT_PETARMOR) {
		get_count = 1;
	}

	if ((pl_sd = map->nick2sd(character, true)) == NULL) {
		clif->message(fd, msg_fd(fd, 3)); // Character not found.
		return false;
	}

	if (pc_get_group_level(sd) < pc_get_group_level(pl_sd)) { // you can add items only to groups of equal or lower level
		clif->message(fd, msg_fd(fd, 81)); // Your GM level don't authorise you to do this action on this player.
		return false;
	}

	for (i = 0; i < number; i += get_count) {
		if (pet_id >= 0) {
			pl_sd->catch_target_class = pet->db[pet_id].class_;
			intif->create_pet(pl_sd->status.account_id, pl_sd->status.char_id,
					pet->db[pet_id].class_, mob->db(pet->db[pet_id].class_)->lv,
					pet->db[pet_id].EggID, 0, pet->db[pet_id].intimate,
					100, 0, 1, pet->db[pet_id].jname);
		} else {
			struct item item_tmp = { 0 };
			item_tmp.nameid = item_id;
			item_tmp.identify = 1;
			item_tmp.refine = ref;
			storage->open(pl_sd);/* without open/close procedure the client requires you to relog to access storage properly */
			storage->additem(pl_sd, &item_tmp, get_count);
			storage->close(pl_sd);
		}
	}
	clif->message(fd, msg_fd(fd, 18)); // Item created.

	return true;
}
HPExport void plugin_init(void)
{
	addAtcommand("storeitem",storeitem);
}
