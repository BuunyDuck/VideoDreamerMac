//
//  PreviewView.m
//  VideoFrame
//
//  Created by Yinjing Li on 12/3/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import "PreviewView.h"

@implementation PreviewView: UIView


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        
        isPlaying = NO;
        
        CGRect frame = CGRectZero;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            frame = CGRectMake(self.frame.size.width / 2 - 15.0f, self.frame.size.height / 2 - 15.0f, 30.0f, 30.0f);
        else
            frame = CGRectMake(self.frame.size.width / 2 - 25.0f, self.frame.size.height / 2 - 25.0f, 50.0f, 50.0f);
        
        self.playingImageView = [[UIImageView alloc] initWithFrame:frame];
        [self.playingImageView setBackgroundColor:[UIColor clearColor]];
        [self.playingImageView setImage:[UIImage imageNamed:@"NewPlay"]];
        [self addSubview:self.playingImageView];
        self.playingImageView.alpha = 0.0f;
        
        float font_2x = 1.0f;
       
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            font_2x = 1.0f;
        else
            font_2x = 1.6f;
        
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [self.doneButton.titleLabel setFont: [UIFont fontWithName:MYRIADPRO size:FONT_SIZE*font_2x]];
        [self.doneButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        self.doneButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        self.doneButton.backgroundColor = UIColorFromRGB(0x53585f);
        self.doneButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.doneButton.layer.borderWidth = 1.0f;
        self.doneButton.layer.cornerRadius = 5.0f;
      
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.doneButton setFrame:CGRectMake(10.0f, 10.0f, 45.0f, 30.0f)];
        else
            [self.doneButton setFrame:CGRectMake(10.0f, 10.0f, 80.0f, 50.0f)];
        
        [self.doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];
        self.doneButton.alpha = 1.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.filterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 10.0f, 260.0f, 30.0f)];
        else
            self.filterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0f, 10.0f,660.0f, 50.0f)];
        
        self.filterNameLabel.backgroundColor = [UIColor clearColor];
        self.filterNameLabel.textAlignment = NSTextAlignmentLeft;
        self.filterNameLabel.font = [UIFont fontWithName:MYRIADPRO size:FONT_SIZE*font_2x];
        self.filterNameLabel.textColor = [UIColor whiteColor];
        self.filterNameLabel.shadowColor = [UIColor blackColor];
        self.filterNameLabel.adjustsFontSizeToFitWidth = YES;
        self.filterNameLabel.minimumScaleFactor = 0.1f;
        self.filterNameLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.filterNameLabel];
        self.filterNameLabel.alpha = 1.0f;
        
        self.videoPositionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, self.frame.size.height - 50.f, 50.0f, 30.0f)];
        self.videoPositionLabel.text = @"0:00";
        self.videoPositionLabel.backgroundColor = [UIColor clearColor];
        self.videoPositionLabel.textAlignment = NSTextAlignmentRight;
        self.videoPositionLabel.font = [UIFont fontWithName:MYRIADPRO size:FONT_SIZE*font_2x];
        self.videoPositionLabel.textColor = [UIColor whiteColor];
        self.videoPositionLabel.shadowColor = [UIColor blackColor];
        self.videoPositionLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.videoPositionLabel];
        
        self.videoLegthLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 55.0f, self.frame.size.height - 50.f, 50.0f, 30.0f)];
        self.videoLegthLabel.text = @"0:00";
        self.videoLegthLabel.backgroundColor = [UIColor clearColor];
        self.videoLegthLabel.textAlignment = NSTextAlignmentLeft;
        self.videoLegthLabel.font = [UIFont fontWithName:MYRIADPRO size:FONT_SIZE*font_2x];
        self.videoLegthLabel.textColor = [UIColor whiteColor];
        self.videoLegthLabel.shadowColor = [UIColor blackColor];
        self.videoLegthLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.videoLegthLabel];
        
        self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f, self.frame.size.height - 50.f, self.frame.size.width - 120.0f, 30.0f)];
        self.seekSlider.backgroundColor = [UIColor clearColor];
        [self.seekSlider setValue:0.0f];
        [self.seekSlider addTarget:self action:@selector(changeSeekSlider) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.seekSlider];
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPlayButton:)];
        selectGesture.delegate = self;
        [self addGestureRecognizer:selectGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoPlayDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) adjustFrameView {
    CGRect frame = CGRectZero;
    UIEdgeInsets safeAreaInsets = self.superview.safeAreaInsets;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        frame = CGRectMake((self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right) / 2.0 + safeAreaInsets.left - 15.0f, (self.frame.size.height - safeAreaInsets.top - safeAreaInsets.bottom) / 2.0 + safeAreaInsets.top - 15.0f, 30.0f, 30.0f);
    else
        frame = CGRectMake((self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right) / 2.0 + safeAreaInsets.left - 25.0f, (self.frame.size.height - safeAreaInsets.top - safeAreaInsets.bottom) / 2.0 + safeAreaInsets.top - 25.0f, 50.0f, 50.0f);
    self.playingImageView.frame = frame;
    
    float font_2x = 1.0f;
   
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        font_2x = 1.0f;
    else
        font_2x = 1.6f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [self.doneButton setFrame:CGRectMake(safeAreaInsets.left + 10.0f, safeAreaInsets.top + 10.0f, 45.0f, 30.0f)];
    else
        [self.doneButton setFrame:CGRectMake(safeAreaInsets.left + 10.0f, safeAreaInsets.top + 10.0f, 80.0f, 50.0f)];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.filterNameLabel.frame = CGRectMake(safeAreaInsets.left + 60.0f, safeAreaInsets.top + 10.0f, 260.0f, 30.0f);
    else
        self.filterNameLabel.frame = CGRectMake(safeAreaInsets.left + 100.0f, safeAreaInsets.top + 10.0f,660.0f, 50.0f);
    
    self.videoPositionLabel.frame = CGRectMake(safeAreaInsets.left + 5.0f, self.frame.size.height - safeAreaInsets.bottom - 50.f, 50.0f, 30.0f);
    
    self.videoLegthLabel.frame = CGRectMake(self.frame.size.width - safeAreaInsets.left - 55.0f, self.frame.size.height - safeAreaInsets.bottom - 50.f, 50.0f, 30.0f);
    
    self.seekSlider.frame = CGRectMake(safeAreaInsets.left + 60.0f, self.frame.size.height - safeAreaInsets.bottom - 50.f, self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right - 120.0f, 30.0f);
}

