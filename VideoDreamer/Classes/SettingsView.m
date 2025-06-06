//
//  SettingsView.m
//  VideoFrame
//
//  Created by Yinjing Li on 4/24/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import "SettingsView.h"
#import "YJLActionMenu.h"
#import "UIImageExtras.h"
#import "MyCloudDocument.h"
#import "SHKActivityIndicator.h"
#import "SceneDelegate.h"

@implementation SettingsView


-(void) initSettingsView
{
    self.backgroundColor = [UIColor blackColor];
    
    [self.photoDurationButton setBackgroundColor:[UIColor clearColor]];
    [self.photoDurationButton setTitle:[NSString stringWithFormat:@"%.1fs", grPhotoDefaultDuration] forState:UIControlStateNormal];
    [self.photoDurationButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.photoDurationButton.titleLabel setMinimumScaleFactor:0.1f];
    self.photoDurationButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.photoDurationButton setTintColor:[UIColor whiteColor]];
    [self.photoDurationButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.photoDurationButton.layer setBorderWidth:1.0f];
    [self.photoDurationButton.layer setCornerRadius:3.0f];
    
    [self.textDurationButton setBackgroundColor:[UIColor clearColor]];
    [self.textDurationButton setTitle:[NSString stringWithFormat:@"%.1fs", grTextDefaultDuration] forState:UIControlStateNormal];
    [self.textDurationButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.textDurationButton.titleLabel setMinimumScaleFactor:0.1f];
    self.textDurationButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.textDurationButton setTintColor:[UIColor whiteColor]];
    [self.textDurationButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.textDurationButton.layer setBorderWidth:1.0f];
    [self.textDurationButton.layer setCornerRadius:3.0f];
    
    [self.startActionButton setBackgroundColor:[UIColor clearColor]];
    [self.startActionButton setTitle:@"None\n0.00s" forState:UIControlStateNormal];
    [self.startActionButton.titleLabel setNumberOfLines:0];
    [self.startActionButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.startActionButton.titleLabel setMinimumScaleFactor:0.1f];
    self.startActionButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:10];
    self.startActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.startActionButton setTintColor:[UIColor whiteColor]];
    [self.startActionButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.startActionButton.layer setBorderWidth:1.0f];
    [self.startActionButton.layer setCornerRadius:3.0f];
    
    [self.endActionButton setBackgroundColor:[UIColor clearColor]];
    [self.endActionButton setTitle:@"None\n0.00s" forState:UIControlStateNormal];
    [self.endActionButton.titleLabel setNumberOfLines:0];
    [self.endActionButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.endActionButton.titleLabel setMinimumScaleFactor:0.1f];
    self.endActionButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:10];
    self.endActionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.endActionButton setTintColor:[UIColor whiteColor]];
    [self.endActionButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.endActionButton.layer setBorderWidth:1.0f];
    [self.endActionButton.layer setCornerRadius:3.0f];
    
    [self.timelineButton setTintColor:[UIColor lightGrayColor]];
    [self.timelineButton setBackgroundColor:[UIColor clearColor]];
    [self.timelineButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.timelineButton.layer setBorderWidth:1.0f];
    [self.timelineButton.layer setCornerRadius:3.0f];
    
    if (gnTimelineType == TIMELINE_TYPE_1)
        [self.timelineButton setImage:[UIImage imageNamed:@"timeline_1"] forState:UIControlStateNormal];
    else if (gnTimelineType == TIMELINE_TYPE_2)
        [self.timelineButton setImage:[UIImage imageNamed:@"timeline_2"] forState:UIControlStateNormal];
    else if (gnTimelineType == TIMELINE_TYPE_3)
        [self.timelineButton setImage:[UIImage imageNamed:@"timeline_3"] forState:UIControlStateNormal];
    
    [self.outputQualityButton setBackgroundColor:[UIColor clearColor]];
    [self.outputQualityButton setTitle:@"HD" forState:UIControlStateNormal];
    self.outputQualityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.outputQualityButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.outputQualityButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.outputQualityButton.titleLabel setMinimumScaleFactor:0.1f];
    [self.outputQualityButton setTintColor:[UIColor whiteColor]];
    [self.outputQualityButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.outputQualityButton.layer setBorderWidth:1.0f];
    [self.outputQualityButton.layer setCornerRadius:3.0f];
    
    [self updateOutputQualityButtonTitle];
    
    [self.previewLengthButton setBackgroundColor:[UIColor clearColor]];
    [self.previewLengthButton setTitle:[NSString stringWithFormat:@"%.1fs", grPreviewDuration] forState:UIControlStateNormal];
    [self.previewLengthButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.previewLengthButton.titleLabel setMinimumScaleFactor:0.1f];
    self.previewLengthButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.previewLengthButton setTintColor:[UIColor whiteColor]];
    [self.previewLengthButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.previewLengthButton.layer setBorderWidth:1.0f];
    [self.previewLengthButton.layer setCornerRadius:3.0f];
    
    [self.outlineButton setBackgroundColor:[UIColor clearColor]];
    [self.outlineButton.layer setBorderWidth:1.0f];
    [self.outlineButton.layer setCornerRadius:3.0f];
    [self.outlineButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.outlineButton.titleLabel.textColor = [UIColor whiteColor];
    
    if (gnDefaultOutlineType == 1)
    {
        [self.outlineButton setImage:nil forState:UIControlStateNormal];
        [self.outlineButton setTitle:@"OFF" forState:UIControlStateNormal];
        [self.outlineButton setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [self.outlineButton setTitle:@"" forState:UIControlStateNormal];
        
        NSString* fileName = [NSString stringWithFormat:@"style_iphone_%d", gnDefaultOutlineType];
        [self.outlineButton setImage:[UIImage imageNamed:fileName] forState:UIControlStateNormal];
        [self.outlineButton setTintColor:defaultOutlineColor];
    }
    
    [self.startWithButton setBackgroundColor:[UIColor clearColor]];
    
    if (gnStartWithType == START_WITH_TEMPLATE)
        [self.startWithButton setTitle:NSLocalizedString(@"Template Page", nil) forState:UIControlStateNormal];
    else if (gnStartWithType == START_WITH_PHOTOCAM)
        [self.startWithButton setTitle:NSLocalizedString(@"PhotoCam", nil) forState:UIControlStateNormal];
    else if (gnStartWithType == START_WITH_VIDEOCAM)
        [self.startWithButton setTitle:NSLocalizedString(@"VideoCam", nil) forState:UIControlStateNormal];
    
    self.startWithButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.startWithButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.startWithButton setTintColor:[UIColor whiteColor]];
    [self.startWithButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.startWithButton.layer setBorderWidth:1.0f];
    [self.startWithButton.layer setCornerRadius:3.0f];
    
    if (isKenBurnsEnabled)
        self.kbSwitch.on = YES;
    else
        self.kbSwitch.on = NO;
    
    if (isTouchVisualizerEnabled)
        self.touchVisualizerSwitch.on = YES;
    else
        self.touchVisualizerSwitch.on = NO;
    
    [self.kbZoomButton setBackgroundColor:[UIColor clearColor]];
    if(gnKBZoomInOutType == KB_IN)
        [self.kbZoomButton setTitle: NSLocalizedString(@"Zoom In", nil) forState:UIControlStateNormal];
    else
        [self.kbZoomButton setTitle:NSLocalizedString(@"Zoom Out", nil) forState:UIControlStateNormal];
    self.kbZoomButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.kbZoomButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.kbZoomButton setTintColor:[UIColor whiteColor]];
    [self.kbZoomButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.kbZoomButton.layer setBorderWidth:1.0f];
    [self.kbZoomButton.layer setCornerRadius:3.0f];
    
    [self.kbScaleButton setBackgroundColor:[UIColor clearColor]];
    [self.kbScaleButton setTitle:[NSString stringWithFormat:@"%.1fx", grKBScale] forState:UIControlStateNormal];
    self.kbScaleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.kbScaleButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.kbScaleButton setTintColor:[UIColor whiteColor]];
    [self.kbScaleButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.kbScaleButton.layer setBorderWidth:1.0f];
    [self.kbScaleButton.layer setCornerRadius:3.0f];
    
    [self.backupButton setBackgroundColor:[UIColor clearColor]];
    [self.backupButton setTitle:NSLocalizedString(@"Backup", nil) forState:UIControlStateNormal];
    self.backupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.backupButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.backupButton setTintColor:[UIColor whiteColor]];
    [self.backupButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.backupButton.layer setBorderWidth:1.0f];
    [self.backupButton.layer setCornerRadius:3.0f];
    
    [self.restoreButton setBackgroundColor:[UIColor clearColor]];
    [self.restoreButton setTitle:NSLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
    self.restoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.restoreButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.restoreButton setTintColor:[UIColor whiteColor]];
    [self.restoreButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.restoreButton.layer setBorderWidth:1.0f];
    [self.restoreButton.layer setCornerRadius:3.0f];
    
    [self.projectBackupButton setBackgroundColor:[UIColor clearColor]];
    [self.projectBackupButton setTitle:NSLocalizedString(@"Backup", nil) forState:UIControlStateNormal];
    self.projectBackupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.projectBackupButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.projectBackupButton setTintColor:[UIColor whiteColor]];
    [self.projectBackupButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.projectBackupButton.layer setBorderWidth:1.0f];
    [self.projectBackupButton.layer setCornerRadius:3.0f];
    
    [self.musicBackupButton setBackgroundColor:[UIColor clearColor]];
    [self.musicBackupButton setTitle:NSLocalizedString(@"Backup", nil) forState:UIControlStateNormal];
    self.musicBackupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.musicBackupButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.musicBackupButton setTintColor:[UIColor whiteColor]];
    [self.musicBackupButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.musicBackupButton.layer setBorderWidth:1.0f];
    [self.musicBackupButton.layer setCornerRadius:3.0f];
    
    [self.projectRestoreButton setBackgroundColor:[UIColor clearColor]];
    [self.projectRestoreButton setTitle:NSLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
    self.projectRestoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.projectRestoreButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.projectRestoreButton setTintColor:[UIColor whiteColor]];
    [self.projectRestoreButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.projectRestoreButton.layer setBorderWidth:1.0f];
    [self.projectRestoreButton.layer setCornerRadius:3.0f];
    
    [self.musicRestoreButton setBackgroundColor:[UIColor clearColor]];
    [self.musicRestoreButton setTitle:NSLocalizedString(@"Restore", nil) forState:UIControlStateNormal];
    self.musicRestoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.musicRestoreButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.musicRestoreButton setTintColor:[UIColor whiteColor]];
    [self.musicRestoreButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.musicRestoreButton.layer setBorderWidth:1.0f];
    [self.musicRestoreButton.layer setCornerRadius:3.0f];
    
    [self.learnButton setBackgroundColor:[UIColor clearColor]];
    [self.learnButton setTitle:NSLocalizedString(@"Learn How", nil) forState:UIControlStateNormal];
    self.learnButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.learnButton.titleLabel.font = [UIFont fontWithName:MYRIADPRO size:15.0f];
    [self.learnButton setTintColor:[UIColor whiteColor]];
    [self.learnButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.learnButton.layer setBorderWidth:1.0f];
    [self.learnButton.layer setCornerRadius:3.0f];
    
    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 200.0f, 295.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 372.0f, 470.0f);
    
    self.outlineView = [[OutlineView alloc] initWithFrame:menuFrame];
    self.outlineView.delegate = self;
}


