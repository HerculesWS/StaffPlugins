/*
 * Copyright (c) Hercules Dev Team
 * Base author: Haru <haru@dotalux.com>
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

/// Vim syntax highlighter generator

#include "common/hercules.h"
#include "common/cbasetypes.h"
#include "common/memmgr.h"
#include "common/strlib.h"
#include "map/itemdb.h"
#include "map/map.h"
#include "map/mob.h"
#include "map/script.h"
#include "map/skill.h"

#include "common/HPMDataCheck.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>

#if !defined(LINE_LENGTH) || LINE_LENGTH < 72
#define LINE_LENGTH 120
#endif // LINE_LENGTH
#if !defined(SYNTAXLANGUAGE)
#define SYNTAXLANGUAGE "herc"
#endif // SYNTAXLANGUAGE
#if !defined(DIRECTORYNAME)
#define DIRECTORYNAME "vimsyntax"
#endif // DIRECTORYNAME
#define SYNKEYWORDPREFIX "syn keyword "
#define SYNMATCHPREFIX "syn match "

HPExport struct hplugin_info pinfo = {
	"vimsyntaxgen",  // Plugin name
	SERVER_TYPE_MAP, // Which server types this plugin works with?
	"0.1",           // Plugin version
	HPM_VERSION,     // HPM Version (don't change, macro is automatically updated)
};

struct {
	FILE *fp;
	struct {
		char prefix[64];
		char separator[8];
		char terminator[8];
		char line[LINE_LENGTH+1];
	} output;
} local;
bool torun = false;

void vimsyntaxgen_flush(int blanklines) {
	int i;
	if (local.output.line[0]) {
		fprintf(local.fp, "%s%s%s\n", local.output.prefix[0] ? local.output.prefix : "",
				local.output.line, local.output.terminator[0] ? local.output.terminator : "");
	}
	local.output.line[0] = '\0';
	for (i = 0; i < blanklines; i++)
		fprintf(local.fp, "\n");
}

void vimsyntaxgen_set(const char *prefix, const char *separator, const char *terminator) {
	safestrncpy(local.output.prefix, prefix, sizeof(local.output.prefix));
	safestrncpy(local.output.separator, separator, sizeof(local.output.separator));
	safestrncpy(local.output.terminator, terminator, sizeof(local.output.terminator));
}

void vimsyntaxgen_append(const char *str) {
	size_t len = strlen(str);
	size_t baselen = strlen(local.output.prefix) + strlen(local.output.terminator);
	if (len + baselen >= LINE_LENGTH) {
		ShowWarning("string %s is too long, skipping.\n", str);
		return;
	}
	if (baselen + (local.output.line[0] ? strlen(local.output.line) + strlen(local.output.separator) : 0) + len >= LINE_LENGTH)
		vimsyntaxgen_flush(0);

	if (local.output.line[0]) {
		safestrncpy(local.output.line + strlen(local.output.line), local.output.separator, sizeof(local.output.line) - strlen(local.output.line));
	}
	safestrncpy(local.output.line + strlen(local.output.line), str, sizeof(local.output.line) - strlen(local.output.line));
}

/// To override script_set_constant, called by script_read_constdb
void vimsyntaxgen_script_set_constant(const char* name, int value, bool isparameter) {
	static char lastprefix[7] = { 0 };
	static size_t lastlen = 0;
	static bool lastwasparameter = false;
	char *underscore = NULL;

	if ((underscore = strchr(name, '_'))) {
		size_t len = 0;
		if (underscore < name)
			len = 0;
		else
			len = underscore-name;
		if (len > sizeof(lastprefix) - 1 || atoi(name) != 0)
			len = 0;
		if (len != lastlen || strncmp(lastprefix, name, len) != 0) {
			vimsyntaxgen_flush(0);
			safestrncpy(lastprefix, name, len+1);
			lastlen = len;
		}
	}
	if (isparameter != lastwasparameter) {
		vimsyntaxgen_flush(0);
		if (isparameter)
			vimsyntaxgen_set(SYNKEYWORDPREFIX"hParam ", " ", "");
		else
			vimsyntaxgen_set(SYNKEYWORDPREFIX"hConstant ", " ", "");
		lastwasparameter = isparameter;
	}
	vimsyntaxgen_append(name);
}

void vimsyntaxgen_constdb(void) {
	void (*script_set_constant) (const char* name, int value, bool isparameter) = NULL;
	/* Link */
	script_set_constant = script->set_constant;
	script->set_constant = vimsyntaxgen_script_set_constant;

	/* Run */
	fprintf(local.fp, "\" Constants (imported from db/const.txt)\n");
	vimsyntaxgen_set(SYNKEYWORDPREFIX"hConstant ", " ", "");
	script->read_constdb();
	script->hardcoded_constants();
	vimsyntaxgen_flush(1);

	/* Unlink */
	script->set_constant = script_set_constant;
}

/// Cloned from mapindex_init
void vimsyntaxgen_mapdb(void) {
	FILE *mfp;
	char line[1024];
	int index;
	char map_name[MAP_NAME_LENGTH];
	char *mapindex_cfgfile = "db/map_index.txt";

	fprintf(local.fp, "\" Maps (imported from db/map_index.txt)\n");
	vimsyntaxgen_set(SYNMATCHPREFIX"hMapName contained display \"\\%(", "\\|", "\\)\"");
	if( ( mfp = fopen(mapindex_cfgfile,"r") ) == NULL ){
		ShowFatalError("Unable to read mapindex config file %s!\n", mapindex_cfgfile);
		return;
	}
	while(fgets(line, sizeof(line), mfp)) {
		if(line[0] == '/' && line[1] == '/')
			continue;

		switch (sscanf(line, "%11s\t%d", map_name, &index)) {
			case 1:
			case 2:
				vimsyntaxgen_append(map_name);
				break;
			default:
				continue;
		}
	}
	fclose(mfp);
	vimsyntaxgen_flush(1);

	return;
}

void vimsyntaxgen_skilldb(void) {
	int i;

	fprintf(local.fp, "\" Skills (imported from db/*/skill_db.txt)\n");
	vimsyntaxgen_set(SYNKEYWORDPREFIX"hSkillId ", " ", "");
	for (i = 1; i < MAX_SKILL_DB; i++) {
		if (skill->dbs->db[i].name[0])
			vimsyntaxgen_append(skill->dbs->db[i].name);
	}
	vimsyntaxgen_flush(1);
}

void vimsyntaxgen_mobdb(void) {
	int i;

	fprintf(local.fp, "\" Mobs (imported from db/*/mob_db.txt)\n");
	vimsyntaxgen_set(SYNKEYWORDPREFIX"hMobId ", " ", "");
	for (i = 0; i < MAX_MOB_DB; i++) {
		struct mob_db *md = mob->db(i);
		if (md == mob->dummy || !md->sprite[0])
			continue;
		vimsyntaxgen_append(md->sprite);
	}
	vimsyntaxgen_flush(1);
}

/// Cloned from itemdb_search
struct item_data* vimsyntaxgen_itemdb_search(int nameid) {
	struct item_data* id;
	if( nameid >= 0 && nameid < ARRAYLENGTH(itemdb->array) )
		id = itemdb->array[nameid];
	else
		id = (struct item_data*)idb_get(itemdb->other, nameid);

	if( id == NULL ) {
		return NULL;
	}
	return id;
}

