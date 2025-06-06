//
//  KBSettingsView.m
//  VideoFrame
//
//  Created by Yinjing Li on 9/30/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "KBSettingsView.h"
#import "Definition.h"
#import "YJLActionMenu.h"


@implementation KBSettingsView

@synthesize delegate = _delegate;
@synthesize kbStatusLabel = _kbStatusLabel;
@synthesize kbZoomButton = _kbZoomButton;
@synthesize kbPreviewButton = _kbPreviewButton;
@synthesize kbApplyButton = _kbApplyButton;
@synthesize kbSwitch = _kbSwitch;
@synthesize kbScaleButton = _kbScaleButton;
@synthesize kbZoomLabel = _kbZoomLabel;
@synthesize kbScaleLabel = _kbScaleLabel;

-(void) awakeFromNib
{
    mbKbEnabled = NO;
    mnKbIn = KB_IN;
    mfKbScale = 1.1f;
    
    self.kbZoomButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.kbZoomButton.layer.borderWidth = 1.0f;
    self.kbZoomButton.layer.cornerRadius = 2.0f;
    
    self.kbScaleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.kbScaleButton.layer.borderWidth = 1.0f;
    self.kbScaleButton.layer.cornerRadius = 2.0f;

    self.kbPreviewButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.kbPreviewButton.layer.borderWidth = 1.0f;
    self.kbPreviewButton.layer.cornerRadius = 2.0f;
    self.kbPreviewButton.tag = 1;

    self.kbApplyButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.kbApplyButton.layer.borderWidth = 1.0f;
    self.kbApplyButton.layer.cornerRadius = 2.0f;
    [super awakeFromNib];
}


#pragma mark - 
#pragma mark - Set Params

-(void) setKbEnabled:(BOOL) enabled
{
    mbKbEnabled = enabled;
    self.kbSwitch.on = mbKbEnabled;
    
    if (mbKbEnabled)
    {
        self.kbStatusLabel.text = NSLocalizedString(@"Enabled", nil);
        self.kbZoomButton.enabled = YES;
        self.kbScaleButton.enabled = YES;
        self.kbPreviewButton.enabled = YES;
        self.kbZoomButton.alpha = 1.0f;
        self.kbScaleButton.alpha = 1.0f;
        self.kbPreviewButton.alpha = 1.0f;
    }
    else
    {
        self.kbStatusLabel.text = NSLocalizedString(@"Disabled", nil);
        self.kbZoomButton.enabled = NO;
        self.kbScaleButton.enabled = NO;
        self.kbPreviewButton.enabled = NO;
        self.kbZoomButton.alpha = 0.5f;
        self.kbScaleButton.alpha = 0.5f;
        self.kbPreviewButton.alpha = 0.5f;
    }
}

-(void) setKbIn:(NSInteger) inOut
{
    mnKbIn = inOut;
    
    NSString* inString = NSLocalizedString(@"In", nil);
    
    if (mnKbIn == KB_IN)
        inString = NSLocalizedString(@"In", nil);
    else
        inString = NSLocalizedString(@"Out", nil);
    
    [self.kbZoomButton setTitle:inString forState:UIControlStateNormal];
}

