//
//  MakeVideoVC.m
//  VideoFrame
//
//  Created by Yinjing Li on 11/13/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "MakeVideoVC.h"
#import "SceneDelegate.h"
#import "VideoDreamer-Swift.h"
#import "NSDate+Extension.h"
#import "Definition.h"
#import "UIImageExtras.h"
#import "VideoEditor.h"
#import "SHKActivityIndicator.h"
#import "CustomModalView.h"
#import "PreviewView.h"
#import "MediaObjectView.h"
#import "TimelineView.h"
#import "MediaTrimView.h"
#import "OutlineView.h"
#import "ShadowView.h"
#import "TextSettingView.h"
#import "ReflectionSettingView.h"
#import "AVChooseView.h"
#import "SpeedSegmentView.h"
#import "JogEditView.h"
#import "ATMHudDelegate.h"
#import "ATMHud.h"
#import "ATMHudQueueItem.h"
#import "SettingsView.h"
#import "OpacityView.h"
#import "VolumeView.h"
#import "YJLCameraPickerController.h"
#import "YJLCustomMusicController.h"
#import "YJLActionMenu.h"
#import "YLVideoService.h"
#import "ProjectManager.h"
#import "TimelineHorizontalView.h"
#import "TimelineVerticalView.h"
#import "PhotoFiltersView.h"
#import "CustomAssetPickerController.h"
#import "KBSettingsView.h"
#import "ShapeColorView.h"
#import "ShapeGalleryPickerController.h"
#import "GIFGalleryPickerController.h"
#import "ProjectGalleryPickerController.h"
#import "VideoFiltersView.h"
#import "filterListView.h"
#import "ChromakeySettingView.h"
#import "EditTrimView.h"
#import "StingerGalleryPickerController.h"
#import "MusicDownloadController.h"
#import "MusicDownload.h"
#import "SelectTemplateVC.h"

#define SYSTEM_VERSION_EQUAL_TO_1(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN_1(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO_1(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_1(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO_1(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface MakeVideoVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, MPMediaPickerControllerDelegate, VideoEditorDelegate, PreviewViewVideoDelegate, MediaObjectDelegate, MediaTrimViewDelegate, TimelineViewDelegate, OpacityViewDelegate, VolumeViewDelegate, OutlineViewDelegate, ShadowViewDelegate, TextSettingViewDelegate, ReflectionSettingViewDelegate, AVChooseDelegate, SpeedSegmentViewDelegate, JogEditViewDelegate, CustomModalViewDelegate, ATMHudDelegate, YJLCameraOverlayDelegate, YJLCustomMusicControllerDelegate, TimelineHorizontalViewDelegate, TimelineVerticalViewDelegate, PhotoFiltersViewDelegate, CustomAssetPickerControllerDelegate, KBSettingsViewDelegate, ShapeColorViewDelegate, ShapeGalleryPickerControllerDelegate, SettingsViewDelegate, ProjectGalleryPickerControllerDelegate, VideoFiltersViewDelegate, FilterListDelegate, ChromakeySettingViewDelegate, GIFGalleryPickerControllerDelegate, EditTrimViewDelegate, StingerGalleryPickerControllerDelegate, MusicDownloadControllerDelegate, MusicDownloadDelegate, SelectTemplateVCDelegate, MFMailComposeViewControllerDelegate>
{
    BOOL isFirstWillAppear;
    BOOL isPreview;
    BOOL isPhotoTake;
    
    float tempVolume;
    
    int mnEditMediaIndex;
    int mnCurrentProcessingCount;
    int mnTotalProcessingCount;
    
    CGSize outputVideoSize;
    
    AVAsset *inputPrepareVideoAsset;
    
    NSTimer* progressTimer;
    
    BOOL isFirstLayout;
}

@end


@implementation MakeVideoVC

#pragma mark -
#pragma mark - ********** Life Cycle **********

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (gnTemplateIndex == TEMPLATE_LANDSCAPE || gnTemplateIndex == TEMPLATE_1080P)
    {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    else if (gnTemplateIndex == TEMPLATE_PORTRAIT || gnTemplateIndex == TEMPLATE_SQUARE)
    {
        return UIInterfaceOrientationMaskPortrait;
    }

    return UIInterfaceOrientationMaskPortrait;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isFirstLayout = YES;
    
    self.selectTemplateVC.delegate = self;
    
    //self.workspaceView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"workspace_pattern"]];
    self.workspaceView.layer.contents = (id)[UIImage imageNamed:@"workspace_pattern"].CGImage;

    /*********** setup media notifications **********************/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayBackDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMusicPlayerControllerVolumeDidChange:)
                                                 name:MPMusicPlayerControllerVolumeDidChangeNotification
                                               object:nil];
    
    [[MPMusicPlayerController applicationMusicPlayer] beginGeneratingPlaybackNotifications];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleInterruption:)
                                                 name: AVAudioSessionInterruptionNotification
                                               object: [AVAudioSession sharedInstance]];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    /***************************************************************/

    /****************** init UI ************************************/
    isFirstWillAppear = YES;
    gnSelectedObjectIndex = 0;
    isPhotoTake = YES;
    isMultiplePhotos = NO;
    isReplace = NO;
    grZoomScale = 1.0f;
    gnZoomType = ZOOM_BOTH;
    isActionChangeAll = NO;
    isKenBurnsChangeAll = NO;
    isWorkspace = YES;
    
    UIImage *minImage = [UIImage imageNamed:@"slider_min"];
    UIImage *maxImage = [UIImage imageNamed:@"slider_max_gray"];
    UIImage *tumbImage = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        tumbImage = [UIImage imageNamed:@"slider_thumb"];
    else
        tumbImage = [UIImage imageNamed:@"slider_thumb_ipad"];
    
    minImage = [minImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    maxImage = [maxImage stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    
    [self.seekSlider setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [self.seekSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [self.seekSlider setThumbImage:tumbImage forState:UIControlStateNormal];
    [self.seekSlider setThumbImage:tumbImage forState:UIControlStateHighlighted];
    [self.seekSlider setBackgroundColor:[UIColor clearColor]];
    [self.seekSlider setValue:0.0f];
    [self.seekSlider setMinimumValue:0.0f];
    
    self.currentSeekTimeLabel.text = @"00:00.000";
    self.totalSeekTimeLabel.text = @"00:00.000";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
    if (isFirstLayout) {
        isFirstLayout = NO;
        
        [self.view layoutIfNeeded];
        
        if (!gstrCurrentProjectName)
        {
            gstrCurrentProjectName = [self.projectManager createNewProject];
            
            [self.projectNameLabel setText:[NSString stringWithFormat:@"%@", gstrCurrentProjectName]];
            [self.totalTimeLabel setText:@"00:00.000"];
            
            if (self.openInProjectVideoUrl)
            {
                [self loadVideoInProject];
            }
        }
        else
        {
            self.projectManager.projectName = gstrCurrentProjectName;

            [self performSelector:@selector(decodeProject) withObject:nil afterDelay:0.5f];
        }
        
        //fix orientation
        [self fixDeviceOrientation];
        
        self.workspaceView.autoresizingMask = UIViewAutoresizingNone;
        
        self.timelineView.frame = CGRectMake(self.timelineView.frame.origin.x + safeAreaInsets.left, self.timelineView.frame.origin.y, self.timelineView.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, self.timelineView.frame.size.height);
        self.horizontalBgView.frame = CGRectMake(self.timelineView.frame.origin.x, self.timelineView.frame.origin.y + self.timelineView.frame.size.height, self.timelineView.frame.size.width, grSliderHeightMax * 1.5f);
        [self.horizontalBgView setContentSize:CGSizeMake(self.timelineView.contentSize.width, 0.0f)];
        [self.horizontalBgView setTotalTime:self.timelineView.totalTime];
        
        /* select tap gesture */
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(workspaceTapped:)];
        selectGesture.delegate = self;
        [self.workspaceView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];

        //grid layer
        self.gridLayer = [CAShapeLayer layer];
        self.gridLayer.frame = self.workspaceView.bounds;
        [self.gridLayer setFillColor:[[UIColor clearColor] CGColor]];
        [self.gridLayer setStrokeColor:[[UIColor whiteColor] CGColor]];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [self.gridLayer setLineWidth:1.0f];
        } else {
            [self.gridLayer setLineWidth:2.0f];
        }
        [self.gridLayer setLineJoin:kCALineJoinRound];
        [self.gridLayer setLineDashPattern: [NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:6],nil]];
        [self.gridLayer setShadowColor:[[UIColor blackColor] CGColor]];
        [self.gridLayer setShadowOffset:CGSizeMake(1.0f, 1.0f)];
        [self.gridLayer setShadowOpacity:1.0f];
        [self.workspaceView.layer addSublayer:self.gridLayer];
        self.gridLayer.hidden = YES;
        
        self.gridLayer.frame = CGRectMake(0, 0, outputVideoSize.width, outputVideoSize.height);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, self.gridLayer.frame.size.width / 3.0, -10.0);
        CGPathAddLineToPoint(path, NULL, self.gridLayer.frame.size.width / 3.0, self.gridLayer.frame.size.height + 10.0);
        CGPathMoveToPoint(path, NULL, self.gridLayer.frame.size.width / 3.0 * 2.0, -10.0);
        CGPathAddLineToPoint(path, NULL, self.gridLayer.frame.size.width / 3.0 * 2.0, self.gridLayer.frame.size.height + 10.0);
        CGPathMoveToPoint(path, NULL, -10, self.gridLayer.frame.size.height / 3.0);
        CGPathAddLineToPoint(path, NULL, self.gridLayer.frame.size.width + 10.0, self.gridLayer.frame.size.height / 3.0);
        CGPathMoveToPoint(path, NULL, -10, self.gridLayer.frame.size.height * 2.0 / 3.0);
        CGPathAddLineToPoint(path, NULL, self.gridLayer.frame.size.width + 10.0, self.gridLayer.frame.size.height * 2.0 / 3.0);
        [self.gridLayer setPath:path];
        CGPathRelease(path);
        
        [self.playingButton setEnabled:NO];
        [self.playingButton setTag:0];
        [self.seekSlider setEnabled:NO];
        [self.currentSeekTimeLabel setText:@"00:00.000"];
        [self.totalSeekTimeLabel setText:@"00:00.000"];
        
        /************************ Buttons on the workspace ********************************/
        float font_2x = 1.0f;
        float label_2x = 1.0f;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            font_2x = 1.2f;
            label_2x = 1.0f;
        } else {
            font_2x = 1.6f;
            label_2x = 1.4f;
        }
        
        UIImage* selectedBackgroundImage = [self makeBackgroundImage:self.saveButton.bounds.size];
        
        /* New */
        [self.saveButton.titleLabel setFont: [UIFont fontWithName:MYRIADPRO size:FONT_SIZE * font_2x]];
        self.saveButton.titleLabel.numberOfLines = 1;
        self.saveButton.backgroundColor = UIColorFromRGB(0x53585f);
        [self.saveButton setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
        [self.saveButton setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected|UIControlStateHighlighted];
        self.saveButton.layer.masksToBounds = NO;
        self.saveButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.saveButton.layer.borderWidth = 1.0f;
        self.saveButton.layer.cornerRadius = 2.0f;
        [self.saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        
        /* Timeline */
        self.timelineButton.layer.masksToBounds = NO;
        self.timelineButton.backgroundColor = UIColorFromRGB(0x53585f);
        self.timelineButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.timelineButton.layer.borderWidth = 1.0f;
        self.timelineButton.layer.cornerRadius = 2.0f;

        /* A/V button */
        [self.avButton.titleLabel setFont: [UIFont fontWithName:MYRIADPRO size:FONT_SIZE * font_2x]];
        self.avButton.titleLabel.numberOfLines = 1;
        self.avButton.backgroundColor = UIColorFromRGB(0x53585f);
        [self.avButton setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
        [self.avButton setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected|UIControlStateHighlighted];
        self.avButton.layer.masksToBounds = NO;
        self.avButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.avButton.layer.borderWidth = 1.0f;
        self.avButton.layer.cornerRadius = 2.0f;
        self.avButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.avButton.titleLabel.minimumScaleFactor = 0.1f;
        [self.avButton setTitle:NSLocalizedString(@"A/V", nil) forState:UIControlStateNormal];

        /* grid button */
        self.gridButton.backgroundColor = UIColorFromRGB(0x53585f);
        [self.gridButton setBackgroundImage:selectedBackgroundImage forState:UIControlStateHighlighted];
        [self.gridButton setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected|UIControlStateHighlighted];
        self.gridButton.layer.masksToBounds = NO;
        self.gridButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.gridButton.layer.borderWidth = 1.0f;
        self.gridButton.layer.cornerRadius = 2.0f;
        self.gridButton.tag = 1;

        /* init media object */
        if (self.mediaObjectArray != nil)
        {
            [self.mediaObjectArray removeAllObjects];
            self.mediaObjectArray = nil;
        }
        self.mediaObjectArray = [[NSMutableArray alloc] init];
        
        CGRect menuFrame = CGRectZero;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            menuFrame = [UIScreen mainScreen].bounds;
        }
        else
        {
            menuFrame = self.view.bounds;

            if (gnTemplateIndex == TEMPLATE_LANDSCAPE)
                menuFrame = self.view.bounds;//CGRectMake(0.0f, 0.0f, menuFrame.size.height, menuFrame.size.width);
            else if (gnTemplateIndex == TEMPLATE_PORTRAIT)
                menuFrame = self.view.bounds;
            else if (gnTemplateIndex == TEMPLATE_1080P)
                menuFrame = self.view.bounds;//CGRectMake(0.0f, 0.0f, menuFrame.size.height, menuFrame.size.width);
            else if (gnTemplateIndex == TEMPLATE_SQUARE)
                menuFrame = self.view.bounds;
        }
        
        self.photoFiltersView = [[PhotoFiltersView alloc] initWithFrame:menuFrame superView:self.view];
        self.photoFiltersView.delegate = self;
        [self.view addSubview:self.photoFiltersView];
        self.photoFiltersView.hidden = YES;
        
        self.videoFiltersView = [[VideoFiltersView alloc] initWithFrame:menuFrame superView:self.view];
        self.videoFiltersView.delegate = self;
        [self.view addSubview:self.videoFiltersView];
        self.videoFiltersView.hidden = YES;
        
        /*************************** ProgressView ******************************/
        self.hudProgressView = [[ATMHud alloc] initWithDelegate:self];
        self.hudProgressView.delegate = self;
        [self.view addSubview:self.hudProgressView.view];
        self.hudProgressView.view.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);

        [self.totalTimeLabel setFont:[UIFont fontWithName:MYRIADPRO size:FONT_SIZE * font_2x]];
        self.totalTimeLabel.textColor = [UIColor blackColor];
        [self.totalTimeLabel setText:@""];

        [self.projectNameLabel setFont:[UIFont fontWithName:MYRIADPRO size:FONT_SIZE * font_2x]];
        self.projectNameLabel.textColor = [UIColor blackColor];
        self.projectNameLabel.text = @"";
        
        self.currentSeekTimeLabel.font = [UIFont fontWithName:MYRIADPRO size:FONT_SIZE * label_2x];
        self.totalSeekTimeLabel.font = self.currentSeekTimeLabel.font;
        
        if ((gnTemplateIndex == TEMPLATE_LANDSCAPE) || (gnTemplateIndex == TEMPLATE_1080P))
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                self.playingButton.center = CGPointMake(self.playingButton.center.x - 20.0f, self.playingButton.center.y);
                self.projectNameLabel.frame = CGRectMake(self.projectNameLabel.frame.origin.x, self.projectNameLabel.frame.origin.y, 200.0f, self.projectNameLabel.frame.size.height);
                self.projectNameLabel.center = CGPointMake(self.view.bounds.size.width / 2.0f - 20.0f, self.timelineButton.center.y);
                self.totalTimeLabel.center = CGPointMake(self.view.bounds.size.width / 2.0f + self.totalTimeLabel.bounds.size.width / 4.0f + 10.0f, self.timelineButton.center.y);
            }
            else
            {
                self.playingButton.center = CGPointMake(self.playingButton.center.x - 30.0f, self.playingButton.center.y);
                self.projectNameLabel.frame = CGRectMake(self.playingButton.frame.origin.x + self.playingButton.frame.size.width - 20.0f, self.projectNameLabel.frame.origin.y, 300.0f, self.projectNameLabel.frame.size.height);
                self.projectNameLabel.center = CGPointMake(self.projectNameLabel.center.x + 50.0f, self.timelineButton.center.y);
                self.totalTimeLabel.center = CGPointMake(self.view.bounds.size.width / 2.0f + self.totalTimeLabel.bounds.size.width / 2.0f + 20.0f, self.timelineButton.center.y);
            }
        }

        self.editScrollBgView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
        self.editScrollBgView.layer.cornerRadius = 5.0f;
        
        self.editThumbnailArray = [[NSMutableArray alloc] init];
        
        //Ken Burns Settings View
        self.kenBurnsSettingsView.delegate = self;
        self.kenBurnsSettingsView.hidden = YES;
        self.kenBurnsSettingsView.layer.cornerRadius = 5.0f;
        
        //remove temp directory
        NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
        for (NSString *file in tmpDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
        }
        
        self.editRightButton.hidden = YES;
        self.editLeftButton.hidden = YES;
    }
    
    CGSize mainScreenBoundsSize = [UIScreen mainScreen].bounds.size;
    if (gnTemplateIndex == TEMPLATE_SQUARE || gnTemplateIndex == TEMPLATE_PORTRAIT) {
        mainScreenBoundsSize = CGSizeMake(fminf(mainScreenBoundsSize.width, mainScreenBoundsSize.height), fmaxf(mainScreenBoundsSize.width, mainScreenBoundsSize.height));
    } else {
        mainScreenBoundsSize = CGSizeMake(fmaxf(mainScreenBoundsSize.width, mainScreenBoundsSize.height), fminf(mainScreenBoundsSize.width, mainScreenBoundsSize.height));
    }
    
    CGFloat workspaceOffset = 0.0;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        if (gnTemplateIndex == TEMPLATE_SQUARE) {
            self.workspaceView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - (mainScreenBoundsSize.width - 24.0f)) / 2.0f, ([UIScreen mainScreen].bounds.size.height - (mainScreenBoundsSize.width - 24.0f)) / 2.0f, (mainScreenBoundsSize.width - 24.0f), (mainScreenBoundsSize.width - 24.0f));
            workspaceOffset = 24.0;
        } else if (gnTemplateIndex == TEMPLATE_1080P) {
            CGFloat offset = 88.0f;
            if (self.view.safeAreaInsets.left >= 20) {
                offset = 108.0f;
            }
            self.workspaceView.frame = CGRectMake((mainScreenBoundsSize.width - 1920.0f / (1080.0f / (mainScreenBoundsSize.height - offset))) / 2.0f, (mainScreenBoundsSize.height - (mainScreenBoundsSize.height - offset)) / 2.0f - offset * 0.3, 1920.0f / (1080.0f / (mainScreenBoundsSize.height - offset)), mainScreenBoundsSize.height - offset);
            workspaceOffset = 28.0;
            if (self.view.safeAreaInsets.left >= 20) {
                workspaceOffset = 20.0;
            }
        } else if (gnTemplateIndex == TEMPLATE_PORTRAIT) {
            self.workspaceView.frame = CGRectMake((mainScreenBoundsSize.width - (mainScreenBoundsSize.width - 32.0f)) / 2.0f, (mainScreenBoundsSize.height - (mainScreenBoundsSize.width - 32.0f) * 420.0f / 280.0f) / 2.0f, (mainScreenBoundsSize.width - 32.0f), (mainScreenBoundsSize.width - 32.0f) * 420.0f / 280.0f);
            workspaceOffset = 20.0;
        } else if (gnTemplateIndex == TEMPLATE_LANDSCAPE) {
            CGFloat offset = 82.0f;
            if (self.view.safeAreaInsets.left >= 20) {
                offset = 82.0f;
            }
            self.workspaceView.frame = CGRectMake((mainScreenBoundsSize.width - (mainScreenBoundsSize.height - offset - safeAreaInsets.bottom) * 420.0f / 280.0f) / 2.0f, (mainScreenBoundsSize.height - (mainScreenBoundsSize.height - offset)) / 2.0f - offset * 0.3, (mainScreenBoundsSize.height - offset) * 420.0f / 280.0f, (mainScreenBoundsSize.height - offset - safeAreaInsets.bottom));
            workspaceOffset = 20.0;
        }
    }
    else //iPad
    {
#if TARGET_OS_MACCATALYST
        if (gnTemplateIndex == TEMPLATE_PORTRAIT || gnTemplateIndex == TEMPLATE_SQUARE) {
            mainScreenBoundsSize = SCREEN_FRAME_PORTRAIT.size;
            self.view.frame = SCREEN_FRAME_PORTRAIT;
        } else {
            mainScreenBoundsSize = SCREEN_FRAME_LANDSCAPE.size;
            self.view.frame = SCREEN_FRAME_LANDSCAPE;
        }
        [self.view layoutIfNeeded];
#endif
        CGFloat width = mainScreenBoundsSize.width;
        CGFloat height = mainScreenBoundsSize.height;
        if (gnTemplateIndex == TEMPLATE_SQUARE) {
            width = mainScreenBoundsSize.width - 136.0f;
            height = width;
            workspaceOffset = 48.0;
        } else if (gnTemplateIndex == TEMPLATE_1080P) {
            if (mainScreenBoundsSize.width == 1180 || mainScreenBoundsSize.width == 1194) {
                width = mainScreenBoundsSize.width - 176.0f;
                height = width * 1080.0f / 1920.0f;
                workspaceOffset = 36.0;
            } else if (mainScreenBoundsSize.width == 1133) {
                width = mainScreenBoundsSize.width - 256.0f;
                height = width * 1080.0f / 1920.0f;
                workspaceOffset = 24.0;
            } else {
                width = mainScreenBoundsSize.width - 136.0f;
                height = width * 1080.0f / 1920.0f;
                workspaceOffset = 32.0;
            }
        } else if (gnTemplateIndex == TEMPLATE_PORTRAIT) {
            if (mainScreenBoundsSize.width == 768) {
                width = mainScreenBoundsSize.width - 248.0f;
                workspaceOffset = 32.0;
            } else if (mainScreenBoundsSize.width == 744) {
                width = mainScreenBoundsSize.width - 168.0f;
                workspaceOffset = 24.0;
            } else if (mainScreenBoundsSize.width == 834) {
                width = mainScreenBoundsSize.width - 208.0f;
                workspaceOffset = 34.0;
            } else if (mainScreenBoundsSize.width == 820) {
                width = mainScreenBoundsSize.width - 208.0f;
                workspaceOffset = 24.0;
            } else if (mainScreenBoundsSize.width == 810) {
                width = mainScreenBoundsSize.width - 248.0f;
                workspaceOffset = 32.0;
            } else if (mainScreenBoundsSize.width == 1024) {
                width = mainScreenBoundsSize.width - 298.0f;
                workspaceOffset = 30.0;
            } else {
                width = mainScreenBoundsSize.width - 258.0f;
            }
            height = width * 1.5f;
        } else if (gnTemplateIndex == TEMPLATE_LANDSCAPE) {
            if (mainScreenBoundsSize.width == 1024) {
                width = mainScreenBoundsSize.width - 218.0f;
                workspaceOffset = 40.0;
            } else if (mainScreenBoundsSize.width == 1133) {
                width = mainScreenBoundsSize.width - 368.0f;
                workspaceOffset = 30.0;
            } else if (mainScreenBoundsSize.width == 1080) {
                width = mainScreenBoundsSize.width - 218.0f;
                workspaceOffset = 40.0;
            } else if (mainScreenBoundsSize.width == 1194) {
                width = mainScreenBoundsSize.width - 328.0f;
                workspaceOffset = 36.0;
            } else if (mainScreenBoundsSize.width == 1180) {
                width = mainScreenBoundsSize.width - 328.0f;
                workspaceOffset = 36.0;
            } else if (mainScreenBoundsSize.width == 1366) {
                width = mainScreenBoundsSize.width - 288.0f;
                workspaceOffset = 36.0;
            } else {
                width = mainScreenBoundsSize.width - 148.0f;
            }
            height = width / 1.5f;
        }
        self.workspaceView.frame = CGRectMake((mainScreenBoundsSize.width - width) / 2.0f, (mainScreenBoundsSize.height - height) / 2.0f, width, height);
    }
    
    outputVideoSize = self.workspaceView.bounds.size;

    float rScaleY = self.workspaceView.frame.size.height / outputVideoSize.height;
    self.workspaceView.frame = CGRectMake(self.workspaceView.frame.origin.x + self.workspaceView.frame.size.width / 2.0 - outputVideoSize.width / 2.0, self.workspaceView.frame.origin.y + self.workspaceView.frame.size.height / 2.0 - outputVideoSize.height / 2.0 + workspaceOffset, outputVideoSize.width, outputVideoSize.height);
    self.workspaceView.transform = CGAffineTransformMakeScale(rScaleY, rScaleY);
    
    self.previewView.frame = self.view.bounds;
    
    self.photoFiltersView.frame = self.view.bounds;
    
    self.videoFiltersView.frame = self.view.bounds;
    
    float seekSliderY = CGRectGetMaxY(self.playingButton.frame) + ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 20.0 : 26.0);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && (gnTemplateIndex == TEMPLATE_1080P || gnTemplateIndex == TEMPLATE_LANDSCAPE)) {
        seekSliderY = self.playingButton.frame.origin.y - 2.0;
    }
    float seekSliderX = 0.0;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && gnTemplateIndex == TEMPLATE_1080P && mainScreenBoundsSize.height <= 667.0) {
        seekSliderX = 32.0;
    }
    float seekLabelOffsetY = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 1.0 : 2.0;
    self.seekSlider.frame = CGRectMake(self.workspaceView.frame.origin.x + self.currentSeekTimeLabel.frame.size.width + 12.0 + seekSliderX, seekSliderY, self.workspaceView.frame.size.width - self.currentSeekTimeLabel.frame.size.width - self.totalSeekTimeLabel.frame.size.width - 24.0 - seekSliderX * 2.0, self.seekSlider.frame.size.height);
    self.currentSeekTimeLabel.frame = CGRectMake(self.workspaceView.frame.origin.x + seekSliderX, self.seekSlider.center.y - self.currentSeekTimeLabel.frame.size.height / 2.0 + seekLabelOffsetY, self.currentSeekTimeLabel.frame.size.width, self.currentSeekTimeLabel.frame.size.height);
    self.totalSeekTimeLabel.frame = CGRectMake(self.workspaceView.frame.origin.x + self.workspaceView.frame.size.width - self.totalSeekTimeLabel.frame.size.width - seekSliderX, self.seekSlider.center.y - self.totalSeekTimeLabel.frame.size.height / 2.0 + seekLabelOffsetY, self.totalSeekTimeLabel.frame.size.width, self.totalSeekTimeLabel.frame.size.height);
    
    CGFloat width = gnOrientation == ORIENTATION_LANDSCAPE ? MAX(self.view.bounds.size.width, self.view.bounds.size.height) : MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    self.timelineView.frame = CGRectMake(grSliderHeightMax * 0.5f + safeAreaInsets.left, self.timelineView.frame.origin.y, width - grSliderHeightMax - safeAreaInsets.left - safeAreaInsets.right, self.timelineView.frame.size.height);
    self.horizontalBgView.frame = CGRectMake(self.timelineView.frame.origin.x, self.timelineView.frame.origin.y + self.timelineView.frame.size.height, self.timelineView.frame.size.width, grSliderHeightMax * 1.5f);
    [self.horizontalBgView setContentSize:CGSizeMake(self.timelineView.contentSize.width, 0.0f)];
    [self.horizontalBgView setTotalTime:self.timelineView.totalTime];
    
    self.workspaceBackgroundView.frame = self.workspaceView.frame;
    
    CGRect frame = self.horizontalLineImageView.frame;
    frame.origin.y = self.workspaceView.frame.origin.y;
    frame.size.height = self.workspaceView.frame.size.height;
    self.horizontalLineImageView.frame = frame;
    
    frame = self.verticalLineImageView.frame;
    frame.origin.x = self.workspaceView.frame.origin.x;
    frame.size.width = self.workspaceView.frame.size.width;
    self.verticalLineImageView.frame = frame;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/* hidden status bar in iOS7 */
-(BOOL) prefersStatusBarHidden
{
    return YES;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self fixDeviceOrientation];
}

-(void) checkEditArrowButtons {
    if (self.mediaObjectArray.count > 1)
    {
        self.editLeftButton.hidden = NO;
        self.editRightButton.hidden = NO;
    }
    else
    {
        self.editLeftButton.hidden = YES;
        self.editRightButton.hidden = YES;
    }
}

#pragma mark -
#pragma mark - viewWillAppear

-(void) viewWillAppear:(BOOL)animated
{
    isWorkspace = YES;

    [super viewWillAppear:animated];
    
    if (isFirstWillAppear)
    {
        isFirstWillAppear = NO;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            grSliderHeight = 35.0f;
            grSliderHeightMax = 35.0f;
        }
        else
        {
            grSliderHeight = 50.0f;
            grSliderHeightMax = 50.0f;
        }
        
        /* preview view */
        if (self.previewView != nil)
        {
            [self.previewView removeFromSuperview];
            self.previewView = nil;
        }
        
        //UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
        self.previewView = [[PreviewView alloc] initWithFrame:self.view.bounds];
        //self.previewView = [[PreviewView alloc] initWithFrame:CGRectMake(safeAreaInsets.top, safeAreaInsets.left, self.view.frame.size.width - safeAreaInsets.left - safeAreaInsets.right, self.view.frame.size.height - safeAreaInsets.top - safeAreaInsets.bottom)];
        self.previewView.delegate = self;
        [self.view addSubview:self.previewView];
        self.previewView.hidden = YES;


        /* timeline view */
        if (self.timelineView != nil)
        {
            [self.timelineView deleteAllSliders];
            [self.timelineView removeFromSuperview];
            self.timelineView = nil;
        }

        CGFloat width = gnOrientation == ORIENTATION_LANDSCAPE ? MAX(self.view.bounds.size.width, self.view.bounds.size.height) : MIN(self.view.bounds.size.width, self.view.bounds.size.height);
        CGFloat height = gnOrientation == ORIENTATION_LANDSCAPE ? MIN(self.view.bounds.size.width, self.view.bounds.size.height) : MAX(self.view.bounds.size.width, self.view.bounds.size.height);
        CGRect bounds = CGRectMake(0, 0, width, height);
        self.timelineView = [[TimelineView alloc] initWithFrame:CGRectMake(grSliderHeightMax * 0.5f, self.timelineButton.frame.origin.y + self.timelineButton.frame.size.height, bounds.size.width - grSliderHeightMax, self.editButtonsView.frame.origin.y - self.timelineButton.frame.origin.y - self.timelineButton.frame.size.height - grSliderHeightMax * 0.5f)];
        [self.timelineView setTimelineDelegate:self];
        [self.timelineView setHidden:YES];
        [self.view addSubview:self.timelineView];


        /* vertical Bg View */
        self.verticalBgView = [[TimelineVerticalView alloc] initWithFrame:CGRectMake(self.timelineView.frame.origin.x + self.timelineView.frame.size.width, self.timelineView.frame.origin.y - grSliderHeightMax * (gnVisibleMaxCount - 1), grSliderHeightMax * 0.5f, grSliderHeightMax * gnVisibleMaxCount)];
        [self.view addSubview:self.verticalBgView];
        [self.verticalBgView setDelegate:self];
        [self.verticalBgView setUserInteractionEnabled:YES];
        [self.verticalBgView setHidden:YES];

        
        /* horizontal Bg View */
        self.horizontalBgView = [[TimelineHorizontalView alloc] initWithFrame:CGRectMake(self.timelineView.frame.origin.x, self.timelineView.frame.origin.y + self.timelineView.frame.size.height, self.timelineView.frame.size.width, grSliderHeightMax * 1.5f)];
        [self.view addSubview:self.horizontalBgView];
        [self.horizontalBgView setDelegate:self];
        [self.horizontalBgView setUserInteractionEnabled:YES];
        [self.horizontalBgView setHidden:YES];
        [self.horizontalBgView setContentSize:CGSizeMake(self.timelineView.contentSize.width, 0.0f)];
        [self.horizontalBgView setTotalTime:self.timelineView.totalTime];


        if (gnStartWithType == START_WITH_PHOTOCAM)
            [self onPhotoFromCamera];
        else if (gnStartWithType == START_WITH_VIDEOCAM)
            [self onVideoFromCamera];
        
        [self fixDeviceOrientation];
        
        
        //Project Manager
        self.projectManager = [[ProjectManager alloc] init];
    }
}

-(void) loadVideoInProject
{
    [self generationVideoView:self.openInProjectVideoUrl flag:NO];
    
    [self updateObjectEdit];
}

