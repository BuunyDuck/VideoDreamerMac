//
//  SelectTemplateVC.h
//  VideoFrame
//
//  Created by Yinjing Li on 11/13/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "YJLCustomMusicController.h"

@protocol SelectTemplateVCDelegate <NSObject>

@optional
-(void) goToLibrary;

@end

@import Photos;

@class MakeVideoVC;
@class CustomModalView;
@class SettingsView;
@class iCarousel;
@class CustomAssetPickerController;
@class ProjectGalleryPickerController;
@class MusicDownloadController;
@class MusicDownload;
@class TermsVC;
@class MediaTrimView;


@interface SelectTemplateVC : UIViewController
{
    BOOL isDeleteButtonShow;
    
    MusicDownload* musicDownload;
    TermsVC* TermsVC;
}

@property(nonatomic, weak) id <SelectTemplateVCDelegate> delegate;

@property(nonatomic, strong) IBOutlet UIButton* tempLandscapeButton;
@property(nonatomic, strong) IBOutlet UIButton* tempPortraitButton;
@property(nonatomic, strong) IBOutlet UIButton* tempInstagramButton;
@property(nonatomic, strong) IBOutlet UIButton* settingsButton;
@property(nonatomic, strong) IBOutlet UIButton* infoButton;
@property(nonatomic, strong) IBOutlet UIButton* playButton;
@property(nonatomic, strong) IBOutlet UIButton* shareProjectButton;
@property(nonatomic, strong) IBOutlet UIButton* settingsButtonForIphoneOnly;
@property(nonatomic, strong) IBOutlet UIButton* shareProjectButtonForIphoneOnly;
@property(nonatomic, strong) IBOutlet UIButton *termAndPrivacyButton;

@property(nonatomic, strong) IBOutlet UILabel* settingLbl;
@property(nonatomic, strong) IBOutlet UILabel* infoLbl;
@property(nonatomic, strong) IBOutlet UILabel *outputLbl;

@property(nonatomic, strong) IBOutlet UIView* projectView;

@property(nonatomic, strong) IBOutlet UILabel* templateLabel;
@property(nonatomic, strong) IBOutlet UILabel* playLabel;
@property(nonatomic, strong) IBOutlet UILabel* savedProjectLabel;
@property(nonatomic, strong) IBOutlet UILabel* shareProjectLabel;
@property(nonatomic, strong) IBOutlet UILabel* versionLabel;

@property(nonatomic, strong) MakeVideoVC* makeVideoVC;
@property(nonatomic, strong) CustomModalView* customModalView;
@property(nonatomic, strong) SettingsView* settingsView;
@property(nonatomic, strong) iCarousel* projectCarousel;
@property(nonatomic, strong) ProjectGalleryPickerController* projectGalleryPicker;
@property(nonatomic, strong) CustomAssetPickerController* customAssetPicker;
@property(nonatomic, strong) MusicDownloadController* musicDownloadController;
@property(nonatomic, strong) YJLCustomMusicController *musicPicker;
@property(nonatomic, strong) MediaTrimView* mediaTrimView;

@property(nonatomic, strong) NSMutableArray* projectNamesArray;
@property(nonatomic, strong) NSMutableArray* projectThumbViewArray;

@property(nonatomic, strong) PHAsset* openInProjectVideoAsset;
@property(nonatomic, strong) NSURL* openInProjectVideoUrl;

@property(nonatomic, strong) AVPlayerViewController* infoVideoPlayer;

@property(nonatomic, assign) CGFloat fTopSpacingConstant_iPhonePortrait;
@property(nonatomic, assign) CGFloat fBottomSpacingConstant_iPhonePortrait;
@property(nonatomic, assign) CGFloat fInstagramWidthConstant_iPhonePortrait;
@property(nonatomic, assign) CGFloat fPortraitCenterConstant_iPhonePortrait;

@property(nonatomic, assign) CGFloat fTopSpacingConstant_iPhoneLadscape;
@property(nonatomic, assign) CGFloat fBottomSpacingConstant_iPhoneLadscape;
@property(nonatomic, assign) CGFloat fInstagramWidthConstant_iPhoneLadscape;
@property(nonatomic, assign) CGFloat fPortraitCenterConstant_iPhoneLadscape;

@property(nonatomic, assign) CGFloat fPortraitCenterConstant_iPadPortrait;
@property(nonatomic, assign) CGFloat fPortraitCenterConstant_iPadLadscape;

-(void) detectFramePerSec;

@end
