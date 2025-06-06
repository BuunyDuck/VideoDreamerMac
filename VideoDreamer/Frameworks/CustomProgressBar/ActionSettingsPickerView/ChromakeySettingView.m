//
//  OutlineView.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "ChromakeySettingView.h"
#import <QuartzCore/QuartzCore.h>
#import "MSColorPicker.h"
#import "MSColorSelectionView.h"
#import "CustomModalView.h"
#import "ColorCollectionCell.h"

@interface ChromakeySettingView () <MSColorViewDelegate, CustomModalViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) MSColorSelectionView *colorSelectionView;
@property (nonatomic, strong) CustomModalView *customModalView;

@end

@implementation ChromakeySettingView


#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectedChromakeyColor = [UIColor greenColor];
        self.selectedChromaType = ChromakeyTypeStandard;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 20.0f, frame.size.width - 40.0f, 20.0f)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = NSLocalizedString(@"Chromakey Color", nil);
        self.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:14.0f];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.1f;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.titleLabel];
        
        self.typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 56.0f, 80.0f, 20.0f)];
        self.typeLabel.backgroundColor = [UIColor clearColor];
        self.typeLabel.textAlignment = NSTextAlignmentLeft;
        self.typeLabel.text = NSLocalizedString(@"Type:", nil);
        self.typeLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.typeLabel.adjustsFontSizeToFitWidth = YES;
        self.typeLabel.minimumScaleFactor = 0.1f;
        self.typeLabel.numberOfLines = 0;
        self.typeLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.typeLabel];
        
        self.typeSegmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(90.0f, 50.0f, 160.0f, 30.0f)];
        [self.typeSegmentedControl insertSegmentWithTitle:@"Standard" atIndex:0 animated:NO];
        [self.typeSegmentedControl insertSegmentWithTitle:@"Custom" atIndex:1 animated:NO];
        [self.typeSegmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:MYRIADPRO size:12.0f], NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
        [self.typeSegmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:MYRIADPRO size:12.0f], NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateHighlighted];
        [self.typeSegmentedControl setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:MYRIADPRO size:12.0f], NSForegroundColorAttributeName: [UIColor blackColor]} forState:UIControlStateSelected];
        [self.typeSegmentedControl addTarget:self action:@selector(typeSegmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.typeSegmentedControl];
        
        self.selectedColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 102.0f, 100.0f, 20.0f)];
        self.selectedColorLabel.backgroundColor = [UIColor clearColor];
        self.selectedColorLabel.textAlignment = NSTextAlignmentLeft;
        self.selectedColorLabel.text = NSLocalizedString(@"Selected Color:", nil);
        self.selectedColorLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.selectedColorLabel.adjustsFontSizeToFitWidth = YES;
        self.selectedColorLabel.minimumScaleFactor = 0.1f;
        self.selectedColorLabel.numberOfLines = 0;
        self.selectedColorLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.selectedColorLabel];
        
        self.selectedColorView = [[UIView alloc] initWithFrame:CGRectMake(110.5f, 96.0f, 30.0f, 30.0f)];
        self.selectedColorView.backgroundColor = [UIColor greenColor];
        self.selectedColorView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.selectedColorView.layer.borderWidth = 1.0f;
        [self addSubview:self.selectedColorView];
        
        //self.colorsCollectionView = [[UICollectionView]]
        
        UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        colorButton.frame = self.selectedColorView.bounds;
        [colorButton addTarget:self action:@selector(actionColorPicker:) forControlEvents:UIControlEventTouchUpInside];
        [self.selectedColorView addSubview:colorButton];
        
        CGFloat y = 72.0 + 24.0 + 46.0;
        self.toleranceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, 60.0f, 24.0f)];
        self.toleranceLabel.backgroundColor = [UIColor clearColor];
        self.toleranceLabel.textAlignment = NSTextAlignmentLeft;
        self.toleranceLabel.text = NSLocalizedString(@"Tolerance:", nil);
        self.toleranceLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.toleranceLabel.adjustsFontSizeToFitWidth = YES;
        self.toleranceLabel.minimumScaleFactor = 0.2f;
        self.toleranceLabel.numberOfLines = 0;
        self.toleranceLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.toleranceLabel];
        
        self.toleranceSlider = [[UISlider alloc] initWithFrame:CGRectMake(90.0f, y - 4.0, frame.size.width - 160.0, 32.0)];
        self.toleranceSlider.minimumValue = 0.0;
        self.toleranceSlider.maximumValue = 1.0;
        [self.toleranceSlider addTarget:self action:@selector(settingsSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.toleranceSlider];
        
        self.toleranceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 60.0, y, 40.0f, 24.0f)];
        self.toleranceValueLabel.backgroundColor = [UIColor clearColor];
        self.toleranceValueLabel.textAlignment = NSTextAlignmentLeft;
        self.toleranceValueLabel.text = @"0";
        self.toleranceValueLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.toleranceValueLabel.minimumScaleFactor = 0.2f;
        self.toleranceValueLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.toleranceValueLabel];
        y += 40.0;
        
        self.noiseLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, 60.0f, 24.0f)];
        self.noiseLabel.backgroundColor = [UIColor clearColor];
        self.noiseLabel.textAlignment = NSTextAlignmentLeft;
        self.noiseLabel.text = NSLocalizedString(@"Noise:", nil);
        self.noiseLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.noiseLabel.adjustsFontSizeToFitWidth = YES;
        self.noiseLabel.minimumScaleFactor = 0.2f;
        self.noiseLabel.numberOfLines = 0;
        self.noiseLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.noiseLabel];
        
        self.noiseSlider = [[UISlider alloc] initWithFrame:CGRectMake(90.0f, y - 4.0, frame.size.width - 160.0, 32.0)];
        self.noiseSlider.minimumValue = 0.0;
        self.noiseSlider.maximumValue = 1.0;
        [self.noiseSlider addTarget:self action:@selector(settingsSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.noiseSlider];
        
        self.noiseValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 60.0, y, 40.0f, 24.0f)];
        self.noiseValueLabel.backgroundColor = [UIColor clearColor];
        self.noiseValueLabel.textAlignment = NSTextAlignmentLeft;
        self.noiseValueLabel.text = @"0";
        self.noiseValueLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.noiseValueLabel.minimumScaleFactor = 0.2f;
        self.noiseValueLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.noiseValueLabel];
        y += 40.0;
        
        /*self.edgesLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, 60.0f, 24.0f)];
        self.edgesLabel.backgroundColor = [UIColor clearColor];
        self.edgesLabel.textAlignment = NSTextAlignmentLeft;
        self.edgesLabel.text = NSLocalizedString(@"Edges:", nil);
        self.edgesLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.edgesLabel.adjustsFontSizeToFitWidth = YES;
        self.edgesLabel.minimumScaleFactor = 0.2f;
        self.edgesLabel.numberOfLines = 0;
        self.edgesLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.edgesLabel];
        
        self.edgesSlider = [[UISlider alloc] initWithFrame:CGRectMake(90.0f, y - 4.0, frame.size.width - 160.0, 32.0)];
        self.edgesSlider.minimumValue = 0.0;
        self.edgesSlider.maximumValue = 1.0;
        [self.edgesSlider addTarget:self action:@selector(settingsSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.edgesSlider];
        
        self.edgesValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 60.0, y, 40.0f, 24.0f)];
        self.edgesValueLabel.backgroundColor = [UIColor clearColor];
        self.edgesValueLabel.textAlignment = NSTextAlignmentLeft;
        self.edgesValueLabel.text = @"0";
        self.edgesValueLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.edgesValueLabel.minimumScaleFactor = 0.2f;
        self.edgesValueLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.edgesValueLabel];
        y += 40.0;
        */
        self.opacityLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, y, 60.0f, 24.0f)];
        self.opacityLabel.backgroundColor = [UIColor clearColor];
        self.opacityLabel.textAlignment = NSTextAlignmentLeft;
        self.opacityLabel.text = NSLocalizedString(@"Opacity:", nil);
        self.opacityLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.opacityLabel.adjustsFontSizeToFitWidth = YES;
        self.opacityLabel.minimumScaleFactor = 0.2f;
        self.opacityLabel.numberOfLines = 0;
        self.opacityLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.opacityLabel];
        
        self.opacitySlider = [[UISlider alloc] initWithFrame:CGRectMake(90.0f, y - 4.0, frame.size.width - 160.0, 32.0)];
        self.opacitySlider.minimumValue = 0.0;
        self.opacitySlider.maximumValue = 1.0;
        [self.opacitySlider addTarget:self action:@selector(settingsSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.opacitySlider];
        
        self.opacityValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 60.0, y, 40.0f, 24.0f)];
        self.opacityValueLabel.backgroundColor = [UIColor clearColor];
        self.opacityValueLabel.textAlignment = NSTextAlignmentLeft;
        self.opacityValueLabel.text = @"0";
        self.opacityValueLabel.font = [UIFont fontWithName:MYRIADPRO size:12.0f];
        self.opacityValueLabel.minimumScaleFactor = 0.2f;
        self.opacityValueLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.opacityValueLabel];
        y += 64.0;
    }
    
    return self;
}

