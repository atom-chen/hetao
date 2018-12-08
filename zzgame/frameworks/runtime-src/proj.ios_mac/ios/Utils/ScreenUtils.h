//
//  
//

#ifndef ScreenUtils_h
#define ScreenUtils_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ScreenUtils : NSObject
{
    int handler;
}
@property (nonatomic) BOOL isAutoOrientation;
//@property (nonatomic) NSUInteger supportOrientation;

+(ScreenUtils *)getInstance;

-(id)init;

-(void) setOrientation:(int)type;

-(void) setHandler:(int)handler;

-(void) releaseHandler;

-(void)callbackHandler:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration winSize:(CGSize)winSize;

@end

#endif //ScreenUtils_h
