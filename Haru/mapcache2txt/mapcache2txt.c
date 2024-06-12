/**
 * This file is part of Hercules.
 * http://herc.ws - http://github.com/HerculesWS/Hercules
 *
 * Copyright (C) 2013-2024  Hercules Dev Team
 *
 * Hercules is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Mapcache Plugin
 * This Plugin is made to handle the creation and update the new format of mapcache
 * it also handles the convertion from the old to the new mapcache format
 **/

#include "common/hercules.h" /* Should always be the first Hercules file included! (if you don't make it first, you won't be able to use interfaces) */

#include "common/grfio.h"
#include "common/memmgr.h"
#include "common/nullpo.h"
#include "common/showmsg.h"
#include "common/strlib.h"
#include "common/utils.h"
#include "map/map.h"

#include "common/HPMDataCheck.h" /* should always be the last Hercules file included! (if you don't make it last, it'll intentionally break compile time) */

#include <zlib.h>
#include <stdio.h>
#include <string.h>

HPExport struct hplugin_info pinfo = {
	"mapcachedump",  ///< Plugin name
	SERVER_TYPE_MAP, ///< Which server types this plugin works with?
	"1.0.0",         ///< Plugin version
	HPM_VERSION,     ///< HPM Version (don't change, macro is automatically updated)
};

#define DUMP_FORMAT_TXT
//#define DUMP_FORMAT_JSON
//#define DUMP_FORMAT_LIBCONFIG

#if defined(DUMP_FORMAT_TXT)
#define DUMP_FILE_EXTENSION ".txt"
#define DUMP_INDENTATION ""
#endif
#if defined(DUMP_FORMAT_JSON)
#define DUMP_FILE_EXTENSION ".json"
#define DUMP_INDENTATION "  "
#endif
#if defined(DUMP_FORMAT_LIBCONFIG)
#define DUMP_FILE_EXTENSION ".conf"
#define DUMP_INDENTATION "\t"
#endif
#ifndef DUMP_FILE_EXTENSION
#error No defined export file type
#endif

bool dump_all = false;           ///< Whether to dump all maps.
VECTOR_DECL(char *) dump_list;

static void mcache_dump_sub_startroot(FILE *fp)
{
	nullpo_retv(fp);

#if defined(DUMP_FORMAT_JSON)
	fprintf(fp, "{\n");
#elif defined(DUMP_FORMAT_LIBCONFIG)
	fprintf(fp, "maps: {\n");
#endif
}

static void mcache_dump_sub_endroot(FILE *fp)
{
	nullpo_retv(fp);

#if defined(DUMP_FORMAT_JSON) || defined(DUMP_FORMAT_LIBCONFIG)
	fprintf(fp, "}");
#endif
}

static void mcache_dump_sub_startmap(FILE *fp, const char *name, const char *indent)
{
	nullpo_retv(fp);
	nullpo_retv(name);
	nullpo_retv(indent);

#if defined(DUMP_FORMAT_TXT)
	fprintf(fp, "%s# %s\n", indent, name);
#elif defined(DUMP_FORMAT_JSON)
	fprintf(fp, "%s\"%s\": {\n", indent, name);
#elif defined(DUMP_FORMAT_LIBCONFIG)
	fprintf(fp, "%s%s: {\n", indent, name);
#endif
}

static void mcache_dump_sub_endmap(FILE *fp, const char *indent)
{
	nullpo_retv(fp);
	nullpo_retv(indent);

#if defined(DUMP_FORMAT_TXT)
	fprintf(fp, "\n");
#elif defined(DUMP_FORMAT_JSON) || defined(DUMP_FORMAT_LIBCONFIG)
	fprintf(fp, "%s}\n", indent);
#endif
}

static void mcache_dump_sub_mapextents(FILE *fp, const struct map_data *mapdata, const char *indent)
{
	nullpo_retv(fp);
	nullpo_retv(mapdata);
	nullpo_retv(indent);

#if defined(DUMP_FORMAT_TXT)
	fprintf(fp, "%s" DUMP_INDENTATION "size: %hd x %hd\n", indent, mapdata->xs, mapdata->ys);
#elif defined(DUMP_FORMAT_JSON)
	fprintf(fp, "%s" DUMP_INDENTATION "\"size\": [%hd, %hd],\n", indent, mapdata->xs, mapdata->ys);
#elif defined(DUMP_FORMAT_LIBCONFIG)
	fprintf(fp, "%s" DUMP_INDENTATION "size: [%hd, %hd], \n", indent, mapdata->xs, mapdata->ys);
#endif
}

