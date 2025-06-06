//
//  YJLVideoThumbMaker.m
//  VideoFrame
//
//  Created by YinjingLi on 12/22/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "YJLVideoThumbMaker.h"


@implementation YJLVideoThumbMaker

@synthesize delegate = _delegate;
@synthesize myTitleLabel = _myTitleLabel;
@synthesize videoPlayerView = _videoPlayerView;
@synthesize useThisFrameButton = _useThisFrameButton;
@synthesize cancelButton = _cancelButton;


-(void) initFrame:(CGRect) frame
{
    self.frame = frame;
    
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 1.0f;
    
    self.useThisFrameButton.layer.cornerRadius = 5.0f;
    self.cancelButton.layer.cornerRadius = 5.0f;
    self.myTitleLabel.layer.cornerRadius = 5.0f;
    self.myTitleLabel.clipsToBounds = YES;
}

- (void) dealloc
{

}

-(void) freePlayer
{
    [self.videoPlayer.player pause];
    [self.videoPlayer.view removeFromSuperview];
    self.videoPlayer = nil;
}

-(void) initVideo:(PHAsset*) asset
{
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
       
        if ([avAsset isKindOfClass:[AVURLAsset class]]) //normal video
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSURL* url = [(AVURLAsset*)avAsset URL];
                
                if (self.videoPlayer != nil)
                {
                    [self.videoPlayer.player pause];
                    [self.videoPlayer.view removeFromSuperview];
                    self.videoPlayer = nil;
                }
                
                self.videoPlayer = [[AVPlayerViewController alloc] init];
                self.videoPlayer.player = [AVPlayer playerWithURL:url];
                self.videoPlayer.view.frame = self.videoPlayerView.bounds;
                [self.videoPlayerView addSubview:self.videoPlayer.view];
                [self.videoPlayer.player play];
            });
        }
        else  //Slow-Mo video
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                    
                    NSURL* url = [info objectForKey:@"PHImageFileURLKey"];
                    
                    if (url)
                    {
                        if (self.videoPlayer != nil)
                        {
                            [self.videoPlayer.player pause];
                            [self.videoPlayer.view removeFromSuperview];
                            self.videoPlayer = nil;
                        }
                        
                        self.videoPlayer = [[AVPlayerViewController alloc] init];
                        self.videoPlayer.player = [AVPlayer playerWithURL:url];
                        self.videoPlayer.view.frame = self.videoPlayerView.bounds;
                        [self.videoPlayerView addSubview:self.videoPlayer.view];
                        [self.videoPlayer.player play];
                    }
                }];
            });
        }
    }];
}

-(void) initMovie:(NSURL*) url
{
    if (self.videoPlayer != nil)
    {
        [self.videoPlayer.player pause];
        [self.videoPlayer.view removeFromSuperview];
        self.videoPlayer = nil;
    }
    
    self.videoPlayer = [[AVPlayerViewController alloc] init];
    self.videoPlayer.player = [AVPlayer playerWithURL:url];
    self.videoPlayer.view.frame = self.videoPlayerView.bounds;
    [self.videoPlayerView addSubview:self.videoPlayer.view];
    [self.videoPlayer.player play];
}


#pragma mark -
#pragma mark - Actions

-(IBAction)actionUseThisFrame:(id)sender
{
    float time = CMTimeGetSeconds(self.videoPlayer.player.currentTime);

    [self freePlayer];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedFrame:)])
    {
        [self.delegate didSelectedFrame:time];
    }
}

-(IBAction)actionCancel:(id)sender
{
    [self freePlayer];
    
    if ([self.delegate respondsToSelector:@selector(didCancelVideoThumbMaker)])
    {
        [self.delegate didCancelVideoThumbMaker];
    }
}


@end