- (void) playVideoInPreview:(NSURL*) videoUrl
{
    UIEdgeInsets safeAreaInsets = self.superview.safeAreaInsets;
    
    self.videoAsset = nil;
    self.videoAsset = [AVURLAsset assetWithURL:videoUrl];
    self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:[AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:self.videoAsset]]];

    self.videoDuration = CMTimeGetSeconds(self.videoAsset.duration);
    self.videoTimescale = self.videoAsset.duration.timescale;
    [_videoPlayerLayer setFrame:CGRectMake(safeAreaInsets.left, safeAreaInsets.top, self.bounds.size.width - safeAreaInsets.left - safeAreaInsets.right, self.bounds.size.height - safeAreaInsets.top - safeAreaInsets.bottom)];
    _videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer insertSublayer:_videoPlayerLayer atIndex:0];
    
    AVAssetTrack *assetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

//    if (gnTemplateIndex == TEMPLATE_SQUARE)
//    {
//        float rWidth = self.bounds.size.width;
//        float rHeight = self.bounds.size.height;
//
//        if (rWidth > rHeight)
//            [_videoPlayerLayer setFrame:CGRectMake((rWidth - rHeight)/2, 0.0f, rHeight, rHeight)];
//        else
//            [_videoPlayerLayer setFrame:CGRectMake(0.0f, (rHeight - rWidth)/2, rWidth, rWidth)];
//    }
//    else if (gnTemplateIndex == TEMPLATE_1080P)
//    {
//        CGFloat scale = self.bounds.size.width/1920.0f;
//
//        CGFloat rWidth = self.bounds.size.width;
//        CGFloat rHeight = 1080.0f*scale;
//
//        [_videoPlayerLayer setFrame:CGRectMake(0.0f, (self.bounds.size.height - rHeight)/2, rWidth, rHeight)];
//    }
//    else
//    {
//        [_videoPlayerLayer setFrame:self.bounds];
//    }
    