void vimsyntaxgen_itemdb(void) {
	int i;

	fprintf(local.fp, "\" Items (imported from db/*/item_db.conf)\n");
	vimsyntaxgen_set(SYNKEYWORDPREFIX"hItemId ", " ", "");
	for (i = 0; i < ARRAYLENGTH(itemdb->array); i++) {
		struct item_data *id = vimsyntaxgen_itemdb_search(i);
		if (!id || !id->name[0])
			continue;
		vimsyntaxgen_append(id->name);
	}
	vimsyntaxgen_flush(1);
}

#define CMD_PUSH(cmd) { cmd, false }
struct cmd_info {
	char *name;
	bool found;
};
struct cmd_info cmd_hKeyword[] = {
	CMD_PUSH("end"),
	CMD_PUSH("close"),
	CMD_PUSH("close2"),
	CMD_PUSH("next"),
	CMD_PUSH("return"),
	CMD_PUSH("callfunc"),
	CMD_PUSH("callsub"),
};
struct cmd_info cmd_hDeprecated[] = {
	CMD_PUSH("menu"),
	CMD_PUSH("goto"),
	CMD_PUSH("set"),
};
struct cmd_info cmd_hStatement[] = {
	CMD_PUSH("mes"),
	CMD_PUSH("select"),
	CMD_PUSH("prompt"),
	CMD_PUSH("getarg"),
	CMD_PUSH("input"),
	CMD_PUSH("setarray"),
	CMD_PUSH("cleararray"),
	CMD_PUSH("copyarray"),
	CMD_PUSH("getarraysize"),
	CMD_PUSH("deletearray"),
	CMD_PUSH("getelementofarray"),
	CMD_PUSH("getd"),
	CMD_PUSH("setd"),
	CMD_PUSH("sleep"),
	CMD_PUSH("sleep2"),
	CMD_PUSH("awake"),
};
struct cmd_info *cmd_hDeprecatedExtra = NULL;
int cmd_hDeprecatedExtra_count = 0;
#undef CMD_PUSH

bool vimsyntaxgen_script_add_builtin(const struct script_function *buildin, bool override) {
	int i;
	if (!buildin)
		return false;
	if (strncmp("__", buildin->name, 2) == 0) // Skip internal commands
		return false;
	if (buildin->deprecated) {
		RECREATE(cmd_hDeprecatedExtra, struct cmd_info, ++cmd_hDeprecatedExtra_count);
		cmd_hDeprecatedExtra[cmd_hDeprecatedExtra_count-1].name = aStrdup(buildin->name);
		cmd_hDeprecatedExtra[cmd_hDeprecatedExtra_count-1].found = true;
		return false;
	}
	for (i = 0; i < ARRAYLENGTH(cmd_hKeyword); i++) {
		if (strcmp(cmd_hKeyword[i].name, buildin->name) != 0)
			continue;
		cmd_hKeyword[i].found = true;
		return false;
	}
	for (i = 0; i < ARRAYLENGTH(cmd_hDeprecated); i++) {
		if (strcmp(cmd_hDeprecated[i].name, buildin->name) != 0)
			continue;
		cmd_hDeprecated[i].found = true;
		return false;
	}
	for (i = 0; i < ARRAYLENGTH(cmd_hStatement); i++) {
		if (strcmp(cmd_hStatement[i].name, buildin->name) != 0)
			continue;
		cmd_hStatement[i].found = true;
		return false;
	}
	vimsyntaxgen_append(buildin->name);
	return false;
}

