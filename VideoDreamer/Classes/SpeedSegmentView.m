//
//  SpeedSegmentView.m
//  VideoFrame
//
//  Created by Yinjing Li on 4/3/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "SpeedSegmentView.h"
#import "SceneDelegate.h"

#define CIRCLE_PICKER_VISIT_TIME 0.2f

@implementation SpeedSegmentView

- (id)initWithFrame:(CGRect)frame type:(int)mediaType url:(NSURL*) meidaUrl superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];

        isPlaying = NO;

        self.originalMediaUrl = meidaUrl;
        
        self.mediaAsset = nil;
        self.mediaAsset = [AVURLAsset assetWithURL:self.originalMediaUrl];

        self.motionValueOfSelectedSegment = 1.0f;
        self.startTime = 0.0f;
        self.stopTime = CMTimeGetSeconds(self.mediaAsset.duration);
       
        NSString* timeString = [self timeToString:(self.stopTime - self.startTime)/self.motionValueOfSelectedSegment];
        
        UIEdgeInsets safeAreaInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        if (superView != nil) {
            safeAreaInsets = superView.safeAreaInsets;
        }

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if (mediaType == MEDIA_MUSIC)
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f + safeAreaInsets.left, self.frame.size.height - 95.0f - safeAreaInsets.bottom, self.frame.size.width - 120.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, self.frame.size.height - 95.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 50.0f - safeAreaInsets.right, self.frame.size.height - 95.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
            }
            else
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f + safeAreaInsets.left, self.frame.size.height - 65.0f - safeAreaInsets.bottom, self.frame.size.width - 120.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, self.frame.size.height - 65.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 50.0f - safeAreaInsets.right, self.frame.size.height - 65.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
            }
            
            [self.seekCurrentTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:11]];
            [self.seekTotalTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:11]];
        }
        else
        {
            if (mediaType == MEDIA_MUSIC)
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(80.0f + safeAreaInsets.left, self.frame.size.height - 130.0f - safeAreaInsets.bottom, self.frame.size.width - 160.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, self.frame.size.height - 130.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 50.0f - safeAreaInsets.right, self.frame.size.height - 130.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
            }
            else
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(80.0f + safeAreaInsets.left, self.frame.size.height - 100.0f - safeAreaInsets.bottom, self.frame.size.width - 160.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 100.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 50.0f - safeAreaInsets.right, self.frame.size.height - 100.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
            }
            
            [self.seekCurrentTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:14]];
            [self.seekTotalTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:14]];
        }
        
        UIImage *minImage = [UIImage imageNamed:@"slider_min"];
        UIImage *maxImage = [UIImage imageNamed:@"slider_max"];
        UIImage *tumbImage = nil;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            tumbImage = [UIImage imageNamed:@"slider_thumb"];
        else
            tumbImage = [UIImage imageNamed:@"slider_thumb_ipad"];
        
        minImage = [minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        maxImage = [maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        
        [self.seekSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [self.seekSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [self.seekSlider setThumbImage:tumbImage forState:UIControlStateNormal];
        [self.seekSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
        [self.seekSlider setBackgroundColor:[UIColor clearColor]];
        [self.seekSlider setValue:0.0f];
        [self.seekSlider addTarget:self action:@selector(playerSeekPositionChanged) forControlEvents:UIControlEventValueChanged];
        [self.seekSlider setMinimumValue:self.startTime];
        [self.seekSlider setMaximumValue:self.stopTime];
        [self addSubview:self.seekSlider];
        
        [self.seekCurrentTimeLabel setBackgroundColor:[UIColor clearColor]];
        [self.seekCurrentTimeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.seekCurrentTimeLabel setAdjustsFontSizeToFitWidth:YES];
        [self.seekCurrentTimeLabel setMinimumScaleFactor:0.1f];
        [self.seekCurrentTimeLabel setNumberOfLines:1];
        [self.seekCurrentTimeLabel setTextColor:[UIColor yellowColor]];
        [self.seekCurrentTimeLabel setText:@"00:00.000"];
        [self addSubview:self.seekCurrentTimeLabel];
        
        [self.seekTotalTimeLabel setBackgroundColor:[UIColor clearColor]];
        [self.seekTotalTimeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.seekTotalTimeLabel setAdjustsFontSizeToFitWidth:YES];
        [self.seekTotalTimeLabel setMinimumScaleFactor:0.1f];
        [self.seekTotalTimeLabel setNumberOfLines:1];
        [self.seekTotalTimeLabel setTextColor:[UIColor yellowColor]];
        self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeString];
        [self addSubview:self.seekTotalTimeLabel];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            if (mediaType == MEDIA_MUSIC)
                self.mediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(10 + safeAreaInsets.left, self.frame.size.height - 90.0f - safeAreaInsets.bottom, self.frame.size.width - 70.0 - safeAreaInsets.left - safeAreaInsets.right, 80.0) videoUrl:self.originalMediaUrl value:self.motionValueOfSelectedSegment];
            else
                self.mediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(10 + safeAreaInsets.left, self.frame.size.height - 60.0f - safeAreaInsets.bottom, self.frame.size.width - 70.0 - safeAreaInsets.left - safeAreaInsets.right, 50.0) videoUrl:self.originalMediaUrl value:self.motionValueOfSelectedSegment];
        }
        else
        {
            if (mediaType == MEDIA_MUSIC)
                self.mediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(5.0 + safeAreaInsets.left, self.frame.size.height - 65.0f - safeAreaInsets.bottom, self.frame.size.width - 40.0 - safeAreaInsets.left - safeAreaInsets.right, 60.0) videoUrl:self.originalMediaUrl value:self.motionValueOfSelectedSegment];
            else
                self.mediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(5.0 + safeAreaInsets.left, self.frame.size.height - 35.0f - safeAreaInsets.bottom, self.frame.size.width - 40.0 - safeAreaInsets.left - safeAreaInsets.right, 30.0) videoUrl:self.originalMediaUrl value:self.motionValueOfSelectedSegment];
        }
        
        self.mediaRangeSlider.delegate = self;
        [self addSubview:self.mediaRangeSlider];
        [self.mediaRangeSlider setLeftRight:self.startTime end:self.stopTime];

        if (mediaType == MEDIA_MUSIC)
        {
            self.waveform = [[FDWaveformView alloc] initWithFrame:CGRectMake(self.mediaRangeSlider.frame.origin.x, self.mediaRangeSlider.frame.origin.y, self.mediaRangeSlider.frame.size.width, self.mediaRangeSlider.frame.size.height)];
            self.waveform.delegate = self;
            self.waveform.alpha = 0.0f;
            self.waveform.audioURL = self.originalMediaUrl;
            self.waveform.progressSamples = 10000;
            self.waveform.doesAllowScrubbing = YES;
            [self addSubview:self.waveform];
            self.waveform.userInteractionEnabled = NO;
            [self.waveform createWaveform];
        }
        
        //play button
        CGFloat x = self.frame.size.width - (self.mediaRangeSlider.frame.origin.x * 2.0 + self.mediaRangeSlider.frame.size.width);
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.playButton setFrame:CGRectMake(self.frame.size.width - x - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y, 30.0f, 30.0f)];
        else
            [self.playButton setFrame:CGRectMake(self.frame.size.width - x - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y, 50.0f, 50.0f)];
        
        self.playButton.center = CGPointMake(self.playButton.center.x, self.mediaRangeSlider.center.y);
        [self.playButton setBackgroundColor:[UIColor clearColor]];
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playbackMotionMovie:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        
        
        // apply button
        self.applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.applyButton setFrame:CGRectMake(10.0f + safeAreaInsets.left, 5.0f + safeAreaInsets.top, 50.0f, 30.0f)];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:15]];
        else
            [self.applyButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:20]];
        [self.applyButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [self.applyButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.applyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.applyButton setBackgroundColor:UIColorFromRGB(0x53585f)];
        [self setSelectedBackgroundViewFor:self.applyButton];
        [self.applyButton.layer setMasksToBounds:YES];
        [self.applyButton.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.applyButton.layer setBorderWidth:1.0f];
        [self.applyButton.layer setCornerRadius:3.0f];
        [self.applyButton setTitle:NSLocalizedString(@" Apply ", nil) forState:UIControlStateNormal];
        [self.applyButton addTarget:self action:@selector(actionApplyButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.applyButton];
        
        CGFloat labelWidth = [self.applyButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyButton.titleLabel.font}].width;
        CGFloat labelHeight = [self.applyButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyButton.titleLabel.font}].height;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyButton setFrame:CGRectMake(5.0f + safeAreaInsets.left, 5.0f + safeAreaInsets.top, labelWidth + 10.0f, labelHeight + 15.0f)];
        else
            [self.applyButton setFrame:CGRectMake(20.0f + safeAreaInsets.left, 20.0f + safeAreaInsets.top, labelWidth + 20.0f, labelHeight + 20.0f)];

        
        // media player
        self.mediaPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.mediaAsset]]];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [_mediaPlayerLayer setFrame:CGRectMake(5.0f + safeAreaInsets.left, self.applyButton.frame.origin.y + self.applyButton.frame.size.height + 10.0f, self.frame.size.width - 10.0f - safeAreaInsets.left - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y - (self.applyButton.frame.origin.y + self.applyButton.frame.size.height) - 20.0f - safeAreaInsets.bottom)];
        else
            [_mediaPlayerLayer setFrame:CGRectMake(10 + safeAreaInsets.left, self.applyButton.frame.origin.y + self.applyButton.frame.size.height + 20.0f, self.frame.size.width - 20.0f - safeAreaInsets.left - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y - (self.applyButton.frame.origin.y + self.applyButton.frame.size.height) - 40.0f - safeAreaInsets.bottom)];

        [self.layer insertSublayer:_mediaPlayerLayer atIndex:0];
        
        [_mediaPlayerLayer.player setVolume:1.0f];
        [_mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale)];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaPlayDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];

        CGFloat duration = self.mediaAsset.duration.value / 500;
        
        __weak typeof(self) weakSelf = self;
        
        [self.mediaPlayerLayer.player addPeriodicTimeObserverForInterval:CMTimeMake(MAX(1, duration), self.mediaAsset.duration.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            __strong SpeedSegmentView *sself = weakSelf;
            
            if (!sself)
                return;
            
            if ([weakSelf.mediaPlayerLayer.player rate] != 0.0f)
            {
                CGFloat currentTime = CMTimeGetSeconds(time);

                if (currentTime > weakSelf.stopTime)
                {
                    currentTime = weakSelf.stopTime;
                    [sself performSelector:@selector(mediaDidFinish)];
                }
                
                weakSelf.seekSlider.value = currentTime;
            }
        }];
        
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if (self.frame.size.width > self.frame.size.height) //landscape
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, 5.0f + safeAreaInsets.top, self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
            else
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.applyButton.frame.origin.x + self.applyButton.frame.size.width), self.applyButton.center.y - 15.0f, self.frame.size.width - (self.applyButton.frame.origin.x + self.applyButton.frame.size.width), 30.0f)];
            
            self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:21];
        }
        else
        {
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, self.applyButton.center.y - 15.0f, self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
            self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:27];
        }
        
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self.titleLabel setMinimumScaleFactor:0.1f];
        [self.titleLabel setNumberOfLines:1];
        [self.titleLabel setShadowColor:[UIColor blackColor]];
        [self.titleLabel setShadowOffset:CGSizeMake(1.0f, 1.0f)];
        [self.titleLabel.layer setShadowOpacity:0.8f];
        [self addSubview:self.titleLabel];

        if (mediaType == MEDIA_VIDEO)
            self.titleLabel.text = NSLocalizedString(@"Video Speed Segment", nil);
        else if (mediaType == MEDIA_MUSIC)
            self.titleLabel.text = NSLocalizedString(@"Music Speed Segment", nil);
        
        labelWidth = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}].width;

        
        CGFloat segmentButtonWidth;
        CGFloat defaultHeight;
        CGFloat mfCircleProgressBarWidth;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            mfCircleProgressBarWidth = 130.0f;
            defaultHeight = 25.0f;
            segmentButtonWidth = 20.0f;
        }
        else
        {
            mfCircleProgressBarWidth = 200.0f;
            defaultHeight = 50.0f;
            segmentButtonWidth = 30.0f;
        }


        self.addSegmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addSegmentButton setFrame:CGRectMake(0.0f, self.titleLabel.frame.origin.y, segmentButtonWidth, segmentButtonWidth)];
        [self.addSegmentButton.titleLabel setFont:self.titleLabel.font];
        [self.addSegmentButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.addSegmentButton setTitle:@"+" forState:UIControlStateNormal];
        [self.addSegmentButton setTitle:@"+" forState:UIControlStateSelected];
        self.addSegmentButton.layer.cornerRadius = segmentButtonWidth/2.0f;
        self.addSegmentButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.addSegmentButton.layer.borderWidth = 1.0f;
        [self.addSegmentButton addTarget:self action:@selector(actionAddNewSegment:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.addSegmentButton];
        self.addSegmentButton.center = CGPointMake((self.bounds.size.width + self.titleLabel.center.x + labelWidth/2.0f)/2.0f, self.titleLabel.center.y);
        
        
        self.deleteSegmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteSegmentButton setFrame:CGRectMake(0.0f, self.titleLabel.frame.origin.y, segmentButtonWidth, segmentButtonWidth)];
        [self.deleteSegmentButton.titleLabel setFont:self.titleLabel.font];
        [self.deleteSegmentButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.deleteSegmentButton setTitle:@"-" forState:UIControlStateNormal];
        [self.deleteSegmentButton setTitle:@"-" forState:UIControlStateSelected];
        self.deleteSegmentButton.layer.cornerRadius = segmentButtonWidth/2.0f;
        self.deleteSegmentButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.deleteSegmentButton.layer.borderWidth = 1.0f;
        [self.deleteSegmentButton addTarget:self action:@selector(deleteSegment:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteSegmentButton];
        self.deleteSegmentButton.center = CGPointMake((self.applyButton.frame.origin.x + self.applyButton.frame.size.width + self.titleLabel.center.x - labelWidth / 2.0f) / 2.0f, self.titleLabel.center.y);
        self.deleteSegmentButton.hidden = YES;


        self.circleProgressBar = [[CircleProgressBar alloc] initWithFrame:CGRectMake((self.bounds.size.width - mfCircleProgressBarWidth)/2.0f, (self.bounds.size.height - mfCircleProgressBarWidth)/2.0f, mfCircleProgressBarWidth, mfCircleProgressBarWidth)];
        self.circleProgressBar.delegate = self;
        [self.circleProgressBar setProgressBarWidth:(self.circleProgressBar.bounds.size.width*0.1f)];
        [self.circleProgressBar setHintViewSpacingForDrawing:(self.circleProgressBar.bounds.size.width*0.0833f)];
        [self addSubview:self.circleProgressBar];
        [self.circleProgressBar setProgress:self.motionValueOfSelectedSegment timeString:timeString];
        
        
        self.myMarkerView = [[MarkerView alloc] initWithFrame:CGRectMake(self.mediaRangeSlider.frame.origin.x + 1.0f, self.seekSlider.frame.origin.y - defaultHeight, self.mediaRangeSlider.frame.size.width - 2.0f, defaultHeight)];
        [self addSubview:self.myMarkerView];
        
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
        [self addGestureRecognizer:panRecognizer];
        
        [self bringSubviewToFront:self.mediaRangeSlider];
    }
    
    return self;
}

