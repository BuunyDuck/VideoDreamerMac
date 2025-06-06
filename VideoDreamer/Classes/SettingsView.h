//
//  SettingsView.h
//  VideoFrame
//
//  Created by Yinjing Li on 4/24/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Definition.h"
#import "ActionSettingsPickerView.h"
#import "OutlineView.h"
#import "CustomModalView.h"
#import "TimePickerView.h"

#define PHOTO_DURATION 1
#define TEXT_DURATION 2
#define PREVIEW_DURATION 3


@protocol SettingsViewDelegate <NSObject>
@optional
-(void) didBackupProjects;
-(void) didRestoreProjects;
-(void) didSelectedOutput:(int)idx;

@end


@interface SettingsView : UIView<UIGestureRecognizerDelegate, ActionSettingsPickerView, CustomModalViewDelegate, OutlineViewDelegate, TimePickerViewDelegate>
{
    CGFloat firstX;
    CGFloat firstY;
    
    int isDurationType;
    
    BOOL isEmpty;
}

@property(nonatomic, weak) id <SettingsViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton* photoDurationButton;
@property (weak, nonatomic) IBOutlet UIButton* textDurationButton;
@property (weak, nonatomic) IBOutlet UIButton* startActionButton;
@property (weak, nonatomic) IBOutlet UIButton* endActionButton;
@property (weak, nonatomic) IBOutlet UIButton* timelineButton;
@property (weak, nonatomic) IBOutlet UIButton* outputQualityButton;
@property (weak, nonatomic) IBOutlet UIButton* previewLengthButton;
@property (weak, nonatomic) IBOutlet UIButton* outlineButton;
@property (weak, nonatomic) IBOutlet UIButton* startWithButton;
@property (weak, nonatomic) IBOutlet UIButton* kbZoomButton;
@property (weak, nonatomic) IBOutlet UIButton* kbScaleButton;

@property (weak, nonatomic) IBOutlet UIButton* backupButton;
@property (weak, nonatomic) IBOutlet UIButton* restoreButton;
@property (weak, nonatomic) IBOutlet UIButton* projectBackupButton;
@property (weak, nonatomic) IBOutlet UIButton* projectRestoreButton;
@property (weak, nonatomic) IBOutlet UIButton* learnButton;
@property (weak, nonatomic) IBOutlet UIButton *musicBackupButton;
@property (weak, nonatomic) IBOutlet UIButton *musicRestoreButton;

@property (weak, nonatomic) IBOutlet UISwitch* kbSwitch;
@property (weak, nonatomic) IBOutlet UISwitch* touchVisualizerSwitch;


@property(nonatomic, strong) ActionSettingsPickerView *actionSettingsPicker;
@property(nonatomic, strong) OutlineView* outlineView;
@property(nonatomic, strong) CustomModalView* customModalView;

-(void) initSettingsView;
-(void) updateSettings;
-(void) hideActionSettingsView;

@end