-(void) decodeProject
{
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"project.plist"];
    
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
    
    int objectArrayCount = [[plistDict objectForKey:@"ObjectArrayCount"] intValue];
    
    grNormalFilterOutputTotalTime = [[plistDict objectForKey:@"gfNormalFilterOutputTotalTime"] floatValue];

    for (int i = 0; i < objectArrayCount; i++)
    {
        int mediaType = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mediaType", i]] intValue];

        if (mediaType == MEDIA_PHOTO)
        {
            NSString* imageName = [plistDict objectForKey:[NSString stringWithFormat:@"%d-imageName", i]];
            
            [self generationImageView:imageName];
        }
        else if (mediaType == MEDIA_GIF)
        {
            NSString* gifName = [plistDict objectForKey:[NSString stringWithFormat:@"%d-gifName", i]];
            
            [self generationGIFImageView:gifName];
        }
        else if (mediaType == MEDIA_VIDEO)
        {
            NSString* videoName = [plistDict objectForKey:[NSString stringWithFormat:@"%d-videoName", i]];
            NSString* urlStr = [folderPath stringByAppendingPathComponent:videoName];
            NSURL* mediaUrl = [NSURL fileURLWithPath:urlStr];
            
            NSArray *motions = nil;
            NSArray *startPositions = nil;
            NSArray *endPositions = nil;
            if ([plistDict objectForKey:[NSString stringWithFormat:@"%d-motionArray", i]])
            {
                motions = [plistDict objectForKey:[NSString stringWithFormat:@"%d-motionArray", i]];
                startPositions = [plistDict objectForKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
                endPositions = [plistDict objectForKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            }

            [self didCompletedTrim:mediaUrl type:MEDIA_VIDEO motions:motions startPositions:startPositions endPositions:endPositions];
        }
        else if (mediaType == MEDIA_MUSIC)
        {
            NSString *musicName = [plistDict objectForKey:[NSString stringWithFormat:@"%d-musicName", i]];
            NSString *urlStr = [folderPath stringByAppendingPathComponent:musicName];
            NSURL *mediaUrl = [NSURL fileURLWithPath:urlStr];
            
            NSArray *motions = nil;
            NSArray *startPositions = nil;
            NSArray *endPositions = nil;
            if ([plistDict objectForKey:[NSString stringWithFormat:@"%d-motionArray", i]])
            {
                motions = [plistDict objectForKey:[NSString stringWithFormat:@"%d-motionArray", i]];
                startPositions = [plistDict objectForKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
                endPositions = [plistDict objectForKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            }
            
            [self didCompletedTrim:mediaUrl type:MEDIA_MUSIC motions:motions startPositions:startPositions endPositions:endPositions];
        }
        else if (mediaType == MEDIA_TEXT)
        {
            if (self.mediaObjectArray == nil)
                self.mediaObjectArray = [[NSMutableArray alloc] init];
         
            NSString* text = [plistDict objectForKey:[NSString stringWithFormat:@"%d-text", i]];

            MediaObjectView* object = [[MediaObjectView alloc] initWithText:text size:self.workspaceView.bounds.size];
            object.delegate = self;
            [self.mediaObjectArray addObject:object];
            [object setIndex:((int)self.mediaObjectArray.count - 1)];
            [self.workspaceView addSubview:object];
            [object object_actived];
            
            [self.timelineView addNewTimeLine:object];

            [object.textView resignFirstResponder];
        }
        
        if ((mediaType == MEDIA_PHOTO) || (mediaType == MEDIA_GIF) || (mediaType == MEDIA_VIDEO) || (mediaType == MEDIA_TEXT))
        {
            MediaObjectView* object = [self.mediaObjectArray lastObject];
            object.mediaType = mediaType;

            object.superViewSize = CGSizeFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-superViewSize", i]]);
            
            CGFloat rX, rY, rScale;
            
            if (object.superViewSize.width != self.workspaceView.bounds.size.width)
            {
                rX = self.workspaceView.bounds.size.width / object.superViewSize.width;
                rY = self.workspaceView.bounds.size.height / object.superViewSize.height;
                
                if (rX >= rY)
                {
                    if (rX >= 1.0f)
                        rScale = rX;
                    else
                        rScale = rY;
                }
                else
                {
                    if (rY >= 1.0f)
                        rScale = rY;
                    else
                        rScale = rX;
                }
                
                object.superViewSize = CGSizeMake(self.workspaceView.bounds.size.width, self.workspaceView.bounds.size.height);
            }
            else
            {
                rX = 1.0f;
                rY = 1.0f;
                rScale = 1.0f;
            }
            
            object.workspaceSize = CGSizeFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-workspaceSize", i]]);
            object.isPlaying = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-isPlaying", i]] boolValue];
            object.mediaDuration = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mediaDuration", i]] floatValue];
            object.mediaVolume = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mediaVolume", i]] floatValue];
            object.inputTransform = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-inputTransform", i]]);
            
            CGRect tempRect = CGRectFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-mediaViewFrame", i]]);
            object.mediaView.frame = CGRectMake(tempRect.origin.x * rX, tempRect.origin.y * rY, tempRect.size.width * rScale, tempRect.size.height * rScale);
            
            tempRect = CGRectFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-imageViewFrame", i]]);
            object.imageView.frame = CGRectMake(tempRect.origin.x * rX, tempRect.origin.y * rY, tempRect.size.width * rScale, tempRect.size.height * rScale);
            
            tempRect = CGRectFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-videoViewFrame", i]]);
//            object.videoView.frame = CGRectMake(tempRect.origin.x * rX, tempRect.origin.y * rY, tempRect.size.width * rScale, tempRect.size.height * rScale);
            object.videoView.frame = CGRectMake(tempRect.origin.x, tempRect.origin.y, tempRect.size.width * rScale, tempRect.size.height * rScale);
            
            object.nationalVideoTransform = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-nationalVideoTransform", i]]);
            object.nationalVideoTransformOutputValue = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-nationalVideoTransformOutputValue", i]]);
            object.nationalReflectionVideoTransformOutputValue = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-nationalReflectionVideoTransformOutputValue", i]]);
            
            object.nationalVideoTransform = CGAffineTransformScale(object.nationalVideoTransform, rScale, rScale);
            object.nationalVideoTransformOutputValue = CGAffineTransformScale(object.nationalVideoTransformOutputValue, rScale, rScale);
            object.nationalVideoTransformOutputValue = CGAffineTransformScale(object.nationalVideoTransformOutputValue, rScale, rScale);

            object.mfStartPosition = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mfStartPosition", i]] floatValue];
            object.mfEndPosition = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mfEndPosition", i]] floatValue];
            object.mfStartAnimationDuration = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mfStartAnimationDuration", i]] floatValue];
            object.mfEndAnimationDuration = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mfEndAnimationDuration", i]] floatValue];
            object.startActionType = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-startActionType", i]] intValue];
            object.endActionType = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-endActionType", i]] intValue];
            
            tempRect = CGRectFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-frame", i]]);
            object.frame = CGRectMake(tempRect.origin.x * rX, tempRect.origin.y * rY, tempRect.size.width * rScale, tempRect.size.height * rScale);
            
            tempRect = CGRectFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-bounds", i]]);
            object.bounds = CGRectMake(tempRect.origin.x * rX, tempRect.origin.y * rY, tempRect.size.width * rScale, tempRect.size.height * rScale);
            
            object.transform = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-transform", i]]);
            object.lastScaleFactor = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-lastScaleFactor", i]] floatValue];
            object.firstX = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-firstX", i]] floatValue];
            object.firstY = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-firstY", i]] floatValue];
            object.lastPoint = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-lastPoint", i]]);
            object.videoTransform = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-videoTransform", i]]);
            object.firstTouchedPoint = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-firstTouchedPoint", i]]);
            object.boundMode = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-boundMode", i]] integerValue];
            object.rotateAngle = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-rotateAngle", i]] floatValue];
            object.scaleValue = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-scaleValue", i]] floatValue];
            object.portraitSpecialScale = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-portraitSpecialScale", i]] floatValue];
            
            tempRect = CGRectFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-originalBounds", i]]);
            object.originalBounds = CGRectMake(tempRect.origin.x * rX, tempRect.origin.y * rY, tempRect.size.width * rScale, tempRect.size.height * rScale);

            object.normalFilterVideoCropRect = CGRectFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-normalFilterVideoCropRect", i]]);
            object.mySX = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mySX", i]] floatValue];
            object.mySY = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mySY", i]] floatValue];
            object.maskArrowTop.transform = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-maskArrowTransform", i]]);
            object.maskArrowLeft.transform = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-maskArrowTransform", i]]);
            object.maskArrowRight.transform = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-maskArrowTransform", i]]);
            object.maskArrowBottom.transform = CGAffineTransformFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-maskArrowTransform", i]]);
            object.maskArrowLeft.center = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-maskArrowLeftCenter", i]]);
            object.maskArrowRight.center = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-maskArrowRightCenter", i]]);
            object.maskArrowTop.center = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-maskArrowTopCenter", i]]);
            object.maskArrowBottom.center = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-maskArrowBottomCenter", i]]);
            object.selectedLineLayer.lineWidth = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-selectedLineLayerLineWidth", i]] floatValue];
            object.isKbEnabled = NO;
            
            id isKenBurn = [plistDict objectForKey:[NSString stringWithFormat:@"%d-isKbEnabled", i]];
            
            if (isKenBurn != nil)
            {
                object.isKbEnabled = [isKenBurn boolValue];
                object.nKbIn = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-nKbIn", i]] integerValue];
                object.fKbScale = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-fKbScale", i]] floatValue];
                
                if ([plistDict objectForKey:[NSString stringWithFormat:@"%d-kbFocusPoint", i]] != nil)
                    object.kbFocusPoint = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-kbFocusPoint", i]]);
                else
                    object.kbFocusPoint = CGPointMake(0.5f, 0.5f);
                
                object.kbFocusImageView.center = CGPointMake(object.bounds.size.width * object.kbFocusPoint.x, object.bounds.size.height * object.kbFocusPoint.y);
            }
            
            if (object.mediaType == MEDIA_PHOTO)
                [object changeImageMaskBound:nil];
            else if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
                [object changeVideoMaskBound:nil];
            
            object.borderLineLayer.frame = CGRectFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-borderLineLayerFrame", i]]);
            object.objectBorderStyle = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectBorderStyle", i]] intValue];
            object.objectBorderWidth = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectBorderWidth", i]] floatValue];
            
            CGFloat red = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectBorderColor-Red", i]] floatValue];
            CGFloat green = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectBorderColor-Green", i]] floatValue];
            CGFloat blue = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectBorderColor-Blue", i]] floatValue];
            CGFloat alpha = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectBorderColor-Alpha", i]] floatValue];
            UIColor* objectBorderColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            object.objectBorderColor = objectBorderColor;
            
            object.objectShadowStyle = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectShadowStyle", i]] intValue];
            object.objectShadowBlur = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectShadowBlur", i]] floatValue];
            object.objectShadowOffset = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectShadowOffset", i]] floatValue];
            
            red = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectShadowColor-Red", i]] floatValue];
            green = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectShadowColor-Green", i]] floatValue];
            blue = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectShadowColor-Blue", i]] floatValue];
            alpha = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectShadowColor-Alpha", i]] floatValue];
            UIColor* objectShadowColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
            
            object.objectShadowColor = objectShadowColor;
            
            if ([plistDict objectForKey:[NSString stringWithFormat:@"%d-objectChromaColor-Red", i]] != nil)
            {
                red = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectChromaColor-Red", i]] floatValue];
                green = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectChromaColor-Green", i]] floatValue];
                blue = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectChromaColor-Blue", i]] floatValue];
                UIColor* objectChromaColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
                
                object.objectChromaColor = objectChromaColor;
            }
            
            if ([plistDict objectForKey:@"objectChromaNoise"] != nil) {
                object.objectChromaTolerance = [[plistDict objectForKey:@"objectChromaTolerance"] floatValue];
            } else {
                object.objectChromaTolerance = 0.0;
            }
            
            if ([plistDict objectForKey:@"objectChromaNoise"] != nil) {
                object.objectChromaNoise = [[plistDict objectForKey:@"objectChromaNoise"] floatValue];
            } else {
                object.objectChromaNoise = 0.0;
            }
            
            if ([plistDict objectForKey:@"objectChromaEdges"] != nil) {
                object.objectChromaEdges = [[plistDict objectForKey:@"objectChromaEdges"] floatValue];
            } else {
                object.objectChromaEdges = 0.1;
            }
            
            if ([plistDict objectForKey:@"objectChromaOpacity"] != nil) {
                object.objectChromaOpacity = [[plistDict objectForKey:@"objectChromaOpacity"] floatValue];
            } else {
                object.objectChromaOpacity = 1.0;
            }
            
            object.objectCornerRadius = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectCornerRadius", i]] floatValue];
            
            id opacity = [plistDict objectForKey:[NSString stringWithFormat:@"%d-objectOpacity", i]];
            
            CGFloat objectOpacity = 1.0f;
            
            if (opacity != nil)
                objectOpacity = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-objectOpacity", i]] floatValue];
            
            if ((mediaType == MEDIA_PHOTO)||(mediaType == MEDIA_GIF)||(mediaType == MEDIA_VIDEO))
            {
                object.imageView.alpha = objectOpacity;
                object.borderLineLayer.opacity = objectOpacity;
                
                if(mediaType == MEDIA_VIDEO)
                    [object setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:objectOpacity]];
            }
            else if (mediaType == MEDIA_TEXT)
            {
                object.textView.alpha = objectOpacity;
                object.borderLineLayer.opacity = objectOpacity;
            }

            [object applyBorder];
            [object applyShadow];
            
            if (object.mediaType == MEDIA_TEXT)
            {
                CGFloat red = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-textViewTextColor-Red", i]] floatValue];
                CGFloat green = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-textViewTextColor-Green", i]] floatValue];
                CGFloat blue = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-textViewTextColor-Blue", i]] floatValue];
                CGFloat alpha = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-textViewTextColor-Alpha", i]] floatValue];
                UIColor* textViewTextColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                
                object.textView.textColor = textViewTextColor;
                
                tempRect = CGRectFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-textViewFrame", i]]);
                object.textView.frame = CGRectMake(tempRect.origin.x * rX, tempRect.origin.y * rY, tempRect.size.width * rScale, tempRect.size.height * rScale);
                
                NSString* fontName = [plistDict objectForKey:[NSString stringWithFormat:@"%d-textViewFontName", i]];
                object.textObjectFontSize = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-textObjectFontSize", i]] floatValue];
                object.textObjectFontSize = object.textObjectFontSize * rScale;
                object.textView.font = [UIFont fontWithName:fontName size:object.textObjectFontSize];
                object.textView.textAlignment = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-textViewTextAlignment", i]] integerValue];
                object.isBold = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-isBold", i]] boolValue];
                object.isItalic = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-isItalic", i]] boolValue];
                object.isUnderline = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-isUnderline", i]] boolValue];
                object.isStroke = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-isStroke", i]] boolValue];
                
                [object initTextAttributed];
                [object changeTextMaskBound:nil];
            }
            
            object.isReflection = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-isReflection", i]] boolValue];
            
            //20150509
            if (object.mediaType == MEDIA_VIDEO)
                object.isReflection = NO;
            
            object.reflectionScale = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-reflectionScale", i]] floatValue];
            object.reflectionAlpha = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-reflectionAlpha", i]] floatValue];
            object.reflectionGap = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-reflectionGap", i]] floatValue];
            object.reflectionDelta = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-reflectionDelta", i]]);
            object.originalVideoCenter = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-originalVideoCenter", i]]);
            object.changedVideoCenter = CGPointFromString([plistDict objectForKey:[NSString stringWithFormat:@"%d-changedVideoCenter", i]]);
            
            //20151105
            if ([plistDict objectForKey:[NSString stringWithFormat:@"%d-motionArray", i]])
            {
                object.motionArray = [plistDict objectForKey:[NSString stringWithFormat:@"%d-motionArray", i]];
                object.startPositionArray = [plistDict objectForKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
                object.endPositionArray = [plistDict objectForKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            }
            
            [object update];
            
            if (object.mediaType == MEDIA_VIDEO)
            {
                CGFloat duration = [object getVideoTotalDuration];
                [self.timelineView changeTimeline:object.objectIndex time:duration];
            }
            
            if (object.mediaType == MEDIA_PHOTO)
            {
                //resume saved filter
                id filteredName = [plistDict objectForKey:[NSString stringWithFormat:@"%d-filterImageName", i]];

                if (filteredName != nil)
                {
                    NSString* filteredImageFileName = [plistDict objectForKey:[NSString stringWithFormat:@"%d-filterImageName", i]];
                    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
                    NSString *fileName = [folderPath stringByAppendingPathComponent:filteredImageFileName];
                    
                    object.imageView.image = [UIImage downsample:[NSURL fileURLWithPath:fileName] size:object.imageView.frame.size scale:[UIScreen mainScreen].scale];
                    
                    if ([plistDict objectForKey:[NSString stringWithFormat:@"%d-photoFilterIndex", i]])
                    {
                        object.photoFilterIndex = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-photoFilterIndex", i]] integerValue];
                        object.photoFilterValue = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-photoFilterValue", i]] floatValue];
                    }

                    YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
                    slider.thumbnailImageView.image = [UIImage downsample:[NSURL fileURLWithPath:fileName] size:slider.thumbnailImageView.frame.size scale:[UIScreen mainScreen].scale];
                }
                
                //shape decode
                id isShape = [plistDict objectForKey:[NSString stringWithFormat:@"%d-isShape", i]];
                
                if (isShape != nil)
                {
                    object.isShape = [isShape boolValue];
                    object.shapeOverlayStyle = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-shapeOverlayStyle", i]] intValue];
                    
                    CGFloat red = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Red", i]] floatValue];
                    CGFloat green = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Green", i]] floatValue];
                    CGFloat blue = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Blue", i]] floatValue];
                    CGFloat alpha = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-shapeOverlayColor-Alpha", i]] floatValue];
                    UIColor* shapeOverlayColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];

                    object.shapeOverlayColor = shapeOverlayColor;
                }
            }
        }
        else if (mediaType == MEDIA_MUSIC)
        {
            MediaObjectView* object = [self.mediaObjectArray lastObject];
            object.mediaType = mediaType;
            object.isPlaying = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-isPlaying", i]] boolValue];
            object.mediaDuration = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mediaDuration", i]] floatValue];
            object.mediaVolume = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mediaVolume", i]] floatValue];
            object.mfStartPosition = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mfStartPosition", i]] floatValue];
            object.mfEndPosition = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mfEndPosition", i]] floatValue];
            object.mfStartAnimationDuration = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mfStartAnimationDuration", i]] floatValue];
            object.mfEndAnimationDuration = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-mfEndAnimationDuration", i]] floatValue];
            object.startActionType = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-startActionType", i]] intValue];
            object.endActionType = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-endActionType", i]] intValue];

            //20151105
            if ([plistDict objectForKey:[NSString stringWithFormat:@"%d-motionArray", i]])
            {
                object.motionArray = [plistDict objectForKey:[NSString stringWithFormat:@"%d-motionArray", i]];
                object.startPositionArray = [plistDict objectForKey:[NSString stringWithFormat:@"%d-startPositionArray", i]];
                object.endPositionArray = [plistDict objectForKey:[NSString stringWithFormat:@"%d-endPositionArray", i]];
            }

            YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:gnSelectedObjectIndex];
            
            NSNumber* startPosNum = [object.startPositionArray objectAtIndex:0];
            NSNumber* endPosNum = [object.endPositionArray lastObject];
            
            CGFloat startPosition = [startPosNum floatValue];
            CGFloat endPosition = [endPosNum floatValue];
            
            [slider changeMusicWaveByRange:startPosition end:endPosition];
        }
        
        //reset timeline
        MediaObjectView* object = [self.mediaObjectArray lastObject];
        object.isGrouped = [[plistDict objectForKey:[NSString stringWithFormat:@"%d-isGrouped", i]] boolValue];
        [self.timelineView resetTimeline:i obj:object];
        [self.timelineView initTimelinePosition:i startPosition:object.mfStartPosition endPosition:object.mfEndPosition];
    }
    
   
    self.timelineView.totalTime = grNormalFilterOutputTotalTime;
    
    if (self.timelineView.sliderArray.count > 0)
    {
        for (int i = 0; i < self.timelineView.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
            slider.frame = CGRectMake(slider.frame.origin.x, grSliderHeightMax * (self.timelineView.sliderArray.count - 1 - i), slider.frame.size.width, grSliderHeightMax);
            slider.yPosition = slider.center.y;
            [slider changeSliderYPosition];
        }
        
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, self.timelineView.sliderArray.count * grSliderHeightMax);
    }
    else
    {
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, grSliderHeightMax);
    }
    
    
    [self.totalTimeLabel setText:[self timeToString:grNormalFilterOutputTotalTime]];
    [self.horizontalBgView setTotalTime:grNormalFilterOutputTotalTime];

    [self.projectNameLabel setText:[NSString stringWithFormat:@"%@", gstrCurrentProjectName]];
    
    [self checkEditArrowButtons];
    
    /*****************************/
    CGFloat minDuration = self.timelineView.totalTime;
    for (int i = 0; i < self.timelineView.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        
        if (minDuration > (slider.rightPosition - slider.leftPosition))
            minDuration = (slider.rightPosition - slider.leftPosition);
    }
    
    CGFloat minWidth = 0.0f;
   
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        minWidth = IPHONE_TIMELINE_WIDTH_MIN;
    else
        minWidth = IPAD_TIMELINE_WIDTH_MIN;
    
    self.timelineView.scaleFactor = minWidth / minDuration;
    
    for (int i = 0; i < self.timelineView.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        [slider changeSliderFrame:self.timelineView.scaleFactor];
        [slider drawRuler];
    }
    
    if (self.timelineView.sliderArray.count > 0)
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor*self.timelineView.totalTime, self.timelineView.sliderArray.count*grSliderHeightMax);
    else
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor*self.timelineView.totalTime, grSliderHeightMax);

    /*****************************/

    [self.horizontalBgView setContentSize:CGSizeMake(self.timelineView.contentSize.width, 0.0f)];
    

    //ObjectEdit Thumbanils
    
    CGFloat contentOffsetX = 0.0f;

    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        UIImage* image = slider.thumbnailImageView.image;

        if (!image)
        {
            MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
            image = object.imageView.image;
            slider.thumbnailImageView.image = object.imageView.image;
        }

        CGSize size = image.size;
        size = CGSizeMake(size.width * self.editScrollView.frame.size.height * 0.9f / size.height, self.editScrollView.frame.size.height * 0.9f);

        UIImageView* thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentOffsetX, (self.editScrollView.frame.size.height - size.height) / 2, size.width, size.height)];
        thumbnailImageView.image = image;
        thumbnailImageView.backgroundColor = [UIColor clearColor];
        thumbnailImageView.userInteractionEnabled = YES;
        
        if (i == gnSelectedObjectIndex)
        {
            thumbnailImageView.layer.borderColor = [UIColor orangeColor].CGColor;
            thumbnailImageView.layer.borderWidth = 1.0f;
        }
        else
        {
            thumbnailImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            thumbnailImageView.layer.borderWidth = 1.0f;
        }
 
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectedEditThumbnail:)];
        selectGesture.delegate = self;
        [thumbnailImageView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];

        thumbnailImageView.tag = i;
        [self.editScrollView addSubview:thumbnailImageView];
        [self.editThumbnailArray addObject:thumbnailImageView];
        
        contentOffsetX = contentOffsetX + size.width + 10.0f;
    }

    [self.editScrollView setContentSize:CGSizeMake(contentOffsetX - 10.0f, self.editScrollView.bounds.size.height)];
    
    [self updateObjectEdit];

    [[SHKActivityIndicator currentIndicator] hide];
    
    if (self.mediaObjectArray.count > 1)
    {
        self.editLeftButton.hidden = NO;
        self.editRightButton.hidden = NO;
    }
}

- (void)prepareVideoPlayer:(MediaObjectView *)objectView {
    
    self.playerItem = nil;
    
    if (self.playerObserver) {
        [self.videoPlayer removeTimeObserver:self.playerObserver];
        self.playerObserver = nil;
    }
    
    if (self.videoPlayer) {
        [self.videoPlayer pause];
        self.videoPlayer = nil;
    }
    
    if (self.videoPlayerLayer) {
        [self.videoPlayerLayer removeFromSuperlayer];
        self.videoPlayerLayer = nil;
    }
    
    if ((objectView.mediaType == MEDIA_VIDEO) || (objectView.mediaType == MEDIA_MUSIC))
    {
        /* generate a player */
        AVAsset *videoAsset = [objectView speedVideoAsset];
        self.playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
        self.videoPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
        __weak typeof(self) weakSelf = self;
        self.playerObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.02, videoAsset.duration.timescale) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            weakSelf.seekSlider.value = CMTimeGetSeconds(time);
            [weakSelf.currentSeekTimeLabel setText:[weakSelf timeToString:CMTimeGetSeconds(time)]];
        }];

        if (CMTimeGetSeconds(objectView.currentPosition) >= CMTimeGetSeconds(videoAsset.duration))
            [self.videoPlayer seekToTime:kCMTimeZero];
        else
            [self.videoPlayer seekToTime:objectView.currentPosition];

        self.seekSlider.minimumValue = 0.0;
        self.seekSlider.maximumValue = CMTimeGetSeconds(videoAsset.duration);
        self.seekSlider.value = CMTimeGetSeconds(objectView.currentPosition);
        [self.seekSlider setEnabled:YES];
        [self.totalSeekTimeLabel setText:[self timeToString:CMTimeGetSeconds(videoAsset.duration)]];
        [self.currentSeekTimeLabel setText:[self timeToString:CMTimeGetSeconds(objectView.currentPosition)]];

        self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
        
        self.videoPlayerLayer.frame = objectView.videoView.bounds;
        [objectView.videoView.layer addSublayer:self.videoPlayerLayer];
        self.videoPlayerLayer.hidden = NO;
        self.videoPlayerLayer.opacity = objectView.imageView.alpha;
        NSLog(@"Bounds : %@", NSStringFromCGRect(objectView.videoView.bounds));
        NSLog(@"Frame : %@", NSStringFromCGRect(objectView.videoView.frame));
        NSLog(@"Object view frame : %@", NSStringFromCGRect(objectView.mediaView.frame));
        [self.playingButton setTag:0];
        [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.playingButton setEnabled:YES];
    }
    else
    {
        [self.playingButton setEnabled:NO];
        [self.playingButton setTag:0];
        [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.seekSlider setEnabled:NO];
        [self.seekSlider setValue:0.0];
        [self.currentSeekTimeLabel setText:@"00:00.000"];
        [self.totalSeekTimeLabel setText:@"00:00.000"];
    }
}

#pragma mark - Tap Workspace for Deselect all objects

- (void)workspaceTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.mediaObjectArray.count <= 0)
        return;
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    object.selectedLineLayer.hidden = YES;
    
    [self.timelineView timelineObjectDeselected];
    
    [self timelineDeselected:gnSelectedObjectIndex];
}


#pragma mark -
#pragma mark - ********** Buttons Actions **********

- (IBAction) editTimeline:(id)sender
{
    if (self.mediaObjectArray.count == 0)
        return;
    
    self.horizontalBgView.frame = CGRectMake(self.horizontalBgView.frame.origin.x, self.editButtonsView.frame.origin.y + self.editButtonsView.frame.size.height - self.horizontalBgView.frame.size.height, self.horizontalBgView.frame.size.width, self.horizontalBgView.frame.size.height);
    self.timelineView.frame = CGRectMake(self.timelineView.frame.origin.x, self.horizontalBgView.frame.origin.y - self.timelineView.frame.size.height - 0.5, self.timelineView.frame.size.width, self.timelineView.frame.size.height);
    if (self.timelineView.hidden)
    {
        self.timelineView.hidden = NO;
        self.horizontalBgView.hidden = NO;
        self.editButtonsView.hidden = YES;
        self.editLeftButton.hidden = YES;
        self.editRightButton.hidden = YES;
        
        if (self.mediaObjectArray.count > gnVisibleMaxCount)
            self.verticalBgView.hidden = NO;
        
        [self.timelineButton setImage:[UIImage imageNamed:@"workspace"] forState:UIControlStateNormal];
    }
    else
    {
        self.timelineView.hidden = YES;
        self.horizontalBgView.hidden = YES;
        self.verticalBgView.hidden = YES;
        self.editButtonsView.hidden = NO;
        self.editLeftButton.hidden = NO;
        self.editRightButton.hidden = NO;

        [self.timelineButton setImage:[UIImage imageNamed:@"timelineButton"] forState:UIControlStateNormal];
    }
}

-(IBAction)onGrid:(id)sender
{
    if ([sender tag] == 1)
    {
        self.gridButton.tag = 2;
        self.gridLayer.hidden = NO;
    }
    else if ([sender tag] == 2)
    {
        self.gridButton.tag = 1;
        self.gridLayer.hidden = YES;
    }
}

-(IBAction)onSeekChanged:(id)sender
{
    if (self.videoPlayer) {
        self.videoPlayerLayer.hidden = NO;
        [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(self.seekSlider.value, 600) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

-(IBAction)onSettings:(id)sender
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    self.settingsView = nil;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        CGSize result = [UIScreen mainScreen].bounds.size;
        float width = result.width;
        float height  = result.height;
        
        if (width > 730 || height > 730 )
        {
            self.settingsView = [[[NSBundle mainBundle] loadNibNamed:@"SettingsView_iPad" owner:self options:nil] objectAtIndex:0];
        } else {
            self.settingsView = [[[NSBundle mainBundle] loadNibNamed:@"SettingsView" owner:self options:nil] objectAtIndex:0];
        }
    } else {
        self.settingsView = [[[NSBundle mainBundle] loadNibNamed:@"SettingsView_iPad" owner:self options:nil] objectAtIndex:0];
    }

    [self.settingsView initSettingsView];
    self.settingsView.delegate = self;

    [self.settingsView updateSettings];
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.settingsView isCenter:YES];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(IBAction)onInfo:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Guide Video", nil)
                            image:nil
                           target:self
                           action:@selector(actionInfoVideo)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Free Background Music", nil)
                            image:nil
                           target:self
                           action:@selector(actionGoToFreeBackgroundMusic)],
      
      //      [YJLActionMenuItem menuItem:NSLocalizedString(@"How to remove iCloud documents", nil)
      //                            image:nil
      //                           target:self
      //                           action:@selector(actionHowToRemoveICloud)],
      
      [YJLActionMenuItem menuItem:@"DreamClouds.Net"
                            image:nil
                           target:self
                           action:@selector(actionGoToDreamSite)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Vimeo Examples", nil)
                            image:nil
                           target:self
                           action:@selector(actionGoToVimeoExamples)],
      
      //      [YJLActionMenuItem menuItem:NSLocalizedString(@"Twitter User Group", nil)
      //                            image:nil
      //                           target:self
      //                           action:@selector(actionGoToTwitter)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Facebook Users Group", nil)
                            image:nil
                           target:self
                           action:@selector(actionGoToFacebook)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Email Help", nil)
                            image:nil
                           target:self
                           action:@selector(actionGoToEmail)],
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Music download", nil)
                            image:nil
                           target:self
                           action:@selector(actionDownloadMusic)],
      ];

    
    CGRect frame = [self.infoButton convertRect:self.infoButton.bounds toView:self.view];

    [YJLActionMenu showMenuInView:self.navigationController.view
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(void) actionDownloadMusic
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (!self.musicDownload)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MusicDownload" bundle:nil];
            self.musicDownload = [sb instantiateViewControllerWithIdentifier:@"MusicDownload"];
            self.musicDownload.musicDownloadDelegate = self;
        }
        else
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MusicDownload_iPad" bundle:nil];
            self.musicDownload = [sb instantiateViewControllerWithIdentifier:@"MusicDownload_iPad"];
            self.musicDownload.musicDownloadDelegate = self;
        }
    }
    
    self.musicDownload.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.musicDownload animated:YES completion:nil];
}

-(void) actionInfoVideo
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"VideoDreamTutorial" ofType:@"mp4" inDirectory:nil];
    
    NSURL *movieURL = [NSURL fileURLWithPath:path];
    
    if (self.infoVideoPlayer)
    {
        [self.infoVideoPlayer.player pause];
        [self.infoVideoPlayer.view removeFromSuperview];
        self.infoVideoPlayer = nil;
    }
    
    self.infoVideoPlayer = [[AVPlayerViewController alloc] init];
    self.infoVideoPlayer.player = [AVPlayer playerWithURL:movieURL];
    self.infoVideoPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.infoVideoPlayer.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.infoVideoPlayer animated:YES completion:^{
        [self.infoVideoPlayer.player play];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)actionDownloadFromWiFi
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (!self.musicDownloadController)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MusicDownloadController" bundle:nil];
        self.musicDownloadController = [sb instantiateViewControllerWithIdentifier:@"MusicDownloadController"];
        self.musicDownloadController.musicDownloadControllerDelegate = self;
    }
    
    [self updateLandscapeView];
    
    self.musicDownloadController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.musicDownloadController animated:YES completion:nil];
}

-(void) actionGoToFreeBackgroundMusic
{
    NSURL *url = [NSURL URLWithString:@"https://www.youtube.com/channel/UCQsBfyc5eOobgCzeY8bBzFg"];
    /*if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (!self.musicDownloadController)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MusicDownloadController" bundle:nil];
        self.musicDownloadController = [sb instantiateViewControllerWithIdentifier:@"MusicDownloadController"];
        self.musicDownloadController.musicDownloadControllerDelegate = self;
    }
    
    [[NSUserDefaults standardUserDefaults] setURL:url forKey:@"viewSite"];
    self.musicDownloadController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.musicDownloadController animated:YES completion:nil];*/
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
    }
}

- (void)updateLandscapeView
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        gnOrientation = ORIENTATION_LANDSCAPE;
    }
    else if ((deviceOrientation == UIDeviceOrientationPortrait) || (deviceOrientation == UIDeviceOrientationPortraitUpsideDown))
    {
        gnOrientation = ORIENTATION_PORTRAIT;
    }
}

