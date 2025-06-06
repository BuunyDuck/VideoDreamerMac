//
//  JogEditView.m
//  VideoFrame
//
//  Created by Yinjing Li on 11/19/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "JogEditView.h"
#import "NSDate+Extension.h"
#import "SceneDelegate.h"

@import Photos;

#define CIRCLE_PICKER_VISIT_TIME 0.2f

@implementation JogEditView


- (id)initWithFrame:(CGRect)frame url:(NSURL*) meidaUrl superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        
        isExporting = NO;
        isPlaying = NO;
        mnSaveCopyFlag = NO;
        mnPlayState = PLAY_READY;
        mnRepeatCount = 1;
        mnCurrentCount = 1;

        self.originalMediaUrl = meidaUrl;
        self.mediaAsset = [AVURLAsset assetWithURL:self.originalMediaUrl];
        self.originalVideoDuration = CMTimeGetSeconds(self.mediaAsset.duration);
        self.motionValueOfJog = 0.5f;
        
        if (self.originalVideoDuration >= 4.0f)
        {
            if (self.originalVideoDuration > 60.0f)
            {
                self.jogStartTime = 10.0f;
                self.jogStopTime = 20.0f;
            }
            else
            {
                self.jogStartTime = 2.0f;
                self.jogStopTime = 4.0f;
            }
        }
        else
        {
            self.jogStartTime = self.originalVideoDuration / 3.0f;
            self.jogStopTime = self.originalVideoDuration * 2.0f / 3.0f;
        }

        UIEdgeInsets safeAreaInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        if (superView != nil) {
            safeAreaInsets = superView.safeAreaInsets;
        }
        
        UIImage *minImage = [UIImage imageNamed:@"slider_min"];
        minImage = [minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];

        UIImage *maxImage = [UIImage imageNamed:@"slider_max"];
        maxImage = [maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
        
        UIImage *tumbImage = nil;

        CGFloat myFontSize = 0.0f;
        CGRect currentTimeLabelFrame = CGRectZero;
        CGRect totalTimeLabelFrame = CGRectZero;
        CGRect seekSliderFrame = CGRectZero;
        CGRect mediaRangeSliderFrame = CGRectZero;
        CGRect playButtonFrame = CGRectZero;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            myFontSize = 11.0f;
            tumbImage= [UIImage imageNamed:@"slider_thumb"];
            
            currentTimeLabelFrame = CGRectMake(2.0f + safeAreaInsets.left, self.frame.size.height - 65.0f - safeAreaInsets.bottom, 50.0f, 30.0f);
            totalTimeLabelFrame = CGRectMake(self.frame.size.width - 52.0f - safeAreaInsets.right, self.frame.size.height - 65.0f - safeAreaInsets.bottom, 50.0f, 30.0f);
            seekSliderFrame = CGRectMake(52.0f + safeAreaInsets.left, self.frame.size.height - 65.0f - safeAreaInsets.bottom, self.frame.size.width - 104.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f);
            mediaRangeSliderFrame = CGRectMake(52.0f + safeAreaInsets.left, self.frame.size.height - 35.0f - safeAreaInsets.bottom, self.frame.size.width - 104.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f);
            playButtonFrame = CGRectMake(self.frame.size.width - 40.0f - safeAreaInsets.right, self.frame.size.height - 35.0f - safeAreaInsets.bottom, 30.0f, 30.0f);
        }
        else
        {
            myFontSize = 14.0f;
            tumbImage= [UIImage imageNamed:@"slider_thumb_ipad"];
            
            currentTimeLabelFrame = CGRectMake(2.0f + safeAreaInsets.left, self.frame.size.height - 100.0f - safeAreaInsets.bottom, 50.0f, 30.0f);
            totalTimeLabelFrame = CGRectMake(self.frame.size.width - 62.0f - safeAreaInsets.right, self.frame.size.height - 100.0f - safeAreaInsets.right, 50.0f, 30.0f);
            seekSliderFrame = CGRectMake(55.0f + safeAreaInsets.left, self.frame.size.height - 100.0f - safeAreaInsets.left - safeAreaInsets.right, self.frame.size.width - 118.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f);
            mediaRangeSliderFrame = CGRectMake(55.0f + safeAreaInsets.left, self.frame.size.height - 60.0f - safeAreaInsets.bottom, self.frame.size.width - 118.0f - safeAreaInsets.left - safeAreaInsets.right, 50);
            playButtonFrame = CGRectMake(self.frame.size.width - 60.0 - safeAreaInsets.right, self.frame.size.height - 60.0f - safeAreaInsets.bottom, 50, 50);
        }
        
        //seek slider
        self.seekSlider = [[UISlider alloc] initWithFrame:seekSliderFrame];
        [self.seekSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [self.seekSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [self.seekSlider setThumbImage:tumbImage forState:UIControlStateNormal];
        [self.seekSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
        [self.seekSlider setBackgroundColor:[UIColor clearColor]];
        [self.seekSlider addTarget:self action:@selector(playerSeekPositionChanged) forControlEvents:UIControlEventValueChanged];
        [self.seekSlider setMinimumValue:0.0f];
        [self.seekSlider setMaximumValue:self.originalVideoDuration];
        [self.seekSlider setValue:0.0f];
        [self addSubview:self.seekSlider];
        
        //current tile label
        self.currentTimeLabel = [[UILabel alloc] initWithFrame:currentTimeLabelFrame];
        [self.currentTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:myFontSize]];
        [self.currentTimeLabel setBackgroundColor:[UIColor clearColor]];
        [self.currentTimeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.currentTimeLabel setAdjustsFontSizeToFitWidth:YES];
        [self.currentTimeLabel setMinimumScaleFactor:0.1f];
        [self.currentTimeLabel setNumberOfLines:1];
        [self.currentTimeLabel setTextColor:[UIColor yellowColor]];
        [self.currentTimeLabel setText:@"00:00.000"];
        [self addSubview:self.currentTimeLabel];
        
        //total time label
        self.totalTimeLabel = [[UILabel alloc] initWithFrame:totalTimeLabelFrame];
        [self.totalTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:myFontSize]];
        [self.totalTimeLabel setBackgroundColor:[UIColor clearColor]];
        [self.totalTimeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.totalTimeLabel setAdjustsFontSizeToFitWidth:YES];
        [self.totalTimeLabel setMinimumScaleFactor:0.1f];
        [self.totalTimeLabel setNumberOfLines:1];
        [self.totalTimeLabel setTextColor:[UIColor yellowColor]];
        NSString* timeString = [self timeToString:self.originalVideoDuration];
        self.totalTimeLabel.text = [NSString stringWithFormat:@"%@", timeString];
        [self addSubview:self.totalTimeLabel];

        //video range slider
        self.mediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:mediaRangeSliderFrame videoUrl:self.originalMediaUrl value:1.0f];
        self.mediaRangeSlider.delegate = self;
        self.mediaRangeSlider.clipsToBounds = YES;
        [self addSubview:self.mediaRangeSlider];
        
        
        CGFloat thumbWidth = mediaRangeSliderFrame.size.width*0.05f;
        CGFloat leftPos = self.jogStartTime * mediaRangeSliderFrame.size.width / self.mediaRangeSlider.durationSeconds;
        CGFloat rightPos = self.jogStopTime * mediaRangeSliderFrame.size.width / self.mediaRangeSlider.durationSeconds;

        if ((rightPos - leftPos) < thumbWidth*2.0f)
            self.jogStopTime = thumbWidth*2.0f / (mediaRangeSliderFrame.size.width / self.mediaRangeSlider.durationSeconds) + self.jogStartTime;
        
        [self.mediaRangeSlider setLeftRight:self.jogStartTime end:self.jogStopTime];
        
        
        //play button
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setFrame:playButtonFrame];
        [self.playButton setCenter:CGPointMake(self.playButton.center.x, self.mediaRangeSlider.center.y)];
        [self.playButton setBackgroundColor:[UIColor clearColor]];
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.playButton addTarget:self action:@selector(playbackMotionMovie:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        
        // apply button
        self.applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.applyButton setFrame:CGRectMake(10.0f + safeAreaInsets.left, 5.0f + safeAreaInsets.top, 50.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:15]];
        else
            [self.applyButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:20]];
        [self.applyButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        self.applyButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.applyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.applyButton setBackgroundColor:UIColorFromRGB(0x53585f)];
        [self setSelectedBackgroundViewFor:self.applyButton];
        self.applyButton.layer.masksToBounds = YES;
        self.applyButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.applyButton.layer.borderWidth = 1.0f;
        self.applyButton.layer.cornerRadius = 3.0f;
        [self.applyButton setTitle:NSLocalizedString(@" Apply ", nil) forState:UIControlStateNormal];
        [self.applyButton addTarget:self action:@selector(actionApplyButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.applyButton];
        
        CGFloat labelWidth = [self.applyButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyButton.titleLabel.font}].width;
        CGFloat labelHeight = [self.applyButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyButton.titleLabel.font}].height;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyButton setFrame:CGRectMake(5.0f + safeAreaInsets.left, 5.0f + safeAreaInsets.top, labelWidth + 10.0f, labelHeight + 15.0f)];
        else
            [self.applyButton setFrame:CGRectMake(20.0f + safeAreaInsets.left, 20.0f + safeAreaInsets.top, labelWidth + 20.0f, labelHeight + 20.0f)];
        
        
        /* Save Checkbox Button */
        self.saveCheckBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.saveCheckBoxButton setFrame:CGRectMake(labelWidth + 20.0f + safeAreaInsets.left, 7.5f + safeAreaInsets.top, labelHeight + 10.0f, labelHeight + 10.0f)];
        else
            [self.saveCheckBoxButton setFrame:CGRectMake(labelWidth + 50.0f + safeAreaInsets.left, 25.0f + safeAreaInsets.top, labelHeight + 10.0f, labelHeight + 10.0f)];
        [self.saveCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
        [self.saveCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
        [self.saveCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
        [self.saveCheckBoxButton addTarget:self action:@selector(onSaveCheckBox) forControlEvents:UIControlEventTouchUpInside];
        [self.saveCheckBoxButton setSelected:mnSaveCopyFlag];
        [self addSubview:self.saveCheckBoxButton];
        self.saveCheckBoxButton.center = CGPointMake(self.saveCheckBoxButton.center.x, self.applyButton.center.y);

        
        /* Save Checkbox Label */
        UILabel* checkLabel;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxButton.frame.origin.x + self.saveCheckBoxButton.frame.size.width, self.saveCheckBoxButton.frame.origin.y, 50.0f, self.saveCheckBoxButton.frame.size.height)];
            checkLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        }
        else
        {
            checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxButton.frame.origin.x + self.saveCheckBoxButton.frame.size.width, self.saveCheckBoxButton.frame.origin.y, 70.0f, self.saveCheckBoxButton.frame.size.height)];
            checkLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
        }
        checkLabel.backgroundColor = [UIColor clearColor];
        checkLabel.textAlignment = NSTextAlignmentCenter;
        checkLabel.adjustsFontSizeToFitWidth = YES;
        checkLabel.minimumScaleFactor = 0.1f;
        checkLabel.numberOfLines = 0;
        checkLabel.textColor = [UIColor lightGrayColor];
        checkLabel.text = NSLocalizedString(@"Save to Photo Roll", nil);
        [self addSubview:checkLabel];

        
        // title label
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            if (self.frame.size.width > self.frame.size.height) //landscape
            {
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, 5.0f + safeAreaInsets.top, self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:21];
            }
            else
            {
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, self.applyButton.frame.origin.y + self.applyButton.frame.size.height + 2.0f, self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:18];
            }
        }
        else
        {
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, self.applyButton.center.y - 15.0f, self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
            self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:25];
        }
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self.titleLabel setMinimumScaleFactor:0.1f];
        [self.titleLabel setNumberOfLines:1];
        [self.titleLabel setShadowColor:[UIColor blackColor]];
        [self.titleLabel setShadowOffset:CGSizeMake(1.0f, 1.0f)];
        self.titleLabel.layer.shadowOpacity = 0.8f;
        self.titleLabel.text = NSLocalizedString(@"Slow Speed Jog", nil);
        [self addSubview:self.titleLabel];
        

        //jog repeat count button
        UILabel* repeatCountLabel = nil;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            repeatCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 120.0f - safeAreaInsets.right, 5.0f + safeAreaInsets.top, 80.0f, 30.0f)];
            repeatCountLabel.font = [UIFont fontWithName:MYRIADPRO size:12];
        }
        else
        {
            repeatCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 145.0f - safeAreaInsets.right, 20.0f + safeAreaInsets.top, 90.0f, 30.0f)];
            repeatCountLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
        }
        
        repeatCountLabel.backgroundColor = [UIColor clearColor];
        repeatCountLabel.textAlignment = NSTextAlignmentRight;
        repeatCountLabel.adjustsFontSizeToFitWidth = YES;
        repeatCountLabel.minimumScaleFactor = 0.1f;
        repeatCountLabel.numberOfLines = 0;
        repeatCountLabel.textColor = [UIColor lightGrayColor];
        repeatCountLabel.text = NSLocalizedString(@"Repeat Jog:", nil);
        [self addSubview:repeatCountLabel];
        repeatCountLabel.center = CGPointMake(repeatCountLabel.center.x, self.applyButton.center.y);

        
        self.repeatCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
       
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self.repeatCountButton setFrame:CGRectMake(self.frame.size.width - self.saveCheckBoxButton.bounds.size.width - 5.0f - safeAreaInsets.right, self.saveCheckBoxButton.frame.origin.y, self.saveCheckBoxButton.bounds.size.width, self.saveCheckBoxButton.bounds.size.height)];
            [self.repeatCountButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:12]];
        }
        else
        {
            [self.repeatCountButton setFrame:CGRectMake(self.frame.size.width - self.saveCheckBoxButton.bounds.size.width - 10.0f - safeAreaInsets.right, self.saveCheckBoxButton.frame.origin.y, self.saveCheckBoxButton.bounds.size.width, self.saveCheckBoxButton.bounds.size.height)];
            [self.repeatCountButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:20]];
        }
        
        [self.repeatCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.repeatCountButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.repeatCountButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.repeatCountButton setBackgroundColor:[UIColor clearColor]];
        self.repeatCountButton.layer.masksToBounds = YES;
        self.repeatCountButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.repeatCountButton.layer.borderWidth = 1.0f;
        self.repeatCountButton.layer.cornerRadius = 3.0f;
        [self.repeatCountButton setTitle:@"1x" forState:UIControlStateNormal];
        [self.repeatCountButton addTarget:self action:@selector(actionJogRepeatCount:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.repeatCountButton];
        
        
        // media player
        self.mediaPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.mediaAsset]]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [_mediaPlayerLayer setFrame:CGRectMake(5.0f + safeAreaInsets.left, self.applyButton.frame.origin.y + self.applyButton.frame.size.height + 5.0f + safeAreaInsets.top, self.frame.size.width - 10.0f - safeAreaInsets.left - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y - (self.applyButton.frame.origin.y + self.applyButton.frame.size.height) - 10.0f - safeAreaInsets.top - safeAreaInsets.bottom)];
        else
            [_mediaPlayerLayer setFrame:CGRectMake(10.0f + safeAreaInsets.left, self.applyButton.frame.origin.y + self.applyButton.frame.size.height + 10.0f + safeAreaInsets.top, self.frame.size.width - 20.0f - safeAreaInsets.left - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y - (self.applyButton.frame.origin.y+self.applyButton.frame.size.height) - 20.0f - safeAreaInsets.top - safeAreaInsets.bottom)];
        
        [self.layer insertSublayer:_mediaPlayerLayer atIndex:0];
        
        [_mediaPlayerLayer.player setVolume:1.0f];
        [_mediaPlayerLayer.player seekToTime:kCMTimeZero];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaPlayDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        
        CGFloat duration = self.mediaAsset.duration.value / 500.0f;
        
        __weak typeof(self) weakSelf = self;
        
        [self.mediaPlayerLayer.player addPeriodicTimeObserverForInterval:CMTimeMake(MAX(1, duration), self.mediaAsset.duration.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            __strong JogEditView *sself = weakSelf;
            
            if (!sself)
                return;
            
            if ([self.mediaPlayerLayer.player rate] != 0.0f)
            {
                CGFloat currentTime = CMTimeGetSeconds(time);

                if (currentTime > self.originalVideoDuration)
                {
                    currentTime = self.originalVideoDuration;
                    [sself performSelector:@selector(mediaDidFinish)];
                }
            
                weakSelf.seekSlider.value = currentTime;
                
                NSString* timeString = [weakSelf timeToString:currentTime];
                weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"%@", timeString];
            }
        }];
        

        // motion circle bar
        CGFloat rWidth = self.mediaPlayerLayer.bounds.size.width >= self.mediaPlayerLayer.bounds.size.height ? self.mediaPlayerLayer.bounds.size.height * 0.72f : self.mediaPlayerLayer.bounds.size.width * 0.72f;
        
        self.motionProgressBar = [[CircleProgressBar alloc] initWithFrame:CGRectMake((self.bounds.size.width - rWidth) / 2.0f, (self.bounds.size.height - rWidth) / 2.0f, rWidth, rWidth)];
        self.motionProgressBar.delegate = self;
        [self.motionProgressBar setProgressBarWidth:(self.motionProgressBar.bounds.size.width * 0.1f)];
        [self.motionProgressBar setHintViewSpacingForDrawing:(self.motionProgressBar.bounds.size.width * 0.27f)];
        [self addSubview:self.motionProgressBar];
        
        CGFloat totalTime = [self getOutputVideoDuration];
        timeString = [self timeToString:totalTime];
        [self.motionProgressBar setProgress:self.motionValueOfJog timeString:timeString];
        
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
        [self addGestureRecognizer:panRecognizer];
        
        [self.seekSlider setValue:0.0f];
        [self.mediaPlayerLayer.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        
        
        self.hudProgressView = [[ATMHud alloc] initWithDelegate:self];
        self.hudProgressView.delegate = self;
        [self addSubview:self.hudProgressView.view];
        self.hudProgressView.view.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    }

    return self;
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

