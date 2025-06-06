//
//  YLVideoService.m
//  VideoFrame
//
//  Created by APPLE'S iMac on 2/23/20.
//  Copyright © 2020 Yinjing Li. All rights reserved.
//

#import "YLVideoService.h"

@implementation YLVideoService

+ (YLVideoService *)sharedInstance {
    static YLVideoService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [[YLVideoService alloc] init];
    });
    return sharedInstance;
}

- (AVAssetExportSession *)saveVideoToFile:(AVAsset *)asset identifier:(NSString *)identifier completion:(void(^)(NSURL *fileURL))completionHandler {
    if (asset == nil) {
        completionHandler(nil);
        return nil;
    }
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", identifier]];
    NSURL *outputURL = [NSURL fileURLWithPath:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        completionHandler(outputURL);
        return nil;
    }
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSError *error = exportSession.error;
        if (completionHandler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil) {
                    completionHandler(nil);
                } else {
                    completionHandler(outputURL);
                }
            });
        }
    }];

    return exportSession;
}

@end
