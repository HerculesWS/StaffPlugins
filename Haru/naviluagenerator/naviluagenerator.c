/*
 * Copyright (c) Hercules Dev Team
 * Base author: Haru <haru@dotalux.com>
 * Adapted from an original version by Yommy
 *
 * This plugin is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This plugin is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this plugin.  If not, see <http://www.gnu.org/licenses/>.
 */

/// Navigation system LUA generator

#include "../common/cbasetypes.h"
#include "../common/strlib.h"
#include "../common/HPMi.h"
#include "../common/db.h"
#include "../common/malloc.h"
#include "../common/mmo.h"
#include "../map/map.h"
#include "../map/path.h"
#include "../map/pc.h"
#include "../map/mob.h"
#include "../map/npc.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>

#include "../common/HPMDataCheck.h"

/*************************** CONFIGURATION ***************************/
// See README.md for a description of these options.

#define COMPACT_OUTPUT

//#define RAGEXERE

//#define CLIENTVER 20140101

/************************* END CONFIGURATION *************************/

#ifdef COMPACT_OUTPUT
#define OUT_INDENT ""
#define OUT_SEPARATOR " "
#define OUT_FINDENT " "
#else
#define OUT_INDENT "\t"
#define OUT_SEPARATOR "\n"
#define OUT_FINDENT "\t"
#endif

#ifdef RAGEXERE
#define NAMESUFFIX "krsak"
#else
#define NAMESUFFIX "krpri"
#endif

#ifndef CLIENTVER
#define CLIENTVER PACKETVER
#endif

#define DIRECTORYNAME "navigation"

HPExport struct hplugin_info pinfo = {
	"naviluagenerator",  // Plugin name
	SERVER_TYPE_MAP,     // Which server types this plugin works with?
	"0.1",               // Plugin version
	HPM_VERSION,         // HPM Version (don't change, macro is automatically updated)
};

// We need a bigger max path length than stock Hercules
#define MAX_WALKPATH_NAVI 1024

struct walkpath_data_navi {
	unsigned char path_len, path_pos;
	unsigned char path[MAX_WALKPATH_NAVI];
};

/* begin 1:1 copy of various definitions and static functions from path.c */

/// @name Structures and defines for A* pathfinding
/// @{

/// Path node
struct path_node {
	struct path_node *parent; ///< pointer to parent (for path reconstruction)
	short x; ///< X-coordinate
	short y; ///< Y-coordinate
	short g_cost; ///< Actual cost from start to this node
	short f_cost; ///< g_cost + heuristic(this, goal)
	short flag; ///< SET_OPEN / SET_CLOSED
};

/// Binary heap of path nodes
BHEAP_STRUCT_DECL(node_heap, struct path_node*);

/// Comparator for binary heap of path nodes (minimum cost at top)
#define NODE_MINTOPCMP(i,j) ((i)->f_cost - (j)->f_cost)

#define calc_index(x,y) (((x)+(y)*MAX_WALKPATH_NAVI) & (MAX_WALKPATH_NAVI*MAX_WALKPATH_NAVI-1))

/// Estimates the cost from (x0,y0) to (x1,y1).
/// This is inadmissible (overestimating) heuristic used by game client.
#define heuristic(x0, y0, x1, y1) (MOVE_COST * (abs((x1) - (x0)) + abs((y1) - (y0)))) // Manhattan distance
/// @}

// Translates dx,dy into walking direction
static const unsigned char walk_choices [3][3] = {
	{1,0,7},
	{2,-1,6},
	{3,4,5},
};


#define SET_OPEN 0
#define SET_CLOSED 1

#define DIR_NORTH 1
#define DIR_WEST 2
#define DIR_SOUTH 4
#define DIR_EAST 8

/// @name A* pathfinding related functions
/// @{

/// Pushes path_node to the binary node_heap.
/// Ensures there is enough space in array to store new element.
static void heap_push_node(struct node_heap *heap, struct path_node *node)
{
#ifndef __clang_analyzer__ // TODO: Figure out why clang's static analyzer doesn't like this
	BHEAP_ENSURE(*heap, 1, 256);
	BHEAP_PUSH2(*heap, node, NODE_MINTOPCMP, swap_ptr);
#endif // __clang_analyzer__
}