#pragma mark -
#pragma mark -

- (IBAction) onPhotoDuration:(id) sender
{
    self.superview.hidden = YES;
    
    isDurationType = PHOTO_DURATION;
    
    TimePickerView *picker = [[TimePickerView alloc] initWithTitle:NSLocalizedString(@"Default", nil)];
    picker.delegate = self;
    [picker setComponents];
    [picker setMediaType:MEDIA_PHOTO];
    [picker setTime:grPhotoDefaultDuration];
    [picker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:picker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

- (IBAction) onTextDuration:(id) sender
{
    self.superview.hidden = YES;
    
    isDurationType = TEXT_DURATION;
    
    TimePickerView *picker = [[TimePickerView alloc] initWithTitle:NSLocalizedString(@"Default", nil)];
    picker.delegate = self;
    [picker setComponents];
    [picker setMediaType:MEDIA_TEXT];
    [picker setTime:grTextDefaultDuration];
    [picker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:picker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

- (IBAction) onStartAction:(id) sender
{
    [self setStartEndAction:YES];
}

- (IBAction) onEndAction:(id) sender
{
    [self setStartEndAction:NO];
}

- (IBAction) onTimeline:(id) sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Stacked", nil)
                            image:[[UIImage imageNamed:@"timeline_1"] rescaleImageToSize:CGSizeMake(30.0f, 15.0f)]
                           target:self
                           action:@selector(onTimeline_1)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Staggered", nil)
                            image:[[UIImage imageNamed:@"timeline_2"] rescaleImageToSize:CGSizeMake(30.0f, 15.0f)]
                           target:self
                           action:@selector(onTimeline_2)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Overlapped", nil)
                            image:[[UIImage imageNamed:@"timeline_3"] rescaleImageToSize:CGSizeMake(30.0f, 15.0f)]
                           target:self
                           action:@selector(onTimeline_3)],
      ];
    
    CGRect frame = [self.superview convertRect:self.timelineButton.frame fromView:self];
    
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

- (void) onTimeline_1
{
    gnTimelineType = TIMELINE_TYPE_1;
    
    [self.timelineButton setImage:[UIImage imageNamed:@"timeline_1"] forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (void) onTimeline_2
{
    gnTimelineType = TIMELINE_TYPE_2;
    
    [self.timelineButton setImage:[UIImage imageNamed:@"timeline_2"] forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (void) onTimeline_3
{
    gnTimelineType = TIMELINE_TYPE_3;
    
    [self.timelineButton setImage:[UIImage imageNamed:@"timeline_3"] forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (IBAction) onPreviewLength:(id) sender
{
    self.superview.hidden = YES;
    
    isDurationType = PREVIEW_DURATION;
    
    TimePickerView *picker = [[TimePickerView alloc] initWithTitle:NSLocalizedString(@"Default", nil)];
    picker.delegate = self;
    [picker setComponents];
    [picker setTime:grPreviewDuration];
    [picker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:picker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

- (IBAction) onOutline:(id) sender
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [self.outlineView setObjectBorderStyle:gnDefaultOutlineType];
    [self.outlineView setObjectBorderWidth:grDefaultOutlineWidth];
    [self.outlineView setObjectBorderColor:defaultOutlineColor];
    [self.outlineView setObjectCornerRadius:grDefaultOutlineCorner];
    [self.outlineView setMaxCornerValue:50.0f];
    [self.outlineView initialize];
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.outlineView isCenter:NO];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

- (IBAction) onStartWith:(id) sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Template Page", nil)
                            image:nil
                           target:self
                           action:@selector(onTemplate)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"PhotoCam", nil)
                            image:nil
                           target:self
                           action:@selector(onPhotoCam)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"VideoCam", nil)
                            image:nil
                           target:self
                           action:@selector(onVideoCam)],
      ];
    
    CGRect frame = [self.superview convertRect:self.startWithButton.frame fromView:self];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

- (void) onTemplate
{
    gnStartWithType = START_WITH_TEMPLATE;
    
    [self.startWithButton setTitle:NSLocalizedString(@"Template Page", nil) forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (void) onPhotoCam
{
    gnStartWithType = START_WITH_PHOTOCAM;
    
    [self.startWithButton setTitle:NSLocalizedString(@"PhotoCam", nil) forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (void) onVideoCam
{
    gnStartWithType = START_WITH_VIDEOCAM;
    
    [self.startWithButton setTitle:NSLocalizedString(@"VideoCam", nil) forState:UIControlStateNormal];
    
    [self saveProjectSettingstoPlist];
}

- (IBAction) onOutputQuality:(id) sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"UHD"
                            image:nil
                           target:self
                           action:@selector(onSelectedUHD)],

      [YJLActionMenuItem menuItem:@"HD"
                            image:nil
                           target:self
                           action:@selector(onSelectedHD)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Universal", nil)
                            image:nil
                           target:self
                           action:@selector(onSelectedUniversal)],
      
      [YJLActionMenuItem menuItem:@"SDTV"
                            image:nil
                           target:self
                           action:@selector(onSelectedSdtv)],
      ];
    
    CGRect frame = [self.superview convertRect:self.outputQualityButton.frame fromView:self];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(void) onSelectedUHD
{
    gnOutputQuality = OUTPUT_UHD;
    
    [self updateOutputQualityButtonTitle];
    
    [self saveProjectSettingstoPlist];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedOutput:)])
    {
        [self.delegate didSelectedOutput: OUTPUT_UHD];
    }
}

-(void) onSelectedHD
{
    gnOutputQuality = OUTPUT_HD;
    
    [self updateOutputQualityButtonTitle];
    
    [self saveProjectSettingstoPlist];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedOutput:)])
    {
        [self.delegate didSelectedOutput: OUTPUT_HD];
    }
}

-(void) onSelectedUniversal
{
    gnOutputQuality = OUTPUT_UNIVERSAL;
    
    [self updateOutputQualityButtonTitle];
    
    [self saveProjectSettingstoPlist];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedOutput:)])
    {
        [self.delegate didSelectedOutput: OUTPUT_UNIVERSAL];
    }
    
}