-(void) removeSegmentUI
{
    [self.circleProgressBar removeFromSuperview];
    [self.myMarkerView removeFromSuperview];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setSelectedBackgroundViewFor:(UIButton *) button
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(button.bounds.size.width, button.bounds.size.height), NO, 0.0);
    [UIColorFromRGB(0x9da1a0) set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.5f, 0.5f, button.bounds.size.width - 0.5f, button.bounds.size.height - 0.5f));
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setBackgroundImage:resultImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:resultImage forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (NSString *)timeToString:(CGFloat)time
{
    // time - seconds
    NSInteger min = floor(time / 60);
    NSInteger sec = floor(time - min * 60);
    NSInteger millisecond = roundf((time - (min*60 + sec))*1000);
    
    if (millisecond == 1000)
    {
        millisecond = 0;
        sec++;
    }

    NSString *minStr = [NSString stringWithFormat:min >= 10 ? @"%i" : @"0%d", (int)min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%i" : @"0%d", (int)sec];
    
    NSString *millisecStr = nil;

    if (millisecond >= 100)
        millisecStr = [NSString stringWithFormat:@"%d", (int)millisecond];
    else if (millisecond >= 10)
        millisecStr = [NSString stringWithFormat:@"0%d", (int)millisecond];
    else
        millisecStr = [NSString stringWithFormat:@"00%d", (int)millisecond];
    
    return [NSString stringWithFormat:@"%@:%@.%@", minStr, secStr, millisecStr];
}


#pragma mark -
#pragma mark - Playback

- (void) playbackMotionMovie:(id) sender
{
    if (isPlaying)
    {
        isPlaying = NO;
        
        [self.mediaPlayerLayer.player pause];
        
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [playbackTimer invalidate];
        playbackTimer = nil;
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            self.circleProgressBar.alpha = 1.0f;
        }];
    }
    else
    {
        isPlaying = YES;
        
        CGFloat currentTime = CMTimeGetSeconds(self.mediaPlayerLayer.player.currentTime);
        
        if ((currentTime - 0.1f) <= self.startTime)
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMake(self.startTime * self.mediaAsset.duration.timescale, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        else if ((currentTime + 0.1f) >= self.stopTime)
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMake(self.startTime * self.mediaAsset.duration.timescale, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        
        mnPlaybackCount = -1;
        
        if (playbackTimer)
        {
            [playbackTimer invalidate];
            playbackTimer = nil;
        }
        
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:.02f target:self selector:@selector(playbackTimeUpdate:) userInfo:nil repeats:YES];
        
        [self.mediaPlayerLayer.player play];
        self.mediaPlayerLayer.player.rate = self.motionValueOfSelectedSegment;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
        else
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            self.circleProgressBar.alpha = 0.0f;
        }];
    }
}

