//
//  
//

#import "MediaTool.h"
#import <AVFoundation/AVFoundation.h>
#import "OSInfoUtils.h"
#import <CoreLocation/CoreLocation.h>

@implementation MediaTool

static MediaTool *mInstance;

+(MediaTool *)getInstance
{
    if(mInstance == nil)
        mInstance = [[MediaTool alloc] init];
    return mInstance;
}

-(id)init
{
    [super init];
    return self;
}

-(int) cameraAuthorization
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    checkType = CHECKCAMERA;
    NSString *appName = [[OSInfoUtils getInstance] getAppName];
    NSString *hintStr = [NSString stringWithFormat:@"请在设备的\"设置-%@\"中允许访问相机", appName];
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
            if(granted){
                NSLog(@"Granted access mic");
            }
            else
            {
                NSLog(@"Not granted access mic");
            }
        }];
    }
    else if(authStatus != AVAuthorizationStatusAuthorized)
    {
        if(osVersion < 10.0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:hintStr
                                                               delegate:self
                                                      cancelButtonTitle:@"设置"
                                                      otherButtonTitles:@"取消", nil];
            [alertView show];
            [alertView release];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:hintStr
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
            
        }
    }

    
    return authStatus;
}

-(int)audioAuthorization
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    checkType = CHECKAUDIO;
    NSString *appName = [[OSInfoUtils getInstance] getAppName];
    NSString *hintStr = [NSString stringWithFormat:@"请在设备的\"设置-%@\"中允许访问麦克风", appName];

    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){
            if(granted){
                NSLog(@"Granted access mic");
            }
            else
            {
                NSLog(@"Not granted access mic");
            }
        }];
    }
    else if(authStatus != AVAuthorizationStatusAuthorized)
    {
        if(osVersion < 10.0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:hintStr
                                                               delegate:self
                                                      cancelButtonTitle:@"设置"
                                                      otherButtonTitles:@"取消", nil];
            [alertView show];
            [alertView release];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:hintStr
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [alertView show];
            [alertView release];
            
        }
    }
    
    return authStatus;
}

-(int)cameraAuthCode
{
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}

-(int)audioAuthCode
{
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
}

@end