-(CGFloat) getOutputVideoDuration
{
    CGFloat totalTime = self.originalVideoDuration + mnRepeatCount*2.0f*(self.jogStopTime - self.jogStartTime)/self.motionValueOfJog;
    return totalTime;
}


#pragma mark -
#pragma mark - Playback

- (void) playbackMotionMovie:(id) sender
{
    if (isExporting)
    {
        return;
    }
    
    if (isPlaying)
    {
        [playbackTimer invalidate];
        playbackTimer = nil;

        isPlaying = NO;
        [self.mediaPlayerLayer.player pause];
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];

        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            self.motionProgressBar.alpha = 1.0f;
        }];
    }
    else
    {
        isPlaying = YES;
        
        if (playbackTimer)
        {
            [playbackTimer invalidate];
            playbackTimer = nil;
        }
        
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:.02f target:self selector:@selector(playbackTimeUpdate:) userInfo:nil repeats:YES];
        
        [self.mediaPlayerLayer.player play];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
        else
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            self.motionProgressBar.alpha = 0.0f;
        }];
    }
}

- (void)playbackTimeUpdate:(NSTimer*)timer
{
    CGFloat currentTime = CMTimeGetSeconds(self.mediaPlayerLayer.player.currentTime);
    
    if (mnPlayState == PLAY_READY)
    {
        if (currentTime < self.jogStartTime)
        {
            mnPlayState = PLAY_NORMAL;
            self.mediaPlayerLayer.player.rate = 1.0f;
        }
        else
        {
            mnPlayState = PLAY_MOTION;
            self.mediaPlayerLayer.player.rate = self.motionValueOfJog;
        }
    }
    else if (mnPlayState == PLAY_NORMAL)
    {
        if (currentTime >= self.jogStartTime)
        {
            mnPlayState = PLAY_MOTION;
            self.mediaPlayerLayer.player.rate = self.motionValueOfJog;
        }
    }
    else if (mnPlayState == PLAY_MOTION)
    {
        if (currentTime >= self.jogStopTime)
        {
            mnPlayState = PLAY_REVERSE;
            self.mediaPlayerLayer.player.rate = -1.0f * self.motionValueOfJog;
        }
    }
    else if (mnPlayState == PLAY_REVERSE)
    {
        if (currentTime <= self.jogStartTime)
        {
            if (mnCurrentCount >= mnRepeatCount)
            {
                mnPlayState = PLAY_REPLAY;
                self.mediaPlayerLayer.player.rate = 1.0f;
                mnCurrentCount = 1;
            }
            else
            {
                mnPlayState = PLAY_MOTION;
                self.mediaPlayerLayer.player.rate = self.motionValueOfJog;
                mnCurrentCount++;
            }
        }
    }
}