-(void) actionHowToRemoveICloud
{
    NSString* path = @"http://support.apple.com/kb/PH12794";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

-(void) actionGoToDreamSite
{
    NSString* path = @"http://www.dreamclouds.net/VideoDreamer/";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

-(void) actionGoToVimeoExamples
{
    NSString* path = @"http://vimeo.com/videodreamer";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

-(void) actionGoToTwitter
{
    NSString* path = @"https://twitter.com/DreamCloudsApps";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

-(void) actionGoToFacebook
{
    NSString* path = @"https://www.facebook.com/VideoDreamerUsers";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

-(void) actionGoToEmail
{
    //NSString* path = @"http://contact.dreamclouds.net";
    //NSURL* url = [NSURL URLWithString:path];
    //[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:@[@"sales@dreamclouds.net"]];
        [controller setSubject:@"Video Dreamer Support"];
        [controller setMessageBody:@"What can we help you with?" isHTML:NO];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:APP_ALERT_TITLE message:@"Please add an email account to your device." preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:controller animated:YES completion:nil];
    }
}


#pragma mark -
#pragma mark - PlayerItem notification

-(void)itemDidFinishPlaying:(NSNotification *) notification
{
    [self.infoVideoPlayer.player seekToTime:kCMTimeZero];
    
    [self.infoVideoPlayer.player pause];
    [self.infoVideoPlayer dismissViewControllerAnimated:YES completion:^{
        self.infoVideoPlayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }];
    
    gnOrientation = ORIENTATION_ALL;
}


#pragma mark -
#pragma mark -
#pragma mark - Save Button Actions

- (IBAction) onSave:(id)sender
{
    if (self.mediaObjectArray.count > 0)
    {
        NSArray *menuItems =
        @[
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Save & Continue", nil)
                                image:nil
                               target:self
                               action:@selector(saveContinue)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Save a Copy", nil)
                                image:nil
                               target:self
                               action:@selector(saveCopy)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Save As Project", nil)
                                image:nil
                               target:self
                               action:@selector(saveAs)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Save & Exit", nil)
                                image:nil
                               target:self
                               action:@selector(saveExit)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Create", nil)
                                image:nil
                               target:self
                               action:@selector(createVideo)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Rename Project", nil)
                                image:nil
                               target:self
                               action:@selector(renameProject)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"No Save & Exit", nil)
                                image:nil
                               target:self
                               action:@selector(noSaveExit)],
          
          ];

        CGRect frame = [self.saveButton convertRect:self.saveButton.bounds toView:self.view];
        [YJLActionMenu showMenuInView:self.navigationController.view
                             fromRect:frame
                            menuItems:menuItems isWhiteBG:NO];
    }
    else
    {
        [self.projectManager deleteProject];

        gnOrientation = ORIENTATION_ALL;
        
        self.playerItem = nil;

        [self.videoPlayer pause];
        self.videoPlayer = nil;
        
        [self.videoPlayerLayer removeFromSuperlayer];
        self.videoPlayerLayer = nil;
        
        self.settingsView = nil;
        self.filterListView = nil;

        [self.navigationController popViewControllerAnimated:NO];
    }
}

-(void) onRemoveObject
{
    if ([self.mediaObjectArray count] <= 0)
    {
        [self showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"Your workspace is empty. Add a video, photo, text or music to continue.", nil) okHandler:nil];
        return;
    }
    
    /******************************* Remove Object *************************/
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    if ((object.mediaType == MEDIA_MUSIC) || (object.mediaType == MEDIA_VIDEO))
    {
        [playbackTimer invalidate];
        playbackTimer = nil;
        
        self.playerItem = nil;
        
        if (self.playerObserver) {
            [self.videoPlayer removeTimeObserver:self.playerObserver];
            self.playerObserver = nil;
        }
        
        [self.videoPlayer pause];
        self.videoPlayer = nil;
        
        [self.videoPlayerLayer removeFromSuperlayer];
        self.videoPlayerLayer = nil;
    }
    
    //delete file on project folder
    if (object.mediaType == MEDIA_PHOTO)
    {
        NSString* imageName = object.imageName;
        
        BOOL isExist = NO;
        
        for (int i = 0; i < self.mediaObjectArray.count; i++)
        {
            MediaObjectView* obj = [self.mediaObjectArray objectAtIndex:i];
            
            if ((i != gnSelectedObjectIndex)&&(obj.mediaType == MEDIA_PHOTO)&&([obj.imageName isEqualToString:imageName]))
                isExist = YES;
        }
        
        if (!isExist)
            [self.projectManager deleteFile:imageName];
    }
    else if (object.mediaType == MEDIA_GIF)
    {
        NSString* gifName = object.imageName;
        
        BOOL isExist = NO;
        
        for (int i = 0; i < self.mediaObjectArray.count; i++)
        {
            MediaObjectView* obj = [self.mediaObjectArray objectAtIndex:i];
            
            if ((i != gnSelectedObjectIndex)&&(obj.mediaType == MEDIA_GIF)&&([obj.imageName isEqualToString:gifName]))
                isExist = YES;
        }
        
        if (!isExist)
            [self.projectManager deleteFile:gifName];
    }
    else if (object.mediaType == MEDIA_VIDEO)
    {
        NSString* videoName = [object.mediaUrl lastPathComponent];
        
        BOOL isExist = NO;
        
        for (int i = 0; i < self.mediaObjectArray.count; i++)
        {
            MediaObjectView* obj = [self.mediaObjectArray objectAtIndex:i];
            
            if ((i != gnSelectedObjectIndex) && (obj.mediaType == MEDIA_VIDEO) && ([[obj.mediaUrl lastPathComponent] isEqualToString:videoName]))
                isExist = YES;
        }
        
        if (!isExist)
            [self.projectManager deleteFile:videoName];
        
        if (object.mediaUrl)
        {
            [self.projectManager deleteFile:[object.mediaUrl lastPathComponent]];
        }
    }
    else if (object.mediaType == MEDIA_MUSIC)
    {
        NSString* musicName = [object.mediaUrl lastPathComponent];
        
        BOOL isExist = NO;
        
        for (int i = 0; i < self.mediaObjectArray.count; i++)
        {
            MediaObjectView* obj = [self.mediaObjectArray objectAtIndex:i];
            
            if ((i != gnSelectedObjectIndex)&&(obj.mediaType == MEDIA_MUSIC)&&([[obj.mediaUrl lastPathComponent] isEqualToString:musicName]))
                isExist = YES;
        }
        
        if (!isExist)
            [self.projectManager deleteFile:musicName];
    }
    
    //remove object from object array
    [self.mediaObjectArray removeObjectAtIndex:gnSelectedObjectIndex];
    [object removeFromSuperview];
    object = nil;
    
    //remove object from timeline
    [self.timelineView removeSlider:gnSelectedObjectIndex];
    
    gnSelectedObjectIndex = 0;
    
    /**************************** Re-Order Objects and Update UI ***************************/
    
    [self.verticalBgView setContentSize:(self.mediaObjectArray.count > 0) ? CGSizeMake(self.verticalBgView.frame.size.width, self.mediaObjectArray.count*grSliderHeight) : CGSizeMake(self.verticalBgView.frame.size.width, grSliderHeight)];
    
    if ([self.mediaObjectArray count] > 0)
    {
        for (int i = 0; i < [self.mediaObjectArray count]; i++)
        {
            MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
            [object setIndex:i];
        }
        
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:self.mediaObjectArray.count - 1];
        
        [self prepareVideoPlayer:object];
        
        [object object_actived];
        
        object.alpha = 1.0f;
        
        if (self.mediaObjectArray.count <= gnVisibleMaxCount)
            self.verticalBgView.hidden = YES;
        
        
        CGFloat minDuration = self.timelineView.totalTime;
        
        for (int i = 0; i < self.timelineView.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
            
            if (minDuration > (slider.rightPosition - slider.leftPosition))
                minDuration = (slider.rightPosition - slider.leftPosition);
        }
        
        CGFloat minWidth = 0.0f;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            minWidth = IPHONE_TIMELINE_WIDTH_MIN;
        else
            minWidth = IPAD_TIMELINE_WIDTH_MIN;
        
        self.timelineView.scaleFactor = minWidth / minDuration;
        
        for (int i = 0; i < self.timelineView.sliderArray.count; i++)
        {
            YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
            [slider changeSliderFrame:self.timelineView.scaleFactor];
            [slider drawRuler];
        }
        
        if (self.timelineView.sliderArray.count > 0)
            self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, self.timelineView.sliderArray.count * grSliderHeight);
        else
            self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, grSliderHeight);
    }
    else
    {
        [self.timelineButton setImage:[UIImage imageNamed:@"timelineButton"] forState:UIControlStateNormal];

        self.timelineView.hidden = YES;
        self.horizontalBgView.hidden = YES;
        self.verticalBgView.hidden = YES;
        self.editButtonsView.hidden = NO;

        [self showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"Your workspace is empty. Add a video, photo, text or music to continue.", nil) okHandler:nil];
    }
    
    if (self.mediaObjectArray.count > gnVisibleMaxCount)
        self.verticalBgView.hidden = NO;
    
    if (self.mediaObjectArray.count > 0)
    {
        MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        
        if ((selectedObject.mediaType == MEDIA_VIDEO) || (selectedObject.mediaType == MEDIA_MUSIC)) {
            [self.playingButton setEnabled:YES];
            [self.seekSlider setEnabled:YES];
        } else {
            [self.playingButton setEnabled:NO];
            [self.seekSlider setEnabled:NO];
            [self.currentSeekTimeLabel setText:@"00:00.000"];
            [self.totalSeekTimeLabel setText:@"00:00.000"];
        }
    }
    else
    {
        [self.playingButton setEnabled:NO];
        [self.seekSlider setEnabled:NO];
        [self.currentSeekTimeLabel setText:@"00:00.000"];
        [self.totalSeekTimeLabel setText:@"00:00.000"];
    }
    
    [self.videoPlayer pause];
    
    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    [self.seekSlider setValue:0.0];
    
    //refresh object edit
    [self updateObjectEdit];
    
    [self.timelineView updateZoom];
    
    [self.horizontalBgView setContentSize:CGSizeMake(self.timelineView.contentSize.width, 0.0f)];
    
    //save project after remove object

    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSString *plistFileName = [folderPath stringByAppendingPathComponent:@"project.plist"];

    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    if ([localFileManager fileExistsAtPath:plistFileName])
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Object Removing...", nil)) isLock:YES];
        
        [self performSelector:@selector(saveContinueWorkspace) withObject:nil afterDelay:0.02f];
        
        return;
    }
    
    [self checkEditArrowButtons];
}

-(IBAction) addAV:(id)sender
{
    NSArray *menuItems =
    @[
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Photo Cam", nil)
                            image:nil
                           target:self
                           action:@selector(onPhotoFromCamera)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"All Photos", nil)
                            image:nil
                           target:self
                           action:@selector(onPhotoFromGallery)],

      [YJLActionMenuItem menuItem:NSLocalizedString(@"All Videos", nil)
                            image:nil
                           target:self
                           action:@selector(onVideoFromGallery)],

      [YJLActionMenuItem menuItem:NSLocalizedString(@"Video Cam", nil)
                            image:nil
                           target:self
                           action:@selector(onVideoFromCamera)],

      [YJLActionMenuItem menuItem:NSLocalizedString(@"Stingers", nil)
                            image:nil
                           target:self
                           action:@selector(onStingerVideos)],
      
      [YJLActionMenuItem menuItem:NSLocalizedString(@"Shapes", nil)
                            image:nil
                           target:self
                           action:@selector(onShapesGallery)],

      [YJLActionMenuItem menuItem:NSLocalizedString(@"GIFs", nil)
                            image:nil
                           target:self
                           action:@selector(onGIFsGallery)],

      [YJLActionMenuItem menuItem:NSLocalizedString(@"Music", nil)
                            image:nil
                           target:self
                           action:@selector(onMusic)],

      [YJLActionMenuItem menuItem:NSLocalizedString(@"Music Download", nil)
                            image:nil
                           target:self
                           action:@selector(actionDownloadMusic)],

      [YJLActionMenuItem menuItem:NSLocalizedString(@"Text", nil)
                            image:nil
                           target:self
                           action:@selector(onText)],
      ];
    
    
    CGRect frame = [self.avButton convertRect:self.avButton.bounds toView:self.view];

    [YJLActionMenu showMenuInView:self.navigationController.view
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];

    isReplace = NO;
}

- (void)onToBack
{
    if (self.mediaObjectArray.count == 0)
        return;
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [self.workspaceView sendSubviewToBack:object];
    
    [self.mediaObjectArray removeObjectAtIndex:gnSelectedObjectIndex];
    [self.mediaObjectArray insertObject:object atIndex:0];
    
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        [object setIndex:i];
    }
    
    [self.timelineView changeSliderOrder:gnSelectedObjectIndex insertFlag:YES];
    
    gnSelectedObjectIndex = 0;
    
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        if (i == gnSelectedObjectIndex)
        {
            object.alpha = 1.0f;
            
            if ((object.mediaType == MEDIA_PHOTO) || (object.mediaType == MEDIA_GIF)||(object.mediaType == MEDIA_TEXT)) {
                [self.playingButton setEnabled:NO];
                [self.seekSlider setEnabled:NO];
                [self.seekSlider setValue:0.0];
                [self.currentSeekTimeLabel setText:@"00:00.000"];
                [self.totalSeekTimeLabel setText:@"00:00.000"];
            } else if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_MUSIC)) {
                [self.playingButton setEnabled:YES];
                [self.seekSlider setEnabled:YES];
            }
        }
        else if(i > gnSelectedObjectIndex)
        {
            if (object.alpha > 0.0f)
                object.alpha = 0.3f;
        }
        else if (i < gnSelectedObjectIndex)
        {
            if (object.alpha > 0.0f)
                object.alpha = 1.0f;
        }
    }
    
    //refresh object edit
    [self refreshObjectEditThumbnailView];
}

- (void) onToFront
{
    if (self.mediaObjectArray.count <= 0)
        return;
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [self.workspaceView bringSubviewToFront:object];
    
    [self.mediaObjectArray removeObjectAtIndex:gnSelectedObjectIndex];
    [self.mediaObjectArray addObject:object];
    
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        [object setIndex:i];
    }
    
    [self.timelineView changeSliderOrder:gnSelectedObjectIndex insertFlag:NO];
    gnSelectedObjectIndex = (int)self.mediaObjectArray.count - 1;
    
    [self bringGridLayerToFront];
    
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        if (i == gnSelectedObjectIndex)
        {
            object.alpha = 1.0f;
            
            if ((object.mediaType == MEDIA_PHOTO) || (object.mediaType == MEDIA_GIF)||(object.mediaType == MEDIA_TEXT)) {
                [self.playingButton setEnabled:NO];
                [self.seekSlider setEnabled:NO];
                [self.seekSlider setValue:0.0];
                [self.currentSeekTimeLabel setText:@"00:00.000"];
                [self.totalSeekTimeLabel setText:@"00:00.000"];
            } else if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_MUSIC)) {
                [self.playingButton setEnabled:YES];
                [self.seekSlider setEnabled:YES];
            }
        }
        else if(i > gnSelectedObjectIndex)
        {
            if (object.alpha > 0.0f)
                object.alpha = 0.3f;
        }
        else if (i < gnSelectedObjectIndex)
        {
            if (object.alpha > 0.0f)
                object.alpha = 1.0f;
        }
    }
    
    //refresh object edit
    [self refreshObjectEditThumbnailView];
}

- (void) createVideo
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if (self.mediaObjectArray.count <= 0)   //if project have not a any objects, then user can not create a video
    {
        [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You have not any object. Please add a photo, video, music or text!", nil) okHandler:nil];
        return;
    }
    else    //if user have audio only, then user can not create a video
    {
        BOOL isExist = NO;
        
        for (int i = 0; i < self.mediaObjectArray.count; i++)
        {
            MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
            
            if ((object.mediaType == MEDIA_VIDEO) || (object.mediaType == MEDIA_PHOTO) || (object.mediaType == MEDIA_GIF) || (object.mediaType == MEDIA_TEXT))
            {
                isExist = YES;
                break;
            }
        }
        
        if (!isExist)
        {
            [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"You have an audio only. Please add a photo, video or text!", nil) okHandler:nil];
            return;
        }
    }
    
    
    // if user have not a video, then user can not apply a chromakey filter
    BOOL isVideoExist = NO;

    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
        {
            isVideoExist = YES;
            break;
        }
    }
    
    
    CGRect menuFrame = CGRectZero;
    
    if (isVideoExist)   //available apply a normal and chromakey both
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            menuFrame = CGRectMake(0.0f, 0.0f, 250.0f, 162.0f);
        else
            menuFrame = CGRectMake(0.0f, 0.0f, 310.0f, 162.0f);
    }
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            menuFrame = CGRectMake(0.0f, 0.0f, 250.0f, 106.0f);
        else
            menuFrame = CGRectMake(0.0f, 0.0f, 310.0f, 106.0f);
    }
    
    self.filterListView = nil;
    self.filterListView = [[FilterListView alloc] initWithFrame:menuFrame];
    self.filterListView.delegate = self;
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.filterListView isCenter:YES];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}


#pragma mark -
#pragma mark - FilterListViewDelegate

-(void) didFilterPreview:(NSInteger) index
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    gnOutputVideoFilterIndex = (VDOutputFilterType)index;
    
    self.timelineView.hidden = YES;
    self.verticalBgView.hidden = YES;
    self.horizontalBgView.hidden = YES;
    self.editButtonsView.hidden = NO;

    [self.timelineButton setImage:[UIImage imageNamed:@"timelineButton"] forState:UIControlStateNormal];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Preparing...", nil) isLock:YES];
    
    if (self.videoEditor != nil)
        self.videoEditor = nil;
    
    self.videoEditor = [[VideoEditor alloc] init];
    self.videoEditor.delegate = self;
    [self.videoEditor setPreviewFlag:YES];
    
    isPreview = YES;
    
    @autoreleasepool
    {
        [self performSelector:@selector(prepareGifToVideo) withObject:nil afterDelay:0.02f];
    }
}

-(void) didFilterApply:(NSInteger) index
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied)
    {
        [self showAlertViewController:NSLocalizedString(@"Video Dreamer is unable to access Camera Roll", nil) message:NSLocalizedString(@"To enable access to the Camera Roll, follow these steps:\r\n Go to: Settings -> Privacy -> Photos and turn ON access for Video Dreamer.", nil) okHandler:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }];
        return;
    }
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    gnOutputVideoFilterIndex = (VDOutputFilterType)index;

    self.timelineView.hidden = YES;
    self.verticalBgView.hidden = YES;
    self.horizontalBgView.hidden = YES;
    self.editButtonsView.hidden = NO;

    [self.timelineButton setImage:[UIImage imageNamed:@"timelineButton"] forState:UIControlStateNormal];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:NSLocalizedString(@"Preparing...", nil) isLock:YES];
    
    if (self.videoEditor != nil)
        self.videoEditor = nil;
    
    self.videoEditor = [[VideoEditor alloc] init];
    self.videoEditor.delegate = self;
    [self.videoEditor setPreviewFlag:NO];
    
    isPreview = NO;
    
    @autoreleasepool
    {
        [self performSelector:@selector(prepareGifToVideo) withObject:nil afterDelay:0.02f];
    }
}


-(void) prepareGifToVideo
{
    self.playerItem = nil;
    [self.videoPlayer pause];
    
    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    grNormalFilterOutputTotalTime = self.timelineView.totalTime;
    
    for (int i = 0; i < [self.mediaObjectArray count]; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        [object maskArrowsHidden];
        
        object.selectedLineLayer.hidden = YES;
        object.isSelected = NO;
        
        /* Get video transform */
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
            object.inputTransform = [self getVideoTranslate:object];
        
        /* Get timelines for a Normal Filter */
        object.mfStartPosition = [self.timelineView getStartPosition:i];
        object.mfEndPosition = [self.timelineView getEndPosition:i];
        object.startActionType = [self.timelineView getStartActionType:i];
        object.mfStartAnimationDuration = [self.timelineView getStartActionTime:i];
        object.endActionType = [self.timelineView getEndActionType:i];
        object.mfEndAnimationDuration = [self.timelineView getEndActionTime:i];
        
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
        {
            object.normalFilterVideoCropRect = [object getNormalFilterVideoCropRect];
            object.nationalVideoTransformOutputValue = [object getNationalVideoTransform];
            object.nationalReflectionVideoTransformOutputValue = [object getReflectionNationalVideoTransform];
        }
        
        if (object.mediaType == MEDIA_GIF)
        {
            object.mediaDuration = object.mfEndPosition - object.mfStartPosition;
            
            NSNumber* startPosNum = [NSNumber numberWithFloat:0.0f];
            NSNumber* endPosNum = [NSNumber numberWithFloat:object.mediaDuration];
            NSNumber* motionValueNum = [NSNumber numberWithFloat:1.0f];
            
            if (object.startPositionArray.count > 0)
            {
                [object.startPositionArray replaceObjectAtIndex:0 withObject:startPosNum];
                [object.endPositionArray replaceObjectAtIndex:0 withObject:endPosNum];
                [object.motionArray replaceObjectAtIndex:0 withObject:motionValueNum];
            }
            else
            {
                [object.startPositionArray addObject:startPosNum];
                [object.endPositionArray addObject:endPosNum];
                [object.motionArray addObject:motionValueNum];
            }

            object.currentPosition = kCMTimeZero;
        }
        
        object.superViewSize = CGSizeMake(object.superview.bounds.size.width, object.superview.bounds.size.height);
    }

    int nGifCount = 0;
    self.nGifProcessingIndex = 0;
    self.gifProcessingIndexArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.mediaObjectArray count]; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];

        if (object.mediaType == MEDIA_GIF)
        {
            [self.gifProcessingIndexArray addObject:[NSNumber numberWithInt:i]];
            
            nGifCount++;
        }
    }
    
    if (nGifCount == 0)
    {
        [self.gifProcessingIndexArray removeAllObjects];
        self.gifProcessingIndexArray = nil;
    
        [self outputVideoProcessing];
    }
    else
    {
        NSNumber *indexNumber = [self.gifProcessingIndexArray objectAtIndex:self.nGifProcessingIndex];

        [self makeVideoFromGIF:[indexNumber intValue]];
    }
}

#pragma mark -
#pragma mark - make video from gif

-(void) makeVideoFromGIF:(int) processingIndex
{
    MediaObjectView* gifObject = [self.mediaObjectArray objectAtIndex:processingIndex];

    UIImage* gifImage = gifObject.imageView.image;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
    NSString* dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString* gifVideoName = [NSString stringWithFormat:@"%@.mp4", dateForFilename];
    NSString* gifVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:gifVideoName];
    unlink([gifVideoPath UTF8String]);
    
    gifObject.mediaUrl = [NSURL fileURLWithPath:gifVideoPath];
    
    NSError *error = nil;
    
    AVAssetWriter* videoWriter = [AVAssetWriter assetWriterWithURL:gifObject.mediaUrl
                                                          fileType:AVFileTypeMPEG4
                                                             error:&error];
    NSParameterAssert(videoWriter);
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecTypeH264,
                                    AVVideoWidthKey: [NSNumber numberWithInt:gifImage.size.width],
                                    AVVideoHeightKey: [NSNumber numberWithInt:gifImage.size.height],
    };
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];

    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:nil];


    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    CGFloat videoDuration = gifObject.mfEndPosition - gifObject.mfStartPosition;
    int nFrameIndex = 0;
    int nFrameTotalCount = 0;
    
    CGFloat rFps = gifImage.images.count / gifImage.duration;
    NSInteger nScale = 1;
    NSUInteger fps = 1;

    if (rFps > 1.0f)
    {
        fps = (NSInteger)rFps;
        nFrameTotalCount = videoDuration * fps;
    }
    else
    {
        fps = (NSInteger)(rFps*10);
        nScale = 10;
        nFrameTotalCount = (int)(videoDuration * rFps);
    }
    
    for (int j = 0; j < nFrameTotalCount; j ++)
    {
        @autoreleasepool
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                CMTime lastTime = CMTimeMake(j * nScale, (int32_t)fps);
                CMTime presentTime = lastTime;
                
                UIImage *image = [gifImage.images objectAtIndex:nFrameIndex];
                
                BOOL isGreenBG = NO;
                
                if ((gnOutputVideoFilterIndex == VDOutputFilterTypeNormal) || (processingIndex == 0))
                    isGreenBG = NO;
                else
                    isGreenBG = YES;
                
                buffer = [self pixelBufferFromCGImage:[image CGImage] size:image.size greenBGFlag:isGreenBG];
                
                BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
                
                if (result == NO) //failes on 3GS, but works on iphone 4
                {
                    NSLog(@"failed to append buffer");
                }
                
                if(buffer)
                    CVBufferRelease(buffer);
                
                if (nFrameIndex >= (gifImage.images.count - 1))
                    nFrameIndex = 0;
                else
                    nFrameIndex++;
            }
            else
            {
                NSLog(@"error");
            }
            
            [NSThread sleepForTimeInterval:0.02];
        }
    }
    
    [videoWriterInput markAsFinished];
    
    [videoWriter finishWritingWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted)
            {
                self.nGifProcessingIndex++;
                
                if (self.nGifProcessingIndex >= self.gifProcessingIndexArray.count)
                {
                    [self.gifProcessingIndexArray removeAllObjects];
                    self.gifProcessingIndexArray = nil;
                    
                    [self outputVideoProcessing];
                }
                else
                {
                    NSNumber *indexNumber = [self.gifProcessingIndexArray objectAtIndex:self.nGifProcessingIndex];
                    
                    [self makeVideoFromGIF:[indexNumber intValue]];
                }
            }
            else
            {
                NSLog(@"photos to video is failed!");
            }
        });
    }];
    
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
}


#pragma mark -
#pragma mark - Create pixel buffer from CGImage

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image size:(CGSize) renderSize greenBGFlag:(BOOL)isGreenBG
{
    NSDictionary *options = @{(NSString *)kCVPixelBufferCGImageCompatibilityKey: [NSNumber numberWithBool:YES],
                              (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: [NSNumber numberWithBool:YES]
    };
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          renderSize.width,
                                          renderSize.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess)
        NSLog(@"Failed to create pixel buffer");
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, renderSize.width,
                                                 renderSize.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    if (isGreenBG)
    {
        CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, renderSize.width, renderSize.height));
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, renderSize.width, renderSize.height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

#pragma mark -
#pragma mark - Create Output Video

- (void) outputVideoProcessing
{
    MediaObjectView *objectView = self.mediaObjectArray[0];
    UIView *superview = objectView.superview;
    CGSize videoSize = superview.bounds.size;
    [self.videoEditor setVideoSize:videoSize];
    //[self.videoEditor setVideoSize:CGSizeMake(outputVideoSize.width, outputVideoSize.height)];
    [self.videoEditor setInputObjectArray:self.mediaObjectArray];
    
    if (gnOutputVideoFilterIndex == VDOutputFilterTypeNormal)        //NORMAL
        [self.videoEditor createNormalVideo];
    else                                                             //CHROMAKEY
        [self.videoEditor createChromaKeyFilterOutput];
}


#pragma mark -
#pragma mark - Rename Project

-(void) renameProject
{
    NSString* strMessage = NSLocalizedString(@"Current Project Name is", nil);
    strMessage = [strMessage stringByAppendingString:[NSString stringWithFormat:@" %@. ", gstrCurrentProjectName]];
    strMessage = [strMessage stringByAppendingString:NSLocalizedString(@"Please enter new name!", nil)];
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Rename Project", nil) message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Project Name", nil);
        textField.text = [NSString stringWithFormat:@"%@", gstrCurrentProjectName];
        textField.textColor = [UIColor blackColor];
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        
        [textField performSelector:@selector(selectAll:) withObject:textField afterDelay:0.0f];
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
        UITextField *textField = [alertController.textFields objectAtIndex:0];
        
        if ([textField.text isEqualToString:@""])
        {
            return;
        }
        else
        {
            if ([self.projectManager renameProjectFolder:textField.text])
            {
                [self.projectNameLabel setText:[NSString stringWithFormat:@"%@", gstrCurrentProjectName]];
                
                for (int i = 0; i < self.mediaObjectArray.count; i++)
                {
                    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
                    
                    if (object.mediaType == MEDIA_VIDEO || object.mediaType == MEDIA_MUSIC)
                    {
                        NSURL* url = object.mediaUrl;
                        NSString* mediaName = url.lastPathComponent;
                        
                        NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                        NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
                        mediaName = [folderPath stringByAppendingPathComponent:mediaName];
                        object.mediaUrl = [NSURL fileURLWithPath:mediaName];
                    }
                }
            }
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



#pragma mark -
#pragma mark - Save Project

-(void) saveContinue
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Save & Continue...", nil)) isLock:YES];
    
    [self performSelector:@selector(saveContinueWorkspace) withObject:nil afterDelay:0.02f];
}

-(void) saveCopy
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Save & Copy...", nil)) isLock:YES];
    
    [self performSelector:@selector(saveCopyWorkspace) withObject:nil afterDelay:0.02f];
}

-(void) saveAs
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Save As...", nil)) isLock:YES];
    
    [self performSelector:@selector(saveAsWorkspace) withObject:nil afterDelay:0.02f];
}

-(void) saveExit
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Saving...", nil)) isLock:YES];
    
    [self performSelector:@selector(saveExitWorkspace) withObject:nil afterDelay:0.02f];
}

-(void) noSaveExit
{
    [self noSaveExitWorkspace];
}


#pragma mark -
#pragma mark - Save Continue

-(void) saveContinueWorkspace
{
    NSMutableArray* gifImageArray = [[NSMutableArray alloc] init];
    
    grNormalFilterOutputTotalTime = self.timelineView.totalTime;
    
    for (int i = 0; i < [self.mediaObjectArray count]; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        /* Get video transform */
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
            object.inputTransform = [self getVideoTranslate:object];
        
        /* Get timelines for a Normal Filter */
        object.mfStartPosition = [self.timelineView getStartPosition:i];
        object.mfEndPosition = [self.timelineView getEndPosition:i];
        object.startActionType = [self.timelineView getStartActionType:i];
        object.mfStartAnimationDuration = [self.timelineView getStartActionTime:i];
        object.endActionType = [self.timelineView getEndActionType:i];
        object.mfEndAnimationDuration = [self.timelineView getEndActionTime:i];
        
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
        {
            object.normalFilterVideoCropRect = [object getNormalFilterVideoCropRect];
            object.nationalVideoTransformOutputValue = [object getNationalVideoTransform];
            object.nationalReflectionVideoTransformOutputValue = [object getReflectionNationalVideoTransform];
        }
        
        if (object.mediaType == MEDIA_GIF)
        {
            [gifImageArray addObject:object.imageView.image];
            object.imageView.image = [object.imageView.image.images objectAtIndex:0];
        }
        
        object.superViewSize = CGSizeMake(object.superview.bounds.size.width, object.superview.bounds.size.height);
    }
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage* screenShotImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    int nGifCount = 0;
    
    for (int i = 0; i < [self.mediaObjectArray count]; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];

        if (object.mediaType == MEDIA_GIF)
        {
            object.imageView.image = [gifImageArray objectAtIndex:nGifCount];
            nGifCount++;
        }
    }
    
    [gifImageArray removeAllObjects];
    gifImageArray = nil;
    
    screenShotImg = [screenShotImg rescaleImageToSize:CGSizeMake(self.view.bounds.size.width*0.5f, self.view.bounds.size.height * 0.5f)];
    
    [self.projectManager saveProject:screenShotImg objects:self.mediaObjectArray];
    
    screenShotImg = nil;
    
    [[SHKActivityIndicator currentIndicator] hide];
}

-(void) saveCopyWorkspace
{
    NSMutableArray* gifImageArray = [[NSMutableArray alloc] init];

    grNormalFilterOutputTotalTime = self.timelineView.totalTime;
    
    for (int i = 0; i < [self.mediaObjectArray count]; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        /* Get video transform */
        if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_GIF))
            object.inputTransform = [self getVideoTranslate:object];
        
        /* Get timelines for a Normal Filter */
        object.mfStartPosition = [self.timelineView getStartPosition:i];
        object.mfEndPosition = [self.timelineView getEndPosition:i];
        object.startActionType = [self.timelineView getStartActionType:i];
        object.mfStartAnimationDuration = [self.timelineView getStartActionTime:i];
        object.endActionType = [self.timelineView getEndActionType:i];
        object.mfEndAnimationDuration = [self.timelineView getEndActionTime:i];
        
        if ((object.mediaType == MEDIA_VIDEO) || (object.mediaType == MEDIA_GIF))
        {
            object.normalFilterVideoCropRect = [object getNormalFilterVideoCropRect];
            object.nationalVideoTransformOutputValue = [object getNationalVideoTransform];
            object.nationalReflectionVideoTransformOutputValue = [object getReflectionNationalVideoTransform];
        }
        
        if (object.mediaType == MEDIA_GIF)
        {
            [gifImageArray addObject:object.imageView.image];
            object.imageView.image = [object.imageView.image.images objectAtIndex:0];
        }

        object.superViewSize = CGSizeMake(object.superview.bounds.size.width, object.superview.bounds.size.height);
    }
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage* screenShotImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    int nGifCount = 0;
    
    for (int i = 0; i < [self.mediaObjectArray count]; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        if (object.mediaType == MEDIA_GIF)
        {
            object.imageView.image = [gifImageArray objectAtIndex:nGifCount];
            nGifCount++;
        }
    }
    
    [gifImageArray removeAllObjects];
    gifImageArray = nil;

    screenShotImg = [screenShotImg rescaleImageToSize:CGSizeMake(self.view.bounds.size.width*0.5f, self.view.bounds.size.height*0.5f)];
    
    [self.projectManager copyProject:screenShotImg objects:self.mediaObjectArray];
    
    [[SHKActivityIndicator currentIndicator] hide];
}