- (void)actionColorPicker:(id)sender {
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (self.colorSelectionView == nil) {
        
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
            CGSize screenWidth = [UIScreen mainScreen].bounds.size;
            CGRect menuFrame = CGRectMake(0.0f, 20.0f, (screenWidth.width / 1.5), (screenWidth.height-40));
            
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                menuFrame = CGRectMake(0.0f, 0.0f, 320.0f, 426.0f);
            }
            self.colorSelectionView = [[MSColorSelectionView alloc] initWithFrame:menuFrame];
        } else {
            CGRect menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 406.0f);
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                menuFrame = CGRectMake(0.0f, 0.0f, 320.0f, 426.0f);
            }
            self.colorSelectionView = [[MSColorSelectionView alloc] initWithFrame:menuFrame];
        }
        
        [self.colorSelectionView setSelectedIndex:1 animated:YES];
        self.colorSelectionView.delegate = self;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.colorSelectionView isCenter:YES];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
    
    self.colorSelectionView.color = self.selectedChromakeyColor;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didShowColorPickerView)]) {
        [self.delegate didShowColorPickerView];
    }
}

- (void)initialize
{
    self.typeSegmentedControl.selectedSegmentIndex = self.selectedChromaType;
    [self.selectedColorView setBackgroundColor:self.selectedChromakeyColor];
    
    self.toleranceSlider.value = self.selectedChromaTolerance;
    self.noiseSlider.value = self.selectedChromaNoise;
    self.edgesSlider.value = self.selectedChromaEdges;
    self.opacitySlider.value = self.selectedChromaOpacity;
    self.toleranceValueLabel.text = [NSString stringWithFormat:@"%d", (int)(self.selectedChromaTolerance * 100.0)];
    self.noiseValueLabel.text = [NSString stringWithFormat:@"%d", (int)(self.selectedChromaNoise * 100.0)];
    self.edgesValueLabel.text = [NSString stringWithFormat:@"%d", (int)(self.selectedChromaEdges * 100.0)];
    self.opacityValueLabel.text = [NSString stringWithFormat:@"%d", (int)(self.selectedChromaOpacity * 100.0)];
}