static void mcache_dump_sub_startmapcells(FILE *fp, const char *indent)
{
	nullpo_retv(fp);
	nullpo_retv(indent);

#if defined(DUMP_FORMAT_JSON)
	fprintf(fp, "%s" DUMP_INDENTATION "\"cells\": [\n", indent);
#elif defined(DUMP_FORMAT_LIBCONFIG)
	fprintf(fp, "%s" DUMP_INDENTATION "cells: [\n", indent);
#endif
}

static void mcache_dump_sub_mapcelldata(FILE *fp, const struct map_data *mapdata, const char *indent)
{
	nullpo_retv(fp);
	nullpo_retv(mapdata);
	nullpo_retv(indent);

	if (mapdata->cell_buf.data != NULL) {
		uint8 buffer[MAX_MAP_SIZE];
		unsigned long size = (unsigned long)mapdata->xs * (unsigned long)mapdata->ys;
		if (grfio->decode_zip(buffer, &size, mapdata->cell_buf.data, mapdata->cell_buf.len) == Z_OK) {
			int x, y;
			for (y = 0; y < mapdata->ys; y++) {
				fprintf(fp, "%s" DUMP_INDENTATION DUMP_INDENTATION, indent);
				for (x = 0; x < mapdata->xs; x++) {
#if defined(DUMP_FORMAT_TXT)
					// inverted row order
					fprintf(fp, "%01x", (unsigned int)buffer[x + (mapdata->ys - y - 1) * mapdata->xs] & 0x0f);
#elif defined(DUMP_FORMAT_JSON)
					fprintf(fp, "%01x%s ",
					        (unsigned int)(buffer[x + y * mapdata->xs]) & 0x0f,
					        (x == mapdata->xs - 1 && y == mapdata->ys - 1) ? "" : ",");
#elif defined(DUMP_FORMAT_LIBCONFIG)
					fprintf(fp, "%01x, ", (unsigned int)buffer[x + y * mapdata->xs] & 0x0f);
#endif
				}
				fprintf(fp, "\n");
			}
		}
	}
}

static void mcache_dump_sub_endmapcells(FILE *fp, const char *indent)
{
	nullpo_retv(fp);
	nullpo_retv(indent);

#if defined(DUMP_FORMAT_JSON) || defined(DUMP_FORMAT_LIBCONFIG)
	fprintf(fp, "%s" DUMP_INDENTATION "]\n", indent);
#endif
}

static bool mcache_dump_sub(FILE *fp, const struct map_data *mapdata, const char *indent)
{
	nullpo_retr(false, fp);
	nullpo_retr(false, mapdata);
	nullpo_retr(false, indent);

	mcache_dump_sub_startmap(fp, mapdata->name, indent);
	mcache_dump_sub_mapextents(fp, mapdata, indent);

	mcache_dump_sub_startmapcells(fp, indent);
	mcache_dump_sub_mapcelldata(fp, mapdata, indent);
	mcache_dump_sub_endmapcells(fp, indent);

	mcache_dump_sub_endmap(fp, indent);

	return true;
}

static bool mcache_dump_all(void)
{
	int i;
	bool retval = true;
	const char *map_cache_dump_file = "mcache_dump_all" DUMP_FILE_EXTENSION;
	FILE *fp = fopen(map_cache_dump_file, "w");
	if (fp == NULL) {
		ShowError("Failure when opening map cache dump file %s\n", map_cache_dump_file);
		return false;
	}

	ShowStatus("Extracting map information...\n");

	mcache_dump_sub_startroot(fp);

	for (i = 0; i < map->count; i++) {
		ShowMessage("- %s (%d/%d)\n", map->list[i].name, i + 1, map->count);
		if (!mcache_dump_sub(fp, &map->list[i], DUMP_INDENTATION))
			retval = false;
	}

	mcache_dump_sub_endroot(fp);

	fclose(fp);
	ShowStatus("Extracted mapcache information to '%s'.\n", map_cache_dump_file);

	return retval;
}

static bool mcache_dump_map(const char *mapname)
{
	int i;
	bool retval = false;
	char filename[256] = "";
	FILE *fp = NULL;

	ARR_FIND(0, map->count, i, strcmp(map->list[i].name, mapname) == 0);

	if (i == map->count) {
		ShowError("Map not found: '%s'.\n", mapname);
		return false;
	}

	ShowStatus("Extracting map information (%s)...\n", mapname);

	snprintf(filename, sizeof filename, "mcache_dump_%s" DUMP_FILE_EXTENSION, mapname);
	fp = fopen(filename, "w");
	if (fp == NULL) {
		ShowError("Could not open the output file %s.\n", filename);
		return false;
	}
	retval = mcache_dump_sub(fp, &map->list[i], "");
	fclose(fp);

	ShowStatus("Extracted mapcache information to '%s'.\n", filename);
	return retval;
}

