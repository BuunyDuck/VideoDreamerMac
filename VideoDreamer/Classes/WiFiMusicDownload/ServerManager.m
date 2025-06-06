//
//  ServerManager.m
//  RandomMusicPlayer
//
//  Created by APPLE'S iMac on 4/3/20.
//  Copyright © 2020 Fredc Weber. All rights reserved.
//

#import "ServerManager.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "GCDWebUploader.h"
#import "VideoDreamer-Swift.h"

@interface ServerManager () <GCDWebUploaderDelegate>
{
    GCDWebUploader *webUploader;
}

@end

@implementation ServerManager

+ (ServerManager *)sharedManager {
    static ServerManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[ServerManager alloc] init];
    });
    return sharedManager;
}

- (BOOL)startDownloadServer:(NSUInteger)port password:(NSString *)password folder:(NSString *)folder {
    NSString *path = [PlaylistManager shared].selectSongsDirectory;
    if (webUploader) {
        [self stopDownloadServer];
    }
    webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:path];
    webUploader.password = password;
    webUploader.currentPath = folder;
    webUploader.delegate = self;
    webUploader.allowedFileExtensions = @[@"mp3", @"wav", @"zip"];
    webUploader.allowHiddenItems = YES;
    return [webUploader startWithPort:port bonjourName:@""];
}

- (void)stopDownloadServer {
    if (webUploader) {
        [webUploader stop];
        webUploader = nil;
    }
}

- (NSString *)ipAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (NSURL *)serverURL {
    return [webUploader serverURL];
}

- (NSString *)serverAddress {
    NSURL *serverURL = [self serverURL];
    if (serverURL == nil) {
        return @"";
    }
    NSString *address = serverURL.absoluteString;
    NSRange range = [address rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound && range.location == address.length - 1) {
        address = [address substringToIndex:range.location];
    }
    return address;
}

- (NSString *)generateRandomPassword {
    NSUInteger length = 8;
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *password = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
         [password appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((uint32_t)[letters length])]];
    }

    return password;
}

- (NSArray<NSString *> *)allowedFileExtensions {
    return webUploader.allowedFileExtensions;
}

#pragma mark - GCDWebUploaderDelegate
- (BOOL)webUploader:(GCDWebUploader *)uploader didUploadFileAtPath:(NSString *)path {

    NSRange range = [path rangeOfString:[PlaylistManager shared].selectSongsDirectory];
    if (range.location == NSNotFound) {
        return NO;
    }
    
    NSString *folderPath = [path substringFromIndex:range.location + range.length];
    NSArray *folders = [folderPath componentsSeparatedByString:@"/"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUploadFile:playlist:)]) {
        BOOL reload = [self.delegate didUploadFile:[NSURL fileURLWithPath:path] playlist:folders.firstObject];
        usleep(1000);
        return reload;
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:APP_SELECTSONGS_UPDATED object:fileObject];
    return NO;
}

- (void)webUploader:(GCDWebUploader *)uploader didDeleteItemAtPath:(NSString *)path {

    NSRange range = [path rangeOfString:[PlaylistManager shared].selectSongsDirectory];
    if (range.location == NSNotFound) {
        return;
    }
    
    NSString *folderPath = [path substringFromIndex:range.location + range.length];
    NSArray *folders = [folderPath componentsSeparatedByString:@"/"];
    if (folders.count == 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveFolder:)]) {
            [self.delegate didRemoveFolder:folders.firstObject];
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:APP_SELECTSONGS_UPDATED object:folderObject userInfo:@{MPMediaPlaylistPropertyPersistentID : persistentID}];
    } else {
        NSString *filename = [path lastPathComponent];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveFile:parent:)]) {
            [self.delegate didRemoveFile:filename parent:folders.lastObject];
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:APP_SELECTSONGS_UPDATED object:fileObject userInfo:@{@"parent" : parent, MPMediaItemPropertyPersistentID : persistentID}];
    }
}

- (void)webUploader:(GCDWebUploader *)uploader didDownloadFileAtPath:(NSString *)path {
    NSLog(@"didDownloadFileAtPath");
}

- (void)webUploader:(GCDWebUploader *)uploader didCreateDirectoryAtPath:(NSString *)path {

    NSRange range = [path rangeOfString:[PlaylistManager shared].selectSongsDirectory];
    if (range.location == NSNotFound) {
        return;
    }
    
    NSString *folderName = [path substringFromIndex:range.location + range.length];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCreateFolder:)]) {
        [self.delegate didCreateFolder:folderName];
    }
}

- (void)webUploader:(GCDWebUploader *)uploader didMoveItemFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    NSRange range = [fromPath rangeOfString:[PlaylistManager shared].selectSongsDirectory];
    if (range.location == NSNotFound) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didMoveItem:toPath:)]) {
        [self.delegate didMoveItem:fromPath toPath:toPath];
    }
}

- (void)webUploader:(GCDWebUploader *)uploader didListDirectoryAtPath:(NSString *)path {
    NSString* folderName = [path lastPathComponent];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectFolder:)]) {
        [self.delegate didSelectFolder:folderName];
    }
}

- (void)webUploader:(GCDWebUploader *)uploader didDropFiles:(NSArray *)files {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDropFiles:)]) {
        [self.delegate didDropFiles:files];
    }
}

- (void)webUploader:(GCDWebUploader *)uploader didUploadFile:(NSDictionary *)file progress:(float)progress {
    if (self.delegate && [self.delegate  respondsToSelector:@selector(didUploadFile:progress:)]) {
        [self.delegate didUploadFile:file progress:progress];
    }
}

@end
