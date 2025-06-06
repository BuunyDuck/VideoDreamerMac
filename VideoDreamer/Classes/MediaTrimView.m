//
//  MusicTrimView.m
//  VideoFrame
//
//  Created by Yinjing Li on 1/21/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "MediaTrimView.h"
#import "NSDate+Extension.h"
#import "SceneDelegate.h"

@import Photos;


@implementation MediaTrimView


typedef enum
{
    PortraitVideo,
    UpsideDownVideo,
    LandscapeLeftVideo,
    LandscapeRightVideo,
} Video_Orientation;


#pragma mark - 
#pragma mark - Init Function

- (id)initWithFrame:(CGRect)frame url:(NSURL*) mediaUrl type:(int)mediaType flag:(BOOL)isFromCamera superView:(UIView *)superView
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];

        self.mnReverseFlag = NO;
        self.isPlaying = NO;
        self.originalMediaUrl = mediaUrl;
        mnMediaType = mediaType;
        mnSaveCopyFlag = NO;
        isCameraVideo = isFromCamera;
        _superView = superView;

        UIEdgeInsets safeAreaInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        if (superView != nil) {
            safeAreaInsets = superView.safeAreaInsets;
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaTrimPlayDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
        
        if (mediaType == MEDIA_VIDEO)
        {
            self.tmpMediaUrl = [[NSDate date] tempFilePathWithProjectName:gstrCurrentProjectName categoryName:@"TrimVideo" extension:@"m4v"];
            
            /* Seek Slider, Label */
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f + safeAreaInsets.left, self.frame.size.height - 65.0f - safeAreaInsets.bottom, self.frame.size.width - 120.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f + safeAreaInsets.left, self.frame.size.height - 65.f - safeAreaInsets.bottom, 50.0f, 30.0f)];
                [self.seekCurrentTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:11]];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - safeAreaInsets.right - 55.0f, self.frame.size.height - 65.f - safeAreaInsets.bottom, 50.0f, 30.0f)];
                [self.seekTotalTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:11]];
            }
            else
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(80.0f + safeAreaInsets.left, self.frame.size.height - 100.0f - safeAreaInsets.bottom, self.frame.size.width - 160.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f + safeAreaInsets.left, self.frame.size.height - 100.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
                [self.seekCurrentTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:14]];
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - safeAreaInsets.right - 60.0f, self.frame.size.height - 100.0f - safeAreaInsets.bottom, 50.0f, 30.0f)];
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
            [self.seekSlider setMinimumValue:0.0f];
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
            [self.seekTotalTimeLabel setText:@"00:00.000"];
            [self addSubview:self.seekTotalTimeLabel];
            
            /* range slider */
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            {
                self.mediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(10.0f + safeAreaInsets.left, self.frame.size.height - 60.0f - safeAreaInsets.bottom, self.frame.size.width - 80.0f - safeAreaInsets.left - safeAreaInsets.right, 50.0f) videoUrl:self.originalMediaUrl value:1.0f];
            }
            else
            {
                self.mediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(5.0f + safeAreaInsets.left, self.frame.size.height - 35.0f - safeAreaInsets.bottom, self.frame.size.width - 45.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f) videoUrl:self.originalMediaUrl value:1.0f];
            }
            
            self.mediaRangeSlider.delegate = self;
            self.mediaRangeSlider.clipsToBounds = YES;
            [self addSubview:self.mediaRangeSlider];
            
            /* play button */
            self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat x = self.frame.size.width - (self.mediaRangeSlider.frame.origin.x * 2.0f + self.mediaRangeSlider.frame.size.width);
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.playButton setFrame:CGRectMake(self.frame.size.width - x - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y, 30.0f, 30.0f)];
            else
                [self.playButton setFrame:CGRectMake(self.frame.size.width - x - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y, 50.0f, 50.0f)];
            
            [self.playButton setBackgroundColor:[UIColor clearColor]];
            [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
            [self.playButton addTarget:self action:@selector(playbackTrimMovie:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.playButton];
            
            
            /* trim button */
            self.trimButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.trimButton setFrame:CGRectMake(20.0f + safeAreaInsets.left, 20.0f + safeAreaInsets.top, 60.0f, 30.0f)];

            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.trimButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:15]];
            else
                [self.trimButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:20]];
            
            [self.trimButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.trimButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [self.trimButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [self.trimButton setBackgroundColor:UIColorFromRGB(0x53585f)];
            [self setSelectedBackgroundViewFor:self.trimButton];
            self.trimButton.layer.masksToBounds = YES;
            self.trimButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.trimButton.layer.borderWidth = 1.0f;
            self.trimButton.layer.cornerRadius = 5.0f;
            [self.trimButton setTitle:NSLocalizedString(@" Apply ", nil) forState:UIControlStateNormal];
            [self.trimButton addTarget:self action:@selector(actionApplyButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.trimButton];
            
            CGFloat labelWidth = [self.trimButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.trimButton.titleLabel.font}].width;
            CGFloat labelHeight = [self.trimButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.trimButton.titleLabel.font}].height;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.trimButton setFrame:CGRectMake(5.0f + safeAreaInsets.left, 7.0f + safeAreaInsets.top, labelWidth+10.0f, labelHeight+15.0f)];
            else
                [self.trimButton setFrame:CGRectMake(20.0f + safeAreaInsets.left, 20.0f + safeAreaInsets.top, labelWidth+20.0f, labelHeight+20.0f)];
            [self.titleLabel setCenter:CGPointMake(self.titleLabel.center.x, self.trimButton.center.y)];
            
            /* Save Checkbox Button */
            self.saveCheckBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.saveCheckBoxButton setFrame:CGRectMake(labelWidth + 30.0f + safeAreaInsets.left, 7.0f + safeAreaInsets.top, labelHeight+10.0f, labelHeight+10.0f)];
            else
                [self.saveCheckBoxButton setFrame:CGRectMake(labelWidth + 50.0f + safeAreaInsets.left, 25.0f + safeAreaInsets.top, labelHeight+10.0f, labelHeight+10.0f)];
            
            [self.saveCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
            [self.saveCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
            [self.saveCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
            [self.saveCheckBoxButton addTarget:self action:@selector(onSaveCheckBox) forControlEvents:UIControlEventTouchUpInside];
            [self.saveCheckBoxButton setSelected:mnSaveCopyFlag];
            [self addSubview:self.saveCheckBoxButton];
            [self.saveCheckBoxButton setCenter:CGPointMake(self.saveCheckBoxButton.center.x, self.trimButton.center.y)];
            

            /* Save Checkbox Label */
            UILabel* checkLabel;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxButton.frame.origin.x+self.saveCheckBoxButton.frame.size.width, self.saveCheckBoxButton.frame.origin.y, 50.0f, self.saveCheckBoxButton.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:10];
            }
            else
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxButton.frame.origin.x+self.saveCheckBoxButton.frame.size.width, self.saveCheckBoxButton.frame.origin.y, 70.0f, self.saveCheckBoxButton.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
            }
            
            checkLabel.backgroundColor = [UIColor clearColor];
            checkLabel.textAlignment = NSTextAlignmentCenter;
            checkLabel.adjustsFontSizeToFitWidth = YES;
            checkLabel.minimumScaleFactor = 0.1f;
            checkLabel.numberOfLines = 0;
            checkLabel.textColor = [UIColor lightGrayColor];
            checkLabel.text = NSLocalizedString(@"Save to Photo Roll", nil);
            [self addSubview:checkLabel];
            [checkLabel setCenter:CGPointMake(checkLabel.center.x, self.trimButton.center.y)];

            
            /* Media Player */
            [self.mediaPlayerLayer.player pause];
            self.mediaPlayerLayer.player = nil;
            
            if (self.mediaPlayerLayer != nil)
            {
                [self.mediaPlayerLayer removeFromSuperlayer];
                self.mediaPlayerLayer = nil;
            }

            self.mediaAsset = nil;
            self.mediaAsset = [AVURLAsset assetWithURL:self.originalMediaUrl];
            self.mediaPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.mediaAsset]]];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                    [_mediaPlayerLayer setFrame:CGRectMake(5.0f + safeAreaInsets.left, self.trimButton.frame.origin.y + self.trimButton.frame.size.height + 5.0f, self.frame.size.width - 10.0f - safeAreaInsets.left - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y - (self.trimButton.frame.origin.y + self.trimButton.frame.size.height) - 10.0f - safeAreaInsets.bottom)];
                else
                    [_mediaPlayerLayer setFrame:CGRectMake(5.0f + safeAreaInsets.left, self.trimButton.frame.origin.y + self.trimButton.frame.size.height + 35.0f, self.frame.size.width - 10.0f - safeAreaInsets.left - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y - (self.trimButton.frame.origin.y + self.trimButton.frame.size.height) - 40.0f - safeAreaInsets.bottom)];
            }
            else
            {
                [_mediaPlayerLayer setFrame:CGRectMake(10.0f + safeAreaInsets.left, self.trimButton.frame.origin.y + self.trimButton.frame.size.height + 10.0f, self.frame.size.width - 20.0f - safeAreaInsets.left - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y - (self.trimButton.frame.origin.y+self.trimButton.frame.size.height) - 20.0f - safeAreaInsets.bottom)];
            }
            
            [self.layer insertSublayer:_mediaPlayerLayer atIndex:0];

            if (isCameraVideo && (gnTemplateIndex == TEMPLATE_SQUARE))
            {
                AVAssetTrack *assetTrack = [[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                CGAffineTransform firstTransform = assetTrack.preferredTransform;
                
                if (assetTrack.naturalSize.width > assetTrack.naturalSize.height)
                {
                    if((firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)||(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0))//portrait
                    {
                        CGFloat w = _mediaPlayerLayer.frame.size.width >= _mediaPlayerLayer.frame.size.height ? _mediaPlayerLayer.frame.size.height : _mediaPlayerLayer.frame.size.width;
                        CGPoint centerPnt = CGPointMake(_mediaPlayerLayer.frame.origin.x + _mediaPlayerLayer.frame.size.width/2.0f, _mediaPlayerLayer.frame.origin.y+_mediaPlayerLayer.frame.size.height/2.0f);
                        
                        [_mediaPlayerLayer setFrame:CGRectMake(centerPnt.x - w/2.0f, centerPnt.y - (assetTrack.naturalSize.width/assetTrack.naturalSize.height)*w/2.0f, w, (assetTrack.naturalSize.width/assetTrack.naturalSize.height)*w)];
                        
                        CALayer* maskLayer = [CALayer layer];
                        maskLayer.frame = CGRectMake((_mediaPlayerLayer.frame.size.width - w)/2.0f, (_mediaPlayerLayer.frame.size.height - w)/2.0f, w, w);
                        maskLayer.backgroundColor = [UIColor blackColor].CGColor;
                        _mediaPlayerLayer.mask = maskLayer;
                    }
                    else
                    {
                        CGFloat w = _mediaPlayerLayer.frame.size.width >= _mediaPlayerLayer.frame.size.height ? _mediaPlayerLayer.frame.size.height: _mediaPlayerLayer.frame.size.width;
                        CGPoint centerPnt = CGPointMake(_mediaPlayerLayer.frame.origin.x + _mediaPlayerLayer.frame.size.width/2.0f, _mediaPlayerLayer.frame.origin.y+_mediaPlayerLayer.frame.size.height/2.0f);
                        
                        [_mediaPlayerLayer setFrame:CGRectMake(centerPnt.x - (assetTrack.naturalSize.width/assetTrack.naturalSize.height)*w/2.0f, centerPnt.y - w/2.0f, (assetTrack.naturalSize.width/assetTrack.naturalSize.height)*w, w)];
                        
                        CALayer* maskLayer = [CALayer layer];
                        maskLayer.frame = CGRectMake((_mediaPlayerLayer.frame.size.width - w)/2.0f, (_mediaPlayerLayer.frame.size.height - w)/2.0f, w, w);
                        maskLayer.backgroundColor = [UIColor blackColor].CGColor;
                        _mediaPlayerLayer.mask = maskLayer;
                    }
                }
                else
                {
                    CGFloat w = _mediaPlayerLayer.frame.size.width >= _mediaPlayerLayer.frame.size.height ? _mediaPlayerLayer.frame.size.width : _mediaPlayerLayer.frame.size.height;
                    CGPoint centerPnt = CGPointMake(_mediaPlayerLayer.frame.origin.x + _mediaPlayerLayer.frame.size.width/2.0f, _mediaPlayerLayer.frame.origin.y+_mediaPlayerLayer.frame.size.height/2.0f);
                    
                    [_mediaPlayerLayer setFrame:CGRectMake(centerPnt.x - w/2.0f, centerPnt.y - (assetTrack.naturalSize.height/assetTrack.naturalSize.width)*w/2.0f, w, (assetTrack.naturalSize.height/assetTrack.naturalSize.width)*w)];
                    
                    CALayer* maskLayer = [CALayer layer];
                    maskLayer.frame = CGRectMake((_mediaPlayerLayer.frame.size.width - w)/2.0f, (_mediaPlayerLayer.frame.size.height - w)/2.0f, w, w);
                    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
                    _mediaPlayerLayer.mask = maskLayer;
                }
            }
            
            self.startTime = 0.0f;
            self.stopTime = CMTimeGetSeconds(self.mediaAsset.duration);
            
            CGFloat duration = self.mediaAsset.duration.value / 500.0f;
            
            __weak typeof(self) weakSelf = self;
            
            [self.mediaPlayerLayer.player addPeriodicTimeObserverForInterval:CMTimeMake(MAX(1, duration), self.mediaAsset.duration.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
             {
                 if (weakSelf.isPlaying)
                 {
                     CGFloat currentTime = CMTimeGetSeconds(time);
                     
                     if ((currentTime >= weakSelf.stopTime) && (weakSelf.mnReverseFlag == NO))
                     {
                         currentTime = weakSelf.stopTime;
                         [weakSelf performSelector:@selector(mediaTrimPlayFinished)];
                     }
                     else if ((currentTime <= weakSelf.startTime)&&(weakSelf.mnReverseFlag == YES))
                     {
                         currentTime = weakSelf.startTime;
                         [weakSelf performSelector:@selector(mediaTrimPlayFinished)];
                     }
                     
                     weakSelf.seekSlider.value = currentTime;
                 }
            }];
            
            
            /* Reverse Checkbox Button */
            self.reverseCheckBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.reverseCheckBoxButton setFrame:CGRectMake(checkLabel.frame.origin.x + checkLabel.frame.size.width + 10.0f, 7.0f + safeAreaInsets.top, labelHeight+10.0f, labelHeight+10.0f)];
            else
                [self.reverseCheckBoxButton setFrame:CGRectMake(checkLabel.frame.origin.x + checkLabel.frame.size.width + 5.0f, 25.0f + safeAreaInsets.top, labelHeight+10.0f, labelHeight+10.0f)];
            
            [self.reverseCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
            [self.reverseCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
            [self.reverseCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
            [self.reverseCheckBoxButton addTarget:self action:@selector(onReverseCheckBox) forControlEvents:UIControlEventTouchUpInside];
            [self.reverseCheckBoxButton setSelected:self.mnReverseFlag];
            [self addSubview:self.reverseCheckBoxButton];
            [self.reverseCheckBoxButton setCenter:CGPointMake(self.reverseCheckBoxButton.center.x, self.trimButton.center.y)];

            
            /* Reverse Checkbox Label */
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.reverseCheckBoxButton.frame.origin.x+self.reverseCheckBoxButton.frame.size.width, self.reverseCheckBoxButton.frame.origin.y, 45.0f, self.reverseCheckBoxButton.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:10];
            }
            else
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.reverseCheckBoxButton.frame.origin.x+self.reverseCheckBoxButton.frame.size.width, self.reverseCheckBoxButton.frame.origin.y, 60.0f, self.reverseCheckBoxButton.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
            }
            
            checkLabel.backgroundColor = [UIColor clearColor];
            checkLabel.textAlignment = NSTextAlignmentCenter;
            checkLabel.adjustsFontSizeToFitWidth = YES;
            checkLabel.minimumScaleFactor = 0.1f;
            checkLabel.numberOfLines = 0;
            checkLabel.textColor = [UIColor lightGrayColor];
            checkLabel.text = NSLocalizedString(@"Reverse Video", nil);
            [self addSubview:checkLabel];
            [checkLabel setCenter:CGPointMake(checkLabel.center.x, self.trimButton.center.y)];

            
            /* Title Label */
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(checkLabel.frame.origin.x + checkLabel.frame.size.width + 5.0f, checkLabel.frame.origin.y + safeAreaInsets.top, self.frame.size.width - (checkLabel.frame.origin.x + checkLabel.frame.size.width + 5.0f), 30.0f)];
                    self.titleLabel.textAlignment = NSTextAlignmentLeft;
                    [self.titleLabel setCenter:CGPointMake(self.titleLabel.center.x, self.trimButton.center.y)];
                }
                else
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 35.0f + safeAreaInsets.top, self.frame.size.width, 30.0f)];
                    self.titleLabel.textAlignment = NSTextAlignmentCenter;
                }
                
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:22];
            }
            else
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, checkLabel.frame.origin.y + safeAreaInsets.top, self.frame.size.width, 30.0f)];
                }
                else
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.trimButton.frame.origin.x + self.trimButton.frame.size.width + 5.0f, checkLabel.frame.origin.y + safeAreaInsets.top, self.frame.size.width - (self.trimButton.frame.origin.x + self.trimButton.frame.size.width + 10.0f), 30.0f)];
                    //self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(safeAreaInsets.left + 5.0, checkLabel.frame.origin.y + safeAreaInsets.top, self.frame.size.width - (safeAreaInsets.left + safeAreaInsets.right + 10.0f), 30.0f)];
                }
                
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:27];
                self.titleLabel.textAlignment = NSTextAlignmentCenter;
                
                [self.titleLabel setCenter:CGPointMake(self.titleLabel.center.x, self.trimButton.center.y)];
            }
            
            [self.titleLabel setBackgroundColor:[UIColor clearColor]];
            [self.titleLabel setTextColor:[UIColor whiteColor]];
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.minimumScaleFactor = 0.1f;
            self.titleLabel.numberOfLines = 1;
            self.titleLabel.text = NSLocalizedString(@"Video Trim Center", nil);
            self.titleLabel.shadowColor = [UIColor blackColor];
            self.titleLabel.shadowOffset = CGSizeMake(1.0f, 1.0f);
            self.titleLabel.layer.shadowOpacity = 0.8f;
            [self addSubview:self.titleLabel];

            NSString* timeStr = [self timeToString:(self.stopTime)];
            self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];

            NSString* startTimeStr = [self timeToString:(self.startTime)];
            self.seekCurrentTimeLabel.text = [NSString stringWithFormat:@"%@", startTimeStr];
            [self.seekSlider setMinimumValue:self.startTime];
            [self.seekSlider setMaximumValue:self.stopTime];
        }
        else if (mediaType == MEDIA_MUSIC) /* Object is Music */
        {
            self.tmpMediaUrl = [[NSDate date] tempFilePathWithProjectName:gstrCurrentProjectName categoryName:@"TrimMusic" extension:@"m4a"];
            
            /* player seek Slider, Label */
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f + safeAreaInsets.left, self.frame.size.height - 95.f - safeAreaInsets.bottom, self.frame.size.width - 120.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, self.frame.size.height - safeAreaInsets.bottom - 95.f, 50.0f, 30.0f)];
                self.seekCurrentTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:11];
                
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - safeAreaInsets.right - 50.0f, self.frame.size.height - 95.f - safeAreaInsets.bottom, 50.0f, 30.0f)];
                self.seekTotalTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:11];
            }
            else
            {
                self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f + safeAreaInsets.left, self.frame.size.height - 130.f - safeAreaInsets.bottom, self.frame.size.width - 120.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
                
                self.seekCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, self.frame.size.height - safeAreaInsets.bottom - 130.f, 50.0f, 30.0f)];
                self.seekCurrentTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:14];
                
                self.seekTotalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - safeAreaInsets.right - 50.0f, self.frame.size.height - 130.f - safeAreaInsets.bottom, 50.0f, 30.0f)];
                self.seekTotalTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:14];
            }
            
            UIImage *minImage = [UIImage imageNamed:@"slider_min"];
            UIImage *maxImage = [UIImage imageNamed:@"slider_max"];
            UIImage *tumbImage = nil;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                tumbImage= [UIImage imageNamed:@"slider_thumb"];
            else
                tumbImage= [UIImage imageNamed:@"slider_thumb_ipad"];
            
            minImage=[minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            maxImage=[maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            
            [self.seekSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
            [self.seekSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
            [self.seekSlider setThumbImage:tumbImage forState:UIControlStateNormal];
            [self.seekSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
            [self.seekSlider setBackgroundColor:[UIColor clearColor]];
            [self.seekSlider setValue:0.0f];
            [self.seekSlider addTarget:self action:@selector(playerSeekPositionChanged) forControlEvents:UIControlEventValueChanged];
            [self.seekSlider setMinimumValue:0.0f];
            [self addSubview:self.seekSlider];

            self.seekCurrentTimeLabel.backgroundColor = [UIColor clearColor];
            self.seekCurrentTimeLabel.textAlignment = NSTextAlignmentCenter;
            self.seekCurrentTimeLabel.adjustsFontSizeToFitWidth = YES;
            self.seekCurrentTimeLabel.minimumScaleFactor = 0.1f;
            self.seekCurrentTimeLabel.numberOfLines = 1;
            self.seekCurrentTimeLabel.textColor = [UIColor yellowColor];
            self.seekCurrentTimeLabel.text = @"00:00.000";
            [self addSubview:self.seekCurrentTimeLabel];

            self.seekTotalTimeLabel.backgroundColor = [UIColor clearColor];
            self.seekTotalTimeLabel.textAlignment = NSTextAlignmentCenter;
            self.seekTotalTimeLabel.adjustsFontSizeToFitWidth = YES;
            self.seekTotalTimeLabel.minimumScaleFactor = 0.1f;
            self.seekTotalTimeLabel.numberOfLines = 1;
            self.seekTotalTimeLabel.textColor = [UIColor yellowColor];
            self.seekTotalTimeLabel.text = @"00:00.000";
            [self addSubview:self.seekTotalTimeLabel];

            
            /* Range Slider */
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            {
                self.mediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(10.0f + safeAreaInsets.left, self.frame.size.height - 90.0f - safeAreaInsets.bottom, self.frame.size.width - 70.0f - safeAreaInsets.left - safeAreaInsets.right, 80.0f) videoUrl:self.originalMediaUrl value:1.0f];
            }
            else
            {
                self.mediaRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(5 + safeAreaInsets.left, self.frame.size.height - 65.0f - safeAreaInsets.bottom, self.frame.size.width - 40.0f - safeAreaInsets.left - safeAreaInsets.right, 60.0f) videoUrl:self.originalMediaUrl value:1.0f];
            }

            self.mediaRangeSlider.delegate = self;
            self.mediaRangeSlider.clipsToBounds = YES;
            [self addSubview:self.mediaRangeSlider];
            
            
            /* Wave Form View */
            self.waveform = [[FDWaveformView alloc] initWithFrame:CGRectMake(self.mediaRangeSlider.frame.origin.x, self.mediaRangeSlider.frame.origin.y, self.mediaRangeSlider.frame.size.width, self.mediaRangeSlider.frame.size.height)];
            self.waveform.delegate = self;
            self.waveform.alpha = 0.0f;
            self.waveform.audioURL = self.originalMediaUrl;
            self.waveform.progressSamples = 10000;
            self.waveform.doesAllowScrubbing = YES;
            [self addSubview:self.waveform];
            self.waveform.userInteractionEnabled = NO;
            [self.waveform createWaveform];
            
            /* Play Button */
            CGFloat x = self.frame.size.width - (self.mediaRangeSlider.frame.origin.x*2.0f + self.mediaRangeSlider.frame.size.width);
            self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.playButton setFrame:CGRectMake(self.frame.size.width - x - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y, 30.0f, 30.0f)];
            else
                [self.playButton setFrame:CGRectMake(self.frame.size.width - x - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y, 50.0f, 50.0f)];
            
            self.playButton.center = CGPointMake(self.playButton.center.x, self.mediaRangeSlider.center.y);
            
            [self.playButton setBackgroundColor:[UIColor clearColor]];
            [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
            [self.playButton addTarget:self action:@selector(playbackTrimMovie:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.playButton];
            
            /* Trim Button */
            self.trimButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.trimButton setFrame:CGRectMake(20.0f + safeAreaInsets.left, 20.0f + safeAreaInsets.top, 60.0f, 30.0f)];

            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.trimButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:15]];
            else
                [self.trimButton.titleLabel setFont:[UIFont fontWithName:MYRIADPRO size:20]];
            
            [self.trimButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.trimButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.trimButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.trimButton.backgroundColor = UIColorFromRGB(0x53585f);
            [self setSelectedBackgroundViewFor:self.trimButton];
            self.trimButton.layer.masksToBounds = YES;
            self.trimButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.trimButton.layer.borderWidth = 1.0f;
            self.trimButton.layer.cornerRadius = 5.0f;
            [self.trimButton setTitle:NSLocalizedString(@" Apply ", nil) forState:UIControlStateNormal];
            [self.trimButton addTarget:self action:@selector(actionApplyButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.trimButton];
            
            CGFloat labelWidth = [self.trimButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.trimButton.titleLabel.font}].width;
            CGFloat labelHeight = [self.trimButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.trimButton.titleLabel.font}].height;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [self.trimButton setFrame:CGRectMake(5.0f + safeAreaInsets.left, 7.0f + safeAreaInsets.top, labelWidth+10.0f, labelHeight+15.0f)];
            else
                [self.trimButton setFrame:CGRectMake(20.0f + safeAreaInsets.left, 20.0f + safeAreaInsets.top, labelWidth+20.0f, labelHeight+20.0f)];
            [self.titleLabel setCenter:CGPointMake(self.titleLabel.center.x, self.trimButton.center.y)];
            
            /* Save Checkbox Button */
            self.saveCheckBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                    [self.saveCheckBoxButton setFrame:CGRectMake(labelWidth + 30.0f + safeAreaInsets.left, 7.0f + safeAreaInsets.top, labelHeight + 10.0f, labelHeight + 10.0f)];
                else
                    [self.saveCheckBoxButton setFrame:CGRectMake(labelWidth + 40.0f + safeAreaInsets.left, 7.0f + safeAreaInsets.top, labelHeight + 10.0f, labelHeight + 10.0f)];
            }
            else
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                    [self.saveCheckBoxButton setFrame:CGRectMake(labelWidth + 80.0f + safeAreaInsets.left, 25.0f + safeAreaInsets.top, labelHeight + 10.0f, labelHeight + 10.0f)];
                else
                    [self.saveCheckBoxButton setFrame:CGRectMake(labelWidth + 70.0f + safeAreaInsets.left, 25.0f + safeAreaInsets.top, labelHeight + 10.0f, labelHeight + 10.0f)];
            }
            
            [self.saveCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
            [self.saveCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
            [self.saveCheckBoxButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
            [self.saveCheckBoxButton addTarget:self action:@selector(onSaveCheckBox) forControlEvents:UIControlEventTouchUpInside];
            [self.saveCheckBoxButton setSelected:mnSaveCopyFlag];
            [self addSubview:self.saveCheckBoxButton];
            [self.saveCheckBoxButton setCenter:CGPointMake(self.saveCheckBoxButton.center.x, self.trimButton.center.y)];

            /* Save Checkbox Label */
            UILabel* checkLabel;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxButton.frame.origin.x + self.saveCheckBoxButton.frame.size.width + 5.0f, self.saveCheckBoxButton.frame.origin.y, 150.0f, self.saveCheckBoxButton.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:12];
                checkLabel.textAlignment = NSTextAlignmentLeft;
            }
            else
            {
                checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.saveCheckBoxButton.frame.origin.x+self.saveCheckBoxButton.frame.size.width, self.saveCheckBoxButton.frame.origin.y, 70.0f, self.saveCheckBoxButton.frame.size.height)];
                checkLabel.font = [UIFont fontWithName:MYRIADPRO size:15];
                checkLabel.textAlignment = NSTextAlignmentCenter;
            }
            
            checkLabel.backgroundColor = [UIColor clearColor];
            checkLabel.adjustsFontSizeToFitWidth = YES;
            checkLabel.minimumScaleFactor = 0.1f;
            checkLabel.numberOfLines = 0;
            checkLabel.textColor = [UIColor lightGrayColor];
            checkLabel.text = NSLocalizedString(@"Save to Library", nil);
            [self addSubview:checkLabel];
            [checkLabel setCenter:CGPointMake(checkLabel.center.x, self.trimButton.center.y)];

            
            /* Media Player */
            self.mediaAsset = nil;
            self.mediaAsset = [AVURLAsset assetWithURL:self.originalMediaUrl];
            self.mediaPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.mediaAsset]]];
            
            self.startTime = 0.0f;
            self.stopTime = CMTimeGetSeconds(self.mediaAsset.duration);

            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                [_mediaPlayerLayer setFrame:CGRectMake(5.0f + safeAreaInsets.left, self.trimButton.frame.origin.y + self.trimButton.frame.size.height + 5.0f, self.frame.size.width - 10.0f - safeAreaInsets.left - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y - (self.trimButton.frame.origin.y+self.trimButton.frame.size.height) - 10.0f - safeAreaInsets.bottom)];
            else
                [_mediaPlayerLayer setFrame:CGRectMake(10.0f + safeAreaInsets.left, self.trimButton.frame.origin.y + self.trimButton.frame.size.height + 10.0f, self.frame.size.width - 20.0f - safeAreaInsets.left - safeAreaInsets.right, self.mediaRangeSlider.frame.origin.y - (self.trimButton.frame.origin.y+self.trimButton.frame.size.height) - 20.0f - safeAreaInsets.bottom)];
            
            [self.layer insertSublayer:_mediaPlayerLayer atIndex:0];
            
            
            /* Media Symbol ImageView */
            self.musicSymbolImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"musicSymbol"]];
            self.musicSymbolImageView.backgroundColor = [UIColor clearColor];
            self.musicSymbolImageView.frame = CGRectMake((self.mediaPlayerLayer.bounds.size.width - self.musicSymbolImageView.frame.size.width) / 2.0f, (self.mediaPlayerLayer.bounds.size.height - self.musicSymbolImageView.frame.size.height) / 2.0f, self.musicSymbolImageView.frame.size.width, self.musicSymbolImageView.frame.size.height);
            [self.mediaPlayerLayer addSublayer:self.musicSymbolImageView.layer];
            
            CGFloat duration = self.mediaAsset.duration.value / 500.0f;
            
            __weak typeof(self) weakSelf = self;
            
            [self.mediaPlayerLayer.player addPeriodicTimeObserverForInterval:CMTimeMake(MAX(1, duration), self.mediaAsset.duration.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time)
             {
                CGFloat currentTime = CMTimeGetSeconds(time);
                
                if (currentTime > weakSelf.stopTime)
                {
                    currentTime = weakSelf.stopTime;
                    [weakSelf performSelector:@selector(mediaTrimPlayFinished)];
                }
                
                 weakSelf.seekSlider.value = currentTime;
            }];
            
            
            /* Title Label */
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                if (self.frame.size.width > self.frame.size.height) //landscape
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, checkLabel.center.y - 15.0f + safeAreaInsets.top, self.frame.size.width, 30.0f)];
                }
                else
                {
                    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, checkLabel.frame.origin.y + checkLabel.frame.size.height + 5.0f + safeAreaInsets.top, self.frame.size.width, 30.0f)];
                }
                
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:22];
            }
            else
            {
                self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, checkLabel.center.y - 15.0f + safeAreaInsets.top, self.frame.size.width, 30.0f)];
                
                self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:27];
            }
            
            [self.titleLabel setBackgroundColor:[UIColor clearColor]];
            [self.titleLabel setTextColor:[UIColor whiteColor]];
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
            self.titleLabel.minimumScaleFactor = 0.1f;
            self.titleLabel.numberOfLines = 1;
            self.titleLabel.text = NSLocalizedString(@"Music Trim Center", nil);
            self.titleLabel.shadowColor = [UIColor blackColor];
            self.titleLabel.shadowOffset = CGSizeMake(1.0f, 1.0f);
            self.titleLabel.layer.shadowOpacity = 0.8f;
            [self addSubview:self.titleLabel];

            NSString* timeStr = [self timeToString:self.stopTime];
            self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
            
            [self.seekSlider setMinimumValue:self.startTime];
            [self.seekSlider setMaximumValue:self.stopTime];
        }
        
        /* ProgressView */
        self.hudProgressView = [[ATMHud alloc] initWithDelegate:self];
        self.hudProgressView.delegate = self;
        [self addSubview:self.hudProgressView.view];
        self.hudProgressView.view.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
        
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, self.mediaRangeSlider.bounds.size.height)];
        self.leftView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
        [self.mediaRangeSlider addSubview:self.leftView];

        self.rightView = [[UIView alloc] initWithFrame:CGRectMake(self.mediaRangeSlider.bounds.size.width - 1.0f, 0.0f, 1.0f, self.mediaRangeSlider.bounds.size.height)];
        self.rightView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
        [self.mediaRangeSlider addSubview:self.rightView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame url:(NSURL*) mediaUrl type:(int)mediaType flag:(BOOL)isFromCamera
{
    return [self initWithFrame:frame url:mediaUrl type:mediaType flag:isFromCamera superView:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setSelectedBackgroundViewFor:(UIButton *) button
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(button.bounds.size.width, button.bounds.size.height), NO, 0.0f);
    [UIColorFromRGB(0x9da1a0) set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.5f, 0.5f, button.bounds.size.width - 0.5f, button.bounds.size.height - 0.5f));
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setBackgroundImage:resultImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:resultImage forState:UIControlStateSelected|UIControlStateHighlighted];
}