- (void)playbackTimeUpdate:(NSTimer*)timer
{
    CGFloat currentTime = CMTimeGetSeconds(self.mediaPlayerLayer.player.currentTime);
    
    for (int i = 0; i < self.mediaRangeSlider.videoRangeSliderArray.count; i++)
    {
        SASliderView* sliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
        
        CGFloat startTime = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
        CGFloat stopTime = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
        
        if ((currentTime > startTime)&&(currentTime < stopTime))
        {
            if (i != mnPlaybackCount)
            {
                mnPlaybackCount = i;
                self.mediaPlayerLayer.player.rate = sliderView.motionValue;
            }
            
            break;
        }
    }
}

- (void) mediaPlayDidFinish:(NSNotification*)notification
{
    [playbackTimer invalidate];
    playbackTimer = nil;

    [self.mediaPlayerLayer.player pause];
    [self.mediaPlayerLayer.player seekToTime:CMTimeMake(self.startTime * self.mediaAsset.duration.timescale, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    [self.seekSlider setValue:self.startTime];

    isPlaying = NO;
    
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        
        self.circleProgressBar.alpha = 1.0f;

    }];
}

- (void) mediaDidFinish
{
    [playbackTimer invalidate];
    playbackTimer = nil;

    [self.mediaPlayerLayer.player pause];
    [self.mediaPlayerLayer.player seekToTime:CMTimeMake(self.startTime * self.mediaAsset.duration.timescale, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    [self.seekSlider setValue:self.startTime];

    isPlaying = NO;
    
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        
        self.circleProgressBar.alpha = 1.0f;

    }];
}

