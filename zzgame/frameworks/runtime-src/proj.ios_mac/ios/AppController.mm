/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2016 Chukong Technologies Inc.
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "AppController.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import <sys/utsname.h>

@implementation AppController

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

const NSString* channel = @"IOSQY01";
bool isFirstInstall = false;
// cocos2d application instance
static AppDelegate s_sharedApplication;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSNumber* buildVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* lastBuildVersion =  [defaults objectForKey:@"last_build_version"];
    //  NSLog(@"buildVersion = %@  lastBuildVersion = %@", buildVersion, lastBuildVersion);
    if(lastBuildVersion == nil or [buildVersion intValue] > [lastBuildVersion intValue]){
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* path = [NSString stringWithFormat:@"%@%@",[paths objectAtIndex:0],@"/hotupdate"];
        NSFileManager* fm =  [NSFileManager defaultManager];
        if([fm fileExistsAtPath:path]){
            [fm removeItemAtPath:path error:nil];
        }
        isFirstInstall = true;
    }
    [defaults setObject:buildVersion forKey:@"last_build_version"];
    
    cocos2d::Application *app = cocos2d::Application::getInstance();
    
    // Initialize the GLView attributes
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

    // Use RootViewController to manage CCEAGLView
    _viewController = [[RootViewController alloc]init];
    _viewController.wantsFullScreenLayout = YES;
    

    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: _viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:_viewController];
    }

    [window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden:true];
    
    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView((__bridge void *)_viewController.view);
    cocos2d::Director::getInstance()->setOpenGLView(glview);
    
    //run the cocos2d-x game scene
    app->run();

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    // We don't need to call this method any more. It will interrupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->pause(); */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    // We don't need to call this method any more. It will interrupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->resume(); */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


+(NSString*) getModel:(NSDictionary*)dic{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XSM";
    if ([platform isEqualToString:@"iPhone11,1"]) return @"iPhone XR";
    //iPod
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    //Simulator
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
}

+(NSString*) getImei:(NSDictionary*)dic{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *imei = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return imei;
}

+(NSString*) getImsi:(NSDictionary*)dic{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *imsi = @"";
    return imsi;
}

+(NSString*) getVersion:(NSDictionary*)dic{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+(NSString*) getChannel:(NSDictionary*)dic{
    NSUserDefaults* userdafault = [NSUserDefaults standardUserDefaults];
    NSString* value = [userdafault objectForKey:@"channel_code"];
    if( value != nil and [value isEqualToString:@""] ){
        return value;
    }
    
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *promote_code = (NSString *)channel;
    return promote_code;
}

+(void) onGameLauch:(NSDictionary*)dic{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[Reachability reachabilityForInternetConnection] startNotifier];
    
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(L, "networkStateChange");
    if(netStatus == NotReachable){
        cocos2d::LuaEngine::getInstance()->getLuaStack()->pushString("true");
    }else{
        cocos2d::LuaEngine::getInstance()->getLuaStack()->pushString("false");
    }
    cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunction(1);
    cocos2d::LuaEngine::getInstance()->getLuaStack()->clean();
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(L, "batteryChange");
    int level = (int)([UIDevice currentDevice].batteryLevel *100);
    cocos2d::LuaEngine::getInstance()->getLuaStack()->pushString([[NSString stringWithFormat:@"%d",level] UTF8String]);
    cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunction(1);
    cocos2d::LuaEngine::getInstance()->getLuaStack()->clean();
}

+(void) reachabilityChanged:(NSNotification *)note{
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    lua_State* L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(L, "networkStateChange");
    if(netStatus == NotReachable){
        cocos2d::LuaEngine::getInstance()->getLuaStack()->pushString("true");
    }else{
        cocos2d::LuaEngine::getInstance()->getLuaStack()->pushString("false");
    }
    cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunction(1);
    cocos2d::LuaEngine::getInstance()->getLuaStack()->clean();
}

+(void) batteryChanged:(NSNotification *)note{
    lua_State*L = cocos2d::LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(L, "batteryChange");
    int level = (int)([UIDevice currentDevice].batteryLevel *100);
    NSString* nsLevel = [NSString stringWithFormat:@"%d",level];
    const char* levelStr = [nsLevel UTF8String];
    cocos2d::LuaEngine::getInstance()->getLuaStack()->pushString(levelStr);
    cocos2d::LuaEngine::getInstance()->getLuaStack()->executeFunction(1);
    cocos2d::LuaEngine::getInstance()->getLuaStack()->clean();
}

+(int) isNetworkConnected:(NSDictionary*)dic{
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(netStatus == NotReachable){
        return 0;
    }else{
        return 1;
    }
}

+(int) getBattery:(NSDictionary*)dic{
    int level = (int)([UIDevice currentDevice].batteryLevel *100);
    return level;
}

+(float) getKeyboardHei:(NSDictionary*)dic{
    return 0;
}

+(float) getAdjustHei:(NSDictionary*)dic{
    return 0;
}

+(int) isInstallWX:(NSDictionary*)dic{
    return true;
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


#if __has_feature(objc_arc)
#else
- (void)dealloc {
    [window release];
    [_viewController release];
    [super dealloc];
}
#endif


@end
