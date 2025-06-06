//
//  YJLMusicAlbumsViewController.h
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "Definition.h"

@class YJLCustomMusicController;



@interface YJLMusicAlbumsViewController : UIViewController
{
    BOOL isEdit;
    BOOL isPlaying;
    NSInteger nPlayingIndex;
}

@property (nonatomic, strong) UITableView *collectionTableView;
@property (nonatomic, strong) UITableView *musicTableView;
@property (nonatomic, strong) UIButton* sortButton;
@property (nonatomic, strong) UIButton* editButton;
@property (nonatomic, strong) NSURL* assetUrl;

@property (nonatomic, strong) AVPlayer* songPlayer;

@property (nonatomic, strong) IBOutlet UITabBar* albumsTabbar;

@property (nonatomic, strong) IBOutlet UITabBarItem* playlistsItem;
@property (nonatomic, strong) IBOutlet UITabBarItem* artistsItem;
@property (nonatomic, strong) IBOutlet UITabBarItem* songsItem;
@property (nonatomic, strong) IBOutlet UITabBarItem* albumsItem;
@property (nonatomic, strong) IBOutlet UITabBarItem* genresItem;
@property (nonatomic, strong) IBOutlet UITabBarItem* libraryItem;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabbarHeightConstraint;

@property(nonatomic, weak) YJLCustomMusicController* customMusicController;

@end