-(void) playerSeekPositionChanged
{
    if (isPlaying)
    {
        [self.mediaPlayerLayer.player pause];
        
        isPlaying = NO;
        
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            
            self.circleProgressBar.alpha = 1.0f;

        }];
    }
    
    float time = self.seekSlider.value;
    [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(time, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


#pragma mark -
#pragma mark - action Apply button

- (void)actionApplyButton:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Apply Speed", nil)
                            image:nil
                           target:self
                           action:@selector(applySpeedSegment:)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Cancel", nil)
                            image:nil
                           target:self
                           action:@selector(cancelSpeedSegment:)],
      ];
    
    CGRect frame = [self.applyButton convertRect:self.applyButton.bounds toView:self];
    [YJLActionMenu showMenuInView:self
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}


#pragma mark - 
#pragma mark - Apply / Cancel Motion

-(void) applySpeedSegment:(id) sender
{
    [playbackTimer invalidate];
    playbackTimer = nil;
    
    [self.mediaPlayerLayer.player pause];
    self.mediaPlayerLayer.player = nil;
    
    if (self.mediaPlayerLayer != nil)
    {
        [self.mediaPlayerLayer removeFromSuperlayer];
        self.mediaPlayerLayer = nil;
    }
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        
        self.circleProgressBar.alpha = 1.0f;

    }];

    if (self.startTimeArray)
    {
        [self.startTimeArray removeAllObjects];
        [self.stopTimeArray removeAllObjects];
        [self.motionValueArray removeAllObjects];
        
        self.startTimeArray = nil;
        self.stopTimeArray = nil;
        self.motionValueArray = nil;
    }
    
    self.startTimeArray = [[NSMutableArray alloc] init];
    self.stopTimeArray = [[NSMutableArray alloc] init];
    self.motionValueArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.mediaRangeSlider.videoRangeSliderArray.count; i++)
    {
        SASliderView* sliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i];

        CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
        CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
        CGFloat motion = sliderView.motionValue;
        
        if (i == 0)
        {
            if (startPos != 0)
            {
                NSNumber* startTimeValue = [NSNumber numberWithFloat:0.0f];
                [self.startTimeArray addObject:startTimeValue];
                
                NSNumber* stopTimeValue = [NSNumber numberWithFloat:startPos];
                [self.stopTimeArray addObject:stopTimeValue];
                
                NSNumber* motionValue = [NSNumber numberWithFloat:1.0f];
                [self.motionValueArray addObject:motionValue];
            }
            
            NSNumber* startTimeValue = [NSNumber numberWithFloat:startPos];
            [self.startTimeArray addObject:startTimeValue];
            
            NSNumber* stopTimeValue = [NSNumber numberWithFloat:stopPos];
            [self.stopTimeArray addObject:stopTimeValue];
            
            NSNumber* motionValue = [NSNumber numberWithFloat:motion];
            [self.motionValueArray addObject:motionValue];
            
            CGFloat endTime = CMTimeGetSeconds(self.mediaAsset.duration);
            if (self.mediaRangeSlider.videoRangeSliderArray.count >= 2) {
                SASliderView* sliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i + 1];
                endTime = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
            }
            if (stopPos != endTime && self.mediaRangeSlider.videoRangeSliderArray.count == 1) {
                NSNumber* startTimeValue = [NSNumber numberWithFloat:stopPos];
                [self.startTimeArray addObject:startTimeValue];
                
                NSNumber* stopTimeValue = [NSNumber numberWithFloat:endTime];
                [self.stopTimeArray addObject:stopTimeValue];
                
                NSNumber* motionValue = [NSNumber numberWithFloat:1.0f];
                [self.motionValueArray addObject:motionValue];
            }
        }
        else if (i == (self.mediaRangeSlider.videoRangeSliderArray.count - 1))
        {
            SASliderView *prevSliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i - 1];
            
            CGFloat prevStopPos = (prevSliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
            
            if ((int)prevStopPos != (int)startPos)
            {
                NSNumber* startTimeValue = [NSNumber numberWithFloat:prevStopPos];
                [self.startTimeArray addObject:startTimeValue];
                
                NSNumber* stopTimeValue = [NSNumber numberWithFloat:startPos];
                [self.stopTimeArray addObject:stopTimeValue];
                
                NSNumber* motionValue = [NSNumber numberWithFloat:1.0f];
                [self.motionValueArray addObject:motionValue];
            }

            NSNumber* startTimeValue = [NSNumber numberWithFloat:startPos];
            [self.startTimeArray addObject:startTimeValue];
            
            NSNumber* stopTimeValue = [NSNumber numberWithFloat:stopPos];
            [self.stopTimeArray addObject:stopTimeValue];
            
            NSNumber* motionValue = [NSNumber numberWithFloat:motion];
            [self.motionValueArray addObject:motionValue];

            if ((int)stopPos != (int)CMTimeGetSeconds(self.mediaAsset.duration))
            {
                NSNumber* startTimeValue = [NSNumber numberWithFloat:stopPos];
                [self.startTimeArray addObject:startTimeValue];
                
                NSNumber* stopTimeValue = [NSNumber numberWithFloat:CMTimeGetSeconds(self.mediaAsset.duration)];
                [self.stopTimeArray addObject:stopTimeValue];
                
                NSNumber* motionValue = [NSNumber numberWithFloat:1.0f];
                [self.motionValueArray addObject:motionValue];
            }
        }
        else
        {
            SASliderView *prevSliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i - 1];
            
            CGFloat prevStopPos = (prevSliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
            
            if ((int)prevStopPos != (int)startPos)
            {
                NSNumber* startTimeValue = [NSNumber numberWithFloat:prevStopPos];
                [self.startTimeArray addObject:startTimeValue];
                
                NSNumber* stopTimeValue = [NSNumber numberWithFloat:startPos];
                [self.stopTimeArray addObject:stopTimeValue];
                
                NSNumber* motionValue = [NSNumber numberWithFloat:1.0f];
                [self.motionValueArray addObject:motionValue];
            }

            NSNumber* startTimeValue = [NSNumber numberWithFloat:startPos];
            [self.startTimeArray addObject:startTimeValue];
            
            NSNumber* stopTimeValue = [NSNumber numberWithFloat:stopPos];
            [self.stopTimeArray addObject:stopTimeValue];
            
            NSNumber* motionValue = [NSNumber numberWithFloat:motion];
            [self.motionValueArray addObject:motionValue];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectedMotion:starts:ends:)])
    {
        [self.delegate didSelectedMotion:self.motionValueArray starts:self.startTimeArray ends:self.stopTimeArray];
    }
}

