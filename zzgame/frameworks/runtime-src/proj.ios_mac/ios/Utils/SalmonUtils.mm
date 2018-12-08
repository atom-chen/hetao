//
//  Lua导出接口 统一在此
//

#include "cocos2d.h"
#include "scripting/lua-bindings/manual/CCLuaBridge.h"
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#import <AVFoundation/AVFoundation.h>

#include "SalmonUtils.h"
#include "MediaUtils.h"
#include "photoGrallery.h"
#import "MediaTool.h"
#include "CameraUtils.h"
#import "TextUtils.h"
#import "FileTools.h"
#import "NetworkUtils.h"
#import "SFHFKeychainUtils.h"
#import "NetUitls.h"

@implementation SalmonUtils

using namespace cocos2d;

static SalmonUtils* s_instance = nil;
NSString* _openUrl = nil;
NSString* _notifyCategory = nil;
static NSString* _deviceToken = nil;
#define WEIXIN_PAY 1
#define ALI_PAY 2

+ (SalmonUtils*) getInstance
{
    if (!s_instance)
    {
        s_instance = [SalmonUtils alloc];
        
        Class cls = NSClassFromString(@"UMANUtil");
        SEL deviceIDSelector = @selector(openUDIDString);
        NSString *deviceID = nil;
        if(cls && [cls respondsToSelector:deviceIDSelector]){
            deviceID = [cls performSelector:deviceIDSelector];
        }
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        
        NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);

        return [s_instance init];
    }
    
    return s_instance;
}

+ (void) destroyInstance
{
    [s_instance release];
}

- (id)init
{
    _scriptHandler = 0;
    _statusBarHandler = 0;
    return self;
}



+(NSString *) getIpv4Address : (NSDictionary *)dict
{
    return NetUtils::getInstance()->getIPAddress(TRUE);
}

+(NSString *) getIpv6Address : (NSDictionary *)dict
{
    return NetUtils::getInstance()->getIPAddress(FALSE);
}

+(NSString *) getPhoneType : (NSDictionary *)dict
{
    return @"";
}

/**
 *  打开微信 , 没有配置
 */
+ (int)openWeixin
{
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
    NSURL *url = [NSURL URLWithString:@"weixin://"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        return 1;
    }else {
        return 0;
    }
}

+(void) setVolume:(NSDictionary *)dict
{
    float percent = [[dict objectForKey:@"percent"] floatValue];
    MediaUtils::getInstance()->setVolume(percent);
}

+(void) setBrightness : (NSDictionary *)dict
{
    float percent = [[dict objectForKey:@"percent"] floatValue];
    MediaUtils::getInstance()->setBrightness(percent);
}

+(float) getVolume
{
    return MediaUtils::getInstance()->getVolume();
}

+(float) getBrightness
{
    return MediaUtils::getInstance()->getBrightness();
}


+(void) openFlashLight
{
    CameraUtils::getInstance()->openFlashLight();
}

+(void)closeFlashLight
{
    CameraUtils::getInstance()->closeFlashLight();
}

+(void) copy:(NSDictionary *)dict
{
    NSString *str = [dict objectForKey:@"content"];
    [[TextUtils getInstance] copy:str];
}

+(NSString *) paste
{
    return [[TextUtils getInstance] paste];
}

+(float) getTotalCacheSize
{
    return [[FileTools getInstance] getTotalCacheSize];
}

+(void) clearAllCache
{
    [[FileTools getInstance] clearAllCache];
}



+(void)saveImageToPhotos : (NSDictionary *)dict
{
    int handler = [[dict objectForKey:@"scriptHandler"] intValue];
    NSString* imageName = [dict objectForKey:@"imageName"];
    [[photoGrallery getInstance] saveImageToPhotos:(int)handler:(NSString*)imageName];
}

+(void)openGallery : (NSDictionary *)dict
{
    int handler = [[dict objectForKey:@"scriptHandler"] intValue];
    NSString* imageName = [dict objectForKey:@"imageName"];
    [[photoGrallery getInstance] openGallery:(int)handler:(NSString*)imageName];
}

