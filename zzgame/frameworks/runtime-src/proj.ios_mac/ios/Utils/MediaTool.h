//
//  
//
#ifndef MediaTool_h
#define MediaTool_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum CheckType{
    CHECKCAMERA = 0,
    CHECKAUDIO = 1,
    CHECKLOCATION = 2, //检查定位／从名字来看似乎什么东西乱入
};

@interface MediaTool : NSObject<UIAlertViewDelegate>
{
    int checkType;
}



+(MediaTool *)getInstance;

-(id)init;

-(int)cameraAuthorization;

-(int)audioAuthorization;

-(int)cameraAuthCode;

-(int)audioAuthCode;


@end

#endif  //MediaTool_h