-(void) onSelectedSdtv
{
    gnOutputQuality = OUTPUT_SDTV;
    
    [self updateOutputQualityButtonTitle];
    
    [self saveProjectSettingstoPlist];
    
    if ([self.delegate respondsToSelector:@selector(didSelectedOutput:)])
    {
        [self.delegate didSelectedOutput: OUTPUT_SDTV];
    }
}

-(void) updateOutputQualityButtonTitle
{
    switch (gnOutputQuality)
    {
        case OUTPUT_UHD:
            [self.outputQualityButton setTitle:@"UHD" forState:UIControlStateNormal];
            break;
        case OUTPUT_HD:
            [self.outputQualityButton setTitle:@"HD" forState:UIControlStateNormal];
            break;
        case OUTPUT_UNIVERSAL:
            [self.outputQualityButton setTitle:NSLocalizedString(@"Universal", nil) forState:UIControlStateNormal];
            break;
        case OUTPUT_SDTV:
            [self.outputQualityButton setTitle:@"SDTV" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark - Update Settings

- (void) updateSettings
{
    if (gnStartActionTypeDef != ACTION_NONE)
    {
        NSString* startActionTypeStr = [gaActionNameArray objectAtIndex:gnStartActionTypeDef];
        [self.startActionButton setTitle:[NSString stringWithFormat:@"%@\n%.2fs", startActionTypeStr, grStartActionTimeDef] forState:UIControlStateNormal];
    }
    
    if (gnEndActionTypeDef != ACTION_NONE)
    {
        NSString* endActionTypeStr = [gaActionNameArray objectAtIndex:gnEndActionTypeDef];
        [self.endActionButton setTitle:[NSString stringWithFormat:@"%@\n%.2fs", endActionTypeStr, grEndActionTimeDef] forState:UIControlStateNormal];
    }
    
    if (gnDefaultOutlineType == 1)
    {
        [self.outlineButton setImage:nil forState:UIControlStateNormal];
        [self.outlineButton setTitle:@"OFF" forState:UIControlStateNormal];
        [self.outlineButton setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [self.outlineButton setTitle:@"" forState:UIControlStateNormal];
        
        NSString* fileName = [NSString stringWithFormat:@"style_iphone_%d", gnDefaultOutlineType];
        [self.outlineButton setImage:[UIImage imageNamed:fileName] forState:UIControlStateNormal];
        [self.outlineButton setTintColor:defaultOutlineColor];
    }
    
    if (isKenBurnsEnabled)
    {
        [self.kbSwitch setOn:YES];
        
        self.kbZoomButton.hidden = NO;
        self.kbScaleButton.hidden = NO;
        
        self.kbZoomButton.alpha = 1.0f;
        self.kbScaleButton.alpha = 1.0f;
    }
    else
    {
        [self.kbSwitch setOn:NO];
        
        self.kbZoomButton.hidden = YES;
        self.kbScaleButton.hidden = YES;
        
        self.kbZoomButton.alpha = 0.0f;
        self.kbScaleButton.alpha = 0.0f;
    }
    
    if (isTouchVisualizerEnabled)
        [self.touchVisualizerSwitch setOn:YES];
    else
        [self.touchVisualizerSwitch setOn:NO];
}


#pragma mark -
#pragma mark - TimePickerViewDelegate

-(void) didCancel
{
    self.superview.hidden = NO;
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}

-(void) timePickerViewSeleted:(CGFloat) time
{
    self.superview.hidden = NO;
    
    if (isDurationType == PHOTO_DURATION)
    {
        grPhotoDefaultDuration = time;
        [self.photoDurationButton setTitle:[NSString stringWithFormat:@"%.1fs", grPhotoDefaultDuration] forState:UIControlStateNormal];
    }
    else if (isDurationType == TEXT_DURATION)
    {
        grTextDefaultDuration = time;
        [self.textDurationButton setTitle:[NSString stringWithFormat:@"%.1fs", grTextDefaultDuration] forState:UIControlStateNormal];
    }
    else if (isDurationType == PREVIEW_DURATION)
    {
        grPreviewDuration = time;
        [self.previewLengthButton setTitle:[NSString stringWithFormat:@"%.1fs", grPreviewDuration] forState:UIControlStateNormal];
    }
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [self saveProjectSettingstoPlist];
}


#pragma mark -
#pragma mark - Save project settings plist

-(void) saveProjectSettingstoPlist
{
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    
    //Project settings in plist
    NSMutableDictionary *plistDict = nil;
    
    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ProjectSettings.plist"];
    
    if (![localFileManager fileExistsAtPath:plistFileName])
    {
        [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
        
        plistDict = [NSMutableDictionary dictionary];
    }
    else
    {
        plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
    }
    
    [plistDict setObject:[NSNumber numberWithFloat:grPhotoDefaultDuration] forKey:@"grPhotoDefaultDuration"];
    [plistDict setObject:[NSNumber numberWithFloat:grTextDefaultDuration] forKey:@"grTextDefaultDuration"];
    [plistDict setObject:[NSNumber numberWithInt:gnStartActionTypeDef] forKey:@"startActionTypeDef"];
    [plistDict setObject:[NSNumber numberWithFloat:grStartActionTimeDef] forKey:@"startActionTimeDef"];
    [plistDict setObject:[NSNumber numberWithInt:gnEndActionTypeDef] forKey:@"endActionTypeDef"];
    [plistDict setObject:[NSNumber numberWithFloat:grEndActionTimeDef] forKey:@"endActionTimeDef"];
    [plistDict setObject:[NSNumber numberWithInt:gnTimelineType] forKey:@"gnTimelineType"];
    [plistDict setObject:[NSNumber numberWithInt:gnOutputQuality] forKey:@"gnOutputQuality"];
    [plistDict setObject:[NSNumber numberWithFloat:grPreviewDuration] forKey:@"grPreviewDuration"];
    [plistDict setObject:[NSNumber numberWithInt:gnDefaultOutlineType] forKey:@"gnDefaultOutlineType"];
    
    NSString* hexString = [defaultOutlineColor hexStringFromColor];
    hexString = [hexString uppercaseString];
    [plistDict setObject:hexString forKey:@"defaultOutlineColor"];
    
    [plistDict setObject:[NSNumber numberWithFloat:grDefaultOutlineWidth] forKey:@"grDefaultOutlineWidth"];
    [plistDict setObject:[NSNumber numberWithFloat:grDefaultOutlineCorner] forKey:@"grDefaultOutlineCorner"];
    [plistDict setObject:[NSNumber numberWithInt:gnStartWithType] forKey:@"gnStartWithType"];
    [plistDict setObject:[NSNumber numberWithBool:isKenBurnsEnabled] forKey:@"isKenBurnsEnabled"];
    [plistDict setObject:[NSNumber numberWithBool:isTouchVisualizerEnabled] forKey:@"isTouchVisualizerEnabled"];
    [plistDict setObject:[NSNumber numberWithInt:gnKBZoomInOutType] forKey:@"gnKBZoomInOutType"];
    [plistDict setObject:[NSNumber numberWithFloat:grKBScale] forKey:@"grKBScale"];
    
    // save music download to plist
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * musicSites= [userDefaults objectForKey:@"allSites"];
    NSMutableArray * defaultSite= [userDefaults objectForKey:@"defaultSite"];
    
    [plistDict setValue:musicSites forKey:@"musicSites"];
    [plistDict setValue:defaultSite forKey:@"defaultSite"];

    [plistDict writeToFile:plistFileName atomically:YES];
}


#pragma mark -
#pragma mark - Start/End Action

- (void) setStartEndAction:(BOOL) isStart
{
    self.superview.hidden = YES;
    
    NSMutableArray* timeArray = [[NSMutableArray alloc] init];
    [timeArray addObject:[NSString stringWithFormat:@"%.2fs", MIN_DURATION]];
    
    CGFloat duration = (isStart == YES) ? grStartActionTimeDef : grEndActionTimeDef;
    CGFloat actionTime = 0.0f;
    
    while (actionTime < 15.0f)
    {
        actionTime += 0.5f;
        NSString* timeStr = [NSString stringWithFormat:@"%.2fs", actionTime];
        [timeArray addObject:timeStr];
    }
    
    if (self.actionSettingsPicker != nil)
        self.actionSettingsPicker = nil;
    
    self.actionSettingsPicker = [[ActionSettingsPickerView alloc] initWithTitle:NSLocalizedString(@"Action Settings", nil)];
    self.actionSettingsPicker.delegate = self;
    [self.actionSettingsPicker setTitlesForComponenets:[NSArray arrayWithObjects:gaActionNameArray,
                                                        [NSArray arrayWithArray:timeArray],
                                                        nil]];
    NSInteger selectedActionTypeIndex = 0;
    NSInteger selectedActionTimeIndex = 0;
    
    for (int i = 0; i < timeArray.count; i++)
    {
        NSString* str = [timeArray objectAtIndex:i];
        CGFloat time = [str floatValue];
        
        if (time == duration)
        {
            selectedActionTimeIndex = i;
            break;
        }
    }
    
    selectedActionTypeIndex = (isStart == YES) ? gnStartActionTypeDef : gnEndActionTypeDef;
    
    [self.actionSettingsPicker setIndexOfActionType:selectedActionTypeIndex];
    [self.actionSettingsPicker setIndexOfActionTime:selectedActionTimeIndex];
    [self.actionSettingsPicker setIsStart:isStart];
    [self.actionSettingsPicker initializePicker];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.actionSettingsPicker bgColor:[UIColor whiteColor]];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}


#pragma mark -
#pragma mark - ActionSettingsPickerView Delegate

-(void)actionSheetPickerView:(ActionSettingsPickerView *)pickerView didSelectTitles:(NSArray *)titles typeIndex:(NSInteger)actionTypeIndex
{
    self.superview.hidden = NO;
    
    //action type
    NSString* actionTypeStr = [titles objectAtIndex:0];
    int actionType = (int)actionTypeIndex;
    
    //action time
    NSString* actionTimeStr = [titles objectAtIndex:1];
    CGFloat actionTime = [actionTimeStr floatValue];
    
    if (pickerView.isStart)
    {
        if (actionType == 0)
            actionTime = 0.0f;
        
        gnStartActionTypeDef = actionType;
        grStartActionTimeDef = actionTime;
        
        [self.startActionButton setTitle:[NSString stringWithFormat:@"%@\n%.2fs", actionTypeStr, actionTime] forState:UIControlStateNormal];
    }
    else
    {
        if (actionType == 0)
            actionTime = 0.0f;
        
        gnEndActionTypeDef = actionType;
        grEndActionTimeDef = actionTime;
        
        [self.endActionButton setTitle:[NSString stringWithFormat:@"%@\n%.2fs", actionTypeStr, actionTime] forState:UIControlStateNormal];
    }
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [self saveProjectSettingstoPlist];
}

-(void) didCancelActionSettings
{
    self.superview.hidden = NO;
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}

- (void) hideActionSettingsView
{
    self.superview.hidden = NO;
    
    if (self.customModalView)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
}


#pragma mark -
#pragma mark - OutlineView Delegate

-(void)changeBorder:(int)style borderColor:(UIColor *)color borderWidth:(CGFloat)width cornerRadius:(CGFloat)radius
{
    gnDefaultOutlineType = style;
    defaultOutlineColor = color;
    grDefaultOutlineWidth = width;
    grDefaultOutlineCorner = radius;
    
    if (gnDefaultOutlineType == 1)
    {
        [self.outlineButton setImage:nil forState:UIControlStateNormal];
        [self.outlineButton setTitle:@"OFF" forState:UIControlStateNormal];
        [self.outlineButton setTintColor:[UIColor whiteColor]];
    }
    else
    {
        [self.outlineButton setTitle:@"" forState:UIControlStateNormal];
        
        NSString* fileName = [NSString stringWithFormat:@"style_iphone_%d", gnDefaultOutlineType];
        [self.outlineButton setImage:[UIImage imageNamed:fileName] forState:UIControlStateNormal];
        [self.outlineButton setTintColor:defaultOutlineColor];
    }
    
    [self saveProjectSettingstoPlist];
}


#pragma mark -
#pragma mark - iCloud

-(IBAction) backupDataToICloud:(id) sender
{
    //Save thumbnail to iCloud
    
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        [self saveProjectSettingstoPlist];
        
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Backup to iCloud...", nil)) isLock:YES];
        
        [self performSelector:@selector(saveData) withObject:nil afterDelay:0.2f];   //save data to iCloud
    }
    else
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please login to iCloud first!", nil) okHandler:nil];
    }
}

-(IBAction) restoreDataFromICloud:(id) sender
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Restore from iCloud...", nil)) isLock:YES];
        
        [self performSelector:@selector(restoreData) withObject:nil afterDelay:0.2f];   //restore data from iCloud
    }
    else
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please login to iCloud first!", nil) okHandler:nil];
    }
}