- (void)changeColor
{
    if ([self.delegate respondsToSelector:@selector(changeChromakeyColor:)])
    {
        [self.delegate changeChromakeyColor:self.selectedChromakeyColor];
    }
}

#pragma mark - Settings slider
- (IBAction)settingsSliderChanged:(UISlider *)sender {
    if (sender == self.toleranceSlider) {
        if ([self.delegate respondsToSelector:@selector(changeChromakeyTolerance:)])
        {
            [self.delegate changeChromakeyTolerance:self.toleranceSlider.value];
            self.toleranceValueLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 100.0)];
        }
    } else if (sender == self.noiseSlider) {
        if ([self.delegate respondsToSelector:@selector(changeChromakeyNoise:)])
        {
            [self.delegate changeChromakeyNoise:self.noiseSlider.value];
            self.noiseValueLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 100.0)];
        }
    } else if (sender == self.edgesSlider) {
        if ([self.delegate respondsToSelector:@selector(changeChromakeyEdges:)])
        {
            [self.delegate changeChromakeyEdges:self.edgesSlider.value];
            self.edgesValueLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 100.0)];
        }
    } else if (sender == self.opacitySlider) {
        if ([self.delegate respondsToSelector:@selector(changeChromakeyOpacity:)])
        {
            [self.delegate changeChromakeyOpacity:self.opacitySlider.value];
            self.opacityValueLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 100.0)];
        }
    }
}

- (IBAction)typeSegmentedControlChanged:(UISegmentedControl *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeChromakeyType:)]) {
        [self.delegate changeChromakeyType:(ChromakeyType)sender.selectedSegmentIndex];
    }
}

#pragma mark - MSColorViewDelegate
- (void)colorView:(id<MSColorView>)colorView didChangeColor:(UIColor *)color withUpdate:(BOOL)update{
    //NSLog(@"%@", color);
    //CGFloat hue;
    //CGFloat saturation;
    //CGFloat brightness;
    //CGFloat alpha;
    //[color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    //NSLog(@"%f, %f, %f, %f", hue, saturation, brightness, alpha);
    self.selectedColorView.backgroundColor = color;
    self.selectedChromakeyColor = color;
    if (update)
        [self changeColor];
}

#pragma mark - CustomModalViewDelegate
- (void)didClosedCustomModalView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHideColorPickerView)]) {
        [self.delegate didHideColorPickerView];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ColorCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCollectionCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDelegateFlowLayout

@end
