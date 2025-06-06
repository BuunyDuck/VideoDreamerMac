//
//  FiltersView.m
//  VideoFrame
//
//  Created by Yinjing Li on 02/20/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "VideoFiltersView.h"

#import <CoreImage/CoreImage.h>

#import "SHKActivityIndicator.h"
#import "Definition.h"
#import "UIImageExtras.h"
#import "YJLActionMenu.h"
#import "VideoFilterCompositor.h"
#import "NSDate+Extension.h"
#import "SceneDelegate.h"

static VideoFiltersView *_sharedInstance = nil;

@interface VideoFiltersView ()

@end

@implementation VideoFiltersView


#pragma mark - 
#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame superView:nil];
}

- (id)initWithFrame:(CGRect)frame superView:(UIView *)superView {
    self = [super initWithFrame:frame];

    if (self)
    {
        _superView = superView;
        
        self.backgroundColor = [UIColor blackColor];
        
        self.filterIndex = 0;
        self.filterValue = 0.5f;
        
        self.context = [[CIContext alloc] init];

        UIEdgeInsets safeAreaInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        if (superView != nil) {
            safeAreaInsets = superView.safeAreaInsets;
        }
        
        CGFloat font_2x = 1.0f;
        CGRect playButtonFrame = CGRectZero;
        CGRect titleLabelFrame = CGRectZero;
        CGRect imageViewFrame = CGRectZero;
        CGRect scrollViewFrame = CGRectZero;
        CGRect originalThumbFrame = CGRectZero;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            thumbWidth = 60.0f;
            thumbHeight = 80.0f;

            font_2x = 1.0f;
            playButtonFrame = CGRectMake(30.0f + safeAreaInsets.left, 10.0f + safeAreaInsets.top, 30.0f, 30.0f);
            titleLabelFrame = CGRectMake(self.frame.size.width / 2.0f - 50.0f, 10.0f + safeAreaInsets.top, 100.0f, 30.0f);
            imageViewFrame = CGRectMake(50.0f + safeAreaInsets.left, 50.0f + safeAreaInsets.top, self.frame.size.width - 100.0f - safeAreaInsets.left - safeAreaInsets.right, self.frame.size.height - 150.0f - safeAreaInsets.top - safeAreaInsets.bottom);
            scrollViewFrame = CGRectMake(15.0f + thumbWidth + safeAreaInsets.left, self.frame.size.height - 90.0f - safeAreaInsets.bottom, self.frame.size.width - 25.0f - thumbWidth - safeAreaInsets.left - safeAreaInsets.right, 80.0f);
            originalThumbFrame = CGRectMake(10.0f + safeAreaInsets.left, self.frame.size.height - 90.0f - safeAreaInsets.bottom, thumbWidth, thumbHeight);
        }
        else
        {
            thumbWidth = 90.0f;
            thumbHeight = 120.0f;

            font_2x = 1.6f;
            playButtonFrame = CGRectMake(50.0f + safeAreaInsets.left, 10.0f + safeAreaInsets.top, 50.0f, 50.0f);
            titleLabelFrame = CGRectMake(self.frame.size.width / 2.0f - 100.0f, 10.0f + safeAreaInsets.top, 200.0f, 50.0f);
            imageViewFrame = CGRectMake(100.0f + safeAreaInsets.left, 70.0f + safeAreaInsets.top, self.frame.size.width - 200.0f - safeAreaInsets.left - safeAreaInsets.right, self.frame.size.height - 210.0f - safeAreaInsets.top - safeAreaInsets.bottom);
            scrollViewFrame = CGRectMake(15.0f + thumbWidth +safeAreaInsets.left, self.frame.size.height - 130.0f - safeAreaInsets.bottom, self.frame.size.width - 25.0f - thumbWidth - safeAreaInsets.left - safeAreaInsets.right, 120.0f);
            originalThumbFrame = CGRectMake(10.0f + safeAreaInsets.left, self.frame.size.height - 130.0f - safeAreaInsets.bottom, thumbWidth, thumbHeight);
        }
        
        
        //title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + safeAreaInsets.left, 10.0f + safeAreaInsets.top, self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
        self.titleLabel.text = NSLocalizedString(@"Choose Filter", nil);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:20];
        else
            self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:25];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];


        //apply button
        self.applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.applyButton setFrame:CGRectMake(self.frame.size.width - 55.0f - safeAreaInsets.right, 10.0f + safeAreaInsets.top, 45.0f, 30.0f)];
        [self.applyButton setTitle:NSLocalizedString(@" Apply ", nil) forState:UIControlStateNormal];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyButton.titleLabel setFont: [UIFont fontWithName:MYRIADPRO size:15]];
        else
            [self.applyButton.titleLabel setFont: [UIFont fontWithName:MYRIADPRO size:20]];
        [self.applyButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [self.applyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        self.applyButton.backgroundColor = [UIColor blackColor];
        self.applyButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.applyButton.layer.borderWidth = 1.0f;
        self.applyButton.layer.cornerRadius = 5.0f;
        [self.applyButton addTarget:self action:@selector(actionShowMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.applyButton];
        
        CGFloat labelWidth = [self.applyButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyButton.titleLabel.font}].width;
        CGFloat labelHeight = [self.applyButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyButton.titleLabel.font}].height;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.applyButton setFrame:CGRectMake(self.frame.size.width - (labelWidth + 15.0f) - safeAreaInsets.right, 10.0f + safeAreaInsets.top, labelWidth + 10.0f, labelHeight + 15.0f)];
        else
            [self.applyButton setFrame:CGRectMake(self.frame.size.width - (labelWidth + 25.0f) - safeAreaInsets.right, 10.0f + safeAreaInsets.top, labelWidth + 20.0f, labelHeight + 20.0f)];

        
        // UIImageView - video player view
        self.filterView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        self.filterView.backgroundColor = [UIColor clearColor];
        self.filterView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.filterView];
        
        
        //play button
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setFrame:playButtonFrame];
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
        [self.playButton setBackgroundColor:[UIColor clearColor]];
        [self.playButton addTarget:self action:@selector(actionPlay:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        
        
        //play seek position label
        self.videoPositionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f + safeAreaInsets.left, titleLabelFrame.origin.y + titleLabelFrame.size.height + 10.0f, 50.0f, 30.0f)];
        self.videoPositionLabel.text = @"0:00";
        self.videoPositionLabel.backgroundColor = [UIColor clearColor];
        self.videoPositionLabel.textAlignment = NSTextAlignmentRight;
        self.videoPositionLabel.font = [UIFont fontWithName:MYRIADPRO size:FONT_SIZE*font_2x];
        self.videoPositionLabel.textColor = [UIColor whiteColor];
        self.videoPositionLabel.shadowColor = [UIColor blackColor];
        self.videoPositionLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.videoPositionLabel];
        
        
        //video length label
        self.videoLegthLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 55.0f - safeAreaInsets.right, titleLabelFrame.origin.y + titleLabelFrame.size.height + 10.0f, 50.0f, 30.0f)];
        self.videoLegthLabel.text = @"0:00";
        self.videoLegthLabel.backgroundColor = [UIColor clearColor];
        self.videoLegthLabel.textAlignment = NSTextAlignmentLeft;
        self.videoLegthLabel.font = [UIFont fontWithName:MYRIADPRO size:FONT_SIZE*font_2x];
        self.videoLegthLabel.textColor = [UIColor whiteColor];
        self.videoLegthLabel.shadowColor = [UIColor blackColor];
        self.videoLegthLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.videoLegthLabel];
        
        
        //play seek slider
        self.seekSlider = [[UISlider alloc] initWithFrame:CGRectMake(60.0f + safeAreaInsets.left, titleLabelFrame.origin.y + titleLabelFrame.size.height + 10.0f, self.frame.size.width - 120.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f)];
        self.seekSlider.backgroundColor = [UIColor clearColor];
        [self.seekSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_min"] forState:UIControlStateNormal];
        [self.seekSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_max"] forState:UIControlStateNormal];
        [self.seekSlider setThumbImage:[UIImage imageNamed:@"slider_thumb_ipad"] forState:UIControlStateNormal];
        [self.seekSlider setValue:0.0f];
        [self.seekSlider addTarget:self action:@selector(changeSeekSlider) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.seekSlider];
        
        
        //filter thumbnails scrollView
        self.filterScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        self.filterScrollView.backgroundColor = [UIColor clearColor];
        [self.filterScrollView setScrollEnabled:YES];
        [self.filterScrollView setShowsHorizontalScrollIndicator:YES];
        [self.filterScrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:self.filterScrollView];
        
        
        //init filter thumbnails
        self.thumbArray = [[NSMutableArray alloc] init];

        VideoFilterThumbView* thumbView = [[VideoFilterThumbView alloc] initWithFrame:originalThumbFrame];
        [thumbView setIndex:0];
        thumbView.delegate = self;
        [self addSubview:thumbView];
        
        [self.thumbArray addObject:thumbView];
        
        for (int i = 1; i <= FILTER_PINCH; i++)
        {
            VideoFilterThumbView* thumbView = [[VideoFilterThumbView alloc] initWithFrame:CGRectMake((5.0f + thumbWidth) * (i - 1), 0.0f, thumbWidth, thumbHeight)];
            [thumbView setIndex:i];
            thumbView.delegate = self;
            [self.filterScrollView addSubview:thumbView];

            [self.thumbArray addObject:thumbView];
        }
        
        [self.filterScrollView setContentSize:CGSizeMake((5.0f + thumbWidth) * (self.thumbArray.count - 1), thumbHeight)];
        
        self.filterSlider = [[UISlider alloc] initWithFrame:CGRectMake(50.0f + safeAreaInsets.left, scrollViewFrame.origin.y - 40.f, self.frame.size.width - 100.0f - safeAreaInsets.left - safeAreaInsets.right, 40.0f)];
        [self.filterSlider setBackgroundColor:[UIColor clearColor]];
        [self.filterSlider setValue:self.filterValue];
        [self.filterSlider addTarget:self action:@selector(filterSliderChanged) forControlEvents:UIControlEventValueChanged];
        [self.filterSlider setMinimumValue:0.1f];
        [self.filterSlider setMaximumValue:1.0f];
        [self addSubview:self.filterSlider];
    }
    
    _sharedInstance = self;
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.applyButton == nil) {
        return;
    }
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (_superView != nil) {
        safeAreaInsets = _superView.safeAreaInsets;
    }
    
    CGRect playButtonFrame = CGRectZero;
    CGRect titleLabelFrame = CGRectZero;
    CGRect imageViewFrame = CGRectZero;
    CGRect scrollViewFrame = CGRectZero;
    CGRect originalThumbFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        thumbWidth = 60.0f;
        thumbHeight = 80.0f;

        playButtonFrame = CGRectMake(30.0f + safeAreaInsets.left, 10.0f + safeAreaInsets.top, 30.0f, 30.0f);
        titleLabelFrame = CGRectMake(self.frame.size.width / 2.0f - 50.0f, 10.0f + safeAreaInsets.top, 100.0f, 30.0f);
        imageViewFrame = CGRectMake(50.0f + safeAreaInsets.left, 50.0f + safeAreaInsets.top, self.frame.size.width - 100.0f - safeAreaInsets.left - safeAreaInsets.right, self.frame.size.height - 150.0f - safeAreaInsets.top - safeAreaInsets.bottom);
        scrollViewFrame = CGRectMake(15.0f + thumbWidth + safeAreaInsets.left, self.frame.size.height - 90.0f - safeAreaInsets.bottom, self.frame.size.width - 25.0f - thumbWidth - safeAreaInsets.left - safeAreaInsets.right, 80.0f);
        originalThumbFrame = CGRectMake(10.0f + safeAreaInsets.left, self.frame.size.height - 90.0f - safeAreaInsets.bottom, thumbWidth, thumbHeight);
    }
    else
    {
        thumbWidth = 90.0f;
        thumbHeight = 120.0f;

        playButtonFrame = CGRectMake(50.0f + safeAreaInsets.left, 10.0f + safeAreaInsets.top, 50.0f, 50.0f);
        titleLabelFrame = CGRectMake(self.frame.size.width / 2.0f - 100.0f, 10.0f + safeAreaInsets.top, 200.0f, 50.0f);
        imageViewFrame = CGRectMake(100.0f + safeAreaInsets.left, 70.0f + safeAreaInsets.top, self.frame.size.width - 200.0f - safeAreaInsets.left - safeAreaInsets.right, self.frame.size.height - 210.0f - safeAreaInsets.top - safeAreaInsets.bottom);
        scrollViewFrame = CGRectMake(15.0f + thumbWidth +safeAreaInsets.left, self.frame.size.height - 130.0f - safeAreaInsets.bottom, self.frame.size.width - 25.0f - thumbWidth - safeAreaInsets.left - safeAreaInsets.right, 120.0f);
        originalThumbFrame = CGRectMake(10.0f + safeAreaInsets.left, self.frame.size.height - 130.0f - safeAreaInsets.bottom, thumbWidth, thumbHeight);
    }
    
    self.titleLabel.frame = CGRectMake(0.0f + safeAreaInsets.left, 10.0f + safeAreaInsets.top, self.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, 30.0f);
    self.applyButton.frame = CGRectMake(self.frame.size.width - 55.0f - safeAreaInsets.right, 10.0f + safeAreaInsets.top, 45.0f, 30.0f);
    
    CGFloat labelWidth = [self.applyButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyButton.titleLabel.font}].width;
    CGFloat labelHeight = [self.applyButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.applyButton.titleLabel.font}].height;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.applyButton.frame = CGRectMake(self.frame.size.width - (labelWidth + 15.0f) - safeAreaInsets.right, 10.0f + safeAreaInsets.top, labelWidth + 10.0f, labelHeight + 15.0f);
    else
        self.applyButton.frame = CGRectMake(self.frame.size.width - (labelWidth + 25.0f) - safeAreaInsets.right, 10.0f + safeAreaInsets.top, labelWidth + 20.0f, labelHeight + 20.0f);
    
    self.filterView.frame = imageViewFrame;
    self.playButton.frame = playButtonFrame;
    self.videoPositionLabel.frame = CGRectMake(5.0f + safeAreaInsets.left, titleLabelFrame.origin.y + titleLabelFrame.size.height + 10.0f, 50.0f, 30.0f);
    self.videoLegthLabel.frame = CGRectMake(self.frame.size.width - 55.0f - safeAreaInsets.right, titleLabelFrame.origin.y + titleLabelFrame.size.height + 10.0f, 50.0f, 30.0f);
    
    //play seek slider
    self.seekSlider.frame = CGRectMake(60.0f + safeAreaInsets.left, titleLabelFrame.origin.y + titleLabelFrame.size.height + 10.0f, self.frame.size.width - 120.0f - safeAreaInsets.left - safeAreaInsets.right, 30.0f);
    self.filterScrollView.frame = scrollViewFrame;

    VideoFilterThumbView* thumbView = self.thumbArray[0];
    thumbView.frame = originalThumbFrame;
    
    self.filterSlider.frame = CGRectMake(50.0f + safeAreaInsets.left, scrollViewFrame.origin.y - 40.f, self.frame.size.width - 100.0f - safeAreaInsets.left - safeAreaInsets.right, 40.0f);
}