/// Updates path_node in the binary node_heap.
static int heap_update_node(struct node_heap *heap, struct path_node *node)
{
	int i;
	ARR_FIND(0, BHEAP_LENGTH(*heap), i, BHEAP_DATA(*heap)[i] == node);
	if (i == BHEAP_LENGTH(*heap)) {
		ShowError("heap_update_node: node not found\n");
		return 1;
	}
	BHEAP_UPDATE(*heap, i, NODE_MINTOPCMP, swap_ptr);
	return 0;
}
/* end 1:1 copy of various definitions and static functions from path.c */

// Too large for the stack, and too slow to calloc/free.
static struct path_node tp[MAX_WALKPATH_NAVI * MAX_WALKPATH_NAVI + 1];
// Speed up (memsetting a smaller array, execution is over 5x faster)
static int tpused[MAX_WALKPATH_NAVI * MAX_WALKPATH_NAVI + 1];

// Append ID to the NPC data
struct npc_data_append {
	int npcid;
};

// Modified copy to better handle static *tp
/// Path_node processing in A* pathfinding.
/// Adds new node to heap and updates/re-adds old ones if necessary.
static int add_path(struct node_heap *heap, int16 x, int16 y, int g_cost, struct path_node *parent, int h_cost)
{
	int i = calc_index(x, y);

	if (tpused[i] && tpused[i] == 1+(x<<16 | y)) { // We processed this node before
		if (g_cost < tp[i].g_cost) { // New path to this node is better than old one
			// Update costs and parent
			tp[i].g_cost = g_cost;
			tp[i].parent = parent;
			tp[i].f_cost = g_cost + h_cost;
			if (tp[i].flag == SET_CLOSED) {
				heap_push_node(heap, &tp[i]); // Put it in open set again
			}
			else if (heap_update_node(heap, &tp[i])) {
				return 1;
			}
			tp[i].flag = SET_OPEN;
		}
		return 0;
	}

	if (tpused[i]) // Index is already taken; see `tp` array FIXME for details
		return 1;

	// New node
	tp[i].x = x;
	tp[i].y = y;
	tp[i].g_cost = g_cost;
	tp[i].parent = parent;
	tp[i].f_cost = g_cost + h_cost;
	tp[i].flag = SET_OPEN;
	tpused[i] = 1+(x<<16 | y);
	heap_push_node(heap, &tp[i]);
	return 0;
}
///@}

// Modification of path_search to better handle static *tp
/*==========================================
 * path search (x0,y0)->(x1,y1)
 * wpd: path info will be written here
 * flag: &1 = easy path search only
 * cell: type of obstruction to check for
 *------------------------------------------*/
