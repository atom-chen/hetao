//
//  相机操作类
//

#import <Foundation/Foundation.h>
#import "photoGrallery.h"
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

using namespace cocos2d;

@implementation photoGrallery

static photoGrallery *mInstance = nil;

+(photoGrallery *) getInstance
{
    if(!mInstance)
    {
        mInstance = [photoGrallery alloc];
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        [[window rootViewController].view addSubview:mInstance.view];
//        [mInstance.view setMultipleTouchEnabled:YES];  //屏蔽多点触摸  by wolf
        return [mInstance init];
    }
    return mInstance;
}

-(id) init
{
    handler = 0;
    return self;
}


-(void) releaseHandler
{
    if(handler)
    {
        LuaBridge::releaseLuaFunctionById(handler);
        handler = 0;
    }
}

-(void) setHandler:(int)scriptHandler
{
    [self releaseHandler];
    handler = scriptHandler;
}

-(void) setFileName:(NSString *)imageName
{
    if(fileName == NULL)
    {
        fileName = [[NSString alloc]initWithFormat:@"%@",imageName];
        return ;
    }
    else{
        [fileName release];
        fileName = [[NSString alloc]initWithFormat:@"%@",imageName];
    }
}

-(void) callbackHandler
{
    LuaBridge::pushLuaFunctionById(handler);
    LuaStack *stack = LuaBridge::getStack();
    stack->executeFunction(0);
}

// 打开相册
-(void)openGallery:(int)handler:(NSString*)imageName
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = true;
    [window.rootViewController presentModalViewController:picker animated:YES];
    [picker release];
    
    [self setHandler:handler];
    [self setFileName:imageName];
}

//开始拍照
-(void)captureImage:(int)handler:(NSString*)imageName
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [window.rootViewController presentModalViewController:picker animated:YES];
        [picker release];
        [self setHandler:handler];
        [self setFileName:imageName];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}


//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        if (image.imageOrientation != UIImageOrientationUp)
        {
            UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
            [image drawInRect:(CGRect){0, 0, image.size}];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 1);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if (fileName && fileName.length != 0) {

        }
        else{
            fileName = @"/image.png";
        }
    
        
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:fileName] contents:data attributes:nil];
        
        //得到选择后沙盒中图片的完整路径
        filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  fileName];
        //关闭相册界面
        picker.view.hidden = YES;
        [picker dismissModalViewControllerAnimated:YES];
        [picker removeFromParentViewController];
        //创建一个选择后图片的小图标放在下方
        //类似微薄选择图后的效果
        //结束
        [[photoGrallery getInstance] sendPathData];
        self.view.hidden = YES;
        [self removeFromParentViewController];
    } else {
        //关闭相册界面
        picker.view.hidden = YES;
        [picker dismissModalViewControllerAnimated:YES];
        [picker removeFromParentViewController];
        //创建一个选择后图片的小图标放在下方
        //类似微薄选择图后的效果
        //结束
        [[photoGrallery getInstance] sendPathData];
        self.view.hidden = YES;
        [self removeFromParentViewController];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    picker.view.hidden = YES;
    [picker dismissModalViewControllerAnimated:YES];
    [picker removeFromParentViewController];
    filePath = [[NSString alloc]initWithFormat:@""];
    [[photoGrallery getInstance] sendPathData];
    self.view.hidden = YES;
    [self removeFromParentViewController];
}

-(void) sendPathData
{
    const char* destDir = [filePath UTF8String];
    if (handler) {
        LuaBridge::pushLuaFunctionById(handler);
        LuaStack *stack = LuaBridge::getStack();
        stack->pushString( destDir );
        stack->executeFunction(1);
    }
    [self releaseHandler];
}


- (UIImage *)fixOrientation:(UIImage *)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
            
        case UIImageOrientationDown:
            
        case UIImageOrientationDownMirrored:
            
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            
            transform = CGAffineTransformRotate(transform, M_PI);
            
            break;
            
        case UIImageOrientationLeft:
            
        case UIImageOrientationLeftMirrored:
            
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            
            transform = CGAffineTransformRotate(transform, M_PI_2);
            
            break;
            
        case UIImageOrientationRight:
            
        case UIImageOrientationRightMirrored:
            
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            
            break;
            
        default:
            
            break;
            
    }
    
    switch (aImage.imageOrientation) {
            
        case UIImageOrientationUpMirrored:
            
        case UIImageOrientationDownMirrored:
            
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            
            transform = CGAffineTransformScale(transform, -1, 1);
            
            break;
            
        case UIImageOrientationLeftMirrored:
            
        case UIImageOrientationRightMirrored:
            
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            
            transform = CGAffineTransformScale(transform, -1, 1);
            
            break;
            
        default:
            
            break;
            
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    
    CGContextConcatCTM(ctx, transform);
    
    switch (aImage.imageOrientation) {
            
        case UIImageOrientationLeft:
            
        case UIImageOrientationLeftMirrored:
            
        case UIImageOrientationRight:
            
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            
            break;
            
        default:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            
            break;
            
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

// 保存图片到相册
- (void)saveImageToPhotos:(int)handler:(NSString*)path
{
    [self setHandler:handler];
    
    if(path)
    {
        UIImage *img = [UIImage imageNamed:path];
        [self saveImage:img];
    }
    else
    {
        NSLog(@"保存图片至相册失败");
    }
}

// 将图片等比例缩放
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    
    if (nil == image)
    {
        newimage = nil;
        
    } else {
        
        CGSize oldsize = image.size;
        
        CGRect rect;
        
        if (asize.width/asize.height > oldsize.width/oldsize.height)
        {
            
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            
            rect.size.height = asize.height;
            
            rect.origin.x = (asize.width - rect.size.width)/2;
            
            rect.origin.y = 0;
            
        } else {
            
            rect.size.width = asize.width;
            
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            
            rect.origin.x = 0;
            
            rect.origin.y = (asize.height - rect.size.height)/2;
            
        }
        
        UIGraphicsBeginImageContext(asize);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        
        [image drawInRect:rect];
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    return newimage;
}

- (void)saveImage:(UIImage*)img
{
    if(img)
    {
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"保存图片"
                              message:@"请输入正确的图片地址"
                              delegate:self
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error != NULL){
        filePath = [[NSString alloc]initWithFormat:@"failed"];
        [[photoGrallery getInstance] sendPathData];
    }else{
        filePath = [[NSString alloc]initWithFormat:@"success"];
        [[photoGrallery getInstance] sendPathData];
    }
    self.view.hidden = YES;
    [self removeFromParentViewController];
}




@end
