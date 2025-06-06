//
//  EditTrimView.h
//  VideoFrame
//
//  Created by Yinjing Li on 12/27/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "SAVideoRangeSlider.h"
#import "CustomModalView.h"
#import "Definition.h"
#import "SHKActivityIndicator.h"
#import "ATMHudDelegate.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"
#import "UIImageExtras.h"
#import "YJLActionMenu.h"
#import "FDWaveformView.h"

@import CoreFoundation;


@protocol EditTrimViewDelegate <NSObject>

@optional
-(void) didEditTrim:(NSURL*) mediaUrl;
-(void) didCancelEditTrim;

@end


@interface EditTrimView : UIView<SAVideoRangeSliderDelegate, UIGestureRecognizerDelegate, ATMHudDelegate, CustomModalViewDelegate, FDWaveformViewDelegate>
{
    int mnMediaType;

    BOOL mnSaveCopyFlag;
    BOOL isSameProgress;
    BOOL isExportCancelled;
    
    CGFloat prevPro;
    
    NSTimeInterval prevTimeInterval;
}

@property(nonatomic, weak) id <EditTrimViewDelegate> delegate;

@property(nonatomic, strong) UIButton *trimButton;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UIButton *saveCheckBoxButton;

@property(nonatomic, strong) UIView* leftView;
@property(nonatomic, strong) UIView* rightView;

@property(nonatomic, strong) UIImageView* musicSymbolImageView;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UILabel* seekCurrentTimeLabel;
@property(nonatomic, strong) UILabel* seekTotalTimeLabel;

@property(nonatomic, strong) UISlider* seekSlider;

@property(nonatomic, strong) AVPlayerLayer *mediaPlayerLayer;

@property(nonatomic, strong) AVAsset *mediaAsset;
@property(nonatomic, strong) AVAssetExportSession *exportSession;

@property(nonatomic, strong) AVAssetWriter *assetWriter;
@property(nonatomic, strong) AVAssetWriterInput* assetWriterInput;
@property(nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor* assetWriterPixelBufferAdaptor;
//@property(nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property(nonatomic, strong) NSURL *inputMediaUrl;
@property(nonatomic, strong) NSURL *outputMediaUrl;
@property(nonatomic, strong) NSTimer* progressTimer;

@property(nonatomic, assign) CGFloat startTime;
@property(nonatomic, assign) CGFloat stopTime;

@property(nonatomic, assign) BOOL isPlaying;

@property(nonatomic, strong) FDWaveformView *waveform;
@property(nonatomic, strong) SAVideoRangeSlider *mediaRangeSlider;
@property(nonatomic, strong) ATMHud *hudProgressView;
@property(nonatomic, strong) CustomModalView *customModalView;


- (id)initWithFrame:(CGRect)frame type:(int)mediaType url:(NSURL*) meidaUrl superView:(UIView *)superView;

@end
