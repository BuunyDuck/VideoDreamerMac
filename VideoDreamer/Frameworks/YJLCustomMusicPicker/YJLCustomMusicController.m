//
//  YJLCustomMusicController.m
//  VideoFrame
//
//  Created by Yinjing Li on 5/12/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "YJLCustomMusicController.h"
#import "YJLMusicAlbumsViewController.h"
#import "SHKActivityIndicator.h"

@interface YJLCustomMusicController ()

@end

@implementation YJLCustomMusicController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - YJLMusicAlbumsViewControllerDelegate
- (void)musicAlbumsViewControllerDidCancel
{
    if ([self.customMusicDelegate respondsToSelector:@selector(musicPickerControllerDidCancel:)])
    {
        [self.customMusicDelegate musicPickerControllerDidCancel:self];
    }
}

- (void)musicSelected:(NSURL*) assetUrl
{
    self.assetUrl = assetUrl;

    if ([self.customMusicDelegate respondsToSelector:@selector(musicPickerControllerDidSelected:asset:)]) {

        [self.customMusicDelegate musicPickerControllerDidSelected:self asset:self.assetUrl];
    }
}


@end