-(void)restoreMusicData
{
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    
    BOOL isDirectory = NO;
    NSString *musicFolderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];
    musicFolderPath = [musicFolderPath stringByAppendingPathComponent:@"Library"];
    
    BOOL exist = [localFileManager fileExistsAtPath:musicFolderPath isDirectory:&isDirectory];
    
    if (exist)
    {
        NSArray* files = [localFileManager contentsOfDirectoryAtPath:musicFolderPath error:nil];
        
        if (files.count == 0)
        {
            [[SHKActivityIndicator currentIndicator] hide];
        }
        else
        {
            for (int i = 0; i < files.count; i++)
            {
                NSString* fileName = [files objectAtIndex:i];
                NSString* filePath = [musicFolderPath stringByAppendingPathComponent:fileName];
                
                NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
                NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:fileName];
                
                MyCloudDocument *musicDoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
                
                [musicDoc openWithCompletionHandler:^(BOOL success) {
                    
                    if (success)
                    {
                        NSError* error = nil;
                        NSData* musicData = musicDoc.dataContent;
                        
                        if ([localFileManager fileExistsAtPath:filePath])
                            [localFileManager removeItemAtPath:filePath error:&error];
                        
                        [musicData writeToFile:filePath atomically:YES];
                        
                        [musicDoc closeWithCompletionHandler:^(BOOL success) {
                            
                        }];
                    }
                    else
                    {
                        NSLog(@"failed to open %@ from iCloud", fileName);
                    }
                    
                    if (i == files.count - 1)
                    {
                        [[SHKActivityIndicator currentIndicator] hide];
                        
                        [self iCloudInstruction:NO];
                    }
                    
                }];
            }
        }
    } else {
        [[SHKActivityIndicator currentIndicator] hide];
    }
}