- (NSString *)timeToString:(CGFloat)time
{
    if(time < 0.0f)
        time = 0.0f;
    
    NSInteger min = floor(time / 60);
    NSInteger sec = floor(time - min * 60);
    NSInteger millisecond = roundf((time - (min*60 + sec))*1000);
    
    if (millisecond == 1000)
    {
        millisecond = 0;
        sec++;
    }

    NSString *minStr = [NSString stringWithFormat:min >= 10 ? @"%d" : @"0%d", (int)min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%d" : @"0%d", (int)sec];
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
#pragma mark - PlayBack Movie

- (void) playbackTrimMovie:(id) sender
{
    if (self.isPlaying)
    {
        self.isPlaying = NO;
        [self.mediaPlayerLayer.player pause];
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    }
    else
    {
        self.isPlaying = YES;
        
        CGFloat currentTime = CMTimeGetSeconds(self.mediaPlayerLayer.player.currentTime);

        if (self.mnReverseFlag && currentTime >= (self.stopTime - 0.1f))
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime - 0.1f, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        
        [self.mediaPlayerLayer.player play];

        if (self.mnReverseFlag)
        {
            self.mediaPlayerLayer.player.rate = -1.0f;
        }

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
        else
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
    }
}


#pragma mark - PlayBackDidFinish Function

- (void) mediaTrimPlayDidFinish:(NSNotification*)notification
{
    self.isPlaying = NO;
    [self.mediaPlayerLayer.player pause];

    if (mnMediaType == MEDIA_VIDEO)
    {
        if (self.mnReverseFlag)
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self.seekSlider setValue:self.stopTime];
        }
        else
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self.seekSlider setValue:self.startTime];
        }
    }
    else if (mnMediaType == MEDIA_MUSIC)
    {
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.seekSlider setValue:self.startTime];
    }
    
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
}