- (void) mediaPlayDidFinish:(NSNotification*)notification
{
    CGFloat currentTime = CMTimeGetSeconds(self.mediaPlayerLayer.player.currentTime);

    if ((mnPlayState == PLAY_REVERSE) || (currentTime < 0.0f))
    {
        if (currentTime <= self.jogStartTime)
        {
            if (mnCurrentCount >= mnRepeatCount)
            {
                mnPlayState = PLAY_REPLAY;
                self.mediaPlayerLayer.player.rate = 1.0f;
                mnCurrentCount = 1;
                //[self.mediaPlayerLayer.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                [self.currentTimeLabel setText:@"00:00.000"];
            }
            else
            {
                mnPlayState = PLAY_MOTION;
                self.mediaPlayerLayer.player.rate = self.motionValueOfJog;
                mnCurrentCount++;
            }
        }
        
        [self.mediaPlayerLayer.player play];
        
        //if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        //    [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
        //} else {
        //    [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
        //}
    }
    else
    {
        [playbackTimer invalidate];
        playbackTimer = nil;
     
        mnPlayState = PLAY_READY;
        [self.currentTimeLabel setText:@"00:00.000"];
        mnCurrentCount = 1;
        isPlaying = NO;
        
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.mediaPlayerLayer.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

        [self.seekSlider setValue:0.0f];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            self.motionProgressBar.alpha = 1.0f;
        }];
    }
}

