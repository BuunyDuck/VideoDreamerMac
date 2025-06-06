//
//  VideoFiltersView.h
//  VideoFrame
//
//  Created by Yinjing Li on 02/20/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "VideoFilterThumbView.h"
#import "ATMHudDelegate.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"
#import "CustomModalView.h"
#import <MediaPlayer/MediaPlayer.h>


@import Photos;

@protocol VideoFiltersViewDelegate <NSObject>

@optional
-(void) didCancelVideoFilterUI;
-(void) didApplyVideoFilter:(NSURL*) url;
@end


#define APPLY_NONE 0
#define APPLY_FILTER 1

@interface VideoFiltersView : UIView<UINavigationControllerDelegate, VideoFilterThumbViewDelegate, ATMHudDelegate, CustomModalViewDelegate>
{
    CGFloat thumbWidth;
    CGFloat thumbHeight;
    
    BOOL isPhotoTake;
    
    UIView *_superView;
}

@property(nonatomic, weak) id <VideoFiltersViewDelegate> delegate;

@property(nonatomic, strong) UIImageView *filterView;
@property(nonatomic, strong) AVPlayer *videoPlayer;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic, strong) CIContext *context;

@property(nonatomic, strong) ATMHud *hudProgressView;

@property(nonatomic, strong) CustomModalView* customModalView;

@property(nonatomic, strong) UIButton* applyButton;
@property(nonatomic, strong) UIButton* playButton;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UILabel* videoLegthLabel;
@property(nonatomic, strong) UILabel* videoPositionLabel;

@property(nonatomic, strong) UISlider* seekSlider;
@property(nonatomic, strong) UISlider* filterSlider;

@property(nonatomic, strong) UIScrollView* filterScrollView;

@property(nonatomic, strong) AVAssetExportSession *assetExportSession;
@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, strong) NSURL* originalVideoUrl;

@property(nonatomic, strong) NSMutableArray* thumbArray;

@property(nonatomic, assign) NSInteger filterIndex;
@property(nonatomic, assign) float filterValue;
@property(nonatomic, strong) CIImage *whiteImage;

@property(nonatomic, assign) BOOL isPlaying;

@property(nonatomic, strong) id observer;

- (id)initWithFrame:(CGRect)frame superView:(UIView *)superView;

- (void)initParams:(NSURL*) originVideoUrl image:(UIImage*) thumbImage;

- (CIFilter *)setupFilterWithSize:(CGSize)size;

+ (VideoFiltersView *)sharedInstance;

@end
