//
//  MusicDownloadController.h
//  VideoFrame
//
//  Created by APPLE on 11/14/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MusicDownloadDelegate;

@interface MusicDownload : UINavigationController

@property (nonatomic, weak) id <MusicDownloadDelegate, UINavigationControllerDelegate> musicDownloadDelegate;

@end

@protocol MusicDownloadDelegate <NSObject>
@optional
- (void)musicDownloadDidCancel:(MusicDownload *)picker;
- (void)musicSiteDidSelected:(MusicDownload *)picker;
- (void)musicDownloadDidSelectWiFi:(MusicDownload *)picker;

@end