-(void) saveAsWorkspace
{
    NSMutableArray* gifImageArray = [[NSMutableArray alloc] init];

    grNormalFilterOutputTotalTime = self.timelineView.totalTime;
    
    for (int i = 0; i < [self.mediaObjectArray count]; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        /* Get video transform */
        if ((object.mediaType == MEDIA_VIDEO) || (object.mediaType == MEDIA_GIF))
            object.inputTransform = [self getVideoTranslate:object];
        
        /* Get timelines for a Normal Filter */
        object.mfStartPosition = [self.timelineView getStartPosition:i];
        object.mfEndPosition = [self.timelineView getEndPosition:i];
        object.startActionType = [self.timelineView getStartActionType:i];
        object.mfStartAnimationDuration = [self.timelineView getStartActionTime:i];
        object.endActionType = [self.timelineView getEndActionType:i];
        object.mfEndAnimationDuration = [self.timelineView getEndActionTime:i];
        
        if ((object.mediaType == MEDIA_VIDEO) || (object.mediaType == MEDIA_GIF))
        {
            object.normalFilterVideoCropRect = [object getNormalFilterVideoCropRect];
            object.nationalVideoTransformOutputValue = [object getNationalVideoTransform];
            object.nationalReflectionVideoTransformOutputValue = [object getReflectionNationalVideoTransform];
        }
        
        if (object.mediaType == MEDIA_GIF)
        {
            [gifImageArray addObject:object.imageView.image];
            object.imageView.image = [object.imageView.image.images objectAtIndex:0];
        }

        object.superViewSize = CGSizeMake(object.superview.bounds.size.width, object.superview.bounds.size.height);
    }
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage* screenShotImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    int nGifCount = 0;
    
    for (int i = 0; i < [self.mediaObjectArray count]; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        if (object.mediaType == MEDIA_GIF)
        {
            object.imageView.image = [gifImageArray objectAtIndex:nGifCount];
            nGifCount++;
        }
    }
    
    [gifImageArray removeAllObjects];
    gifImageArray = nil;

    UIImage *resizedImage = [screenShotImg rescaleImageToSize:CGSizeMake(self.view.bounds.size.width*0.5f, self.view.bounds.size.height*0.5f)];
    
    [self.projectManager saveAsProject:resizedImage objects:self.mediaObjectArray];
    
    gstrCurrentProjectName = self.projectManager.projectName;
    [self.projectNameLabel setText:[NSString stringWithFormat:@"%@", gstrCurrentProjectName]];

    [[SHKActivityIndicator currentIndicator] hide];
}

-(void) saveExitWorkspace
{
    grNormalFilterOutputTotalTime = self.timelineView.totalTime;
    
    for (int i = 0; i < [self.mediaObjectArray count]; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        /* Get video transform */
        if (object.mediaType == MEDIA_VIDEO || object.mediaType == MEDIA_GIF)
            object.inputTransform = [self getVideoTranslate:object];
        
        /* Get timelines for a Normal Filter */
        object.mfStartPosition = [self.timelineView getStartPosition:i];
        object.mfEndPosition = [self.timelineView getEndPosition:i];
        object.startActionType = [self.timelineView getStartActionType:i];
        object.mfStartAnimationDuration = [self.timelineView getStartActionTime:i];
        object.endActionType = [self.timelineView getEndActionType:i];
        object.mfEndAnimationDuration = [self.timelineView getEndActionTime:i];
        
        if ((object.mediaType == MEDIA_VIDEO) || (object.mediaType == MEDIA_GIF))
        {
            object.normalFilterVideoCropRect = [object getNormalFilterVideoCropRect];
            object.nationalVideoTransformOutputValue = [object getNationalVideoTransform];
            object.nationalReflectionVideoTransformOutputValue = [object getReflectionNationalVideoTransform];
        }
        
        if (object.mediaType == MEDIA_GIF)
        {
            object.imageView.image = [object.imageView.image.images objectAtIndex:0];
        }
        
        object.superViewSize = CGSizeMake(object.superview.bounds.size.width, object.superview.bounds.size.height);
    }

    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage* screenShotImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    screenShotImg = [screenShotImg rescaleImageToSize:CGSizeMake(self.view.bounds.size.width*0.5f, self.view.bounds.size.height*0.5f)];
    
    [self.projectManager saveProject:screenShotImg objects:self.mediaObjectArray];
    
    gnOrientation = ORIENTATION_ALL;
    
    self.playerItem = nil;
    
    if (self.playerObserver) {
        [self.videoPlayer removeTimeObserver:self.playerObserver];
        self.playerObserver = nil;
    }
    
    [self.videoPlayer pause];
    self.videoPlayer = nil;
    
    [self.videoPlayerLayer removeFromSuperlayer];
    self.videoPlayerLayer = nil;
    
    self.settingsView = nil;
    self.filterListView = nil;

    [[SHKActivityIndicator currentIndicator] hide];

    [self.navigationController popViewControllerAnimated:NO];
}

- (void) noSaveExitWorkspace
{
    [self.projectManager noSaveProject];
    
    gnOrientation = ORIENTATION_ALL;
    
    self.playerItem = nil;
    
    if (self.playerObserver) {
        [self.videoPlayer removeTimeObserver:self.playerObserver];
        self.playerObserver = nil;
    }
    
    [self.videoPlayer pause];
    self.videoPlayer = nil;
    
    [self.videoPlayerLayer removeFromSuperlayer];
    self.videoPlayerLayer = nil;
    
    self.settingsView = nil;
    self.filterListView = nil;
    
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark -
#pragma mark - ********* A/V Choose Delegate Functions ***********

-(void) requestCameraAuthorization:(void(^)(BOOL granted))completion {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(true);
        });
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(granted);
            });
        }];
    }
}

-(void) requestMicrophoneAuthorization:(void(^)(BOOL granted))completion {
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] == AVAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(true);
        });
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(granted);
            });
        }];
    }
}

-(void) onPhotoFromCamera
{
    [self requestCameraAuthorization:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [self openPhotoFromCamera];
            } else {
                [self showAlertViewController:NSLocalizedString(@"Video Dreamer is unable to access Camera", nil) message:NSLocalizedString(@"To enable access to the Camera, follow these steps:\r\n Go to: Settings -> Privacy -> Camera and turn ON access for Video Dreamer.", nil) okHandler:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                }];
            }
        });
    }];
}

-(void) openPhotoFromCamera
{
    isMultiplePhotos = NO;
    
    if (self.multiplePhotosArray != nil)
    {
        [self.multiplePhotosArray removeAllObjects];
        self.multiplePhotosArray = nil;
    }
    
    self.multiplePhotosArray = [[NSMutableArray alloc] init];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    /*if (@available(iOS 16.0, *)) {
        UIWindowScene *windowScene = [[UIApplication sharedApplication] windowScene];
        UIWindowSceneGeometryPreferencesIOS *preferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
        [windowScene requestGeometryUpdateWithPreferences:preferences errorHandler:nil];
    } else {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }*/
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) //iphone
    {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            gnOrientation = ORIENTATION_ALL;
            
            if (self.cameraPickerController != nil)
            {
                [self.cameraPickerController removeCustomOverlayView];
                [self.cameraPickerController dismissViewControllerAnimated:YES completion:nil];
                self.cameraPickerController = nil;
            }
            
            self.cameraPickerController = [[YJLCameraPickerController alloc] init];
            self.cameraPickerController.delegate = self;
            self.cameraPickerController.cameraOverlayDelegate = self;
            self.cameraPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.cameraPickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            
            if (isIPhoneFive)
                self.cameraPickerController.cameraViewTransform = CGAffineTransformTranslate(self.cameraPickerController.cameraViewTransform, 0.0f, 60.0f);
            
            self.cameraPickerController.cameraOverlayView = nil;
            self.cameraPickerController.showsCameraControls = NO;
            self.cameraPickerController.navigationBarHidden = YES;
            
            [self presentViewController:self.cameraPickerController animated:YES completion:^{

                [self.cameraPickerController initOverlayViewWithFrame:self.cameraPickerController.view.bounds isPhoto:YES type:gnTemplateIndex superView:self.view];

            }];
        }
        else
        {
            [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"No camera available!", nil) okHandler:nil];
        }
    }
    else //ipad
    {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            gnOrientation = ORIENTATION_ALL;
            
            if (self.cameraPickerController != nil)
            {
                [self.cameraPickerController removeCustomOverlayView];
                [self.cameraPickerController dismissViewControllerAnimated:YES completion:nil];
                self.cameraPickerController = nil;
            }
            
            self.cameraPickerController = [[YJLCameraPickerController alloc] init];
            self.cameraPickerController.delegate = self;
            self.cameraPickerController.cameraOverlayDelegate = self;
            self.cameraPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.cameraPickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
            self.cameraPickerController.cameraViewTransform = CGAffineTransformScale(self.cameraPickerController.cameraViewTransform, 1, 1);
            self.cameraPickerController.cameraOverlayView = nil;
            self.cameraPickerController.showsCameraControls = NO;
            self.cameraPickerController.navigationBarHidden = YES;
            
            [self presentViewController:self.cameraPickerController animated:YES completion:^{
                
                [self.cameraPickerController initOverlayViewWithFrame:self.cameraPickerController.view.bounds isPhoto:YES type:gnTemplateIndex superView:self.view];
                
            }];
        }
        else
        {
            [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"No camera available!", nil) okHandler:nil];
        }
    }
}

-(void) onPhotoFromGallery
{
    isMultiplePhotos = NO;

    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    isPhotoTake = YES;

    if (!self.customAssetPicker)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        self.customAssetPicker = [sb instantiateViewControllerWithIdentifier:@"CustomAssetPickerController"];
        self.customAssetPicker.customAssetDelegate = self;
        self.customAssetPicker.filterType = PHAssetMediaTypeImage;
    }
    
    self.customAssetPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.customAssetPicker animated:YES completion:nil];
}

-(void) onVideoFromCamera
{
    [self requestCameraAuthorization:^(BOOL granted) {
        if (granted) {
            [self openVideoFromCamera];
        } else {
            [self showAlertViewController:NSLocalizedString(@"Video Dreamer is unable to access Camera", nil) message:NSLocalizedString(@"To enable access to the Camera, follow these steps:\r\n Go to: Settings -> Privacy -> Camera and turn ON access for Video Dreamer.", nil) okHandler:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }];
        }
    }];
}

-(void) openVideoFromCamera
{
    isMultiplePhotos = NO;

    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            gnOrientation = ORIENTATION_ALL;
            
            if (self.cameraPickerController != nil)
            {
                [self.cameraPickerController removeCustomOverlayView];
                [self.cameraPickerController dismissViewControllerAnimated:YES completion:nil];
                self.cameraPickerController = nil;
            }

            self.cameraPickerController = [[YJLCameraPickerController alloc] init];
            self.cameraPickerController.delegate = self;
            self.cameraPickerController.cameraOverlayDelegate = self;
            self.cameraPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.cameraPickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];

            if (!isIPhoneFive)
                self.cameraPickerController.cameraViewTransform = CGAffineTransformTranslate(self.cameraPickerController.cameraViewTransform, 0.0f, 27.0f);
            else
                self.cameraPickerController.cameraViewTransform = CGAffineTransformScale(self.cameraPickerController.cameraViewTransform, 1, 1);

            self.cameraPickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
            self.cameraPickerController.cameraOverlayView = nil;
            self.cameraPickerController.showsCameraControls = NO;
            self.cameraPickerController.navigationBarHidden = YES;

            self.cameraPickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:self.cameraPickerController animated:YES completion:^{
                [self.cameraPickerController initOverlayViewWithFrame:self.cameraPickerController.view.bounds isPhoto:NO type:gnTemplateIndex superView:self.view];
            }];
        }
        else
        {
            [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"No camera available!", nil) okHandler:nil];
        }
    }
    else
    {
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            gnOrientation = ORIENTATION_ALL;
            
            if (self.cameraPickerController != nil)
            {
                [self.cameraPickerController removeCustomOverlayView];
                [self.cameraPickerController dismissViewControllerAnimated:YES completion:nil];
                self.cameraPickerController = nil;
            }
            
            self.cameraPickerController = [[YJLCameraPickerController alloc] init];
            self.cameraPickerController.delegate = self;
            self.cameraPickerController.cameraOverlayDelegate = self;
            self.cameraPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.cameraPickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
            self.cameraPickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
            
            if ((gnTemplateIndex == TEMPLATE_PORTRAIT)||(gnTemplateIndex == TEMPLATE_LANDSCAPE)||(gnTemplateIndex == TEMPLATE_SQUARE))
                self.cameraPickerController.cameraViewTransform = CGAffineTransformScale(self.cameraPickerController.cameraViewTransform, 1.4f, 1.4f);
            else
                self.cameraPickerController.cameraViewTransform = CGAffineTransformScale(self.cameraPickerController.cameraViewTransform, 1, 1);
            
            self.cameraPickerController.cameraOverlayView = nil;
            self.cameraPickerController.showsCameraControls = NO;
            self.cameraPickerController.navigationBarHidden = YES;
            
            self.cameraPickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:self.cameraPickerController animated:YES completion:^{
                
                [self.cameraPickerController initOverlayViewWithFrame:self.cameraPickerController.view.bounds isPhoto:NO type:gnTemplateIndex superView:self.view];
                
            }];
        }
        else
        {
            [self showAlertViewController:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"No camera available!", nil) okHandler:nil];
        }
    }
}

-(void) onVideoFromGallery
{
    isMultiplePhotos = NO;

    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    isPhotoTake = NO;
    
    if (!self.customAssetPicker)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        self.customAssetPicker = [sb instantiateViewControllerWithIdentifier:@"CustomAssetPickerController"];
        self.customAssetPicker.customAssetDelegate = self;
        self.customAssetPicker.filterType = PHAssetMediaTypeVideo;
    }
    
    self.customAssetPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.customAssetPicker animated:YES completion:nil];
}

-(void) onStingerVideos
{
    isMultiplePhotos = NO;
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    isPhotoTake = NO;

    if (!self.stingerGalleryPickerController)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"StingerGalleryStoryboard" bundle:nil];
        self.stingerGalleryPickerController = [sb instantiateViewControllerWithIdentifier:@"StingerGalleryPickerController"];
        self.stingerGalleryPickerController.stingerGalleryPickerControllerDelegate = self;
    }
    
    self.stingerGalleryPickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.stingerGalleryPickerController animated:YES completion:nil];
}

-(void) onShapesGallery
{
    isMultiplePhotos = NO;
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    isPhotoTake = NO;
    
    if (!self.shapeGalleryPickerController)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ShapeGalleryStoryboard" bundle:nil];
        self.shapeGalleryPickerController = [sb instantiateViewControllerWithIdentifier:@"ShapeGalleryPickerController"];
        self.shapeGalleryPickerController.shapeGalleryDelegate = self;
    }
    
    self.shapeGalleryPickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.shapeGalleryPickerController animated:YES completion:nil];
}

-(void) onGIFsGallery
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Loading...", nil)) isLock:YES];

    isMultiplePhotos = NO;
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    isPhotoTake = NO;
    
    if (!self.gifGalleryPickerController)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GIFGalleryStoryboard" bundle:nil];
        self.gifGalleryPickerController = [sb instantiateViewControllerWithIdentifier:@"GIFGalleryPickerController"];
        self.gifGalleryPickerController.gifGalleryDelegate = self;
    }
    
    self.gifGalleryPickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.gifGalleryPickerController animated:YES completion:nil];
}

-(void) onMusic
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if (!self.musicPicker)
    {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:NO forKey:@"fromDownload"];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"YJLCustomMusicPickerStoryboard" bundle:nil];
        self.musicPicker = [sb instantiateViewControllerWithIdentifier:@"YJLCustomMusicController"];
        self.musicPicker.customMusicDelegate = self;
    }
    
    self.musicPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.musicPicker animated:YES completion:nil];
}

-(void) onText
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    [self generateNewTextObject];
}

-(void) updateObjectEdit
{
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        if (i == gnSelectedObjectIndex)
        {
            object.alpha = 1.0f;
            
            if ((object.mediaType == MEDIA_PHOTO) || (object.mediaType == MEDIA_GIF) || (object.mediaType == MEDIA_TEXT)) {
                [self.playingButton setEnabled:NO];
                [self.seekSlider setEnabled:NO];
                [self.currentSeekTimeLabel setText:@"00:00.000"];
                [self.totalSeekTimeLabel setText:@"00:00.000"];
            } else if ((object.mediaType == MEDIA_VIDEO) || (object.mediaType == MEDIA_MUSIC)) {
                [self.playingButton setEnabled:YES];
                [self.seekSlider setEnabled:YES];
            }
        }
        else
        {
            object.alpha = 0.0f;
        }
    }
    
    if (self.mediaObjectArray.count == self.timelineView.sliderArray.count)
        [self refreshObjectEditThumbnailView];
}

#pragma mark -
#pragma mark - ************** YJLCustomMusicPickerController Delegate - Custom Music ****************

- (void)musicPickerControllerDidCancel:(YJLCustomMusicController *)picker
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.musicPicker dismissViewControllerAnimated:YES completion:^{
        self.musicPicker = nil;
    }];
}

- (void)musicPickerControllerDidSelected:(YJLCustomMusicController *)picker asset:(NSURL *)assetUrl
{
    [self fixAppOrientationAfterDismissImagePickerController];

    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if (self.mediaTrimView != nil)
    {
        [self.mediaTrimView removeFromSuperview];
        self.mediaTrimView = nil;
    }
    
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Loading...", nil)) isLock:YES];

    dispatch_async(dispatch_get_main_queue(), ^{

        self.mediaTrimView = [[MediaTrimView alloc] initWithFrame:self.view.bounds url:assetUrl type:MEDIA_MUSIC flag:NO superView:self.view];
        self.mediaTrimView.delegate = self;
        [self.view addSubview:self.mediaTrimView];
        self.mediaTrimView.frame = CGRectMake(0.0f, self.mediaTrimView.frame.size.height, self.mediaTrimView.frame.size.width, self.mediaTrimView.frame.size.height);
        
        [UIView animateWithDuration:0.3f animations:^{
            
            self.mediaTrimView.frame = CGRectMake(0.0f, 0.0f, self.mediaTrimView.frame.size.width, self.mediaTrimView.frame.size.height);
            
        } completion:^(BOOL finished) {

        }];
    });

    [self.musicPicker dismissViewControllerAnimated:YES completion:^{
        self.musicPicker = nil;
    }];
}


#pragma mark -
#pragma mark - iOS 8 - CustomAssetPickerControllerDelegate

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self fixAppOrientationAfterDismissImagePickerController];
        
        for (int i = 0; i < assets.count; i++)
        {
            PHAsset *asset = [assets objectAtIndex:i];
            NSString *identifier = asset.localIdentifier;
            NSRange range = [identifier rangeOfString:@"/"];
            identifier = [identifier substringToIndex:range.location];
            
            PHAssetMediaType type = asset.mediaType;
            
            if (type == PHAssetMediaTypeVideo)    // Video
            {
                @autoreleasepool
                {
                    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                    options.version = PHVideoRequestOptionsVersionCurrent;
                    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                    options.networkAccessAllowed = YES;
                    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
                        
                        if ([avAsset isKindOfClass:[AVURLAsset class]]) //normal video
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{

                                NSURL* url = [(AVURLAsset*)avAsset URL];
                                [self generationVideoView:url flag:NO];

                            });
                        }
                        else  //Slow-Mo video
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {

                                    NSURL* url = [info objectForKey:@"PHImageFileURLKey"];

                                    if (url)
                                    {
                                        [self generationVideoView:url flag:NO];
                                    }
                                    else
                                    {
                                        AVAssetExportSession *session = [[YLVideoService sharedInstance] saveVideoToFile:avAsset identifier:identifier completion:^(NSURL * _Nonnull fileURL) {
                                            if (fileURL) {
                                                [self generationVideoView:fileURL flag:NO];
                                            }
                                        }];
                                        if (session != nil) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self startAllNormalProgress:session current:1 total:1];
                                            });
                                        }
                                    }
                                }];
                            });
                        }
                    }];
                }
            }
            else if (type == PHAssetMediaTypeImage)   //Photo
            {
                @autoreleasepool
                {
                    PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
                    options.synchronous = YES;
                    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                   
                    [[PHImageManager defaultManager] requestImageForAsset:asset
                                                               targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                                                              contentMode:PHImageContentModeDefault
                                                                  options:options
                                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                
                        /*  rotate image by width and height */
                        result = [UIImage rotateImage:result];
                                                                
                                                                
                        /*******************************************************/
                        /* detect transparency, if png or jpg is not transparency, compress that to 30%*/
                        /*******************************************************/
                        /* detect transparency png */
                        
                        
                                                                
                        //Added By Yinjing
//                        if (!isTransparency)    /* if png is non-transparency, compress to 30% */
//                        {
//                            if (isIPhoneFive && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//                            {
//                                NSData* data = UIImageJPEGRepresentation(result, 0.6f);
//                                result = [UIImage imageWithData:data];
//                            }
//                            else
//                            {
//                                NSData* data = UIImageJPEGRepresentation(result, 0.3f);
//                                result = [UIImage imageWithData:data];
//                            }
//                        }
                        /************************************************************/
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
                        NSString *dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
                        
                        NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                        NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
                        NSString *imageName = [NSString stringWithFormat:@"image-%@%d.png", dateForFilename, i];
                        NSString *fileName = [folderPath stringByAppendingPathComponent:imageName];
                        
                        if([UIImagePNGRepresentation(result) writeToFile:fileName atomically:YES])
                        {
                            /* generate imageView from UIImage */
                            [self generationImageView:imageName];
                        }
                    }];
                    
                    options = nil;
                }
            }
        }
        
        [self.customAssetPicker dismissViewControllerAnimated:YES completion:^{
            self.customAssetPicker = nil;
            
            [[SHKActivityIndicator currentIndicator] hide];
        }];
        
        [self updateObjectEdit];
    });
}

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingMovies:(NSArray *)movies
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self fixAppOrientationAfterDismissImagePickerController];
        
        for (int i = 0; i < movies.count; i++)
        {
            MPMediaItemCollection* item = [movies objectAtIndex:i];
            
            MPMediaItem *representativeItem = [item representativeItem];
            NSURL *url = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
            
            [self generationVideoView:url flag:NO];
        }
        
        [self.customAssetPicker dismissViewControllerAnimated:YES completion:^{
            self.customAssetPicker = nil;
            
            [[SHKActivityIndicator currentIndicator] hide];
        }];
        
        [self updateObjectEdit];
    });
}

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingShapes:(NSArray *)indexArray
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self fixAppOrientationAfterDismissImagePickerController];
        
        for (int i = 0; i < indexArray.count; i++)
        {
            NSNumber* number = [indexArray objectAtIndex:i];
            NSInteger index = [number integerValue];
            
            UIImage* shapeImage = [UIImage imageNamed:[NSString stringWithFormat:@"shape%d", (int)index]];
            
            /*  rotate image by width and height */
            shapeImage = [UIImage rotateImage:shapeImage];
            
            /*******************************************************/
            /* detect transparency, if png or jpg is not transparency, compress that to 30 %*/
            /*******************************************************/
            /* detect transparency png */
            BOOL isTransparency = [shapeImage detectTransparency];
            
            if (!isTransparency)    /* if png is non-transparency, compress to 30% */
            {
                if (isIPhoneFive && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                {
                    NSData* data = UIImageJPEGRepresentation(shapeImage, 0.6f);
                    shapeImage = [UIImage imageWithData:data];
                }
                else
                {
                    NSData* data = UIImageJPEGRepresentation(shapeImage, 0.3f);
                    shapeImage = [UIImage imageWithData:data];
                }
            }
            /************************************************************/
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
            NSString *dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
            
            NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
            NSString* imageName = [NSString stringWithFormat:@"image-%@.png", dateForFilename];
            NSString *fileName = [folderPath stringByAppendingPathComponent:imageName];
            
            [UIImagePNGRepresentation(shapeImage) writeToFile:fileName atomically:YES];
            
            
            /* generate imageView from UIImage */
            [self generationImageView:imageName];
            
            MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
            object.isShape = YES;
        }
        
        [self.customAssetPicker dismissViewControllerAnimated:YES completion:^{
            self.customAssetPicker = nil;
            
            [[SHKActivityIndicator currentIndicator] hide];
        }];
        
        [self updateObjectEdit];
    });
}


- (void)customAssetsPickerControllerDidCancel:(CustomAssetPickerController *)picker
{
    isReplace = NO;
    
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.customAssetPicker dismissViewControllerAnimated:YES completion:^{
        self.customAssetPicker = nil;
    }];
}

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker failedWithError:(NSError *)error
{
    
}


#pragma mark -
#pragma mark - *********** YJLCameraOverlayViewDelegate - Custom Camera Overlay View **********

- (void)actionCameraCancel
{
    isReplace = NO;

    [self fixAppOrientationAfterDismissImagePickerController];

    [self.cameraPickerController dismissViewControllerAnimated:YES completion:^{

        self.cameraPickerController = nil;
        
        self->isMultiplePhotos = NO;

        [self.multiplePhotosArray removeAllObjects];
        self.multiplePhotosArray = nil;
    }];
}

- (void)selectedMultiplePhotos:(BOOL) multiplePhotos
{
    isMultiplePhotos = multiplePhotos;
}

- (void)actionUsePhotos
{
    [self performSelector:@selector(importMultiplePhotos) withObject:nil afterDelay:0.02f];
}

- (void)importMultiplePhotos
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.cameraPickerController dismissViewControllerAnimated:YES completion:^{

        self.cameraPickerController = nil;
        
        int i = 0;
        
        for (NSDictionary* info in self.multiplePhotosArray)
        {
            @autoreleasepool
            {
                UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
                /*  rotate image by width and height */
                image = [UIImage rotateImage:image];
                
                /*******************************************************/
                /* detect transparency, if png or jpg is not transparency, compress that to 30% */
                /*******************************************************/
                /* detect transparency png */
                BOOL isTransparency = [image detectTransparency];
                
                /* if png is non-transparency, compress to 30% */
                if (!isTransparency)
                {
                    if (isIPhoneFive && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    {
                        NSData* data = UIImageJPEGRepresentation(image, 0.6f);
                        image = [UIImage imageWithData:data];
                    }
                    else
                    {
                        NSData* data = UIImageJPEGRepresentation(image, 0.3f);
                        image = [UIImage imageWithData:data];
                    }
                }
                /************************************************************/
                
                if (gnTemplateIndex == TEMPLATE_SQUARE) {
                    image = [self cropCameraImage:image];
                }
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
                NSString *dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
                
                NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
                NSString* imageName = [NSString stringWithFormat:@"image-%@%d.png", dateForFilename, i];
                NSString *fileName = [folderPath stringByAppendingPathComponent:imageName];
                
                [UIImagePNGRepresentation(image) writeToFile:fileName atomically:YES];
                
                /* generate imageView from UIImage */
                [self generationImageView:imageName];
                
                i++;
            }
        }
        
        self->isMultiplePhotos = NO;
        
        [self.multiplePhotosArray removeAllObjects];
        self.multiplePhotosArray = nil;
        
        [[SHKActivityIndicator currentIndicator] hide];
        
        [self updateObjectEdit];
    }];
}


#pragma mark -
#pragma mark - ********** UIImagePickerController delegate **********

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    isReplace = NO;
    
    [self fixAppOrientationAfterDismissImagePickerController];
   
    [picker dismissViewControllerAnimated:YES completion:^{
        
        self.cameraPickerController = nil;
        
        [self.multiplePhotosArray removeAllObjects];
        self.multiplePhotosArray = nil;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];

    // if media is a photo.
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)  // handle a photo
    {
        if (isMultiplePhotos)
        {
            [self.multiplePhotosArray addObject:info];
        }
        else
        {
            [self fixAppOrientationAfterDismissImagePickerController];
            
            [picker dismissViewControllerAnimated:YES completion:^{
                
                self.cameraPickerController = nil;
                
                @autoreleasepool
                {
                    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
                    /*  rotate image by width and height */
                    image = [UIImage rotateImage:image];
                    
                    /*******************************************************/
                    /* detect transparency, if png or jpg is not transparency, compress that to 30%*/
                    /*******************************************************/
                    /* detect transparency png */
                    BOOL isTransparency = [image detectTransparency];
                    
                    /* if png is non-transparency, compress to 30% */
                    if (!isTransparency)
                    {
                        if (isIPhoneFive && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                        {
                            NSData* data = UIImageJPEGRepresentation(image, 0.6f);
                            image = [UIImage imageWithData:data];
                        }
                        else
                        {
                            NSData* data = UIImageJPEGRepresentation(image, 0.3f);
                            image = [UIImage imageWithData:data];
                        }
                    }
                    /************************************************************/
                    
                    if (gnTemplateIndex == TEMPLATE_SQUARE) {
                        image = [self cropCameraImage:image];
                    }
                    
                    NSDate *date = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
                    NSString *dateForFilename = [dateFormatter stringFromDate:date];
                    
                    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
                    NSString* imageName = [NSString stringWithFormat:@"image-%@.png", dateForFilename];
                    NSString *fileName = [folderPath stringByAppendingPathComponent:imageName];
                    
                    [UIImagePNGRepresentation(image) writeToFile:fileName atomically:YES];
                    
                    /* generate imageView from UIImage */
                    [self generationImageView:imageName];
                }
                
                [[SHKActivityIndicator currentIndicator] hide];
                
                [self updateObjectEdit];
            }];
        }
    }   // if media is a video.
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)     // Handle a movie capture
    {
        [self fixAppOrientationAfterDismissImagePickerController];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            self.cameraPickerController = nil;
            
            @autoreleasepool
            {
                NSURL* videoUrl = nil;
                videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
                
                if (videoUrl == nil)
                    videoUrl = [info objectForKey:UIImagePickerControllerMediaMetadata];
                
                [self generationVideoView:videoUrl flag:YES];
            }
            
            [[SHKActivityIndicator currentIndicator] hide];
        }];
    }
}

-(UIImage*) cropCameraImage:(UIImage*) image
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if ((gnTemplateIndex == TEMPLATE_1080P) && (image.size.width > image.size.height))
            image = [image cropImageToRect:CGRectMake(0.0f, (image.size.height - image.size.width * 0.5625f) / 2.0f, image.size.width, 0.5625f * image.size.width)];
        else if ((gnTemplateIndex == TEMPLATE_SQUARE) && (image.size.width > image.size.height))
            image = [image cropImageToRect:CGRectMake((image.size.width - image.size.height) / 2.0f, 0.0f, image.size.height, image.size.height)];
        else if ((gnTemplateIndex == TEMPLATE_SQUARE) && (image.size.width < image.size.height))
            image = [image cropImageToRect:CGRectMake(0.0f, (image.size.height - image.size.width) / 2.0f, image.size.width, image.size.width)];
    }
    else
    {
        if ((gnTemplateIndex == TEMPLATE_1080P) && (image.size.width > image.size.height))
        {
            if (isIPhoneFive)
                image = [image cropImageToRect:CGRectMake(0.0f, (image.size.height - image.size.width * 320.0f / 568.0f) / 2.0f, image.size.width, 320.0f / 568.0f * image.size.width)];
            else
                image = [image cropImageToRect:CGRectMake(0.0f, (image.size.height - image.size.width * 0.5625f) / 2.0f, image.size.width, 0.5625f * image.size.width)];
        }
        else if ((gnTemplateIndex == TEMPLATE_LANDSCAPE) && (image.size.width > image.size.height))
        {
            if (isIPhoneFive)
                image = [image cropImageToRect:CGRectMake(0.0f, (image.size.height - image.size.width * 320.0f / 568.0f) / 2.0f, image.size.width, 320.0f / 568.0f * image.size.width)];
            else
                image = [image cropImageToRect:CGRectMake(0.0f, (image.size.height - image.size.width * 320.0f / 480.0f) / 2.0f, image.size.width, 320.0f / 480.0f * image.size.width)];
        }
        else if ((gnTemplateIndex == TEMPLATE_PORTRAIT) && (image.size.width < image.size.height))
        {
            if (isIPhoneFive)
                image = [image cropImageToRect:CGRectMake((image.size.width - image.size.height * 320.0f / 568.0f) / 2.0, 0.0f, image.size.height * 320.0f / 568.0f, image.size.height)];
            else
                image = [image cropImageToRect:CGRectMake((image.size.width - image.size.height * 320.0f / 480.0f) / 2.0, 0.0f, image.size.height * 320.0f / 480.0f, image.size.height)];
        }
        else if ((gnTemplateIndex == TEMPLATE_SQUARE) && (image.size.width > image.size.height))
        {
            image = [image cropImageToRect:CGRectMake((image.size.width - image.size.height) / 2.0f, 0.0f, image.size.height, image.size.height)];
        }
        else if ((gnTemplateIndex == TEMPLATE_SQUARE) && (image.size.width < image.size.height))
        {
            image = [image cropImageToRect:CGRectMake(0.0f, (image.size.height - image.size.width) / 2.0f, image.size.width, image.size.width)];
        }
    }

    return image;
}


#pragma mark -
#pragma mark - ************ Generate Photo, GIF, Video, Text and Music Object **************