static bool path_search_navi(struct walkpath_data_navi *wpd, int16 m, int16 x0, int16 y0, int16 x1, int16 y1, cell_chk cell)
{
	register int i, j, x, y, dx, dy;
	struct map_data *md;
	struct walkpath_data_navi s_wpd;

	if (wpd == NULL)
		wpd = &s_wpd; // use dummy output variable

	if (!map->list[m].cell)
		return false;
	md = &map->list[m];

	//Do not check starting cell as that would get you stuck.
	if (x0 < 0 || x0 >= md->xs || y0 < 0 || y0 >= md->ys /*|| md->getcellp(md,x0,y0,cell)*/)
		return false;

	// Check destination cell
	if (x1 < 0 || x1 >= md->xs || y1 < 0 || y1 >= md->ys || md->getcellp(md,x1,y1,cell))
		return false;

	if( x0 == x1 && y0 == y1 ) {
		wpd->path_len = 0;
		wpd->path_pos = 0;
		return true;
	}

	{ // !(flag&1)
		// A* (A-star) pathfinding
		// We always use A* for finding walkpaths because it is what game client uses.
		// Easy pathfinding cuts corners of non-walkable cells, but client always walks around it.

		BHEAP_STRUCT_VAR(node_heap, open_set); // 'Open' set

		// FIXME: This array is too small to ensure all paths shorter than MAX_WALKPATH_NAVI
		// can be found without node collision: calc_index(node1) = calc_index(node2).
		// Figure out more proper size or another way to keep track of known nodes.
		struct path_node *current, *it;
		int xs = md->xs - 1;
		int ys = md->ys - 1;
		int len = 0;
		memset(tpused, 0, sizeof(tpused));

		// Start node
		i = calc_index(x0, y0);
		tp[i].parent = NULL;
		tp[i].x      = x0;
		tp[i].y      = y0;
		tp[i].g_cost = 0;
		tp[i].f_cost = heuristic(x0, y0, x1, y1);
		tp[i].flag   = SET_OPEN;
		tpused[i] = 1+(x0<<16 | y0);

		heap_push_node(&open_set, &tp[i]); // Put start node to 'open' set

		for(;;) {
			int e = 0; // error flag

			// Saves allowed directions for the current cell. Diagonal directions
			// are only allowed if both directions around it are allowed. This is
			// to prevent cutting corner of nearby wall.
			// For example, you can only go NW from the current cell, if you can
			// go N *and* you can go W. Otherwise you need to walk around the
			// (corner of the) non-walkable cell.
			int allowed_dirs = 0;

			int g_cost;

			if (BHEAP_LENGTH(open_set) == 0) {
				BHEAP_CLEAR(open_set);
				return false;
			}

			current = BHEAP_PEEK(open_set); // Look for the lowest f_cost node in the 'open' set
			BHEAP_POP2(open_set, NODE_MINTOPCMP, swap_ptr); // Remove it from 'open' set

			x      = current->x;
			y      = current->y;
			g_cost = current->g_cost;

			current->flag = SET_CLOSED; // Add current node to 'closed' set

			if (x == x1 && y == y1) {
				BHEAP_CLEAR(open_set);
				break;
			}

			if (y < ys && !md->getcellp(md, x, y+1, cell)) allowed_dirs |= DIR_NORTH;
			if (y >  0 && !md->getcellp(md, x, y-1, cell)) allowed_dirs |= DIR_SOUTH;
			if (x < xs && !md->getcellp(md, x+1, y, cell)) allowed_dirs |= DIR_EAST;
			if (x >  0 && !md->getcellp(md, x-1, y, cell)) allowed_dirs |= DIR_WEST;

#define chk_dir(d) ((allowed_dirs & (d)) == (d))
			// Process neighbors of current node
			if (chk_dir(DIR_SOUTH|DIR_EAST) && !md->getcellp(md, x+1, y-1, cell))
				e += add_path(&open_set, x+1, y-1, g_cost + MOVE_DIAGONAL_COST, current, heuristic(x+1, y-1, x1, y1)); // (x+1, y-1) 5
			if (chk_dir(DIR_EAST))
				e += add_path(&open_set, x+1, y, g_cost + MOVE_COST, current, heuristic(x+1, y, x1, y1)); // (x+1, y) 6
			if (chk_dir(DIR_NORTH|DIR_EAST) && !md->getcellp(md, x+1, y+1, cell))
				e += add_path(&open_set, x+1, y+1, g_cost + MOVE_DIAGONAL_COST, current, heuristic(x+1, y+1, x1, y1)); // (x+1, y+1) 7
			if (chk_dir(DIR_NORTH))
				e += add_path(&open_set, x, y+1, g_cost + MOVE_COST, current, heuristic(x, y+1, x1, y1)); // (x, y+1) 0
			if (chk_dir(DIR_NORTH|DIR_WEST) && !md->getcellp(md, x-1, y+1, cell))
				e += add_path(&open_set, x-1, y+1, g_cost + MOVE_DIAGONAL_COST, current, heuristic(x-1, y+1, x1, y1)); // (x-1, y+1) 1
			if (chk_dir(DIR_WEST))
				e += add_path(&open_set, x-1, y, g_cost + MOVE_COST, current, heuristic(x-1, y, x1, y1)); // (x-1, y) 2
			if (chk_dir(DIR_SOUTH|DIR_WEST) && !md->getcellp(md, x-1, y-1, cell))
				e += add_path(&open_set, x-1, y-1, g_cost + MOVE_DIAGONAL_COST, current, heuristic(x-1, y-1, x1, y1)); // (x-1, y-1) 3
			if (chk_dir(DIR_SOUTH))
				e += add_path(&open_set, x, y-1, g_cost + MOVE_COST, current, heuristic(x, y-1, x1, y1)); // (x, y-1) 4
#undef chk_dir
			if (e) {
				BHEAP_CLEAR(open_set);
				return false;
			}
		}

		for (it = current; it->parent != NULL; it = it->parent, len++);
		if (len > sizeof(wpd->path)) {
			return false;
		}

		// Recreate path
		wpd->path_len = len;
		wpd->path_pos = 0;
		for (it = current, j = len-1; j >= 0; it = it->parent, j--) {
			dx = it->x - it->parent->x;
			dy = it->y - it->parent->y;
			wpd->path[j] = walk_choices[-dy + 1][dx + 1];
		}
		return true;
	} // A* end

	return false;
}

struct s_warplog_warp {
	struct {
		int map;
		int x;
		int y;
	} src;
	struct {
		int map;
		int x;
		int y;
	} dst;
	char *name;
	int gid;
};

