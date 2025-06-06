//
//  KBSettingsView.h
//  VideoFrame
//
//  Created by Yinjing Li on 9/30/14.
//  Copyright (c) 2014 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol KBSettingsViewDelegate <NSObject>

@optional
-(void) didApplyKBSettingsView:(BOOL)enabled inOut:(NSInteger)inOutType scale:(CGFloat) zoomScale;
-(void) didPreviewKBSettingsView:(BOOL)enabled inOut:(NSInteger)inOutType scale:(CGFloat) zoomScale;
-(void) didStopPreview;

@end


@interface KBSettingsView : UIView
{
    BOOL mbKbEnabled;
    NSInteger mnKbIn;
    CGFloat mfKbScale;
}

@property(nonatomic,assign) id<KBSettingsViewDelegate> delegate;

@property(nonatomic, retain) IBOutlet UIButton* kbZoomButton;
@property(nonatomic, retain) IBOutlet UIButton* kbScaleButton;
@property(nonatomic, retain) IBOutlet UIButton* kbPreviewButton;
@property(nonatomic, retain) IBOutlet UIButton* kbApplyButton;
@property(nonatomic, retain) IBOutlet UIButton* kbCheckToAllButton;

@property(nonatomic, retain) IBOutlet UISwitch* kbSwitch;
@property(nonatomic, retain) IBOutlet UILabel* kbStatusLabel;
@property(nonatomic, retain) IBOutlet UILabel* kbZoomLabel;
@property(nonatomic, retain) IBOutlet UILabel* kbScaleLabel;

-(void) setKbEnabled:(BOOL) enabled;
-(void) setKbIn:(NSInteger) inOut;
-(void) setKbScale:(CGFloat) scale;

@end
