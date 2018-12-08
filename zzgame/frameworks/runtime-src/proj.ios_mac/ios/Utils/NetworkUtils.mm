//
//  
//

#import <Foundation/Foundation.h>
#import "NetworkUtils.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

USING_NS_CC;

@implementation NetworkUtils

static NetworkUtils *mInstance = nullptr;


+(NetworkUtils *) getInstance
{
    if(!mInstance)
    {
        mInstance = [[NetworkUtils alloc] init];
    }
    return mInstance;
}

-(id) init
{
    [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachbilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    hostReach = [[Reachability reachabilityWithHostName:@"www.apple.com"] retain];//可以以多种形式初始化
    [hostReach startNotifier];  //开始监听,会启动一个run loop
    
    return self;
}

-(void) reachbilityChanged: (NSNotification*) note
{
    Reachability  *curReach = [note object];
    //断言：判断是否Reachability类
//    NSCParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentRatioAccessTechnology = info.currentRadioAccessTechnology;
    
    // TODO: 判断网络2G／3G／4G的
//    if (currentRatioAccessTechnology) {
//        if ([currentRatioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
//            kReachableVia4G;
//        }
//    }
    
    [self onStatusChange:status networkType:0 rat:currentRatioAccessTechnology];
}

-(void) dealloc
{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) releaseStatusHandler
{
    if(statusHandler > 0)
    {
        LuaBridge::releaseLuaFunctionById(statusHandler);
        statusHandler = 0;
    }
}

-(void) setNetworkChangeEvent:(int)handle
{
    [self releaseStatusHandler];
    statusHandler = handle;
}

-(void) onStatusChange:(int)type networkType:(int)networkType rat:(NSString *)rat
{
    if(statusHandler == 0) return;
    LuaBridge::pushLuaFunctionById(statusHandler);
    LuaStack *stack = LuaBridge::getStack();
    stack->pushInt(type);
    stack->pushInt(networkType);
    stack->pushString([rat cStringUsingEncoding:NSUTF8StringEncoding]);
    stack->executeFunction(3);
    stack->clean(); // demo没有这一句
}

-(int) getConnectedType
{
    if(hostReach==nil) return 0;
    NetworkStatus status = [hostReach currentReachabilityStatus];
    return status;
}

@end
