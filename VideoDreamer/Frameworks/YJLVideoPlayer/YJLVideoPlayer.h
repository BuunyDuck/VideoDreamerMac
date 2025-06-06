//
//  YJLVideoPlayer.h
//  VideoFrame
//
//  Created by YinjingLi on 12/25/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@import Photos;


/**************************************************/
@protocol YJLVideoPlayerDelegate <NSObject>

@optional
-(void) openInProject;
@end
/**************************************************/


@interface YJLVideoPlayer : UIView

@property(nonatomic, assign) id <YJLVideoPlayerDelegate> delegate;

@property(nonatomic, strong) IBOutlet UILabel* myTitleLabel;
@property(nonatomic, strong) IBOutlet UIView* videoPlayerView;
@property(nonatomic, strong) IBOutlet UIButton* openInProjectButton;
@property(nonatomic, strong) IBOutlet UIImageView* openInProjectImg;

@property(nonatomic, strong) AVPlayerViewController *videoPlayer;

-(void) initFrame:(CGRect) frame;
-(void) initVideo:(PHAsset*) asset;
-(void) initMovie:(NSURL*) url;
-(void) freePlayer;

@end
