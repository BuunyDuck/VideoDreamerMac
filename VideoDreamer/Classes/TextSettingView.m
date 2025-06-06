//
//  TextSettingView.m
//  VideoFrame
//
//  Created by Yinjing Li on 3/6/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//


#import "TextSettingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TextSettingView


#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        self.isBold = NO;
        self.isItalic = NO;
        self.isUnderline = NO;
        self.isStroke = NO;
        
        CGFloat rFontSize = 0.0f;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            rFontSize = 10.0f;
        else
            rFontSize = 14.0f;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //font name table view
            self.fontNameTableView = [[UITableView alloc] initWithFrame:CGRectMake(-8.0f, 0.0f, self.frame.size.width*0.4f, 76.0f) style:UITableViewStylePlain];
            self.fontNameTableView.backgroundColor = [UIColor clearColor];
            [self addSubview:self.fontNameTableView];
            self.fontNameTableView.delegate = self;
            self.fontNameTableView.dataSource = self;
            [self.fontNameTableView reloadData];
            self.fontNameTableView.layer.borderWidth = 1.0f;
            self.fontNameTableView.layer.borderColor = [UIColor whiteColor].CGColor;

            //alignment view
            self.alignmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 75.0f, self.frame.size.width, 35)];
            self.alignmentView.backgroundColor = [UIColor clearColor];
            self.alignmentView.layer.borderWidth = 1.0f;
            self.alignmentView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.alignmentView];
            
            self.alignmentLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.alignmentLeftButton.frame = CGRectMake(3.5f, 5.0f, 25.0f, 25.0f);
            [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment"] forState:UIControlStateNormal];
            [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment_Hightlight"] forState:UIControlStateHighlighted];
            [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment_Hightlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.alignmentLeftButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.alignmentLeftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.alignmentLeftButton.backgroundColor = [UIColor clearColor];
            self.alignmentLeftButton.layer.masksToBounds = YES;
            self.alignmentLeftButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.alignmentLeftButton.layer.borderWidth = 0.5f;
            self.alignmentLeftButton.layer.cornerRadius = 0.5f;
            [self.alignmentLeftButton addTarget:self action:@selector(alignmentChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.alignmentLeftButton];
            self.alignmentLeftButton.tag = 1;
            
            self.alignmentCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.alignmentCenterButton.frame = CGRectMake(31.5f, 5.0f, 25.0f, 25.0f);
            [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment"] forState:UIControlStateNormal];
            [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment_Hightlight"] forState:UIControlStateHighlighted];
            [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment_Hightlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.alignmentCenterButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.alignmentCenterButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.alignmentCenterButton.backgroundColor = [UIColor clearColor];
            self.alignmentCenterButton.layer.masksToBounds = YES;
            self.alignmentCenterButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.alignmentCenterButton.layer.borderWidth = 0.5f;
            self.alignmentCenterButton.layer.cornerRadius = 0.5f;
            [self.alignmentCenterButton addTarget:self action:@selector(alignmentChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.alignmentCenterButton];
            self.alignmentCenterButton.tag = 2;

            self.alignmentRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.alignmentRightButton.frame = CGRectMake(59.5f, 5.0f, 25.0f, 25.0f);
            [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment"] forState:UIControlStateNormal];
            [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment_Highlight"] forState:UIControlStateHighlighted];
            [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.alignmentRightButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.alignmentRightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.alignmentRightButton.backgroundColor = [UIColor clearColor];
            self.alignmentRightButton.layer.masksToBounds = YES;
            self.alignmentRightButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.alignmentRightButton.layer.borderWidth = 0.5f;
            self.alignmentRightButton.layer.cornerRadius = 0.5f;
            [self.alignmentRightButton addTarget:self action:@selector(alignmentChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.alignmentRightButton];
            self.alignmentRightButton.tag = 3;
            
            self.alignmentJustifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.alignmentJustifyButton.frame = CGRectMake(87.5f, 5.0f, 25.0f, 25.0f);
            [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment"] forState:UIControlStateNormal];
            [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment_Highlight"] forState:UIControlStateHighlighted];
            [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.alignmentJustifyButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.alignmentJustifyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.alignmentJustifyButton.backgroundColor = [UIColor clearColor];
            self.alignmentJustifyButton.layer.masksToBounds = YES;
            self.alignmentJustifyButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.alignmentJustifyButton.layer.borderWidth = 0.5f;
            self.alignmentJustifyButton.layer.cornerRadius = 0.5f;
            [self.alignmentJustifyButton addTarget:self action:@selector(alignmentChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.alignmentJustifyButton];
            self.alignmentJustifyButton.tag = 4;

            self.boldButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.boldButton.frame = CGRectMake(115.5f, 5.0f, 25.0f, 25.0f);
            [self.boldButton setImage:[UIImage imageNamed:@"Bold"] forState:UIControlStateNormal];
            [self.boldButton setImage:[UIImage imageNamed:@"Bold_Hightlight"] forState:UIControlStateHighlighted];
            [self.boldButton setImage:[UIImage imageNamed:@"Bold_Hightlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.boldButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.boldButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.boldButton.backgroundColor = [UIColor clearColor];
            self.boldButton.layer.masksToBounds = YES;
            self.boldButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.boldButton.layer.borderWidth = 0.5f;
            self.boldButton.layer.cornerRadius = 0.5f;
            [self.boldButton addTarget:self action:@selector(boldChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.boldButton];

            self.italicButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.italicButton.frame = CGRectMake(143.5f, 5.0f, 25.0f, 25.0f);
            [self.italicButton setImage:[UIImage imageNamed:@"Italic"] forState:UIControlStateNormal];
            [self.italicButton setImage:[UIImage imageNamed:@"Italic_Highlight"] forState:UIControlStateHighlighted];
            [self.italicButton setImage:[UIImage imageNamed:@"Italic_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.italicButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.italicButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.italicButton.backgroundColor = [UIColor clearColor];
            self.italicButton.layer.masksToBounds = YES;
            self.italicButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.italicButton.layer.borderWidth = 0.5f;
            self.italicButton.layer.cornerRadius = 0.5f;
            [self.italicButton addTarget:self action:@selector(italicChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.italicButton];
            
            self.underlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.underlineButton.frame = CGRectMake(171.5f, 5.0f, 25.0f, 25.0f);
            [self.underlineButton setImage:[UIImage imageNamed:@"Underline"] forState:UIControlStateNormal];
            [self.underlineButton setImage:[UIImage imageNamed:@"Underline_Highlight"] forState:UIControlStateHighlighted];
            [self.underlineButton setImage:[UIImage imageNamed:@"Underline_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.underlineButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.underlineButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.underlineButton.backgroundColor = [UIColor clearColor];
            self.underlineButton.layer.masksToBounds = YES;
            self.underlineButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.underlineButton.layer.borderWidth = 0.5f;
            self.underlineButton.layer.cornerRadius = 0.5f;
            [self.underlineButton addTarget:self action:@selector(underlineChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.underlineButton];

            self.strokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.strokeButton.frame = CGRectMake(199.5f, 5.0f, 25.0f, 25.0f);
            [self.strokeButton setImage:[UIImage imageNamed:@"Stroke"] forState:UIControlStateNormal];
            [self.strokeButton setImage:[UIImage imageNamed:@"Stroke_Highlight"] forState:UIControlStateHighlighted];
            [self.strokeButton setImage:[UIImage imageNamed:@"Stroke_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.strokeButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.strokeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.strokeButton.backgroundColor = [UIColor clearColor];
            self.strokeButton.layer.masksToBounds = YES;
            self.strokeButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.strokeButton.layer.borderWidth = 0.5f;
            self.strokeButton.layer.cornerRadius = 0.5f;
            [self.strokeButton addTarget:self action:@selector(strokeChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.strokeButton];
            
            //font size
            self.fontSizeView = [[UIView alloc] initWithFrame:CGRectMake(0, 109, self.frame.size.width, 38)];
            self.fontSizeView.backgroundColor = [UIColor clearColor];
            self.fontSizeView.layer.borderWidth = 1.0f;
            self.fontSizeView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.fontSizeView];
            
            self.fontSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width, 15.0f)];
            self.fontSizeLabel.backgroundColor = [UIColor clearColor];
            self.fontSizeLabel.textAlignment = NSTextAlignmentLeft;
            
            NSString* strText = NSLocalizedString(@"Font Size", nil);
            strText = [strText stringByAppendingString:[NSString stringWithFormat:@" : %dpt", (int)self.textFontSize]];
            
            self.fontSizeLabel.text = strText;
            self.fontSizeLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.fontSizeLabel.adjustsFontSizeToFitWidth = YES;
            self.fontSizeLabel.minimumScaleFactor = 0.1f;
            self.fontSizeLabel.numberOfLines = 0;
            self.fontSizeLabel.textColor = [UIColor whiteColor];
            [self.fontSizeView addSubview:self.fontSizeLabel];
            
            UIImage *minImage = [UIImage imageNamed:@"slider_min"];
            UIImage *maxImage = [UIImage imageNamed:@"slider_max"];
            UIImage *tumbImage = nil;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                tumbImage= [UIImage imageNamed:@"slider_thumb"];
            else
                tumbImage= [UIImage imageNamed:@"slider_thumb_ipad"];
            
            minImage=[minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            maxImage=[maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];

            self.fontSizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(18, 15, self.frame.size.width - 50, 20)];
            [self.fontSizeSlider setBackgroundColor:[UIColor clearColor]];
            [self.fontSizeSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
            [self.fontSizeSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
            [self.fontSizeSlider setThumbImage:tumbImage forState:UIControlStateNormal];
            [self.fontSizeSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
            [self.fontSizeSlider setMinimumValue:5.0f];
            [self.fontSizeSlider setMaximumValue:500.0f];
            [self.fontSizeSlider addTarget:self action:@selector(textFontSizeChanged:) forControlEvents:UIControlEventValueChanged];
            [self.fontSizeView addSubview:self.fontSizeSlider];
            [self.fontSizeSlider setValue:self.textFontSize];

            UILabel* minLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 20, 20)];
            minLabel.backgroundColor = [UIColor clearColor];
            minLabel.textAlignment = NSTextAlignmentCenter;
            minLabel.text = @"5pt";
            minLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            minLabel.adjustsFontSizeToFitWidth = YES;
            minLabel.minimumScaleFactor = 0.1f;
            minLabel.numberOfLines = 0;
            minLabel.textColor = [UIColor whiteColor];
            [self.fontSizeView addSubview:minLabel];
            
            UILabel* maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-30, 15, 28, 20)];
            maxLabel.backgroundColor = [UIColor clearColor];
            maxLabel.textAlignment = NSTextAlignmentCenter;
            maxLabel.text = @"500pt";
            maxLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            maxLabel.adjustsFontSizeToFitWidth = YES;
            maxLabel.minimumScaleFactor = 0.1f;
            maxLabel.numberOfLines = 0;
            maxLabel.textColor = [UIColor whiteColor];
            [self.fontSizeView addSubview:maxLabel];

            //text color picker
            self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 147.0f, self.frame.size.width-5.0f, 20.0f)];
            self.colorLabel.backgroundColor = [UIColor clearColor];
            self.colorLabel.textAlignment = NSTextAlignmentLeft;
            self.colorLabel.text = NSLocalizedString(@"Color", nil);
            self.colorLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.colorLabel.adjustsFontSizeToFitWidth = YES;
            self.colorLabel.minimumScaleFactor = 0.1f;
            self.colorLabel.numberOfLines = 0;
            self.colorLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.colorLabel];

            self.colorPickerView = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (self.frame.size.width - 60), self.frame.size.width, self.frame.size.width - 60)];
            self.colorPickerView.selectedColor = self.textColor;
            self.colorPickerView.oldColor = self.textColor;
            [self.colorPickerView addTarget:self action:@selector(textColorPickerChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.colorPickerView];
            
            //leftbox view
            self.leftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-30, 30, 30)];
            self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBox"]];
            self.leftBoxView.userInteractionEnabled = YES;
            [self addSubview:self.leftBoxView];
            
            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(textMenuMove:)];
            [moveGesture setMinimumNumberOfTouches:1];
            [moveGesture setMaximumNumberOfTouches:1];
            moveGesture.delegate = self;
            [self.leftBoxView addGestureRecognizer:moveGesture];
        }
        else
        {
            self.fontNameTableView = [[UITableView alloc] initWithFrame:CGRectMake(-8.0f, 0.0f, self.frame.size.width*0.4f, 116.0f) style:UITableViewStylePlain];
            self.fontNameTableView.backgroundColor = [UIColor clearColor];
            [self addSubview:self.fontNameTableView];
            self.fontNameTableView.delegate = self;
            self.fontNameTableView.dataSource = self;
            [self.fontNameTableView reloadData];
            self.fontNameTableView.layer.borderWidth = 1.0f;
            self.fontNameTableView.layer.borderColor = [UIColor whiteColor].CGColor;

            //alignment view
            self.alignmentView = [[UIView alloc] initWithFrame:CGRectMake(0, 115.0f, self.frame.size.width, 50.0f)];
            self.alignmentView.backgroundColor = [UIColor clearColor];
            self.alignmentView.layer.borderWidth = 1.0f;
            self.alignmentView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.alignmentView];
            
            self.alignmentLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.alignmentLeftButton.frame = CGRectMake(2.5f, 5.0f, 40.0f, 40.0f);
            [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment"] forState:UIControlStateNormal];
            [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment_Hightlight"] forState:UIControlStateHighlighted];
            [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment_Hightlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.alignmentLeftButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.alignmentLeftButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.alignmentLeftButton.backgroundColor = [UIColor clearColor];
            self.alignmentLeftButton.layer.masksToBounds = YES;
            self.alignmentLeftButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.alignmentLeftButton.layer.borderWidth = 0.5f;
            self.alignmentLeftButton.layer.cornerRadius = 0.5f;
            [self.alignmentLeftButton addTarget:self action:@selector(alignmentChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.alignmentLeftButton];
            self.alignmentLeftButton.tag = 1;
            
            self.alignmentCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.alignmentCenterButton.frame = CGRectMake(45.0f, 5.0f, 40.0f, 40.0f);
            [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment"] forState:UIControlStateNormal];
            [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment_Hightlight"] forState:UIControlStateHighlighted];
            [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment_Hightlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.alignmentCenterButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.alignmentCenterButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.alignmentCenterButton.backgroundColor = [UIColor clearColor];
            self.alignmentCenterButton.layer.masksToBounds = YES;
            self.alignmentCenterButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.alignmentCenterButton.layer.borderWidth = 0.5f;
            self.alignmentCenterButton.layer.cornerRadius = 0.5f;
            [self.alignmentCenterButton addTarget:self action:@selector(alignmentChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.alignmentCenterButton];
            self.alignmentCenterButton.tag = 2;
            
            self.alignmentRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.alignmentRightButton.frame = CGRectMake(87.5f, 5.0f, 40.0f, 40.0f);
            [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment"] forState:UIControlStateNormal];
            [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment_Highlight"] forState:UIControlStateHighlighted];
            [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.alignmentRightButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.alignmentRightButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.alignmentRightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.alignmentRightButton.backgroundColor = [UIColor clearColor];
            self.alignmentRightButton.layer.masksToBounds = YES;
            self.alignmentRightButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.alignmentRightButton.layer.borderWidth = 0.5f;
            self.alignmentRightButton.layer.cornerRadius = 0.5f;
            [self.alignmentRightButton addTarget:self action:@selector(alignmentChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.alignmentRightButton];
            self.alignmentRightButton.tag = 3;
            
            self.alignmentJustifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.alignmentJustifyButton.frame = CGRectMake(130.5f, 5.0f, 40.0f, 40.0f);
            [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment"] forState:UIControlStateNormal];
            [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment_Highlight"] forState:UIControlStateHighlighted];
            [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.alignmentJustifyButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            self.alignmentJustifyButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [self.alignmentJustifyButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.alignmentJustifyButton.backgroundColor = [UIColor clearColor];
            self.alignmentJustifyButton.layer.masksToBounds = YES;
            self.alignmentJustifyButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.alignmentJustifyButton.layer.borderWidth = 0.5f;
            self.alignmentJustifyButton.layer.cornerRadius = 0.5f;
            [self.alignmentJustifyButton addTarget:self action:@selector(alignmentChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.alignmentJustifyButton];
            self.alignmentJustifyButton.tag = 4;
            
            self.boldButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.boldButton.frame = CGRectMake(172.0f, 5.0f, 40.0f, 40.0f);
            [self.boldButton setImage:[UIImage imageNamed:@"Bold"] forState:UIControlStateNormal];
            [self.boldButton setImage:[UIImage imageNamed:@"Bold_Hightlight"] forState:UIControlStateHighlighted];
            [self.boldButton setImage:[UIImage imageNamed:@"Bold_Hightlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.boldButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.boldButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.boldButton.backgroundColor = [UIColor clearColor];
            self.boldButton.layer.masksToBounds = YES;
            self.boldButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.boldButton.layer.borderWidth = 0.5f;
            self.boldButton.layer.cornerRadius = 0.5f;
            [self.boldButton addTarget:self action:@selector(boldChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.boldButton];
            
            self.italicButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.italicButton.frame = CGRectMake(215.5f, 5.0f, 40.0f, 40.0f);
            [self.italicButton setImage:[UIImage imageNamed:@"Italic"] forState:UIControlStateNormal];
            [self.italicButton setImage:[UIImage imageNamed:@"Italic_Highlight"] forState:UIControlStateHighlighted];
            [self.italicButton setImage:[UIImage imageNamed:@"Italic_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.italicButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.italicButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.italicButton.backgroundColor = [UIColor clearColor];
            self.italicButton.layer.masksToBounds = YES;
            self.italicButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.italicButton.layer.borderWidth = 0.5f;
            self.italicButton.layer.cornerRadius = 0.5f;
            [self.italicButton addTarget:self action:@selector(italicChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.italicButton];
            
            self.underlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.underlineButton.frame = CGRectMake(257.0f, 5.0f, 40.0f, 40.0f);
            [self.underlineButton setImage:[UIImage imageNamed:@"Underline"] forState:UIControlStateNormal];
            [self.underlineButton setImage:[UIImage imageNamed:@"Underline_Highlight"] forState:UIControlStateHighlighted];
            [self.underlineButton setImage:[UIImage imageNamed:@"Underline_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.underlineButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.underlineButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.underlineButton.backgroundColor = [UIColor clearColor];
            self.underlineButton.layer.masksToBounds = YES;
            self.underlineButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.underlineButton.layer.borderWidth = 0.5f;
            self.underlineButton.layer.cornerRadius = 0.5f;
            [self.underlineButton addTarget:self action:@selector(underlineChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.underlineButton];

            self.strokeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.strokeButton.frame = CGRectMake(299.5f, 5.0f, 40.0f, 40.0f);
            [self.strokeButton setImage:[UIImage imageNamed:@"Stroke"] forState:UIControlStateNormal];
            [self.strokeButton setImage:[UIImage imageNamed:@"Stroke_Highlight"] forState:UIControlStateHighlighted];
            [self.strokeButton setImage:[UIImage imageNamed:@"Stroke_Highlight"] forState:UIControlStateSelected|UIControlStateHighlighted];
            [self.strokeButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            [self.strokeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            self.strokeButton.backgroundColor = [UIColor clearColor];
            self.strokeButton.layer.masksToBounds = YES;
            self.strokeButton.layer.borderColor = [UIColor whiteColor].CGColor;
            self.strokeButton.layer.borderWidth = 0.5f;
            self.strokeButton.layer.cornerRadius = 0.5f;
            [self.strokeButton addTarget:self action:@selector(strokeChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self.alignmentView addSubview:self.strokeButton];

            //font size
            self.fontSizeView = [[UIView alloc] initWithFrame:CGRectMake(0, 164, self.frame.size.width, 50)];
            self.fontSizeView.backgroundColor = [UIColor clearColor];
            self.fontSizeView.layer.borderWidth = 1.0f;
            self.fontSizeView.layer.borderColor = [UIColor whiteColor].CGColor;
            [self addSubview:self.fontSizeView];
            
            self.fontSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width, 20.0f)];
            self.fontSizeLabel.backgroundColor = [UIColor clearColor];
            self.fontSizeLabel.textAlignment = NSTextAlignmentLeft;
            
            NSString* strText = NSLocalizedString(@"Font Size", nil);
            strText = [strText stringByAppendingString:[NSString stringWithFormat:@" : %dpt", (int)self.textFontSize]];

            self.fontSizeLabel.text = strText;
            self.fontSizeLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.fontSizeLabel.adjustsFontSizeToFitWidth = YES;
            self.fontSizeLabel.minimumScaleFactor = 0.1f;
            self.fontSizeLabel.numberOfLines = 0;
            self.fontSizeLabel.textColor = [UIColor whiteColor];
            [self.fontSizeView addSubview:self.fontSizeLabel];
            
            UIImage *minImage = [UIImage imageNamed:@"slider_min"];
            UIImage *maxImage = [UIImage imageNamed:@"slider_max"];
            UIImage *tumbImage = nil;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                tumbImage= [UIImage imageNamed:@"slider_thumb"];
            else
                tumbImage= [UIImage imageNamed:@"slider_thumb_ipad"];
            
            minImage=[minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
            maxImage=[maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];

            self.fontSizeSlider = [[UISlider alloc] initWithFrame:CGRectMake(35, 25, self.frame.size.width - 80, 20)];
            [self.fontSizeSlider setBackgroundColor:[UIColor clearColor]];
            [self.fontSizeSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
            [self.fontSizeSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
            [self.fontSizeSlider setThumbImage:tumbImage forState:UIControlStateNormal];
            [self.fontSizeSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
            [self.fontSizeSlider setMinimumValue:5.0f];
            [self.fontSizeSlider setMaximumValue:500.0f];
            [self.fontSizeSlider setValue:self.textFontSize];
            [self.fontSizeSlider addTarget:self action:@selector(textFontSizeChanged:) forControlEvents:UIControlEventValueChanged];
            [self.fontSizeView addSubview:self.fontSizeSlider];
            
            UILabel* minLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 30, 20)];
            minLabel.backgroundColor = [UIColor clearColor];
            minLabel.textAlignment = NSTextAlignmentCenter;
            minLabel.text = @"5pt";
            minLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            minLabel.adjustsFontSizeToFitWidth = YES;
            minLabel.minimumScaleFactor = 0.1f;
            minLabel.numberOfLines = 0;
            minLabel.textColor = [UIColor whiteColor];
            [self.fontSizeView addSubview:minLabel];

            UILabel* maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-40, 25, 38, 20)];
            maxLabel.backgroundColor = [UIColor clearColor];
            maxLabel.textAlignment = NSTextAlignmentCenter;
            maxLabel.text = @"500pt";
            maxLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            maxLabel.adjustsFontSizeToFitWidth = YES;
            maxLabel.minimumScaleFactor = 0.1f;
            maxLabel.numberOfLines = 0;
            maxLabel.textColor = [UIColor whiteColor];
            [self.fontSizeView addSubview:maxLabel];

            //text color picker
            self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 215.0f, self.frame.size.width-5.0f, 20.0f)];
            self.colorLabel.backgroundColor = [UIColor clearColor];
            self.colorLabel.textAlignment = NSTextAlignmentLeft;
            self.colorLabel.text = NSLocalizedString(@"Color", nil);
            self.colorLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize];
            self.colorLabel.adjustsFontSizeToFitWidth = YES;
            self.colorLabel.minimumScaleFactor = 0.1f;
            self.colorLabel.numberOfLines = 0;
            self.colorLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.colorLabel];
            
            self.colorPickerView = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, self.frame.size.height - (self.frame.size.width - 70), self.frame.size.width, self.frame.size.width - 70)];
            self.colorPickerView.selectedColor = self.textColor;
            self.colorPickerView.oldColor = self.textColor;
            [self.colorPickerView addTarget:self action:@selector(textColorPickerChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:self.colorPickerView];
            
            //leftbox view
            self.leftBoxView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-40, 40, 40)];
            self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leftBox"]];
            self.leftBoxView.userInteractionEnabled = YES;
            [self addSubview:self.leftBoxView];
            
            UIPanGestureRecognizer* moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(textMenuMove:)];
            [moveGesture setMinimumNumberOfTouches:1];
            [moveGesture setMaximumNumberOfTouches:1];
            moveGesture.delegate = self;
            [self.leftBoxView addGestureRecognizer:moveGesture];
       }
        
        CGFloat originY = 20.0f;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            originY = 15.0f;
        
        //color preview
        self.colorPreviewView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 5.0f, self.frame.size.width*0.2f, originY)];
        self.colorPreviewView.backgroundColor = [UIColor whiteColor];
        self.colorPreviewView.userInteractionEnabled = YES;
        [self addSubview:self.colorPreviewView];
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionColorPreviewToRecent:)];
        selectGesture.delegate = self;
        [self.colorPreviewView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];
        
        self.addLabel = [[UILabel alloc] initWithFrame:self.colorPreviewView.bounds];
        self.addLabel.backgroundColor = [UIColor clearColor];
        self.addLabel.text = @"+";
        self.addLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize*1.2f];
        self.addLabel.adjustsFontSizeToFitWidth = YES;
        self.addLabel.minimumScaleFactor = 0.1f;
        self.addLabel.textAlignment = NSTextAlignmentCenter;
        self.addLabel.textColor = [UIColor whiteColor];
        self.addLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.addLabel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
        self.addLabel.layer.shadowOpacity = 1.0f;
        [self.colorPreviewView addSubview:self.addLabel];
        
        self.xLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.colorPreviewView.frame.origin.x + self.colorPreviewView.frame.size.width + 5.0f, 5.0f, 10.0f, originY)];
        self.xLabel.backgroundColor = [UIColor whiteColor];
        self.xLabel.text = @"#";
        self.xLabel.font = [UIFont fontWithName:MYRIADPRO size:rFontSize*1.2f];
        self.xLabel.adjustsFontSizeToFitWidth = YES;
        self.xLabel.minimumScaleFactor = 0.1f;
        self.xLabel.textAlignment = NSTextAlignmentRight;
        self.xLabel.textColor = [UIColor blackColor];
        [self addSubview:self.xLabel];
        
        self.hexTextField = [[UITextField alloc] initWithFrame:CGRectMake(self.xLabel.frame.origin.x + self.xLabel.frame.size.width, 5.0f, self.frame.size.width - (self.xLabel.frame.origin.x + self.xLabel.frame.size.width) - 5.0f, originY)];
        self.hexTextField.backgroundColor = [UIColor whiteColor];
        self.hexTextField.text = @"FFFFFF";
        self.hexTextField.font = [UIFont fontWithName:MYRIADPRO size:rFontSize*1.2f];
        self.hexTextField.adjustsFontSizeToFitWidth = YES;
        self.hexTextField.textAlignment = NSTextAlignmentLeft;
        self.hexTextField.textColor = [UIColor blackColor];
        self.hexTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.hexTextField.delegate = self;
        [self addSubview:self.hexTextField];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            [self setIPhoneKeyboard:[[BSKeyboardControls alloc] initWithFields:@[self.hexTextField,]]];
            [self.iPhoneKeyboard setDelegate:self];
        }
        
        UILabel* recentTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 10.0f + originY, self.frame.size.width*0.2f, 10.0f)];
        recentTitleLabel.backgroundColor = [UIColor clearColor];
        recentTitleLabel.text = NSLocalizedString(@"Recent", nil);
        recentTitleLabel.textColor = [UIColor whiteColor];
        recentTitleLabel.font = [UIFont fontWithName:MYRIADPRO size:10.0f];
        recentTitleLabel.adjustsFontSizeToFitWidth = YES;
        recentTitleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:recentTitleLabel];
        
        self.recentColorScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.4f + 5.0f, 20.0f + originY, self.frame.size.width*0.6f - 10.0f, self.alignmentView.frame.origin.y - (22.0f + originY))];
        self.recentColorScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.recentColorScrollView];
        self.recentColorScrollView.delegate = self;
        self.recentColorScrollView.scrollEnabled = YES;
        self.recentColorScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        
        [self updateRecentColorScrollView];
        
        self.removeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        self.removeTapGesture.delegate = self;
        [self addGestureRecognizer:self.removeTapGesture];
        [self.removeTapGesture setNumberOfTapsRequired:1];
    }
    
    return self;
}

- (void) initialize
{
    [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment"] forState:UIControlStateNormal];
    [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment"] forState:UIControlStateNormal];
    [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment"] forState:UIControlStateNormal];
    [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment"] forState:UIControlStateNormal];

    switch (self.alignment)
    {
        case NSTextAlignmentLeft://Alignment Left
            [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment_Hightlight"] forState:UIControlStateNormal];
            break;
        case NSTextAlignmentCenter://Alignment Center
            [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment_Hightlight"] forState:UIControlStateNormal];
            break;
        case NSTextAlignmentRight://Alignment Right
            [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment_Highlight"] forState:UIControlStateNormal];
            break;
        case NSTextAlignmentJustified://Alignment Justify
            [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment_Highlight"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    if (self.isBold)
        [self.boldButton setImage:[UIImage imageNamed:@"Bold_Hightlight"] forState:UIControlStateNormal];
    else
        [self.boldButton setImage:[UIImage imageNamed:@"Bold"] forState:UIControlStateNormal];
    
    if (self.isItalic)
        [self.italicButton setImage:[UIImage imageNamed:@"Italic_Highlight"] forState:UIControlStateNormal];
    else
        [self.italicButton setImage:[UIImage imageNamed:@"Italic"] forState:UIControlStateNormal];

    if (self.isUnderline)
        [self.underlineButton setImage:[UIImage imageNamed:@"Underline_Highlight"] forState:UIControlStateNormal];
    else
        [self.underlineButton setImage:[UIImage imageNamed:@"Underline"] forState:UIControlStateNormal];

    if (self.isStroke)
        [self.strokeButton setImage:[UIImage imageNamed:@"Stroke_Highlight"] forState:UIControlStateNormal];
    else
        [self.strokeButton setImage:[UIImage imageNamed:@"Stroke"] forState:UIControlStateNormal];
    
    self.fontSizeSlider.value = self.textFontSize;
    
    NSString* strText = NSLocalizedString(@"Font Size", nil);
    strText = [strText stringByAppendingString:[NSString stringWithFormat:@" : %dpt", (int)self.textFontSize]];

    self.fontSizeLabel.text = strText;

    [self.colorPickerView setOldColor:self.textColor];
    [self.colorPickerView setSelectedColor:self.textColor];
    
    self.colorPreviewView.backgroundColor = self.textColor;
    
    NSString* hexString = [self.textColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];

    [self updateRecentColorScrollView];
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

- (void)textMenuMove:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translatedPoint = [gestureRecognizer translationInView:self.superview];
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        firstX = self.superview.center.x;
        firstY = self.superview.center.y;
    }
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    [self.superview setCenter:translatedPoint];
}


#pragma mark - 
#pragma mark - Text Font Size Changed
-(void) textFontSizeChanged:(id) sender
{
    self.textFontSize = self.fontSizeSlider.value;
    
    NSString* strText = NSLocalizedString(@"Font Size", nil);
    strText = [strText stringByAppendingString:[NSString stringWithFormat:@" : %dpt", (int)self.textFontSize]];

    self.fontSizeLabel.text = strText;

    if ([self.delegate respondsToSelector:@selector(changeTextFont: size: bold: italic:)])
    {
        [self.delegate changeTextFont:self.strFontName size:self.textFontSize bold:self.isBold italic:self.isItalic];
    }
}


#pragma mark -
#pragma mark - ColorPicker Changed

- (void) textColorPickerChanged:(KZColorPicker *)cp
{
    self.textColor = cp.selectedColor;
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.textColor]];
    
    self.colorPreviewView.backgroundColor = self.textColor;
    
    NSString* hexString = [self.textColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];

    [self deleteDesabled];

    if ([self.delegate respondsToSelector:@selector(changeTextColor:)])
    {
        [self.delegate changeTextColor:self.textColor];
    }
}


#pragma mark -
#pragma mark - Text Alignment Changed

- (void) alignmentChanged:(id)sender
{
    NSInteger tag = [sender tag];
    
    [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment"] forState:UIControlStateNormal];
    [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment"] forState:UIControlStateNormal];
    [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment"] forState:UIControlStateNormal];
    [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment"] forState:UIControlStateNormal];

    switch (tag)
    {
        case 1://Alignment Left
            self.alignment = NSTextAlignmentLeft;
            [self.alignmentLeftButton setImage:[UIImage imageNamed:@"LeftAlignment_Hightlight"] forState:UIControlStateNormal];
            break;
        case 2://Alignment Center
            self.alignment = NSTextAlignmentCenter;
            [self.alignmentCenterButton setImage:[UIImage imageNamed:@"CenterAlignment_Hightlight"] forState:UIControlStateNormal];
            break;
        case 3://Alignment Right
            self.alignment = NSTextAlignmentRight;
            [self.alignmentRightButton setImage:[UIImage imageNamed:@"RightAlignment_Highlight"] forState:UIControlStateNormal];
            break;
        case 4://Alignment Justify
            self.alignment = NSTextAlignmentJustified;
            [self.alignmentJustifyButton setImage:[UIImage imageNamed:@"JustifyAlignment_Highlight"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(changeTextAlignment:)])
    {
        [self.delegate changeTextAlignment:self.alignment];
    }
}


#pragma mark -
#pragma mark - Bold Changed

-(void) boldChanged:(id)sender
{
    self.isBold = !self.isBold;
    
    if (self.isBold)
        [self.boldButton setImage:[UIImage imageNamed:@"Bold_Hightlight"] forState:UIControlStateNormal];
    else
        [self.boldButton setImage:[UIImage imageNamed:@"Bold"] forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(changeTextFont: size: bold: italic:)])
    {
        [self.delegate changeTextFont:nil size:self.textFontSize bold:self.isBold italic:self.isItalic];
    }
}


#pragma mark -
#pragma mark - Italic Changed

-(void) italicChanged:(id)sender
{
    self.isItalic = !self.isItalic;
    
    if (self.isItalic)
        [self.italicButton setImage:[UIImage imageNamed:@"Italic_Highlight"] forState:UIControlStateNormal];
    else
        [self.italicButton setImage:[UIImage imageNamed:@"Italic"] forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(changeTextFont: size: bold: italic:)])
    {
        [self.delegate changeTextFont:self.strFontName size:self.textFontSize bold:self.isBold italic:self.isItalic];
    }
}


#pragma mark -
#pragma mark - Underline Changed

-(void) underlineChanged:(id)sender
{
    self.isUnderline = !self.isUnderline;
    
    if (self.isUnderline)
        [self.underlineButton setImage:[UIImage imageNamed:@"Underline_Highlight"] forState:UIControlStateNormal];
    else
        [self.underlineButton setImage:[UIImage imageNamed:@"Underline"] forState:UIControlStateNormal];
    
    if ([self.delegate respondsToSelector:@selector(changeTextUnderline:)])
    {
        [self.delegate changeTextUnderline:self.isUnderline];
    }
}


#pragma mark -
#pragma mark - stroke changed

-(void) strokeChanged:(id)sender
{
    self.isStroke = !self.isStroke;
    
    if (self.isStroke)
        [self.strokeButton setImage:[UIImage imageNamed:@"Stroke_Highlight"] forState:UIControlStateNormal];
    else
        [self.strokeButton setImage:[UIImage imageNamed:@"Stroke"] forState:UIControlStateNormal];

    if ([self.delegate respondsToSelector:@selector(changeTextStroke:)])
    {
        [self.delegate changeTextStroke:self.isStroke];
    }
}


#pragma mark -
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return gaFontNameArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"font-%d", (int)indexPath.row];
    
    UITableViewCell* fontcell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(fontcell == nil)
    {
        fontcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        fontcell.backgroundColor = [UIColor clearColor];
        
        if(indexPath.row < gaFontNameArray.count)
        {
            fontcell.textLabel.backgroundColor = [UIColor clearColor];
            fontcell.textLabel.text = [NSString stringWithFormat:@"%@", [gaFontNameArray objectAtIndex:indexPath.row]];
            fontcell.textLabel.textColor = [UIColor whiteColor];
            fontcell.textLabel.textAlignment = NSTextAlignmentCenter;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                fontcell.textLabel.font = [UIFont fontWithName:[gaFontNameArray objectAtIndex:indexPath.row] size:12];
            else
                fontcell.textLabel.font = [UIFont fontWithName:[gaFontNameArray objectAtIndex:indexPath.row] size:20];
            
            fontcell.textLabel.adjustsFontSizeToFitWidth = YES;
            fontcell.textLabel.minimumScaleFactor = 0.3f;
            
            if ([fontcell.textLabel.text isEqualToString:self.strFontName])
                fontcell.textLabel.textColor = [UIColor yellowColor];
        }
    }
    else
    {
        if((indexPath.row < gaFontNameArray.count)&&(indexPath.row >= 0))
        {
            fontcell.textLabel.backgroundColor = [UIColor clearColor];
            fontcell.textLabel.text = [NSString stringWithFormat:@"%@", [gaFontNameArray objectAtIndex:indexPath.row]];
            fontcell.textLabel.textColor = [UIColor whiteColor];
            fontcell.textLabel.textAlignment = NSTextAlignmentCenter;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                fontcell.textLabel.font = [UIFont fontWithName:[gaFontNameArray objectAtIndex:indexPath.row] size:12];
            else
                fontcell.textLabel.font = [UIFont fontWithName:[gaFontNameArray objectAtIndex:indexPath.row] size:20];
            
            fontcell.textLabel.adjustsFontSizeToFitWidth = YES;
            fontcell.textLabel.minimumScaleFactor = 0.3f;
            fontcell.backgroundColor = [UIColor clearColor];
            
            if ([fontcell.textLabel.text isEqualToString:self.strFontName])
                fontcell.textLabel.textColor = [UIColor yellowColor];
            
            fontcell.backgroundColor = [UIColor clearColor];
        }
    }
    
    return fontcell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return 20.0f;
    else
        return 30.0f;
    
    return 30.0f;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        return;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.strFontName = [gaFontNameArray objectAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(changeTextFont: size: bold: italic:)])
    {
        [self.delegate changeTextFont:self.strFontName size:self.textFontSize bold:self.isBold italic:self.isItalic];
    }

    [self.fontNameTableView reloadData];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row >= gaFontNameArray.count)
    {
        return sourceIndexPath;
    }
    
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < gaFontNameArray.count)
        return YES;
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < gaFontNameArray.count)
        return YES;
    
    return NO;
}


#pragma mark -
#pragma mark - BSKeyboardControls Delegate

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [self.hexTextField resignFirstResponder];
}


#pragma mark -
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = [textField.text uppercaseString];
    
    self.textColor = [UIColor colorWithHexString:textField.text];
    
    [self.colorPickerView setOldColor:self.textColor];
    [self.colorPickerView setSelectedColor:self.textColor];

    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.textColor]];
    self.colorPreviewView.backgroundColor = self.textColor;
    
    NSString* hexString = [self.textColor hexStringFromColor];
    self.hexTextField.text = [hexString uppercaseString];
    
    [self deleteDesabled];
    
    if ([self.delegate respondsToSelector:@selector(changeTextColor:)])
    {
        [self.delegate changeTextColor:self.textColor];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string length] == 0)
        return YES;
    
    if (range.location >= 8)
        return NO;
    
    string = [string uppercaseString];
    
    //compare string with A-F, 0-9
    NSCharacterSet* myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
    
    for (int i = 0; i < [string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        
        if ([myCharSet characterIsMember:c])
        {
            return YES;
        }
    }
    
    return NO;
}


#pragma mark -
#pragma mark - Action Tap Color Preview to Add Recent

- (void) actionColorPreviewToRecent:(UITapGestureRecognizer*) recognizer
{
    [self saveCurrentColorToRecent];
    [self updateRecentColorScrollView];
}


#pragma mark - Save color to Recent

-(void) saveCurrentColorToRecent
{
    //get hex string
    NSString* hexString = [self.textColor hexStringFromColor];
    hexString = [hexString uppercaseString];
    
    //if current hex string is exist on recent color array, then return. else if then add current hex string to recent color array
    for (int i = 0; i < gaRecentColorArray.count; i++)
    {
        NSString* recentString = [gaRecentColorArray objectAtIndex:i];
        
        if ([hexString isEqualToString:recentString])
        {
            return;
        }
    }
    
    [gaRecentColorArray addObject:hexString];
    
    //Save hex color string to plist
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSError *error;
    
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"RecentColor.plist"];
    
    if (![localFileManager fileExistsAtPath:plistFileName])
        [localFileManager removeItemAtPath:plistFileName error:&error ];
    [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
    
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionary];
    
    [plistDict setObject:[NSNumber numberWithInt:(int)gaRecentColorArray.count] forKey:@"RecentColorCount"];
    
    for (int i = 0; i < gaRecentColorArray.count; i++)
    {
        NSString* recentString = [gaRecentColorArray objectAtIndex:i];
        [plistDict setObject:recentString forKey:[NSString stringWithFormat:@"%d-RecentColorString", i]];
    }
    
    [plistDict writeToFile:plistFileName atomically:YES];
}


-(void) updateRecentColorScrollView
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
        {
            [view removeFromSuperview];
        }
    }
    
    CGFloat width = (self.recentColorScrollView.frame.size.width - 7.0f)/6.0f;
    CGFloat height = (self.recentColorScrollView.frame.size.height - 5.0f)/4.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        height = height*2.0f;
    
    for (int i = 0; i < gaRecentColorArray.count; i++)
    {
        NSString* colorString = [gaRecentColorArray objectAtIndex:i];
        
        RecentColorView* recentView = [[RecentColorView alloc] initWithFrame:CGRectMake(1.0f + (width+1.0f)*(i%6), 1.0f + (height+1.0f)*(i/6), width, height) index:i+1 string:colorString];
        recentView.delegate = self;
        [self.recentColorScrollView addSubview:recentView];
    }
    
    [self.recentColorScrollView setContentSize:CGSizeMake(self.recentColorScrollView.bounds.size.width, 1.0f + (height+1.0f)*(gaRecentColorArray.count/6 + 1))];
}


#pragma mark -
#pragma mark - RecentColorViewDelegate

-(void) selectColor:(NSInteger) colorIndex
{
    NSString* colorString = [gaRecentColorArray objectAtIndex:colorIndex-1];

    self.textColor = [UIColor colorWithHexString:colorString];

    [self.colorPickerView setOldColor:self.textColor];
    [self.colorPickerView setSelectedColor:self.textColor];
    
    self.leftBoxView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"leftBox"] imageWithOverlayColor:self.textColor]];
    self.colorPreviewView.backgroundColor = self.textColor;
    
    self.hexTextField.text = colorString;
    
    if ([self.delegate respondsToSelector:@selector(changeTextColor:)])
    {
        [self.delegate changeTextColor:self.textColor];
    }
}

-(void) deleteColor:(NSInteger) colorIndex
{
    [gaRecentColorArray removeObjectAtIndex:(colorIndex-1)];
    
    [self updateRecentColorScrollView];
    
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
        {
            view.deleteButton.hidden = NO;
        }
    }
}

-(void) deleteColorEnabled
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
        {
            view.deleteButton.hidden = NO;
        }
    }
    
    [self addGestureRecognizer:self.removeTapGesture];
}

-(void) deleteDesabled
{
    for (RecentColorView* view in self.recentColorScrollView.subviews)
    {
        if (view.tag > 0)
        {
            view.deleteButton.hidden = YES;
        }
    }
}

-(void) tapGesture:(UITapGestureRecognizer*) gesture
{
    [self deleteDesabled];
    
    [self removeGestureRecognizer:self.removeTapGesture];
}

@end