struct s_map_npcdata {
	TBL_NPC *npcs[MAX_NPC_PER_MAP];
	int nnpcs;

	TBL_NPC *inner_warps[MAX_NPC_PER_MAP]; // Warps leading to this map
	struct s_warplog_warp *inner_links[MAX_NPC_PER_MAP];
	int ninner_warps;

	TBL_NPC *outer_warps[MAX_NPC_PER_MAP]; // Warps leading from this map
	struct s_warplog_warp *outer_links[MAX_NPC_PER_MAP];
	int nouter_warps;
};

struct s_npc_link_data {
	struct s_warplog_warp warps[100];
};

enum {
	WARPLOG_TYPE_WARP      = 200, // warp
	WARPLOG_TYPE_NPCSCRIPT = 201, // npc script (free?)
	WARPLOG_TYPE_KAFRA     = 202, // Kafra Dungeon Warp
	WARPLOG_TYPE_COOLEVENT = 203, // Cool Event Dungeon Warp
	WARPLOG_TYPE_NPCWARPER = 204, // Kafra/Cool Event/Alberta warp
	WARPLOG_TYPE_AIRPORT   = 205, // airport
};

void atcommand_createnavigationlua_sub_mob(FILE *fp, int m, struct mob_db *mobinfo, int amount, int mob_global_idx) {
	fprintf(fp, OUT_INDENT "{" OUT_SEPARATOR);
	fprintf(fp, OUT_INDENT OUT_INDENT "\"%s\"," OUT_SEPARATOR, map->list[m].name);     // Map gat
	fprintf(fp, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, mob_global_idx);            // Global ID
	fprintf(fp, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, mobinfo->mexp ? 301 : 300); // 300 = Normal, 301 = MVP
#if CLIENTVER >= 20140000
	fprintf(fp, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, (amount<<16)|mobinfo->vd.class_);
	                                                                                   // Spawn amount << 16 | Mob class
#else /* CLIENTVER < 20140000 */
	fprintf(fp, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, mobinfo->vd.class_);        // Mob Class
#endif /* CLIENTVER */
	fprintf(fp, OUT_INDENT OUT_INDENT "\"%s\"," OUT_SEPARATOR, mobinfo->jname);        // Mob Name
	fprintf(fp, OUT_INDENT OUT_INDENT "\"%s\"," OUT_SEPARATOR, mobinfo->sprite);       // Sprite Name
	fprintf(fp, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, mobinfo->lv);               // Mob Level
	fprintf(fp, OUT_INDENT OUT_INDENT "%u," OUT_SEPARATOR, ((mobinfo->status.ele_lv*20+mobinfo->status.def_ele) << 16) | ( mobinfo->status.size << 8 ) | mobinfo->status.race);
	                                                                                   // Element << 16 | Size << 8 | Race
	fprintf(fp, OUT_INDENT "},\n");
}

void atcommand_createnavigationlua_sub_map(FILE *fp, int m) {
	fprintf(fp, OUT_INDENT "{" OUT_SEPARATOR);
	fprintf(fp, OUT_INDENT OUT_INDENT "\"%s\"," OUT_SEPARATOR, map->list[m].name); // Map gat
	/*
	 * FIXME: The following field should be the user-visible name, but we don't have it anywhere.
	 * A possible improvement to this plugin would be to have it read mapnametable.txt and store them into a strdb.
	 */
	fprintf(fp, OUT_INDENT OUT_INDENT "\"%s\"," OUT_SEPARATOR, map->list[m].name); // Map Name
	fprintf(fp, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, strstr(map->list[m].name, "_in") ? 5003 : ( strstr(map->list[m].name, "air") ? 5002 : 5001 ) );
	                                                                               // 5001 = normal, 5002 = airport/airship, 5003 = indoor maps
	fprintf(fp, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, map->list[m].xs);       // Map size X
	fprintf(fp, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, map->list[m].ys);       // Map size Y
	fprintf(fp, OUT_INDENT "},\n");
}