- (void) mediaDidFinish
{
    [playbackTimer invalidate];
    playbackTimer = nil;

    [self.mediaPlayerLayer.player pause];
    [self.mediaPlayerLayer.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

    mnPlayState = PLAY_READY;
    mnCurrentCount = 1;
    isPlaying = NO;
    
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];

    [self.seekSlider setValue:0.0f];
    [self.currentTimeLabel setText:@"00:00.000"];

    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        self.motionProgressBar.alpha = 1.0f;
    }];
}

-(void) playerSeekPositionChanged
{
    if (isPlaying)
    {
        [playbackTimer invalidate];
        playbackTimer = nil;

        [self.mediaPlayerLayer.player pause];
        isPlaying = NO;
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            self.motionProgressBar.alpha = 1.0f;
        }];
    }
    
    float time = self.seekSlider.value;
    [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(time, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    NSString* timeString = [self timeToString:time];
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%@", timeString];
}


#pragma mark -
#pragma mark - SAVideoRangeSliderDelegate

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition LCR:(int)leftCenterRight value:(CGFloat)motionValue
{
    [playbackTimer invalidate];
    playbackTimer = nil;

    if (isPlaying)
    {
        [self.mediaPlayerLayer.player pause];
        isPlaying = NO;
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            self.motionProgressBar.alpha = 1.0f;
        }];
        
        mnPlayState = PLAY_READY;
        mnCurrentCount = 1;
    }
    
    self.jogStartTime = leftPosition;
    self.jogStopTime = rightPosition;
    
    [self.mediaRangeSlider updateSelectedRangeBubble];
    
    CGFloat totalTime = [self getOutputVideoDuration];
    NSString* timeString = [self timeToString:totalTime];
    [self.motionProgressBar setProgress:self.motionValueOfJog timeString:timeString];
    
    if (leftCenterRight == 1)//LEFT
    {
        [self.seekSlider setValue:self.jogStartTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.jogStartTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else if (leftCenterRight == 2)//CENTER
    {
        [self.seekSlider setValue:self.jogStartTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.jogStartTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else if (leftCenterRight == 3)//RIGHT
    {
        [self.seekSlider setValue:self.jogStopTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.jogStopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}


#pragma mark -
#pragma mark - pan gesture

-(void)panRecognized:(UIPanGestureRecognizer*)sender
{
    if(!self.motionProgressBar)
        return;
    
    if (isExporting)
        return;
    
    [self.motionProgressBar panGestureRecognized:sender];
}


#pragma mark -
#pragma mark - CircleProgressBarDelegate

- (void) didChangedProgress:(CGFloat) progress
{
    self.motionValueOfJog = progress;

    if (isPlaying)
    {
        [playbackTimer invalidate];
        playbackTimer = nil;

        isPlaying = NO;
        [self.mediaPlayerLayer.player pause];
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];

        [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
            self.motionProgressBar.alpha = 1.0f;
        }];
    }
    
    CGFloat totalTime = [self getOutputVideoDuration];
    NSString* timeString = [self timeToString:totalTime];
    [self.motionProgressBar setProgress:self.motionValueOfJog timeString:timeString];
    
    if (progress < 1.0f)
        self.titleLabel.text = NSLocalizedString(@"Slow Speed Jog", nil);
    else
        self.titleLabel.text = NSLocalizedString(@"Fast Speed Jog", nil);
    
    if (mnPlayState != PLAY_READY)
    {
        mnPlayState = PLAY_READY;
        mnCurrentCount = 1;
        
        [self.currentTimeLabel setText:@"00:00.000"];
        
        [self.mediaPlayerLayer.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.seekSlider setValue:0.0f];
    }
}


#pragma mark -
#pragma mark - action Apply button

- (void)actionApplyButton:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Apply Jog", nil)
                            image:nil
                           target:self
                           action:@selector(applyJog:)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Cancel", nil)
                            image:nil
                           target:self
                           action:@selector(cancelJog:)],
      ];
    
    CGRect frame = [self.applyButton convertRect:self.applyButton.bounds toView:self];
    [YJLActionMenu showMenuInView:self
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}


#pragma mark -
#pragma mark - Apply / Cancel Jog

-(void) cancelJog:(id) sender
{
    isExporting = NO;
    [playbackTimer invalidate];
    playbackTimer = nil;
    
    [_imageGenerator cancelAllCGImageGeneration];
    _imageGenerator = nil;
    
    [self.mediaPlayerLayer.player pause];
    self.mediaPlayerLayer.player = nil;
    
    if (self.mediaPlayerLayer != nil)
    {
        [self.mediaPlayerLayer removeFromSuperlayer];
        self.mediaPlayerLayer = nil;
    }
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        self.motionProgressBar.alpha = 1.0f;
    }];
    
    if ([self.delegate respondsToSelector:@selector(didCancelJogReverse)])
    {
        [self.delegate didCancelJogReverse];
    }
}

