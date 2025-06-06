//
//  MusicTrimView.h
//  VideoFrame
//
//  Created by Yinjing Li on 1/21/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "SAVideoRangeSlider.h"
#import "CustomModalView.h"
#import "Definition.h"
#import "FDWaveformView.h"
#import "SHKActivityIndicator.h"
#import "ATMHudDelegate.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"
#import "UIImageExtras.h"
#import "AppDelegate.h"
#import "YJLActionMenu.h"

@import CoreFoundation;


@protocol MediaTrimViewDelegate <NSObject>

@optional
-(void) didCompletedTrim:(NSURL*) mediaUrl type:(int)mediaType;
-(void) didCancelTrimUI;

@end


@interface MediaTrimView : UIView<SAVideoRangeSliderDelegate, UIGestureRecognizerDelegate, FDWaveformViewDelegate, ATMHudDelegate, CustomModalViewDelegate>
{
    int mnMediaType;
    int mnVideoOrientation;
    
    BOOL mnSaveCopyFlag;
    BOOL isCameraVideo;
    BOOL isSameProgress;
    BOOL isExportCancelled;
    
    CGFloat percentageDone;
    CGFloat prevPro;
    Float64 fakeTimeElapsed;
    
    CGSize reverseVideoSize;
    CGSize cropVideoSize;
    
    NSMutableArray* timesArray;
    
    NSTimeInterval prevTimeInterval;
    
    UIView *_superView;
}

@property(nonatomic, weak) id <MediaTrimViewDelegate> delegate;

@property(nonatomic, strong) UIButton *trimButton;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UIButton *saveCheckBoxButton;
@property(nonatomic, strong) UIButton *reverseCheckBoxButton;

@property(nonatomic, strong) UIView* leftView;
@property(nonatomic, strong) UIView* rightView;

@property(nonatomic, strong) UIImageView* musicSymbolImageView;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UILabel* seekCurrentTimeLabel;
@property(nonatomic, strong) UILabel* seekTotalTimeLabel;

@property(nonatomic, strong) UISlider* seekSlider;

@property(nonatomic, strong) AVPlayerLayer *mediaPlayerLayer;

@property(nonatomic, strong) AVAsset *mediaAsset;
@property(nonatomic, strong) AVAsset *videoAsset;
@property(nonatomic, strong) AVAssetExportSession *exportSession;

@property(nonatomic, strong) AVAssetWriter *assetWriter;
@property(nonatomic, strong) AVAssetWriterInput* assetWriterInput;
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor* assetWriterPixelBufferAdaptor;
@property(nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property(nonatomic, strong) AVAsset *mixAsset;

@property(nonatomic, strong) NSURL *originalMediaUrl;
@property(nonatomic, strong) NSURL *tmpMediaUrl;
@property(nonatomic, strong) NSTimer* progressTimer;

@property(nonatomic, assign) CGFloat startTime;
@property(nonatomic, assign) CGFloat stopTime;

@property(nonatomic, assign) BOOL mnReverseFlag;
@property(nonatomic, assign) BOOL isPlaying;

@property(nonatomic, strong) SAVideoRangeSlider *mediaRangeSlider;
@property(nonatomic, strong) FDWaveformView *waveform;
@property(nonatomic, strong) ATMHud *hudProgressView;
@property(nonatomic, strong) CustomModalView* customModalView;

@property(nonatomic, assign) int nCount;

-(id) initWithFrame:(CGRect)frame url:(NSURL*) mediaUrl type:(int)mediaType flag:(BOOL)isFromCamera superView:(UIView *)superView;
-(id) initWithFrame:(CGRect)frame url:(NSURL*) mediaUrl type:(int)mediaType flag:(BOOL)isFromCamera;
-(int) getMediaType;

@end
