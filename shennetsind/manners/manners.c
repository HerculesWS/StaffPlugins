// Copyright (c) Hercules Dev Team, licensed under GNU GPL.
// See the LICENSE file
// Sample Hercules Plugin

#include "common/hercules.h"
#include "common/memmgr.h"
#include "common/mmo.h"
#include "common/socket.h"
#include "common/strlib.h"
#include "map/atcommand.h"
#include "map/clif.h"
#include "map/pc.h"

#include "common/HPMDataCheck.h" /* should always be the last file included! (if you don't make it last, it'll intentionally break compile time) */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/**
 * Reads off conf/manners.txt
 * - 1 Word per line
 * Causes players not to be able to spell badwords blacklisted
 * Implements @reloadmanners
 * Implements 'mouthful' permission set, so individual groups can be set to bypass the filter.
 **/

HPExport struct hplugin_info pinfo = {
	"Manners",		// Plugin name
	SERVER_TYPE_MAP,// Which server types this plugin works with?
	"0.2",			// Plugin version
	HPM_VERSION,	// HPM Version (don't change, macro is automatically updated)
};

/* our globalz */
char **badlist = NULL;
unsigned int badlistcount = 0;
unsigned int mouthful_mask = UINT_MAX - 1;

/**
 * Woohooo, lets teach those badmouthing players a lesson!
 **/
bool clif_process_message_post(bool retVal, struct map_session_data *sd, int *format, char **name_, size_t *namelen_, char **message_, size_t *messagelen_) {
	char *message = *message_;
	unsigned int i;

	/* don't bother! */
	if( !retVal || !message )
		return false;

	/* Can this user skip? */
	if( !badlistcount || pc_has_permission(sd,mouthful_mask) )
		return true;

	/* Lets go! */
	for(i = 0; i < badlistcount; i++) {
		if( stristr(message,badlist[i]) ) {
			char output[254];
			sprintf(output,"Thou shall not utter '%s'!",badlist[i]);
			clif->messagecolor_self(sd->fd,COLOR_RED,output);
			return false;
		}
	}

	/* you may pass! */
	return true;
}

/**
 * for shutdown & reload
 **/
void clean_manners(void) {
	unsigned int i;

	for(i = 0; i < badlistcount; i++) {
		if( badlist[i] )
			aFree(badlist[i]);
	}
	if( badlist )
		aFree(badlist);

	badlistcount = 0;
	badlist = NULL;
}
/**
 * conf/manners.txt
 **/
void load_manners(void) {
	FILE* fp;

	clean_manners();

	if ((fp=fopen("conf/manners.txt","r"))) {
		char line[1024], param[1024];

		while(fgets(line, sizeof(line), fp)) {
			/* we skip the baaaars! and the blaaanks */
			if (( line[0] == '/' && line[1] == '/' ) || line[0] == '\n' || line[1] == '\n' )
				continue;

			/* to strip the crap out, laaazy! */
			if (sscanf(line, "%1023s", param) != 1)
				continue;

			RECREATE(badlist, char *, ++badlistcount);
			badlist[badlistcount - 1] = aStrdup(param);
		}
		fclose(fp);
		ShowStatus("Done reading '"CL_WHITE"%u"CL_RESET"' entries in '"CL_WHITE"manners.txt"CL_RESET"'.\n", badlistcount);
	} else {
		ShowError("Failed to load 'conf/manners.txt'!\n");
	}
}
/**
 * Our @reloadmanners
 ***/
ACMD(reloadmanners) {
	load_manners();
	clif->message(fd,"Manners reloaded!");

	return true;
}

/**
 * We started!
 **/
HPExport void plugin_init (void) {
	/* lets add our command! */
	addAtcommand("reloadmanners",reloadmanners);

	/* lets hook! */
	addHookPost("clif->process_message",clif_process_message_post);

	/* lets add our permission */
	addGroupPermission("mouthful",mouthful_mask);

	load_manners();
}
/**
 * we are going down!
 **/
HPExport void plugin_final (void) {
	clean_manners();
}