-(void) applyJog:(id) sender
{
    isExporting = YES;
    isExportCancelled = NO;
    
    self.mediaRangeSlider.userInteractionEnabled = NO;
    self.seekSlider.userInteractionEnabled = NO;
    
    [playbackTimer invalidate];
    playbackTimer = nil;
    
    [self.mediaPlayerLayer.player pause];
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:CIRCLE_PICKER_VISIT_TIME animations:^{
        self.motionProgressBar.alpha = 1.0f;
    }];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Preparing...", nil) isLock:YES];

    [self performSelector:@selector(createReverseVideo) withObject:nil afterDelay:0.02f];
}


#pragma mark -
#pragma mark - Save Copy CheckBox

-(void) onSaveCheckBox
{
    if (isExporting)
    {
        return;
    }

    if (self.saveCheckBoxButton.selected)
    {
        [self.saveCheckBoxButton setSelected:NO];
        mnSaveCopyFlag = NO;
    }
    else
    {
        [self.saveCheckBoxButton setSelected:YES];
        mnSaveCopyFlag = YES;
    }
}

- (void) saveMovieToPhotoAlbum
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^
     {
         PHFetchOptions *fetchOptions = [PHFetchOptions new];
         fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title == %@", NSLocalizedString(@"Video Dreamer", nil)];
         
         PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
         
         if (fetchResult.count == 0)//new create
         {
             //create asset
             PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.outputJogMediaUrl];
             
             //Create Album
             PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:NSLocalizedString(@"Video Dreamer", nil)];
             
             //get a placeholder for the new asset and add it to the album editing request
             PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
             
             [albumRequest addAssets:@[assetPlaceholder]];
         }
         else //add video to album
         {
             //create asset
             PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.outputJogMediaUrl];
             
             //change Album
             PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
             PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
             
             //get a placeholder for the new asset and add it to the album editing request
             PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
             
             [albumRequest addAssets:@[assetPlaceholder]];
         }
         
     } completionHandler:^(BOOL success, NSError *error) {
         
         if (error!=nil)
         {
             [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Video Saving Failed:%@", nil), [error description]] okHandler:nil];
         }
         else
         {
             NSLog(@"Jog Video Saved to Photo Roll!");
         }
     }];
}


#pragma mark -
#pragma mark - Jog Repeat Count

