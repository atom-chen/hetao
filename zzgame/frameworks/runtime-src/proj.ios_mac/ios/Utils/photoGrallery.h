//
//  相机操作类
//

#ifndef photoGrallery__h
#define photoGrallery__h

#import <UIKit/UIKit.h>


@interface photoGrallery : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    int handler;
    NSString* filePath;
    NSString *fileName;
}

+(photoGrallery *) getInstance;

-(id) init;

-(void) openGallery:(int)handler:(NSString*)imageName;

-(void) captureImage:(int)handler:(NSString*)imageName;

-(void) releaseHandler;

-(void) setHandler:(int) scriptHandler;
-(void) setFileName:(NSString*) imageName;

-(void) callbackHandler;

-(void) sendPathData;

- (UIImage *)fixOrientation:(UIImage *)aImage;
//-(int) getScriptHandler;
//-(void) setScriptHandler:(int)scriptHandler;
//+(void)registerScriptHandler:(NSDictionary *)dict;
//+(void)unregisterScriptHandler;
//+(void)callbackScriptHandler:(std::string)path;

// 保存图片到相册
-(void) saveImage:(UIImage *)img;
-(void) saveImageToPhotos:(int)handler:(NSString*)path;

// 将图片等比例缩放
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo;

@end

#endif //photoGrallery__h