void atcommand_createnavigationlua_sub_warp(FILE *fp_link, TBL_NPC *nd, int mnext, int nlink) {
	struct npc_data_append *nda;
	if( !(nda = getFromNPCD(nd, 0)) ) {
		ShowError("Unable to find NPC ID for NPC '%s'. Skipping...\n", nd->exname);
		return;
	}

	fprintf(fp_link, OUT_INDENT "{" OUT_SEPARATOR);
	fprintf(fp_link, OUT_INDENT OUT_INDENT "\"%s\"," OUT_SEPARATOR, map->list[nd->bl.m].name); // Map gat
	fprintf(fp_link, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, nda->npcid);                   // GID
	fprintf(fp_link, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, 200);                          // 200 = warp , 201 = npc script (free?), 202 = Kafra Dungeon Warp,
	                                                                                           // 203 = Cool Event Dungeon Warp, 204 Kafra/Cool Event/Alberta warp,
	                                                                                           // 205 = airport  (Currently we only support warps)
	fprintf(fp_link, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, (nd->vd->class_ == WARP_CLASS) ? 99999 : nd->vd->class_);
	                                                                                           // sprite id, 99999 = warp portal
	fprintf(fp_link, OUT_INDENT OUT_INDENT "\"%s_%s_%d\"," OUT_SEPARATOR, map->list[nd->bl.m].name, map->list[mnext].name, nlink);
	                                                                                           // Name
	fprintf(fp_link, OUT_INDENT OUT_INDENT "\"\"," OUT_SEPARATOR);                             // Unique Name
	fprintf(fp_link, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, nd->bl.x);                     // Link X
	fprintf(fp_link, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, nd->bl.y);                     // Link Y
	fprintf(fp_link, OUT_INDENT OUT_INDENT "\"%s\"," OUT_SEPARATOR, map->list[mnext].name);    // Link to Map
	fprintf(fp_link, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, nd->u.warp.x);                 // Link to X
	fprintf(fp_link, OUT_INDENT OUT_INDENT "%d" OUT_SEPARATOR, nd->u.warp.y);                  // Link to Y
	fprintf(fp_link, OUT_INDENT "},\n");
}

void atcommand_createnavigationlua_sub_npc(FILE *fp_npc, TBL_NPC *nd, int nnpc) {
	char visible_name[256];
	char *delimiter;
	struct npc_data_append *nda;

	if( !(nda = getFromNPCD(nd, 0)) ) {
		ShowError("Unable to find NPC ID for NPC '%s'. Skipping...\n", nd->exname);
		return;
	}

	safestrncpy(visible_name, nd->name, sizeof(visible_name));

	delimiter = strchr(visible_name,'#');
	if ( delimiter != 0 )
		*delimiter = 0;

	fprintf(fp_npc, OUT_INDENT "{" OUT_SEPARATOR);
	fprintf(fp_npc, OUT_INDENT OUT_INDENT "\"%s\"," OUT_SEPARATOR, map->list[nd->bl.m].name); // Map gat
	fprintf(fp_npc, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, nda->npcid);                   // GID
	fprintf(fp_npc, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, (nd->subtype == SHOP || nd->subtype == CASHSHOP) ? 102 : 101);
	                                                                                          // 101 = Npc, 102 = Trader
	fprintf(fp_npc, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, nd->class_);                   // Sprite ID
	fprintf(fp_npc, OUT_INDENT OUT_INDENT "\"%s\"," OUT_SEPARATOR, visible_name);             // NPC Name
	fprintf(fp_npc, OUT_INDENT OUT_INDENT "\"\"," OUT_SEPARATOR);                             // Unique Name
	fprintf(fp_npc, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, nd->bl.x);                     // X
	fprintf(fp_npc, OUT_INDENT OUT_INDENT "%d," OUT_SEPARATOR, nd->bl.y);                     // Y
	fprintf(fp_npc, OUT_INDENT "},\n");
}

bool createdirectory(const char *dirname) {
#ifdef WIN32
	if (!CreateDirectory(dirname, NULL)) {
		if (ERROR_ALREADY_EXISTS != GetLastError())
			return false;
	}
#else /* Not WIN32 */
	struct stat st = { 0 };
	if (stat(dirname, &st) == -1 ) {
		if (mkdir(dirname, 0755) != 0)
			return false;
	}
#endif // WIN32 check
	return true;
}

void writeheader(FILE *fp, const char *table_name) {
	time_t t = time(NULL);
	struct tm *lt = localtime(&t);

	fprintf(fp,
		"-- File generated by the Hercules naviluagenerator plugin\n"
		"-- http://hercules.ws / http://github.com/HerculesWS/StaffPlugins\n"
		"-- Last Change: %04d-%02d-%02d\n"
		"\n"
		"%s = {\n",
		lt->tm_year+1900, lt->tm_mon+1, lt->tm_mday, table_name);
}