void vimsyntaxgen_scriptcmd(void) {
	int i;
	bool (*script_add_builtin) (const struct script_function *buildin, bool override) = NULL;

	/* Link */
	script_add_builtin = script->add_builtin;
	script->add_builtin = vimsyntaxgen_script_add_builtin;

	/* Run */
	fprintf(local.fp, "\" Script Commands (imported from src/map/script.c)\n");

	vimsyntaxgen_set(SYNKEYWORDPREFIX"hCommand ", " ", "");
	script->parse_builtin();
	vimsyntaxgen_flush(0);

	vimsyntaxgen_set(SYNKEYWORDPREFIX"hKeyword ", " ", "");
	for (i = 0; i < ARRAYLENGTH(cmd_hKeyword); i++) {
		if (!cmd_hKeyword[i].found) {
			ShowWarning("Command %s was not found.\n", cmd_hKeyword[i].name);
			continue;
		}
		vimsyntaxgen_append(cmd_hKeyword[i].name);
	}
	vimsyntaxgen_flush(0);

	vimsyntaxgen_set(SYNKEYWORDPREFIX"hDeprecated ", " ", "");
	for (i = 0; i < ARRAYLENGTH(cmd_hDeprecated); i++) {
		if (!cmd_hDeprecated[i].found) {
			ShowWarning("Command %s was not found.\n", cmd_hDeprecated[i].name);
			continue;
		}
		vimsyntaxgen_append(cmd_hDeprecated[i].name);
	}
	if (cmd_hDeprecatedExtra) {
		for (i = 0; i < cmd_hDeprecatedExtra_count; i++) {
			vimsyntaxgen_append(cmd_hDeprecatedExtra[i].name);
			aFree(cmd_hDeprecatedExtra[i].name);
			cmd_hDeprecatedExtra[i].name = NULL;
		}
		aFree(cmd_hDeprecatedExtra);
		cmd_hDeprecatedExtra = NULL;
	}
	vimsyntaxgen_flush(0);

	vimsyntaxgen_set(SYNKEYWORDPREFIX"hStatement ", " ", "");
	for (i = 0; i < ARRAYLENGTH(cmd_hStatement); i++) {
		if (!cmd_hStatement[i].found) {
			ShowWarning("Command %s was not found.\n", cmd_hStatement[i].name);
			continue;
		}
		vimsyntaxgen_append(cmd_hStatement[i].name);
	}
	vimsyntaxgen_flush(1);

	/* Unlink */
	script->add_builtin = script_add_builtin;
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

void writeheader(const char *description) {
	time_t t = time(NULL);
	struct tm *lt = localtime(&t);

	fprintf(local.fp,
		"\" %s\n"
		"\" Language:    Hercules/*Athena Script\n"
		"\" Maintainer:  Haru <haru@dotalux.com>\n"
		"\" Last Change: %04d-%02d-%02d\n"
		"\n\n", description, lt->tm_year+1900, lt->tm_mon+1, lt->tm_mday);
}

void do_vimsyntaxgen(void) {
	memset(&local, 0, sizeof(local));

	if (!createdirectory(DIRECTORYNAME)
	 || !createdirectory(DIRECTORYNAME PATHSEP_STR "ftdetect")
	 || !createdirectory(DIRECTORYNAME PATHSEP_STR "ftplugin")
	 || !createdirectory(DIRECTORYNAME PATHSEP_STR "indent")
	 || !createdirectory(DIRECTORYNAME PATHSEP_STR "syntastic")
	 || !createdirectory(DIRECTORYNAME PATHSEP_STR "syntax") ) {
		ShowError("do_vimsyntaxgen: Unable to create output directory\n");
		return;
	}

	/* File Type Detector */
	if ((local.fp = fopen(DIRECTORYNAME PATHSEP_STR "ftdetect" PATHSEP_STR SYNTAXLANGUAGE".vim", "wt+")) == NULL) {
		ShowError("do_vimsyntaxgen: Unable to open syntastic output file\n");
		return;
	}
	writeheader("Vim File type detection file");

	fprintf(local.fp,
		"\"if exists(\"did_load_filetypes\")\n"
		"\"  finish\n"
		"\"endif\n"
		"augroup filetypedetect\n"
		"  \" au! commands to set the filetype go here\n"
		"  au! BufNewFile,BufRead *.txt call s:FTath()\n"
		"  function! s:FTath()\n"
		"    if getline(1) =~ '^//=.*\\(eAthena\\|rAthena\\|Hercules\\) Script'\n"
		"      setf "SYNTAXLANGUAGE"\n"
		"    endif\n"
		"  endfunction\n"
		"augroup END\n"
		);

	fclose(local.fp);

	/* File Type plugin */
	if ((local.fp = fopen(DIRECTORYNAME PATHSEP_STR "ftplugin" PATHSEP_STR SYNTAXLANGUAGE".vim", "wt+")) == NULL) {
		ShowError("do_vimsyntaxgen: Unable to open syntastic output file\n");
		return;
	}
	writeheader("Vim filetype plugin file");

	fprintf(local.fp,
		"\" Only do this when not done yet for this buffer\n"
		"if exists(\"b:did_ftplugin\")\n"
		"  finish\n"
		"endif\n"
		"\n"
		"\" Don't load another plugin for this buffer\n"
		"let b:did_ftplugin = 1\n"
		"\n"
		"\" Using line continuation here.\n"
		"let s:cpo_save = &cpo\n"
		"set cpo-=C\n"
		"\n"
		"let b:undo_ftplugin = \"setl fo< com< ofu< | if has('vms') | setl isk< | endif\"\n"
		"\n"
		"\" Set 'formatoptions' to break comment lines but not other lines,\n"
		"\" and insert the comment leader when hitting <CR> or using \"o\".\n"
		"setlocal fo-=t fo+=croql\n"
		"\n"
		"\" Set completion with CTRL-X CTRL-O to autoloaded function.\n"
		"\"if exists('&ofu')\n"
		"\"  setlocal ofu=ccomplete#Complete\n"
		"\"endif\n"
		"\n"
		"\" Set 'comments' to format dashed lists in comments.\n"
		"setlocal comments=sO:*\\ -,mO:*\\ \\ ,exO:*/,s1:/*,mb:*,ex:*/,://\n"
		"\n"
		"\" When the matchit plugin is loaded, this makes the %% command skip parens and\n"
		"\" braces in comments.\n"
		"let b:match_words = &matchpairs\n"
		"let b:match_skip = 's:comment\\|string'\n"
		"\n"
		"\" Win32 can filter files in the browse dialog\n"
		"if has(\"gui_win32\") && !exists(\"b:browsefilter\")\n"
		"    let b:browsefilter = \"Athena Scripts (*.txt *.ath *."SYNTAXLANGUAGE" *."SYNTAXLANGUAGE".txt)\\t*.txt;*."SYNTAXLANGUAGE";*."SYNTAXLANGUAGE".txt\\n\" .\n"
		"         \\ \"All Files (*.*)\\t*.*\\n\"\n"
		"endif\n"
		"\n"
		"let &cpo = s:cpo_save\n"
		"unlet s:cpo_save\n"
		);

	fclose(local.fp);

	/* Indentation definition */
	if ((local.fp = fopen(DIRECTORYNAME PATHSEP_STR "indent" PATHSEP_STR SYNTAXLANGUAGE".vim", "wt+")) == NULL) {
		ShowError("do_vimsyntaxgen: Unable to open syntastic output file\n");
		return;
	}
	writeheader("Vim indent file");

	fprintf(local.fp,
		"\" Only load this indent file when no other was loaded.\n"
		"if exists(\"b:did_indent\")\n"
		"   finish\n"
		"endif\n"
		"let b:did_indent = 1\n"
		"\n"
		"\" C indenting is built-in, thus this is very simple\n"
		"\" Custom settings:\n"
		"\" - align contents of a case label with case rather than what follows it\n"
		"\" - disable preprocessor directives indentation\n"
		"setlocal cindent cinoptions+=l1 cinkeys-=#\n"
		"\n"
		"let b:undo_indent = \"setl cin<\"\n"
		);

	fclose(local.fp);

	/* Syntastic syntax checker definition */

	if ((local.fp = fopen(DIRECTORYNAME PATHSEP_STR "syntastic" PATHSEP_STR SYNTAXLANGUAGE".vim", "wt+")) == NULL) {
		ShowError("do_vimsyntaxgen: Unable to open syntastic output file\n");
		return;
	}
	writeheader("Vim syntastic definition");
	fprintf(local.fp,
		"\" It is possible to add additional compiler options to the syntax\n"
		"\" checking execution via the variable 'g:syntastic_"SYNTAXLANGUAGE"_compiler_options':\n"
		"\"\n"
		"\"   let g:syntastic_"SYNTAXLANGUAGE"_compiler_options = ' -my_custom_options'\n"
		"\"\n"
		"\" Additionally the setting 'g:syntastic_"SYNTAXLANGUAGE"_config_file' allows you to define a\n"
		"\" file that contains additional compiler arguments.\n"
		"\" The file is expected to contain one option per line. If none is\n"
		"\" given the filename defaults to '.syntastic_"SYNTAXLANGUAGE"_config':\n"
		"\"\n"
		"\"   let g:syntastic_"SYNTAXLANGUAGE"_config_file = '.config'\n"
		"\"\n"
		"\" Use the variable 'g:syntastic_"SYNTAXLANGUAGE"_errorformat' to override the default error\n"
		"\" format:\n"
		"\"\n"
		"\"   let g:syntastic_"SYNTAXLANGUAGE"_errorformat = '%%f:%%l:%%c: %%trror: %%m'\n"
		"\"\n"
		"\" Set your compiler executable with e.g. (defaults to script-checker)\n"
		"\"\n"
		"\"   let g:syntastic_"SYNTAXLANGUAGE"_compiler = '/path/to/Hercules/script-checker'\n"
		"\n"
		"if exists('g:loaded_syntastic_"SYNTAXLANGUAGE"_hercules_checker')\n"
		"    finish\n"
		"endif\n"
		"let g:loaded_syntastic_"SYNTAXLANGUAGE"_hercules_checker = 1\n"
		"\n"
		"if !exists('g:syntastic_"SYNTAXLANGUAGE"_compiler')\n"
		"    let g:syntastic_"SYNTAXLANGUAGE"_compiler = 'script-checker'\n"
		"endif\n"
		"\n"
		"function! SyntaxCheckers_"SYNTAXLANGUAGE"_hercules_IsAvailable()\n"
		"    return executable(g:syntastic_"SYNTAXLANGUAGE"_compiler)\n"
		"endfunction\n"
		"\n"
		"let s:save_cpo = &cpo\n"
		"set cpo&vim\n"
		"\n"
		"if !exists('g:syntastic_"SYNTAXLANGUAGE"_compiler_options')\n"
		"    let g:syntastic_"SYNTAXLANGUAGE"_compiler_options = ''\n"
		"endif\n"
		"\n"
		"if !exists('g:syntastic_"SYNTAXLANGUAGE"_config_file')\n"
		"    let g:syntastic_"SYNTAXLANGUAGE"_config_file = '.syntastic_"SYNTAXLANGUAGE"_config'\n"
		"endif\n"
		"\n"
		"function! SyntaxCheckers_"SYNTAXLANGUAGE"_hercules_GetLocList() dict\n"
		"    \"let makeprg = g:syntastic_"SYNTAXLANGUAGE"_compiler . ''\n"
		"    let makeprg = self.makeprgBuild({\n"
		"        \\ 'exe' : g:syntastic_"SYNTAXLANGUAGE"_compiler,\n"
		"        \\ 'args' : g:syntastic_"SYNTAXLANGUAGE"_compiler_options,\n"
		"        \\ 'filetype' : '"SYNTAXLANGUAGE"',\n"
		"        \\ 'subchecker' : 'hercules' })\n"
		"\n"
		"    \" Generic errors\n"
		"    let errorformat =\n"
		"        \\ '[%%tarning]: %%m in file ''%%f''%%\\, line ''%%l''%%.%%#,' .\n"
		"        \\ '[%%trror]: %%m in file ''%%f''%%\\, line ''%%l''%%.%%#,'\n"
		"    \" from npc_parsename\n"
		"    \" > ShowWarning(\"npc_parsename: Display name of '%%s' is too long (len=%%u) in file '%%s', line '%%d'. Truncating to %%u characters.\\n\");\n"
		"    \" > ShowWarning(\"npc_parsename: Unique name of '%%s' is too long (len=%%u) in file '%%s', line '%%d'. Truncating to %%u characters.\\n\");\n"
		"    \" > ShowWarning(\"npc_parsename: Name '%%s' is too long (len=%%u) in file '%%s', line '%%d'. Truncating to %%u characters.\\n\");\n"
		"    \" > ShowWarning(\"npc_parsename: Invalid unique name in file '%%s', line '%%d'. Renaming '%%s' to '%%s'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parsename: Duplicate unique name in file '%%s', line '%%d'. Renaming '%%s' to '%%s'.\\n\");\n"
		"    \" (skip) ShowDebug(\"this npc:\\n   display name '%%s'\\n   unique name '%%s'\\n   map=%%s, x=%%d, y=%%d\\n\");\n"
		"    \" (skip) ShowDebug(\"other npc in '%%s' :\\n   display name '%%s'\\n   unique name '%%s'\\n   map=%%s, x=%%d, y=%%d\\n\");\n"
		"    let errorformat .=\n"
		"        \\ '%%-G[Debug]: this npc:,' .\n"
		"        \\ '%%-G[Debug]: other npc in ''%%.%%#'' :,'\n"
		"    \" from npc_parse_warp\n"
		"    \" > ShowError(\"npc_parse_warp: Invalid warp definition in file '%%s', line '%%d'.\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowError(\"npc_parse_warp: Unknown destination map in file '%%s', line '%%d' : %%s\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowError(\"npc_parse_warp: out-of-bounds coordinates (\\\"%%s\\\",%%d,%%d), map is %%dx%%d, in file '%%s', line '%%d'\\n\");\n"
		"    let errorformat .= ''\n"
		"    \" from npc_parse_shop\n"
		"    \" > ShowError(\"npc_parse_shop: Invalid shop definition in file '%%s', line '%%d'.\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowError(\"npc_parse_shop: out-of-bounds coordinates (\\\"%%s\\\",%%d,%%d), map is %%dx%%d, in file '%%s', line '%%d'\\n\");\n"
		"    \" > ShowError(\"npc_parse_shop: Invalid item definition in file '%%s', line '%%d'. Ignoring the rest of the line...\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_shop: Invalid sell item in file '%%s', line '%%d' (id '%%d').\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_shop: Item %%s [%%d] is being sold for FREE in file '%%s', line '%%d'.\\n\")\n"
		"    \" > ShowWarning(\"npc_parse_shop: Item %%s [%%d] discounted buying price (%%d->%%d) is less than overcharged selling price (%%d->%%d) at file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_shop: Ignoring empty shop in file '%%s', line '%%d'.\\n\");\n"
		"    let errorformat .= ''\n"
		"    \" from npc_convertlabel_db\n"
		"    \" * ShowError(\"npc_parse_script: label name longer than 23 chars! (%%s) in file '%%s'\\n\");\n"
		"    let errorformat .=\n"
		"        \\ '[%%trror]: %%m in file ''%%f''%%\\%%.,'\n"
		"    \" from npc_skip_script\n"
		"    \" > ShowError(\"npc_skip_script: Missing left curly in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"Missing %%d right curlys at file '%%s', line '%%d'.\\n\");\n"
		"    let errorformat .= ''\n"
		"    \" from npc_parse_script\n"
		"    \" > ShowError(\"npc_parse_script: Invalid placement format for a script in file '%%s', line '%%d'. Skipping the rest of file...\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowError(\"npc_parse_script: Missing left curly ',{' in file '%%s', line '%%d'. Skipping the rest of the file.\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_script: duplicate event %%s::%%s in file '%%s'.\\n\");\n"
		"    let errorformat .= ''\n"
		"    \" from npc_parse_duplicate\n"
		"    \" > ShowError(\"npc_parse_script: bad duplicate name in file '%%s', line '%%d': %%s\\n\");\n"
		"    \" > ShowError(\"npc_parse_script: original npc not found for duplicate in file '%%s', line '%%d': %%s\\n\");\n"
		"    \" > ShowError(\"npc_parse_duplicate: Invalid placement format for duplicate in file '%%s', line '%%d'. Skipping line...\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowError(\"npc_parse_duplicate: out-of-bounds coordinates (\\\"%%s\\\",%%d,%%d), map is %%dx%%d, in file '%%s', line '%%d'\\n\");\n"
		"    \" > ShowError(\"npc_parse_duplicate: Invalid span format for duplicate warp in file '%%s', line '%%d'. Skipping line...\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_duplicate: duplicate event %%s::%%s in file '%%s'.\\n\");\n"
		"    let errorformat .= ''\n"
		"    \" from npc_parse_function\n"
		"    \" > ShowError(\"npc_parse_function: Missing left curly '%%%%TAB%%%%{' in file '%%s', line '%%d'. Skipping the rest of the file.\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_function: Overwriting user function [%%s] in file '%%s', line '%%d'.\\n\");\n"
		"    let errorformat .= ''\n"
		"    \" from npc_parse_mob\n"
		"    \" > ShowError(\"npc_parse_mob: Invalid mob definition in file '%%s', line '%%d'.\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowError(\"npc_parse_mob: Unknown map '%%s' in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"npc_parse_mob: Spawn coordinates out of range: %%s (%%d,%%d), map size is (%%d,%%d) - %%s %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"npc_parse_mob: Unknown mob ID %%d in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"npc_parse_mob: Invalid number of monsters %%d, must be inside the range [1,1000] in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"npc_parse_mob: Invalid size number %%d for mob ID %%d in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"npc_parse_mob: Invalid ai %%d for mob ID %%d in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"npc_parse_mob: Invalid level %%d for mob ID %%d in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"npc_parse_mob: Invalid spawn delays %%u %%u in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"npc_parse_mob: Invalid dataset for monster ID %%d in file '%%s', line '%%d'.\\n\");\n"
		"    let errorformat .= ''\n"
		"    \" from npc_parse_mapflag\n"
		"    \" > ShowError(\"npc_parse_mapflag: Invalid mapflag definition in file '%%s', line '%%d'.\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: Unknown map in file '%%s', line '%%d' : %%s\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: Specified save point map '%%s' for mapflag 'nosave' not found in file '%%s', line '%%d', using 'SavePoint'.\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: You can't set PvP and GvG flags for the same map! Removing GvG flags from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: You can't set PvP and BattleGround flags for the same map! Removing BattleGround flag from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: You can't set PvP and BattleGround flags for the same map! Removing PvP flag from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: You can't set GvG and BattleGround flags for the same map! Removing GvG flag from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: Missing 5th param for 'adjust_unit_duration' flag! removing flag from %%s in file '%%s', line '%%d'.\\n\")\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: Unknown skill (%%s) for 'adjust_unit_duration' flag! removing flag from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: Invalid modifier '%%d' for skill '%%s' for 'adjust_unit_duration' flag! removing flag from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: Missing 5th param for 'adjust_skill_damage' flag! removing flag from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: Unknown skill (%%s) for 'adjust_skill_damage' flag! removing flag from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: Invalid modifier '%%d' for skill '%%s' for 'adjust_skill_damage' flag! removing flag from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowWarning(\"npc_parse_mapflag: Invalid zone '%%s'! removing flag from %%s in file '%%s', line '%%d'.\\n\");\n"
		"    \" > ShowError(\"npc_parse_mapflag: unrecognized mapflag '%%s' in file '%%s', line '%%d'.\\n\");\n"
		"    let errorformat .= ''\n"
		"    \" from npc_parsesrcfile\n"
		"    \" ShowError(\"npc_parsesrcfile: Parse error in file '%%s', line '%%d'. Stopping...\\n\");\n"
		"    \" ShowWarning(\"npc_parsesrcfile: w1 truncated, too much data (%%d) in file '%%s', line '%%d'.\\n\");\n"
		"    \" ShowWarning(\"npc_parsesrcfile: w2 truncated, too much data (%%d) in file '%%s', line '%%d'.\\n\");\n"
		"    \" ShowWarning(\"npc_parsesrcfile: w3 truncated, too much data (%%d) in file '%%s', line '%%d'.\\n\");\n"
		"    \" ShowWarning(\"npc_parsesrcfile: w4 truncated, too much data (%%d) in file '%%s', line '%%d'.\\n\");\n"
		"    \" ShowError(\"npc_parsesrcfile: Unknown syntax in file '%%s', line '%%d'. Stopping...\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    \" ShowError(\"npc_parsesrcfile: Unknown map '%%s' in file '%%s', line '%%d'. Skipping line...\\n\");\n"
		"    \" ShowError(\"npc_parsesrcfile: Unknown coordinates ('%%d', '%%d') for map '%%s' in file '%%s', line '%%d'. Skipping line...\\n\");\n"
		"    \" ShowError(\"npc_parsesrcfile: Unable to parse, probably a missing or extra TAB in file '%%s', line '%%d'. Skipping line...\\n * w1=%%s\\n * w2=%%s\\n * w3=%%s\\n * w4=%%s\\n\");\n"
		"    let errorformat .= ''\n"
		"    \" for ENABLE_CASE_CHECK\n"
		"    let errorformat .=\n"
		"        \\ '[%%trror]: %%m (in ''%%f'')%%.%%#,'\n"
		"\n"
		"    let errorformat .=\n"
		"        \\ '%%E[%%trror]: %%.script error in file ''%%f'' line %%l column %%c,%%Z%%m,' .\n"
		"        \\ '%%W[%%tarning]: script error in file ''%%f'' line %%l column %%c,%%Z%%m,' .\n"
		"        \\ '%%-G[Debug]: mapindex_name2id: Map \"%%.%%#\" not found in index list!,' .\n"
		"        \\ '%%E[%%trror]: %%m in file ''%%f''%%\\, line ''%%l'',%%Z %%# %%m,' .\n"
		"        \\ '[%%trror]: %%m,' .\n"
		"        \\ '[%%tarning]: %%m,' .\n"
		"        \\ '%%-G %%.%%#,' .\n"
		"        \\ '%%-G* %%.%%#,' .\n"
		"        \\ '%%m,'\n"
		"\n"
		"    \"if exists('g:syntastic_"SYNTAXLANGUAGE"_errorformat')\n"
		"    \"    let errorformat = g:syntastic_"SYNTAXLANGUAGE"_errorformat\n"
		"    \"endif\n"
		"\n"
		"    \" add optional user-defined compiler options\n"
		"    \"let makeprg .= g:syntastic_"SYNTAXLANGUAGE"_compiler_options\n"
		"\n"
		"    \"let makeprg .= ' ' . syntastic#util#shexpand('%%')\n"
		"\n"
		"    \" add optional config file parameters\n"
		"    \"let makeprg .= ' ' . syntastic#c#ReadConfig(g:syntastic_"SYNTAXLANGUAGE"_config_file)\n"
		"\n"
		"    \" process makeprg\n"
		"    return SyntasticMake({ 'makeprg': makeprg,\n"
		"                \\ 'errorformat': errorformat })\n"
		"endfunction\n"
		"\n"
		"call g:SyntasticRegistry.CreateAndRegisterChecker({\n"
		"    \\ 'filetype': '"SYNTAXLANGUAGE"',\n"
		"    \\ 'name': 'hercules'})\n"
		"\n"
		"let &cpo = s:save_cpo\n"
		"unlet s:save_cpo\n"
		"\n"
		"\" vim: set et sts=4 sw=4:\n");

	fclose(local.fp);

	/* Syntax definition */

	if ((local.fp = fopen(DIRECTORYNAME PATHSEP_STR "syntax" PATHSEP_STR SYNTAXLANGUAGE".vim", "wt+")) == NULL) {
		ShowError("do_vimsyntaxgen: Unable to open syntax output file\n");
		return;
	}

	writeheader("Vim syntax file");

	fprintf(local.fp,
		"\" For version 5.x: Clear all syntax items\n"
		"\" For version 6.x: Quit when a syntax file was already loaded\n"
		"if version < 600\n"
		"  syntax clear\n"
		"elseif exists(\"b:current_syntax\")\n"
		"  finish\n"
		"endif\n"
		"\n\n");

	fprintf(local.fp,
		"\" Allowed characters in a keyword\n"
		"setlocal iskeyword=@,',_,a-z,A-Z,48-57\n"
		"\n"
		"syn match	hVariable	display \"\\<\\%%(\\.\\?\\.@\\?\\|\\$\\|'\\|##\\?\\)\\I\\i*\\$\\?\\>\"\n"
		"\n"
		"syn keyword	hKeyword	break continue\n"
		"\" FIXME hKeyword function\n"
		"syn keyword	hConditional	if else switch\n"
		"syn keyword	hRepeat		do for while\n"
		"\n"
		"syn keyword	hTodo		contained TODO FIXME XXX\n"
		"\n"
		"\" hCommentGroup allows adding matches for special things in comments\n"
		"syn cluster	hCommentGroup	contains=hTodo\n"
		"\n"
		"\" String constants\n"
		"\" Escaped double quotes\n"
		"syn match	hStringSpecial	display contained \"\\\\\\\"\\|\\\\[abtnvfr?]\\|\\\\x[0-9a-fA-F]\\{2\\}\\|\\\\[0-3][0-7]\\+\\|\\\\\\\\\"\n"
		"\" Color constants\n"
		"syn match	hColor		display contained \"\\^[0-9a-fA-F]\\{6\\}\"\n"
		"\" Event names\n"
		"syn match	hNpcEvent	display contained \"[a-zA-Z][a-zA-Z0-9 _#-]\\+::On[A-Z][A-Za-z0-9_-]\\+\"\n"
		"syn region	hString		start=+\"+ skip=+\\\\\\\\\\|\\\\\"\\|\\\\$+ excludenl end=+\"+ end='$' contains=hColor,hNpcEvent,hStringSpecial,@Spell\n"
		"\n"
		"\"when wanted, highlight trailing white space -- FIXME\n"
		"\"if exists(\"c_space_errors\")\n"
		"\"  if !exists(\"c_no_trail_space_error\")\n"
		"    syn match	hSpaceError	display excludenl \"\\s\\+$\"\n"
		"\"  endif\n"
		"\"  if !exists(\"c_no_tab_space_error\")\n"
		"    syn match	hSpaceError	display \" \\+\\t\"me=e-1\n"
		"\"  endif\n"
		"\"endif\n"
		"\n"
		"if exists(\"c_curly_error\")\n"
		"  syntax match hCurlyError	\"}\"\n"
		"  syntax region hBlock		start=\"{\" end=\"}\" contains=ALLBUT,hCurlyError,@hParenGroup,hErrInParen,hErrInBracket,hString,@hTopLevel,@Spell fold\n"
		"else\n"
		"  syntax region	hBlock		start=\"{\" end=\"}\" contains=TOP,@hTopLevel transparent fold\n"
		"endif\n"
		"\n"
		"\"catch errors caused by wrong parenthesis and brackets\n"
		"syn cluster	hParenGroup	contains=hParenError,hNpcEvent,hCommentSkip,hCommentString,hComment2String,@hCommentGroup,hCommentStartError,hUserCont,hUserLabel,hNumber,hNumbersCom\n"
		"if exists(\"c_no_curly_error\")\n"
		"\"  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,hString,@Spell\n"
		"  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,@Spell,@hTopLevel\n"
		"  syn match	hParenError	display \")\"\n"
		"  syn match	hErrInParen	display contained \"^[{}]\"\n"
		"elseif exists(\"c_no_bracket_error\")\n"
		"\"  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,hString,@Spell\n"
		"  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,@Spell,@hTopLevel\n"
		"  syn match	hParenError	display \")\"\n"
		"  syn match	hErrInParen	display contained \"[{}]\"\n"
		"else\n"
		"\"  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,hErrInBracket,hString,@Spell\n"
		"  syn region	hParen		transparent start='(' end=')' contains=ALLBUT,@hParenGroup,hErrInBracket,@Spell,@hTopLevel\n"
		"  syn match	hParenError	display \"[\\])]\"\n"
		"  syn match	hErrInParen	display contained \"[\\]{}]\"\n"
		"\"  syn region	hBracket	transparent start='\\[' end=']' contains=ALLBUT,@hParenGroup,hErrInParen,hString,@Spell\n"
		"  syn region	hBracket	transparent start='\\[' end=']' contains=ALLBUT,@hParenGroup,hErrInParen,@Spell,@hTopLevel\n"
		"  syn match	hErrInBracket	display contained \"[);{}]\"\n"
		"endif\n"
		"\n"
		"\"integer number.\n"
		"syn case ignore\n"
		"syn match	hNumbers	display transparent \"\\<\\d\" contains=hNumber\n"
		"syn match	hNumbersCom	display contained transparent \"\\<\\d\" contains=hNumber\n"
		"syn match	hNumber		display contained \"\\d\\+\\>\"\n"
		"\"hex number\n"
		"syn match	hNumber		display contained \"0x\\x\\+\\>\"\n"
		"\n"
		"syn case match\n"
		"\n"
		"syntax match	hTopError	excludenl \".\\+\" contained\n"
		"syntax match	hTopName	excludenl \"[^\\t#:]*\\%%(#[^\\t:]*\\)\\?\\%%(::[^\\t]*\\)\\?\\t\"me=e-1 contained\n"
		"\n"
		"syntax match	hTopShopData	excludenl \"\\%%(,[0-9]\\+:\\%%(-1\\|[0-9]\\+\\)\\)*\" contains=hNumber\n"
		"syntax match	hTopMobData	excludenl \"[0-9]\\+,[0-9]\\+\\%%(,[0-9]\\+\\%%(,[0-9]\\+\\%%(,[^,]\\+\\%%(,[0-9]\\+\\)\\{,2}\\)\\)\\)\\?\" contains=hNpcEvent,hNumber\n"
		"syntax match	hTopWDest	excludenl \"[0-9]\\+,[0-9]\\+,[a-zA-Z0-9@_-]\\+,[0-9]\\+,[0-9]\\+\" contains=hMapName,hNumber\n"
		"syntax match	hTopFSprite	excludenl \"-1,\" contained contains=hNumber nextgroup=hBlock\n"
		"syntax match	hTopSprite	excludenl \"[^,]\\+\\%%(,[0-9]\\+,[0-9]\\+\\)\\?,\" contained contains=hNumber,hConstant nextgroup=hBlock\n"
		"syntax match	hTopSSprite	excludenl \"[^,]\\+\\%%(,[0-9]\\+,[0-9]\\+\\)\\?\" contained contains=hNumber,hConstant nextgroup=hTopShopData,hTopError\n"
		"syntax match	hTopDSprite	excludenl \"[^,]\\+\\%%(,[0-9]\\+,[0-9]\\+\\)\\?$\" contained contains=hNumber,hConstant\n"
		"\n"
		"syntax match	hTopNameFunc	excludenl \"[^\\t]*\\t\" transparent contained contains=hTopName nextgroup=hBlock\n"
		"syntax match	hTopNameShop	excludenl \"[^\\t]*\\t\" transparent contained contains=hTopName nextgroup=hTopSSprite,hTopError\n"
		"syntax match	hTopNameScript	excludenl \"[^\\t]*\\t\" transparent contained contains=hTopName nextgroup=hTopSprite,hTopFSprite,hTopError\n"
		"syntax match	hTopNameDup	excludenl \"[^\\t]*\\t\" transparent contained contains=hTopName nextgroup=hTopDSprite,hTopError\n"
		"syntax match	hTopNameWarp	excludenl \"[^\\t]*\\t\" transparent contained contains=hTopName nextgroup=hTopWDest,hTopError\n"
		"syntax match	hTopNameMob	excludenl \"[^,\\t]*\\%%(,[0-9]\\+\\)\\?\\t\" transparent contained contains=hTopName nextgroup=hTopMobData,hTopError\n"
		"syntax match	hDupName	excludenl \"duplicate([^)]*)\"me=e-1,ms=s+10 contained\n"
		"\n"
		"syntax match	hTopMapflag	excludenl \"nosave\\t\\%%(off\\|SavePoint\\|[a-zA-Z0-9@_-]\\+,[0-9]\\+,[0-9]\\+\\)\" contained contains=hMapName,hNumber\n"
		"syntax match	hTopMapflag	excludenl \"pvp_nightmaredrop\\t\\%%(off\\|\\%%(random\\|inventory\\|equip\\|all\\),[^,]\\+,[0-9]\\+\\)\" contained contains=hMapName,hNumber\n"
		"syntax match	hTopMapflag	excludenl \"\\%%(nocommand\\|battleground\\|invincible_time_inc\\|\\%%(weapon\\|magic\\|misc\\|short\\|long\\)_damage_rate\\)\\%%(\\|\\toff\\|\\t[0-9]\\+\\)\" contained contains=hNumber\n"
		"syntax match	hTopMapflag	excludenl \"\\%%(autotrade\\|allowks\\|town\\|monster_noteleport\\|no\\%%(memo\\|teleport\\|warp\\%%(to\\)\\?\\|return\\|branch\\|\\%%(\\|zeny\\|exp\\)penalty\\|trade\\|vending\\|drop\\|skill\\|icewall\\|\\%%(\\|base\\|job\\)exp\\|\\%%(\\|mob\\|mvp\\)loot\\|command\\|chat\\|tomb\\|mapchannelautojoin\\|knockback\\|cashshop\\)\\|pvp\\%%(\\|_noparty\\|_noguild\\|_nocalcrank\\)\\|gvg\\%%(\\|_noparty\\|_dungeon\\|_castle\\)\\|snow\\|clouds2\\?\\|fog\\|fireworks\\|sakura\\|leaves\\|nightenabled\\|[bj]exp\\|loadevent\\|\\%%(party\\|guild\\)lock\\|reset\\|src4instance\\)\\%%(\\toff\\)\\?\" contained\n"
		"syntax match	hTopMapflag	excludenl \"adjust_\\%%(unit_duration\\|skill_damage\\)\\t.*\" contained\n"
		"syntax match	hTopMapflag	excludenl \"zone\\t.*\" contained\n"
		"\" TODO: adjust_unit_duration, adjust_skill_damage\n"
		"\n"
		"syntax match	hTopTypeM	excludenl \"\\%%(\\|boss_\\)monster\\t\" contained nextgroup=hTopNameMob,hTopError\n"
		"syntax match	hTopTypeW	excludenl \"warp\\t\" contained nextgroup=hTopNameWarp,hTopError\n"
		"syntax match	hTopTypeS	excludenl \"\\%%(script\\|trader\\)\\t\" contained nextgroup=hTopNameScript,hTopError\n"
		"syntax match	hTopTypeS	excludenl \"\\%%(\\|cash\\)shop\\t\" contained nextgroup=hTopNameShop,hTopError\n"
		"syntax match	hTopTypeMF	excludenl \"mapflag\\t\" contained nextgroup=hTopMapflag,hTopError\n"
		"syntax match	hTopType	excludenl \"duplicate([^)\\t]*)\\t\"he=e-1 contains=hDupName contained nextgroup=hTopNameDup,hTopError\n"
		"\n"
		"syntax match	hTopLocation	excludenl \"^[a-zA-Z0-9@_-]\\+,[0-9]\\+,[0-9]\\+\\%%(,[0-9]\\+\\)\\{,2}\\t\" contains=hMapName,hNumber nextgroup=hTopTypeM,hTopError\n"
		"syntax match	hTopLocation	excludenl \"^[a-zA-Z0-9@_-]\\+,[0-9]\\+,[0-9]\\+\\t\" contains=hMapName,hNumber nextgroup=hTopTypeW,hTopError\n"
		"syntax match	hTopLocation	excludenl \"^[a-zA-Z0-9@_-]\\+,[0-9]\\+,[0-9]\\+,[0-9]\\+\\t\" contains=hMapName,hNumber nextgroup=hTopType,hTopTypeS,hTopTypeW,hTopError\n"
		"syntax match	hTopLocation	excludenl \"^[a-zA-Z0-9@_-]\\+\\t\" contains=hMapName nextgroup=hTopTypeMF,hTopError\n"
		"syntax match	hTopLocation	excludenl \"^-\\t\" contains=hKeyword nextgroup=hTopTypeS,hTopError\n"
		"syntax match	hTopLocation	excludenl \"^function\\tscript\\t\" contains=hKeyword nextgroup=hTopNameFunc,hTopError\n"
		"syn cluster hTopLevel contains=hTopLocation,@hTopKeywordG,hDupName,hTopNameShop,hTopNameDup,hTopNameScript,hTopNameFunc,hTopNameMob,hTopNameWarp,hTopFSprite,hTopName,hTopSprite,hTopDSprite,hTopSSprite,hTopWDest,hTopError,hTopMobData,hTopShopData,hTopMapflag\n"
		"syn cluster hTopKeywordG contains=hTopType,hTopTypeW,hTopTypeS,hTopTypeM,hTopTypeMF\n"
		"\n"
		"syn case match\n"
		"syn keyword	hConstant	null\n"
		"\n\n");

	vimsyntaxgen_constdb();

	vimsyntaxgen_mapdb();

	vimsyntaxgen_skilldb();

	vimsyntaxgen_mobdb();

	vimsyntaxgen_itemdb();

	vimsyntaxgen_scriptcmd();

	fprintf(local.fp,
		"\n\n"
		"\" Ternary operator doesn't work too well, let's ignore it.\n"
		"\"syn cluster	hMultiGroup	contains=hNpcEvent,hCommentSkip,hCommentString,hComment2String,@hCommentGroup,hCommentStartError,hUserCont,hUserLabel,hNumber,hNumbersCom,hString\n"
		"\"syn region	hMulti		transparent start='?' skip='::' end=':' contains=ALLBUT,@hMultiGroup,@Spell,@hTopLevel\n"
		"\" Avoid matching foo::bar by requiring that the next char is not ':'\n"
		"\" Highlight User Labels\n"
		"syn cluster	hLabelGroup	contains=hUserLabel,hDefaultLabel\n"
		"syn match	hUserCont	transparent \"^\\s*\\I\\i*\\s*:$\" contains=@hLabelGroup\n"
		"syn match	hUserCont	transparent \";\\s*\\I\\i*\\s*:$\" contains=@hLabelGroup\n"
		"syn match	hUserCont	transparent \"^\\s*\\I\\i*\\s*:[^:]\"me=e-1 contains=@hLabelGroup\n"
		"syn match	hUserCont	transparent \";\\s*\\I\\i*\\s*:[^:]\"me=e-1 contains=@hLabelGroup\n"
		"\n"
		"\" User defined labels\n"
		"syn match	hUserLabel	display \"[A-Z]_\\i*\" contained\n"
		"syn match	hUserLabel	display \"On\\i*\" contained\n"
		"\n"
		"\" Pre-defined labels\n"
		"\" chrif_connectack\n"
		"syn match	hDefaultLabel	display \"OnInterIfInit\\%%(Once\\)\\?:\"me=e-1 contained\n"
		"\" clif_parse_WisMessage\n"
		"syn match	hDefaultLabel	display \"OnWhisperGlobal:\"me=e-1 contained\n"
		"\" castle_guild_broken_sub\n"
		"syn match	hDefaultLabel	display \"OnGuildBreak:\"me=e-1 contained\n"
		"\" guild_castledataloadack, guild_agit_start, guild_agit_end, guild_agit2_start, guild_agit2_end\n"
		"syn match	hDefaultLabel	display \"OnAgit\\%%(Init\\|Start\\|End\\)2\\?:\"me=e-1 contained\n"
		"\" instance_init_npc\n"
		"syn match	hDefaultLabel	display \"OnInstanceInit:\"me=e-1 contained\n"
		"\" npc_event_do_clock:\n"
		"syn match	hDefaultLabel	display \"On\\%%(Minute\\|Hour\\)[0-9]\\{2\\}:\"me=e-1 contained\n"
		"syn match	hDefaultLabel	display \"On\\%%(Day\\|Clock\\|Sun\\|Mon\\|Tue\\|Wed\\|Thu\\|Fri\\|Sat\\)[0-9]\\{4\\}:\"me=e-1 contained\n"
		"syn match	hDefaultLabel	display \"OnDay[0-9]:\"me=e-1 contained\n"
		"\" npc_event_do_oninit:\n"
		"syn match	hDefaultLabel	display \"OnInit:\"me=e-1 contained\n"
		"\" npc_timerevent_quit:\n"
		"syn match	hDefaultLabel	display \"OnTimerQuit:\"me=e-1 contained\n"
		"\" npc_touch_areanpc2\n"
		"syn match	hDefaultLabel	display \"OnTouchNPC:\"me=e-1 contained\n"
		"\" npc_buylist_sub, npc_selllist_sub\n"
		"syn match	hDefaultLabel	display \"On\\%%(Buy\\|Sell\\)Item:\"me=e-1 contained\n"
		"\" npc_timerevent_export\n"
		"syn match	hDefaultLabel	display \"OnTimer[0-9]\\+:\"me=e-1 contained\n"
		"\" npc_trader_*\n"
		"syn match	hDefaultLabel	display \"On\\%%(Count\\|Pay\\)Funds:\"me=e-1 contained\n"
		"\" BUILDIN(cmdothernpc)\n"
		"syn match	hDefaultLabel	display \"OnCommand\\i\\+:\"me=e-1 contained\n"
		"\" script_defaults\n"
		"syn match	hDefaultLabel	display \"OnPC\\%%(Die\\|Kill\\|Login\\|Logout\\|LoadMap\\|BaseLvUp\\|JobLvUp\\)Event:\"me=e-1 contained\n"
		"syn match	hDefaultLabel	display \"OnNPCKillEvent:\"me=e-1 contained\n"
		"syn match	hDefaultLabel	display \"OnTouch_\\?:\"me=e-1 contained\n"
		"\n"
		"syn match	hSwitchLabel	display \"\\s*case\\s*\\i*\\s*:\"me=e-1 contains=hNumber,hConstant,hParam\n"
		"syn match	hSwitchLabel	display \"\\s*default:\"me=e-1\n"
		"\n"
		"if exists(\"c_comment_strings\")\n"
		"  \" A comment can contain hString and hNumber.\n"
		"  \" But a \"*/\" inside an hString in an hComment DOES end the comment!  So we\n"
		"  \" need to use a special type of hString: hCommentString, which also ends on\n"
		"  \" \"*/\", and sees a \"*\" at the start of the line as comment again.\n"
		"  \" Unfortunately this doesn't very well work for // type of comments :-(\n"
		"  syntax match	hCommentSkip	contained \"^\\s*\\*\\%%($\\|\\s\\+\\)\"\n"
		"  syntax region hCommentString	contained start=+\\\\\\@<!\"+ skip=+\\\\\\\\\\|\\\\\"+ end=+\"+ end=+\\*/+me=s-1 contains=hColor,hNpcEvent,hStringSpecial,hCommentSkip\n"
		"  syntax region hComment2String	contained start=+\\\\\\@<!\"+ skip=+\\\\\\\\\\|\\\\\"+ end=+\"+ end=\"$\" contains=hColor,hNpcEvent,hStringSpecial\n"
		"  syntax region hCommentL	start=\"//\" skip=\"\\\\$\" end=\"$\" keepend contains=@hCommentGroup,hComment2String,hNumbersCom,hSpaceError,@Spell\n"
		"  if exists(\"c_no_comment_fold\")\n"
		"    \" Use \"extend\" here to have preprocessor lines not terminate halfway a\n"
		"    \" comment.\n"
		"    syntax region hComment	matchgroup=hCommentStart start=\"/\\*\" end=\"\\*/\" contains=@hCommentGroup,hCommentStartError,hCommentString,hNumbersCom,hSpaceError,@Spell extend\n"
		"  else\n"
		"    syntax region hComment	matchgroup=hCommentStart start=\"/\\*\" end=\"\\*/\" contains=@hCommentGroup,hCommentStartError,hCommentString,hNumbersCom,hSpaceError,@Spell fold extend\n"
		"  endif\n"
		"else\n"
		"  syn region	hCommentL	start=\"//\" skip=\"\\\\$\" end=\"$\" keepend contains=@hCommentGroup,hSpaceError,@Spell\n"
		"  if exists(\"c_no_comment_fold\")\n"
		"    syn region	hComment	matchgroup=hCommentStart start=\"/\\*\" end=\"\\*/\" contains=@hCommentGroup,hCommentStartError,hSpaceError,@Spell extend\n"
		"  else\n"
		"    syn region	hComment	matchgroup=hCommentStart start=\"/\\*\" end=\"\\*/\" contains=@hCommentGroup,hCommentStartError,hSpaceError,@Spell fold extend\n"
		"  endif\n"
		"endif\n"
		"\" keep a // comment separately, it terminates a preproc. conditional\n"
		"syntax match	hCommentError		display \"\\*/\"\n"
		"syntax match	hCommentStartError	display \"/\\*\"me=e-1 contained\n"
		"\n"
		"if exists(\"c_minlines\")\n"
		"  let b:c_minlines = c_minlines\n"
		"else\n"
		"  if !exists(\"c_no_if0\")\n"
		"    let b:c_minlines = 50	\" #if 0 constructs can be long\n"
		"  else\n"
		"    let b:c_minlines = 15	\" mostly for () constructs\n"
		"  endif\n"
		"endif\n"
		"if exists(\"c_curly_error\")\n"
		"  syn sync fromstart\n"
		"else\n"
		"  exec \"syn sync ccomment hComment minlines=\" . b:c_minlines\n"
		"endif\n"
		"\n"
		"\" Define the default highlighting.\n"
		"\" Only used when an item doesn't have highlighting yet\n"
		"hi def link hCommentL		hComment\n"
		"hi def link hCommentStart	hComment\n"
		"hi def link hDefaultLabel 	Boolean\n"
		"hi def link hUserLabel		Label\n"
		"hi def link hSwitchLabel	Boolean\n"
		"hi def link hConditional	Conditional\n"
		"hi def link hRepeat		Repeat\n"
		"hi def link hNumber		Number\n"
		"hi def link hParenError		Error\n"
		"hi def link hErrInParen		Error\n"
		"hi def link hErrInBracket	Error\n"
		"hi def link hCommentError	Error\n"
		"hi def link hCommentStartError	Error\n"
		"hi def link hSpaceError		Error\n"
		"hi def link hCurlyError		hError\n"
		"hi def link hStatement		Type\n"
		"hi def link hKeyword		Statement\n"
		"hi def link hCommand		Function\n"
		"hi def link hDeprecated		Error\n"
		"hi def link hConstant		Constant\n"
		"hi def link hMapName		PreProc\n"
		"hi def link hSkillId		Constant\n"
		"hi def link hMobId		Constant\n"
		"hi def link hItemId		Constant\n"
		"hi def link hParam		Float\n"
		"hi def link hCommentString	hString\n"
		"hi def link hComment2String	hString\n"
		"hi def link hCommentSkip	hComment\n"
		"hi def link hString		String\n"
		"hi def link hComment		Comment\n"
		"hi def link hNpcEvent		SpecialChar\n"
		"hi def link hStringSpecial	SpecialChar\n"
		"hi def link hColor		SpecialChar\n"
		"hi def link hTodo		Todo\n"
		"\n"
		"hi def link hTopError		Error\n"
		"hi def link hTopMapflag		hTopLevelColor\n"
		"hi def link hTopLocation	hTopLevelColor\n"
		"hi def link hTopWDest		hTopLevelColor\n"
		"hi def link hTopMobData		hTopLevelColor\n"
		"hi def link hTopShopData	hTopLevelColor\n"
		"hi def link hTopNameDup		hTopNpcName\n"
		"hi def link hTopName		hTopNpcName\n"
		"hi def link hDupName		hTopNpcName\n"
		"hi def link hTopNameFunc	hTopLevelColor\n"
		"hi def link hTopType		hTopKeyword\n"
		"hi def link hTopTypeW		hTopKeyword\n"
		"hi def link hTopTypeS		hTopKeyword\n"
		"hi def link hTopTypeM		hTopKeyword\n"
		"hi def link hTopTypeMF		hTopKeyword\n"
		"hi def link hTopNpcName		Define\n"
		"hi def link hTopLevelColor	Float\n"
		"hi def link hTopKeyword		Float\n"
		"hi def link hVariable		Include\n"
		"\n"
		"\n\n"
		"let b:current_syntax = \""SYNTAXLANGUAGE"\"\n"
		"\n"
		"\" vim: set ts=8 tw=%d colorcolumn=%d :\n", LINE_LENGTH, LINE_LENGTH);
	fclose(local.fp);
}
CPCMD(vimsyntaxgen) {
	do_vimsyntaxgen();
}
CMDLINEARG(vimsyntaxgen)
{
	map->minimal = torun = true;
	return true;
}
HPExport void server_preinit(void) {
	addArg("--vimsyntaxgen", false, vimsyntaxgen, NULL);
}
HPExport void plugin_init(void) {
	addCPCommand("server:tools:vimsyntaxgen", vimsyntaxgen);
}
HPExport void server_online(void) {
	if (torun)
		do_vimsyntaxgen();
}
