//
//  SpeedSegmentView.h
//  VideoFrame
//
//  Created by Yinjing Li on 4/3/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import "SAVideoRangeSlider.h"
#import "CustomModalView.h"
#import "Definition.h"
#import "SHKActivityIndicator.h"
#import "FDWaveformView.h"
#import "YJLActionMenu.h"
#import "CircleProgressBar.h"
#import "MarkerView.h"


@protocol SpeedSegmentViewDelegate <NSObject>

@optional
-(void) didSelectedMotion:(NSMutableArray*) motionsArray starts:(NSMutableArray*) startPosArray ends:(NSMutableArray*) endPosArray;
-(void) didCancelSpeed;

@end


@interface SpeedSegmentView : UIView<SAVideoRangeSliderDelegate, FDWaveformViewDelegate, UIGestureRecognizerDelegate, CustomModalViewDelegate, CircleProgressBarDelegate>
{
    int mnPlaybackCount;
    BOOL isPlaying;
    NSTimer* playbackTimer;
}

@property(nonatomic, weak) id <SpeedSegmentViewDelegate> delegate;

@property(nonatomic, strong) UIButton* applyButton;
@property(nonatomic, strong) UIButton* playButton;
@property(nonatomic, strong) UIButton* addSegmentButton;
@property(nonatomic, strong) UIButton* deleteSegmentButton;

@property(nonatomic, strong) UISlider* seekSlider;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UILabel* seekCurrentTimeLabel;
@property(nonatomic, strong) UILabel* seekTotalTimeLabel;

@property(nonatomic, strong) AVPlayerLayer* mediaPlayerLayer;

@property(nonatomic, strong) AVAsset* mediaAsset;

@property(nonatomic, strong) NSURL* originalMediaUrl;

@property(nonatomic, assign) CGFloat startTime;
@property(nonatomic, assign) CGFloat stopTime;
@property(nonatomic, assign) CGFloat timescale;
@property(nonatomic, assign) CGFloat motionValueOfSelectedSegment;

@property(nonatomic, strong) NSMutableArray* startTimeArray;
@property(nonatomic, strong) NSMutableArray* stopTimeArray;
@property(nonatomic, strong) NSMutableArray* motionValueArray;

@property(nonatomic, strong) SAVideoRangeSlider* mediaRangeSlider;
@property(nonatomic, strong) FDWaveformView* waveform;
@property(nonatomic, strong) CustomModalView* customModalView;
@property(nonatomic, strong) MarkerView* myMarkerView;
@property(nonatomic, strong) CircleProgressBar* circleProgressBar;


- (id)initWithFrame:(CGRect)frame type:(int)mediaType url:(NSURL*) meidaUrl superView:(UIView *)superView;
-(void) removeSegmentUI;

@end