// Converts NPC warp data to unified s_warplog_warp structure.
// Note that src.map / dst.map variables have map_ids instead of mapindices.
bool linkdata_convert(const struct s_map_npcdata *npcdata, int idx, bool inner, struct s_warplog_warp *out) {
	if (!out)
		return false;

	if ( ( inner && npcdata->inner_warps[idx] ) || ( !inner && npcdata->outer_warps[idx] ) ) {
		TBL_NPC *wnd = ( inner ? npcdata->inner_warps[idx] : npcdata->outer_warps[idx] );
		struct npc_data_append *wnda;
		if( !(wnda = getFromNPCD(wnd, 0)) ) {
			ShowError("Unable to find NPC ID for NPC '%s'. Skipping...\n", wnd->exname);
			return false;
		}
		out->gid = wnda->npcid;
		out->src.map = wnd->bl.m;
		out->src.x = wnd->bl.x;
		out->src.y = wnd->bl.y;
		out->dst.map = map->mapindex2mapid(wnd->u.warp.mapindex);
		out->dst.x = wnd->u.warp.x;
		out->dst.y = wnd->u.warp.y;
	} else {
		struct s_warplog_warp *warp = ( inner ? npcdata->inner_links[idx] : npcdata->outer_links[idx] );
		out->gid = warp->gid;
		out->src.map = map->mapindex2mapid(warp->src.map);
		out->src.x = warp->src.x;
		out->src.y = warp->src.y;
		out->dst.map = map->mapindex2mapid(warp->dst.map);
		out->dst.x = warp->dst.x;
		out->dst.y = warp->dst.y;
	}

	return true;
}

