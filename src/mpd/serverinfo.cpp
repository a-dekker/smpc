#include "serverinfo.h"

ServerInfo::ServerInfo()
{
    pAlbumartSupported = false;
}

void ServerInfo::setVersion(MPD_version_t version) {
    pVersion = version;
}

void ServerInfo::setIdleSupported(bool idle) {
    pIdleSupported = idle;
}

void ServerInfo::setAlbumartSupported(bool value)
{
    pAlbumartSupported = value;
}

void ServerInfo::setListFilterSupported(bool filter) {
    pListFilterSupported = filter;
}

void ServerInfo::setListGroupSupported(bool groupSupported) {
    pListGroupSupported = groupSupported;
}

void ServerInfo::setListMultiGroupSupported(bool multiGroupSupported) {
    pListMultiGroupSupported = multiGroupSupported;
}

void ServerInfo::setListGroupFormatOld(bool value)
{
    pListGroupFormatOld = value;
}

void ServerInfo::setMBIDTagsSupported(bool MBIDSupported) {
    pMBIDTagsSupported = MBIDSupported;
}

MPD_version_t *ServerInfo::getVersion() {
    return &pVersion;
}

bool ServerInfo::getIdleSupported() {
    return pIdleSupported;
}

bool ServerInfo::getAlbumartSupported()
{
    return pAlbumartSupported;
}

bool ServerInfo::getListFilterSupported() {
    return pListFilterSupported;
}

bool ServerInfo::getListGroupSupported() {
    return pListGroupSupported;
}

bool ServerInfo::getListMultiGroupSupported() {
    return pListMultiGroupSupported;
}

bool ServerInfo::getListGroupFormatOld()
{
    return pListGroupFormatOld;
}

bool ServerInfo::getMBIDTagsSupported() {
    return pMBIDTagsSupported;
}