#pragma mark -
#pragma mark - Restore Data from iCloud

-(void)restoreData
{
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSString* thumbFolderPath = [plistFolderPath stringByAppendingPathComponent:@"CustomThumbnails"];
    
    //load ProjectSettings.plist from iCloud
    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ProjectSettings.plist"];
    
    NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"ProjectSettings.plist"];
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
    
    [mydoc openWithCompletionHandler:^(BOOL success) {
        
        if (success)
        {
            NSError* error = nil;
            NSData* plistData = mydoc.dataContent;
            
            if ([localFileManager fileExistsAtPath:plistFileName])
                [localFileManager removeItemAtPath:plistFileName error:&error];
            
            [plistData writeToFile:plistFileName atomically:YES];
            
            NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
            
            grPhotoDefaultDuration = [[plistDict objectForKey:@"grPhotoDefaultDuration"] floatValue];
            grTextDefaultDuration = [[plistDict objectForKey:@"grTextDefaultDuration"] floatValue];
            gnStartActionTypeDef = [[plistDict objectForKey:@"startActionTypeDef"] intValue];
            grStartActionTimeDef = [[plistDict objectForKey:@"startActionTimeDef"] floatValue];
            gnEndActionTypeDef = [[plistDict objectForKey:@"endActionTypeDef"] intValue];
            grEndActionTimeDef = [[plistDict objectForKey:@"endActionTimeDef"] floatValue];
            gnTimelineType = [[plistDict objectForKey:@"gnTimelineType"] intValue];
            gnOutputQuality = [[plistDict objectForKey:@"gnOutputQuality"] intValue];
            grPreviewDuration = [[plistDict objectForKey:@"grPreviewDuration"] floatValue];
            gnDefaultOutlineType = [[plistDict objectForKey:@"gnDefaultOutlineType"] intValue];
            
            NSString* hexColor = [plistDict objectForKey:@"defaultOutlineColor"];
            defaultOutlineColor = [UIColor colorWithHexString:hexColor];
            
            grDefaultOutlineWidth = [[plistDict objectForKey:@"grDefaultOutlineWidth"] floatValue];
            grDefaultOutlineCorner = [[plistDict objectForKey:@"grDefaultOutlineCorner"] floatValue];
            
            // load music download from plist
            NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray * musicSites = [plistDict mutableArrayValueForKey:@"musicSites"];
            [userDefaults setValue:musicSites forKey:@"allSites"];
            
            NSMutableArray * defaultSite = [plistDict mutableArrayValueForKey:@"defaultSite"];
            [userDefaults setValue:defaultSite forKey:@"defaultSite"];
           
            //update UI
            [self.photoDurationButton setTitle:[NSString stringWithFormat:@"%.1fs", grPhotoDefaultDuration] forState:UIControlStateNormal];
            [self.textDurationButton setTitle:[NSString stringWithFormat:@"%.1fs", grTextDefaultDuration] forState:UIControlStateNormal];
            [self.previewLengthButton setTitle:[NSString stringWithFormat:@"%.1fs", grPreviewDuration] forState:UIControlStateNormal];
            
            [self updateSettings];
            [self updateOutputQualityButtonTitle];
            
            if (gnStartWithType == START_WITH_TEMPLATE)
                [self.startWithButton setTitle:NSLocalizedString(@"Template Page", nil) forState:UIControlStateNormal];
            else if (gnStartWithType == START_WITH_PHOTOCAM)
                [self.startWithButton setTitle:NSLocalizedString(@"PhotoCam", nil) forState:UIControlStateNormal];
            else if (gnStartWithType == START_WITH_VIDEOCAM)
                [self.startWithButton setTitle:NSLocalizedString(@"VideoCam", nil) forState:UIControlStateNormal];
            
            if (gnTimelineType == TIMELINE_TYPE_1)
                [self.timelineButton setImage:[UIImage imageNamed:@"timeline_1"] forState:UIControlStateNormal];
            else if (gnTimelineType == TIMELINE_TYPE_2)
                [self.timelineButton setImage:[UIImage imageNamed:@"timeline_2"] forState:UIControlStateNormal];
            else if (gnTimelineType == TIMELINE_TYPE_3)
                [self.timelineButton setImage:[UIImage imageNamed:@"timeline_3"] forState:UIControlStateNormal];
            
            [mydoc closeWithCompletionHandler:^(BOOL success) {
                
            }];
        }
    }];
    
    //load RecentColor.plist from iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"RecentColor.plist"];
    
    containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"RecentColor.plist"];
    
    mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
    
    [mydoc openWithCompletionHandler:^(BOOL success) {
        
        if (success)
        {
            NSError* error = nil;
            NSData* plistData = mydoc.dataContent;
            
            if ([localFileManager fileExistsAtPath:plistFileName])
                [localFileManager removeItemAtPath:plistFileName error:&error];
            
            [plistData writeToFile:plistFileName atomically:YES];
            
            [gaRecentColorArray removeAllObjects];
            gaRecentColorArray = nil;
            
            gaRecentColorArray = [[NSMutableArray alloc] init];
            
            NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
            
            int recentArrayCount = [[plistDict objectForKey:@"RecentColorCount"] intValue];
            
            for (int i = 0; i < recentArrayCount; i++)
            {
                NSString* recentString = [plistDict objectForKey:[NSString stringWithFormat:@"%d-RecentColorString", i]];
                
                [gaRecentColorArray addObject:recentString];
            }
            
            [mydoc closeWithCompletionHandler:^(BOOL success) {
                
            }];
        }
    }];
    
    
    //load custom video name from iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
    
    containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"VideoName.plist"];
    
    mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
    
    [mydoc openWithCompletionHandler:^(BOOL success) {
        
        if (success)
        {
            NSError* error = nil;
            NSData* plistData = mydoc.dataContent;
            
            if ([localFileManager fileExistsAtPath:plistFileName])
                [localFileManager removeItemAtPath:plistFileName error:&error];
            
            [plistData writeToFile:plistFileName atomically:YES];
            
            [mydoc closeWithCompletionHandler:^(BOOL success) {
                
            }];
        }
    }];
    
    
    //load ThumbFileName.plist from iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ThumbFileName.plist"];
    
    containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"ThumbFileName.plist"];
    
    mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
    
    [mydoc openWithCompletionHandler:^(BOOL success) {
        
        if (success)
        {
            NSError* error = nil;
            NSData* plistData = mydoc.dataContent;
            
            if ([localFileManager fileExistsAtPath:plistFileName])
                [localFileManager removeItemAtPath:plistFileName error:&error];
            
            [plistData writeToFile:plistFileName atomically:YES];
            
            BOOL isDirectory = NO;
            BOOL exist = [localFileManager fileExistsAtPath:thumbFolderPath isDirectory:&isDirectory];
            
            if (!exist)
            {
                [localFileManager createDirectoryAtPath:thumbFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            
            //load thumbnail image from iCloud
            NSMutableDictionary *plistDict = nil;
            plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
            
            NSArray* allValues = plistDict.allValues;
            
            for (int i = 0; i < allValues.count; i++)
            {
                NSString* fileName = [allValues objectAtIndex:i];
                NSString* filePath = [thumbFolderPath stringByAppendingPathComponent:fileName];
                
                NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
                NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:fileName];
                
                MyCloudDocument *thumbDoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
                
                [thumbDoc openWithCompletionHandler:^(BOOL success) {
                    
                    if (success)
                    {
                        NSError* error = nil;
                        NSData* imageData = thumbDoc.dataContent;
                        
                        if ([localFileManager fileExistsAtPath:filePath])
                            [localFileManager removeItemAtPath:filePath error:&error];
                        
                        [imageData writeToFile:filePath atomically:YES];
                        
                        [thumbDoc closeWithCompletionHandler:^(BOOL success) {
                            
                        }];
                    }
                    else
                    {
                        NSLog(@"failed to open %@ from iCloud", fileName);
                    }
                    
                    if (i == (allValues.count-1))
                    {
                        [[SHKActivityIndicator currentIndicator] hide];
                        
                        [self iCloudInstruction:NO];
                    }
                    
                }];
            }
            
            [mydoc closeWithCompletionHandler:^(BOOL success) {
                
            }];
        }
        else
        {
            [[SHKActivityIndicator currentIndicator] hide];
        }
        
    }];
}

