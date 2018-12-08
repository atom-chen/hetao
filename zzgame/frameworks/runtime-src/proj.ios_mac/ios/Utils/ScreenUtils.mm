//
// 
//

#import "ScreenUtils.h"
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#include "CCLuaEngine.h"
#include "CCLuaBridge.h"

using namespace cocos2d;
@implementation ScreenUtils

static ScreenUtils *mInstance = nullptr;

+(ScreenUtils *)getInstance
{
    if(!mInstance)
    {
        mInstance = [ScreenUtils alloc];
        [mInstance init];
    }
    return mInstance;

}

-(id)init
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUIKeyboardNotification2:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    return self;
}


-(void)setOrientation:(int)type
{
    switch (type) {
        case 2:
            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationLandscapeRight];
            break;
        case 1:
            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationPortrait];
            break;
            
        default:
            break;
    }
}

-(void)releaseHandler
{
    if(handler)
    {
        LuaBridge::releaseLuaFunctionById(handler);
        handler = 0;
    }
}

-(void)setHandler:(int)h
{
    [self releaseHandler];
    handler = h;
}

// 自定义键盘通知
- (void)onUIKeyboardNotification2:(NSNotification *)notif;
{
    
}

-(void)callbackHandler:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration winSize:(CGSize)winSize
{
    if(handler)
    {
        int orientation = 1;
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
            orientation = 2;
        LuaBridge::pushLuaFunctionById(handler);
        LuaStack *stack = LuaBridge::getStack();
        stack->pushInt(orientation);
        stack->pushFloat(winSize.width);
        stack->pushFloat(winSize.height);
        stack->executeFunction(3);
        stack->clean(); // demo没有这一句
    }
}



@end
