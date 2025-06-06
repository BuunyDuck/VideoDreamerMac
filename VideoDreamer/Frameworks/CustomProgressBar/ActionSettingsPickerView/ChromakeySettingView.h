//
//  OutlineView.h
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "Definition.h"
#import "AppDelegate.h"
#import "UIImageExtras.h"
#import "UIColor-Expanded.h"
#import "MSColorPicker.h"

@class BSKeyboardControls;


@protocol ChromakeySettingViewDelegate <NSObject>

- (void)changeChromakeyType:(ChromakeyType) type;
- (void)changeChromakeyColor:(UIColor*) color;
- (void)changeChromakeyTolerance:(CGFloat) tolerance;
- (void)changeChromakeyNoise:(CGFloat) noise;
- (void)changeChromakeyEdges:(CGFloat) edges;
- (void)changeChromakeyOpacity:(CGFloat) opacity;
- (void)didShowColorPickerView;
- (void)didHideColorPickerView;

@end


@interface ChromakeySettingView : UIView<UIScrollViewDelegate,  UITextFieldDelegate>

@property (nonatomic, weak) id<ChromakeySettingViewDelegate> delegate;

@property (nonatomic, assign) ChromakeyType selectedChromaType;
@property (nonatomic, strong) UIColor *selectedChromakeyColor;
@property (nonatomic, assign) CGFloat selectedChromaTolerance;
@property (nonatomic, assign) CGFloat selectedChromaNoise;
@property (nonatomic, assign) CGFloat selectedChromaEdges;
@property (nonatomic, assign) CGFloat selectedChromaOpacity;

@property (nonatomic, strong) UIView* selectedColorView;
@property (nonatomic, strong) UICollectionView* colorsCollectionView;

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* typeLabel;
@property (nonatomic, strong) UILabel* selectedColorLabel;

@property (nonatomic, strong) UISegmentedControl* typeSegmentedControl;
@property (nonatomic, strong) UISlider *toleranceSlider;
@property (nonatomic, strong) UISlider *noiseSlider;
@property (nonatomic, strong) UISlider *edgesSlider;
@property (nonatomic, strong) UISlider *opacitySlider;

@property (nonatomic, strong) UILabel *toleranceLabel;
@property (nonatomic, strong) UILabel *noiseLabel;
@property (nonatomic, strong) UILabel *edgesLabel;
@property (nonatomic, strong) UILabel *opacityLabel;

@property (nonatomic, strong) UILabel *toleranceValueLabel;
@property (nonatomic, strong) UILabel *noiseValueLabel;
@property (nonatomic, strong) UILabel *edgesValueLabel;
@property (nonatomic, strong) UILabel *opacityValueLabel;

- (void)initialize;

@end