-(void) cancelSpeedSegment:(id) sender
{
    [playbackTimer invalidate];
    playbackTimer = nil;
    
    [self.mediaPlayerLayer.player pause];
    self.mediaPlayerLayer.player = nil;
    
    if (self.mediaPlayerLayer != nil)
    {
        [self.mediaPlayerLayer removeFromSuperlayer];
        self.mediaPlayerLayer = nil;
    }
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        
        self.circleProgressBar.alpha = 1.0f;

    }];
    
    if ([self.delegate respondsToSelector:@selector(didCancelSpeed)])
    {
        [self.delegate didCancelSpeed];
    }
}


#pragma mark -
#pragma mark - SAVideoRangeSliderDelegate

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition LCR:(int)leftCenterRight value:(CGFloat)motionValue
{
    [playbackTimer invalidate];
    playbackTimer = nil;

    self.motionValueOfSelectedSegment = motionValue;

    if (isPlaying)
    {
        [self.mediaPlayerLayer.player pause];
        
        isPlaying = NO;
        
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            
            self.circleProgressBar.alpha = 1.0f;

        }];
    }
    
    self.startTime = leftPosition;
    self.stopTime = rightPosition;

    NSString* timeString = [self timeToString:(self.stopTime - self.startTime)/self.motionValueOfSelectedSegment];
    self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeString];

    [self.seekSlider setMinimumValue:self.startTime];
    [self.seekSlider setMaximumValue:self.stopTime];

    if (leftCenterRight == 1)//LEFT
    {
        [self.seekSlider setValue:self.startTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else if (leftCenterRight == 2)//CENTER
    {
        [self.seekSlider setValue:self.startTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else if (leftCenterRight == 3)//RIGHT
    {
        [self.seekSlider setValue:self.stopTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }

    [self.mediaRangeSlider updateSelectedRangeBubble];
    
    
    SASliderView* mySASliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:self.mediaRangeSlider.nSelectedSliderIndex];

    CGFloat fStartPos = mySASliderView.leftPos;
    CGFloat fEndPos = mySASliderView.rightPos;
    
    self.myMarkerView.frame = CGRectMake(self.mediaRangeSlider.frame.origin.x + fStartPos + 1.0f, self.myMarkerView.frame.origin.y, (fEndPos-fStartPos) - 2.0f, self.myMarkerView.frame.size.height);
    [self.myMarkerView setNeedsDisplay];

    [self.circleProgressBar setProgress:self.motionValueOfSelectedSegment timeString:timeString];
}

-(void) fetchSASliderViews
{
    if (self.mediaRangeSlider.videoRangeSliderArray.count == 1)
    {
        self.deleteSegmentButton.hidden = YES;
    }
}


#pragma mark -
#pragma mark FDWaveformViewDelegate

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    [UIView animateWithDuration:0.02f animations:^{
        waveformView.alpha = 1.0f;
    }];
}


#pragma mark -
#pragma mark - Add new Segment

-(void) actionAddNewSegment:(id) sender
{
    BOOL isAddedNewSegment = NO;
    
    isAddedNewSegment = [self.mediaRangeSlider addNewVideoRangeSlider];
    
    [self bringSubviewToFront:self.mediaRangeSlider];
    
    if (isAddedNewSegment)
    {
        self.deleteSegmentButton.hidden = NO;
    }
    else if (self.mediaRangeSlider.videoRangeSliderArray.count > 1)
    {
        self.deleteSegmentButton.hidden = NO;
    }
}


-(void) deleteSegment:(id) sender
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"Delete this segment?", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
        if (self.mediaRangeSlider.videoRangeSliderArray.count > 1)
        {
            [self.mediaRangeSlider deleteVideoRangeSlider:self.mediaRangeSlider.nSelectedSliderIndex];
        }
        
        if (self.mediaRangeSlider.videoRangeSliderArray.count == 1)
        {
            self.deleteSegmentButton.hidden = YES;
        }

    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        
        // Ok action example
        
    }];

    [alertController addAction:okAction];
    [alertController addAction:cancelAction];

    [[SceneDelegate sharedDelegate].navigationController.visibleViewController presentViewController:alertController animated:YES completion:nil];
}


#pragma mark -
#pragma mark - pan gesture

-(void)panRecognized:(UIPanGestureRecognizer*)sender
{
    if (self.circleProgressBar)
    {
        [self.circleProgressBar panGestureRecognized:sender];
    }
}


#pragma mark -
#pragma mark - CircleProgressBarDelegate

- (void) didSelectedCircleProgressBar:(NSInteger) index
{
    [self.mediaRangeSlider didSelectedSASliderView:index];
}

- (void) didChangedProgress:(CGFloat) progress
{
    self.motionValueOfSelectedSegment = progress;

    NSString* timeString = [self timeToString:(self.stopTime - self.startTime) / self.motionValueOfSelectedSegment];
    self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeString];

    [self.mediaRangeSlider setChangedMotionValue:self.motionValueOfSelectedSegment];

    if (isPlaying)
    {
        [playbackTimer invalidate];
        playbackTimer = nil;

        isPlaying = NO;
        
        [self.mediaPlayerLayer.player pause];
        
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            
            self.circleProgressBar.alpha = 1.0f;
            
        }];
    }

    [self.circleProgressBar setProgress:self.motionValueOfSelectedSegment timeString:timeString];
}

@end
