//
//  YLVideoService.h
//  VideoFrame
//
//  Created by APPLE'S iMac on 2/23/20.
//  Copyright © 2020 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLVideoService : NSObject

+ (YLVideoService *)sharedInstance;

- (AVAssetExportSession *)saveVideoToFile:(AVAsset *)asset identifier:(NSString *)identifier completion:(void(^)(NSURL *fileURL))completionHandler;

@end

NS_ASSUME_NONNULL_END