-(void) setKbScale:(CGFloat) scale
{
    mfKbScale = scale;
    
    [self.kbScaleButton setTitle:[NSString stringWithFormat:@"%.1fx", mfKbScale] forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark - Actions

-(IBAction)actionCheckToAll:(id)sender
{
    isKenBurnsChangeAll = !isKenBurnsChangeAll;
    
    if (isKenBurnsChangeAll)
    {
        [self.kbCheckToAllButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateNormal];
        [self.kbCheckToAllButton setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateSelected];
        [self.kbCheckToAllButton setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateHighlighted];
    }
    else
    {
        [self.kbCheckToAllButton setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
        [self.kbCheckToAllButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
        [self.kbCheckToAllButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
    }
}

-(IBAction)actionChangedSwitch:(id)sender
{
    mbKbEnabled = self.kbSwitch.on;
    
    if (mbKbEnabled)
    {
        self.kbStatusLabel.text = NSLocalizedString(@"Enabled", nil);
        self.kbZoomButton.enabled = YES;
        self.kbScaleButton.enabled = YES;
        self.kbPreviewButton.enabled = YES;
        self.kbZoomButton.alpha = 1.0f;
        self.kbScaleButton.alpha = 1.0f;
        self.kbPreviewButton.alpha = 1.0f;
    }
    else
    {
        self.kbStatusLabel.text = NSLocalizedString(@"Disabled", nil);
        self.kbZoomButton.enabled = NO;
        self.kbScaleButton.enabled = NO;
        self.kbPreviewButton.enabled = NO;
        self.kbZoomButton.alpha = 0.5f;
        self.kbScaleButton.alpha = 0.5f;
        self.kbPreviewButton.alpha = 0.5f;
    }
}

-(IBAction)actionZoomButton:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Zoom In", nil)
                            image:nil
                           target:self
                           action:@selector(didSelectZoomIn)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Zoom Out", nil)
                            image:nil
                           target:self
                           action:@selector(didSelectZoomOut)],
      ];
    
    CGRect frame = [self convertRect:self.kbZoomButton.frame toView:self.superview];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(IBAction)actionScaleButton:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"1.1x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:0],
      
      [YJLActionMenuItem menuItem:@"1.2x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:1],
      
      [YJLActionMenuItem menuItem:@"1.3x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:2],
      
      [YJLActionMenuItem menuItem:@"1.4x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:3],
      
      [YJLActionMenuItem menuItem:@"1.5x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:4],
      
      [YJLActionMenuItem menuItem:@"1.6x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:5],

      [YJLActionMenuItem menuItem:@"1.7x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:6],

      [YJLActionMenuItem menuItem:@"1.8x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:7],

      [YJLActionMenuItem menuItem:@"1.9x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:8],

      [YJLActionMenuItem menuItem:@"2.0x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:9],

      [YJLActionMenuItem menuItem:@"2.1x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:10],

      [YJLActionMenuItem menuItem:@"2.2x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:11],

      [YJLActionMenuItem menuItem:@"2.3x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:12],

      [YJLActionMenuItem menuItem:@"2.4x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:13],

      [YJLActionMenuItem menuItem:@"2.5x"
                            image:nil
                           target:self
                           action:@selector(didScale:)
                            index:14],
      ];
    
    CGRect frame = [self convertRect:self.kbScaleButton.frame toView:self.superview];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(IBAction)actionPreviewButton:(id)sender
{
    if (self.kbPreviewButton.tag == 1)
    {
        if ([self.delegate respondsToSelector:@selector(didPreviewKBSettingsView:inOut:scale:)])
        {
            [self.delegate didPreviewKBSettingsView:mbKbEnabled inOut:mnKbIn scale:mfKbScale];
        }

        self.kbPreviewButton.tag = 2;
        [self.kbPreviewButton setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
    }
    else if (self.kbPreviewButton.tag == 2)
    {
        if ([self.delegate respondsToSelector:@selector(didStopPreview)])
        {
            [self.delegate didStopPreview];
        }
        
        self.kbPreviewButton.tag = 1;
        [self.kbPreviewButton setTitle:NSLocalizedString(@"Preview", nil) forState:UIControlStateNormal];
    }
}

-(IBAction)actionApplyButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didApplyKBSettingsView:inOut:scale:)])
    {
        [self.delegate didApplyKBSettingsView:mbKbEnabled inOut:mnKbIn scale:mfKbScale];
    }
}


#pragma mark -
#pragma mark - Ken Burns In/Out type

-(void) didSelectZoomIn
{
    mnKbIn = KB_IN;
    
    [self.kbZoomButton setTitle:NSLocalizedString(@"In", nil) forState:UIControlStateNormal];
}

-(void) didSelectZoomOut
{
    mnKbIn = KB_OUT;
    
    [self.kbZoomButton setTitle:NSLocalizedString(@"Out", nil) forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark - Ken Burns Scale

-(void) didScale:(id) sender
{
    YJLActionMenuItem* menu = (YJLActionMenuItem*) sender;

    int index = menu.index;
    
    mfKbScale = 1.1f + index/10.0f;

    [self.kbScaleButton setTitle:[NSString stringWithFormat:@"%.1fx", mfKbScale] forState:UIControlStateNormal];
}


@end
