//
//  
//

#import <Foundation/Foundation.h>
#import "FileTools.h"
#include <iostream>
#include "cocos2d.h"

using namespace cocos2d;

@implementation FileTools

static FileTools *mInstance = nil;

+(FileTools *) getInstance
{
    if(!mInstance)
    {
        mInstance = [FileTools alloc];
        return [mInstance init];
    }
    return mInstance;
}

-(id) init
{
    
    return self;
}

-(float) getTotalCacheSize
{
    std::string writablePath = cocos2d::FileUtils::getInstance()->getWritablePath();
    NSString *s = [NSString stringWithCString:writablePath.c_str() encoding:NSUTF8StringEncoding];
    float size = [self folderSizeAtPath:s];
    return size;
}

-(float)folderSizeAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    float folderSize;
    
    if ([fileManager fileExistsAtPath:path]) {
        
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        
        for (NSString *fileName in childerFiles) {
            
            NSString *absolutePath = [path stringByAppendingString:fileName];
            
            // 计算单个文件大小
            folderSize += [self fileSizeAtPath:absolutePath];
            
        }
        
        return folderSize;
        
    }
    
    return 0;

}

-(float)fileSizeAtPath:(NSString *)path
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]){
        
        // 返回值是字节 B K M
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        
        return size/1024.0/1024.0;
        
    }
    
    return 0;
}

-(void)clearAllCache
{
    std::string path = FileUtils::getInstance()->getWritablePath();
    [self clearCache:[NSString stringWithCString:path.c_str() encoding:NSUTF8StringEncoding]];
}

-(void)clearCache:(NSString *)path
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        
        for (NSString *fileName in childerFiles) {
            
            //如有需要，加入条件，过滤掉不想删除的文件
            
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            
            [fileManager removeItemAtPath:absolutePath error:nil];
            
        }
        
    }
}

@end
