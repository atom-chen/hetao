//
//

#import <Foundation/Foundation.h>
#import "TextUtils.h"
#import <UIKit/UIKit.h>

@implementation TextUtils

static TextUtils *mInstance = nil;

+(TextUtils *) getInstance
{
    if(!mInstance)
    {
        mInstance = [TextUtils alloc];
        return [mInstance init];
    }
    return mInstance;
}

-(id) init
{
    return self;
}

-(void) copy:(NSString *)str
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:str];
}

-(NSString *) paste
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    return pasteboard.string;
}


@end
