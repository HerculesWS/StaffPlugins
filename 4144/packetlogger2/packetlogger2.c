/**
 * This file is part of Hercules.
 * http://herc.ws - http://github.com/HerculesWS/Hercules
 *
 * Copyright (C) 2014-2015  Hercules Dev Team
 * Copyright (C) 2019  Andrei Karas (4144)
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

#include "common/hercules.h"
#include "common/socket.h"
#include "common/mmo.h"
#include "common/memmgr.h"
#include "common/nullpo.h"

#include "plugins/HPMHooking.h"

#include <stdio.h>
#include <stdlib.h>

#include <sys/time.h>

#include "common/HPMDataCheck.h"

#ifndef PACKETTYPE
#define PACKETTYPE "unknown"
#endif

struct SessionExt
{
    bool enabled;
    bool triggered;
    FILE *file;
    int (*recv_func) (int fd);
};

HPExport struct hplugin_info pinfo = {
    "packet_logger_v2",  // Plugin name
    SERVER_TYPE_LOGIN | SERVER_TYPE_CHAR | SERVER_TYPE_MAP,  // Which server types this plugin works with?
    "0.1",               // Plugin version
    HPM_VERSION,         // HPM Version (don't change, macro is automatically updated)
};

static void packet_log(FILE *file, char *buf, int len, bool isSend)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    fprintf(file, "#time %ld.%ld\n", tv.tv_sec, tv.tv_usec);

    if (isSend)
        fprintf(file, "5252\n");
    else
        fprintf(file, "5353\n");
    for (int32_t f = 0; f < len; f ++)
    {
        fprintf(file, "%02x", ((const unsigned char*)buf)[f]);
    }
    fprintf(file, "\n");
    fflush(file);
}

static void open_file(struct SessionExt *data)
{
    if (data->file != NULL)
        return;
    time_t time1;
    char buf[201];
    char tbuf[101];
    struct tm* tm_info;
    const char *type = "unknown";

    if (SERVER_TYPE == SERVER_TYPE_LOGIN)
        type = "login";
    else if (SERVER_TYPE == SERVER_TYPE_CHAR)
        type = "char";
    else if (SERVER_TYPE == SERVER_TYPE_MAP)
        type = "map";

    time(&time1);
    tm_info = localtime(&time1);

    strftime(tbuf, 100, "%Y-%m-%d_%H-%M-%S", tm_info);
    sprintf(buf, "log/%s_%d_" PACKETTYPE "_%s.txt", type, PACKETVER, tbuf);

    FILE *file = fopen(buf, "wt");
    fprintf(file, "#format 2\n");
    fprintf(file, "#packetversion %d " PACKETTYPE "\n", PACKETVER);
    fprintf(file, "#time %ld\n", (long int)time1);
    fflush(file);
    data->file = file;
}

static void socket_validateWfifo_pre(int *fdPtr, size_t *lenPtr)
{
    const int fd = *fdPtr;
    if (!sockt->session_is_valid(fd))
        return;
    const size_t len = *lenPtr;
    if (len == 0)
        return;
    struct SessionExt *data = getFromSession(sockt->session[fd], 0);
    if (data == NULL || data->enabled == false || sockt->session[fd]->flag.validate == 0)
        return;

    open_file(data);
    packet_log(data->file, WFIFOP(fd, 0), len, true);
}

static int recv_func_proxy(int fd)
{
    if (!sockt->session_is_valid(fd))
        return 0;

    struct SessionExt *data = getFromSession(sockt->session[fd], 0);
    nullpo_ret(data);
    int len = data->recv_func(fd);
    if (len <= 0 || data->enabled == false || sockt->session[fd]->flag.validate == 0)
        return len;

    if (data->triggered == false)
    {
        if (SERVER_TYPE == SERVER_TYPE_LOGIN && RFIFOW(fd, 0) == 0x2710)
        {
            data->enabled = false;
            return len;
        }
        if (SERVER_TYPE == SERVER_TYPE_CHAR && RFIFOW(fd, 0) == 0x2af8)
        {
            data->enabled = false;
            return len;
        }
    }
    data->triggered = true;

    char *buf = (char*) sockt->session[fd]->rdata + sockt->session[fd]->rdata_size - len;
    open_file(data);
    packet_log(data->file, buf, len, false);
    return len;
}

static int sockt_connect_client_post(int retVal, int listen_fd)
{
    const int fd = retVal;

    if (retVal < 0 || !sockt->session_is_valid(fd))
        return retVal;

    struct SessionExt *data = getFromSession(sockt->session[fd], 0);
    if (!data)
    {
        ShowInfo("Enable logging for fd %d\n", fd);
        CREATE(data, struct SessionExt, 1);
        data->enabled = true;
        data->recv_func = sockt->session[fd]->func_recv;
        sockt->session[fd]->func_recv = recv_func_proxy;
        addToSession(sockt->session[fd], data, 0, true);
    }
    else
    {
        ShowError("Double logging for fd %d\n", fd);
    }

    return retVal;
}

static void socket_close_pre(int *fdPtr)
{
    const int fd = *fdPtr;
    if (!sockt->session_is_valid(fd))
        return;
    struct SessionExt *data = getFromSession(sockt->session[fd], 0);
    if (!data || data->enabled == false)
        return;
    if (data->file != NULL)
    {
        fclose(data->file);
        data->file = NULL;
    }
}

void (*socketCloseBack) (int fd) = NULL;

HPExport void server_preinit(void)
{
    socketCloseBack = sockt->close;
    addHookPre(sockt, validateWfifo, socket_validateWfifo_pre);
    addHookPre(sockt, close, socket_close_pre);
    addHookPost(sockt, connect_client, sockt_connect_client_post);
}

HPExport void plugin_init(void)
{
}

HPExport void plugin_final(void)
{
    // hack for avoid crash on exit
    sockt->close = socketCloseBack;
}
