// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file
// Sample Hercules Plugin

#include "common/hercules.h"
#include "common/mmo.h"
#include "map/itemdb.h"
#include "map/mob.h"

#include "common/HPMDataCheck.h" /* should always be the last file included! (if you don't make it last, it'll intentionally break compile time) */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/**
 * Adds a 50% ( customizeable ) chance for ETC (customizeable) items to drop from mobs with double quantity
 * Adds a 25% ( customizeable as well ) chance for it to use tripple quantity (this dice is only played if the 50% one succeeded)
 * Adds a 10% ( customizeable as well ) chance for it to use quadruple quantity (this dice is only played if the 25% one succeeded)
 * Adds a 5%  ( customizeable as well ) chance for it to use quintuple quantity (this dice is only played if the 10% one succeeded)
 * For example, after a player succeeds at dropping a jellopy (at any rate), theres a 50% chance it'll be 2 jellopies instead of 1,
 * and if that 50% succeeds, there'll be another 25% chance for it to be 3 instead of 2, and if that 25% succeeds,
 * there will be another 10% chance for it to drop 4 instead of 3, and if that 10% succeeds, there will be a 5% chance to drop 5 instead of 4.
 * - MvP drops are not affected
 * - Items looted by monsters are not affected
 **/

HPExport struct hplugin_info pinfo = {
	"MobDropQty",	// Plugin name
	SERVER_TYPE_MAP,// Which server types this plugin works with?
	"0.1",			// Plugin version
	HPM_VERSION,	// HPM Version (don't change, macro is automatically updated)
};


/**
 * Our pre-hook to mob->setdropitem
 **/
struct item_drop *mob_setdropitem_pre(int *nameid, int *qty, struct item_data *data) {
	if( data ) {/* we only care about the areas that send it as non-NULL */
		switch( data->type ) {
			/* uncomment those you wanna affect, don't even try adding gear or non-stackable types -- they are not meant to have qty higher than 1! */
			//case IT_HEALING:
			//case IT_USABLE:
			//case IT_CARD:
			//case IT_AMMO:
			//case IT_DELAYCONSUME:
			//case IT_CASH:
			case IT_ETC:
				/* Feel free to modify the formula here! */
				if( rand()%100 > 50 ) /* if rand > 50, break and do not affect the qty */
					break;
				*qty += 1;//from 1 to 2
				if( rand()%100 > 25 ) /* if rand > 25, break and do not affect the qty further */
					break;
				*qty += 1;//from 2 to 3
				if( rand()%100 > 10 ) /* if rand > 10, break and do not affect the qty further */
					break;
				*qty += 1;//from 3 to 4
				if( rand()%100 > 5 ) /* if rand > 5, break and do not affect the qty further */
					break;
				*qty += 1;//from 4 to 5
				break;
		}
	}

	return NULL;/* return value on pre hooks doesn't matter unless we tell it not to run the original (with 'hookStop();') */
}
/**
 * We started!
 **/
HPExport void plugin_init (void) {
	/* lets hook! */
	addHookPre("mob->setdropitem",mob_setdropitem_pre);
}
