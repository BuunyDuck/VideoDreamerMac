//
//  FDWaveformView
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "SHKActivityIndicator.h"


@protocol FDWaveformViewDelegate;

@interface FDWaveformView : UIView


@property (nonatomic, weak) id<FDWaveformViewDelegate> delegate;

@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) AVAssetReaderTrackOutput *output;
@property (nonatomic, strong) NSMutableData *fullSongData;
@property (nonatomic, strong) NSDictionary *outputSettingsDict;

@property (nonatomic, assign, readonly) unsigned long int totalSamples;
@property (nonatomic, assign) unsigned long int progressSamples;
@property (nonatomic, assign) unsigned long int startSamples; // does nothing right now (see #9)
@property (nonatomic, assign) unsigned long int endSamples; // does nothing right now (see #9)

@property (nonatomic) BOOL doesAllowScrubbing;

@property (nonatomic, copy) UIColor *wavesColor;
@property (nonatomic, copy) UIColor *progressColor;


-(void) createWaveform;
- (void)changeWaveFrame;
- (void)changeStartEndSamples:(unsigned long int) startSample end:(unsigned long int) endSample;

@end



@protocol FDWaveformViewDelegate <NSObject>
@optional
- (void)waveformViewWillRender:(FDWaveformView *)waveformView;
- (void)waveformViewDidRender:(FDWaveformView *)waveformView;
@end