- (void) mediaTrimPlayFinished
{
    self.isPlaying = NO;
    [self.mediaPlayerLayer.player pause];

    if (mnMediaType == MEDIA_VIDEO)
    {
        if (self.mnReverseFlag)
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self.seekSlider setValue:self.stopTime];
        }
        else
        {
            [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            [self.seekSlider setValue:self.startTime];
        }
    }
    else if (mnMediaType == MEDIA_MUSIC)
    {
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self.seekSlider setValue:self.startTime];
    }
    
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
}


-(void) playerSeekPositionChanged
{
    if (self.isPlaying)
    {
        [self.mediaPlayerLayer.player pause];
        self.isPlaying = NO;
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    }
    
    float time = self.seekSlider.value;
    [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(time, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


#pragma mark -
#pragma mark - Save Copy CheckBox

-(void) onSaveCheckBox
{
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


#pragma mark -
#pragma mark - Reverse CheckBox

-(void) onReverseCheckBox
{
    if (self.isPlaying)
    {
        [self.mediaPlayerLayer.player pause];
        self.isPlaying = NO;
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    }

    if (self.reverseCheckBoxButton.selected)
    {
        [self.reverseCheckBoxButton setSelected:NO];
        self.mnReverseFlag = NO;
        
        [self.seekSlider setValue:self.startTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else
    {
        [self.reverseCheckBoxButton setSelected:YES];
        self.mnReverseFlag = YES;
        
        [self.seekSlider setValue:self.stopTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

- (int) getMediaType
{
    return mnMediaType;
}

- (void)hudWillDisappear:(ATMHud *)_hud
{
    isExportCancelled = YES;
    
    if (self.mnReverseFlag && (self.assetWriter.status == AVAssetWriterStatusWriting))
    {
        [self.assetWriter cancelWriting];
        self.assetWriter = nil;
    }
    else
    {
        AVAssetExportSession* session = self.progressTimer.userInfo;
        [session cancelExport];
    }
    
    if (self.exportSession != nil) {
        [self.exportSession cancelExport];
        self.exportSession = nil;
    }
    
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}


#pragma mark -
#pragma mark - did action Apply button

- (void)actionApplyButton:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Apply Trim", nil)
                            image:nil
                           target:self
                           action:@selector(applyTrim:)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Cancel", nil)
                            image:nil
                           target:self
                           action:@selector(didCancelTrim:)],
      
      ];
    
    CGRect frame = [self.trimButton convertRect:self.trimButton.bounds toView:self];
    [YJLActionMenu showMenuInView:self
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

- (void)didCancelTrim:(id) sender
{
    isExportCancelled = YES;
    
    if (self.mnReverseFlag && (self.assetWriter.status == AVAssetWriterStatusWriting))
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
    
    [self.mediaPlayerLayer.player pause];

    if ([self.delegate respondsToSelector:@selector(didCancelTrimUI)])
    {
        [self.delegate didCancelTrimUI];
    }
}

#pragma mark -
#pragma mark - Apply Trim

- (void)applyTrim:(id)sender
{
    isExportCancelled = NO;
    [self.mediaPlayerLayer.player pause];

    CMTime mediaDuration = self.mediaAsset.duration;
    
    if (mnMediaType == MEDIA_VIDEO)
    {
        if (self.mnReverseFlag)  // Reverse
        {
            NSError *error = nil;

            AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
            
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            NSArray *videoDataSources = [NSArray arrayWithArray:[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo]];
            
            CMTime startTimeOnComposition = kCMTimeZero;
            
            for (int i = 0; i < self.mediaRangeSlider.videoRangeSliderArray.count; i++)
            {
                SASliderView* sliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                
                CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                
                CMTime start = CMTimeMake(startPos * mediaDuration.timescale, mediaDuration.timescale);
                CMTime duration = CMTimeMake((stopPos - startPos) * mediaDuration.timescale, mediaDuration.timescale);
                
                if (videoDataSources.count > 0) {
                    AVAssetTrack *assetTrack = videoDataSources[0];
                    [videoTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                        ofTrack:assetTrack
                                         atTime:startTimeOnComposition
                                          error:&error];
                    
                    if (error)
                        NSLog(@"Insertion error: %@", error);
                    
                    videoTrack.preferredTransform = assetTrack.preferredTransform;
                }
                
                startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
            }
            
            NSArray *audioDataSources = [NSArray arrayWithArray: [self.mediaAsset tracksWithMediaType:AVMediaTypeAudio]];
            if ([audioDataSources count] > 0)
            {
                AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                error = nil;
                
                startTimeOnComposition = kCMTimeZero;
                
                for (int i = 0; i < self.mediaRangeSlider.videoRangeSliderArray.count; i++)
                {
                    SASliderView* sliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                    
                    CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                    CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                    
                    CMTime start = CMTimeMakeWithSeconds(startPos, mediaDuration.timescale);
                    CMTime duration = CMTimeMakeWithSeconds((stopPos - startPos), mediaDuration.timescale);
                    
                    [audioTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                        ofTrack:[audioDataSources objectAtIndex:0]
                                         atTime:startTimeOnComposition
                                          error:&error];
                    if (error)
                        NSLog(@"Insertion error: %@", error);
                    
                    startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
                }
            }
            
            self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02f target:self selector:@selector(progressLandscapeVideoReverseUpdate:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
            [self.hudProgressView setCaption:NSLocalizedString(@"Reversing Video...", nil)];
            [self.hudProgressView setProgress:0.08];
            [self.hudProgressView show];
            [self.hudProgressView showDismissButton];

            AVAssetTrack *assetTrack = [[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            CGAffineTransform firstTransform = assetTrack.preferredTransform;
            
            //[[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Preparing...", nil) isLock:YES];

            BOOL isNeedToFixAffinetransform = NO;
            
            if ((firstTransform.a == 0) && (firstTransform.b == 1.0) && (firstTransform.c == -1.0) && (firstTransform.d == 0))//portrait
            {
                isNeedToFixAffinetransform = YES;
                mnVideoOrientation = PortraitVideo;
                reverseVideoSize = CGSizeMake(mixComposition.naturalSize.height, mixComposition.naturalSize.width);
            }
            else if ((firstTransform.a == 0) && (firstTransform.b == -1.0) && (firstTransform.c == 1.0) && (firstTransform.d == 0))//upside down
            {
                isNeedToFixAffinetransform = YES;
                mnVideoOrientation = UpsideDownVideo;
                reverseVideoSize = CGSizeMake(mixComposition.naturalSize.height, mixComposition.naturalSize.width);
            }
            else if ((firstTransform.a == -1) && (firstTransform.b == 0.0) && (firstTransform.c == 0.0) && (firstTransform.d == -1.0))//landscape left
            {
                isNeedToFixAffinetransform = YES;
                mnVideoOrientation = LandscapeLeftVideo;
                reverseVideoSize = mixComposition.naturalSize;
            }
            else
            {
                isNeedToFixAffinetransform = NO;
                mnVideoOrientation = LandscapeRightVideo;
                reverseVideoSize = mixComposition.naturalSize;
            }
            
            cropVideoSize = reverseVideoSize;
            self.mixAsset = nil;
            self.mixAsset = mixComposition;
            
            if (isCameraVideo || isNeedToFixAffinetransform)
            {
                if (isCameraVideo)
                {
                    if (gnTemplateIndex == TEMPLATE_SQUARE)
                    {
                        if (reverseVideoSize.width > reverseVideoSize.height)
                            cropVideoSize = CGSizeMake(reverseVideoSize.height, reverseVideoSize.height);
                        else if (reverseVideoSize.height > reverseVideoSize.width)
                            cropVideoSize = CGSizeMake(reverseVideoSize.width, reverseVideoSize.width);
                    }
                    else if (gnTemplateIndex == TEMPLATE_LANDSCAPE)
                    {
                        if ((mnVideoOrientation == LandscapeLeftVideo) || (mnVideoOrientation == LandscapeRightVideo)) //landscape left, right
                        {
                            CGSize workspaceSize = CGSizeZero;
                            
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                            {
                                if (isIPhoneFive)
                                    workspaceSize = CGSizeMake(568.0f, 320.0f);
                                else
                                    workspaceSize = CGSizeMake(480.0f, 320.0f);
                            }
                            else
                                workspaceSize = CGSizeMake(1024.0f, 768.0f);
                            
                            cropVideoSize = CGSizeMake(reverseVideoSize.height*workspaceSize.width/workspaceSize.height, reverseVideoSize.height);
                        }
                    }
                    else if (gnTemplateIndex == TEMPLATE_1080P)
                    {
                        if ((mnVideoOrientation == LandscapeLeftVideo) || (mnVideoOrientation == LandscapeRightVideo)) //landscape left, right
                        {
                            CGSize workspaceSize = CGSizeZero;
                            
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                            {
                                if (isIPhoneFive)
                                    workspaceSize = CGSizeMake(568.0f, 320.0f);
                                else
                                    workspaceSize = CGSizeMake(480.0f, 270.0f);
                            }
                            else
                                workspaceSize = CGSizeMake(1024.0f, 576.0f);
                            
                            cropVideoSize = CGSizeMake(reverseVideoSize.height * workspaceSize.width / workspaceSize.height, reverseVideoSize.height);
                        }
                    }
                    else if (gnTemplateIndex == TEMPLATE_PORTRAIT)
                    {
                        if ((mnVideoOrientation == PortraitVideo) || (mnVideoOrientation == UpsideDownVideo)) //portrait up, down
                        {
                            CGSize workspaceSize = CGSizeZero;
                            
                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                            {
                                if (isIPhoneFive)
                                    workspaceSize = CGSizeMake(320.0f, 568.0f);
                                else
                                    workspaceSize = CGSizeMake(320.0f, 480.0f);
                            }
                            else
                                workspaceSize = CGSizeMake(768.0f, 1024.0f);
                            
                            cropVideoSize = CGSizeMake(reverseVideoSize.width, reverseVideoSize.width*workspaceSize.height/workspaceSize.width);
                        }
                    }
                }

                //[self performSelectorInBackground:@selector(createReverseVideoFromComposition:) withObject:mixComposition];
                [self performSelector:@selector(reverseVideo:) withObject:self.mixAsset];
            }
            else
            {
                //[self performSelectorInBackground:@selector(reverseComposition:) withObject:mixComposition];
                [self performSelector:@selector(reverseVideo:) withObject:self.mixAsset];
            }
        }
        else    // Trim Only
        {
            AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
            AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
            
            //Video Track
            AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            NSArray *videoDataSourceArray = [NSArray arrayWithArray: [self.mediaAsset tracksWithMediaType:AVMediaTypeVideo]];
            NSError *error = nil;
            
            CMTime startTimeOnComposition = kCMTimeZero;
            
            for (int i = 0; i < self.mediaRangeSlider.videoRangeSliderArray.count; i++)
            {
                SASliderView* sliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                
                CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                
                CMTime start = CMTimeMakeWithSeconds(startPos, mediaDuration.timescale);
                CMTime duration = CMTimeMakeWithSeconds((stopPos - startPos), mediaDuration.timescale);
                
                [videoTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                    ofTrack:([videoDataSourceArray count]>0)?[videoDataSourceArray objectAtIndex:0]:nil
                                     atTime:startTimeOnComposition
                                      error:&error];
                if (error)
                    NSLog(@"Insertion error: %@", error);
                
                startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
            }
            
            //Audio Track
            NSArray *audioDataSourceArray = [NSArray arrayWithArray: [self.mediaAsset tracksWithMediaType:AVMediaTypeAudio]];
            if ([audioDataSourceArray count] > 0)
            {
                AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                error = nil;
                
                CMTime startTimeOnComposition = kCMTimeZero;
                
                for (int i = 0; i < self.mediaRangeSlider.videoRangeSliderArray.count; i++)
                {
                    SASliderView* sliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                    
                    CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                    CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                    
                    CMTime start = CMTimeMakeWithSeconds(startPos, mediaDuration.timescale);
                    CMTime duration = CMTimeMakeWithSeconds((stopPos - startPos), mediaDuration.timescale);
                    
                    [audioTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                        ofTrack:[audioDataSourceArray objectAtIndex:0]
                                         atTime:startTimeOnComposition
                                          error:&error];
                    if (error)
                        NSLog(@"Insertion error: %@", error);
                    
                    startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
                }
            }
            
            layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            AVAssetTrack *assetTrack = [[self.mediaAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            CGAffineTransform firstTransform = assetTrack.preferredTransform;
            CGSize videoSize = assetTrack.naturalSize;
            
            if (isCameraVideo && (gnTemplateIndex == TEMPLATE_SQUARE))
            {
                CGRect cropRect = CGRectZero;

                if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                {
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2.0f, 0.0f, assetTrack.naturalSize.height, assetTrack.naturalSize.height);

                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2.0f, 0.0f);
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
                else if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                {
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f, assetTrack.naturalSize.height, assetTrack.naturalSize.height);

                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformTranslate(transform, 0.0f, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2);
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
                else if (firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0)//landscape left
                {
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f, assetTrack.naturalSize.height, assetTrack.naturalSize.height);

                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    transform = CGAffineTransformTranslate(transform, (assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f);
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
                else
                {
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f, assetTrack.naturalSize.height, assetTrack.naturalSize.height);

                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height)/2, 0.0f);
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }

                [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
            }
            else if (isCameraVideo && (gnTemplateIndex == TEMPLATE_LANDSCAPE))
            {
                if ((firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0)||(firstTransform.a == 1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == 1.0))//landscape left, right
                {
                    CGRect cropRect = CGRectZero;
                    CGSize workspaceSize = CGSizeZero;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        if (isIPhoneFive)
                            workspaceSize = CGSizeMake(568.0f, 320.0f);
                        else
                            workspaceSize = CGSizeMake(480.0f, 320.0f);
                    }
                    else
                    {
                        workspaceSize = CGSizeMake(1024.0f, 768.0f);
                    }

                    videoSize = CGSizeMake(assetTrack.naturalSize.height*workspaceSize.width/workspaceSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - videoSize.width)/2, 0.0f, videoSize.width, videoSize.height);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    
                    if (firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0)
                        transform = CGAffineTransformTranslate(transform, (assetTrack.naturalSize.width - videoSize.width)/2, 0.0f);
                    else if (firstTransform.a == 1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == 1.0)
                        transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - videoSize.width)/2, 0.0f);
                    
                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                    [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                }
                else
                {
                    if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    else if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
            }
            else if (isCameraVideo && (gnTemplateIndex == TEMPLATE_1080P))
            {
                if ((firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0) || (firstTransform.a == 1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == 1.0))//landscape left, right
                {
                    CGRect cropRect = CGRectZero;
                    CGSize workspaceSize = CGSizeZero;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        if (isIPhoneFive)
                            workspaceSize = CGSizeMake(568.0f, 320.0f);
                        else
                            workspaceSize = CGSizeMake(480.0f, 270.0f);
                    }
                    else
                    {
                        workspaceSize = CGSizeMake(1024.0f, 576.0f);
                    }
                    
                    videoSize = CGSizeMake(assetTrack.naturalSize.height*workspaceSize.width/workspaceSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - videoSize.width)/2, 0.0f, videoSize.width, videoSize.height);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                    
                    if (firstTransform.a == -1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == -1.0)
                        transform = CGAffineTransformTranslate(transform, (assetTrack.naturalSize.width - videoSize.width) / 2, 0.0f);
                    else if (firstTransform.a == 1 && firstTransform.b == 0.0 && firstTransform.c == 0.0 && firstTransform.d == 1.0)
                        transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - videoSize.width) / 2, 0.0f);

                    [layerInstruction setTransform:transform atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                    [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                }
                else
                {
                    if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    else if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
            }
            else if (isCameraVideo && (gnTemplateIndex == TEMPLATE_PORTRAIT))
            {
                if ((firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0) || (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0))//portrait up, down
                {
                    CGRect cropRect = CGRectZero;
                    CGSize workspaceSize = CGSizeZero;
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        if (isIPhoneFive)
                            workspaceSize = CGSizeMake(568.0f, 320.0f);
                        else
                            workspaceSize = CGSizeMake(480.0f, 320.0f);
                    }
                    else
                    {
                        workspaceSize = CGSizeMake(1024.0f, 768.0f);
                    }
                    
                    videoSize = CGSizeMake(assetTrack.naturalSize.height * workspaceSize.width / workspaceSize.height, assetTrack.naturalSize.height);
                    cropRect = CGRectMake((assetTrack.naturalSize.width - videoSize.width) / 2, 0.0f, videoSize.width, videoSize.height);
                    
                    if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                    {
                        CGAffineTransform transform = CGAffineTransformIdentity;
                        transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                        transform = CGAffineTransformTranslate(transform, -(assetTrack.naturalSize.width - videoSize.width) / 2, 0.0f);
                        [layerInstruction setTransform:transform atTime:kCMTimeZero];
                        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                    }
                    else if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                    {
                        CGAffineTransform transform = CGAffineTransformIdentity;
                        transform = CGAffineTransformTranslate(transform, 0.0f, -(assetTrack.naturalSize.width - videoSize.width) / 2);
                        transform = CGAffineTransformConcat(assetTrack.preferredTransform, transform);
                        [layerInstruction setTransform:transform atTime:kCMTimeZero];
                        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                    }

                    [layerInstruction setCropRectangle:cropRect atTime:kCMTimeZero];
                    videoSize = CGSizeMake(videoSize.height, videoSize.width);
                }
                else
                {
                    if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    else if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                    
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
                }
            }
            else
            {
                if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)//portrait
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                else if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)//portrait-home top
                    videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
                
                CGAffineTransform transform = CGAffineTransformIdentity;
                if (firstTransform.b == 1 && firstTransform.c == -1 && firstTransform.tx == 0 && firstTransform.ty == 0) {
                    transform = CGAffineTransformTranslate(transform, assetTrack.naturalSize.height, 0);
                } else if (firstTransform.b == -1 && firstTransform.c == 1 && firstTransform.tx == 0 && firstTransform.ty == 0) {
                    transform = CGAffineTransformTranslate(transform, assetTrack.naturalSize.width, 0);
                }
                [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
                [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
            }
            
            AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
            MainInstruction.backgroundColor = [UIColor clearColor].CGColor;
            MainInstruction.layerInstructions = @[layerInstruction];
            
            AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
            MainCompositionInst.instructions = @[MainInstruction];
            MainCompositionInst.frameDuration = CMTimeMake(1.0f, 30.0f);
            MainCompositionInst.renderSize = videoSize;
            
            if (self.exportSession) {
                self.exportSession = nil;
            }

            self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
            self.exportSession.outputURL = self.tmpMediaUrl;
            self.exportSession.outputFileType = AVFileTypeMPEG4;
            self.exportSession.videoComposition = MainCompositionInst;
            self.exportSession.shouldOptimizeForNetworkUse = YES;
            self.exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
            
            prevPro = 0.0f;
            isSameProgress = NO;
            
            self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(progressSimpleUpdate:) userInfo:self.exportSession repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
            [self.hudProgressView setCaption:NSLocalizedString(@"Importing Video...", nil)];
            [self.hudProgressView setProgress:0.08];
            [self.hudProgressView show];
            [self.hudProgressView showDismissButton];

            BOOL _mnSaveCopyFlag = mnSaveCopyFlag;
            int _mnMediaType = mnMediaType;
            [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    switch ([self.exportSession status])
                    {
                        case AVAssetExportSessionStatusFailed:
                        {
                            NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                            
                            [self.exportSession cancelExport];
                            
                            [[SHKActivityIndicator currentIndicator] hide];
                            
                            [self.progressTimer invalidate];
                            self.progressTimer = nil;
                            
                            [self.hudProgressView hide];
                        }
                            break;
                            
                        case AVAssetExportSessionStatusCancelled:
                        {
                            NSLog(@"Export canceled");
                            
                            [self.exportSession cancelExport];

                            [[SHKActivityIndicator currentIndicator] hide];
                            
                            [self.progressTimer invalidate];
                            self.progressTimer = nil;
                            
                            [self.hudProgressView hide];
                            
                            self.exportSession = nil;
                        }
                            break;
                        case AVAssetExportSessionStatusUnknown:
                            
                            [[SHKActivityIndicator currentIndicator] hide];

                            NSLog(@"AVAssetExportSessionStatusUnknown");
                            
                            break;
                        case AVAssetExportSessionStatusWaiting:

                            [[SHKActivityIndicator currentIndicator] hide];

                            NSLog(@"AVAssetExportSessionStatusWaiting");
                            
                            break;
                        case AVAssetExportSessionStatusExporting:

                            [[SHKActivityIndicator currentIndicator] hide];

                            NSLog(@"AVAssetExportSessionStatusExporting");
                            
                            break;
                            
                        default:
                        {
                            [[SHKActivityIndicator currentIndicator] hide];
                            
                            if ((_mnSaveCopyFlag) && (_mnMediaType == MEDIA_VIDEO))
                                [self saveMovieToPhotoAlbum];
                            
                            if ([self.delegate respondsToSelector:@selector(didCompletedTrim:type:)])
                            {
                                [self.delegate didCompletedTrim:self.tmpMediaUrl type:_mnMediaType];
                            }
                            
                            [self.progressTimer invalidate];
                            self.progressTimer = nil;
                            
                            [self.hudProgressView hide];
                            
                            self.mediaPlayerLayer.player = nil;
                            
                            if (self.mediaPlayerLayer != nil){
                                [self.mediaPlayerLayer removeFromSuperlayer];
                                self.mediaPlayerLayer = nil;
                            }
                            
                            self.exportSession = nil;
                        }
                            break;
                    }

                });

            }];
        }
    }
    else if(mnMediaType == MEDIA_MUSIC)
    {
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
            
        NSArray *audioDataSourceArray = [NSArray arrayWithArray: [self.mediaAsset tracksWithMediaType:AVMediaTypeAudio]];
        
        if ([audioDataSourceArray count] > 0)
        {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            NSError* error = nil;
            
            CMTime startTimeOnComposition = kCMTimeZero;
            
            for (int i = 0; i < self.mediaRangeSlider.videoRangeSliderArray.count; i++)
            {
                SASliderView* sliderView = [self.mediaRangeSlider.videoRangeSliderArray objectAtIndex:i];
                
                CGFloat startPos = (sliderView.leftPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                CGFloat stopPos = (sliderView.rightPos * CMTimeGetSeconds(self.mediaAsset.duration) / self.mediaRangeSlider.frame.size.width);
                
                CMTime start = CMTimeMakeWithSeconds(startPos, mediaDuration.timescale);
                CMTime duration = CMTimeMakeWithSeconds((stopPos - startPos), mediaDuration.timescale);
                
                [audioTrack insertTimeRange:CMTimeRangeMake(start, duration)
                                    ofTrack:[audioDataSourceArray objectAtIndex:0]
                                     atTime:startTimeOnComposition
                                      error:&error];
                if(error)
                    NSLog(@"Insertion error: %@", error);
                
                startTimeOnComposition = CMTimeAdd(startTimeOnComposition, duration);
            }
        }

        if (self.exportSession) {
            self.exportSession = nil;
        }
        
        self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetAppleM4A];
        self.exportSession.outputURL = self.tmpMediaUrl;
        self.exportSession.outputFileType = AVFileTypeAppleM4A;
        CGFloat totalDuration = CMTimeGetSeconds(mixComposition.duration);
        self.exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(totalDuration, mediaDuration.timescale));
        
        prevPro = 0.0f;
        isSameProgress = NO;
        
        [self.hudProgressView setProgress:0.01];
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(progressSimpleUpdate:) userInfo:self.exportSession repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
        [self.hudProgressView setCaption:NSLocalizedString(@"Importing Music...", nil)];
        [self.hudProgressView setProgress:0.08];
        [self.hudProgressView show];
        [self.hudProgressView showDismissButton];
        
        BOOL _mnSaveCopyFlag = mnSaveCopyFlag;
        int _mnMediaType = mnMediaType;
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                {
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                        
                        [self.progressTimer invalidate];
                        self.progressTimer = nil;
                        [self.hudProgressView hide];
                        
                        self.exportSession = nil;
                    });
                }
                    break;
                case AVAssetExportSessionStatusCancelled:
                {
                    NSLog(@"Export canceled");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
                        
                        [self.progressTimer invalidate];
                        self.progressTimer = nil;
                        [self.hudProgressView hide];
                        
                        self.exportSession = nil;
                    });
                }
                    break;
                    
                default:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[SHKActivityIndicator currentIndicator] hide];
                        
                        if ((_mnSaveCopyFlag) && (_mnMediaType == MEDIA_MUSIC))
                            [self saveToLibrary];
                        
                        if ([self.delegate respondsToSelector:@selector(didCompletedTrim:type:)])
                        {
                            [self.delegate didCompletedTrim:self.tmpMediaUrl type:_mnMediaType];
                        }
                        
                        [self.progressTimer invalidate];
                        self.progressTimer = nil;
                        [self.hudProgressView hide];
                        
                        self.mediaPlayerLayer.player = nil;
                        
                        if (self.mediaPlayerLayer != nil)
                        {
                            [self.mediaPlayerLayer removeFromSuperlayer];
                            self.mediaPlayerLayer = nil;
                        }
                        
                        self.exportSession = nil;
                    });
                }
                    break;
            }
        }];
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
             PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.tmpMediaUrl];
             
             //Create Album
             PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:NSLocalizedString(@"Video Dreamer", nil)];
             
             //get a placeholder for the new asset and add it to the album editing request
             PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
             
             [albumRequest addAssets:@[assetPlaceholder]];
         }
         else //add video to album
         {
             //create asset
             PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.tmpMediaUrl];
             
             //change Album
             PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
             PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
             
             //get a placeholder for the new asset and add it to the album editing request
             PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
             
             [albumRequest addAssets:@[assetPlaceholder]];
         }
         
     } completionHandler:^(BOOL success, NSError *error) {
         
         if (error != nil)
         {
             [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:[NSString stringWithFormat:NSLocalizedString(@"Video Saving Failed:%@", nil), error.description] okHandler:nil];
             
             [[SHKActivityIndicator currentIndicator] hide];
         }
         else
         {
             NSLog(@"Video Saved!");
             
             [self.progressTimer invalidate];
             self.progressTimer = nil;
             [self.hudProgressView hide];
             
             [[SHKActivityIndicator currentIndicator] hide];
         }
     }];
}

