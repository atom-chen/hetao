//
//  TextUtils.h
//  Utils
//
//  Created by huzhiwei on 16/4/24.
//  Copyright © 2016年 salmon. All rights reserved.
//

#ifndef TextUtils_h
#define TextUtils_h

#import <Foundation/Foundation.h>
#include <iostream>

@interface TextUtils : NSObject
{
    
}

+(TextUtils *) getInstance;

-(id) init;

-(void) copy:(NSString *) str;

-(NSString *) paste;

@end

#endif /* TextUtils_h */