+ (VideoFiltersView *)sharedInstance {
    return _sharedInstance;
}

#pragma mark -
#pragma mark - Init Video, Selected Filter

- (void)initParams:(NSURL *)originVideoUrl image:(UIImage *)thumbImage
{
    self.filterIndex = 0;
    self.originalVideoUrl = originVideoUrl;

    self.videoPlayer = nil;
    self.isPlaying = NO;
    
    [self.seekSlider setValue:0.0f];
    [self.videoPositionLabel setText:@"0:00"];
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];

    
    [self checkFilterSlider];

    //init seek slider max value
    AVAsset* asset = [AVAsset assetWithURL:self.originalVideoUrl];
    [self.seekSlider setMaximumValue:CMTimeGetSeconds(asset.duration)];
    
    //video thumbnail image
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:nil];
    self.whiteImage = [[CIImage alloc] initWithImage:[self imageWithColor:[UIColor whiteColor] size:CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef))]];
    CFRelease(imageRef);
    
    //init video length label
    int min = CMTimeGetSeconds(asset.duration) / 60;
    int sec = CMTimeGetSeconds(asset.duration) - (min * 60);
    NSString* string = [NSString stringWithFormat:@"%d:%02d", min, sec];
    [self.videoLegthLabel setText:string];

    //init thumbnails
    CGSize originalThumbSize = thumbImage.size.height > thumbWidth * 2.0f ? CGSizeMake(thumbImage.size.width * thumbWidth * 2.0f / thumbImage.size.height, thumbWidth * 2.0f) : thumbImage.size;
    UIImage* thumbnailImage = [thumbImage rescaleImageToSize:originalThumbSize];

    CIFilter *thumbFilter = nil;

    for (int filterIndex = 0; filterIndex < self.thumbArray.count; filterIndex++)
    {
        VideoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:filterIndex];
        
        switch (filterIndex)
        {
            case FILTER_NONE:
            {
                thumbFilter = nil;
            }; break;
            case FILTER_SEPIA://(0.0, 1.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CISepiaTone"];
                [thumbFilter setValue:@1.0 forKey:kCIInputIntensityKey];
            }; break;
            case FILTER_SATURATION://(0.0, 2.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CIColorControls"];
                [thumbFilter setValue:@2.0 forKey:kCIInputSaturationKey];
            }; break;
            case FILTER_CONTRAST://(1.0, 3.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CIColorControls"];
                [thumbFilter setValue:@2.0 forKey:kCIInputContrastKey];
            }; break;
            case FILTER_BRIGHTNESS://(-0.5, 0.5)
            {
                thumbFilter = [CIFilter filterWithName:@"CIColorControls"];
                [thumbFilter setValue:@0.0 forKey:kCIInputBrightnessKey];
            }; break;
            case FILTER_LEVELS://(0.0, 1.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CIColorClamp"];
                [thumbFilter setValue:[CIVector vectorWithX:0.5 Y:0.0 Z:0.0 W:0.0] forKey:@"inputMinComponents"];
                [thumbFilter setValue:[CIVector vectorWithX:1.0 Y:1.0 Z:1.0 W:1.0] forKey:@"inputMaxComponents"];
            }; break;
            case FILTER_EXPOSURE://(-4.0, 4.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
                [thumbFilter setValue:@1.0 forKey:@"inputEV"];
            }; break;
            case FILTER_RGB://(0.0, 2.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CILinearToSRGBToneCurve"];
            }; break;
            case FILTER_HUE://(0.0, 360.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CIHueAdjust"];
                [thumbFilter setValue:@180.0 forKey:kCIInputAngleKey];
            }; break;
            case FILTER_COLORINVERT:
            {
                thumbFilter = [CIFilter filterWithName:@"CIColorInvert"];
            }; break;
            case FILTER_WHITEBALANCE://(2500, 7500)
            {
                thumbFilter = [CIFilter filterWithName:@"CITemperatureAndTint"];
                [thumbFilter setValue:[CIVector vectorWithX:3000 Y:0] forKey:@"inputNeutral"];
            }; break;
            case FILTER_MONOCHROME://(0.0, 1.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
                [thumbFilter setValue:@1.0 forKey:kCIInputIntensityKey];
            }; break;
            case FILTER_SHARPEN://(-1.0, 4.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CISharpenLuminance"];
                [thumbFilter setValue:@2.0 forKey:kCIInputSharpnessKey];
            }; break;
            case FILTER_UNSHARPMASK://(0.0, 5.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CIUnsharpMask"];
                [thumbFilter setValue:@2.0 forKey:kCIInputIntensityKey];
            }; break;
            case FILTER_GAMMA://(1.0, 3.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CIGammaAdjust"];
                [thumbFilter setValue:@2.0 forKey:@"inputPower"];
            }; break;
            case FILTER_TONECURVE://(0.0, 1.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear"];
                //[thumbFilter setValue:@1.0 forKey:kCIInputBrightnessKey];
                //[(GPUImageToneCurveFilter *)thumbFilter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
                //[(GPUImageToneCurveFilter *)thumbFilter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
            }; break;
            case FILTER_HIGHLIGHTSHADOW://(0.0, 1.0)
            {
                thumbFilter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
                [thumbFilter setValue:@0.5 forKey:@"inputHighlightAmount"];
            }; break;
            case FILTER_HAZE://(-0.2, 0.2)
            {
                thumbFilter = [CIFilter filterWithName:@"CISepiaTone"];
                [thumbFilter setValue:@1.0 forKey:kCIInputIntensityKey];
                //[(GPUImageHazeFilter *)thumbFilter setDistance:0.2];
            }; break;
            case FILTER_GRAYSCALE:
            {
                thumbFilter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
            }; break;
            case FILTER_SKETCH://0.0, 1.0
            {
                //thumbFilter = [CIFilter filterWithName:@"CIEdgeWork"];
                //[thumbFilter setValue:@2.0 forKey:kCIInputRadiusKey];
                thumbFilter = [CIFilter filterWithName:@"CILineOverlay"
                                         keysAndValues:@"inputNRNoiseLevel", @0.072, //0.07, 0~0.1
                                         @"inputNRSharpness", @0.72,//0.71 ,0~2
                                         @"inputEdgeIntensity", @1.0,//1.0 ,0.0~20
                                         @"inputThreshold", @0.10,//0.1 ,0~1
                                         @"inputContrast", @50.0,// 50 ,0.25~200
                                         nil];
            }; break;
            case FILTER_SMOOTHTOON://1.0, 6.0
            {
                thumbFilter = [CIFilter filterWithName:@"CIHeightFieldFromMask"];
                [thumbFilter setValue:@6.0 forKey:kCIInputRadiusKey];
            }; break;
            case FILTER_TILTSHIFT://0.2, 0.8
            {
                thumbFilter = [CIFilter filterWithName:@"CIDepthOfField"];
            }; break;
            /*case FILTER_EMBOSS://0.0, 5.0
            {
                thumbFilter = [CIFilter filterWithName:@"CISepiaTone"];
                [thumbFilter setValue:@1.0 forKey:kCIInputIntensityKey];
            }; break;*/
            case FILTER_POSTERIZE://2.0, 20.0
            {
                thumbFilter = [CIFilter filterWithName:@"CIColorPosterize"];
                [thumbFilter setValue:@6.0 forKey:@"inputLevels"];
            }; break;
            case FILTER_PINCH://0.0, 2.0
            {
                thumbFilter = [CIFilter filterWithName:@"CIPinchDistortion"];
                [thumbFilter setValue:[CIVector vectorWithX:thumbnailImage.size.width / 2.0 Y:thumbnailImage.size.height / 2.0] forKey:kCIInputCenterKey];
                [thumbFilter setValue:@300.0 forKey:kCIInputRadiusKey];
                [thumbFilter setValue:@0.5 forKey:kCIInputScaleKey];
            }; break;
            case FILTER_VIGNETTE://0.5, 0.9
            {
                thumbFilter = [CIFilter filterWithName:@"CIVignette"];
                [thumbFilter setValue:@2.0 forKey:kCIInputRadiusKey];
                [thumbFilter setValue:@1.0 forKey:kCIInputIntensityKey];
            }; break;
            case FILTER_GAUSSIAN://0.0, 24.0
            {
                thumbFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
                [thumbFilter setValue:@6.0 forKey:kCIInputRadiusKey];
            }; break;
            case FILTER_GAUSSIAN_SELECTIVE://0.0, 0.75f
            {
                thumbFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
                [thumbFilter setValue:@16.0 forKey:kCIInputRadiusKey];
            }; break;
            case FILTER_GAUSSIAN_POSITION://0.0, 0.75
            {
                thumbFilter = [CIFilter filterWithName:@"CIGaussianGradient"];
                [thumbFilter setValue:[CIVector vectorWithX:thumbnailImage.size.width / 2.0 Y:thumbnailImage.size.height / 2.0] forKey:kCIInputCenterKey];
                [thumbFilter setValue:@(thumbnailImage.size.width / 3.0) forKey:kCIInputRadiusKey];
                [thumbFilter setValue:[CIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.4] forKey:@"inputColor0"];
                [thumbFilter setValue:[CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] forKey:@"inputColor1"];
            }; break;
            
            default:
                thumbFilter = nil;
            break;
        }

        UIImage *quickFilteredImage = thumbnailImage;
        if (thumbFilter != nil) {
            CIImage *ciImage;
            if (filterIndex == FILTER_GAUSSIAN_POSITION) {
                CIImage *blurImage = thumbFilter.outputImage;
                ciImage = [blurImage imageByCompositingOverImage:[[CIImage alloc] initWithImage:thumbnailImage]];
            } else {
                [thumbFilter setValue:[[CIImage alloc] initWithImage:thumbnailImage] forKey:kCIInputImageKey];
                ciImage = thumbFilter.outputImage;
                if (filterIndex == FILTER_SKETCH) {
                    ciImage = [ciImage imageByCompositingOverImage:[[CIImage alloc] initWithImage:[self imageWithColor:[UIColor whiteColor] size:thumbnailImage.size]]];
                }

            }
            CGImageRef cgImage = [self.context createCGImage:ciImage fromRect:ciImage.extent];
            if (cgImage != nil) {
                quickFilteredImage = [UIImage imageWithCGImage:cgImage];
            }
        }
        [thumbView setVideoThumbImage:quickFilteredImage];
        [thumbView disableThumbBorder];
        
        thumbFilter = nil;
        quickFilteredImage = nil;
    }

    VideoFilterThumbView *newThumbView = [self.thumbArray objectAtIndex:self.filterIndex];
    [newThumbView enableThumbBorder];

    [self previewSelectedFilter];
}