//    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)&&(gnOutputQuality == OUTPUT_SDTV))
//    {
//        [_videoPlayerLayer setFrame:CGRectMake((self.frame.size.width-assetTrack.naturalSize.width)/2, (self.frame.size.height - assetTrack.naturalSize.height)/2, assetTrack.naturalSize.width, assetTrack.naturalSize.height)];
//    }

    CGFloat duration = self.videoAsset.duration.value / 500;
   
    __weak typeof (self) weakSelf = self;
    
    [self.videoPlayerLayer.player addPeriodicTimeObserverForInterval:CMTimeMake(MAX(1, duration), self.videoTimescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        CGFloat currentTime = CMTimeGetSeconds(time);
        [weakSelf.seekSlider setValue:currentTime];
        
        int min = currentTime / 60;
        int sec = currentTime - (min * 60);
        [weakSelf.videoPositionLabel setText:[NSString stringWithFormat:@"%d:%02d", min, sec]];
    }];
    
    int min = self.videoDuration / 60;
    int sec = self.videoDuration - (min * 60);
    NSString* string = [NSString stringWithFormat:@"%d:%02d", min, sec];
    [self.videoLegthLabel setText:string];
    [self.videoPositionLabel setText:@"0:00"];
    [self.seekSlider setMaximumValue:self.videoDuration];

    switch (gnOutputQuality)
    {
        case OUTPUT_UHD:
            self.filterNameLabel.text = [NSString stringWithFormat:@"%@.mp4 UHD %dx%d", gstrCurrentProjectName, (int)assetTrack.naturalSize.width, (int)assetTrack.naturalSize.height];
            break;
        case OUTPUT_HD:
            self.filterNameLabel.text = [NSString stringWithFormat:@"%@.mp4 HD %dx%d", gstrCurrentProjectName, (int)assetTrack.naturalSize.width, (int)assetTrack.naturalSize.height];
            break;
        case OUTPUT_UNIVERSAL:
            self.filterNameLabel.text = [NSString stringWithFormat:@"%@.mp4 Universal %dx%d", gstrCurrentProjectName, (int)assetTrack.naturalSize.width, (int)assetTrack.naturalSize.height];
            break;
        case OUTPUT_SDTV:
            self.filterNameLabel.text = [NSString stringWithFormat:@"%@.mp4 SDTV %dx%d", gstrCurrentProjectName, (int)assetTrack.naturalSize.width, (int)assetTrack.naturalSize.height];
            break;
            
        default:
            break;
    }
    
    isPlaying = YES;
    
    [self.playingImageView setImage:[UIImage imageNamed:@"NewPlay"]];
    self.playingImageView.alpha = 0.0f;

    [self.videoPlayerLayer.player play];
}

- (void) videoPlayDidFinish:(NSNotification*)notification
{
    [self.videoPlayerLayer.player pause];
    [self.videoPlayerLayer.player seekToTime:CMTimeMake(0, self.videoTimescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    isPlaying = NO;
    
    [self.playingImageView setImage:[UIImage imageNamed:@"NewPlay"]];
    
    self.playingImageView.alpha = 0.0f;
    
    [UIView animateWithDuration:0.5f animations:^{

        self.playingImageView.alpha = 1.0f;
        
    }completion:^(BOOL finished) {
        
    }];
}

- (void) done
{
    [self.videoPlayerLayer.player pause];
    self.videoPlayerLayer.player = nil;
    
    if (self.videoPlayerLayer != nil)
    {
        [self.videoPlayerLayer removeFromSuperlayer];
        self.videoPlayerLayer = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(previewPlayDidFinished)])
    {
        [self.delegate previewPlayDidFinished];
    }

}

- (void) showPlayButton:(UITapGestureRecognizer *)gestureRecognizer
{
    if (isPlaying)
    {
        isPlaying = NO;
        
        [self.playingImageView setImage:[UIImage imageNamed:@"NewPlay"]];

        [self.videoPlayerLayer.player pause];
        
        [UIView animateWithDuration:0.5f animations:^{
            
            self.playingImageView.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            
            [self performSelector:@selector(hidePlayButton) withObject:nil afterDelay:5.0f];

        }];
    }
    else
    {
        isPlaying = YES;
        
        [self.playingImageView setImage:[UIImage imageNamed:@"NewPause_iPad"]];

        [self.videoPlayerLayer.player play];
        
        [UIView animateWithDuration:0.5f animations:^{
            
            self.playingImageView.alpha = 1.0f;
            
        } completion:^(BOOL finished) {
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                [self.playingImageView setImage:[UIImage imageNamed:@"NewPause_iPhone"]];
            }
            else
            {
                [self performSelector:@selector(hidePlayButton) withObject:nil afterDelay:5.0f];
            }
        }];
    }
}

- (void) hidePlayButton
{
    [UIView animateWithDuration:0.5f animations:^{
        
        self.playingImageView.alpha = 0.0f;
        
    }];
}

- (void) changeSeekSlider
{
    isPlaying = NO;
    
    [self.videoPlayerLayer.player pause];
    
    [self.playingImageView setImage:[UIImage imageNamed:@"NewPlay"]];

    float time = self.seekSlider.value;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.playingImageView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        //[self performSelector:@selector(hidePlayButton) withObject:nil afterDelay:5.0f];
    }];
    
    [self.videoPlayerLayer.player seekToTime:CMTimeMake(time * self.videoTimescale, self.videoTimescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

@end