- (void) actionJogRepeatCount:(id) sender
{
    if (isExporting)
    {
        return;
    }

    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"1x"
                            image:nil
                           target:self
                           action:@selector(setJogRepeatCount:)
                            index:1],
      
      [YJLActionMenuItem menuItem:@"2x"
                            image:nil
                           target:self
                           action:@selector(setJogRepeatCount:)
                            index:2],
      
      [YJLActionMenuItem menuItem:@"3x"
                            image:nil
                           target:self
                           action:@selector(setJogRepeatCount:)
                            index:3],
      ];
    
    CGRect frame = [self.repeatCountButton convertRect:self.repeatCountButton.bounds toView:self];
    [YJLActionMenu showMenuInView:self
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(void) setJogRepeatCount:(id) sender
{
    YJLActionMenuItem* menu = (YJLActionMenuItem*) sender;
    mnRepeatCount = menu.index;
    [self.repeatCountButton setTitle:[NSString stringWithFormat:@"%dx", mnRepeatCount] forState:UIControlStateNormal];
    
    CGFloat totalTime = [self getOutputVideoDuration];
    NSString* timeString = [self timeToString:totalTime];
    [self.motionProgressBar setProgress:self.motionValueOfJog timeString:timeString];
}


#pragma mark -
#pragma mark - Create Video

-(void) createReverseVideo
{
    _percentageDone = 0.0f;
    _nCount = 0;
    fakeTimeElapsed = 0.0f;
    
    Float64 defaultTimePerFrame = (Float64)1.0f/grFrameRate;
    
    CMTime mediaDuration = self.mediaAsset.duration;
    CMTime jogStart = CMTimeMakeWithSeconds(self.jogStartTime, mediaDuration.timescale);
    CMTime jogDuration = CMTimeMakeWithSeconds((self.jogStopTime - self.jogStartTime), mediaDuration.timescale);
    
    if ((defaultTimePerFrame >= (self.jogStopTime - self.jogStartTime)) || (jogDuration.value == 0.0f))
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Jog video duration is little. You need to change a duration to longer using Yellow Box or Motion Control.", nil) okHandler:nil];

        isExporting = NO;
        isExportCancelled = YES;
        
        self.mediaRangeSlider.userInteractionEnabled = YES;
        self.seekSlider.userInteractionEnabled = YES;
        
        [[SHKActivityIndicator currentIndicator] hide];
        return;
    }
    
    
    NSError *error = nil;
    
    AVMutableComposition* reverseComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *videoTrack = [reverseComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSArray *videoDataSourceArray = [NSArray arrayWithArray:[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo]];
    if ([videoDataSourceArray count] == 0)
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"A video track is invalid. You need to use a valid video.", nil) okHandler:nil];
      
        isExporting = NO;
        isExportCancelled = YES;
        
        self.mediaRangeSlider.userInteractionEnabled = YES;
        self.seekSlider.userInteractionEnabled = YES;
        
        [[SHKActivityIndicator currentIndicator] hide];
        return;
    }
    
    [videoTrack insertTimeRange:CMTimeRangeMake(jogStart, jogDuration)
                        ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                         atTime:kCMTimeZero
                          error:&error];
    if (error)
        NSLog(@"Insertion error: %@", error);
    
    
    NSArray *audioDataSourceArray = [NSArray arrayWithArray: [self.mediaAsset tracksWithMediaType:AVMediaTypeAudio]];
    if ([audioDataSourceArray count] > 0)
    {
        AVMutableCompositionTrack *audioTrack = [reverseComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        error = nil;
        
        [audioTrack insertTimeRange:CMTimeRangeMake(jogStart, jogDuration)
                            ofTrack:[audioDataSourceArray objectAtIndex:0]
                             atTime:kCMTimeZero
                              error:&error];
        if(error)
            NSLog(@"Insertion error: %@", error);
    }
    
    
    AVAssetTrack *assetTrack = [[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGAffineTransform firstTransform = assetTrack.preferredTransform;
    
    if ((firstTransform.a == 0) && (firstTransform.b == 1.0) && (firstTransform.c == -1.0) && (firstTransform.d == 0))//portrait
        outputVideoSize = CGSizeMake(reverseComposition.naturalSize.height, reverseComposition.naturalSize.width);
    else if((firstTransform.a == 0) && (firstTransform.b == -1.0) && (firstTransform.c == 1.0) && (firstTransform.d == 0))//upside down
        outputVideoSize = CGSizeMake(reverseComposition.naturalSize.height, reverseComposition.naturalSize.width);
    else
        outputVideoSize = reverseComposition.naturalSize;
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02f target:self selector:@selector(progressVideoReverseUpdate:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
    [self.hudProgressView setCaption:NSLocalizedString(@"Reversing Video...", nil)];
    [self.hudProgressView setProgress:0.08];
    [self.hudProgressView show];
    [self.hudProgressView showDismissButton];
    
    
    /*
     * reverse processing
     */
    
    Float64 clipTime = (Float64)1.0f/grFrameRate;
    Float64 assetDuration = CMTimeGetSeconds(reverseComposition.duration);
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:reverseComposition];
    self.imageGenerator.maximumSize = reverseComposition.naturalSize;
    
    timesArray = [[NSMutableArray alloc] init];
    
    while (clipTime < assetDuration)
    {
        CMTime frameTime = CMTimeMakeWithSeconds(assetDuration - clipTime, 600.0f);
        NSValue *frameTimeValue = [NSValue valueWithCMTime:frameTime];
        [timesArray addObject:frameTimeValue];
        clipTime += (Float64)1.0f / grFrameRate;
    };
    
    [self startRecording];
    
    [[SHKActivityIndicator currentIndicator] hide];
    
    NSMutableArray *_timesArray = timesArray;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:timesArray
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                                  AVAssetImageGeneratorResult result, NSError *error) {
                                                  
                                                  if (result == AVAssetImageGeneratorSucceeded)
                                                  {
                                                      self.percentageDone = ((Float32)self.nCount / (Float32)[_timesArray count]);
                                                      
                                                      @autoreleasepool
                                                      {
                                                          [self writeSample:image];
                                                      }
                                                      
                                                      self.nCount++;
                                                      
                                                      if (self.nCount == [_timesArray count])
                                                          [self finishRecording];
                                                  }
                                              }];
}

-(void) writeSample: (CGImageRef)imageRef
{
    if (self.assetWriterInput.readyForMoreMediaData)
    {
        CVPixelBufferRef pixelBuffer = [self pixelBufferFromCGImage:imageRef];
        
        CFTimeInterval elapsedTime = fakeTimeElapsed;
        CMTime presentationTime =  CMTimeMake(elapsedTime * 600.0f, 600.0f);
        
        [self.assetWriterPixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:presentationTime];
        
        CVPixelBufferRelease(pixelBuffer);
        
        fakeTimeElapsed += (Float64)1.0f/grFrameRate;
    }
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CGSize size = outputVideoSize;
    
    NSDictionary *options = @{(NSString *)kCVPixelBufferCGImageCompatibilityKey: [NSNumber numberWithBool:YES],
                              (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: [NSNumber numberWithBool:YES]
    };
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess)
        NSLog(@"Failed to create pixel buffer");
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(void) startRecording
{
    NSError *movieError = nil;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
    NSString *dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"ReverseVideo-%@.mp4", dateForFilename]];
    self.tmpMediaUrl = [NSURL fileURLWithPath:videoPath];
    
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.tmpMediaUrl
                                                 fileType: AVFileTypeMPEG4
                                                    error: &movieError];
    NSDictionary *assetWriterInputSettings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
                                               AVVideoWidthKey: [NSNumber numberWithInt:outputVideoSize.width],
                                               AVVideoHeightKey: [NSNumber numberWithInt:outputVideoSize.height]
    };
    self.assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeVideo outputSettings:assetWriterInputSettings];
    self.assetWriterInput.expectsMediaDataInRealTime = YES;
    [self.assetWriter addInput:self.assetWriterInput];
    self.assetWriterPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor
                                          assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.assetWriterInput
                                          sourcePixelBufferAttributes:nil];
    [self.assetWriter startWriting];
    [_assetWriter startSessionAtSourceTime: CMTimeMake(0.0f, 600.0f)];
}

-(void) finishRecording
{
    if (isExportCancelled)
        return;
    
    if (_assetWriter.status == AVAssetWriterStatusWriting)
    {
        [_assetWriter finishWritingWithCompletionHandler:^{
            self.assetWriter = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self completedProcessReverse];
            });
            
        }];
    }
}

- (void) completedProcessReverse
{
    [timesArray removeAllObjects];
    timesArray = nil;
    
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    
    if (isExportCancelled)
        return;
    
    if (mnRepeatCount == 1)
    {
        //mix normal video + motion range + reverse video + normal video
        [self mixJogVideos];
    }
    else if (mnRepeatCount > 1)
    {
        [self createJogVideo];
    }
}