#pragma mark -
#pragma mark - FilterThumbViewDelegate

- (void)selectedFilterThumb:(NSInteger)index
{
    if (index != self.filterIndex)
    {
        //remove old selected filter
        VideoFilterThumbView* oldThumbView = [self.thumbArray objectAtIndex:self.filterIndex];
        [oldThumbView disableThumbBorder];
        
        self.filterIndex = index;
        self.filterValue = 0.5f;
        
        VideoFilterThumbView* newThumbView = [self.thumbArray objectAtIndex:index];
        [newThumbView enableThumbBorder];
        
        [self checkFilterSlider];
        
        [self previewSelectedFilter];
    }
}


#pragma mark -
#pragma mark - setup Filter


- (CIFilter *)setupFilterWithSize:(CGSize)size
{
    CIFilter *thumbFilter = nil;

    switch (self.filterIndex)
    {
        case FILTER_NONE:
        {
            thumbFilter = nil;
        }; break;
        case FILTER_SEPIA://(0.0, 1.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CISepiaTone"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputIntensityKey];
        }; break;
        case FILTER_SATURATION://(0.0, 2.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CIColorControls"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputSaturationKey];
        }; break;
        case FILTER_CONTRAST://(1.0, 3.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CIColorControls"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputContrastKey];
        }; break;
        case FILTER_BRIGHTNESS://(-0.5, 0.5)
        {
            thumbFilter = [CIFilter filterWithName:@"CIColorControls"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputBrightnessKey];
        }; break;
        case FILTER_LEVELS://(0.0, 1.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CIColorClamp"];
            [thumbFilter setValue:[CIVector vectorWithX:self.filterValue Y:0.0 Z:0.0 W:0.0] forKey:@"inputMinComponents"];
            [thumbFilter setValue:[CIVector vectorWithX:self.filterValue Y:1.0 Z:1.0 W:1.0] forKey:@"inputMaxComponents"];
        }; break;
        case FILTER_EXPOSURE://(-4.0, 4.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CIExposureAdjust"];
            [thumbFilter setValue:@(self.filterValue) forKey:@"inputEV"];
        }; break;
        case FILTER_RGB://(0.0, 2.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CILinearToSRGBToneCurve"];
            //[(GPUImageRGBFilter *)tempFilter setGreen:filterValue];
        }; break;
        case FILTER_HUE://(0.0, 360.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CIHueAdjust"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputAngleKey];
        }; break;
        case FILTER_COLORINVERT:
        {
            thumbFilter = [CIFilter filterWithName:@"CIColorInvert"];
        }; break;
        case FILTER_WHITEBALANCE://(2500, 7500)
        {
            thumbFilter = [CIFilter filterWithName:@"CITemperatureAndTint"];
            [thumbFilter setValue:[CIVector vectorWithX:self.filterValue Y:0] forKey:@"inputNeutral"];
        }; break;
        case FILTER_MONOCHROME://(0.0, 1.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputIntensityKey];
        }; break;
        case FILTER_SHARPEN://(-1.0, 4.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CISharpenLuminance"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputSharpnessKey];
        }; break;
        case FILTER_UNSHARPMASK://(0.0, 5.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CIUnsharpMask"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputIntensityKey];
        }; break;
        case FILTER_GAMMA://(1.0, 3.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CIGammaAdjust"];
            [thumbFilter setValue:@(self.filterValue) forKey:@"inputPower"];
        }; break;
        case FILTER_TONECURVE://(0.0, 1.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CISRGBToneCurveToLinear"];
            //[(GPUImageToneCurveFilter *)tempFilter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
            //[(GPUImageToneCurveFilter *)tempFilter setBlueControlPoints:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)], [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)], [NSValue valueWithCGPoint:CGPointMake(1.0, 0.75)], nil]];
        }; break;
        case FILTER_HIGHLIGHTSHADOW://(0.0, 1.0)
        {
            thumbFilter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
            [thumbFilter setValue:@(self.filterValue) forKey:@"inputHighlightAmount"];
        }; break;
        case FILTER_HAZE://(-0.2, 0.2)
        {
            thumbFilter = [CIFilter filterWithName:@"CISepiaTone"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputIntensityKey];
        }; break;
        case FILTER_GRAYSCALE:
        {
            thumbFilter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
        }; break;
        case FILTER_SKETCH://1.0, 3.0
        {
            //thumbFilter = [CIFilter filterWithName:@"CIEdgeWork"];
            //[thumbFilter setValue:@2.0 forKey:kCIInputRadiusKey];
            thumbFilter = [CIFilter filterWithName:@"CILineOverlay"
                                     keysAndValues:@"inputNRNoiseLevel", @0.1, //0.07, 0~0.1
                                     @"inputNRSharpness", @1.0,//0.71 ,0~2
                                     @"inputEdgeIntensity", @1.0,//1.0 ,0.0~20
                                     @"inputThreshold", @0.2,//0.1 ,0~1
                                     @"inputContrast", @50.0,// 50 ,0.25~200
                                     nil];
        }; break;
        case FILTER_SMOOTHTOON://1.0, 6.0
        {
            thumbFilter = [CIFilter filterWithName:@"CIHeightFieldFromMask"];
            [thumbFilter setValue:@6.0 forKey:kCIInputRadiusKey];
        }; break;
        case FILTER_TILTSHIFT://0.2, 0.8
        {
            thumbFilter = [CIFilter filterWithName:@"CIDepthOfField"];
            //[(GPUImageTiltShiftFilter *)tempFilter setTopFocusLevel:0.4];
            //[(GPUImageTiltShiftFilter *)tempFilter setBottomFocusLevel:0.6];
            //[(GPUImageTiltShiftFilter *)tempFilter setFocusFallOffRate:filterValue];
        }; break;
        /*case FILTER_EMBOSS://0.0, 5.0
        {
            thumbFilter = [CIFilter filterWithName:@"CISepiaTone"];
            [thumbFilter setValue:@1.0 forKey:kCIInputIntensityKey];
            //[(GPUImageEmbossFilter *)tempFilter setIntensity:filterValue];
        }; break;*/
        case FILTER_POSTERIZE://2.0, 20.0
        {
            thumbFilter = [CIFilter filterWithName:@"CIColorPosterize"];
            [thumbFilter setValue:@(self.filterValue) forKey:@"inputLevels"];
        }; break;
        case FILTER_PINCH://0.0, 2.0
        {
            thumbFilter = [CIFilter filterWithName:@"CIPinchDistortion"];
            [thumbFilter setValue:[CIVector vectorWithX:size.width / 2.0 Y:size.height / 2.0] forKey:kCIInputCenterKey];
            [thumbFilter setValue:@(self.filterValue * 300.0) forKey:kCIInputRadiusKey];
            [thumbFilter setValue:@0.5 forKey:kCIInputScaleKey];
        }; break;
        case FILTER_VIGNETTE://0.5, 0.9
        {
            thumbFilter = [CIFilter filterWithName:@"CIVignette"];
            [thumbFilter setValue:@(self.filterValue) forKey:kCIInputRadiusKey];
            [thumbFilter setValue:@1.0 forKey:kCIInputIntensityKey];
        }; break;
        case FILTER_GAUSSIAN://0.0, 24.0
        {
            thumbFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [thumbFilter setValue:@6.0 forKey:kCIInputRadiusKey];
        }; break;
        case FILTER_GAUSSIAN_SELECTIVE://0.0, 40.0f
        {
            thumbFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
            [thumbFilter setValue:@16.0 forKey:kCIInputRadiusKey];
        }; break;
        case FILTER_GAUSSIAN_POSITION://0.0, 0.75
        {
            thumbFilter = [CIFilter filterWithName:@"CIGaussianGradient"];
            [thumbFilter setValue:[CIVector vectorWithX:size.width / 2.0 Y:size.height / 2.0] forKey:kCIInputCenterKey];
            [thumbFilter setValue:@(size.width / self.filterValue) forKey:kCIInputRadiusKey];
            [thumbFilter setValue:[CIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:0.4] forKey:@"inputColor0"];
            [thumbFilter setValue:[CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] forKey:@"inputColor1"];
        }; break;
    }

    return thumbFilter;
}