- (void) generationImageView:(NSString*) imageName
{
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSString *fileName = [folderPath stringByAppendingPathComponent:imageName];

    NSDictionary *imageSourceOptions = @{(id)kCGImageSourceShouldCache: @NO};
    CGImageSourceRef source = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:fileName], (__bridge CFDictionaryRef)imageSourceOptions);
    
    if (!source) {
        return;
    }
    NSDictionary* imageHeader = (__bridge_transfer NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);

    CGFloat pixelWidth = [[imageHeader objectForKey:(NSString *)kCGImagePropertyPixelWidth] doubleValue];
    CGFloat pixelHeight = [[imageHeader objectForKey:(NSString *)kCGImagePropertyPixelHeight] doubleValue];

    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    CFRelease(source);

    CGSize workspaceSize = CGSizeMake(self.workspaceView.bounds.size.width, self.workspaceView.bounds.size.height);
    
    float rWidth, rHeight;
    
    float rScaleX = imageSize.width / workspaceSize.width;
    float rScaleY = imageSize.height / workspaceSize.height;
    
    if (rScaleX >= rScaleY)
    {
        rWidth = workspaceSize.width;
        rHeight = imageSize.height * workspaceSize.width / imageSize.width;
    }
    else
    {
        rHeight = workspaceSize.height;
        rWidth = imageSize.width * workspaceSize.height / imageSize.height;
    }

    if (gnDefaultOutlineType > 1)
    {
        rWidth = rWidth - grDefaultOutlineWidth * 2.0f;
        rHeight = rHeight - grDefaultOutlineWidth * 2.0f;
    }

    //marked by Yinjing Li, 2017/05/01
    //image = [image rescaleImageToSize:CGSizeMake(rWidth, rHeight)];
    
    if (self.mediaObjectArray == nil)
        self.mediaObjectArray = [[NSMutableArray alloc] init];
    
    CGRect objectRect = CGRectMake((workspaceSize.width - rWidth) / 2.0, (workspaceSize.height - rHeight) / 2.0, rWidth, rHeight);
    NSLog(@"down sample size = %f", objectRect.size.width);
    MediaObjectView* object = [[MediaObjectView alloc] initWithImage:[UIImage downsample:[NSURL fileURLWithPath:fileName] size:objectRect.size scale:[UIScreen mainScreen].scale] frame:CGRectMake((workspaceSize.width - rWidth) / 2.0, (workspaceSize.height - rHeight) / 2.0, rWidth, rHeight)];
    object.delegate = self;
    object.imageName = imageName;
    
    if (isReplace)
    {
        /* remove an old object */
        MediaObjectView* selectedObj = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        selectedObj.startActionType = [self.timelineView getStartActionType:gnSelectedObjectIndex];
        selectedObj.mfStartAnimationDuration = [self.timelineView getStartActionTime:gnSelectedObjectIndex];
        selectedObj.endActionType = [self.timelineView getEndActionType:gnSelectedObjectIndex];
        selectedObj.mfEndAnimationDuration = [self.timelineView getEndActionTime:gnSelectedObjectIndex];
        
        object.startActionType = selectedObj.startActionType;
        object.mfStartAnimationDuration = selectedObj.mfStartAnimationDuration;
        object.endActionType = selectedObj.endActionType;
        object.mfEndAnimationDuration = selectedObj.mfEndAnimationDuration;
        object.objectBorderStyle = selectedObj.objectBorderStyle;
        object.objectBorderWidth = selectedObj.objectBorderWidth;
        object.objectBorderColor = selectedObj.objectBorderColor;
        object.objectShadowStyle = selectedObj.objectShadowStyle;
        object.objectShadowBlur = selectedObj.objectShadowBlur;
        object.objectShadowOffset = selectedObj.objectShadowOffset;
        object.objectShadowColor = selectedObj.objectShadowColor;
        object.objectChromaColor = selectedObj.objectChromaColor;
        object.objectChromaTolerance = selectedObj.objectChromaTolerance;
        object.objectChromaNoise = selectedObj.objectChromaNoise;
        object.objectChromaEdges = selectedObj.objectChromaEdges;
        object.objectChromaOpacity = selectedObj.objectChromaOpacity;
        object.objectCornerRadius = selectedObj.objectCornerRadius;
        object.imageView.alpha = selectedObj.imageView.alpha;
        object.borderLineLayer.opacity = selectedObj.borderLineLayer.opacity;
        
        [object applyBorder];
        [object applyShadow];
        
        object.isReflection = selectedObj.isReflection;
        object.reflectionScale = selectedObj.reflectionScale;
        object.reflectionAlpha = selectedObj.reflectionAlpha;
        object.reflectionGap = selectedObj.reflectionGap;
        object.reflectionDelta = selectedObj.reflectionDelta;
        
        [object update];

        object.mySX *= selectedObj.mySX;
        object.mySY *= selectedObj.mySY;
        
        object.transform = CGAffineTransformScale(object.transform, object.mySX, object.mySY);
        object.videoTransform = CGAffineTransformScale(object.videoTransform, object.mySX, object.mySY);
        
        object.isKbEnabled = selectedObj.isKbEnabled;
        object.nKbIn = selectedObj.nKbIn;
        object.kbFocusPoint = selectedObj.kbFocusPoint;
        object.fKbScale = selectedObj.fKbScale;
        object.kbFocusImageView.center = object.kbFocusPoint;

        [self.mediaObjectArray removeObjectAtIndex:gnSelectedObjectIndex];
        [selectedObj removeFromSuperview];
        selectedObj = nil;
        
        /* insert a new object */
        [self.mediaObjectArray insertObject:object atIndex:gnSelectedObjectIndex];
        [object setIndex:gnSelectedObjectIndex];
        [self.workspaceView insertSubview:object atIndex:gnSelectedObjectIndex];
        [object object_actived];

        @autoreleasepool
        {
            [self.timelineView addNewTimeLine:object];
            [self.timelineView replaceSlider:gnSelectedObjectIndex];
            [self.timelineView resetTimeline:object.objectIndex obj:object];
        }

        isReplace = NO;
    }
    else
    {
        [self.mediaObjectArray addObject:object];
        [object setIndex:(int)(self.mediaObjectArray.count - 1)];
        [self.workspaceView addSubview:object];
        [object object_actived];
        
        @autoreleasepool
        {
            [self.timelineView addNewTimeLine:object];
        }
    }
    
    if(self.mediaObjectArray.count > 0)
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, self.mediaObjectArray.count * grSliderHeight)];
    else
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, grSliderHeight)];
    
    if ((self.mediaObjectArray.count > gnVisibleMaxCount) && (!self.timelineView.hidden))
        self.verticalBgView.hidden = NO;
    
    [self bringGridLayerToFront];
    
    [self checkEditArrowButtons];
}

- (void) generationGIFImageView:(NSString*) gifImageName
{
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSString *fileName = [folderPath stringByAppendingPathComponent:gifImageName];
    
    UIImage* gifImage = [UIImage imageWithContentsOfFile:fileName];
    
    CGSize imageSize = CGSizeMake(gifImage.size.width, gifImage.size.height);
    CGSize workspaceSize = CGSizeMake(self.workspaceView.bounds.size.width, self.workspaceView.bounds.size.height);
    
    float rWidth, rHeight;
    
    float rScaleX = imageSize.width / workspaceSize.width;
    float rScaleY = imageSize.height / workspaceSize.height;
    
    if (rScaleX >= rScaleY)
    {
        rWidth = workspaceSize.width;
        rHeight = imageSize.height * workspaceSize.width / imageSize.width;
    }
    else
    {
        rHeight = workspaceSize.height;
        rWidth = imageSize.width * workspaceSize.height / imageSize.height;
    }
    
    if (gnDefaultOutlineType > 1)
    {
        rWidth = rWidth - grDefaultOutlineWidth * 2.0f;
        rHeight = rHeight - grDefaultOutlineWidth * 2.0f;
    }
    
    gifImage = [gifImage rescaleGIFImageToSize:CGSizeMake(rWidth, rHeight)];
    
    if (self.mediaObjectArray == nil)
        self.mediaObjectArray = [[NSMutableArray alloc] init];

    MediaObjectView* object = [[MediaObjectView alloc] initWithGIF:gifImage size:workspaceSize];
    object.delegate = self;
    object.imageName = gifImageName;
    
    if (isReplace)
    {
        /* remove an old object */
        MediaObjectView* selectedObj = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        selectedObj.startActionType = [self.timelineView getStartActionType:gnSelectedObjectIndex];
        selectedObj.mfStartAnimationDuration = [self.timelineView getStartActionTime:gnSelectedObjectIndex];
        selectedObj.endActionType = [self.timelineView getEndActionType:gnSelectedObjectIndex];
        selectedObj.mfEndAnimationDuration = [self.timelineView getEndActionTime:gnSelectedObjectIndex];
        
        object.startActionType = selectedObj.startActionType;
        object.mfStartAnimationDuration = selectedObj.mfStartAnimationDuration;
        object.endActionType = selectedObj.endActionType;
        object.mfEndAnimationDuration = selectedObj.mfEndAnimationDuration;
        object.objectBorderStyle = selectedObj.objectBorderStyle;
        object.objectBorderWidth = selectedObj.objectBorderWidth;
        object.objectBorderColor = selectedObj.objectBorderColor;
        object.objectShadowStyle = selectedObj.objectShadowStyle;
        object.objectShadowBlur = selectedObj.objectShadowBlur;
        object.objectShadowOffset = selectedObj.objectShadowOffset;
        object.objectShadowColor = selectedObj.objectShadowColor;
        object.objectChromaColor = selectedObj.objectChromaColor;
        object.objectChromaTolerance = selectedObj.objectChromaTolerance;
        object.objectChromaNoise = selectedObj.objectChromaNoise;
        object.objectChromaEdges = selectedObj.objectChromaEdges;
        object.objectChromaOpacity = selectedObj.objectChromaOpacity;
        object.objectCornerRadius = selectedObj.objectCornerRadius;
        object.imageView.alpha = selectedObj.imageView.alpha;
        object.borderLineLayer.opacity = selectedObj.borderLineLayer.opacity;
        
        [object applyBorder];
        [object applyShadow];
        
        object.isReflection = selectedObj.isReflection;
        object.reflectionScale = selectedObj.reflectionScale;
        object.reflectionAlpha = selectedObj.reflectionAlpha;
        object.reflectionGap = selectedObj.reflectionGap;
        object.reflectionDelta = selectedObj.reflectionDelta;
        
        [object update];
        
        object.mySX *= selectedObj.mySX;
        object.mySY *= selectedObj.mySY;
        
        object.transform = CGAffineTransformScale(object.transform, object.mySX, object.mySY);
        object.videoTransform = CGAffineTransformScale(object.videoTransform, object.mySX, object.mySY);
        
        [self.mediaObjectArray removeObjectAtIndex:gnSelectedObjectIndex];
        [selectedObj removeFromSuperview];
        selectedObj = nil;
        
        /* insert a new object */
        [self.mediaObjectArray insertObject:object atIndex:gnSelectedObjectIndex];
        [object setIndex:gnSelectedObjectIndex];
        [self.workspaceView insertSubview:object atIndex:gnSelectedObjectIndex];
        [object object_actived];
        
        @autoreleasepool
        {
            [self.timelineView addNewTimeLine:object];
            [self.timelineView replaceSlider:gnSelectedObjectIndex];
            [self.timelineView resetTimeline:object.objectIndex obj:object];
        }
        
        isReplace = NO;
    }
    else
    {
        [self.mediaObjectArray addObject:object];
        [object setIndex:(int)(self.mediaObjectArray.count - 1)];
        [self.workspaceView addSubview:object];
        [object object_actived];
        
        @autoreleasepool
        {
            [self.timelineView addNewTimeLine:object];
        }
    }
    
    if (self.mediaObjectArray.count > 0)
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, self.mediaObjectArray.count * grSliderHeight)];
    else
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, grSliderHeight)];
    
    if ((self.mediaObjectArray.count > gnVisibleMaxCount) && (!self.timelineView.hidden))
        self.verticalBgView.hidden = NO;
    
    [self bringGridLayerToFront];
    
    [self checkEditArrowButtons];
}

- (void) generationVideoView:(NSURL*) mediaUrl flag:(BOOL)isFromCamera
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    //trim
    if (self.mediaTrimView != nil)
    {
        [self.mediaTrimView removeFromSuperview];
        self.mediaTrimView = nil;
    }

    /* 2015/09/29 */
    /* 2022/11/15 Updated*/
    CGFloat width = gnOrientation == ORIENTATION_LANDSCAPE ? MAX(self.view.bounds.size.width, self.view.bounds.size.height) : MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    CGFloat height = gnOrientation == ORIENTATION_LANDSCAPE ? MIN(self.view.bounds.size.width, self.view.bounds.size.height) : MAX(self.view.bounds.size.width, self.view.bounds.size.height);
    CGRect bounds = CGRectMake(0, 0, width, height);
    self.mediaTrimView = [[MediaTrimView alloc] initWithFrame:bounds url:mediaUrl type:MEDIA_VIDEO flag:isFromCamera superView:self.view];
    self.mediaTrimView.delegate = self;
    [self.view addSubview:self.mediaTrimView];
    self.mediaTrimView.frame = CGRectMake(0.0f, self.mediaTrimView.frame.size.height, self.mediaTrimView.frame.size.width, self.mediaTrimView.frame.size.height);
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.mediaTrimView.frame = CGRectMake(0.0f, 0.0f, self.mediaTrimView.frame.size.width, self.mediaTrimView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        [[SHKActivityIndicator currentIndicator] performSelector:@selector(hide) withObject:nil afterDelay:0.5f];
        
    }];
}

-(void) generateNewTextObject
{
    if (self.mediaObjectArray == nil)
        self.mediaObjectArray = [[NSMutableArray alloc] init];
    
    MediaObjectView* object = [[MediaObjectView alloc] initWithText:NSLocalizedString(@"Press long to edit text ", nil) size:self.workspaceView.bounds.size];
    object.delegate = self;
    [self.mediaObjectArray addObject:object];
    [object setIndex:(int)(self.mediaObjectArray.count - 1)];
    [self.workspaceView addSubview:object];
    [object object_actived];
    
    [self.timelineView addNewTimeLine:object];
    
    if(self.mediaObjectArray.count > 0)
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, self.mediaObjectArray.count*grSliderHeight)];
    else
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, grSliderHeight)];
    
    if ((self.mediaObjectArray.count > gnVisibleMaxCount) && (!self.timelineView.hidden))
        self.verticalBgView.hidden = NO;
    
    [self bringGridLayerToFront];
    
    [self updateObjectEdit];
    
    [self checkEditArrowButtons];
}

-(void) duplicateTextObject:(MediaObjectView*) selectedObject
{
    if (self.mediaObjectArray == nil)
        self.mediaObjectArray = [[NSMutableArray alloc] init];
    
    MediaObjectView* object = [[MediaObjectView alloc] initWithText:selectedObject.textView.text size:self.workspaceView.bounds.size];
    object.textView.frame = selectedObject.textView.frame;
    object.delegate = self;
    [self.mediaObjectArray addObject:object];
    [object setIndex:(int)(self.mediaObjectArray.count - 1)];
    [self.workspaceView addSubview:object];
    [object object_actived];
    
    [self.timelineView addNewTimeLine:object];
    
    [object.textView resignFirstResponder];

    if(self.mediaObjectArray.count > 0)
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, self.mediaObjectArray.count*grSliderHeight)];
    else
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, grSliderHeight)];
    
    if ((self.mediaObjectArray.count > gnVisibleMaxCount) && (!self.timelineView.hidden))
        self.verticalBgView.hidden = NO;
    
    [self bringGridLayerToFront];
    
    [self updateObjectEdit];
    
    [self checkEditArrowButtons];
}


#pragma mark -
#pragma mark - Media Trim Delegate

-(void) didCancelTrimUI
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.mediaTrimView.frame = CGRectMake(0.0f, self.mediaTrimView.frame.size.height, self.mediaTrimView.frame.size.width, self.mediaTrimView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        if (self.mediaTrimView != nil)
        {
            [self.mediaTrimView.mediaPlayerLayer.player pause];
            
            if (self.mediaTrimView.mediaPlayerLayer.player != nil)
                self.mediaTrimView.mediaPlayerLayer.player = nil;
            
            if (self.mediaTrimView.mediaPlayerLayer != nil)
            {
                [self.mediaTrimView.mediaPlayerLayer removeFromSuperlayer];
                self.mediaTrimView.mediaPlayerLayer = nil;
            }
            
            [self.mediaTrimView removeFromSuperview];
            self.mediaTrimView = nil;
        }
    }];
}

-(void) didCompletedTrim:(NSURL*) mediaUrl type:(int)mediaType {
    [self didCompletedTrim:mediaUrl type:mediaType motions:nil startPositions:nil endPositions:nil];
}

-(void) didCompletedTrim:(NSURL*) mediaUrl type:(int)mediaType motions:(NSArray *)motions startPositions:(NSArray *)startPositions endPositions:(NSArray *)endPositions {
    [UIView animateWithDuration:0.3f animations:^{
        
        self.mediaTrimView.frame = CGRectMake(0.0f, self.mediaTrimView.frame.size.height, self.mediaTrimView.frame.size.width, self.mediaTrimView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        if (self.mediaTrimView != nil)
        {
            [self.mediaTrimView.mediaPlayerLayer.player pause];
            
            if (self.mediaTrimView.mediaPlayerLayer.player != nil)
                self.mediaTrimView.mediaPlayerLayer.player = nil;
            
            if (self.mediaTrimView.mediaPlayerLayer != nil)
            {
                [self.mediaTrimView.mediaPlayerLayer removeFromSuperlayer];
                self.mediaTrimView.mediaPlayerLayer = nil;
            }
            
            [self.mediaTrimView removeFromSuperview];
            self.mediaTrimView = nil;
        }
    }];
    
    if (mediaType == MEDIA_VIDEO)
    {
        CGSize workspaceSize = CGSizeMake(self.workspaceView.bounds.size.width, self.workspaceView.bounds.size.height);
        
        if (self.mediaObjectArray == nil)
            self.mediaObjectArray = [[NSMutableArray alloc] init];
        
        MediaObjectView* object = [[MediaObjectView alloc] initWithVideoUrl:mediaUrl size:workspaceSize startPositions:startPositions endPositions:endPositions motionArray:motions];
        object.delegate = self;
        
        if (isReplace)
        {
            /* remove an old object */
            MediaObjectView* selectedObj = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
            selectedObj.startActionType = [self.timelineView getStartActionType:gnSelectedObjectIndex];
            selectedObj.mfStartAnimationDuration = [self.timelineView getStartActionTime:gnSelectedObjectIndex];
            selectedObj.endActionType = [self.timelineView getEndActionType:gnSelectedObjectIndex];
            selectedObj.mfEndAnimationDuration = [self.timelineView getEndActionTime:gnSelectedObjectIndex];
            
            object.startActionType = selectedObj.startActionType;
            object.mfStartAnimationDuration = selectedObj.mfStartAnimationDuration;
            object.endActionType = selectedObj.endActionType;
            object.mfEndAnimationDuration = selectedObj.mfEndAnimationDuration;
            object.objectBorderStyle = selectedObj.objectBorderStyle;
            object.objectBorderWidth = selectedObj.objectBorderWidth;
            object.objectBorderColor = selectedObj.objectBorderColor;
            object.objectShadowStyle = selectedObj.objectShadowStyle;
            object.objectShadowBlur = selectedObj.objectShadowBlur;
            object.objectShadowOffset = selectedObj.objectShadowOffset;
            object.objectShadowColor = selectedObj.objectShadowColor;
            object.objectChromaColor = selectedObj.objectChromaColor;
            object.objectChromaTolerance = selectedObj.objectChromaTolerance;
            object.objectChromaNoise = selectedObj.objectChromaNoise;
            object.objectChromaEdges = selectedObj.objectChromaEdges;
            object.objectChromaOpacity = selectedObj.objectChromaOpacity;
            object.objectCornerRadius = selectedObj.objectCornerRadius;
            object.imageView.alpha = selectedObj.imageView.alpha;
            object.borderLineLayer.opacity = selectedObj.borderLineLayer.opacity;
            [object setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:selectedObj.imageView.alpha]];
            
            [object applyBorder];
            [object applyShadow];
            
            object.isReflection = selectedObj.isReflection;
            object.reflectionScale = selectedObj.reflectionScale;
            object.reflectionAlpha = selectedObj.reflectionAlpha;
            object.reflectionGap = selectedObj.reflectionGap;
            object.reflectionDelta = selectedObj.reflectionDelta;
            
            [object update];
            
            object.mySX *= selectedObj.mySX;
            object.mySY *= selectedObj.mySY;
            
            object.transform = CGAffineTransformScale(object.transform, object.mySX, object.mySY);
            object.videoTransform = CGAffineTransformScale(object.videoTransform, object.mySX, object.mySY);
            
            [self.mediaObjectArray removeObjectAtIndex:gnSelectedObjectIndex];
            [selectedObj removeFromSuperview];
            selectedObj = nil;
            
            /* insert a new object */
            [self.mediaObjectArray insertObject:object atIndex:gnSelectedObjectIndex];
            [object setIndex:gnSelectedObjectIndex];
            [self.workspaceView insertSubview:object atIndex:gnSelectedObjectIndex];
            [object object_actived];
            
            @autoreleasepool
            {
                [self.timelineView addNewTimeLine:object];
                [self.timelineView replaceSlider:gnSelectedObjectIndex];
                [self.timelineView resetTimeline:object.objectIndex obj:object];
            }
            
            isReplace = NO;
        }
        else
        {
            [self.mediaObjectArray addObject:object];
            [object setIndex:(int)(self.mediaObjectArray.count - 1)];
            [self.workspaceView addSubview:object];
            [object object_actived];
            
            @autoreleasepool
            {
                [self.timelineView addNewTimeLine:object];
            }
        }
        
        
        if (self.mediaObjectArray.count > 0)
            [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, self.mediaObjectArray.count*grSliderHeight)];
        else
            [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, grSliderHeight)];
        
        if ((self.mediaObjectArray.count > gnVisibleMaxCount) && (!self.timelineView.hidden))
            self.verticalBgView.hidden = NO;
        
        [self prepareVideoPlayer:object];
        
        AVAsset *videoAsset = object.mixComposition;
        [self.totalSeekTimeLabel setText:[self timeToString:CMTimeGetSeconds(videoAsset.duration)]];
        [self.currentSeekTimeLabel setText:[self timeToString:CMTimeGetSeconds(object.currentPosition)]];
    }
    else if (mediaType == MEDIA_MUSIC)
    {
        if (self.mediaObjectArray == nil)
            self.mediaObjectArray = [[NSMutableArray alloc] init];
        
        CGSize workspaceSize = CGSizeMake(self.workspaceView.bounds.size.width, self.workspaceView.bounds.size.height);
        
        MediaObjectView* object = [[MediaObjectView alloc] initWithMusicUrl:mediaUrl size:workspaceSize];
        object.delegate = self;
        [self.mediaObjectArray addObject:object];
        [object setIndex:(int)(self.mediaObjectArray.count - 1)];
        [self.workspaceView addSubview:object];
        [object object_actived];
        
        [self.timelineView addNewTimeLine:object];
        
        if (self.mediaObjectArray.count > 0)
            [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, self.mediaObjectArray.count * grSliderHeight)];
        else
            [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, grSliderHeight)];
        
        if ((self.mediaObjectArray.count > gnVisibleMaxCount) && (!self.timelineView.hidden))
            self.verticalBgView.hidden = NO;
        
        [self prepareVideoPlayer:object];
        
        AVAsset *videoAsset = object.mixComposition;
        [self.totalSeekTimeLabel setText:[self timeToString:CMTimeGetSeconds(videoAsset.duration)]];
        [self.currentSeekTimeLabel setText:[self timeToString:CMTimeGetSeconds(object.currentPosition)]];
    }
    
    [self bringGridLayerToFront];
    
    [self updateObjectEdit];
    
    [self checkEditArrowButtons];
}


#pragma mark -
#pragma mark - ************** MediaObjectViewDelegate **************

- (void) mediaObjectSelected:(int) objectIndex
{
    if (gnSelectedObjectIndex == objectIndex)
    {
        MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:objectIndex];
        [selectedObject maskArrowsHidden];
        
        [self.timelineView selectTimelineObject:objectIndex];
    }
    else
    {
        MediaObjectView* prevSelectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        prevSelectedObject.isSelected = NO;
        prevSelectedObject.selectedLineLayer.hidden = YES;
        [prevSelectedObject maskArrowsHidden];
        
        if ((prevSelectedObject.mediaType == MEDIA_VIDEO) || (prevSelectedObject.mediaType == MEDIA_MUSIC))
        {
            [self.videoPlayer pause];

            CGFloat currentPosition = CMTimeGetSeconds(self.videoPlayer.currentTime);
            prevSelectedObject.currentPosition = CMTimeMakeWithSeconds(currentPosition, 1);
            
            if (prevSelectedObject.mediaType == MEDIA_VIDEO)
            {
                CGFloat currentTime = currentPosition;
                [prevSelectedObject updateVideoThumbnail:currentTime];
            }
        }

        MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:objectIndex];
        [self.timelineView selectTimelineObject:objectIndex];
        selectedObject.isSelected = YES;
        selectedObject.selectedLineLayer.hidden = NO;

        int prevSelectedIndex = gnSelectedObjectIndex;
        gnSelectedObjectIndex = objectIndex;
        
        [self prepareVideoPlayer:selectedObject];
        
        if ((self.mediaObjectArray.count == self.timelineView.sliderArray.count) && (self.editThumbnailArray.count == self.timelineView.sliderArray.count))
        {
            for (int i = 0; i < self.mediaObjectArray.count; i++)
            {
                MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
                UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:i];
                
                if (i == gnSelectedObjectIndex)
                {
                    if (object.mediaType == MEDIA_PHOTO || object.mediaType == MEDIA_GIF || object.mediaType == MEDIA_TEXT) {
                        [self.playingButton setEnabled:NO];
                        [self.seekSlider setEnabled:NO];
                        [self.currentSeekTimeLabel setText:@"00:00.000"];
                        [self.totalSeekTimeLabel setText:@"00:00.000"];
                    } else if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_MUSIC)) {
                        [self.playingButton setEnabled:YES];
                        [self.seekSlider setEnabled:YES];
                    }
                    
                    thumbImageView.layer.borderColor = [UIColor greenColor].CGColor;
                    thumbImageView.layer.borderWidth = 3.0f;
                }
                else if (i == prevSelectedIndex)
                {
                    thumbImageView.layer.borderColor = [UIColor orangeColor].CGColor;
                    thumbImageView.layer.borderWidth = 1.0f;
                }
            }
        }
    }
}

-(void) textChanged:(id) object
{
    MediaObjectView* selectedObject = (MediaObjectView*) object;
    [self.timelineView changedTextThumbnail:selectedObject];
    
    [self refreshTextObjectEditThumbnailView:selectedObject.objectIndex];
}

-(void) changeBoldButton:(BOOL) isBold
{
    if (isBold)
    {
        [self.textSettingView.boldButton setImage:[UIImage imageNamed:@"Bold_Hightlight"] forState:UIControlStateNormal];
        self.textSettingView.isBold = YES;
    }
    else
    {
        [self.textSettingView.boldButton setImage:[UIImage imageNamed:@"Bold"] forState:UIControlStateNormal];
        self.textSettingView.isBold = NO;
    }
}

-(void) changeItalicButton:(BOOL) isItalic
{
    if (isItalic)
    {
        [self.textSettingView.italicButton setImage:[UIImage imageNamed:@"Italic_Highlight"] forState:UIControlStateNormal];
        self.textSettingView.isItalic = YES;
    }
    else
    {
        [self.textSettingView.italicButton setImage:[UIImage imageNamed:@"Italic"] forState:UIControlStateNormal];
        self.textSettingView.isItalic = NO;
    }
}

- (void)mediaObjectMoved:(MediaObjectView *)objectView {
    self.horizontalLineImageView.hidden = YES;
    self.verticalLineImageView.hidden = YES;
    if (objectView.frame.origin.x == 0 || objectView.center.x == self.workspaceView.frame.size.width / 2.0 || objectView.frame.origin.x + objectView.frame.size.width == self.workspaceView.frame.size.width) {
        self.horizontalLineImageView.hidden = NO;
        if (objectView.frame.origin.x == 0) {
            self.horizontalLineImageView.center = CGPointMake(self.workspaceView.frame.origin.x, self.horizontalLineImageView.center.y);
        }
        if (objectView.frame.origin.x + objectView.frame.size.width == self.workspaceView.frame.size.width) {
            self.horizontalLineImageView.center = CGPointMake(self.workspaceView.frame.origin.x + self.workspaceView.frame.size.width, self.horizontalLineImageView.center.y);
        }
        if (objectView.center.x == self.workspaceView.frame.size.width / 2.0) {
            self.horizontalLineImageView.center = CGPointMake(self.workspaceView.center.x, self.horizontalLineImageView.center.y);
        }
    }
    if (objectView.frame.origin.y == 0 || objectView.center.y == self.workspaceView.frame.size.height / 2.0 || objectView.frame.origin.y + objectView.frame.size.height == self.workspaceView.frame.size.height) {
        self.verticalLineImageView.hidden = NO;
        if (objectView.frame.origin.y == 0) {
            self.verticalLineImageView.center = CGPointMake(self.verticalLineImageView.center.x, self.workspaceView.frame.origin.y);
        }
        if (objectView.frame.origin.y + objectView.frame.size.height == self.workspaceView.frame.size.height) {
            self.verticalLineImageView.center = CGPointMake(self.verticalLineImageView.center.x, self.workspaceView.frame.origin.y + self.workspaceView.frame.size.height);
        }
        if (objectView.center.y == self.workspaceView.frame.size.height / 2.0) {
            self.verticalLineImageView.center = CGPointMake(self.verticalLineImageView.center.x, self.workspaceView.center.y);
        }
    }
}

- (void)mediaObjectMoveEnded:(MediaObjectView *)objectView {
    self.horizontalLineImageView.hidden = YES;
    self.verticalLineImageView.hidden = YES;
}


#pragma mark -
#pragma mark - Object Edit Menu Show

-(void) objectSettingViewShow:(int) index
{
    gnSelectedObjectIndex = index;
    
    if (!self.kenBurnsSettingsView.hidden)
        return;
    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    NSArray *menuItems = nil;
    
    if (selectedObject.mediaType == MEDIA_PHOTO)
    {
        if (selectedObject.isShape)
        {
            menuItems =
            @[
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Remove", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onRemoveObject)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Filters", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onShowFiltersUI)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Replace", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onReplace)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"To Back", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onToBack)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"To Front", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onToFront)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip H", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onFlipH)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip V", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onFlipV)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip Both", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onFlipBoth)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Opacity", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didOpacity)],

              [YJLActionMenuItem menuItem:NSLocalizedString(@"Shape Color", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didColorOverlay)],

              [YJLActionMenuItem menuItem:NSLocalizedString(@"Outline", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didOutline)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Shadow", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didShadow)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Reflection", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didReflection)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Ken Burns", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didChangeKenburn)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Duplicate", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didDuplicated)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Mask", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didMaskShow)],
              
// Added by Yinjing 20170221
//              [YJLActionMenuItem menuItem:@"Perspective"
//                                    image:nil
//                                   target:self
//                                   action:@selector(didPerspective)],
              ];
            
        }
        else
        {
            menuItems =
            @[
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Remove", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onRemoveObject)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Filters", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onShowFiltersUI)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"ChromaColor", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didShowChromakeyColorSettings)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Replace", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onReplace)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"To Back", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onToBack)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"To Front", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onToFront)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip H", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onFlipH)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip V", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onFlipV)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip Both", nil)
                                    image:nil
                                   target:self
                                   action:@selector(onFlipBoth)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Opacity", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didOpacity)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Outline", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didOutline)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Shadow", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didShadow)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Reflection", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didReflection)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Ken Burns", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didChangeKenburn)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Duplicate", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didDuplicated)],
              
              [YJLActionMenuItem menuItem:NSLocalizedString(@"Mask", nil)
                                    image:nil
                                   target:self
                                   action:@selector(didMaskShow)],
// Added by Yinjing 20170221
//              [YJLActionMenuItem menuItem:@"Perspective"
//                                    image:nil
//                                   target:self
//                                   action:@selector(didPerspective)],
              ];
        }
    }
    else if (selectedObject.mediaType == MEDIA_GIF)
    {
        menuItems =
        @[
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Remove", nil)
                                image:nil
                               target:self
                               action:@selector(onRemoveObject)],

          [YJLActionMenuItem menuItem:NSLocalizedString(@"Replace", nil)
                                image:nil
                               target:self
                               action:@selector(onReplace)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"To Back", nil)
                                image:nil
                               target:self
                               action:@selector(onToBack)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"To Front", nil)
                                image:nil
                               target:self
                               action:@selector(onToFront)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip H", nil)
                                image:nil
                               target:self
                               action:@selector(onFlipH)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip V", nil)
                                image:nil
                               target:self
                               action:@selector(onFlipV)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip Both", nil)
                                image:nil
                               target:self
                               action:@selector(onFlipBoth)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Opacity", nil)
                                image:nil
                               target:self
                               action:@selector(didOpacity)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Outline", nil)
                                image:nil
                               target:self
                               action:@selector(didOutline)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Shadow", nil)
                                image:nil
                               target:self
                               action:@selector(didShadow)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Duplicate", nil)
                                image:nil
                               target:self
                               action:@selector(didDuplicated)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Mask", nil)
                                image:nil
                               target:self
                               action:@selector(didMaskShow)],
