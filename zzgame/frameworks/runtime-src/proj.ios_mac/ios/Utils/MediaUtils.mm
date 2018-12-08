//
//  
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#include "MediaUtils.h"
#import <AVFoundation/AVFoundation.h>

static MediaUtils* mInstance = NULL;

MediaUtils::MediaUtils()
{
    
}

MediaUtils::~MediaUtils()
{
    
}

MediaUtils* MediaUtils::getInstance()
{
    if(!mInstance)
        mInstance = new MediaUtils();
    return mInstance;
}

void MediaUtils::setVolume(float percent)
{
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    musicPlayer.volume = percent;
}

void MediaUtils::setBrightness(float percent)
{
    [[UIScreen mainScreen] setBrightness:percent];
}

float MediaUtils::getVolume()
{
    MPMusicPlayerController *player = [MPMusicPlayerController applicationMusicPlayer];
    return player.volume;
}

float MediaUtils::getBrightness()
{
    return [[UIScreen mainScreen] brightness];
}