-(void) saveToLibrary
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    NSString* toFolderName = @"Music Library";
    NSString *toFolderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *toFolderPath = [toFolderDir stringByAppendingPathComponent:toFolderName];
    toFolderPath = [toFolderPath stringByAppendingPathComponent:@"Library"];
    
    if (![localFileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:NO attributes:nil error:nil])
    {
        [localFileManager createDirectoryAtPath:toFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString* musicFileName = [self.tmpMediaUrl lastPathComponent];
    
    NSError* error = nil;
    
    [localFileManager copyItemAtPath:[self.tmpMediaUrl path] toPath:[toFolderPath stringByAppendingPathComponent:musicFileName] error:&error];
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
#pragma mark - SAVideoRangeSliderDelegate

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition LCR:(int)leftCenterRight value:(CGFloat)motionValue
{
    if (self.isPlaying)
    {
        [self.mediaPlayerLayer.player pause];
        self.isPlaying = NO;
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    }
    
    self.startTime = leftPosition;
    self.stopTime = rightPosition;

    NSString* timeStr = [self timeToString:self.stopTime];
    self.seekTotalTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
    self.seekCurrentTimeLabel.text = [NSString stringWithFormat:@"%@", [self timeToString:self.startTime]];
    [self.seekSlider setMinimumValue:self.startTime];
    [self.seekSlider setMaximumValue:self.stopTime];
    
    if (leftCenterRight == LEFT)
    {
        [self.seekSlider setValue:self.startTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else if (leftCenterRight == RIGHT)
    {
        [self.seekSlider setValue:self.stopTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.stopTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    else
    {
        [self.seekSlider setValue:self.startTime];
        [self.mediaPlayerLayer.player seekToTime:CMTimeMakeWithSeconds(self.startTime, self.mediaAsset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    
    [self.mediaRangeSlider updateSelectedRangeBubble];
    
    // left, right opacity view
    CGFloat leftPoint = leftPosition * self.mediaRangeSlider.frame.size.width / CMTimeGetSeconds(self.mediaAsset.duration);
    CGFloat rightPoint = rightPosition * self.mediaRangeSlider.frame.size.width / CMTimeGetSeconds(self.mediaAsset.duration);
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (_superView != nil) {
        safeAreaInsets = _superView.safeAreaInsets;
    }
    [self.leftView setFrame:CGRectMake(0.0f, 0.0f, leftPoint, self.leftView.bounds.size.height)];
    [self.rightView setFrame:CGRectMake(rightPoint, 0.0f, self.mediaRangeSlider.bounds.size.width - rightPoint, self.rightView.bounds.size.height)];
}


/***************************************  Reverse Processing!!!  *****************************************************/

#pragma mark -
#pragma mark - create reverse video

- (void) reverseComposition:(AVMutableComposition*) composition
{
    percentageDone = 0.0f;

    NSError *error;
    
    AVAssetReader *assetReader = [[AVAssetReader alloc] initWithAsset:composition error:&error];
    AVAssetTrack *videoTrack = [[composition tracksWithMediaType:AVMediaTypeVideo] lastObject];
    NSDictionary *readerOutputSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    AVAssetReaderTrackOutput* readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:readerOutputSettings];
    [assetReader addOutput:readerVideoTrackOutput];
    readerVideoTrackOutput.supportsRandomAccess = YES;
    [assetReader startReading];
    
    [self startRecording];
    
    CMSampleBufferRef sample;
    timesArray = [[NSMutableArray alloc] init];
    while((sample = [readerVideoTrackOutput copyNextSampleBuffer]))
    {
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sample);
        NSValue *frameTimeValue = [NSValue valueWithCMTime:presentationTime];
        [timesArray addObject:frameTimeValue];
        CFRelease(sample);
    }
    
    [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];
    
    CMTime newPresentationTime = kCMTimeZero;
    CMTime lastSamplePresentationTime = kCMTimeZero;
    BOOL isFirstEmpty = NO;
    
    // write reversed video frames
    for (int i = 0; i < timesArray.count; i++)
    {
        if (isExportCancelled)
            return;
        
        percentageDone = ((Float32)i / (Float32)timesArray.count);

        NSValue *frameTimeValue = [timesArray objectAtIndex:(timesArray.count - 1 - i)];
        CMTime presentationTime = [frameTimeValue CMTimeValue];
        CMTime nextSamplePresentationTime = kCMTimeZero;
        
        if (i == 0)
        {
            nextSamplePresentationTime = composition.duration;
            lastSamplePresentationTime = presentationTime;
            
            if (nextSamplePresentationTime.value == presentationTime.value)
            {
                isFirstEmpty = YES;
                continue;
            }
        }
        else
        {
            NSValue *nextFrameTimeValue = [timesArray objectAtIndex:(timesArray.count - i)];
            nextSamplePresentationTime = [nextFrameTimeValue CMTimeValue];
            
            if ((i == 1)&&(isFirstEmpty == YES))
            {
                lastSamplePresentationTime = presentationTime;
            }
        }
        
        CMTime frameDuration = CMTimeSubtract(nextSamplePresentationTime, presentationTime);
        
        CMTimeRange range = CMTimeRangeMake(presentationTime, frameDuration);
        NSValue *resetframeTimeValue = [NSValue valueWithCMTimeRange:range];
        [readerVideoTrackOutput resetForReadingTimeRanges:[NSArray arrayWithObject:resetframeTimeValue]];
        
        newPresentationTime = CMTimeSubtract(lastSamplePresentationTime, presentationTime);
        
        CMSampleBufferRef sample;
        
        while((sample = [readerVideoTrackOutput copyNextSampleBuffer]))
        {
            CVPixelBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(sample);
            
            if (self.assetWriterInput.readyForMoreMediaData)
            {
                if(![self.assetWriterPixelBufferAdaptor appendPixelBuffer:imageBufferRef withPresentationTime:newPresentationTime])
                    NSLog(@"asset write failed");
            }
            
            CFRelease(sample);
        }
    }
    
    [self stopRecording];
}


-(void) startRecording
{
    NSError *movieError = nil;
    
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.tmpMediaUrl
                                                 fileType: AVFileTypeMPEG4
                                                    error: &movieError];
    NSDictionary *assetWriterInputSettings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
                                               AVVideoWidthKey: [NSNumber numberWithInt:cropVideoSize.width],
                                               AVVideoHeightKey: [NSNumber numberWithInt:cropVideoSize.height]
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

-(void) stopRecording
{
    if (isExportCancelled)
        return;

    if (_assetWriter.status == AVAssetWriterStatusWriting)
    {
        [_assetWriter finishWritingWithCompletionHandler:^{
            self.assetWriter = nil;
            [self performSelectorOnMainThread:@selector(completedTrimReverse) withObject:nil waitUntilDone:NO];
        }];
    }
}

- (void) completedTrimReverse
{
    if (timesArray != nil) {
        [timesArray removeAllObjects];
        timesArray = nil;
    }
    
    if (_imageGenerator != nil) {
        [_imageGenerator cancelAllCGImageGeneration];
        _imageGenerator = nil;
    }
    
    if (isExportCancelled)
        return;
        
    if ([self.delegate respondsToSelector:@selector(didCompletedTrim:type:)])
    {
        [self.delegate didCompletedTrim:self.tmpMediaUrl type:mnMediaType];
    }
    
    if ((mnSaveCopyFlag) && (mnMediaType == MEDIA_VIDEO))
    {
        [self.hudProgressView setCaption:NSLocalizedString(@"Save video to gallery...", nil)];
        [self saveMovieToPhotoAlbum];
    }
    else
    {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        [self.hudProgressView hide];
        
        [[SHKActivityIndicator currentIndicator] hide];
    }
    
    self.mediaPlayerLayer.player = nil;
    
    if (self.mediaPlayerLayer != nil)
    {
        [self.mediaPlayerLayer removeFromSuperlayer];
        self.mediaPlayerLayer = nil;
    }
}

- (void) failedTrimReverse
{
    if (timesArray != nil) {
        [timesArray removeAllObjects];
        timesArray = nil;
    }
    
    if (_imageGenerator != nil) {
        [_imageGenerator cancelAllCGImageGeneration];
        _imageGenerator = nil;
    }
    
    if (isExportCancelled)
        return;
        
    self.exportSession = nil;
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [self.hudProgressView hide];
    
    [[SHKActivityIndicator currentIndicator] displayErrorMessage:@"Failed to reverse video. Please try again."];
}

#pragma mark - old code for reverse

- (void) createReverseVideoFromComposition:(AVMutableComposition*) composition
{
    timesArray = [[NSMutableArray alloc] init];
    
    percentageDone = 0.0f;
    fakeTimeElapsed = 0.0f;
    _nCount = 0;

    Float64 clipTime = (Float64)1.0f / grFrameRate;
    Float64 assetDuration = CMTimeGetSeconds(composition.duration);
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:composition];
    self.imageGenerator.maximumSize = composition.naturalSize;
    
    while (clipTime < assetDuration)
    {
        CMTime frameTime = CMTimeMakeWithSeconds(assetDuration - clipTime, 600.0f);
        NSValue *frameTimeValue = [NSValue valueWithCMTime:frameTime];
        [timesArray addObject:frameTimeValue];
        clipTime += (Float64)1.0f / grFrameRate;
    };
    
    [self startRecording];

    [[SHKActivityIndicator currentIndicator] performSelectorOnMainThread:@selector(hide) withObject:nil waitUntilDone:NO];

    int _mnVideoOrientation = mnVideoOrientation;
    CGSize _cropVideoSize = cropVideoSize;
    NSMutableArray *_timesArray = timesArray;
    BOOL _isCameraVideo = isCameraVideo;
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:timesArray
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                                  AVAssetImageGeneratorResult result, NSError *error) {
                                                  
      if (result == AVAssetImageGeneratorSucceeded)
      {
          self->percentageDone = ((Float32)self.nCount / (Float32)[_timesArray count]);
          
          @autoreleasepool
          {
              if(_mnVideoOrientation == PortraitVideo)//portrait
                  image = [self rotateFrameImage:image];
              else if(_mnVideoOrientation == UpsideDownVideo)//upside down
                  image = [self rotateFrameImage:image];
              else if (_mnVideoOrientation == LandscapeLeftVideo)//landscape left
                  image = [self rotateFrameImage:image];
              
              if (_isCameraVideo)
              {
                  if (gnTemplateIndex == TEMPLATE_SQUARE)
                  {
                      UIImage* cropImage = [UIImage imageWithCGImage:image];
                      CGRect rect = CGRectMake((cropImage.size.width - _cropVideoSize.width) / 2.0f, (cropImage.size.height - _cropVideoSize.height) / 2.0f, _cropVideoSize.width, _cropVideoSize.height);
                      cropImage = [cropImage cropImageToRect:rect];
                      image = cropImage.CGImage;
                  }
                  else if (gnTemplateIndex == TEMPLATE_LANDSCAPE)
                  {
                      if ((_mnVideoOrientation == LandscapeLeftVideo) || (_mnVideoOrientation == LandscapeRightVideo))//landscape left, right
                      {
                          UIImage* cropImage = [UIImage imageWithCGImage:image];
                          CGRect rect = CGRectMake((cropImage.size.width - _cropVideoSize.width) / 2.0f, (cropImage.size.height - _cropVideoSize.height) / 2.0f, _cropVideoSize.width, _cropVideoSize.height);
                          cropImage = [cropImage cropImageToRect:rect];
                          image = cropImage.CGImage;
                      }
                  }
                  else if (gnTemplateIndex == TEMPLATE_1080P)
                  {
                      if((_mnVideoOrientation == LandscapeLeftVideo) || (_mnVideoOrientation == LandscapeRightVideo))//landscape left, right
                      {
                          UIImage* cropImage = [UIImage imageWithCGImage:image];
                          CGRect rect = CGRectMake((cropImage.size.width - _cropVideoSize.width) / 2.0f, (cropImage.size.height - _cropVideoSize.height) / 2.0f, _cropVideoSize.width, _cropVideoSize.height);
                          cropImage = [cropImage cropImageToRect:rect];
                          image = cropImage.CGImage;
                      }
                  }
                  else if (gnTemplateIndex == TEMPLATE_PORTRAIT)
                  {
                      if((_mnVideoOrientation == PortraitVideo) || (_mnVideoOrientation == UpsideDownVideo))//portrait, upside down
                      {
                          UIImage* cropImage = [UIImage imageWithCGImage:image];
                          CGRect rect = CGRectMake((cropImage.size.width - _cropVideoSize.width) / 2.0f, (cropImage.size.height - _cropVideoSize.height) / 2.0f, _cropVideoSize.width, _cropVideoSize.height);
                          cropImage = [cropImage cropImageToRect:rect];
                          image = cropImage.CGImage;
                      }
                  }
              }
              
              [self writeSample:image];
          }
          
          self.nCount++;
          
          if (self.nCount == [_timesArray count])
              [self stopRecording];
      }
    }];
}

-(CGImageRef) rotateFrameImage:(CGImageRef)image
{
    UIImage* rotateImage = [UIImage imageWithCGImage:image];
    
    if (mnVideoOrientation == LandscapeLeftVideo)//landscape left
    {
        CGRect rect = CGRectMake(0.0f, 0.0f, rotateImage.size.width, rotateImage.size.height);
        UIGraphicsBeginImageContext(rect.size);

        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformMakeTranslation(rotateImage.size.width, rotateImage.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
        
        [rotateImage drawInRect:rect];
        rotateImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if (mnVideoOrientation == PortraitVideo)//portrait
    {
        CGRect rect = CGRectMake(0.0f, 0.0f, rotateImage.size.height, rotateImage.size.width);
        UIGraphicsBeginImageContext(rect.size);
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformMakeTranslation(rotateImage.size.height, 0);
        transform = CGAffineTransformRotate(transform, M_PI/2);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
        
        rect = CGRectMake(0.0f, 0.0f, rotateImage.size.width, rotateImage.size.height);
        
        [rotateImage drawInRect:rect];
        rotateImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if (mnVideoOrientation == UpsideDownVideo)//upside down
    {
        CGRect rect = CGRectMake(0.0f, 0.0f, rotateImage.size.height, rotateImage.size.width);
        UIGraphicsBeginImageContext(rect.size);
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformMakeTranslation(0.0f, rotateImage.size.width);
        transform = CGAffineTransformRotate(transform, 3.0f * M_PI / 2.0f);
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
        
        rect = CGRectMake(0.0f, 0.0f, rotateImage.size.width, rotateImage.size.height);
        
        [rotateImage drawInRect:rect];
        rotateImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return rotateImage.CGImage;
}


- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CGSize size = CGSizeZero;
    
    if ((mnVideoOrientation == PortraitVideo) || (mnVideoOrientation == UpsideDownVideo)) //portrait, upside down
        size = CGSizeMake(reverseVideoSize.height, reverseVideoSize.width);
    else if ((mnVideoOrientation == LandscapeLeftVideo) || (mnVideoOrientation == LandscapeRightVideo))//landscape left, right
        size = reverseVideoSize;
    
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


#pragma mark-
#pragma mark-

- (void)progressSimpleUpdate:(NSTimer*)timer
{
    AVAssetExportSession* session = (AVAssetExportSession*)timer.userInfo;

    [self.hudProgressView setProgress:[session progress]];
    
    //process exception of bad frames video
    float currentPro = [session progress];
    if (currentPro == prevPro)
    {
        if (isSameProgress)
        {
            NSTimeInterval currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
            
            if ((currentTimeInterval - prevTimeInterval) > 5.0f)
            {
                if (mnMediaType == MEDIA_VIDEO)
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"This video may have damaged frames. You may change the Trim range and try again.", nil) okHandler:nil];
                }
                else if (mnMediaType == MEDIA_MUSIC)
                {
                    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"This music may have damaged frames. You may change the Trim range and try again.", nil) okHandler:nil];
                }
                
                AVAssetExportSession* session = self.progressTimer.userInfo;
                [session cancelExport];
                
                [self.progressTimer invalidate];
                self.progressTimer = nil;
            }
        }
        else
        {
            isSameProgress = YES;
            prevTimeInterval = [NSDate timeIntervalSinceReferenceDate];
        }
    }
    else
    {
        prevPro = currentPro;
        isSameProgress = NO;
    }
}

- (void)progressLandscapeVideoReverseUpdate:(NSTimer*)timer
{
    if (self.exportSession != nil) {
        [self.hudProgressView setProgress:(self.exportSession.progress)];
    } else {
        [self.hudProgressView setProgress:percentageDone];
    }
}

- (void)progressAudioReverseUpdate:(NSTimer*)timer
{
    if (self.exportSession != nil) {
        [self.hudProgressView setProgress:(self.exportSession.progress)];
    } else {
        [self.hudProgressView setProgress:percentageDone];
    }
}

#pragma mark - new code for reverse

- (void)reverseVideo:(AVAsset *)asset {
    self.exportSession = [self reverseVideo:asset outputURL:self.tmpMediaUrl completionHandler:^(BOOL success, NSError *error) {
        if (success) {
            [self completedTrimReverse];
        } else {
            [self failedTrimReverse];
        }
    }];
}

- (AVAssetExportSession *)reverseVideo:(AVAsset *)asset outputURL:(NSURL *)outputURL completionHandler:(void(^)(BOOL, NSError *))completionHandler {
    
    percentageDone = 0.0f;
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    self.videoAsset = asset;
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *videoDataSources = [NSArray arrayWithArray:[self.videoAsset tracksWithMediaType:AVMediaTypeVideo]];
    if (videoDataSources.count == 0) {
        completionHandler(NO, nil);
        return nil;
    }
    
    AVAssetTrack *assetTrack = [videoDataSources objectAtIndex:0];
    CMTime minFrameDuration = assetTrack.minFrameDuration;
    CMTime videoDuration = self.videoAsset.duration;
    CMTime duration = minFrameDuration;
    CMTime startTime = kCMTimeZero;
    NSError *error = nil;
    while (CMTimeGetSeconds(duration) < CMTimeGetSeconds(videoDuration)) {
        [videoTrack insertTimeRange:CMTimeRangeMake(CMTimeSubtract(videoDuration, duration), minFrameDuration) ofTrack:assetTrack atTime:startTime error:&error];
        if (error != nil) {
            completionHandler(NO, nil);
            return nil;
        }

        duration = CMTimeAdd(duration, minFrameDuration);
        startTime = CMTimeAdd(startTime, minFrameDuration);
    }
    
    videoTrack.preferredTransform = assetTrack.preferredTransform;

    NSArray *audioDataSources = [NSArray arrayWithArray:[self.videoAsset tracksWithMediaType:AVMediaTypeAudio]];
    if (audioDataSources.count > 0) {
        AVAssetTrack *assetTrack = [audioDataSources objectAtIndex:0];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        CMTime duration = minFrameDuration;
        CMTime startTime = kCMTimeZero;
        while (CMTimeGetSeconds(duration) < CMTimeGetSeconds(videoDuration)) {
            [audioTrack insertTimeRange:CMTimeRangeMake(CMTimeSubtract(videoDuration, duration), minFrameDuration) ofTrack:assetTrack atTime:startTime error:&error];
            duration = CMTimeAdd(duration, minFrameDuration);
            startTime = CMTimeAdd(startTime, minFrameDuration);
        }
    }
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    CGSize videoSize = assetTrack.naturalSize;
    if (assetTrack.preferredTransform.a == 0 && assetTrack.preferredTransform.b == 1.0 && assetTrack.preferredTransform.c == -1.0 && assetTrack.preferredTransform.d == 0)//portrait
        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
    else if (assetTrack.preferredTransform.a == 0 && assetTrack.preferredTransform.b == -1.0 && assetTrack.preferredTransform.c == 1.0 && assetTrack.preferredTransform.d == 0)//portrait-home top
        videoSize = CGSizeMake(assetTrack.naturalSize.height, assetTrack.naturalSize.width);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (assetTrack.preferredTransform.b == 1 && assetTrack.preferredTransform.c == -1 && assetTrack.preferredTransform.tx == 0 && assetTrack.preferredTransform.ty == 0) {
        transform = CGAffineTransformTranslate(transform, assetTrack.naturalSize.height, 0);
    } else if (assetTrack.preferredTransform.b == -1 && assetTrack.preferredTransform.c == 1 && assetTrack.preferredTransform.tx == 0 && assetTrack.preferredTransform.ty == 0) {
        transform = CGAffineTransformTranslate(transform, assetTrack.naturalSize.width, 0);
    }
    [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
    [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration);
    mainInstruction.backgroundColor = [UIColor clearColor].CGColor;
    mainInstruction.layerInstructions = @[layerInstruction];
    
    AVMutableVideoComposition *mainVideoComposition = [AVMutableVideoComposition videoComposition];
    mainVideoComposition.instructions = @[mainInstruction];
    mainVideoComposition.frameDuration = CMTimeMake(1.0f, 30.0f);
    mainVideoComposition.renderSize = videoSize;
    
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.videoComposition = mainVideoComposition;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exportSession.error == nil) {
                completionHandler(YES, nil);
            } else {
                completionHandler(NO, exportSession.error);
            }
        });
    }];
    
    return exportSession;
}

@end