+(void)captureImage:(NSDictionary *)dict
{
    int handler = [[dict objectForKey:@"scriptHandler"] intValue];
    NSString* imageName = [dict objectForKey:@"imageName"];
    
    [[photoGrallery getInstance] captureImage:(int)handler:(NSString*)imageName];
}

+(void)setOrientation:(NSDictionary *)dict
{
    int type = [[dict objectForKey:@"typ"] intValue];
    [[ScreenUtils getInstance] setOrientation:type];
}

+(void)setOrientationEnable:(NSDictionary *)dict
{
    BOOL b = [[dict objectForKey:@"isEnable"] boolValue];
    [ScreenUtils getInstance].isAutoOrientation = b;
}

+(BOOL)getOrientationEnable
{
    return [ScreenUtils getInstance].isAutoOrientation;
}

+(void)setScreenHandler:(NSDictionary *)dict
{
    int handler = [[dict objectForKey:@"handler"] intValue];
    [[ScreenUtils getInstance] setHandler:handler];
}

+(void) setNetworkChangeEvent:(NSDictionary *)dict
{
    int handler = [[dict objectForKey:@"handler"] intValue];
    [[NetworkUtils getInstance] setNetworkChangeEvent:handler];
}

+(int) getConnectedType
{
    return [[NetworkUtils getInstance] getConnectedType];
}

+(int) cameraAuthorization
{
    return [[MediaTool getInstance] cameraAuthorization];
}

+(int)audioAuthorization
{
    return [[MediaTool getInstance] audioAuthorization];
}

+(int)cameraAuthCode
{
    return [[MediaTool getInstance] cameraAuthCode];
}

+(int)audioAuthCode
{
    return [[MediaTool getInstance] audioAuthCode];
}

+(void)setStatusBarVisible:(NSDictionary *)dict
{
    BOOL isShow = [[dict valueForKey:@"isShow"] boolValue];
//    int handler = [[dict valueForKey:@"handler"] intValue];
    [[UIApplication sharedApplication] setStatusBarHidden:!isShow];
}

+(bool)isStatusBarVisible
{
    return [[UIApplication sharedApplication] isStatusBarHidden];
}

+(float)getStatusBarHeight
{
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    return rect.size.height;
}

+(void)setIsKeepWake:(NSDictionary *)dict
{
    BOOL isKeepWake = [[dict objectForKey:@"isKeepWake"] boolValue];
//    [[UIApplication sharedApplication] setIdleTimerDisabled:true];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];  
}

+(void) thirdPlatformPay:(NSDictionary *)dict
{
    
}

+(void) aliAuthor:(NSDictionary *)dict
{
    
}


+(void) appStorePayment:(NSDictionary *)dict
{
    
}


+(NSString *) getInfoDataByKey:(NSDictionary *)dict
{
    NSString* key = [dict objectForKey:@"key"];
    NSString *data = [[[NSBundle mainBundle] infoDictionary] objectForKey:key];
    NSLog(@"%@",data);
    return data;
}

+(NSString *) getVersionName
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSLog(@"%@",version);
    
    return version;
}

+(NSString *) fixUrl2utf8:(NSDictionary *)dict
{
    NSString *urlStr = [dict objectForKey:@"urlStr"];
 //   NSLog(@"转换前： %@", urlStr);
    NSString *utf8Str = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"#%^{}\"[]|\\<> "].invertedSet];
    urlStr = [utf8Str copy];
 //   NSLog(@"转换后： %@", urlStr);
    return urlStr;
}

