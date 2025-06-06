//
//  VideoFilterThumbView.m
//  VideoFrame
//
//  Created by Yinjing Li on 02/20/15.
//  Copyright (c) 2015 Yinjing Li. All rights reserved.
//

#import "VideoFilterThumbView.h"
#import "SHKActivityIndicator.h"
#import "Definition.h"
#import "UIImageExtras.h"


@implementation VideoFilterThumbView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        CGRect thumbButtonFrame = CGRectZero;
        CGRect nameLabelFrame = CGRectZero;
        CGFloat fontsize = 1.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            thumbButtonFrame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
            nameLabelFrame = CGRectMake(0.0f, 65.0f, 60.0f, 15.0f);
            fontsize = 9.0f;
        }
        else
        {
            thumbButtonFrame = CGRectMake(0.0f, 0.0f, 90.0f, 90.0f);
            nameLabelFrame = CGRectMake(0.0f, 95.0f, 90.0f, 25.0f);
            fontsize = 15.0f;
        }
        
        self.backgroundColor = [UIColor clearColor];
        
        self.videoThumbImageView = [[UIImageView alloc] initWithFrame:thumbButtonFrame];
        self.videoThumbImageView.backgroundColor = [UIColor clearColor];
        self.videoThumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.videoThumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.videoThumbImageView.layer.borderWidth = 1.0f;
        self.videoThumbImageView.layer.cornerRadius = 5.0f;
        self.videoThumbImageView.layer.masksToBounds = YES;
        self.videoThumbImageView.userInteractionEnabled = YES;
        [self addSubview:self.videoThumbImageView];

        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelected:)];
        selectGesture.delegate = self;
        [self.videoThumbImageView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];

        self.filterNameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
        [self.filterNameLabel setTextColor:[UIColor whiteColor]];
        [self.filterNameLabel setBackgroundColor:[UIColor blackColor]];
        [self.filterNameLabel setFont:[UIFont fontWithName:MYRIADPRO size:fontsize]];
        [self.filterNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.filterNameLabel setMinimumScaleFactor:0.1f];
        self.filterNameLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.filterNameLabel];
        self.filterNameLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.filterNameLabel.layer.borderWidth = 1.0f;
        self.filterNameLabel.layer.cornerRadius = 2.0f;
        self.filterNameLabel.layer.masksToBounds = YES;
    }
    
    return self;
}

-(void) setIndex:(NSInteger) index
{
    self.filterIndex = index;
    
    switch (index)
    {
        case FILTER_NONE: self.filterNameLabel.text = @"Original"; break;
        case FILTER_SATURATION: self.filterNameLabel.text = @"Saturation"; break;
        case FILTER_CONTRAST: self.filterNameLabel.text = @"Contrast"; break;
        case FILTER_BRIGHTNESS: self.filterNameLabel.text = @"Brightness"; break;
        case FILTER_LEVELS: self.filterNameLabel.text = @"Levels"; break;
        case FILTER_EXPOSURE: self.filterNameLabel.text = @"Exposure"; break;
        case FILTER_RGB: self.filterNameLabel.text = @"RGB"; break;
        case FILTER_HUE: self.filterNameLabel.text = @"Hue"; break;
        case FILTER_COLORINVERT: self.filterNameLabel.text = @"Color invert"; break;
        case FILTER_WHITEBALANCE: self.filterNameLabel.text = @"White balance"; break;
        case FILTER_MONOCHROME: self.filterNameLabel.text = @"Monochrome"; break;
        case FILTER_SHARPEN: self.filterNameLabel.text = @"Sharpen"; break;
        case FILTER_UNSHARPMASK: self.filterNameLabel.text = @"Unsharp mask"; break;
        case FILTER_GAMMA: self.filterNameLabel.text = @"Gamma"; break;
        case FILTER_TONECURVE: self.filterNameLabel.text = @"Tone curve"; break;
        case FILTER_HIGHLIGHTSHADOW: self.filterNameLabel.text = @"Highlights and shadows"; break;
        case FILTER_HAZE: self.filterNameLabel.text = @"Haze"; break;
        case FILTER_GRAYSCALE: self.filterNameLabel.text = @"Grayscale"; break;
        case FILTER_SEPIA: self.filterNameLabel.text = @"Sepia tone"; break;
        case FILTER_SKETCH: self.filterNameLabel.text = @"Sketch"; break;
        case FILTER_SMOOTHTOON: self.filterNameLabel.text = @"Smooth toon"; break;
        case FILTER_TILTSHIFT: self.filterNameLabel.text = @"Tilt shift"; break;
        //case FILTER_EMBOSS: self.filterNameLabel.text = @"Emboss"; break;
        case FILTER_POSTERIZE: self.filterNameLabel.text = @"Posterize"; break;
        case FILTER_PINCH: self.filterNameLabel.text = @"Pinch"; break;
        case FILTER_VIGNETTE: self.filterNameLabel.text = @"Vignette"; break;
        case FILTER_GAUSSIAN: self.filterNameLabel.text = @"Gaussian blur"; break;
        case FILTER_GAUSSIAN_SELECTIVE: self.filterNameLabel.text = @"Gaussian selective blur"; break;
        case FILTER_GAUSSIAN_POSITION: self.filterNameLabel.text = @"Gaussian (centered)"; break;
    }
}

-(void) setVideoThumbImage:(UIImage*) image
{
    [self.videoThumbImageView setImage:image];
}

-(void) enableThumbBorder
{
    self.videoThumbImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.videoThumbImageView.layer.borderWidth = 3.0f;

    self.filterNameLabel.layer.borderColor = [UIColor yellowColor].CGColor;
    [self.filterNameLabel setBackgroundColor:[UIColor grayColor]];
}

-(void) disableThumbBorder
{
    self.videoThumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.videoThumbImageView.layer.borderWidth = 1.0f;
    
    self.filterNameLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.filterNameLabel setBackgroundColor:[UIColor blackColor]];
}

-(void)onSelected:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(selectedFilterThumb:)])
    {
        [self.delegate selectedFilterThumb:self.filterIndex];
    }
}


@end


