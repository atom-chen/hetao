//
//  
//

#ifndef NetworkUtils_h
#define NetworkUtils_h

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkUtils : NSObject
{
    int statusHandler;
    Reachability *hostReach;
}

+(NetworkUtils *) getInstance;

-(id) init;

-(void) dealloc;

-(void) reachbilityChanged: (NSNotification*) note;

-(void) setNetworkChangeEvent:(int) handle;

-(void) releaseStatusHandler;

-(void) onStatusChange:(int)type networkType:(int)networkType rat:(NSString *)rat;

-(int) getConnectedType;

@end

#endif //NetworkUtils_h