// Added by Yinjing 20170221
//          [YJLActionMenuItem menuItem:@"Perspective"
//                                image:nil
//                               target:self
//                               action:@selector(didPerspective)],
          ];
    }
    else if (selectedObject.mediaType == MEDIA_VIDEO)
    {
        menuItems =
        @[
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Remove", nil)
                                image:nil
                               target:self
                               action:@selector(onRemoveObject)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Filters", nil)
                                image:nil
                               target:self
                               action:@selector(onShowVideoFiltersUI)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"ChromaColor", nil)
                                image:nil
                               target:self
                               action:@selector(didShowChromakeyColorSettings)],

          [YJLActionMenuItem menuItem:NSLocalizedString(@"Replace", nil)
                                image:nil
                               target:self
                               action:@selector(onReplace)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"To Back", nil)
                                image:nil
                               target:self
                               action:@selector(onToBack)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"To Front", nil)
                                image:nil
                               target:self
                               action:@selector(onToFront)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip H", nil)
                                image:nil
                               target:self
                               action:@selector(onFlipH)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip V", nil)
                                image:nil
                               target:self
                               action:@selector(onFlipV)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip Both", nil)
                                image:nil
                               target:self
                               action:@selector(onFlipBoth)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Volume", nil)
                                image:nil
                               target:self
                               action:@selector(didVolume)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Opacity", nil)
                                image:nil
                               target:self
                               action:@selector(didOpacity)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Outline", nil)
                                image:nil
                               target:self
                               action:@selector(didOutline)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Shadow", nil)
                                image:nil
                               target:self
                               action:@selector(didShadow)],
          
//          [YJLActionMenuItem menuItem:@"Reflection"
//                                image:nil
//                               target:self
//                               action:@selector(didReflection)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Duplicate", nil)
                                image:nil
                               target:self
                               action:@selector(didDuplicated)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Mask", nil)
                                image:nil
                               target:self
                               action:@selector(didMaskShow)],
// Added by Yinjing 20170221
//          [YJLActionMenuItem menuItem:@"Perspective"
//                                image:nil
//                               target:self
//                               action:@selector(didPerspective)],
          ];
    }
    else if (selectedObject.mediaType == MEDIA_MUSIC)
    {
        menuItems =
        @[
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Remove", nil)
                                image:nil
                               target:self
                               action:@selector(onRemoveObject)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"To Back", nil)
                                image:nil
                               target:self
                               action:@selector(onToBack)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"To Front", nil)
                                image:nil
                               target:self
                               action:@selector(onToFront)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Edit Volume", nil)
                                image:nil
                               target:self
                               action:@selector(didVolume)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Duplicate", nil)
                                image:nil
                               target:self
                               action:@selector(didDuplicated)],
          ];
    }
    else if (selectedObject.mediaType == MEDIA_TEXT)
    {
        menuItems =
        @[
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Remove", nil)
                                image:nil
                               target:self
                               action:@selector(onRemoveObject)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Filters", nil)
                                image:nil
                               target:self
                               action:@selector(onShowFiltersUI)],

          [YJLActionMenuItem menuItem:NSLocalizedString(@"To Back", nil)
                                image:nil
                               target:self
                               action:@selector(onToBack)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"To Front", nil)
                                image:nil
                               target:self
                               action:@selector(onToFront)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip H", nil)
                                image:nil
                               target:self
                               action:@selector(onFlipH)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip V", nil)
                                image:nil
                               target:self
                               action:@selector(onFlipV)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Flip Both", nil)
                                image:nil
                               target:self
                               action:@selector(onFlipBoth)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Text", nil)
                                image:nil
                               target:self
                               action:@selector(didText)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Opacity", nil)
                                image:nil
                               target:self
                               action:@selector(didOpacity)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Outline", nil)
                                image:nil
                               target:self
                               action:@selector(didOutline)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Shadow", nil)
                                image:nil
                               target:self
                               action:@selector(didShadow)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Reflection", nil)
                                image:nil
                               target:self
                               action:@selector(didReflection)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Ken Burns", nil)
                                image:nil
                               target:self
                               action:@selector(didChangeKenburn)],

          [YJLActionMenuItem menuItem:NSLocalizedString(@"Duplicate", nil)
                                image:nil
                               target:self
                               action:@selector(didDuplicated)],
          
          [YJLActionMenuItem menuItem:NSLocalizedString(@"Mask", nil)
                                image:nil
                               target:self
                               action:@selector(didMaskShow)],
// Added by Yinjing 20170221
//          [YJLActionMenuItem menuItem:@"Perspective"
//                                image:nil
//                               target:self
//                               action:@selector(didPerspective)],
          ];
    }
    
    CGRect frame = [selectedObject convertRect:selectedObject.bounds toView:self.view];
    [YJLActionMenu showMenuInView:self.navigationController.view
                         fromRect:frame
                        menuItems:menuItems isWhiteBG:NO];
}


#pragma mark -
#pragma mark - *************** Video Music PlayBack Functions *******************

- (void)MPMusicPlayerControllerVolumeDidChange:(NSNotification *)notification
{
    
}


#pragma mark -
#pragma mark - AVAudioSession Delegate

-(void) handleInterruption:(NSNotification*)notification
{
    
}


/*
 name - videoPlayBackDidFinish
 param - (NSNotification*)notification
 return - non
 description - when AVPlayer finished a playing, this function will called. app can get end playing position of video from this function.
 created - 10/27/2013
 author - Yinjing Li.
 */

- (void) videoPlayBackDidFinish:(NSNotification*)notification
{
    [self.videoPlayer pause];
    
    [playbackTimer invalidate];
    playbackTimer = nil;

    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.videoPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.seekSlider setValue:0.0];
}


#pragma mark -
#pragma mark - playback update timer

- (void)playbackTimeUpdate:(NSTimer*)timer
{
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    CGFloat currentTime = CMTimeGetSeconds(self.videoPlayer.currentTime);
    
    for (int i = 0; i < selectedObject.motionArray.count; i++)
    {
        CGFloat startPosition = [[selectedObject.startPositionArray objectAtIndex:i] floatValue];
        CGFloat endPosition = [[selectedObject.endPositionArray objectAtIndex:i] floatValue];
        
        if ((currentTime > startPosition) && (currentTime < endPosition))
        {
            if (i != mnPlaybackCount)
            {
                mnPlaybackCount = i;
                CGFloat motion = [[selectedObject.motionArray objectAtIndex:i] floatValue];
                self.videoPlayer.rate = motion;
            }
            
            break;
        }
    }
}

- (IBAction)onPlaying:(id)sender
{
    if ([sender tag] == 0)  //play
    {
        MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        
        if (!self.playerItem)
        {
            self.playerItem = [AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:selectedObject.mediaUrl]];
            [self.videoPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
        }

        mnPlaybackCount = -1;
        //playbackTimer = [NSTimer scheduledTimerWithTimeInterval:.02f target:self selector:@selector(playbackTimeUpdate:) userInfo:nil repeats:YES];

        self.videoPlayerLayer.hidden = NO;
        [self.videoPlayer play];
        
        self.videoPlayer.volume = selectedObject.mediaVolume;
        
        [self.playingButton setTag:1];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            [self.playingButton setImage:[UIImage imageNamed:@"NewPause_iPhone"] forState:UIControlStateNormal];
        else
            [self.playingButton setImage:[UIImage imageNamed:@"NewPause_iPad"] forState:UIControlStateNormal];
    }
    else    //pause
    {
        //[playbackTimer invalidate];
        //playbackTimer = nil;

        [self.videoPlayer pause];

        [self.playingButton setTag:0];
        [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    }
}


#pragma mark -
#pragma mark - get video translate of video object

- (CGAffineTransform) getVideoTranslate:(MediaObjectView*) object
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGSize workspaceSize = CGSizeZero;
    CGPoint videoCenterPnt = CGPointZero;
    
    workspaceSize = self.workspaceView.bounds.size;
    
    CGRect intersectRect = [object getIntersectionRect];
    CGRect intersectRect_ = [object convertRect:intersectRect toView:self.workspaceView];
    videoCenterPnt = CGPointMake(intersectRect_.origin.x + intersectRect_.size.width / 2.0, intersectRect_.origin.y + intersectRect_.size.height / 2.0);
    
    CGPoint workspaceCenterPnt = CGPointApplyAffineTransform(CGPointMake(self.workspaceView.frame.size.width/2, self.workspaceView.frame.size.height/2), CGAffineTransformInvert(self.workspaceView.transform));
    
    float tx = (videoCenterPnt.x - workspaceCenterPnt.x) * (2.0f / workspaceSize.width );
    float ty = 0.0f;
    
    if (object.transform.a == 0)
        ty = 0.0f;
    else
        ty = (videoCenterPnt.y - workspaceCenterPnt.y) * (2.0f * intersectRect.size.height * fabs(object.transform.d) / (intersectRect.size.width * fabs(object.transform.a) * workspaceSize.height));
    
    transform = [object getVideoTransform];
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(tx, ty));
    
    return transform;
}


#pragma mark -
#pragma mark - ****************** Progress Bar Processing ************************

- (void)hudWillDisappear:(ATMHud *)_hud
{
    AVAssetExportSession* session = progressTimer.userInfo;
    [session cancelExport];
    
    [progressTimer invalidate];
    progressTimer = nil;
}

-(void) updateAllVideoExportingTimer:(NSTimer*) timer
{
    AVAssetExportSession* session = (AVAssetExportSession*) timer.userInfo;
    
    CGFloat minPercent = ((CGFloat)(mnCurrentProcessingCount - 1) / (CGFloat)mnTotalProcessingCount);
    CGFloat percent = minPercent + (CGFloat)([session progress] / mnTotalProcessingCount);
    
    if ((percent > [self.hudProgressView getProgress]) && (percent <= 1.0f))
    {
        [self.hudProgressView setProgress:percent];
    }
}

-(void) updateChromakeyVideoExporting:(CGFloat) progress
{
    CGFloat minPercent = ((CGFloat)(mnCurrentProcessingCount - 1) / (CGFloat)mnTotalProcessingCount);
    CGFloat percent = minPercent + (CGFloat)(progress / mnTotalProcessingCount);
    
    if ((percent > [self.hudProgressView getProgress]) && (percent <= 1.0f))
    {
        [self.hudProgressView setProgress:percent];
    }
}

- (void)saveToAlbumProgress
{
    [progressTimer invalidate];
    progressTimer = nil;

    [self.hudProgressView setCaption:NSLocalizedString(@"Video Saving to Photo Album...", nil)];
    [self.hudProgressView setProgress:1.0f];
    [self.hudProgressView show];
}

- (void)startAllNormalProgress:(AVAssetExportSession*) session current:(int) currentCount total:(int) totalCount
{
    mnCurrentProcessingCount = currentCount;
    mnTotalProcessingCount = totalCount;

    if (currentCount == 1)
    {
        [[SHKActivityIndicator currentIndicator] hide];

        progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(updateAllVideoExportingTimer:) userInfo:session repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:progressTimer forMode:NSRunLoopCommonModes];
        
        NSString* message = nil;

        if (isPreview)
        {
            switch (gnOutputQuality)
            {
                case OUTPUT_UHD:
                    message = NSLocalizedString(@"Preview to UHD Video...", nil);
                    break;
                case OUTPUT_HD:
                    message = NSLocalizedString(@"Preview to HD Video...", nil);
                    break;
                case OUTPUT_UNIVERSAL:
                    message = NSLocalizedString(@"Preview to Universal Video...", nil);
                    break;
                case OUTPUT_SDTV:
                    message = NSLocalizedString(@"Preview to SDTV Video...", nil);
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            switch (gnOutputQuality)
            {
                case OUTPUT_UHD:
                    message = NSLocalizedString(@"Creating to UHD Video...", nil);
                    break;
                case OUTPUT_HD:
                    message = NSLocalizedString(@"Creating to HD Video...", nil);
                    break;
                case OUTPUT_UNIVERSAL:
                    message = NSLocalizedString(@"Creating to Universal Video...", nil);
                    break;
                case OUTPUT_SDTV:
                    message = NSLocalizedString(@"Creating to SDTV Video...", nil);
                    break;
                    
                default:
                    break;
            }
        }
        
        [self.hudProgressView setCaption:message];

        CGFloat minPercent = ((CGFloat)(mnCurrentProcessingCount - 1)/(CGFloat)mnTotalProcessingCount);
        [self.hudProgressView setProgress:minPercent + 0.08f];
        [self.hudProgressView show];
        [self.hudProgressView showDismissButton];
    }
    else
    {
        [progressTimer invalidate];
        progressTimer = nil;

        progressTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(updateAllVideoExportingTimer:) userInfo:session repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:progressTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)startAllChromakeyProgress:(int) currentCount total:(int) totalCount
{
    [progressTimer invalidate];
    progressTimer = nil;
    
    mnCurrentProcessingCount = currentCount;
    mnTotalProcessingCount = totalCount;
}

#pragma mark -
#pragma mark - ************** Did Complete Preview Video Generation, Go to play a preview video ********************

- (void)didCompletedPreview
{
    [self performSelectorOnMainThread:@selector(playPreviewOutputVideo) withObject:nil waitUntilDone:NO];
}

- (void)didFailedPreview
{
    [self previewPlayDidFinished];
}

- (void) playPreviewOutputVideo
{
    self.previewView.hidden = NO;
    
    NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-Preview.mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:videoPath];
    [self.previewView adjustFrameView];
    [self.previewView playVideoInPreview:movieURL];
    NSLog(@"%@", self.previewView);
    
    [progressTimer invalidate];
    progressTimer = nil;
    [self.hudProgressView hide];
    
    if (self.videoEditor != nil)
    {
        [self.videoEditor removeAllObjects];
        self.videoEditor = nil;
    }
}

-(void) previewPlayDidFinished
{
    if (self.videoEditor != nil)
    {
        [self.videoEditor removeAllObjects];
        self.videoEditor = nil;
    }

    self.previewView.hidden = YES;
    self.editButtonsView.hidden = NO;
    
    [progressTimer invalidate];
    progressTimer = nil;
    [self.hudProgressView hide];
    
    
    NSString *previewVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer-Preview.mp4"];
    unlink([previewVideoPath UTF8String]);

    NSString *outputVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer.mp4"];
    unlink([outputVideoPath UTF8String]);
}


#pragma mark -
#pragma mark - ********************* Did Complete Output Video Generation, Go to "play a output video" or "continue" ************************

- (void)didCompleteProgressbar
{
    [progressTimer invalidate];
    progressTimer = nil;
    
    [self.hudProgressView hide];
}

- (void)didCompleteOutput:(int)index
{
    if (index == 1)
        [self performSelectorOnMainThread:@selector(playCompleteOutputVideo) withObject:nil waitUntilDone:NO];
    else
        [self performSelectorOnMainThread:@selector(continueCompleteOutputVideo) withObject:nil waitUntilDone:NO];
}

-(void) playCompleteOutputVideo
{
    if (self.videoEditor != nil)
    {
        [self.videoEditor removeAllObjects];
        self.videoEditor = nil;
    }
    
    self.previewView.hidden = NO;
    self.editButtonsView.hidden = NO;

    NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer.mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:videoPath];
    [self.previewView adjustFrameView];
    [self.previewView playVideoInPreview:movieURL];
    
    [progressTimer invalidate];
    progressTimer = nil;
    
    [self.hudProgressView hide];
}

-(void) continueCompleteOutputVideo
{
    if (self.videoEditor != nil)
        self.videoEditor = nil;
    
    [progressTimer invalidate];
    progressTimer = nil;
    
    [self.hudProgressView hide];
    
    NSString *outputVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoDreamer.mp4"];
    unlink([outputVideoPath UTF8String]);
}


- (void)didFailedOutput
{
    if (self.videoEditor != nil)
        self.videoEditor = nil;
    
    self.previewView.hidden = YES;

    [progressTimer invalidate];
    progressTimer = nil;
    
    [self.hudProgressView hide];
}


#pragma mark -
#pragma mark - ****************** TimelineViewDelegate ******************

-(void) timelineSelected:(int) index
{
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        if (i == index)
        {
            object.isSelected = YES;
            object.selectedLineLayer.hidden = NO;
        }
        else
        {
            [object maskArrowsHidden];
            object.selectedLineLayer.hidden = YES;
            object.isSelected = NO;
        }
    }
    
    if (gnSelectedObjectIndex == index)
    {
        MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        [selectedObject maskArrowsHidden];
    }
    else
    {
        MediaObjectView* prevSelectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        prevSelectedObject.isSelected = NO;
        prevSelectedObject.selectedLineLayer.hidden = YES;
        [prevSelectedObject maskArrowsHidden];
        
        if ((prevSelectedObject.mediaType == MEDIA_VIDEO) || (prevSelectedObject.mediaType == MEDIA_MUSIC))
        {
            [self.videoPlayer pause];

            CGFloat currentPosition = CMTimeGetSeconds(self.videoPlayer.currentTime);
            prevSelectedObject.currentPosition = CMTimeMakeWithSeconds(currentPosition, 1);
            
            if (prevSelectedObject.mediaType == MEDIA_VIDEO)
            {
                CGFloat currentTime = currentPosition;
                [prevSelectedObject updateVideoThumbnail:currentTime];
            }
        }
        
        MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:index];
        [self.timelineView selectTimelineObject:index];
        selectedObject.isSelected = YES;
        selectedObject.selectedLineLayer.hidden = NO;
        
        gnSelectedObjectIndex = index;
        
        [self prepareVideoPlayer:selectedObject];
    }
    
    [self updateObjectEdit];
}

-(void) timelineGrouped:(int) index isGrouped:(BOOL)flag
{
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:index];
    object.isGrouped = flag;
}

-(void) timelineUnGroupAll
{
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        object.isGrouped = NO;
    }
}

-(void) onEditSpeed
{
    [self.videoPlayer pause];
    
    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    if (object.mediaType == MEDIA_MUSIC)
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Loading...", nil)) isLock:YES];
    }
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (self.speedSegmentView != nil)
        self.speedSegmentView = nil;
    
    self.speedSegmentView = [[SpeedSegmentView alloc] initWithFrame:self.view.bounds type:object.mediaType url:object.mediaUrl superView:self.view];
    self.speedSegmentView.delegate = self;
    self.speedSegmentView.frame = CGRectMake(0.0f, self.speedSegmentView.frame.size.height, self.speedSegmentView.frame.size.width, self.speedSegmentView.frame.size.height);
    [self.view addSubview:self.speedSegmentView];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.speedSegmentView.frame = CGRectMake(0.0f, 0.0f, self.speedSegmentView.frame.size.width, self.speedSegmentView.frame.size.height);

    } completion:^(BOOL finished) {
        
    }];
}

-(void) onEditJog
{
    [self.videoPlayer pause];
    
    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (self.jogEditView != nil)
        self.jogEditView = nil;
    
    self.jogEditView = [[JogEditView alloc] initWithFrame:self.view.bounds url:object.mediaUrl superView:self.view];
    self.jogEditView.delegate = self;
    self.jogEditView.frame = CGRectMake(0.0f, self.jogEditView.frame.size.height, self.jogEditView.frame.size.width, self.jogEditView.frame.size.height);
    [self.view addSubview:self.jogEditView];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.jogEditView.frame = CGRectMake(0.0f, 0.0f, self.jogEditView.frame.size.width, self.jogEditView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void) onEditTrim
{
    [self.videoPlayer pause];
    
    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    if (object.mediaType == MEDIA_MUSIC)
    {
        [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Loading...", nil)) isLock:YES];
    }

    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (self.jogEditView != nil)
        self.jogEditView = nil;
    
    self.editTrimView = [[EditTrimView alloc] initWithFrame:self.view.bounds type:object.mediaType url:object.mediaUrl superView:self.view];
    self.editTrimView.delegate = self;
    self.editTrimView.frame = CGRectMake(0.0f, self.editTrimView.frame.size.height, self.editTrimView.frame.size.width, self.editTrimView.frame.size.height);
    [self.view addSubview:self.editTrimView];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.editTrimView.frame = CGRectMake(0.0f, 0.0f, self.editTrimView.frame.size.width, self.editTrimView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void) updateTotalTime
{
    [self.totalTimeLabel setText:[self timeToString:self.timelineView.totalTime]];
    
    [self.horizontalBgView setContentSize:CGSizeMake(self.timelineView.contentSize.width, 0.0f)];
    [self.horizontalBgView setTotalTime:self.timelineView.totalTime];
    
    [self.verticalBgView setContentSize:self.timelineView.contentSize];

    [self.timelineView setNeedsDisplay];
}

-(void) hideVerticalView:(BOOL) hide
{
    self.verticalBgView.hidden = hide;
}

-(void) exchangedObjects:(int) fromIdx toIndex:(int) toIdx
{
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:fromIdx];
    [self.mediaObjectArray removeObjectAtIndex:fromIdx];
    [self.mediaObjectArray insertObject:object atIndex:toIdx];
    
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        [object setObjectIndex:i];
    }
    
    object = [self.mediaObjectArray objectAtIndex:toIdx];
    
    [object removeFromSuperview];
    
    [self.workspaceView insertSubview:object atIndex:toIdx];
    
    [self updateObjectEdit];
}

-(void) onEditVolume
{
    [self didVolume];
}

-(void) onRemoveMusic
{
    [self onRemoveObject];
}


#pragma mark -
#pragma mark - ******************* ObjectSettings Changing *****************

-(void) onReplace
{
    isReplace = YES;
    
    [self.videoPlayer pause];
    
    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 200.0f, 115.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 160.0f);
    
    self.avChooseView = [[AVChooseView alloc] initWithFrame:menuFrame];
    self.avChooseView.delegate = self;

    
    self.customModalView = [[CustomModalView alloc] initWithView:self.avChooseView isCenter:YES];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) onFlipH
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;
    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject flip:0];
}

-(void) onFlipV
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;
    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject flip:1];
}

-(void) onFlipBoth
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;
    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject flip:2];
}

-(void) didText
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;
    
    CGRect menuFrame = CGRectZero;
    
    /**********************************************************************
     Text Setting View
     **********************************************************************/
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 228.0f, 324.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 344.0f, 500.0f);
    
    self.textSettingView = [[TextSettingView alloc] initWithFrame:menuFrame];
    self.textSettingView.delegate = self;

    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    if (selectedObject.mediaType == MEDIA_TEXT)  //display TextObjectSetting View
    {
        [self.textSettingView setTextColor:selectedObject.textView.textColor];
        [self.textSettingView setStrFontName:selectedObject.textView.font.familyName];
        self.textSettingView.alignment = selectedObject.textView.textAlignment;
        self.textSettingView.isBold = selectedObject.isBold;
        self.textSettingView.isItalic = selectedObject.isItalic;
        self.textSettingView.isUnderline = selectedObject.isUnderline;
        self.textSettingView.isStroke = selectedObject.isStroke;
        self.textSettingView.textFontSize = selectedObject.textObjectFontSize;
        [self.textSettingView initialize];
        [self.textSettingView.fontNameTableView reloadData];

        self.customModalView = [[CustomModalView alloc] initWithView:self.textSettingView isCenter:NO];
        self.customModalView.delegate = self;
        self.customModalView.dismissButtonRight = YES;
        [self.customModalView show];
    }
    else     //create a new Text Object
    {
        [self generateNewTextObject];
    }
}

-(void) didOpacity
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count -1))
        return;
    
    
    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 200.0f, 80.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 80.0f);
    
    self.opacityView = [[OpacityView alloc] initWithFrame:menuFrame];
    self.opacityView.delegate = self;

    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    if ((selectedObject.mediaType ==  MEDIA_PHOTO) || (selectedObject.mediaType ==  MEDIA_GIF) || (selectedObject.mediaType ==  MEDIA_VIDEO))
        [self.opacityView setOpacityValue:selectedObject.imageView.alpha];
    else if (selectedObject.mediaType == MEDIA_TEXT)
        [self.opacityView setOpacityValue:selectedObject.textView.alpha];
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.opacityView isCenter:YES];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) didVolume
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;
    
    
    CGRect menuFrame = CGRectZero;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 200.0f, 80.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 80.0f);
    
    self.volumeView = [[VolumeView alloc] initWithFrame:menuFrame];
    self.volumeView.delegate = self;

    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    [self.volumeView setVolumeValue:[selectedObject getVolume]];
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.volumeView isCenter:YES];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) didColorOverlay
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;
    
    
    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 200.0f, 215.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 350.0f);
    
    self.shapeColorView = [[ShapeColorView alloc] initWithFrame:menuFrame];
    self.shapeColorView.delegate = self;

    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    [self.shapeColorView setShapeOverlayColor:selectedObject.shapeOverlayColor];
    [self.shapeColorView setShapeOverlayStyle:selectedObject.shapeOverlayStyle];
    [self.shapeColorView initialize];
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.shapeColorView isCenter:NO];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) didOutline
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    
    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 200.0f, 295.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 450.0f);
    
    self.outlineView = [[OutlineView alloc] initWithFrame:menuFrame];
    self.outlineView.delegate = self;

    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [self.outlineView setObjectBorderStyle:selectedObject.objectBorderStyle];
    [self.outlineView setObjectBorderWidth:selectedObject.objectBorderWidth];
    [self.outlineView setObjectBorderColor:selectedObject.objectBorderColor];
    [self.outlineView setObjectCornerRadius:selectedObject.objectCornerRadius];
    
    CGFloat max = 0.0f;
    
    if (selectedObject.bounds.size.width >= selectedObject.bounds.size.height)
        max = selectedObject.bounds.size.height / 2.0f;
    else
        max = selectedObject.bounds.size.width / 2.0f;
    
    [self.outlineView setMaxCornerValue:max];
    [self.outlineView initialize];
    [self.outlineView changeMaxCornerValue:max];

    self.customModalView = [[CustomModalView alloc] initWithView:self.outlineView isCenter:NO];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) didShadow
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    
    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 200.0f, 295.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 450.0f);
    
    self.shadowView = [[ShadowView alloc] initWithFrame:menuFrame];
    self.shadowView.delegate = self;

    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    [self.shadowView setObjectShadowStyle:selectedObject.objectShadowStyle];
    [self.shadowView setObjectShadowBlur:selectedObject.objectShadowBlur];
    [self.shadowView setObjectShadowOffset:selectedObject.objectShadowOffset];
    [self.shadowView setObjectShadowColor:selectedObject.objectShadowColor];
    [self.shadowView initialize];

    self.customModalView = [[CustomModalView alloc] initWithView:self.shadowView isCenter:NO];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) didReflection
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    
    CGRect menuFrame = CGRectZero;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        menuFrame = CGRectMake(0.0f, 0.0f, 200.0f, 295.0f);
    else
        menuFrame = CGRectMake(0.0f, 0.0f, 300.0f, 450.0f);
    
    self.reflectionSettingView = [[ReflectionSettingView alloc] initWithFrame:menuFrame];
    self.reflectionSettingView.delegate = self;

    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    [self.reflectionSettingView setIsReflection:selectedObject.isReflection];
    [self.reflectionSettingView setReflectionScale:selectedObject.reflectionScale];
    [self.reflectionSettingView setReflectionAlpha:selectedObject.reflectionAlpha];
    [self.reflectionSettingView setReflectionGap:selectedObject.reflectionGap];
    [self.reflectionSettingView initialize];
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.reflectionSettingView isCenter:NO];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}

-(void) didChangeKenburn
{
    self.editButtonsView.hidden = YES;
    self.editLeftButton.hidden = YES;
    self.editRightButton.hidden = YES;
    self.timelineButton.hidden = YES;
    self.playingButton.hidden = YES;
    self.seekSlider.hidden = YES;
    self.currentSeekTimeLabel.hidden = YES;
    self.totalSeekTimeLabel.hidden = YES;
    self.saveButton.hidden = YES;
    self.gridButton.hidden = YES;
    self.timelineView.hidden = YES;
    self.horizontalBgView.hidden = YES;
    self.verticalBgView.hidden = YES;
    self.projectNameLabel.hidden = YES;
    self.totalTimeLabel.hidden = YES;
    
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:i];
        
        if (i == gnSelectedObjectIndex)
        {
            if ((object.mediaType == MEDIA_PHOTO) || (object.mediaType == MEDIA_TEXT)) {
                [self.playingButton setEnabled:NO];
                [self.seekSlider setEnabled:NO];
                [self.currentSeekTimeLabel setText:@"00:00.000"];
                [self.totalSeekTimeLabel setText:@"00:00.000"];
            } else if ((object.mediaType == MEDIA_VIDEO) || (object.mediaType == MEDIA_MUSIC)) {
                [self.playingButton setEnabled:YES];
                [self.seekSlider setEnabled:YES];
            }
            
            [object object_actived];
            
            thumbImageView.layer.borderColor = [UIColor greenColor].CGColor;
            thumbImageView.layer.borderWidth = 3.0f;
        }
        else
        {
            object.alpha = 0.0f;
            
            thumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            thumbImageView.layer.borderWidth = 1.0f;
        }
    }
    
    [self updateObjectEdit];
  
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [self.kenBurnsSettingsView setKbEnabled:selectedObject.isKbEnabled];
    [self.kenBurnsSettingsView setKbIn:selectedObject.nKbIn];
    [self.kenBurnsSettingsView setKbScale:selectedObject.fKbScale];

    [selectedObject showKenBurnsFocusImageView];
    
    self.kenBurnsSettingsView.hidden = NO;
}

-(void) didDuplicated
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    selectedObject.mfStartPosition = [self.timelineView getStartPosition:gnSelectedObjectIndex];
    selectedObject.mfEndPosition = [self.timelineView getEndPosition:gnSelectedObjectIndex];
    selectedObject.startActionType = [self.timelineView getStartActionType:gnSelectedObjectIndex];
    selectedObject.mfStartAnimationDuration = [self.timelineView getStartActionTime:gnSelectedObjectIndex];
    selectedObject.endActionType = [self.timelineView getEndActionType:gnSelectedObjectIndex];
    selectedObject.mfEndAnimationDuration = [self.timelineView getEndActionTime:gnSelectedObjectIndex];

    if (selectedObject.mediaType == MEDIA_PHOTO)
    {
        [self generationImageView:selectedObject.imageName];
        
        MediaObjectView* object = [self.mediaObjectArray lastObject];
        [object setObjectValuesFromOldObject:selectedObject];
    }
    else if (selectedObject.mediaType == MEDIA_GIF)
    {
        [self generationGIFImageView:selectedObject.imageName];
        
        MediaObjectView* object = [self.mediaObjectArray lastObject];
        [object setObjectValuesFromOldObject:selectedObject];
    }
    else if (selectedObject.mediaType == MEDIA_VIDEO)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
        NSString *dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
        NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
        NSURL* tmpMediaUrl = [NSURL fileURLWithPath:[folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"TrimVideo-%@.mp4", dateForFilename]]];

        NSError* error = nil;
        NSFileManager *localFileManager = [NSFileManager defaultManager];
        [localFileManager copyItemAtPath:[selectedObject.mediaUrl path] toPath:[tmpMediaUrl path] error:&error];

        if (error)
            NSLog(@"%@", [error localizedDescription]);
        
        [self didCompletedTrim:tmpMediaUrl type:MEDIA_VIDEO];
        
        MediaObjectView* object = [self.mediaObjectArray lastObject];
        
        grNormalFilterOutputTotalTime = self.timelineView.totalTime;

        [self.projectManager saveObjectWithModifiedVideoInfo:object];

        [object setObjectValuesFromOldObject:selectedObject];
        
        CGFloat duration = [object getVideoTotalDuration];
        [self.timelineView changeTimeline:object.objectIndex time:duration];
    }
    else if (selectedObject.mediaType == MEDIA_TEXT)
    {
        [self duplicateTextObject:selectedObject];
        
        MediaObjectView* object = [self.mediaObjectArray lastObject];
        [object setObjectValuesFromOldObject:selectedObject];
    }
    else if (selectedObject.mediaType == MEDIA_MUSIC)
    {
        [self didCompletedTrim:selectedObject.mediaUrl type:MEDIA_MUSIC];
        
        MediaObjectView* object = [self.mediaObjectArray lastObject];
        [object setObjectValuesFromOldObject:selectedObject];
        
        CGFloat duration = [object getVideoTotalDuration];
        [self.timelineView changeTimeline:object.objectIndex time:duration];
    }
    
    MediaObjectView* object = [self.mediaObjectArray lastObject];

    [self.timelineView resetTimeline:object.objectIndex obj:object];
    
    if (self.mediaObjectArray.count > 0)
    {
        MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        
        if ((selectedObject.mediaType == MEDIA_VIDEO) || (selectedObject.mediaType == MEDIA_MUSIC)) {
            [self.playingButton setEnabled:YES];
            [self.seekSlider setEnabled:YES];
        } else {
            [self.playingButton setEnabled:NO];
            [self.seekSlider setEnabled:NO];
            [self.currentSeekTimeLabel setText:@"00:00.000"];
            [self.totalSeekTimeLabel setText:@"00:00.000"];
        }
    }
    else
    {
        [self.playingButton setEnabled:NO];
        [self.seekSlider setEnabled:NO];
        [self.currentSeekTimeLabel setText:@"00:00.000"];
        [self.totalSeekTimeLabel setText:@"00:00.000"];
    }
    
    [self.videoPlayer pause];
    
    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    
    [self updateObjectEdit];
}

-(void) didMaskShow
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }

    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject maskArrowsShow];
}

// Added by Yinjing 20170221
- (void) didPerspective
{
    
}


