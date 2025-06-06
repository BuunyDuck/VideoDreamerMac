//
//  MusicDownloadController.h
//  VideoFrame
//
//  Created by APPLE on 11/14/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MusicDownloadControllerDelegate;

@class MusicDownloadWebVC;

@interface MusicDownloadController : UINavigationController

@property (nonatomic, weak) id <MusicDownloadControllerDelegate, UINavigationControllerDelegate> musicDownloadControllerDelegate;

@property(nonatomic, strong) MusicDownloadWebVC* musicDownloadWebVC;

@end

@protocol MusicDownloadControllerDelegate <NSObject>
@optional
- (void)musicDownloadControllerDidCancel:(MusicDownloadController *)picker;
- (void)goToLibraryFromMusicDownloadController:(MusicDownloadController *)picker;
- (void)importSong:(MusicDownloadController *)picker asset:(NSURL *)assetUrl;
@end
