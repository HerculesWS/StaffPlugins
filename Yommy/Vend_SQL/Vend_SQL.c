// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file

// Vend_SQL Plugin - Yommy
// Inserts Player vends into sql database

#include "common/hercules.h"
#include "common/mmo.h"
#include "common/nullpo.h"
#include "common/sql.h"
#include "common/showmsg.h"
#include "common/strlib.h"
#include "common/timer.h"
#include "map/buyingstore.h"
#include "map/map.h"
#include "map/npc.h"
#include "map/pc.h"

#include "common/HPMDataCheck.h"

#include <stdio.h>
#include <string.h>

static char vendingstat_table[32] = "vending_stat";
static uint32 vendingstat_refresh_sec = 120;

HPExport struct hplugin_info pinfo = {
	"vend_sql",      // Plugin name
	SERVER_TYPE_MAP, // Which server types this plugin works with?
	"0.1",           // Plugin version
	HPM_VERSION,	 // HPM Version (don't change, macro is automatically updated)
};

int map_vendingstat_npcshop_sub(struct npc_data *nd, va_list ap)
{
	StringBuf *buf = va_arg(ap, StringBuf *);
	int *n_ptr = va_arg(ap, int *);
	int i;
	int n = *n_ptr;
	char map_esc[MAP_NAME_LENGTH*2+1] = "";
	char name[NAME_LENGTH] = "";
	char name_esc[NAME_LENGTH*2+1] = "";
	char shop_esc[MESSAGE_SIZE*2+1] = "";

	nullpo_ret(nd);

	if (nd->subtype != SHOP && nd->subtype != CASHSHOP)
		return 0;

	if (nd->bl.m != 0)
		SQL->EscapeStringLen(map->mysql_handle, map_esc, map->list[nd->bl.m].name, strnlen(map->list[nd->bl.m].name, MAP_NAME_LENGTH));

	sscanf(nd->name, "%23[^#]", name);
	SQL->EscapeStringLen(map->mysql_handle, name_esc, name, strnlen(name,NAME_LENGTH));

	for (i = 0; i < nd->u.shop.count; i++) {
		if (n > 0)
			StrBuf->AppendStr(buf, ",");

		StrBuf->Printf(buf,"('%d','%s','%s','%s','%d','%d','%d','%d','%d','%d','%d','%d','%d','%u')",
				nd->subtype == SHOP ? 2 : 3, name_esc, shop_esc, map_esc, nd->bl.x, nd->bl.y,
				nd->u.shop.shop_item[i].nameid, 0, 0, 0, 0, 0, -1, nd->u.shop.shop_item[i].value);
		n++;
	}

	*n_ptr = n;

	return 1;
}

int map_vendingstat_tosql_timer(int tid, int64 tick, int id, intptr_t data)
{
	const struct map_session_data *sd = NULL;
	int n = 0;
	StringBuf *buf = StrBuf->Malloc();
	struct s_mapiterator *iter = mapit_getallusers();

	timer->add(timer->gettick() + vendingstat_refresh_sec*1000, map_vendingstat_tosql_timer, 0, 0);

	StrBuf->Printf(buf, "INSERT DELAYED INTO `%s` "
			"(`type`,`owner`,`shop`,`map`,`x`,`y`,`nameid`,`refine`,`card0`,`card1`,`card2`,`card3`,`amount`,`price`) VALUES ",
			vendingstat_table);

	// Insert PC shops into query string
	for (sd = BL_UCCAST(BL_PC, mapit->first(iter)); mapit->exists(iter); sd = BL_UCCAST(BL_PC, mapit->next(iter))) {
		char map_esc[MAP_NAME_LENGTH*2+1];
		char name_esc[NAME_LENGTH*2+1];
		char shop_esc[MESSAGE_SIZE*2+1];
		int i;

		SQL->EscapeStringLen(map->mysql_handle, map_esc, map->list[sd->bl.m].name, strnlen(map->list[sd->bl.m].name, MAP_NAME_LENGTH));
		SQL->EscapeStringLen(map->mysql_handle, name_esc, sd->status.name, strnlen(sd->status.name, NAME_LENGTH));
		SQL->EscapeStringLen(map->mysql_handle, shop_esc, sd->message, strnlen(sd->message, MESSAGE_SIZE));

		if (sd->state.vending != 0) {
			for (i = 0; i < sd->vend_num; i++) {
				const struct item *item =  &sd->status.cart[sd->vending[i].index];
				if (sd->vending[i].amount == 0)
					continue;

				if (n > 0)
					StrBuf->AppendStr(buf, ",");

				StrBuf->Printf(buf,"('%d','%s','%s','%s','%d','%d','%d','%d','%d','%d','%d','%d','%d','%u')",
						0, name_esc, shop_esc, map_esc, sd->bl.x, sd->bl.y,
						item->nameid, item->refine, item->card[0], item->card[1], item->card[2], item->card[3],
						sd->vending[i].amount, sd->vending[i].value);
				n++;
			}
		}

		if (sd->state.buyingstore != 0) {
			for (i = 0; i < sd->buyingstore.slots; i++) {
				const struct s_buyingstore_item *item = &sd->buyingstore.items[i];

				if (item->amount == 0)
					continue;

				if (n > 0)
					StrBuf->AppendStr(buf, ",");

				StrBuf->Printf(buf,"('%d','%s','%s','%s','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d')",
						1, name_esc, shop_esc, map_esc, sd->bl.x, sd->bl.y,
						item->nameid, 0, 0, 0, 0, 0, item->amount, item->price);
				n++;
			}
		}
	}

	// Now the NPC shops.
	map->foreachnpc(map_vendingstat_npcshop_sub, buf, &n);

	// Clear table
	if (SQL_ERROR == SQL->Query(map->mysql_handle, "DELETE FROM `%s`", vendingstat_table))
		Sql_ShowDebug(map->mysql_handle);

	// Execute query
	if (n > 0) {
		if (SQL_ERROR == SQL->QueryStr(map->mysql_handle, StrBuf->Value(buf)))
			Sql_ShowDebug(map->mysql_handle);
	}

	mapit->free(iter);
	StrBuf->Free(buf);

	return 0;
}

void do_init_vendingstat(void)
{
	timer->add(timer->gettick() + vendingstat_refresh_sec*1000, map_vendingstat_tosql_timer, 0, 0);

	if (SQL_ERROR == SQL->Query(map->mysql_handle,
				"CREATE TABLE IF NOT EXISTS `%s` ("
				"`type` tinyint(3) unsigned NOT NULL,"
				"`owner` varchar(23) NOT NULL,"
				"`shop` varchar(79) NOT NULL,"
				"`map` varchar(11) NOT NULL,"
				"`x` smallint(5) unsigned NOT NULL,"
				"`y` smallint(5) unsigned NOT NULL,"
				"`nameid` smallint(6) NOT NULL,"
				"`refine` tinyint(3) unsigned NOT NULL,"
				"`card0` smallint(6) NOT NULL,"
				"`card1` smallint(6) NOT NULL,"
				"`card2` smallint(6) NOT NULL,"
				"`card3` smallint(6) NOT NULL,"
				"`amount` int(10) NOT NULL,"
				"`price` int(10) unsigned NOT NULL)",
				vendingstat_table)
	) {
		Sql_ShowDebug(map->mysql_handle);
		ShowFatalError("Couldn't init SQL");
	}
}

HPExport void plugin_init(void)
{
}

/* run when server is ready (online) */
HPExport void server_online(void)
{
	do_init_vendingstat();
}