static bool mcache_readfromcache(struct map_data *m, const char *file_path)
{
	unsigned int file_size;
	FILE *fp = NULL;
	bool retval = false;
	int16 version;

	nullpo_retr(false, m);
	nullpo_retr(false, file_path);

	fp = fopen(file_path, "rb");

	if (fp == NULL) {
		ShowWarning("map_readfromcache: Could not open the mapcache file for map '%s' at path '%s'.\n", m->name, file_path);
		return false;
	}

	if (fread(&version, sizeof(version), 1, fp) < 1) {
		ShowError("map_readfromcache: Could not read file version for map '%s'.\n", m->name);
		fclose(fp);
		return false;
	}

	fseek(fp, 0, SEEK_END);
	file_size = (unsigned int)ftell(fp);
	fseek(fp, 0, SEEK_SET); // Rewind file pointer before passing it to the read function.

	switch(version) {
	case 1:
		retval = map->readfromcache_v1(fp, m, file_size);
		break;
	default:
		ShowError("map_readfromcache: Mapcache file has unknown version '%d' for map '%s'.\n", version, m->name);
		break;
	}

	fclose(fp);
	return retval;
}

static bool mcache_dump_mcache(const char *filename)
{
	struct map_data mapdata = {{ 0 }};
	char *filenamebuf = NULL;
	const char *basename = NULL, *last_dot = NULL;
	FILE *fp = NULL;
	bool retval = false;
	char out_filename[256] = "";

	basename = strrchr(filename, '/');
#ifdef WIN32
	{
		const char *basename_windows = strrchr(filename, '\\');
		if (basename_windows > basename)
			basename = basename_windows;
	}
#endif // WIN32
	if (basename == NULL)
		basename = filename;
	else
		basename++; // Skip slash

	if (*basename == '\0') {
		ShowError("Invalid map name: %s.\n", filename);
		return false;
	}

	last_dot = strrchr(basename, '.');
	if (last_dot != NULL) {
		if (last_dot == basename) {
			basename++;
		} else {
			filenamebuf = aStrndup(basename, last_dot - basename);
			basename = filenamebuf;
		}
	}

	safestrncpy(mapdata.name, basename, sizeof mapdata.name);

	if (!mcache_readfromcache(&mapdata, filename)) {
		ShowError("Unable to read mapcache for map '%s'.\n", basename);
		if (filenamebuf != NULL)
			aFree(filenamebuf);
		return false;
	}

	ShowStatus("Extracting map information (%s)...\n", basename);
	snprintf(out_filename, sizeof out_filename, "mcache_dump_%s" DUMP_FILE_EXTENSION, basename);
	if (filenamebuf != NULL) {
		aFree(filenamebuf);
		basename = NULL;
	}
	fp = fopen(out_filename, "w");
	if (fp == NULL) {
		ShowError("Could not open the output file %s.\n", out_filename);
		return false;
	}

	retval = mcache_dump_sub(fp, &mapdata, "");

	ShowStatus("Extracted mapcache information to '%s'.\n", out_filename);
	fclose(fp);
	return retval;
}

/**
 * --map-cache-dump handler
 *
 * Overrides the default map cache dump filename.
 * @see cmdline->exec
 */
CMDLINEARG(dumpall)
{
	dump_all = true;
	return true;
}

CMDLINEARG(dumpmap)
{
	char *map_name = aStrdup(params);
	VECTOR_ENSURE(dump_list, 1, 1);
	VECTOR_PUSH(dump_list, map_name);
	return true;
}

CMDLINEARG(dumpmcache)
{
	mcache_dump_mcache(params);
	return true;
}

HPExport void server_preinit(void)
{
	map->minimal = true;
	addArg("--dump-map", true, dumpmap,
			"Dumps the data from a loaded map (by map name) to a " DUMP_FILE_EXTENSION " file.");
	addArg("--dump-mcache", true, dumpmcache,
			"Dumps the data from a .mcache file (by file name) to a " DUMP_FILE_EXTENSION " file.");
	addArg("--dump-all", false, dumpall,
			"Dumps the data from all the loaded maps to a " DUMP_FILE_EXTENSION " file.");

	VECTOR_INIT(dump_list);
}

HPExport void server_online(void)
{
	if (dump_all) {
		mcache_dump_all();
	} else {
		int i;
		for (i = 0; i < VECTOR_LENGTH(dump_list); i++) {
			mcache_dump_map(VECTOR_INDEX(dump_list, i));
		}
	}
}

HPExport void plugin_final(void)
{
	while (VECTOR_LENGTH(dump_list) > 0) {
		char *name = VECTOR_POP(dump_list);
		aFree(name);
	}
	VECTOR_CLEAR(dump_list);
}