- (void)checkFilterSlider
{
    self.filterSlider.hidden = NO;
    
    switch (self.filterIndex)
    {
        case FILTER_NONE:
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case FILTER_SEPIA://(0.0, 1.0)
        {
            self.filterValue = 1.0;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_SATURATION://(0.0, 2.0)
        {
            self.filterValue = 1.8f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:2.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_CONTRAST://(1.0, 3.0)
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:1.0f];
            [self.filterSlider setMaximumValue:3.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_BRIGHTNESS://(-0.5, 0.5)
        {
            self.filterValue = -0.0f;
            
            [self.filterSlider setMinimumValue:-0.5f];
            [self.filterSlider setMaximumValue:0.5f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_LEVELS://(0.0, 1.0)
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_EXPOSURE://(-4.0, 4.0)
        {
            self.filterValue = 1.0f;
            
            [self.filterSlider setMinimumValue:-4.0f];
            [self.filterSlider setMaximumValue:4.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_RGB://(0.0, 2.0)
        {
            self.filterValue = 1.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:2.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_HUE://(0.0, 360.0)
        {
            self.filterValue = 180.0f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:360.0f];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_COLORINVERT:
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case FILTER_WHITEBALANCE://(2500, 7500)
        {
            self.filterValue = 3000.0f;
            
            [self.filterSlider setMinimumValue:2500];
            [self.filterSlider setMaximumValue:7500];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_MONOCHROME://(0.0, 1.0)
        {
            self.filterValue = 1.0;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:1.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_SHARPEN://(-1.0, 4.0)
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:-1.0];
            [self.filterSlider setMaximumValue:4.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_UNSHARPMASK://(0.0, 5.0)
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:5.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_GAMMA://(1.0, 3.0)
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:1.0];
            [self.filterSlider setMaximumValue:3.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_TONECURVE://(0.0, 1.0)
        {
            self.filterValue = 0.5;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:1.0];
            [self.filterSlider setValue:self.filterValue];
            self.filterSlider.hidden = YES;
        }; break;
        case FILTER_HIGHLIGHTSHADOW://(0.0, 1.0)
        {
            self.filterValue = 0.5;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:1.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_HAZE://(-0.2, 0.2)
        {
            self.filterValue = 0.2;
            
            [self.filterSlider setMinimumValue:-0.2];
            [self.filterSlider setMaximumValue:0.2];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_GRAYSCALE:
        {
            self.filterValue = 0.5f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:1.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case FILTER_SKETCH://1.0, 3.0
        {
            self.filterValue = 2.0;
            
            [self.filterSlider setMinimumValue:1.0];
            [self.filterSlider setMaximumValue:3.0];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case FILTER_SMOOTHTOON://1.0, 6.0
        {
            self.filterValue = 1.0;
            
            [self.filterSlider setMinimumValue:1.0];
            [self.filterSlider setMaximumValue:6.0];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case FILTER_TILTSHIFT://0.2, 0.8
        {
            self.filterValue = 0.2;
            
            [self.filterSlider setMinimumValue:0.2];
            [self.filterSlider setMaximumValue:0.8];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        /*case FILTER_EMBOSS://0.0, 5.0
        {
            self.filterValue = 1.0;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:5.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;*/
        case FILTER_POSTERIZE://1.0, 20.0
        {
            self.filterValue = 6.0f;
            
            [self.filterSlider setMinimumValue:2.0];
            [self.filterSlider setMaximumValue:20.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_PINCH://0.0, 2.0
        {
            self.filterValue = 1.0;
            
            [self.filterSlider setMinimumValue:0.0];
            [self.filterSlider setMaximumValue:2.0];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_VIGNETTE://0.5, 0.9
        {
            self.filterValue = 0.75;
            
            [self.filterSlider setMinimumValue:0.5];
            [self.filterSlider setMaximumValue:0.9];
            [self.filterSlider setValue:self.filterValue];
        }; break;
        case FILTER_GAUSSIAN://0.0, 24.0
        {
            self.filterValue = 2.0f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:24.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case FILTER_GAUSSIAN_SELECTIVE://0.0, 40.0
        {
            self.filterValue = 20.0f;
            
            [self.filterSlider setMinimumValue:0.0f];
            [self.filterSlider setMaximumValue:40.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
        case FILTER_GAUSSIAN_POSITION://2.0, 5.0
        {
            self.filterValue = 3.0f;
            
            [self.filterSlider setMinimumValue:2.0f];
            [self.filterSlider setMaximumValue:5.0f];
            [self.filterSlider setValue:self.filterValue];
            
            self.filterSlider.hidden = YES;
        }; break;
    }
}


#pragma mark -
#pragma mark - Video Play, Seek Actions

- (void)actionPlay:(id)sender
{
    if (self.isPlaying)
    {
        self.isPlaying = NO;
        
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
        
        [self.videoPlayer pause];
    }
    else
    {
        self.isPlaying = YES;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateSelected];
        }
        else
        {
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateSelected];
        }
        
        [self.videoPlayer play];
    }
}

- (void)changeSeekSlider
{
    float time = self.seekSlider.value;
    
    self.isPlaying = NO;
    
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
    
    [self.videoPlayer pause];
    [self.videoPlayer seekToTime:CMTimeMake(time * self.videoPlayer.currentItem.asset.duration.timescale, self.videoPlayer.currentItem.asset.duration.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


#pragma mark -
#pragma mark - Menu Apparence

- (void)actionShowMenu
{
    NSArray *menuItems = nil;
    
    menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Cancel", nil)
                            image:nil
                           target:self
                           action:@selector(cancelVideoFilter)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Apply Filter", nil)
                            image:nil
                           target:self
                           action:@selector(applyVideoFilter)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Save to Album", nil)
                            image:nil
                           target:self
                           action:@selector(didSaveFilteredVideoToAlbum)],
      ];
    
    [YJLActionMenu showMenuInView:self
                         fromRect:self.applyButton.frame
                        menuItems:menuItems isWhiteBG:NO];
}


#pragma mark -
#pragma mark - Cancel, Apply, Save Actions

- (void)cancelVideoFilter
{
    [self.videoPlayer pause];
    [self.videoPlayer removeTimeObserver:self.observer];
    self.playerItem = nil;
    self.videoPlayer = nil;
    
    for (int i = 0; i < self.thumbArray.count; i++)
    {
        VideoFilterThumbView* thumbView = [self.thumbArray objectAtIndex:i];
        [thumbView setVideoThumbImage:nil];
    }

    if ([self.delegate respondsToSelector:@selector(didCancelVideoFilterUI)])
    {
        [self.delegate didCancelVideoFilterUI];
    }
}

- (void)retrievingProgress
{
    if (self.assetExportSession == nil) {
        return;
    }
    
    [self.hudProgressView setProgress:self.assetExportSession.progress];
    
    if (self.assetExportSession.progress >= 1.0f)
    {
        [self.hudProgressView hide];
        [self.timer invalidate];
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [[SHKActivityIndicator currentIndicator] hide];
    
    [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Saved", nil) message:NSLocalizedString(@"You can look this video on the Camera Roll.", nil) okHandler:nil];
}


#pragma mark -
#pragma mark - Preview Processing!!!

- (void)previewSelectedFilter
{
    if (!self.playerItem)
    {
        AVAsset* asset = [AVAsset assetWithURL:self.originalVideoUrl];
        self.playerItem = [[AVPlayerItem alloc] initWithURL:self.originalVideoUrl];
        self.playerItem.videoComposition = [AVVideoComposition videoCompositionWithAsset:asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
            CIImage *sourceImage = request.sourceImage;
            CGSize size = sourceImage.extent.size;
            CIFilter *filter = [self setupFilterWithSize:sourceImage.extent.size];
            if (filter != nil) {
                if (self.filterIndex == FILTER_GAUSSIAN_POSITION) {
                    CIImage *blurImage = filter.outputImage;
                    sourceImage = [blurImage imageByCompositingOverImage:sourceImage];
                } else {
                    [filter setValue:sourceImage forKey:kCIInputImageKey];
                    sourceImage = filter.outputImage;
                    if (self.filterIndex == FILTER_SKETCH) {
                        sourceImage = [sourceImage imageByCompositingOverImage:self.whiteImage];
                    }
                }
            }
            CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, size.width / sourceImage.extent.size.width, size.height / sourceImage.extent.size.height);
            transform = CGAffineTransformTranslate(transform, -sourceImage.extent.origin.x, -sourceImage.extent.origin.y);
            sourceImage = [sourceImage imageByApplyingTransform:transform];
            [request finishWithImage:sourceImage context:self.context];
        }];
        self.videoPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
        self.playerLayer.frame = self.filterView.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.filterView.layer addSublayer:self.playerLayer];

        CGFloat duration = asset.duration.value / 500;

        __weak typeof (self) weakSelf = self;

        self.observer = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(MAX(1, duration), asset.duration.timescale) queue:/*dispatch_get_current_queue()*/ dispatch_get_main_queue() usingBlock:^(CMTime time) {

            if (CMTimeCompare(time, asset.duration) >= 0)
            {
                weakSelf.isPlaying = NO;
                [weakSelf.seekSlider setValue:0.0f];
                [weakSelf.videoPositionLabel setText:@"0:00"];
                [weakSelf.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
                [weakSelf.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];
                [weakSelf.videoPlayer pause];
                [weakSelf.videoPlayer seekToTime:kCMTimeZero];
            }
            else
            {
                CGFloat currentTime = CMTimeGetSeconds(time);
                [weakSelf.seekSlider setValue:currentTime];
                int min = currentTime / 60;
                int sec = currentTime - (min * 60);
                [weakSelf.videoPositionLabel setText:[NSString stringWithFormat:@"%d:%02d", min, sec]];
            }
        }];
    }

    if (self.videoPlayer.rate != 1.0f)
    {
        self.isPlaying = YES;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateSelected];
        }
        else
        {
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
            [self.playButton setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateSelected];
        }

        [self.videoPlayer play];
    }
}


#pragma mark -
#pragma mark -

-(AVAssetExportSession *) filterVideo:(void(^)(NSURL *outputURL, NSError *error))completionHandler {
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    NSMutableArray *layerInstructions = [NSMutableArray array];
    AVMutableCompositionTrack *videoTrack = nil;
    
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:self.originalVideoUrl options:nil];
    AVAssetTrack *assetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize renderSize = assetTrack.naturalSize;
    CGAffineTransform transform = assetTrack.preferredTransform;
    if ((transform.b == 1 && transform.c == -1) || (transform.b == -1 && transform.c == 1))
        renderSize = CGSizeMake(renderSize.height, renderSize.width);
    else if ((renderSize.width == transform.tx && renderSize.height == transform.ty) || (transform.tx == 0 && transform.ty == 0))
        renderSize = CGSizeMake(renderSize.width, renderSize.height);
    else
        renderSize = CGSizeMake(renderSize.height, renderSize.width);
    
    // duration
    CMTime trimDuration = kCMTimeZero;
    if (videoAsset != nil)
    {
        // VIDEO TRACK
        videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        NSArray *arrayVideoDataSources = [NSArray arrayWithArray:[videoAsset tracksWithMediaType:AVMediaTypeVideo]];
        NSError *error = nil;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                            ofTrack:arrayVideoDataSources[0]
                             atTime:kCMTimeZero
                              error:&error];
        if (error)
        {
            NSLog(@"Insertion error: %@", error);
            completionHandler(nil, error);
            return nil;
        }
        
        // AUDIO TRACK
        NSArray *arrayAudioDataSources = [NSArray arrayWithArray:[videoAsset tracksWithMediaType:AVMediaTypeAudio]];
        if (arrayAudioDataSources.count > 0)
        {
            AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            error = nil;
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                ofTrack:arrayAudioDataSources[0]
                                 atTime:kCMTimeZero
                                  error:&error];
            if (error)
            {
                NSLog(@"Insertion error: %@", error);
                completionHandler(nil, error);
                return nil;
            }
        }
        
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        assetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        [layerInstruction setTransform:CGAffineTransformConcat(assetTrack.preferredTransform, transform) atTime:kCMTimeZero];
        
        [layerInstruction setOpacity:1.0 atTime:kCMTimeZero];
        [layerInstructions addObject:layerInstruction];
    }
    
    AVMutableVideoCompositionInstruction * mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    mainInstruction.layerInstructions = layerInstructions;
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = renderSize;
    mainCompositionInst.customVideoCompositorClass = [VideoFilterCompositor class];
    
    NSURL *videoOutputURL = [[NSDate date] tempFilePathWithProjectName:gstrCurrentProjectName categoryName:@"TrimVideo" extension:@"m4v"];
    
    AVAssetExportSession *exporter = [AVAssetExportSession exportSessionWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = videoOutputURL;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.videoComposition = mainCompositionInst;
    exporter.timeRange = CMTimeRangeMake(kCMTimeZero, trimDuration);
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
         BOOL success = YES;
         switch ([exporter status]) {
             case AVAssetExportSessionStatusCompleted:
                 success = YES;
                 break;
             case AVAssetExportSessionStatusFailed:
                 success = NO;
                 NSLog(@"input videos - failed: %@", [[exporter error] localizedDescription]);
                 break;
             case AVAssetExportSessionStatusCancelled:
                 success = NO;
                 NSLog(@"input videos - canceled");
                 break;
             default:
                 success = NO;
                 break;
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             if (completionHandler == nil)
                 return;
             if (success == YES) {
                 completionHandler(videoOutputURL, nil);
             } else {
                 completionHandler(nil, exporter.error);
             }
         });
     }];
    
    return exporter;
}

- (void)applyVideoFilter
{
    [self.videoPlayer pause];
    [self.videoPlayer removeTimeObserver:self.observer];
    self.playerItem = nil;
    self.videoPlayer = nil;

    self.isPlaying = NO;
    [self.seekSlider setValue:0.0f];
    [self.videoPositionLabel setText:@"0:00"];
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];

    if (self.filterIndex == 0)
    {
        if ([self.delegate respondsToSelector:@selector(didApplyVideoFilter:)])
        {
            [self.delegate didApplyVideoFilter:self.originalVideoUrl];
        }

        return;
    }

    __weak typeof (self) weakSelf = self;
    self.assetExportSession = [self filterVideo:^(NSURL *outputURL, NSError *error) {
        if (outputURL != nil) {
            [weakSelf.hudProgressView hide];
            [weakSelf.timer invalidate];

            for (int i = 0; i < weakSelf.thumbArray.count; i++)
            {
                VideoFilterThumbView* thumbView = [weakSelf.thumbArray objectAtIndex:i];
                [thumbView setVideoThumbImage:nil];
            }

            if ([weakSelf.delegate respondsToSelector:@selector(didApplyVideoFilter:)])
            {
                [weakSelf.delegate didApplyVideoFilter:outputURL];
            }
        } else {
            [weakSelf.hudProgressView hide];
            [weakSelf.timer invalidate];

            [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Failed", nil) message:error.description okHandler:nil];

            [weakSelf previewSelectedFilter];
        }
    }];

    //progress view
    self.hudProgressView = [[ATMHud alloc] initWithDelegate:self];
    self.hudProgressView.delegate = self;
    [self addSubview:self.hudProgressView.view];
    self.hudProgressView.view.center = self.filterView.center;
    [self.hudProgressView setCaption:NSLocalizedString(@"Apply filter...", nil)];
    [self.hudProgressView setProgress:0.08f];
    [self.hudProgressView show];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f
                                                  target:self
                                                selector:@selector(retrievingProgress)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)didSaveFilteredVideoToAlbum
{
    if (self.filterIndex == 0)
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Saving...", nil)) isLock:YES];

        NSString* videoPath = [self.originalVideoUrl path];

        UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);

        return;
    }

    [self.videoPlayer pause];
    [self.videoPlayer removeTimeObserver:self.observer];
    self.playerItem = nil;
    self.videoPlayer = nil;

    self.isPlaying = NO;
    [self.seekSlider setValue:0.0f];
    [self.videoPositionLabel setText:@"0:00"];
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateSelected];

    __weak typeof (self) weakSelf = self;
    self.assetExportSession = [self filterVideo:^(NSURL *outputURL, NSError *error) {
        if (outputURL != nil) {
            [weakSelf.hudProgressView hide];
            [weakSelf.timer invalidate];

            [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Saving...", nil)) isLock:YES];

            UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);

            [weakSelf previewSelectedFilter];
        } else {
            [weakSelf.hudProgressView hide];
            [weakSelf.timer invalidate];

            [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Failed", nil) message:error.description okHandler:nil];

            [weakSelf previewSelectedFilter];
        }
    }];
    
    //progress view
    self.hudProgressView = [[ATMHud alloc] initWithDelegate:self];
    self.hudProgressView.delegate = self;
    [self addSubview:self.hudProgressView.view];
    self.hudProgressView.view.center = self.filterView.center;
    [self.hudProgressView setCaption:NSLocalizedString(@"Apply filter...", nil)];
    [self.hudProgressView setProgress:0.08f];
    [self.hudProgressView show];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f
                                                  target:self
                                                selector:@selector(retrievingProgress)
                                                userInfo:nil
                                                 repeats:YES];
}


#pragma mark - 
#pragma mark -

- (void)filterSliderChanged
{
    self.filterValue = self.filterSlider.value;

    [self previewSelectedFilter];
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