-(void) createJogVideo
{
    self.reversedMediaAsset = [AVURLAsset assetWithURL:self.tmpMediaUrl];
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    NSMutableArray* layerInstructionArray = [[NSMutableArray alloc] init];
    
    CMTime startTimeOnComposition = kCMTimeZero;
    CMTime mediaDuration = self.mediaAsset.duration;
    
    /***************************************************
     add motion video range (jogStartTime, jogStopTime)
     ***************************************************/
    
    CMTime start = CMTimeMakeWithSeconds(self.jogStartTime, mediaDuration.timescale);
    CMTime duration = CMTimeMakeWithSeconds((self.jogStopTime - self.jogStartTime), mediaDuration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    AVMutableVideoCompositionLayerInstruction *motionRangeLayerInstruction = [self addTrackToAVMutableComposition:mixComposition asset:self.mediaAsset range:range start:startTimeOnComposition scale:self.motionValueOfJog];
    [layerInstructionArray addObject:motionRangeLayerInstruction];
    startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMake(duration.value / self.motionValueOfJog, duration.timescale));
    
    
    /***************************************************
     add reverse video range (jogStartTime, jogStopTime)
     ***************************************************/
    
    start = kCMTimeZero;
    duration = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.reversedMediaAsset.duration), mediaDuration.timescale);
    range = CMTimeRangeMake(start, duration);
    
    AVMutableVideoCompositionLayerInstruction *reverseRangeLayerInstruction = [self addTrackToAVMutableComposition:mixComposition asset:self.reversedMediaAsset range:range start:startTimeOnComposition scale:self.motionValueOfJog];
    [layerInstructionArray addObject:reverseRangeLayerInstruction];
    
    AVMutableVideoCompositionInstruction *MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
    MainInstruction.backgroundColor = [UIColor clearColor].CGColor;
    MainInstruction.layerInstructions = layerInstructionArray;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = @[MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1.0f, 30.0f);
    AVAssetTrack *assetTrack = [[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize videoSize = assetTrack.naturalSize;
    MainCompositionInst.renderSize = videoSize;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
    NSString *dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
    NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"JogVideo-%@.mp4", dateForFilename]];
    self.tmpMediaUrl = [NSURL fileURLWithPath:videoPath];
    
    self.exportSession = [[AVAssetExportSession alloc]
                          initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    self.exportSession.outputURL = self.tmpMediaUrl;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.videoComposition = MainCompositionInst;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(progressMixJogVideos:) userInfo:self.exportSession repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
    [self.hudProgressView setCaption:NSLocalizedString(@"Creating Jog Video...", nil)];
    [self.hudProgressView setProgress:0.08];
    [self.hudProgressView update];
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.progressTimer invalidate];
            self.progressTimer = nil;
            
            switch ([self.exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Export failed: %@", [[self.exportSession error] localizedDescription]] okHandler:nil];

                    [self.hudProgressView hide];
                }
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Export canceled", nil) okHandler:nil];

                    [self.hudProgressView hide];
                }
                    break;
                    
                case AVAssetExportSessionStatusUnknown:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Export Unknown: %@", [self.exportSession.error localizedDescription]] okHandler:nil];

                    [self.hudProgressView hide];
                }
                    break;
                    
                case AVAssetExportSessionStatusWaiting:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Export Waiting: %@", [self.exportSession.error localizedDescription]] okHandler:nil];

                    [self.hudProgressView hide];
                }
                    break;
                    
                case AVAssetExportSessionStatusExporting:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Export Exporting: %@", [self.exportSession.error localizedDescription]] okHandler:nil];

                    [self.hudProgressView hide];
                }
                    break;
                    
                case AVAssetExportSessionStatusCompleted:// export completed
                {
                    [self mixJogVideos];
                }
                    break;
                    
                default:
                {
                    [self.hudProgressView hide];
                }
                    break;
            }
            
        });
        
    }];
}

