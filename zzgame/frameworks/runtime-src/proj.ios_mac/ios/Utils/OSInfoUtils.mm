//
//  
//

#import "OSInfoUtils.h"
#import <UIKit/UIKit.h>
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
//#import "Message/NetworkController.h"
#import "sys/utsname.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


using namespace cocos2d;
@implementation OSInfoUtils

static OSInfoUtils *mInstance = nullptr;

+(OSInfoUtils *)getInstance
{
    if(!mInstance)
    {
        mInstance = [OSInfoUtils alloc];
        [mInstance init];
    }
    return mInstance;
    
}

-(id)init
{
    
    return self;
}



-(void) test
{
    NSString * str = [self getPhoneModel];
    [self getPhoneOSVersion];
    [self getSerialNumber];
    [self getPhoneIMEI];
    [self getPhoneIMSI];
}




////地方型号  （国际化区域名称）
//NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
//NSLog(@"国际化区域名称: %@",localPhoneModel );

//NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//// 当前应用名称
//NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
//NSLog(@"当前应用名称：%@",appCurName);
//// 当前应用软件版本  比如：1.0.1
//NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//NSLog(@"当前应用软件版本:%@",appCurVersion);
//// 当前应用版本号码   int类型
//NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
//NSLog(@"当前应用版本号码：%@",appCurVersionNum);

+(NSString *) getPhoneModel
{

    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSLog(@"手机型号: %@",deviceString );  //手机型号: iPod touch
    
    return deviceString;
}

-(NSString *) getSerialNumber
{
    //手机序列号
    
    NSUUID* nsUid = [[UIDevice currentDevice] identifierForVendor];
    NSString* str = [nsUid UUIDString];
    NSLog(@"手机序列号: %@",str);  //手机序列号: 6685c75e34104be0b04c6ceb72985dc381f0f746
    
    return str;
}

-(NSString *) getPhoneSDKVersion
{
    return nil;
}

+(NSString *) getPhoneOSVersion
{
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"手机系统版本: %@", phoneVersion);  //手机系统版本: 5.1.1
    return phoneVersion;
}

-(NSString *) getPhoneNumber
{
    //电话号码
    
    return nil;
}


-(NSString *) getPhoneIMEI
{
//    [[NSUserDefaults standardUserDefaults] valueForKey:@"SBFormattedPhoneNumber"];
//    //获取手机的IMEI
//    NetworkController *ntc=[[NetworkController sharedInstance] autorelease];
//    NSString *imeistring = [ntc IMEI];
//    return imeistring;
//    return nil;
    
//    NSArray *results = getValue(@"device-imei");
//    if(results)
//    {
//           //return [results objectAtIndex:0];
//             NSString *string_content = [results objectAtIndex:0];
//        
//              const char *char_content = [string_content UTF8String];
//        
//            return [[NSString alloc] initWithCString:(const char*)char_content  encoding:NSUTF8StringEncoding];
//    }
    return nil;
}

-(NSString *) getPhoneIMSI
{
    return nil;
}

+(NSString *) getAppID
{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    return identifier;
}

-(NSString *) getAppName
{
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    return appName;
}

-(NSString *) getAppVersion
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return version;
}

-(NSString *) getCarrierName
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    return carrier.carrierName;
}

+(NSString *) getChannelId
{
    NSString *identifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ChannelID"];
    return identifier;
}

+(NSString *) getDeviceInfo
{
    return nil;
}

@end
