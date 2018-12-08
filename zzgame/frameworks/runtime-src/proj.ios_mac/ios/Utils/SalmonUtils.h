//
//  Lua导出接口 统一在此
//

#ifndef SalmonUtils_h
#define SalmonUtils_h

#import <Foundation/Foundation.h>
#include <iostream>
#import "ScreenUtils.h"

@interface SalmonUtils : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate> {
    int _scriptHandler;
    NSString* filePath;
    int _statusBarHandler;
}

+ (SalmonUtils*) getInstance;
+ (void) destroyInstance;

+ (int)openWeixin;

+(NSString *) getPhoneType : (NSDictionary *)dict;

+(void) setVolume:(NSDictionary *)dict;

+(void) setBrightness:(NSDictionary *)dict;

+(float) getVolume;

+(float) getBirghtness;

+(void) openFlashLight;

+(void) closeFlashLight;

+(void) getCNBylocation:(NSDictionary *)dict;

+(void) copy:(NSDictionary *)dict;

+(NSString *) paste;

+(float) getTotalCacheSize;

+(void) clearAllCache;

// by wolf
+(void)saveImageToPhotos:(NSDictionary *)dict;

+(void)openGallery:(NSDictionary *)dict;

+(void)captureImage:(NSDictionary *)dict;

+(void)setOrientation:(NSDictionary *)dict;

+(void)setOrientationEnable:(NSDictionary *)dict;

+(BOOL)getOrientationEnable;

+(void)setScreenHandler:(NSDictionary *)dict;

+(void)setNetworkChangeEvent:(NSDictionary *)dict;


+(int)cameraAuthorization;

+(int)audioAuthorization;

+(int)locationAuthorization;

+(int)cameraAuthCode;

+(int)audioAuthCode;

// 0无连接 1 wifi 2 移动网络
+(int) getConnectedType;

+(void) setStatusBarVisible:(NSDictionary *)dict;

+(bool) isStatusBarVisible;

+(float) getStatusBarHeight;

+(int)getLocationAuth;
+(void) thirdPlatformPay:(NSDictionary *)dict;
+(void) aliAuthor:(NSDictionary *)dict;


+(void) appStorePayment:(NSDictionary *)dict;

//版本号
+(NSString *) getVersionName;

+(void) setOpenUrlQuery:(NSString *)urlQuery;
+(NSString *) getOpenUrlDic;
+(NSString *) getIdentifier;

+(NSString *) fixUrl2utf8:(NSString *)urlStr;

+(void) setDeviceToken:(NSString *)deviceToken;
+(NSString *) getDeviceToken;
+(void) callLuaEnterRoomFunc:(NSString *)roomId andUrl:(NSString *)url;

+(void) setNotifyCategoryType:(NSString *)category;
+(NSString *) getNotifyCategoryType;
+(void) callLuaNotifyFunc: (NSString *)notifyCategory;

// 释放状态了事件
+(void) releaseStatusBarEventHandler;

// 设置状态了事件
+(void) setStatusBarEventHandler:(NSDictionary *)dict;

+(void) callbackStatusBarEvent:(NSString *)eventType;
+(void) callLuaAliauthResult:(NSString *)auth_code;
+(void) umengAnalyticsEvent:(NSDictionary *)dict;
+(void) accountCreate:(NSString *)uid;
+(void) onUserLogin:(NSDictionary*)dict;
+(void) onUserLogout;

- (id) init;
@end

#endif /* SalmonUtil_h */