-(void) mixJogVideos
{
    self.reversedMediaAsset = [AVURLAsset assetWithURL:self.tmpMediaUrl];
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    NSMutableArray* layerInstructionArray = [[NSMutableArray alloc] init];
    
    CMTime startTimeOnComposition = kCMTimeZero;
    CMTime mediaDuration = self.mediaAsset.duration;
    
    
    /******************************************
     add normal video range (0, jogStartTime)
     ******************************************/
    
    if (self.jogStartTime > 0.0f)
    {
        CMTime start = kCMTimeZero;
        CMTime duration = CMTimeMakeWithSeconds(self.jogStartTime, mediaDuration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        
        AVMutableVideoCompositionLayerInstruction *normalRangeLayerInstruction = [self addTrackToAVMutableComposition:mixComposition asset:self.mediaAsset range:range start:startTimeOnComposition scale:1.0f];
        [layerInstructionArray addObject:normalRangeLayerInstruction];
        startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
    }
    
    if (mnRepeatCount == 1)
    {
        /***************************************************
         add motion video range (jogStartTime, jogStopTime)
         ***************************************************/
        
        CMTime start = CMTimeMakeWithSeconds(self.jogStartTime, mediaDuration.timescale);
        CMTime duration = CMTimeMakeWithSeconds((self.jogStopTime - self.jogStartTime), mediaDuration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        
        AVMutableVideoCompositionLayerInstruction *motionRangeLayerInstruction = [self addTrackToAVMutableComposition:mixComposition asset:self.mediaAsset range:range start:startTimeOnComposition scale:self.motionValueOfJog];
        [layerInstructionArray addObject:motionRangeLayerInstruction];
        startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMake(duration.value / self.motionValueOfJog, duration.timescale));
        
        
        /***************************************************
         add reverse video range (jogStartTime, jogStopTime)
         ***************************************************/
        
        start = kCMTimeZero;
        duration = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.reversedMediaAsset.duration), mediaDuration.timescale);
        range = CMTimeRangeMake(start, duration);
        
        AVMutableVideoCompositionLayerInstruction *reverseRangeLayerInstruction = [self addTrackToAVMutableComposition:mixComposition asset:self.reversedMediaAsset range:range start:startTimeOnComposition scale:self.motionValueOfJog];
        [layerInstructionArray addObject:reverseRangeLayerInstruction];
        startTimeOnComposition = CMTimeAdd(startTimeOnComposition, CMTimeMake(duration.value / self.motionValueOfJog, duration.timescale));
    }
    else if(mnRepeatCount > 1)
    {
        for (int i = 0; i < mnRepeatCount; i++)
        {
            CMTime start = kCMTimeZero;
            CMTime duration = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.reversedMediaAsset.duration), mediaDuration.timescale);
            CMTimeRange range = CMTimeRangeMake(start, duration);
            
            AVMutableVideoCompositionLayerInstruction *reverseRangeLayerInstruction = [self addTrackToAVMutableComposition:mixComposition asset:self.reversedMediaAsset range:range start:startTimeOnComposition scale:1.0f];
            [layerInstructionArray addObject:reverseRangeLayerInstruction];
            startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
        }
    }
    
    
    /***************************************************
     add normal video range (jogStartTime, end)
     ***************************************************/
    
    CMTime start = CMTimeMakeWithSeconds(self.jogStartTime, mediaDuration.timescale);
    CMTime duration = CMTimeMakeWithSeconds((CMTimeGetSeconds(mediaDuration) - self.jogStartTime), mediaDuration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    AVMutableVideoCompositionLayerInstruction *normalRangeLayerInstruction = [self addTrackToAVMutableComposition:mixComposition asset:self.mediaAsset range:range start:startTimeOnComposition scale:1.0f];
    [layerInstructionArray addObject:normalRangeLayerInstruction];
    
    
    AVMutableVideoCompositionInstruction *MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
    MainInstruction.backgroundColor = [UIColor clearColor].CGColor;
    MainInstruction.layerInstructions = layerInstructionArray;
    
    AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
    MainCompositionInst.instructions = @[MainInstruction];
    MainCompositionInst.frameDuration = CMTimeMake(1.0f, 30.0f);
    AVAssetTrack *assetTrack = [[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize videoSize = assetTrack.naturalSize;
    MainCompositionInst.renderSize = videoSize;
    
    self.outputJogMediaUrl = [[NSDate date] tempFilePathWithProjectName:gstrCurrentProjectName categoryName:@"TrimVideo" extension:@"m4v"];
    
    self.exportSession = [[AVAssetExportSession alloc]
                          initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    self.exportSession.outputURL = self.outputJogMediaUrl;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.videoComposition = MainCompositionInst;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(progressMixJogVideos:) userInfo:self.exportSession repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
    [self.hudProgressView setCaption:NSLocalizedString(@"Importing Video...", nil)];
    [self.hudProgressView setProgress:0.08];
    [self.hudProgressView update];
    
    BOOL _mnSaveCopyFlag = mnSaveCopyFlag;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.progressTimer invalidate];
            self.progressTimer = nil;
            [self.hudProgressView hide];
            
            switch ([self.exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Export failed: %@", [self.exportSession.error localizedDescription]] okHandler:nil];
                }
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Export canceled", nil) okHandler:nil];
                }
                    break;
                    
                case AVAssetExportSessionStatusUnknown:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Export Unknown: %@", [self.exportSession.error localizedDescription]] okHandler:nil];
                }
                    break;
                    
                case AVAssetExportSessionStatusWaiting:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Export Waiting: %@", [self.exportSession.error localizedDescription]] okHandler:nil];
                }
                    break;
                    
                case AVAssetExportSessionStatusExporting:
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:@"Export Exporting: %@", [self.exportSession.error localizedDescription]] okHandler:nil];
                }
                    break;
                    
                case AVAssetExportSessionStatusCompleted: // export completed
                {
                    if (_mnSaveCopyFlag)
                        [self saveMovieToPhotoAlbum];
                    
                    if ([self.delegate respondsToSelector:@selector(didApplyJogReverse:)])
                    {
                        [self.delegate didApplyJogReverse:self.outputJogMediaUrl];
                    }
                    
                    self.mediaPlayerLayer.player = nil;
                    
                    if (self.mediaPlayerLayer != nil){
                        [self.mediaPlayerLayer removeFromSuperlayer];
                        self.mediaPlayerLayer = nil;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
        });
        
    }];
}


#pragma mark -
#pragma mark - add Track to AVMutableComposition

-(AVMutableVideoCompositionLayerInstruction*) addTrackToAVMutableComposition:(AVMutableComposition*) mixComposition asset:(AVAsset*)mediaAsset range:(CMTimeRange) timeRange start:(CMTime)startTime scale:(CGFloat)motionScale
{
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *videoDataSourceArray = [NSArray arrayWithArray: [mediaAsset tracksWithMediaType:AVMediaTypeVideo]];
    NSError *error = nil;
    
    [videoTrack insertTimeRange:timeRange
                        ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                         atTime:startTime
                          error:&error];
    if(error)
        NSLog(@"Insertion error: %@", error);
    
    [videoTrack scaleTimeRange:CMTimeRangeMake(startTime, timeRange.duration)
                    toDuration:CMTimeMake(timeRange.duration.value / motionScale, timeRange.duration.timescale)];
    
    //Audio Track
    NSArray *audioDataSourceArray = [NSArray arrayWithArray: [mediaAsset tracksWithMediaType:AVMediaTypeAudio]];
    if ([audioDataSourceArray count] > 0)
    {
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        error = nil;
        
        [audioTrack insertTimeRange:timeRange
                            ofTrack:[audioDataSourceArray objectAtIndex:0]
                             atTime:startTime
                              error:&error];
        if(error)
            NSLog(@"Insertion error: %@", error);
        
        [audioTrack scaleTimeRange:CMTimeRangeMake(startTime, timeRange.duration)
                        toDuration:CMTimeMake(timeRange.duration.value / motionScale, timeRange.duration.timescale)];
    }
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    AVAssetTrack *assetTrack = [[mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGAffineTransform transform = CGAffineTransformIdentity;
    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
    [layerInstruction setOpacity:1.0 atTime:startTime];
    CMTime layerDurationTime = CMTimeAdd(startTime, CMTimeMake(timeRange.duration.value / motionScale, timeRange.duration.timescale));
    [layerInstruction setOpacity:0.0 atTime:layerDurationTime];
    
    return layerInstruction;
}


#pragma mark -

- (void)progressMixJogVideos:(NSTimer*)timer
{
    AVAssetExportSession* session = (AVAssetExportSession*)timer.userInfo;
    [self.hudProgressView setProgress:[session progress]];
}

- (void)progressVideoReverseUpdate:(NSTimer*)timer
{
    [self.hudProgressView setProgress:_percentageDone];
}

- (void)hudWillDisappear:(ATMHud *)_hud
{
    isExportCancelled = YES;
    isExporting = NO;
    
    self.mediaRangeSlider.userInteractionEnabled = YES;
    self.seekSlider.userInteractionEnabled = YES;
    
    [_imageGenerator cancelAllCGImageGeneration];
    _imageGenerator = nil;
    
    if (self.assetWriter.status == AVAssetWriterStatusWriting)
    {
        [self.assetWriter cancelWriting];
        self.assetWriter = nil;
    }
    else
    {
        AVAssetExportSession* session = self.progressTimer.userInfo;
        [session cancelExport];
    }
    
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    
    [timesArray removeAllObjects];
    timesArray = nil;
}

@end