bool atcommand_createnavigationlua_sub(void) {
	int global_mob_idx = 17104;
	int n=0;
	int m;
	int mobidx, npcidx, warpidx;
	FILE *fp_mob, *fp_map, *fp_link, *fp_npc, *fp_npcdist, *fp_linkdist;
	int nlink = 0, nnpc = 0;

	struct s_map_npcdata *map_npcdata = NULL;

	struct walkpath_data_navi wpd;
	memset(&wpd, '\0', sizeof(wpd));

	ShowStatus("Creating navigation LUA files. This can take several minutes.\n");

	if (!createdirectory(DIRECTORYNAME)) {
		ShowError("do_navigationlua: Unable to create output directory.\n");
		return false;
	}

	fp_mob = fopen(DIRECTORYNAME PATHSEP_STR "navi_mob_" NAMESUFFIX ".lua", "wt+");
	fp_map = fopen(DIRECTORYNAME PATHSEP_STR "navi_map_" NAMESUFFIX ".lua", "wt+");
	fp_link = fopen(DIRECTORYNAME PATHSEP_STR "navi_link_" NAMESUFFIX ".lua", "wt+");
	fp_npc = fopen(DIRECTORYNAME PATHSEP_STR "navi_npc_" NAMESUFFIX ".lua", "wt+");
	fp_npcdist = fopen(DIRECTORYNAME PATHSEP_STR "navi_npcdistance_" NAMESUFFIX ".lua", "wt+");
	fp_linkdist = fopen(DIRECTORYNAME PATHSEP_STR "navi_linkdistance_" NAMESUFFIX ".lua", "wt+");

	if( !fp_mob || !fp_map || !fp_link || !fp_npc || !fp_npcdist || !fp_linkdist ) {
		ShowError("do_navigationlua: Unable to open output file.\n");
		return false;
	}

	map_npcdata = (struct s_map_npcdata *)aCalloc(sizeof(struct s_map_npcdata), map->count);

	ShowStatus("Stage 1: creating maps and objects list...\n");

	writeheader(fp_map, "Navi_Map");
	writeheader(fp_mob, "Navi_Mob");
	writeheader(fp_npc, "Navi_Npc");
	writeheader(fp_link, "Navi_Link");
	writeheader(fp_npcdist, "Navi_NpcDistance");
	writeheader(fp_linkdist, "Navi_Distance");

	for( m=0; m < map->count; m++ ) {
		//int nmapnpc=0;

		atcommand_createnavigationlua_sub_map(fp_map, m);

		// Warps/NPCs
		for( npcidx = 0; npcidx < map->list[m].npc_num; npcidx++ ) {
			TBL_NPC *nd = map->list[m].npc[npcidx];
			struct npc_data_append *nda;

			if( !nd )
				continue;

			if( !(nda = getFromNPCD(nd, 0)) ) {
				CREATE(nda,struct npc_data_append,1);
				addToNPCD(nd, nda, 0, true);
			}

			if( nd->subtype == WARP ) {
				int mnext = map->mapindex2mapid(nd->u.warp.mapindex);
				if( mnext < 0 )
					continue;
				nda->npcid = 13350 + nlink;

				atcommand_createnavigationlua_sub_warp(fp_link, nd, mnext, nlink);

				map_npcdata[mnext].inner_warps[map_npcdata[mnext].ninner_warps++] = nd;
				map_npcdata[m].outer_warps[map_npcdata[m].nouter_warps++] = nd;

				nlink++;
			} else {
				if( nd->class_ == -1 || nd->class_ == INVISIBLE_CLASS || nd->class_ == HIDDEN_WARP_CLASS || nd->class_ == FLAG_CLASS )
					continue;

				nda->npcid = 11984 + nnpc;

				atcommand_createnavigationlua_sub_npc(fp_npc, nd, nnpc);

				map_npcdata[m].npcs[map_npcdata[m].nnpcs] = nd;
				map_npcdata[m].nnpcs++;

				nnpc++;
			}
		}

		// Mobs
		for( mobidx=0; mobidx < MAX_MOB_LIST_PER_MAP; mobidx++ ) {
			struct mob_db *mobinfo;

			if( !map->list[m].moblist[mobidx] )
				continue;

			mobinfo = mob->db(map->list[m].moblist[mobidx]->class_);
			if( mobinfo == mob->dummy )
				continue;

			atcommand_createnavigationlua_sub_mob(fp_mob, m, mobinfo, map->list[m].moblist[mobidx]->num, global_mob_idx+n);

			n++;
		}
		ShowStatus("Created %s objects list (%d/%d)\n", map->list[m].name, m+1, map->count);
	}

	fprintf(fp_mob, "}\n");
	fclose(fp_mob);
	fprintf(fp_npc, "}\n");
	fclose(fp_npc);
	fprintf(fp_map, "}\n");
	fclose(fp_map);
	fprintf(fp_link, "}\n");
	fclose(fp_link);

	ShowStatus("Stage 2: Creating NPC distance tables...\n");

	// NPC distance lua
	for( m = 0; m < map->count; m++ ) {
		if( !map_npcdata[m].nnpcs || !map_npcdata[m].ninner_warps ) {
			ShowStatus("Skipped %s NPC distance table, no NPCs in map (%d/%d)\n", map->list[m].name, m+1, map->count);
			continue;
		}

		fprintf(fp_npcdist, OUT_INDENT "\"%s\", %d," OUT_SEPARATOR, map->list[m].name, map_npcdata[m].nnpcs); // Map gat, num of Objects
		fprintf(fp_npcdist, OUT_INDENT "{\n");

		for( npcidx = 0; npcidx < map_npcdata[m].nnpcs; npcidx++ ) {
			TBL_NPC *nd = map_npcdata[m].npcs[npcidx];
			struct npc_data_append *nda;

			if( !(nda = getFromNPCD(nd, 0)) ) {
				ShowError("Unable to find NPC ID for NPC '%s'. Skipping...\n", nd->exname);
				continue;
			}

			//int nwarps=0;

			fprintf(fp_npcdist, OUT_INDENT OUT_FINDENT "{ %d, -- GID (%s %s,%d,%d)\n", nda->npcid, nd->name, map->list[nd->bl.m].name, nd->bl.x, nd->bl.y); // NPC GID
			for( warpidx = 0; warpidx < map_npcdata[m].ninner_warps; warpidx++ ) {
				struct s_warplog_warp w;
				TBL_NPC *wnd = map_npcdata[m].inner_warps[warpidx];
				struct npc_data_append *wnda;
				if (!linkdata_convert(&map_npcdata[m], warpidx, true, &w))
					continue;

				if( !(wnda = getFromNPCD(wnd, 0)) ) {
					ShowError("Unable to find NPC ID for NPC '%s'. Skipping...\n", wnd->exname);
					continue;
				}

				if( !path_search_navi(&wpd, m, nd->bl.x, nd->bl.y, wnd->u.warp.x, wnd->u.warp.y, CELL_CHKNOREACH) )
					continue;

				fprintf(fp_npcdist, OUT_INDENT OUT_FINDENT OUT_FINDENT "{ \"%s\", %d, %d }, -- Srcmap, gid, dist (%s,%d,%d)\n", map->list[w.src.map].name, w.gid, wpd.path_len, map->list[w.src.map].name, w.src.x, w.src.y);
			}
			fprintf(fp_npcdist, OUT_INDENT OUT_FINDENT OUT_FINDENT "{ \"\", 0, 0 }\n");
			fprintf(fp_npcdist, OUT_INDENT OUT_FINDENT "},\n");
		}

		fprintf(fp_npcdist, OUT_INDENT "},\n");

		ShowStatus("Created %s NPC distance table (%d/%d)\n", map->list[m].name, m+1, map->count);
	}

	fprintf(fp_npcdist, "}\n");
	fclose(fp_npcdist);

	ShowStatus("Stage 3: Creating Warp distance tables...\n");

	for( m = 0; m < map->count; m++ ) {
		fprintf(fp_linkdist, OUT_INDENT "\"%s\",%d," OUT_SEPARATOR, map->list[m].name, map_npcdata[m].nouter_warps); // Map gat, num of outer warps
		fprintf(fp_linkdist, OUT_INDENT "{\n");

		for( warpidx = 0; warpidx < map_npcdata[m].nouter_warps; warpidx++ ) {
			int warpidx2;
			struct s_warplog_warp w1;
			if (!linkdata_convert(&map_npcdata[m], warpidx, false, &w1))
				continue;

			fprintf(fp_linkdist, OUT_INDENT OUT_FINDENT "{ %d, -- GID (%s,%d,%d)\n", w1.gid, map->list[w1.src.map].name, w1.src.x, w1.src.y); // Warp GID

			// ReachableFromSrc warps
			for( warpidx2 = 0; warpidx2 < map_npcdata[m].nouter_warps; warpidx2++ ) {
				struct s_warplog_warp w2;

				if ( warpidx == warpidx2 )
					continue;

				if (!linkdata_convert(&map_npcdata[m], warpidx2, false, &w2))
					continue;

				if( !path_search_navi(&wpd, m, w1.src.x, w1.src.y, w2.src.x, w2.src.y, CELL_CHKNOREACH) )
					continue;

				fprintf(fp_linkdist, OUT_INDENT OUT_FINDENT OUT_FINDENT "{ \"P\", %d, %d }, -- ReachableFromSrc warp (%s,%d,%d)\n", w2.gid, wpd.path_len, map->list[m].name, w2.src.x, w2.src.y); // ReachableFromSrc warp
			}

			// ReachableFromDst warps
			for( warpidx2 = 0; warpidx2 < map_npcdata[w1.dst.map].nouter_warps; warpidx2++ ) {
				struct s_warplog_warp w2;

				if (!linkdata_convert(&map_npcdata[w1.dst.map], warpidx2, false, &w2))
					continue;

				if( !path_search_navi(&wpd, w1.dst.map, w1.dst.x, w1.dst.y, w2.src.x, w2.src.y, CELL_CHKNOREACH) )
					continue;

				fprintf(fp_linkdist, OUT_FINDENT OUT_FINDENT OUT_FINDENT "{ \"E\", %d, %d }, -- ReachableFromDst warp (%s,%d,%d)\n", w2.gid, wpd.path_len, map->list[w1.dst.map].name, w2.src.x, w2.src.y); // ReachableFromDst warp
			}
			fprintf(fp_linkdist, OUT_INDENT OUT_FINDENT OUT_FINDENT "{ \"NULL\", 0, 0 }\n");
			fprintf(fp_linkdist, OUT_INDENT OUT_FINDENT "},\n");
		}
		fprintf(fp_linkdist, OUT_INDENT "},\n");
		ShowStatus("Created %s Warp distance table (%d/%d)\n", map->list[m].name, m+1, map->count);
	}

	aFree(map_npcdata);

	fprintf(fp_linkdist, "}\n");
	fclose(fp_linkdist);

	ShowStatus("Finished creating navigation LUA files successfully\n");

	return true;
}

void do_navigationlua(struct map_session_data *sd) {
	if ( !atcommand_createnavigationlua_sub() ) {
		ShowError("Failed to create navigation LUA files\n");
		if ( sd ) clif->message(sd->fd, "Failed to create navigation LUA files");
	} else {
		ShowStatus("File has been generated.\n");
		if ( sd ) clif->message(sd->fd, "File has been generated.");
	}
}

ACMD(createnavigationlua) {
	do_navigationlua(sd);
	return true;
}

CPCMD(createnavigationlua) {
	do_navigationlua(map->cpsd);
}
HPExport void server_preinit(void) {
	map = GET_SYMBOL("map");
	iMalloc = GET_SYMBOL("iMalloc");
	clif = GET_SYMBOL("clif");
	mob = GET_SYMBOL("mob");
	strlib = GET_SYMBOL("strlib");
}
HPExport void plugin_init(void) {
	addCPCommand("server:tools:navigationlua", createnavigationlua);
	addAtcommand("createnavigationlua", createnavigationlua)
}