#pragma mark -
#pragma mark - Backup Music to iCloud

-(void)saveMusicData
{
    isEmpty = YES;
    
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *musicFolderPath = [folderDir stringByAppendingPathComponent:@"Music Library"];
    musicFolderPath = [musicFolderPath stringByAppendingPathComponent:@"Library"];
    
    BOOL isDirectory = NO;
    
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    BOOL exist = [localFileManager fileExistsAtPath:musicFolderPath isDirectory:&isDirectory];
    
    if (exist)
    {
        NSArray* files = [localFileManager contentsOfDirectoryAtPath:musicFolderPath error:nil];
        if (files.count == 0)
        {
            [[SHKActivityIndicator currentIndicator] hide];
        }
        else
        {
            for (int i = 0; i < files.count; i++)
            {
                isEmpty = NO;
                
                NSString* file = [files objectAtIndex:i];
                NSString* filePath = [musicFolderPath stringByAppendingPathComponent:file];
                
                NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
                NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[filePath lastPathComponent]];
                
                MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                mydoc.dataContent = data;
                
                [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
                 {
                     if(success)
                     {
                         [[SHKActivityIndicator currentIndicator] hide];
                         
                         [self iCloudInstruction:YES];
                     }
                     if (!success)
                     {
                         NSLog(@"Saving failed %@ to icloud", file);
                     }
                 }];
            }
        }
    }
    else
    {
        [[SHKActivityIndicator currentIndicator] hide];
    }
    
    if (isEmpty)
    {
        [[SHKActivityIndicator currentIndicator] hide];
    }
}

