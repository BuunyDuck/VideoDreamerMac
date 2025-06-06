//
//  YJLVideoPlayer.m
//  VideoFrame
//
//  Created by YinjingLi on 12/25/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "YJLVideoPlayer.h"

@implementation YJLVideoPlayer

@synthesize delegate = _delegate;
@synthesize myTitleLabel = _myTitleLabel;
@synthesize videoPlayerView = _videoPlayerView;
@synthesize openInProjectButton = _openInProjectButton;
@synthesize openInProjectImg = _openInProjectImg;


-(void) initFrame:(CGRect) frame
{
    self.frame = frame;
    
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

-(void) freePlayer
{
    [self.videoPlayer.player pause];
    [self.videoPlayer.view removeFromSuperview];
    self.videoPlayer = nil;
}

- (void) dealloc
{

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
#pragma mark - Action Open In Project

-(IBAction)actionOpenInProject:(id)sender
{
    [self.videoPlayer.player pause];
    
    [self freePlayer];
    
    if ([self.delegate respondsToSelector:@selector(openInProject)])
    {
        [self.delegate openInProject];
    }
}


@end