+(void) setOpenUrlQuery:(NSString *)urlQuery
{
    _openUrl = [[NSString alloc] init];
    _openUrl = urlQuery;
    [_openUrl retain];
   

    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        NSArray *components = [_openUrl componentsSeparatedByString:@"&"];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        for (NSString *component in components) {
            NSArray *subcomponents = [component componentsSeparatedByString:@"="];
            [parameters setObject:[[subcomponents objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                           forKey:[[subcomponents objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
        }
        [SalmonUtils callLuaEnterRoomFunc: [parameters objectForKey:@"roomId"] andUrl:[parameters objectForKey:@"liveUrl"]];
        [_openUrl release];
        _openUrl = nil;
    }
}

+(NSString *) getOpenUrlDic
{
    if(_openUrl)
    {
       
        NSString *str = [_openUrl stringByReplacingOccurrencesOfString:@"&" withString:@"*"];
        [_openUrl release];
        _openUrl = nil;
        return str;
    }
    return nil;
}

NSString *SERVICE_NAME=@"imayKey";
+(NSString *) getIdentifier
{
    NSString *identifierForVendor =  [SFHFKeychainUtils getPasswordForUsername:@"imayLive"
                                                     andServiceName:SERVICE_NAME
                                                              error:nil];
    if (identifierForVendor == nil){ //if identifierForVendor not save, now create a new
//        NSLog(@"%@",identifierForVendor);
        identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
        [SFHFKeychainUtils storeUsername:@"imayLive"
                             andPassword:identifierForVendor
                          forServiceName:SERVICE_NAME
                          updateExisting:1
                                   error:nil];
    }
    return identifierForVendor;
}

+(void) setDeviceToken:(NSString *)deviceToken;

{
    _deviceToken = deviceToken;
}

+(NSString *) getDeviceToken;
{
    return _deviceToken;
}

+(void) setNotifyCategoryType:(NSString *)category;
{
    _notifyCategory = [[NSString alloc] init];
    _notifyCategory = category;
    [_notifyCategory retain];
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        [SalmonUtils callLuaNotifyFunc: _notifyCategory];
        [_notifyCategory release];
        _notifyCategory = nil;
    }
}

+(void) callLuaAliauthResult:(NSString *)auth_code
{
    auto engine = cocos2d::LuaEngine::getInstance();
    cocos2d::ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_getglobal(L, "aliAuthResultCode");
    lua_pushstring(L, [auth_code UTF8String]);
    lua_call(L, 1, 2);
    lua_pop(L, 1);
}

+(NSString *) getNotifyCategoryType
{
    if(_notifyCategory)
    {
        NSString* category = [[NSString alloc] initWithString:_notifyCategory];
        [_notifyCategory release];
        _notifyCategory = nil;
        return category;
    }
    return nil;
}

+(void) callLuaNotifyFunc: (NSString *)notifyCategory
{
    auto engine = cocos2d::LuaEngine::getInstance();
    cocos2d::ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_getglobal(L, "callNotifyFuncByCategory");
    lua_pushstring(L, [notifyCategory UTF8String]);
    lua_call(L, 1, 2);
    lua_pop(L, 1);
}

+(void) releaseStatusBarEventHandler
{
    if(s_instance->_statusBarHandler > 0)
    {
        LuaBridge::releaseLuaFunctionById(s_instance->_statusBarHandler);
        s_instance->_statusBarHandler = 0;
    }
}

+(void) setStatusBarEventHandler:(NSDictionary *)dict
{
    [self releaseStatusBarEventHandler];
    int handler = [[dict objectForKey:@"scriptHandler"] intValue];
    s_instance->_statusBarHandler = handler;
}

+(void) callbackStatusBarEvent:(NSString *)eventType
{
    if(s_instance->_statusBarHandler > 0)
    {
        LuaBridge::pushLuaFunctionById(s_instance->_statusBarHandler);
        LuaStack *stack = LuaBridge::getStack();
        stack->pushString([eventType cStringUsingEncoding:NSUTF8StringEncoding]);
        stack->executeFunction(1);
        stack->clean(); // demo没有这一句
    }
}

+(void) umengAnalyticsEvent:(NSDictionary *)dict
{
    
}

+(void) :(NSString *)uid
{
    
}

+(void) onUserLogin:(NSDictionary*)dict
{
    
}
+(void) onUserLogout
{
    
}
@end

