//
//  
//

#import <Foundation/Foundation.h>
#import "CameraUtils.h"
#import <AVFoundation/AVFoundation.h>

static CameraUtils* mInstance = nullptr;

CameraUtils* CameraUtils::getInstance()
{
    if(!mInstance)
        mInstance = new CameraUtils();
    return mInstance;
}

CameraUtils::CameraUtils()
{
    
}

CameraUtils::~CameraUtils()
{
    
}

void CameraUtils::openFlashLight()
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
        }
        [device unlockForConfiguration];
    }
}

void CameraUtils::closeFlashLight()
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
}

void CameraUtils::setFlashLight(bool isOpen)
{
    if (isOpen)
        openFlashLight();
    else
        closeFlashLight();
}