#pragma mark -
#pragma mark - Backup Data to iCloud

-(void)saveData
{
    isEmpty = YES;
    
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSString* thumbFolderPath = [plistFolderPath stringByAppendingPathComponent:@"CustomThumbnails"];
    
    //Save project settings plist to iCloud
    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ProjectSettings.plist"];
    
    BOOL isDirectory = NO;
    BOOL exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        isEmpty = NO;
        
        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"ProjectSettings.plist"];
        
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        mydoc.dataContent = [NSData dataWithContentsOfFile:plistFileName];
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (!success)
            {
                NSLog(@"Saving failed ProjectSettings.plist to icloud");
            }
        }];
    }
    
    //Save recent color plist to iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"RecentColor.plist"];
    
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        isEmpty = NO;
        
        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"RecentColor.plist"];
        
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        mydoc.dataContent = [NSData dataWithContentsOfFile:plistFileName];
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
                
            }
            else
            {
                NSLog(@"Saving failed RecentColor.plist to icloud");
            }
        }];
    }
    
    //Save custom video name plist to iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"VideoName.plist"];
    
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        isEmpty = NO;
        
        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"VideoName.plist"];
        
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        mydoc.dataContent = [NSData dataWithContentsOfFile:plistFileName];
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
                
            }
            else
            {
                NSLog(@"Saving failed VideoName.plist to icloud");
            }
        }];
    }
    
    //Save thumbnail file name plist to iCloud
    plistFileName = [plistFolderPath stringByAppendingPathComponent:@"ThumbFileName.plist"];
    
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        isEmpty = NO;
        
        NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"ThumbFileName.plist"];
        
        MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
        mydoc.dataContent = [NSData dataWithContentsOfFile:plistFileName];
        
        [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
                
            }
            else
            {
                NSLog(@"Saving failed ThumbFileName.plist to icloud");
            }
        }];
    }
    
    
    //Save custom thumbnails to iCloud
    isDirectory = NO;
    exist = [localFileManager fileExistsAtPath:thumbFolderPath isDirectory:&isDirectory];
    
    if (exist)
    {
        NSArray* files = [localFileManager contentsOfDirectoryAtPath:thumbFolderPath error:nil];
        
        if (files.count == 0)
        {
            [[SHKActivityIndicator currentIndicator] hide];
            
            NSString* lastUpdatePlistFileName = [plistFolderPath stringByAppendingPathComponent:@"LastUpdate.plist"];
            
            BOOL isDirectory = NO;
            BOOL exist = [localFileManager fileExistsAtPath:lastUpdatePlistFileName isDirectory:&isDirectory];
            
            NSMutableDictionary* lastUpdatePlistDict = nil;
            
            if (!exist)
            {
                [localFileManager createFileAtPath:lastUpdatePlistFileName contents:nil attributes:nil];
                
                lastUpdatePlistDict = [NSMutableDictionary dictionary];
            }
            else
            {
                lastUpdatePlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:lastUpdatePlistFileName];
            }
            
            NSDate* currentDate = [NSDate date];
            
            [lastUpdatePlistDict setObject:currentDate forKey:@"LastUpdatedDate"];
            [lastUpdatePlistDict writeToFile:lastUpdatePlistFileName atomically:YES];
        }
        
        for (int i = 0; i < files.count; i++)
        {
            isEmpty = NO;
            
            NSString* file = [files objectAtIndex:i];
            NSString* filePath = [thumbFolderPath stringByAppendingPathComponent:file];
            
            NSURL *containerUbiquitousURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
            NSURL *destinationUbiquitousURL = [[containerUbiquitousURL URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:[filePath lastPathComponent]];
            
            MyCloudDocument *mydoc = [[MyCloudDocument alloc] initWithFileURL:destinationUbiquitousURL];
            mydoc.dataContent = [NSData dataWithContentsOfFile:filePath];
            
            [mydoc saveToURL:[mydoc fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if (i == (files.count-1))
                {
                    [[SHKActivityIndicator currentIndicator] hide];
                    
                    [self iCloudInstruction:YES];
                    
                    NSString* lastUpdatePlistFileName = [plistFolderPath stringByAppendingPathComponent:@"LastUpdate.plist"];
                    
                    BOOL isDirectory = NO;
                    BOOL exist = [localFileManager fileExistsAtPath:lastUpdatePlistFileName isDirectory:&isDirectory];
                    
                    NSMutableDictionary* lastUpdatePlistDict = nil;
                    
                    if (!exist)
                    {
                        [localFileManager createFileAtPath:lastUpdatePlistFileName contents:nil attributes:nil];
                        
                        lastUpdatePlistDict = [NSMutableDictionary dictionary];
                    }
                    else
                    {
                        lastUpdatePlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:lastUpdatePlistFileName];
                    }
                    
                    NSDate* currentDate = [NSDate date];
                    
                    [lastUpdatePlistDict setObject:currentDate forKey:@"LastUpdatedDate"];
                    [lastUpdatePlistDict writeToFile:lastUpdatePlistFileName atomically:YES];
                }
                
                if (!success)
                {
                    NSLog(@"Saving failed %@ to icloud", file);
                }
            }];
        }
    }
    else
    {
        [[SHKActivityIndicator currentIndicator] hide];
    }
}

