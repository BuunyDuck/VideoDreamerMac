//
//  FileNetworkManager.h
//  RandomMusicPlayer
//
//  Created by APPLE'S iMac on 6/22/21.
//  Copyright © 2021 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileNetworkManager : NSObject

+ (FileNetworkManager *)sharedManager;

- (void)retrieveFileSize:(NSURL *)url completion:(void(^)(double size))completion;
- (void)estimateDownloadDuration:(NSURL *)url completion:(void(^)(double size, double duration))completion;
- (NSString *)contentType:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
