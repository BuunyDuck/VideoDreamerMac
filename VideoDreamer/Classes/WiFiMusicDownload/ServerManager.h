//
//  ServerManager.h
//  RandomMusicPlayer
//
//  Created by APPLE'S iMac on 4/3/20.
//  Copyright © 2020 Fredc Weber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Playlist;
@class Song;

@protocol ServerManagerDelegate;

@interface ServerManager : NSObject

@property (nonatomic, strong) id<ServerManagerDelegate> delegate;

+ (ServerManager *)sharedManager;

- (BOOL)startDownloadServer:(NSUInteger)port password:(NSString *)password folder:(NSString *)folder;
- (void)stopDownloadServer;

- (NSString *)ipAddress;
- (NSURL *)serverURL;
- (NSString *)serverAddress;
- (NSString *)generateRandomPassword;
- (NSArray<NSString *> *)allowedFileExtensions;

@end

@protocol ServerManagerDelegate <NSObject>

- (void)didSelectFolder:(NSString *)name;
- (void)didCreateFolder:(NSString *)name;
- (void)didRemoveFolder:(NSString *)name;
- (void)didMoveItem:(NSString *)fromPath toPath:(NSString *)toPath;
- (void)didRemoveFile:(NSString *)filename parent:(NSString *)name;
- (BOOL)didUploadFile:(NSURL *)fileURL playlist:(NSString *)name;
- (void)didDropFiles:(NSArray *)files;
- (void)didUploadFile:(NSDictionary *)file progress:(float)progress;
- (void)serverManager:(ServerManager *)serverManager didRenameFolder:(NSString *)name;
- (void)serverManager:(ServerManager *)serverManager didRenameFile:(NSURL *)fileURL playlist:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
