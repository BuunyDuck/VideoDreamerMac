//
//  NSDate+Extension.h
//  VideoDreamer
//
//  Created by Yinjing Li on 11/15/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Extension)

- (NSString *)tempMP3FileName;
- (NSURL *)tempFilePathWithProjectName:(NSString *)projectName categoryName:(NSString *)categoryName extension:(NSString *)extension;
- (NSString *)tempImageFilePathWithProjectName:(NSString *)projectName;

@end

NS_ASSUME_NONNULL_END
