#include <localdb/coversource.h>

CoverSource::CoverSource() : QObject(nullptr)
{
    mLocalEnabled = 0;
    mLastFmEnabled = 1;
}

CoverSource *CoverSource::instance()
{
    static CoverSource source;
    return &source;
}

void CoverSource::setLocalEnabled(bool enabled)
{
    mLocalEnabled.storeRelease(enabled ? 1 : 0);
    emit localEnabledChanged(enabled);
}

void CoverSource::setLastFmEnabled(bool enabled)
{
    mLastFmEnabled.storeRelease(enabled ? 1 : 0);
}
