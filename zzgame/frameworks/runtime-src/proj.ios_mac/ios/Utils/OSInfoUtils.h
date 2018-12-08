//
//  
//

#ifndef OSInfoUtils_h
#define OSInfoUtils_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OSInfoUtils : NSObject
{
    int handler;
}
@property (nonatomic) BOOL isAutoOrientation;

+(OSInfoUtils *)getInstance;

-(id)init;

-(void) test;

-(NSString *) getSerialNumber;

+(NSString *) getPhoneModel;

-(NSString *) getPhoneSDKVersion;

+(NSString *) getPhoneOSVersion;

-(NSString *) getPhoneNumber;

-(NSString *) getPhoneIMEI;

-(NSString *) getPhoneIMSI;

+(NSString *) getAppID;

-(NSString *) getAppName;

-(NSString *) getAppVersion;
-(NSString *) getCarrierName;
+(NSString *) getChannelId;
+(NSString *) getDeviceInfo;

@end

#endif //OSInfoUtils_h
