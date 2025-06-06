//
//  FileNetworkManager.m
//  RandomMusicPlayer
//
//  Created by APPLE'S iMac on 6/22/21.
//  Copyright © 2021 Yinjing Li. All rights reserved.
//

#import "FileNetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import <CoreServices/CoreServices.h>

@implementation FileNetworkManager

+ (FileNetworkManager *)sharedManager {
    static FileNetworkManager *_sharedManager;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[FileNetworkManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)retrieveFileSize:(NSURL *)url completion:(void(^)(double size))completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *urlRequest = [request mutableCopy];
    urlRequest.HTTPMethod = @"HEAD";
    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
        //NSString* contentType = [headers objectForKey:@"Content-Type"];
        NSInteger fileSize = [[headers objectForKey:@"Content-Length"] integerValue];
        //NSString* filename = [response suggestedFilename];
        if (completion) {
            completion(fileSize);
        }
    }];

    [dataTask resume];
}

- (void)estimateDownloadDuration:(NSURL *)url completion:(void(^)(double size, double duration))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSString *filename = [url lastPathComponent];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    __block NSURLSessionDownloadTask *cancelTask = nil;
    __block NSInteger count = 0;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (cancelTask != nil && count == 10) {
            [cancelTask cancel];
            cancelTask = nil;
            double downloadedBytes = downloadProgress.completedUnitCount;
            double totalBytes = downloadProgress.totalUnitCount;
            double speedSeconds = downloadedBytes / ([NSDate timeIntervalSinceReferenceDate] - startTime);
            double speed = totalBytes / speedSeconds;
            if (completion) {
                completion(totalBytes, speed);
            }
        }
        count += 1;
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    cancelTask = downloadTask;
    [downloadTask resume];
}

- (NSString *)contentType:(NSURL *)url {
    CFStringRef fileExtension = (__bridge CFStringRef)[url pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *mimeType = (__bridge_transfer NSString *)MIMEType;
    return mimeType;
}

@end
