//
//  NSDate+Extension.m
//  VideoDreamer
//
//  Created by Yinjing Li on 11/15/22.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

- (NSString *)tempMP3FileName {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
    NSString *dateForFilename = [dateFormatter stringFromDate:self];
    NSString *fileName = [dateForFilename stringByAppendingString:@".mp3"];
    return fileName;
}

- (NSURL *)tempFilePathWithProjectName:(NSString *)projectName categoryName:(NSString *)categoryName extension:(NSString *)extension {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
    NSString *dateForFilename = [dateFormatter stringFromDate:self];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:projectName];
    NSURL *fileUrl = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@.%@", categoryName, dateForFilename, extension]]];
    return fileUrl;
}

- (NSString *)tempImageFilePathWithProjectName:(NSString *)projectName {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
    NSString *dateForFilename = [dateFormatter stringFromDate:self];
    
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:projectName];
    NSString* imageName = [NSString stringWithFormat:@"image-%@.png", dateForFilename];
    NSString *filePath = [folderPath stringByAppendingPathComponent:imageName];
    return filePath;
}

@end