-(void) onShowFiltersUI
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Loading Filters...", nil)) isLock:YES];

    [self performSelector:@selector(gotoPhotoFilters) withObject:nil afterDelay:0.02f];
}

-(void) gotoPhotoFilters
{
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    if (selectedObject.mediaType == MEDIA_PHOTO)
    {
        [self.photoFiltersView setImage:selectedObject.originalImage isText:NO];
        [self.photoFiltersView setSelectedFilter:selectedObject.photoFilterIndex value:selectedObject.photoFilterValue];
    }
    else if (selectedObject.mediaType == MEDIA_TEXT)
    {
        UIGraphicsBeginImageContextWithOptions(selectedObject.textView.bounds.size, NO, 2.0f);
        
        selectedObject.textView.layer.shadowColor = [UIColor clearColor].CGColor;
        [selectedObject.textView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        if (selectedObject.objectShadowStyle == 2)
            selectedObject.textView.layer.shadowColor = selectedObject.objectShadowColor.CGColor;
        
        selectedObject.originalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.photoFiltersView setImage:selectedObject.originalImage isText:YES];
        [self.photoFiltersView setSelectedFilter:selectedObject.photoFilterIndex value:selectedObject.photoFilterValue];
    }
    
    [self.view bringSubviewToFront:self.photoFiltersView];
    
    self.photoFiltersView.frame = CGRectMake(0.0f, self.photoFiltersView.frame.size.height, self.photoFiltersView.frame.size.width, self.photoFiltersView.frame.size.height);
    self.photoFiltersView.hidden = NO;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.photoFiltersView.frame = CGRectMake(0.0f, 0.0f, self.photoFiltersView.frame.size.width, self.photoFiltersView.frame.size.height);
    } completion:^(BOOL finished) {
        [[SHKActivityIndicator currentIndicator] performSelector:@selector(hide) withObject:nil afterDelay:0.5f];
    }];
}

-(void) onShowVideoFiltersUI
{
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Loading Filters...", nil)) isLock:YES];
    
    [self performSelector:@selector(gotoVideoFilters) withObject:nil afterDelay:0.02f];
}

-(void) gotoVideoFilters
{
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    [self.videoFiltersView initParams:selectedObject.mediaUrl image:selectedObject.originalImage];
    
    [self.view bringSubviewToFront:self.videoFiltersView];
    
    self.videoFiltersView.frame = CGRectMake(0.0f, self.videoFiltersView.frame.size.height, self.videoFiltersView.frame.size.width, self.videoFiltersView.frame.size.height);
    self.videoFiltersView.hidden = NO;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.videoFiltersView.frame = CGRectMake(0.0f, 0.0f, self.videoFiltersView.frame.size.width, self.videoFiltersView.frame.size.height);
    } completion:^(BOOL finished) {
        [[SHKActivityIndicator currentIndicator] performSelector:@selector(hide) withObject:nil afterDelay:0.5f];
    }];
}

- (void)didShowChromakeyColorSettings
{
    if (self.videoPlayer.rate != 0) {
        [self onPlaying:self.playingButton];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.videoPlayerLayer.hidden = YES;
        
        MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        CMTime currentTime = self.videoPlayer.currentTime;
        [selectedObject showThumbImageView:currentTime];

        if (self.customModalView != nil)
        {
            [self.customModalView hideCustomModalView];
            self.customModalView = nil;
        }
        
        //CGRect menuFrame = CGRectMake(0.0f, 0.0f, 250.0f, 160.0f);
        //CGRect menuFrame = CGRectMake(0.0f, 0.0f, 320.0f, 330.0f); // With edges
        CGRect menuFrame = CGRectMake(0.0f, 0.0f, 320.0f, 266.0f);
        
        self.chromakeySettingView = [[ChromakeySettingView alloc] initWithFrame:menuFrame];
        self.chromakeySettingView.delegate = self;
        self.chromakeySettingView.selectedChromaType = selectedObject.objectChromaType;
        self.chromakeySettingView.selectedChromakeyColor = selectedObject.objectChromaColor;
        self.chromakeySettingView.selectedChromaTolerance = selectedObject.objectChromaTolerance;
        self.chromakeySettingView.selectedChromaNoise = selectedObject.objectChromaNoise;
        self.chromakeySettingView.selectedChromaEdges = selectedObject.objectChromaEdges;
        self.chromakeySettingView.selectedChromaOpacity = selectedObject.objectChromaOpacity;
        [self.chromakeySettingView initialize];
        
        self.customModalView = [[CustomModalView alloc] initWithView:self.chromakeySettingView isCenter:NO];
        self.customModalView.delegate = self;
        self.customModalView.dismissButtonRight = YES;
        [self.customModalView show];
        
        [selectedObject applyChromakeyFilter];
    });
}


#pragma mark -
#pragma mark - SpeedSegmentViewDelegate

-(void) didSelectedMotion:(NSMutableArray*) motionsArray starts:(NSMutableArray*) startPosArray ends:(NSMutableArray*) endPosArray
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    
    /************** remove speedSegmentView **************/
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.speedSegmentView.frame = CGRectMake(0.0f, self.speedSegmentView.frame.size.height, self.speedSegmentView.frame.size.width, self.speedSegmentView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        if (self.speedSegmentView != nil)
        {
            [self.speedSegmentView.mediaPlayerLayer.player pause];
            
            if (self.speedSegmentView.mediaPlayerLayer.player != nil)
                self.speedSegmentView.mediaPlayerLayer.player = nil;
            
            if (self.speedSegmentView.mediaPlayerLayer != nil)
            {
                [self.speedSegmentView.mediaPlayerLayer removeFromSuperlayer];
                self.speedSegmentView.mediaPlayerLayer = nil;
            }
            
            [self.speedSegmentView removeSegmentUI];

            [self.speedSegmentView removeFromSuperview];
            self.speedSegmentView = nil;
        }
    }];
    
    
    /**************** set speedSegment values to selected object ******************/
    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    // startPositionArray
    if (selectedObject.startPositionArray)
    {
        [selectedObject.startPositionArray removeAllObjects];
        selectedObject.startPositionArray = nil;
    }
    
    selectedObject.startPositionArray = [[NSMutableArray alloc] init];
    
    for (NSNumber* startPos in startPosArray)
        [selectedObject.startPositionArray addObject:startPos];
    
    // endPositionArray
    if (selectedObject.endPositionArray)
    {
        [selectedObject.endPositionArray removeAllObjects];
        selectedObject.endPositionArray = nil;
    }
    
    selectedObject.endPositionArray = [[NSMutableArray alloc] init];
    
    for (NSNumber* endPos in endPosArray)
        [selectedObject.endPositionArray addObject:endPos];
    
    // motionArray
    if (selectedObject.motionArray)
    {
        [selectedObject.motionArray removeAllObjects];
        selectedObject.motionArray = nil;
    }
    
    selectedObject.motionArray = [[NSMutableArray alloc] init];
    
    for (NSNumber* motionValue in motionsArray)
        [selectedObject.motionArray addObject:motionValue];

    
    /***************** change timeline ****************/
    
    CGFloat duration = [selectedObject getVideoTotalDuration];
    [self.timelineView changeTimeline:selectedObject.objectIndex time:duration];
    
    
    /************* update video thumbnail **************/
    
    NSNumber* startPosNum = [startPosArray objectAtIndex:0];
    CGFloat startPosition = [startPosNum floatValue];
    
    [selectedObject updateVideoThumbnail:startPosition];
    
    
    /************** change video range slider ****************/
    
    CGFloat minDuration = self.timelineView.totalTime;
    
    for (int i = 0; i < self.timelineView.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        
        if (minDuration > (slider.rightPosition - slider.leftPosition))
            minDuration = (slider.rightPosition - slider.leftPosition);
    }
    
    CGFloat minWidth = 0.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        minWidth = IPHONE_TIMELINE_WIDTH_MIN;
    else
        minWidth = IPAD_TIMELINE_WIDTH_MIN;
    
    self.timelineView.scaleFactor = minWidth / minDuration;
    
    for (int i = 0; i < self.timelineView.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        [slider changeSliderFrame:self.timelineView.scaleFactor];
        [slider drawRuler];
    }
    
    if (self.timelineView.sliderArray.count > 0)
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, self.timelineView.sliderArray.count * grSliderHeight);
    else
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, grSliderHeight);
    
    [self prepareVideoPlayer:selectedObject];
}

-(void) didCancelSpeed
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.speedSegmentView.frame = CGRectMake(0.0f, self.speedSegmentView.frame.size.height, self.speedSegmentView.frame.size.width, self.speedSegmentView.frame.size.height);
    } completion:^(BOOL finished) {
        if (self.speedSegmentView != nil)
        {
            [self.speedSegmentView.mediaPlayerLayer.player pause];
            
            if (self.speedSegmentView.mediaPlayerLayer.player != nil)
                self.speedSegmentView.mediaPlayerLayer.player = nil;
            
            if (self.speedSegmentView.mediaPlayerLayer != nil)
            {
                [self.speedSegmentView.mediaPlayerLayer removeFromSuperlayer];
                self.speedSegmentView.mediaPlayerLayer = nil;
            }
            
            [self.speedSegmentView removeSegmentUI];
            
            [self.speedSegmentView removeFromSuperview];
            self.speedSegmentView = nil;
        }
    }];
}


#pragma mark -
#pragma mark - JogEditViewDelegate

-(void) didApplyJogReverse:(NSURL*) jogVideoUrl
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.jogEditView.frame = CGRectMake(0.0f, self.jogEditView.frame.size.height, self.jogEditView.frame.size.width, self.jogEditView.frame.size.height);
    } completion:^(BOOL finished) {
        if (self.jogEditView != nil)
        {
            [self.jogEditView.mediaPlayerLayer.player pause];
            
            if (self.jogEditView.mediaPlayerLayer.player != nil)
                self.jogEditView.mediaPlayerLayer.player = nil;
            
            if (self.jogEditView.mediaPlayerLayer != nil)
            {
                [self.jogEditView.mediaPlayerLayer removeFromSuperlayer];
                self.jogEditView.mediaPlayerLayer = nil;
            }
            
            [self.jogEditView removeFromSuperview];
            self.jogEditView = nil;
        }
    }];
    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    unlink([[selectedObject.mediaUrl path] UTF8String]);
    selectedObject.mediaUrl = jogVideoUrl;
    
    [selectedObject changeVideoThumbWithFilter];
    
    YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:gnSelectedObjectIndex];
    slider.thumbnailImageView.image = selectedObject.imageView.image;
    
    UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:gnSelectedObjectIndex];
    thumbImageView.image = selectedObject.imageView.image;
    
    [self.timelineView selectTimelineObject:gnSelectedObjectIndex];
    
    selectedObject.isSelected = YES;
    selectedObject.selectedLineLayer.hidden = NO;
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:selectedObject.mediaUrl]];
    [self.videoPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
    
    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playingButton setEnabled:YES];
    
    AVAsset* mediaAsset = [AVURLAsset assetWithURL:jogVideoUrl];
    selectedObject.mediaDuration = CMTimeGetSeconds(mediaAsset.duration);
    
    if (selectedObject.startPositionArray) {
        [selectedObject.startPositionArray removeAllObjects];
        [selectedObject.endPositionArray removeAllObjects];
        [selectedObject.motionArray removeAllObjects];
    }
    
    [selectedObject.startPositionArray addObject:[NSNumber numberWithFloat:0.0f]];
    [selectedObject.endPositionArray addObject:[NSNumber numberWithFloat:selectedObject.mediaDuration]];
    [selectedObject.motionArray addObject:[NSNumber numberWithFloat:1.0f]];
    
    self.seekSlider.minimumValue = 0.0;
    self.seekSlider.maximumValue = CMTimeGetSeconds(mediaAsset.duration);
    self.seekSlider.value = 0.0;
    [self.seekSlider setEnabled:YES];
    [self.currentSeekTimeLabel setText:@"00:00.000"];
    [self.totalSeekTimeLabel setText:[self timeToString:CMTimeGetSeconds(mediaAsset.duration)]];
    
    [self.timelineView changeTimeline:selectedObject.objectIndex time:selectedObject.mediaDuration];
    
    CGFloat minDuration = self.timelineView.totalTime;
    
    for (int i = 0; i < self.timelineView.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        
        if (minDuration > (slider.rightPosition - slider.leftPosition))
            minDuration = (slider.rightPosition - slider.leftPosition);
    }
    
    CGFloat minWidth = 0.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        minWidth = IPHONE_TIMELINE_WIDTH_MIN;
    else
        minWidth = IPAD_TIMELINE_WIDTH_MIN;
    
    self.timelineView.scaleFactor = minWidth / minDuration;
    
    for (int i = 0; i < self.timelineView.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        [slider changeSliderFrame:self.timelineView.scaleFactor];
        [slider drawRuler];
    }
    
    if (self.timelineView.sliderArray.count > 0)
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, self.timelineView.sliderArray.count * grSliderHeight);
    else
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, grSliderHeight);
    
    selectedObject.mfStartPosition = [self.timelineView getStartPosition:gnSelectedObjectIndex];
    selectedObject.mfEndPosition = [self.timelineView getEndPosition:gnSelectedObjectIndex];
    
    grNormalFilterOutputTotalTime = self.timelineView.totalTime;

    [self.projectManager saveObjectWithModifiedVideoInfo:selectedObject];
    
    [self prepareVideoPlayer:selectedObject];
}

-(void) didCancelJogReverse
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.jogEditView.frame = CGRectMake(0.0f, self.jogEditView.frame.size.height, self.jogEditView.frame.size.width, self.jogEditView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        if (self.jogEditView != nil)
        {
            [self.jogEditView.mediaPlayerLayer.player pause];
            
            if (self.jogEditView.mediaPlayerLayer.player != nil)
                self.jogEditView.mediaPlayerLayer.player = nil;
            
            if (self.jogEditView.mediaPlayerLayer != nil)
            {
                [self.jogEditView.mediaPlayerLayer removeFromSuperlayer];
                self.jogEditView.mediaPlayerLayer = nil;
            }
            
            [self.jogEditView removeFromSuperview];
            self.jogEditView = nil;
        }
        
    }];
}


#pragma mark -
#pragma mark - EditTrimViewDelegate

-(void) didEditTrim:(NSURL*) mediaUrl
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.editTrimView.frame = CGRectMake(0.0f, self.editTrimView.frame.size.height, self.editTrimView.frame.size.width, self.editTrimView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        if (self.editTrimView != nil)
        {
            [self.editTrimView.mediaPlayerLayer.player pause];
            
            if (self.editTrimView.mediaPlayerLayer.player != nil)
                self.editTrimView.mediaPlayerLayer.player = nil;
            
            if (self.editTrimView.mediaPlayerLayer != nil)
            {
                [self.editTrimView.mediaPlayerLayer removeFromSuperlayer];
                self.editTrimView.mediaPlayerLayer = nil;
            }
            
            [self.editTrimView removeFromSuperview];
            self.editTrimView = nil;
        }
    }];
    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    unlink([[selectedObject.mediaUrl path] UTF8String]);
    selectedObject.mediaUrl = mediaUrl;
    
    [selectedObject changeVideoThumbWithFilter];
    
    YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:gnSelectedObjectIndex];
    slider.thumbnailImageView.image = selectedObject.imageView.image;
    
    UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:gnSelectedObjectIndex];
    thumbImageView.image = selectedObject.imageView.image;
    
    [self.timelineView selectTimelineObject:gnSelectedObjectIndex];
    
    selectedObject.isSelected = YES;
    selectedObject.selectedLineLayer.hidden = NO;
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:[AVURLAsset assetWithURL:selectedObject.mediaUrl]];
    [self.videoPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
    
    [self.playingButton setTag:0];
    [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
    [self.playingButton setEnabled:YES];
    
    AVAsset* mediaAsset = [AVURLAsset assetWithURL:mediaUrl];
    selectedObject.mediaDuration = CMTimeGetSeconds(mediaAsset.duration);
    
    if (selectedObject.startPositionArray)
    {
        [selectedObject.startPositionArray removeAllObjects];
        [selectedObject.endPositionArray removeAllObjects];
        [selectedObject.motionArray removeAllObjects];
    }
    
    [selectedObject.startPositionArray addObject:[NSNumber numberWithFloat:0.0f]];
    [selectedObject.endPositionArray addObject:[NSNumber numberWithFloat:selectedObject.mediaDuration]];
    [selectedObject.motionArray addObject:[NSNumber numberWithFloat:1.0f]];
    
    self.seekSlider.minimumValue = 0.0;
    self.seekSlider.maximumValue = CMTimeGetSeconds(mediaAsset.duration);
    self.seekSlider.value = 0.0;
    [self.seekSlider setEnabled:YES];
    [self.currentSeekTimeLabel setText:@"00:00.000"];
    [self.totalSeekTimeLabel setText:[self timeToString:CMTimeGetSeconds(mediaAsset.duration)]];
    
    [self.timelineView changeTimeline:selectedObject.objectIndex time:selectedObject.mediaDuration];
    
    CGFloat minDuration = self.timelineView.totalTime;
    
    for (int i = 0; i < self.timelineView.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        
        if (minDuration > (slider.rightPosition - slider.leftPosition))
            minDuration = (slider.rightPosition - slider.leftPosition);
    }
    
    CGFloat minWidth = 0.0f;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        minWidth = IPHONE_TIMELINE_WIDTH_MIN;
    else
        minWidth = IPAD_TIMELINE_WIDTH_MIN;
    
    self.timelineView.scaleFactor = minWidth / minDuration;
    
    for (int i = 0; i < self.timelineView.sliderArray.count; i++)
    {
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        [slider changeSliderFrame:self.timelineView.scaleFactor];
        [slider drawRuler];
    }
    
    if (self.timelineView.sliderArray.count > 0)
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, self.timelineView.sliderArray.count * grSliderHeight);
    else
        self.timelineView.contentSize = CGSizeMake(self.timelineView.scaleFactor * self.timelineView.totalTime, grSliderHeight);
    
    selectedObject.mfStartPosition = [self.timelineView getStartPosition:gnSelectedObjectIndex];
    selectedObject.mfEndPosition = [self.timelineView getEndPosition:gnSelectedObjectIndex];
    
    grNormalFilterOutputTotalTime = self.timelineView.totalTime;

    [self.projectManager saveObjectWithModifiedVideoInfo:selectedObject];
    
    if (selectedObject.mediaType == MEDIA_MUSIC)
    {
        [self.timelineView updateWaveform:gnSelectedObjectIndex url:selectedObject.mediaUrl];
    }
    
    [self prepareVideoPlayer:selectedObject];
}

-(void) didCancelEditTrim
{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.editTrimView.frame = CGRectMake(0.0f, self.editTrimView.frame.size.height, self.editTrimView.frame.size.width, self.editTrimView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
        if (self.editTrimView != nil)
        {
            [self.editTrimView.mediaPlayerLayer.player pause];
            
            if (self.editTrimView.mediaPlayerLayer.player != nil)
                self.editTrimView.mediaPlayerLayer.player = nil;
            
            if (self.editTrimView.mediaPlayerLayer != nil)
            {
                [self.editTrimView.mediaPlayerLayer removeFromSuperlayer];
                self.editTrimView.mediaPlayerLayer = nil;
            }
            
            [self.editTrimView removeFromSuperview];
            self.editTrimView = nil;
        }
    }];
}


#pragma mark -
#pragma mark - setting change functions

-(void) changeOpacity:(CGFloat) opacityValue
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;
    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    if ((selectedObject.mediaType == MEDIA_PHOTO)||(selectedObject.mediaType == MEDIA_GIF)||(selectedObject.mediaType == MEDIA_VIDEO))
    {
        selectedObject.imageView.alpha = opacityValue;
        selectedObject.borderLineLayer.opacity = opacityValue;

        if (selectedObject.mediaType == MEDIA_VIDEO)
        {
            self.videoPlayerLayer.opacity = opacityValue;
            [selectedObject setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:opacityValue]];
        }
        
        [selectedObject applyShadow];
    }
    else if (selectedObject.mediaType == MEDIA_TEXT)
    {
        selectedObject.textView.alpha = opacityValue;
        selectedObject.borderLineLayer.opacity = opacityValue;
        [selectedObject applyShadow];
    }
}

-(void) changeVolume:(CGFloat)volumeValue
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count -1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject setVolume:volumeValue];
    
    self.videoPlayer.volume = selectedObject.mediaVolume;
}

-(void) changeBorder:(int)style borderColor:(UIColor *)color borderWidth:(CGFloat)width cornerRadius:(CGFloat)radius
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count -1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    selectedObject.objectBorderStyle = style;
    selectedObject.objectBorderColor = color;
    selectedObject.objectBorderWidth = width;
    selectedObject.objectCornerRadius = radius;
    
    [selectedObject applyBorder];
}

- (void)changeChromakeyType:(ChromakeyType)type {
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    selectedObject.objectChromaType = type;
    [selectedObject applyChromakeyFilter];
}

-(void) changeChromakeyColor:(UIColor*) color
{
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    selectedObject.objectChromaColor = [UIColor colorWithCGColor:color.CGColor];
    [selectedObject applyChromakeyFilter];
}

- (void)changeChromakeyTolerance:(CGFloat)tolerance {
    MediaObjectView *selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    selectedObject.objectChromaTolerance = tolerance;
    [selectedObject applyChromakeyFilter];
}

- (void)changeChromakeyNoise:(CGFloat) noise {
    MediaObjectView *selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    selectedObject.objectChromaNoise = noise;
    [selectedObject applyChromakeyFilter];
}

- (void)changeChromakeyEdges:(CGFloat) edges {
    MediaObjectView *selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    selectedObject.objectChromaEdges = edges;
    [selectedObject applyChromakeyFilter];
}

- (void)changeChromakeyOpacity:(CGFloat) opacity {
    MediaObjectView *selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    selectedObject.objectChromaOpacity = opacity;
    [selectedObject applyChromakeyFilter];
}

- (void)didShowColorPickerView {
    if (self.customModalView != nil) {
        self.customModalView.hidden = YES;
    }
}

- (void)didHideColorPickerView {
    if (self.customModalView != nil) {
        self.customModalView.hidden = NO;
    }
}

-(void) changeShadow:(CGFloat)shadowOffset shadowBlur:(CGFloat)blur shadowColor:(UIColor*)color shadowStyle:(int)style
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    selectedObject.objectShadowOffset = shadowOffset;
    selectedObject.objectShadowBlur = blur;
    selectedObject.objectShadowColor = color;
    selectedObject.objectShadowStyle = style;
    
    [selectedObject applyShadow];
}

-(void) changeTextColor:(UIColor*) color
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject applyTextColor:color];
}

-(void) changeTextAlignment:(NSTextAlignment) alignment
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject applyTextAlignment:alignment];
}

-(void) changeTextUnderline:(BOOL) isUnderline
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject applyTextUnderline:isUnderline];
}

-(void) changeTextStroke:(BOOL) isStroke
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject applyTextStroke:isStroke];
}

-(void) changeTextFont:(NSString*)fontName size:(CGFloat)fontSize bold:(BOOL)isBold italic:(BOOL)isItalic
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject applyTextFont:fontName size:fontSize bold:isBold italic:isItalic];
}

-(void) changeReflection:(BOOL) isReflection scale:(CGFloat)reflectionScale alpha:(CGFloat)reflectionAlpha gap:(CGFloat)reflectionGap
{
    if ((self.mediaObjectArray.count <= 0) || (gnSelectedObjectIndex > self.mediaObjectArray.count - 1))
        return;

    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    [selectedObject setIsReflection:isReflection];
    [selectedObject setReflectionScale:reflectionScale];
    [selectedObject setReflectionAlpha:reflectionAlpha];
    [selectedObject setReflectionGap:reflectionGap];
    [selectedObject update];
    
    if (selectedObject.isKbEnabled && isReflection)
    {
        selectedObject.isKbEnabled = NO;
    }
}


#pragma mark -
#pragma mark - *************** CustomModalViewDelegate *****************

-(void) didClosedCustomModalView
{
    isReplace = NO;

    self.videoPlayerLayer.hidden = NO;
    
    if (self.mediaObjectArray != nil && self.mediaObjectArray.count > 0) {
        MediaObjectView *selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [selectedObject hideThumbImageView];
        });
    }
    
    if (self.mediaTrimView != nil)
    {
        if ([self.mediaTrimView getMediaType] == MEDIA_MUSIC)
            [self onMusic];
        
        [self.mediaTrimView.mediaPlayerLayer.player pause];
        
        if (self.mediaTrimView.mediaPlayerLayer.player != nil)
            self.mediaTrimView.mediaPlayerLayer.player = nil;
        
        if (self.mediaTrimView.mediaPlayerLayer != nil)
        {
            [self.mediaTrimView.mediaPlayerLayer removeFromSuperlayer];
            self.mediaTrimView.mediaPlayerLayer = nil;
        }
        
        [self.mediaTrimView removeFromSuperview];
        self.mediaTrimView = nil;
    }

    if (self.speedSegmentView != nil)
    {
        self.settingsButton.hidden = YES;
        self.editButtonsView.hidden = YES;
        self.infoButton.hidden = YES;
        self.timelineView.hidden = NO;
        self.verticalBgView.alpha = 1.0f;
        self.horizontalBgView.alpha = 1.0f;

        [self.speedSegmentView.mediaPlayerLayer.player pause];
        [self.speedSegmentView removeFromSuperview];
        self.speedSegmentView = nil;
    }
    
    if (self.opacityView)
    {
        self.opacityView.delegate = nil;
        self.opacityView = nil;
    }
    
    if (self.volumeView)
    {
        self.volumeView.delegate = nil;
        self.volumeView = nil;
    }
    
    if (self.outlineView)
    {
        self.outlineView.delegate = nil;
        self.outlineView = nil;
    }
    
    if (self.shadowView)
    {
        self.shadowView.delegate = nil;
        self.shadowView = nil;
    }
    
    if (self.shapeColorView)
    {
        self.shapeColorView.delegate = nil;
        self.shapeColorView = nil;
    }
    
    if (self.textSettingView)
    {
        self.textSettingView.delegate = nil;
        self.textSettingView = nil;
    }
    
    if (self.reflectionSettingView)
    {
        self.reflectionSettingView.delegate = nil;
        self.reflectionSettingView = nil;
    }
    
    if (self.avChooseView)
    {
        self.avChooseView.delegate = nil;
        self.avChooseView = nil;
    }
    
    if (self.filterListView)
    {
        self.filterListView.delegate = nil;
        self.filterListView = nil;
    }

    if (self.settingsView)
    {
        self.settingsView.delegate = nil;
        self.settingsView = nil;
    }
}

-(void) timelineDeselected:(int) index
{
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView *object = [self.mediaObjectArray objectAtIndex:i];
        
        if (i == index)
        {
            [object maskArrowsHidden];
            object.isSelected = YES;
            object.selectedLineLayer.hidden = YES;
        }
        else
        {
            [object maskArrowsHidden];
            object.selectedLineLayer.hidden = YES;
            object.isSelected = NO;
        }
    }
}


#pragma mark -
#pragma mark - Timeline Horizontal View Delegate

-(void) setTimelineViewContentOffsetX:(CGFloat) offsetX
{
    [self.timelineView setContentOffset:CGPointMake(offsetX, self.timelineView.oldY)];
    [self.timelineView setNeedsDisplay];
}

-(void) timelineViewHorizontalScrollViewWillBeginDragging
{
    if (self.mediaObjectArray.count <= 0)
        return;
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    object.selectedLineLayer.hidden = YES;
    [self.timelineView timelineObjectDeselected];
    
    [self timelineDeselected:gnSelectedObjectIndex];
}

-(void) moveToBegin
{
    [self.timelineView setContentOffset:CGPointMake(0.0f, self.timelineView.contentOffset.y)];
    [self.horizontalBgView.horizontalScrollView setContentOffset:CGPointMake(0.0f, self.horizontalBgView.horizontalScrollView.contentOffset.y)];
}

-(void) moveToEnd
{
    if (self.timelineView.contentSize.width > self.timelineView.bounds.size.width)
    {
        [self.timelineView setContentOffset:CGPointMake(self.timelineView.contentSize.width - self.timelineView.bounds.size.width, self.timelineView.contentOffset.y)];
        [self.horizontalBgView.horizontalScrollView setContentOffset:CGPointMake(self.timelineView.contentSize.width - self.timelineView.bounds.size.width, self.horizontalBgView.horizontalScrollView.contentOffset.y)];
    }
}

-(void) changeTimelineScale:(CGFloat) scale
{
    if (gnZoomType == ZOOM_BOTH)
    {
        grSliderHeight = grSliderHeightMax*scale;
        grZoomScale = scale;
    }
    else if (gnZoomType == ZOOM_HORIZONTAL)
    {
        grZoomScale = scale;
    }
    else if (gnZoomType == ZOOM_VERTICAL)
    {
        grSliderHeight = grSliderHeightMax*scale;
    }

    [self.timelineView updateZoom];
}


#pragma mark -
#pragma mark - Timeline Vertical View Delegate

-(void) setTimelineViewContentOffsetY:(CGFloat)offsetY
{
    [self.timelineView setContentOffset:CGPointMake(self.timelineView.contentOffset.x, offsetY)];
    self.timelineView.oldY = offsetY;
    
    [self.timelineView setNeedsDisplay];
}

-(void) timelineViewVerticalScrollViewWillBeginDragging
{
    if (self.mediaObjectArray.count <= 0)
        return;
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    object.selectedLineLayer.hidden = YES;
    [self.timelineView timelineObjectDeselected];
    
    [self timelineDeselected:gnSelectedObjectIndex];
}

-(void) moveToTop
{
    [self.timelineView setContentOffset:CGPointMake(self.timelineView.contentOffset.x, 0.0f)];
    [self.verticalBgView.verticalScrollView setContentOffset:CGPointMake(self.verticalBgView.verticalScrollView.contentOffset.x, 0.0f)];
}

-(void) moveToBottom
{
    [self.timelineView setContentOffset:CGPointMake(self.timelineView.contentOffset.x, self.timelineView.contentSize.height - self.timelineView.bounds.size.height)];
    [self.verticalBgView.verticalScrollView setContentOffset:CGPointMake(self.verticalBgView.verticalScrollView.contentOffset.x, self.timelineView.contentSize.height - self.timelineView.bounds.size.height)];
}


#pragma mark -
#pragma mark - ******************** Other Functions ******************************

/*
 name - fixDeviceOrientation
 param - non
 return - non
 description - fix device orientation.
 created - 10/27/2013
 author - Yinjing Li.
 */

-(void) fixDeviceOrientation
{
    UIInterfaceOrientation orientation = [UIApplication orientation];
    
    if ((orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)&&(gnTemplateIndex == TEMPLATE_LANDSCAPE || gnTemplateIndex == TEMPLATE_1080P))
    {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    else if ((orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)&&(gnTemplateIndex == TEMPLATE_PORTRAIT || gnTemplateIndex == TEMPLATE_SQUARE))
    {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
}

- (void) fixAppOrientationAfterDismissImagePickerController
{
    if (gnTemplateIndex == TEMPLATE_LANDSCAPE || gnTemplateIndex == TEMPLATE_1080P)
        gnOrientation = ORIENTATION_LANDSCAPE;
    else if (gnTemplateIndex == TEMPLATE_PORTRAIT || gnTemplateIndex == TEMPLATE_SQUARE)
        gnOrientation = ORIENTATION_PORTRAIT;
    else
    {
        UIInterfaceOrientation orientation = [UIApplication orientation];
        
        if((orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) && (gnInstagramOrientation == ORIENTATION_LANDSCAPE))
            gnOrientation = ORIENTATION_LANDSCAPE;
        else if((orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) && (gnInstagramOrientation == ORIENTATION_PORTRAIT))
            gnOrientation = ORIENTATION_PORTRAIT;
        else
            gnOrientation = gnInstagramOrientation;
    }
    
    [self fixDeviceOrientation];
}

- (void)bringGridLayerToFront
{
    [self.gridLayer removeFromSuperlayer];
    [self.workspaceView.layer addSublayer:self.gridLayer];
}

- (NSString *)timeToString:(CGFloat)time
{
    // time - seconds
    NSInteger min = floor(time / 60);
    NSInteger sec = floor(time - min * 60);
    NSInteger millisecond = roundf((time - (min * 60 + sec)) * 1000);
    
    if (millisecond == 1000)
    {
        millisecond = 0;
        sec++;
    }
    
    NSString *minStr = [NSString stringWithFormat:min >= 10 ? @"%d" : @"0%d", (int)min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%d" : @"0%d", (int)sec];
    
    NSString *millisecStr = nil;
    
    if (millisecond >= 100)
        millisecStr = [NSString stringWithFormat:@"%d", (int)millisecond];
    else if (millisecond >= 10)
        millisecStr = [NSString stringWithFormat:@"0%d", (int)millisecond];
    else
        millisecStr = [NSString stringWithFormat:@"00%d", (int)millisecond];
    
    return [NSString stringWithFormat:@"%@:%@.%@", minStr, secStr, millisecStr];
}

- (UIImage *) makeBackgroundImage:(CGSize) size
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0.0);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColorFromRGB(0x9da1a0).CGColor);
    CGRect r = CGRectMake(0.0f, 0.0f, size.width, size.height);
    CGFloat cornerRadius = 2.0f;
    CGMutablePathRef path = CGPathCreateMutable() ;
    CGPathMoveToPoint( path, NULL, r.origin.x + cornerRadius, r.origin.y ) ;
    CGFloat maxX = CGRectGetMaxX( r ) ;    CGFloat maxY = CGRectGetMaxY( r ) ;
    CGPathAddArcToPoint( path, NULL, maxX, r.origin.y, maxX, r.origin.y + cornerRadius, cornerRadius ) ;
    CGPathAddArcToPoint( path, NULL, maxX, maxY, maxX - cornerRadius, maxY, cornerRadius ) ;
    CGPathAddArcToPoint( path, NULL, r.origin.x, maxY, r.origin.x, maxY - cornerRadius, cornerRadius ) ;
    CGPathAddArcToPoint( path, NULL, r.origin.x, r.origin.y, r.origin.x + cornerRadius, r.origin.y, cornerRadius ) ;
    CGContextAddPath(UIGraphicsGetCurrentContext(), path);
    CGContextFillPath(UIGraphicsGetCurrentContext());
    CGPathRelease(path);
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}


