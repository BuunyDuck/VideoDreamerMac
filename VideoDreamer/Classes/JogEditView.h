//
//  JogEditView.h
//  VideoFrame
//
//  Created by Yinjing Li on 11/19/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import <MediaPlayer/MediaPlayer.h>
#import "SAVideoRangeSlider.h"
#import "CustomModalView.h"
#import "Definition.h"
#import "SHKActivityIndicator.h"
#import "YJLActionMenu.h"
#import "CircleProgressBar.h"
#import "ATMHudDelegate.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"


#define PLAY_READY 0
#define PLAY_MOTION 1
#define PLAY_REVERSE 2
#define PLAY_NORMAL 3
#define PLAY_REPLAY 4

@protocol JogEditViewDelegate <NSObject>

@optional
-(void) didApplyJogReverse:(NSURL*) jogVideoUrl;
-(void) didCancelJogReverse;

@end


@interface JogEditView : UIView<SAVideoRangeSliderDelegate, UIGestureRecognizerDelegate, CustomModalViewDelegate, CircleProgressBarDelegate, ATMHudDelegate>
{
    int mnPlayState;
    int mnRepeatCount;
    int mnCurrentCount;

    BOOL isPlaying;
    BOOL isExportCancelled;
    BOOL mnSaveCopyFlag;
    BOOL isExporting;

    CGSize outputVideoSize;

    NSTimer* playbackTimer;

    Float64 fakeTimeElapsed;

    NSMutableArray* timesArray;
}

@property(nonatomic, weak) id <JogEditViewDelegate> delegate;

@property(nonatomic, strong) UIButton* applyButton;
@property(nonatomic, strong) UIButton* playButton;
@property(nonatomic, strong) UIButton* saveCheckBoxButton;
@property(nonatomic, strong) UIButton* repeatCountButton;

@property(nonatomic, strong) UISlider* seekSlider;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UILabel* currentTimeLabel;
@property(nonatomic, strong) UILabel* totalTimeLabel;

@property(nonatomic, strong) AVPlayerLayer* mediaPlayerLayer;

@property(nonatomic, strong) AVAsset* mediaAsset;
@property(nonatomic, strong) AVAsset* reversedMediaAsset;

@property(nonatomic, strong) AVAssetExportSession* exportSession;
@property(nonatomic, strong) AVAssetImageGenerator* imageGenerator;

@property(nonatomic, strong) NSURL* originalMediaUrl;
@property(nonatomic, strong) NSURL* outputJogMediaUrl;
@property(nonatomic, strong) NSURL* tmpMediaUrl;
@property(nonatomic, strong) NSTimer* progressTimer;

@property(nonatomic, assign) CGFloat originalVideoDuration;
@property(nonatomic, assign) CGFloat jogStartTime;
@property(nonatomic, assign) CGFloat jogStopTime;
@property(nonatomic, assign) CGFloat timescale;
@property(nonatomic, assign) CGFloat motionValueOfJog;

@property(nonatomic, strong) AVAssetWriter* assetWriter;
@property(nonatomic, strong) AVAssetWriterInput* assetWriterInput;
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor* assetWriterPixelBufferAdaptor;

@property(nonatomic, strong) SAVideoRangeSlider* mediaRangeSlider;
@property(nonatomic, strong) CustomModalView* customModalView;
@property(nonatomic, strong) CircleProgressBar* motionProgressBar;
@property(nonatomic, strong) ATMHud* hudProgressView;

@property(nonatomic, assign) CGFloat percentageDone;
@property(nonatomic, assign) int nCount;

- (id)initWithFrame:(CGRect)frame url:(NSURL*) meidaUrl superView:(UIView *)superView;

@end
