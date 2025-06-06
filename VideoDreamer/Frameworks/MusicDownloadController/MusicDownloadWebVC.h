//
//  MusicDownloadWebVC.h
//  VideoFrame
//
//  Created by APPLE on 11/14/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "AppDelegate.h"
#import "YJLCustomMusicController.h"

@class MusicDownloadController;
@class MakeVideoVC;
@class YJLCustomMusicController;

@interface MusicDownloadWebVC : UIViewController<UIGestureRecognizerDelegate, WKNavigationDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) IBOutlet UIView* webContainerView;
@property (nonatomic, strong) IBOutlet WKWebView* musicWebView;
@property (nonatomic, strong) NSURL* assetUrl;

@property(nonatomic, weak)   MusicDownloadController* musicDownloadController;
@property(nonatomic, strong) MakeVideoVC* makeVideoVC;
@property(nonatomic, weak) YJLCustomMusicController* customMusicController;

@end