#pragma mark -
#pragma mark - Object Editing Function

-(IBAction)onLeft:(id)sender
{
    [self editLeft:sender];
}

-(IBAction)onRight:(id)sender
{
    [self editRight:sender];
}

-(IBAction)editLeft:(id)sender
{
    int index = gnSelectedObjectIndex - 1;
    
    if (index < 0)
        index = (int)self.mediaObjectArray.count - 1;
    
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:i];
        
        if (i == index)
        {
            if ((object.mediaType == MEDIA_PHOTO) || (object.mediaType == MEDIA_GIF) || (object.mediaType == MEDIA_TEXT)) {
                [self.playingButton setEnabled:NO];
                [self.seekSlider setEnabled:NO];
                [self.currentSeekTimeLabel setText:@"00:00.000"];
                [self.totalSeekTimeLabel setText:@"00:00.000"];
            } else if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_MUSIC)) {
                [self.playingButton setEnabled:YES];
                [self.seekSlider setEnabled:YES];
            }
            
            [object object_actived];
            
            thumbImageView.layer.borderColor = [UIColor greenColor].CGColor;
            thumbImageView.layer.borderWidth = 3.0f;
        }
        else
        {
            object.alpha = 0.0f;

            thumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            thumbImageView.layer.borderWidth = 1.0f;
        }
    }
    
    [self updateObjectEdit];
}

-(IBAction)editRight:(id)sender
{
    int index = gnSelectedObjectIndex + 1;
    
    if (index > (self.mediaObjectArray.count - 1))
        index = 0;
    
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:i];

        if (i == index)
        {
            if ((object.mediaType == MEDIA_PHOTO) || (object.mediaType == MEDIA_GIF) || (object.mediaType == MEDIA_TEXT)) {
                [self.playingButton setEnabled:NO];
                [self.seekSlider setEnabled:NO];
                [self.currentSeekTimeLabel setText:@"00:00.000"];
                [self.totalSeekTimeLabel setText:@"00:00.000"];
            } else if ((object.mediaType == MEDIA_VIDEO)||(object.mediaType == MEDIA_MUSIC)) {
                [self.playingButton setEnabled:YES];
                [self.seekSlider setEnabled:YES];
            }
            
            [object object_actived];
            
            thumbImageView.layer.borderColor = [UIColor greenColor].CGColor;
            thumbImageView.layer.borderWidth = 3.0f;
        }
        else
        {
            object.alpha = 0.0f;

            thumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            thumbImageView.layer.borderWidth = 1.0f;
        }
    }
    
    [self updateObjectEdit];
}

-(void) onSelectedEditThumbnail:(UITapGestureRecognizer *)gestureRecognizer
{
    int selectedIndex = (int)((UIImageView *)gestureRecognizer.view).tag;
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:selectedIndex];
    UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:selectedIndex];
    
    if (selectedIndex != gnSelectedObjectIndex)
    {
        if (object.alpha == 0.0f)
        {
            object.alpha = 1.0f;
            
            thumbImageView.layer.borderColor = [UIColor orangeColor].CGColor;
            thumbImageView.layer.borderWidth = 1.0f;
        }
        else
        {
            object.alpha = 0.0f;
            
            thumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            thumbImageView.layer.borderWidth = 1.0f;
        }
    }
    
    // Updated 23.02.23 Yinjing
    /*for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:i];
        
        if (i == selectedIndex)
        {
            if ((object.mediaType == MEDIA_PHOTO) || (object.mediaType == MEDIA_GIF) || (object.mediaType == MEDIA_TEXT)) {
                [self.playingButton setEnabled:NO];
                [self.seekSlider setEnabled:NO];
                [self.currentSeekTimeLabel setText:@"00:00.000"];
                [self.totalSeekTimeLabel setText:@"00:00.000"];
            } else if ((object.mediaType == MEDIA_VIDEO) || (object.mediaType == MEDIA_MUSIC)) {
                [self.playingButton setEnabled:YES];
                [self.seekSlider setEnabled:YES];
            }
            
            [object object_actived];
            
            thumbImageView.layer.borderColor = [UIColor greenColor].CGColor;
            thumbImageView.layer.borderWidth = 3.0f;
        }
        else
        {
            object.alpha = 0.0f;

            thumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            thumbImageView.layer.borderWidth = 1.0f;
        }
    }
    
    [self updateObjectEdit];*/
}

-(void) refreshTextObjectEditThumbnailView:(int) objectIndex
{
    YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:objectIndex];
    UIImage* image = slider.thumbnailImageView.image;

    if (self.editThumbnailArray.count > objectIndex)
    {
        UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:objectIndex];
        thumbImageView.image = image;
    }
}

-(void) refreshObjectEditThumbnailView
{
    for (int i = 0; i < self.editThumbnailArray.count; i++)
    {
        UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:i];
        [thumbImageView removeFromSuperview];
    }
    
    [self.editThumbnailArray removeAllObjects];
    self.editThumbnailArray = nil;
    self.editThumbnailArray = [[NSMutableArray alloc] init];
    
    CGFloat contentOffsetX = 0.0f;
    
    for (int i = 0; i < self.mediaObjectArray.count; i++)
    {
        MediaObjectView* object = [self.mediaObjectArray objectAtIndex:i];
        
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:i];
        
        UIImage* image = nil;
        
        if (object.mediaType == MEDIA_MUSIC)
            image = [UIImage imageNamed:@"musicSymbol"];
        else
            image = slider.thumbnailImageView.image;
        
        if (!image)
        {
            image = object.imageView.image;
            slider.thumbnailImageView.image = object.imageView.image;
        }
        
        CGSize size = image.size;
        size = CGSizeMake(size.width * self.editScrollView.frame.size.height * 0.9f / size.height, self.editScrollView.frame.size.height * 0.9f);

        UIImageView* thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentOffsetX, (self.editScrollView.frame.size.height - size.height) / 2, size.width, size.height)];
        [thumbImageView setBackgroundColor:[UIColor clearColor]];
        thumbImageView.image = image;
        thumbImageView.userInteractionEnabled = YES;
        
        if (i == gnSelectedObjectIndex)
        {
            thumbImageView.layer.borderColor = [UIColor greenColor].CGColor;
            thumbImageView.layer.borderWidth = 3.0f;
        }
        else
        {
            if (object.alpha > 0.0f)
            {
                thumbImageView.layer.borderColor = [UIColor orangeColor].CGColor;
                thumbImageView.layer.borderWidth = 1.0f;
            }
            else
            {
                thumbImageView.layer.borderColor = [UIColor whiteColor].CGColor;
                thumbImageView.layer.borderWidth = 1.0f;
            }
        }
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectedEditThumbnail:)];
        selectGesture.delegate = self;
        [thumbImageView addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];

        thumbImageView.tag = i;
        [self.editScrollView addSubview:thumbImageView];
        [self.editThumbnailArray addObject:thumbImageView];
        
        contentOffsetX = contentOffsetX + size.width + 10.0f;
    }
    
    [self.editScrollView setContentSize:CGSizeMake(contentOffsetX - 10.0f, self.editScrollView.bounds.size.height)];
}


#pragma mark -
#pragma mark - KenBurns Settings Delegate

-(void) didApplyKBSettingsView:(BOOL)enabled inOut:(NSInteger)inOutType scale:(CGFloat)zoomScale
{
    [self.timelineButton setImage:[UIImage imageNamed:@"timelineButton"] forState:UIControlStateNormal];

    self.editButtonsView.hidden = NO;
    self.editLeftButton.hidden = NO;
    self.editRightButton.hidden = NO;
    self.timelineButton.hidden = NO;
    self.playingButton.hidden = NO;
    self.seekSlider.hidden = NO;
    self.currentSeekTimeLabel.hidden = NO;
    self.totalSeekTimeLabel.hidden = NO;
    self.saveButton.hidden = NO;
    self.gridButton.hidden = NO;
    self.projectNameLabel.hidden = NO;
    self.totalTimeLabel.hidden = NO;

    self.kenBurnsSettingsView.hidden = YES;
    
    if (isKenBurnsChangeAll)
    {
        for (MediaObjectView* object in self.mediaObjectArray)
        {
            if ((object.mediaType == MEDIA_PHOTO) || (object.mediaType == MEDIA_TEXT))
            {
                [object.imageView.layer removeAnimationForKey:@"KenBurns"];
                
                object.isKbEnabled = enabled;
                object.nKbIn = inOutType;
                object.fKbScale = zoomScale;
                
                [object hideKenBurnsFocusImageView];
                
                if (object.isReflection && enabled)
                {
                    [object setIsReflection:NO];
                    [object update];
                }
            }
        }
        
        self.kenBurnsSettingsView.kbPreviewButton.tag = 1;
        [self.kenBurnsSettingsView.kbPreviewButton setTitle:NSLocalizedString(@"Preview", nil) forState:UIControlStateNormal];
        [self.kenBurnsSettingsView.kbCheckToAllButton setBackgroundImage:[UIImage imageNamed:@"dark_check_off"] forState:UIControlStateNormal];
        [self.kenBurnsSettingsView.kbCheckToAllButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateSelected];
        [self.kenBurnsSettingsView.kbCheckToAllButton setBackgroundImage:[UIImage imageNamed:@"dark_check_on"] forState:UIControlStateHighlighted];
        isKenBurnsChangeAll = NO;
    }
    else
    {
        MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
        
        if (selectedObject.mediaType == MEDIA_PHOTO)
            [selectedObject.imageView.layer removeAnimationForKey:@"KenBurns"];
        else if (selectedObject.mediaType == MEDIA_TEXT)
            [selectedObject.textView.layer removeAnimationForKey:@"KenBurns"];
        
        self.kenBurnsSettingsView.kbPreviewButton.tag = 1;
        [self.kenBurnsSettingsView.kbPreviewButton setTitle:NSLocalizedString(@"Preview", nil) forState:UIControlStateNormal];
        
        selectedObject.isKbEnabled = enabled;
        selectedObject.nKbIn = inOutType;
        selectedObject.fKbScale = zoomScale;
        
        [selectedObject hideKenBurnsFocusImageView];
        
        if (selectedObject.isReflection && enabled)
        {
            [selectedObject setIsReflection:NO];
            [selectedObject update];
        }
    }
}

-(void) didStopPreview
{
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    if (selectedObject.mediaType == MEDIA_PHOTO)
        [selectedObject.imageView.layer removeAnimationForKey:@"KenBurns"];
    else if (selectedObject.mediaType == MEDIA_TEXT)
        [selectedObject.textView.layer removeAnimationForKey:@"KenBurns"];
}

-(void) didPreviewKBSettingsView:(BOOL)enabled inOut:(NSInteger)inOutType scale:(CGFloat)zoomScale
{
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    CALayer* animationLayer = nil;

    if (selectedObject.mediaType == MEDIA_PHOTO)
        animationLayer = selectedObject.imageView.layer;
    else if (selectedObject.mediaType == MEDIA_TEXT)
        animationLayer = selectedObject.textView.layer;
    
    [animationLayer removeAnimationForKey:@"KenBurns"];

    selectedObject.mfStartPosition = [self.timelineView getStartPosition:gnSelectedObjectIndex];
    selectedObject.mfEndPosition = [self.timelineView getEndPosition:gnSelectedObjectIndex];
    
    CGFloat duration = selectedObject.mfEndPosition - selectedObject.mfStartPosition;

    //Translation Animation
    CAKeyframeAnimation * inKeyFrameTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CGFloat viewWidth = (animationLayer.bounds.size.width * zoomScale - animationLayer.bounds.size.width) / 2.0f;
    CGFloat viewHeight = (animationLayer.bounds.size.height * zoomScale - animationLayer.bounds.size.height) / 2.0f;
    
    CATransform3D translationTransform = CATransform3DTranslate(CATransform3DIdentity, viewWidth*(1.0f - selectedObject.kbFocusPoint.x * 2.0f), viewHeight*(1.0f - selectedObject.kbFocusPoint.y * 2.0f), 0);

    if (inOutType == KB_IN)
    {
        inKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                                                [NSValue valueWithCATransform3D:translationTransform]];
    }
    else if (inOutType == KB_OUT)
    {
        inKeyFrameTransformAnimation.values = @[[NSValue valueWithCATransform3D:translationTransform],
                                                [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    }

    //Scale Animation
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    if (inOutType == KB_IN)
    {
        scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
        scaleAnimation.toValue = [NSNumber numberWithFloat:zoomScale];
    }
    else if (inOutType == KB_OUT)
    {
        scaleAnimation.fromValue = [NSNumber numberWithFloat:zoomScale];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    }
    
    CAAnimationGroup * kbAnimation = [CAAnimationGroup animation];
    kbAnimation.animations = @[inKeyFrameTransformAnimation, scaleAnimation];
    kbAnimation.duration = duration;
    kbAnimation.repeatCount = 1;
    kbAnimation.fillMode = kCAFillModeBackwards;
    kbAnimation.delegate = (id)self;
    
    [animationLayer addAnimation:kbAnimation forKey:@"KenBurns"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    if (selectedObject.mediaType == MEDIA_PHOTO)
        [selectedObject.imageView.layer removeAnimationForKey:@"KenBurns"];
    else if (selectedObject.mediaType == MEDIA_TEXT)
        [selectedObject.textView.layer removeAnimationForKey:@"KenBurns"];
    
    self.kenBurnsSettingsView.kbPreviewButton.tag = 1;
    [self.kenBurnsSettingsView.kbPreviewButton setTitle:NSLocalizedString(@"Preview", nil) forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark - ShapeColorViewDelegate

-(void) changeShapeColor:(UIColor*) color style:(int)shapeOverlayStyle
{
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];

    if (object.isShape)
    {
        object.shapeOverlayStyle = shapeOverlayStyle;
        object.shapeOverlayColor = color;
        
        if (shapeOverlayStyle == 1)
            object.imageView.image = object.originalImage;
        else
            object.imageView.image = [object.originalImage imageWithOverlayColor:color];
    }
}


#pragma mark -
#pragma mark - ShapeGalleryPickerControllerDelegate

- (void)shapeGalleryPickerController:(ShapeGalleryPickerController *)picker didFinishPickingIndex:(NSInteger)index
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    UIImage* shapeImage = [UIImage imageNamed:[NSString stringWithFormat:@"shape%d", (int)index]];
    
    /*  rotate image by width and height */
    shapeImage = [UIImage rotateImage:shapeImage];
    
    /*******************************************************/
    /* detect transparency, if png or jpg is not transparency, compress that to 30%*/
    /*******************************************************/
    /* detect transparency png */
    BOOL isTransparency = [shapeImage detectTransparency];
    
    if (!isTransparency)    /* if png is non-transparency, compress to 30% */
    {
        if (isIPhoneFive && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            NSData* data = UIImageJPEGRepresentation(shapeImage, 0.6f);
            shapeImage = [UIImage imageWithData:data];
        }
        else
        {
            NSData* data = UIImageJPEGRepresentation(shapeImage, 0.3f);
            shapeImage = [UIImage imageWithData:data];
        }
    }
    /************************************************************/
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
    NSString *dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSString *imageName = [NSString stringWithFormat:@"image-%@.png", dateForFilename];
    NSString *fileName = [folderPath stringByAppendingPathComponent:imageName];
    
    [UIImagePNGRepresentation(shapeImage) writeToFile:fileName atomically:YES];
    
    
    /* generate imageView from UIImage */
    [self generationImageView:imageName];
    
    MediaObjectView* object = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    object.isShape = YES;
    
    [self.shapeGalleryPickerController dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.shapeGalleryPickerController = nil;
    }];
    
    [self updateObjectEdit];
}

- (void)shapeGalleryPickerControllerDidCancel:(ShapeGalleryPickerController *)picker
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.shapeGalleryPickerController dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.shapeGalleryPickerController = nil;
    }];
}


- (void)shapeGalleryPickerController:(ShapeGalleryPickerController *)picker failedWithError:(NSError *)error
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.shapeGalleryPickerController dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.shapeGalleryPickerController = nil;
    }];
}


#pragma mark -
#pragma mark - StingerGalleryPickerControllerDelegate

- (void)stingerGalleryPickerController:(StingerGalleryPickerController *)picker didFinishPickingStingerName:(NSString*)strStingerName
{
    [self fixAppOrientationAfterDismissImagePickerController];

    NSString *path = [[NSBundle mainBundle] pathForResource:strStingerName ofType:@"mp4"];
    NSURL* videoURL = [NSURL fileURLWithPath:path];

    [self generationVideoView:videoURL flag:NO];

    [self.stingerGalleryPickerController dismissViewControllerAnimated:YES completion:^{
        self.stingerGalleryPickerController = nil;
    }];
    
    [self updateObjectEdit];
}

- (void)stingerGalleryPickerControllerDidCancel:(StingerGalleryPickerController *)picker
{
    [self fixAppOrientationAfterDismissImagePickerController];

    [self.stingerGalleryPickerController dismissViewControllerAnimated:YES completion:^{
        self.stingerGalleryPickerController = nil;
    }];
}

- (void)stingerGalleryPickerController:(StingerGalleryPickerController *)picker failedWithError:(NSError *)error
{
    [self fixAppOrientationAfterDismissImagePickerController];

    [self.stingerGalleryPickerController dismissViewControllerAnimated:YES completion:^{
        self.stingerGalleryPickerController = nil;
    }];
}


#pragma mark -
#pragma mark - SettingsViewDelegate

-(void) didBackupProjects
{
    if (self.settingsView)
    {
        self.settingsView.delegate = nil;
        self.settingsView = nil;
    }
    
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (!self.projectGalleryPicker)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProjectGalleryStoryboard" bundle:nil];
        self.projectGalleryPicker = [sb instantiateViewControllerWithIdentifier:@"ProjectGalleryPickerController"];
        self.projectGalleryPicker.projectGalleryPickerDelegate = self;
        self.projectGalleryPicker.isBackup = YES;
        self.projectGalleryPicker.isSharing = NO;
    }
    
    self.projectGalleryPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.projectGalleryPicker animated:YES completion:nil];
}

-(void) didRestoreProjects
{
    if (self.settingsView)
    {
        self.settingsView.delegate = nil;
        self.settingsView = nil;
    }

    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (!self.projectGalleryPicker)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ProjectGalleryStoryboard" bundle:nil];
        self.projectGalleryPicker = [sb instantiateViewControllerWithIdentifier:@"ProjectGalleryPickerController"];
        self.projectGalleryPicker.projectGalleryPickerDelegate = self;
        self.projectGalleryPicker.isBackup = NO;
        self.projectGalleryPicker.isSharing = NO;
    }
    
    self.projectGalleryPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.projectGalleryPicker animated:YES completion:nil];
}


#pragma mark -
#pragma mark - ProjectGalleryPickerControllerDelegate

-(void) projectGalleryPickerControllerDidCancel:(ProjectGalleryPickerController *)picker
{
    [self.projectGalleryPicker dismissViewControllerAnimated:YES completion:^{
        self.projectGalleryPicker = nil;
    }];
}


#pragma mark -
#pragma mark - VideoFiltersViewDelegate

-(void) didCancelVideoFilterUI
{
    [UIView animateWithDuration:0.3f animations:^{
        self.videoFiltersView.frame = CGRectMake(0.0f, self.videoFiltersView.frame.size.height, self.videoFiltersView.frame.size.width, self.videoFiltersView.frame.size.height);
    } completion:^(BOOL finished) {
        self.videoFiltersView.hidden = YES;
    }];
}

-(void) didApplyVideoFilter:(NSURL*) url
{
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    NSString* oldPath = [selectedObject.mediaUrl lastPathComponent];
    NSString* newPath = [url lastPathComponent];
    
    if (![oldPath isEqualToString:newPath])
    {
        unlink([[selectedObject.mediaUrl path] UTF8String]);
        
        selectedObject.mediaUrl = url;

        [self.projectManager saveObjectWithModifiedVideoInfo:selectedObject];

        [selectedObject changeVideoThumbWithFilter];
        
        YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:gnSelectedObjectIndex];
        slider.thumbnailImageView.image = selectedObject.imageView.image;
        
        UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:gnSelectedObjectIndex];
        thumbImageView.image = selectedObject.imageView.image;
        
        [self.timelineView selectTimelineObject:gnSelectedObjectIndex];
        selectedObject.isSelected = YES;
        selectedObject.selectedLineLayer.hidden = NO;
        
        AVAsset *videoAsset = [AVURLAsset assetWithURL:selectedObject.mediaUrl];
        self.playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
        [self.videoPlayer replaceCurrentItemWithPlayerItem:self.playerItem];
        
        [self.playingButton setTag:0];
        [self.playingButton setImage:[UIImage imageNamed:@"NewPlay"] forState:UIControlStateNormal];
        [self.playingButton setEnabled:YES];
        
        self.seekSlider.minimumValue = 0.0;
        self.seekSlider.maximumValue = CMTimeGetSeconds(videoAsset.duration);
        self.seekSlider.value = 0.0;
        [self.seekSlider setEnabled:YES];
        [self.currentSeekTimeLabel setText:@"00:00.000"];
        [self.totalSeekTimeLabel setText:[self timeToString:CMTimeGetSeconds(videoAsset.duration)]];
    }

    [UIView animateWithDuration:0.3f animations:^{
        self.videoFiltersView.frame = CGRectMake(0.0f, self.videoFiltersView.frame.size.height, self.videoFiltersView.frame.size.width, self.videoFiltersView.frame.size.height);
    } completion:^(BOOL finished) {
        self.videoFiltersView.hidden = YES;
    }];
}


#pragma mark -
#pragma mark - FiltersViewDelegate(Photo, Text)

-(void) didCancelFilter
{
    [UIView animateWithDuration:0.3f animations:^{
        self.photoFiltersView.frame = CGRectMake(0.0f, self.photoFiltersView.frame.size.height, self.photoFiltersView.frame.size.width, self.photoFiltersView.frame.size.height);
    } completion:^(BOOL finished) {
        self.photoFiltersView.hidden = YES;
    }];
}

-(void) didApplyFilter:(UIImage*) filteredImage index:(NSInteger) filterIndex value:(float) filterValue
{
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    selectedObject.imageView.image = filteredImage;
    
    selectedObject.photoFilterIndex = filterIndex;
    selectedObject.photoFilterValue = filterValue;
    
    YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:gnSelectedObjectIndex];
    slider.thumbnailImageView.image = filteredImage;
    
    UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:gnSelectedObjectIndex];
    thumbImageView.image = filteredImage;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.photoFiltersView.frame = CGRectMake(0.0f, self.photoFiltersView.frame.size.height, self.photoFiltersView.frame.size.width, self.photoFiltersView.frame.size.height);
    } completion:^(BOOL finished) {
        self.photoFiltersView.hidden = YES;
    }];
}

-(void) didApplyRasterizedFilter:(UIImage*) filteredImage index:(NSInteger) filterIndex value:(float) filterValue
{
    [UIView animateWithDuration:0.3f animations:^{
        self.photoFiltersView.frame = CGRectMake(0.0f, self.photoFiltersView.frame.size.height, self.photoFiltersView.frame.size.width, self.photoFiltersView.frame.size.height);
    } completion:^(BOOL finished) {
        self.photoFiltersView.hidden = YES;
    }];
    
    MediaObjectView* selectedObject = [self.mediaObjectArray objectAtIndex:gnSelectedObjectIndex];
    
    UIGraphicsBeginImageContextWithOptions(selectedObject.textView.bounds.size, NO, 2.0f);
    selectedObject.textView.layer.shadowColor = [UIColor clearColor].CGColor;
    [selectedObject.textView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
    NSString *dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSString* imageName = [NSString stringWithFormat:@"image-%@.png", dateForFilename];
    NSString *fileName = [folderPath stringByAppendingPathComponent:imageName];
    
    [UIImagePNGRepresentation(selectedObject.originalImage) writeToFile:fileName atomically:YES];
    
    CGSize imageSize = CGSizeMake(image.size.width, image.size.height);
    CGSize workspaceSize = CGSizeMake(self.workspaceView.bounds.size.width, self.workspaceView.bounds.size.height);
    
    float rWidth, rHeight;
    float rScaleX = imageSize.width / workspaceSize.width;
    float rScaleY = imageSize.height / workspaceSize.height;
    
    if (rScaleX >= rScaleY)
    {
        rWidth = workspaceSize.width;
        rHeight = imageSize.height * workspaceSize.width / imageSize.width;
    }
    else
    {
        rHeight = workspaceSize.height;
        rWidth = imageSize.width * workspaceSize.height / imageSize.height;
    }
    
    if (gnDefaultOutlineType > 1)
    {
        rWidth = rWidth - grDefaultOutlineWidth * 2.0f;
        rHeight = rHeight - grDefaultOutlineWidth * 2.0f;
    }
    
    image = [image rescaleImageToSize:CGSizeMake(rWidth, rHeight)];
    
    
    MediaObjectView* object = [[MediaObjectView alloc] initWithImage:image frame:CGRectMake((workspaceSize.width - rWidth) / 2, (workspaceSize.height - rHeight) / 2, rWidth, rHeight)];
    object.delegate = self;
    object.imageName = imageName;
    object.imageView.image = filteredImage;
    
    ////////////////////
    CGSize originalSize = image.size;
    CGSize filterSize = filteredImage.size;
    
    CGFloat sX = filterSize.width / originalSize.width;
    CGFloat sY = filterSize.height / originalSize.height;
    
    CGPoint centerPnt = object.center;
    
    object.frame = CGRectMake(object.frame.origin.x, object.frame.origin.y, object.frame.size.width*sX, object.frame.size.height*sY);
    object.mediaView.frame = object.bounds;
    object.imageView.frame = object.bounds;
    object.originalBounds = object.bounds;
    object.center = centerPnt;
    ///////////////////
    
    object.photoFilterIndex = filterIndex;
    object.photoFilterValue = filterValue;

    
    /* remove an old object */
    selectedObject.startActionType = [self.timelineView getStartActionType:gnSelectedObjectIndex];
    selectedObject.mfStartAnimationDuration = [self.timelineView getStartActionTime:gnSelectedObjectIndex];
    selectedObject.endActionType = [self.timelineView getEndActionType:gnSelectedObjectIndex];
    selectedObject.mfEndAnimationDuration = [self.timelineView getEndActionTime:gnSelectedObjectIndex];
    
    object.startActionType = selectedObject.startActionType;
    object.mfStartAnimationDuration = selectedObject.mfStartAnimationDuration;
    object.endActionType = selectedObject.endActionType;
    object.mfEndAnimationDuration = selectedObject.mfEndAnimationDuration;
    object.objectBorderStyle = selectedObject.objectBorderStyle;
    object.objectBorderWidth = selectedObject.objectBorderWidth;
    object.objectBorderColor = selectedObject.objectBorderColor;
    object.objectShadowStyle = selectedObject.objectShadowStyle;
    object.objectShadowBlur = selectedObject.objectShadowBlur;
    object.objectShadowOffset = selectedObject.objectShadowOffset;
    object.objectShadowColor = selectedObject.objectShadowColor;
    object.objectChromaColor = selectedObject.objectChromaColor;
    object.objectChromaTolerance = selectedObject.objectChromaTolerance;
    object.objectChromaNoise = selectedObject.objectChromaNoise;
    object.objectChromaEdges = selectedObject.objectChromaEdges;
    object.objectChromaOpacity = selectedObject.objectChromaOpacity;
    object.objectCornerRadius = selectedObject.objectCornerRadius;
    
    [object applyBorder];
    [object applyShadow];
    
    object.isReflection = selectedObject.isReflection;
    object.reflectionScale = selectedObject.reflectionScale;
    object.reflectionAlpha = selectedObject.reflectionAlpha;
    object.reflectionGap = selectedObject.reflectionGap;
    object.reflectionDelta = selectedObject.reflectionDelta;
    
    [object update];
    
    [self.mediaObjectArray removeObjectAtIndex:gnSelectedObjectIndex];
    [selectedObject removeFromSuperview];
    selectedObject = nil;
    
    /* insert a new object */
    [self.mediaObjectArray insertObject:object atIndex:gnSelectedObjectIndex];
    [object setIndex:gnSelectedObjectIndex];
    [self.workspaceView insertSubview:object atIndex:gnSelectedObjectIndex];
    [object object_actived];
    
    @autoreleasepool
    {
        [self.timelineView addNewTimeLine:object];
        [self.timelineView replaceSlider:gnSelectedObjectIndex];
        [self.timelineView resetTimeline:object.objectIndex obj:object];
    }
    
    YJLVideoRangeSlider* slider = [self.timelineView.sliderArray objectAtIndex:gnSelectedObjectIndex];
    slider.thumbnailImageView.image = filteredImage;
    slider.media_type = MEDIA_PHOTO;
    [slider.thumbnailLabel removeFromSuperview];
    [slider layoutSubviews];
    
    UIImageView* thumbImageView = [self.editThumbnailArray objectAtIndex:gnSelectedObjectIndex];
    [thumbImageView setImage:filteredImage];
    
    if (self.mediaObjectArray.count > 0)
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, self.mediaObjectArray.count*grSliderHeight)];
    else
        [self.verticalBgView setContentSize:CGSizeMake(self.verticalBgView.frame.size.width, grSliderHeight)];
    
    if ((self.mediaObjectArray.count > gnVisibleMaxCount) && (!self.timelineView.hidden))
    {
        self.verticalBgView.hidden = NO;
    }
    
    [self bringGridLayerToFront];
    
    [self checkEditArrowButtons];
}


#pragma mark -
#pragma mark - GIFGalleryPickerControllerDelegate

- (void)gifGalleryPickerController:(GIFGalleryPickerController *)picker didFinishPickingGifPath:(NSString *)gifPath
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddhhmms"];
    NSString* dateForFilename = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSString* gifFileName = [NSString stringWithFormat:@"image-%@.gif", dateForFilename];
    NSString* fileName = [folderPath stringByAppendingPathComponent:gifFileName];
    
    NSData* gifData = [NSData dataWithContentsOfFile:gifPath];
    [gifData writeToFile:fileName atomically:YES];
    
    /* generate imageView from GIF */
    [self generationGIFImageView:gifFileName];
    
    [self.gifGalleryPickerController dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.gifGalleryPickerController = nil;
    }];
    
    [self updateObjectEdit];
}

- (void)gifGalleryPickerControllerDidCancel:(GIFGalleryPickerController *)picker
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.gifGalleryPickerController dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.gifGalleryPickerController = nil;
    }];
}


- (void)gifGalleryPickerController:(GIFGalleryPickerController *)picker failedWithError:(NSError *)error
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.gifGalleryPickerController dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.gifGalleryPickerController = nil;
    }];
}

#pragma mark -
#pragma mark - Music WebView

- (void)musicDownloadControllerDidCancel:(MusicDownloadController *)picker
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.musicDownloadController dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.musicDownloadController = nil;
    }];
}

- (void)goToLibraryFromMusicDownloadController:(MusicDownloadController *)picker
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.musicDownloadController dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.musicDownloadController = nil;
        if (self.customModalView != nil)
        {
            [self.customModalView hideCustomModalView];
            self.customModalView = nil;
        }
        
        if (!self.musicPicker)
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"YJLCustomMusicPickerStoryboard" bundle:nil];
            self.musicPicker = [sb instantiateViewControllerWithIdentifier:@"YJLCustomMusicController"];
            self.musicPicker.customMusicDelegate = self;
        }
        
        self.musicPicker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:self.musicPicker animated:YES completion:nil];
    }];
}

- (void)importSong:(MusicDownloadController *)picker asset:(NSURL *)assetUrl
{
    [self.musicDownloadController dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.musicDownloadController = nil;
        [self musicPickerControllerDidSelected:(YJLCustomMusicController *)picker asset:(NSURL *)assetUrl];
    }];
}

-(void) goToLibrary{
    if (self.customModalView != nil)
    {
        [self.customModalView hideCustomModalView];
        self.customModalView = nil;
    }
    
    if (!self.musicPicker)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"YJLCustomMusicPickerStoryboard" bundle:nil];
        self.musicPicker = [sb instantiateViewControllerWithIdentifier:@"YJLCustomMusicController"];
        self.musicPicker.customMusicDelegate = self;
    }
    
    self.musicPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.musicPicker animated:YES completion:nil];
}

- (void)musicSiteDidSelected:(MusicDownload *)picker
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.musicDownload dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.musicDownload = nil;
        [self actionGoToFreeBackgroundMusic];
    }];
}

- (void)musicDownloadDidSelectWiFi:(MusicDownload *)picker {
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.musicDownload dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.musicDownload = nil;
        [self actionDownloadFromWiFi];
    }];
}

- (void)musicDownloadDidCancel:(MusicDownload *)picker
{
    [self fixAppOrientationAfterDismissImagePickerController];
    
    [self.musicDownload dismissViewControllerAnimated:YES completion:^{
        [[SHKActivityIndicator currentIndicator] hide];
        self.musicDownload = nil;
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
