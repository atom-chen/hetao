//
//  
//

#ifndef FileUtils_h
#define FileUtils_h

#import <Foundation/Foundation.h>

@interface FileTools : NSObject
{
    
}

+(FileTools *) getInstance;

-(id) init;

-(float) getTotalCacheSize;

-(void) clearAllCache;

-(float)folderSizeAtPath:(NSString *)path;

-(float)fileSizeAtPath:(NSString *)path;

-(void)clearCache:(NSString *)path;

@end


#endif //FileUtils_h