-(void)iCloudInstruction:(BOOL) isBackup
{
    if (isBackup)
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Backup Successful!", nil) message:@"" okHandler:nil];
    }
    else
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Restore Successful!", nil) message:@"" okHandler:nil];
    }
}


#pragma mark -
#pragma mark - Action Project Backup/Restore

-(IBAction)actionBackupProject:(id)sender
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        if ([self.delegate respondsToSelector:@selector(didBackupProjects)])
        {
            [self.delegate didBackupProjects];
        }
    }
    else
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please login to iCloud first!", nil) okHandler:nil];
    }
}

-(IBAction)actionRestoreProject:(id)sender
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        if ([self.delegate respondsToSelector:@selector(didRestoreProjects)])
        {
            [self.delegate didRestoreProjects];
        }
    }
    else
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please login to iCloud first!", nil) okHandler:nil];
    }
}

- (IBAction)actionBackupMusic:(id)sender {
    //Save Music to iCloud
    
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Backup to iCloud...", nil)) isLock:YES];
        
        [self performSelector:@selector(saveMusicData) withObject:nil afterDelay:0.2f];   //save music to iCloud
    }
    else
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please login to iCloud first!", nil) okHandler:nil];
    }
}

- (IBAction)actionRestoreMusic:(id)sender {
    
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (ubiq)
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Restore from iCloud...", nil)) isLock:YES];
        
        [self performSelector:@selector(restoreMusicData) withObject:nil afterDelay:0.2f];   //restore music from iCloud
    }
    else
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please login to iCloud first!", nil) okHandler:nil];
    }
}

#pragma mark -
#pragma mark - Learn How

-(IBAction)actionLearnHow:(id)sender
{
    NSString* path = @"https://support.apple.com/en-us/HT204247";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}


#pragma mark -
#pragma mark - Ken Burns

- (IBAction)actionKenBurnsOnOff:(id)sender
{
    if (self.kbSwitch.on)
    {
        isKenBurnsEnabled = YES;
        
        self.kbZoomButton.hidden = NO;
        self.kbScaleButton.hidden = NO;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.kbZoomButton.alpha = 1.0f;
            self.kbScaleButton.alpha = 1.0f;
        }];
    }
    else
    {
        isKenBurnsEnabled = NO;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.kbZoomButton.alpha = 0.0f;
            self.kbScaleButton.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.kbZoomButton.hidden = YES;
            self.kbScaleButton.hidden = YES;
        }];
    }
    
    [self saveProjectSettingstoPlist];
}

- (IBAction)actionKenBurnsZoom:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Zoom In", nil)
                            image:nil
                           target:self
                           action:@selector(selectZoomIn)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Zoom Out", nil)
                            image:nil
                           target:self
                           action:@selector(selectZoomOut)],
      ];
    
    CGRect frame = [self convertRect:self.kbZoomButton.frame toView:self.superview];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
    
}

-(void) selectZoomIn
{
    gnKBZoomInOutType = KB_IN;
    [self.kbZoomButton setTitle:NSLocalizedString(@"Zoom In", nil) forState:UIControlStateNormal];
    [self saveProjectSettingstoPlist];
}

-(void) selectZoomOut
{
    gnKBZoomInOutType = KB_OUT;
    [self.kbZoomButton setTitle:NSLocalizedString(@"Zoom Out", nil) forState:UIControlStateNormal];
    [self saveProjectSettingstoPlist];
}

- (IBAction)actionKenBurnsScale:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:@"1.1x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:0],
      
      [YJLActionMenuItem menuItem:@"1.2x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:1],
      
      [YJLActionMenuItem menuItem:@"1.3x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:2],
      
      [YJLActionMenuItem menuItem:@"1.4x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:3],
      
      [YJLActionMenuItem menuItem:@"1.5x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:4],
      
      [YJLActionMenuItem menuItem:@"1.6x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:5],
      
      [YJLActionMenuItem menuItem:@"1.7x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:6],
      
      [YJLActionMenuItem menuItem:@"1.8x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:7],
      
      [YJLActionMenuItem menuItem:@"1.9x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:8],
      
      [YJLActionMenuItem menuItem:@"2.0x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:9],
      
      [YJLActionMenuItem menuItem:@"2.1x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:10],
      
      [YJLActionMenuItem menuItem:@"2.2x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:11],
      
      [YJLActionMenuItem menuItem:@"2.3x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:12],
      
      [YJLActionMenuItem menuItem:@"2.4x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:13],
      
      [YJLActionMenuItem menuItem:@"2.5x"
                            image:nil
                           target:self
                           action:@selector(changedScale:)
                            index:14],
      ];
    
    CGRect frame = [self convertRect:self.kbScaleButton.frame toView:self.superview];
    [YJLActionMenu showMenuInView:self.superview
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(void) changedScale:(id) sender
{
    YJLActionMenuItem* menu = (YJLActionMenuItem*) sender;
    int index = menu.index;
    grKBScale = 1.1f + index/10.0f;
    [self.kbScaleButton setTitle:[NSString stringWithFormat:@"%.1fx", grKBScale] forState:UIControlStateNormal];
    [self saveProjectSettingstoPlist];
}

-(IBAction)touchVisualizerChanged:(id)sender
{
    if (self.touchVisualizerSwitch.on)
        isTouchVisualizerEnabled = YES;
    else
        isTouchVisualizerEnabled = NO;
    
    [self saveProjectSettingstoPlist];
}

@end
