//
//  SelectTemplateVC.m
//  VideoFrame
//
//  Created by Yinjing Li on 11/13/13.
//  Copyright (c) 2013 Yinjing Li and Fredercik Weber. All rights reserved.
//

#import "SelectTemplateVC.h"

#import "Definition.h"
#import "MakeVideoVC.h"
#import "TermsVC.h"
#import "SettingsView.h"
#import "CustomModalView.h"
#import "ProjectManager.h"
#import "ProjectThumbView.h"
#import "SHKActivityIndicator.h"
#import "iCarousel.h"
#import "CustomAssetPickerController.h"
#import "YJLActionMenu.h"
#import "ProjectGalleryPickerController.h"
#import "MyCloudDocument.h"
#import "SSZipArchive.h"
#import "MusicDownloadController.h"
#import "MusicDownload.h"
#import "MediaTrimView.h"
#import "AppDelegate.h"
#import "SceneDelegate.h"
#import <MessageUI/MessageUI.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface SelectTemplateVC () <CustomModalViewDelegate, ProjectThumbViewDelegate, UIGestureRecognizerDelegate, iCarouselDelegate, iCarouselDataSource, CustomAssetPickerControllerDelegate, UINavigationControllerDelegate, SettingsViewDelegate, ProjectGalleryPickerControllerDelegate, UIAlertViewDelegate, MusicDownloadControllerDelegate, MusicDownloadDelegate, YJLCustomMusicControllerDelegate, MediaTrimViewDelegate, MFMailComposeViewControllerDelegate>

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacing;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *topSpacing;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *iphoneInstagramWidth;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *iPadPortraitCenterX;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *iPhonePortraitCenterX;
@property float deltaX;
@property float deltaY;
@property float orgY;
@property float instagramOriX;
@end


@implementation SelectTemplateVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    _fTopSpacingConstant_iPhonePortrait = 80.0f;
    _fBottomSpacingConstant_iPhonePortrait = 80.0f;
    _fInstagramWidthConstant_iPhonePortrait = 80.0f;
    _fPortraitCenterConstant_iPhonePortrait = -5.0f;
    
    _fTopSpacingConstant_iPhoneLadscape = 20.0f;
    _fBottomSpacingConstant_iPhoneLadscape = 20.0f;
    _fInstagramWidthConstant_iPhoneLadscape = 100.0f;
    _fPortraitCenterConstant_iPhoneLadscape = 0.0f;
    
    _fPortraitCenterConstant_iPadPortrait = 15.0f;
    _fPortraitCenterConstant_iPadLadscape = 0.0f;

    _deltaX = 15.0f;
    _instagramOriX = self.tempInstagramButton.center.x;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    //check bundle build version
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@", build];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [tapGesture setNumberOfTapsRequired:1];
    
    //detect Max FrameRate from Device
    [self detectFramePerSec];
    
    self.playButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.playButton.layer.borderWidth = 2.0f;
    self.playButton.layer.cornerRadius = self.playButton.bounds.size.width/2.0f;
    self.playButton.clipsToBounds = YES;
    
    _orgY = _savedProjectLabel.frame.origin.y;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedProject:)
                                                 name:@"ReceivedProjectNotification"
                                               object:nil];
    
    /*NSArray *interFaceNames = (__bridge_transfer id)CNCopySupportedInterfaces();

    for (NSString *name in interFaceNames) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)name);

        NSLog(@"wifi info: bssid: %@, ssid:%@, ssidData: %@", info[@"BSSID"], info[@"SSID"], info[@"SSIDDATA"]);
    }*/
}

- (void) checkSampleProjects
{
    
    NSMutableArray* sampleProjectNamesArray = [[NSMutableArray alloc] init];
    [sampleProjectNamesArray addObject:@"Sample#1"];
    [sampleProjectNamesArray addObject:@"Sample#2"];
    [sampleProjectNamesArray addObject:@"Sample#3"];
    [sampleProjectNamesArray addObject:@"Sample#4"];

    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    for (int i = 0; i < sampleProjectNamesArray.count; i++)
    {
        NSString* projectName = [sampleProjectNamesArray objectAtIndex:i];
        NSString* projectPath = [documentsPath stringByAppendingPathComponent:projectName];

        if (![localFileManager fileExistsAtPath:projectPath])
        {
            NSString* zipFileName = [projectName stringByAppendingString:@".zip"];
            NSString *zipFilePath = [[NSBundle mainBundle] pathForResource:[zipFileName stringByDeletingPathExtension] ofType:[zipFileName pathExtension] inDirectory:nil];

            @autoreleasepool
            {
                [SSZipArchive unzipFileAtPath:zipFilePath toDestination:documentsPath];
            }
        }
    }

    [sampleProjectNamesArray removeAllObjects];
    sampleProjectNamesArray = nil;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //NSLog(@"%f, %f", self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Loading...", nil)) isLock:YES];

    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.makeVideoVC = nil;
    
    isDeleteButtonShow = NO;
    isWorkspace = NO;
    
    UIInterfaceOrientation orientation = [UIApplication orientation];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
            
            _topSpacing.constant = _fTopSpacingConstant_iPhonePortrait;
            _bottomSpacing.constant = _fBottomSpacingConstant_iPhonePortrait;
            _iphoneInstagramWidth.constant = _fInstagramWidthConstant_iPhonePortrait;
            _iPhonePortraitCenterX.constant = -_fPortraitCenterConstant_iPhonePortrait;
            
        }
        else
        {
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateNormal];
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateSelected];

            _topSpacing.constant = _fTopSpacingConstant_iPhoneLadscape;
            _bottomSpacing.constant = _fBottomSpacingConstant_iPhoneLadscape;
            _iphoneInstagramWidth.constant = _fInstagramWidthConstant_iPhoneLadscape;
            _iPhonePortraitCenterX.constant = _fPortraitCenterConstant_iPhoneLadscape;
        }
    }
    else
    {
#if TARGET_OS_MACCATALYST
        if (self.view.frame.size.width == SCREEN_FRAME_PORTRAIT.size.width) {
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
            
            _iPadPortraitCenterX.constant = _fPortraitCenterConstant_iPadPortrait;
        } else {
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateNormal];
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateSelected];
            
            _iPadPortraitCenterX.constant = _fPortraitCenterConstant_iPadLadscape;
        }
#else
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
            
            _iPadPortraitCenterX.constant = _fPortraitCenterConstant_iPadPortrait;
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
        {
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateNormal];
            [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateSelected];
            
            _iPadPortraitCenterX.constant = _fPortraitCenterConstant_iPadLadscape;
        }
#endif
    }
    
    // init Settings View
    if (!self.settingsView)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            CGSize result = [UIScreen mainScreen].bounds.size;
            float width = result.width;
            float height  = result.height;
            
            if (width > 730 || height > 730 ) {
                self.settingsView = [[[NSBundle mainBundle] loadNibNamed:@"SettingsView_iPad" owner:self options:nil] objectAtIndex:0];
            } else {
                self.settingsView = [[[NSBundle mainBundle] loadNibNamed:@"SettingsView" owner:self options:nil] objectAtIndex:0];
            }
        }
        else
            self.settingsView = [[[NSBundle mainBundle] loadNibNamed:@"SettingsView_iPad" owner:self options:nil] objectAtIndex:0];

        [self.settingsView initSettingsView];
        self.settingsView.delegate = self;
    }
    
    [self checkSampleProjects];

    // get saved Projects
    [self getProjects];
    
    //check iCloud`s last updated date
    [self checkCloudsLastUpdateDate];
    /*
    NSString *message = [NSString stringWithFormat:@"%@", [AppDelegate sharedDelegate].launchOptions];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:APP_ALERT_TITLE message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:controller animated:YES completion:nil];*/
    
    [[SHKActivityIndicator currentIndicator] hide];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if( gnOutputQuality == OUTPUT_UHD )
        self.outputLbl.text = NSLocalizedString(@"UHD OUTPUT", nil);
    else if( gnOutputQuality == OUTPUT_HD )
        self.outputLbl.text = NSLocalizedString(@"HD OUTPUT", nil);
    else if ( gnOutputQuality == OUTPUT_UNIVERSAL )
        self.outputLbl.text = NSLocalizedString(@"UNIVERSAL", nil);
    else if( gnOutputQuality == OUTPUT_SDTV )
        self.outputLbl.text = NSLocalizedString(@"SDTV OUTPUT", nil);
}


#pragma mark -
#pragma mark - orientation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
                                    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // what ever you want to prepare
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        UIInterfaceOrientation toInterfaceOrientation = [UIApplication orientation];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
                self.tempInstagramButton.frame = CGRectMake(self.tempInstagramButton.frame.origin.x, self.tempInstagramButton.frame.origin.y, 92.0f, 122.0f);

                self.topSpacing.constant = self.fTopSpacingConstant_iPhonePortrait;
                self.bottomSpacing.constant = self.fBottomSpacingConstant_iPhonePortrait;
                self.iphoneInstagramWidth.constant = self.fInstagramWidthConstant_iPhonePortrait;
                self.iPhonePortraitCenterX.constant = -self.fPortraitCenterConstant_iPhonePortrait;
            }
            else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateNormal];
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateSelected];
                self.tempInstagramButton.frame = CGRectMake(self.tempInstagramButton.frame.origin.x, self.tempInstagramButton.frame.origin.y, 132.0f, 112.0f);

                self.topSpacing.constant = self.fTopSpacingConstant_iPhoneLadscape;
                self.bottomSpacing.constant = self.fBottomSpacingConstant_iPhoneLadscape;
                self.iphoneInstagramWidth.constant = self.fInstagramWidthConstant_iPhoneLadscape;
                self.iPhonePortraitCenterX.constant = self.fPortraitCenterConstant_iPhoneLadscape;
            }
        }
        else
        {
#if TARGET_OS_MACCATALYST
            if (self.view.frame.size.width == SCREEN_FRAME_PORTRAIT.size.width)
            {
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
                self.tempInstagramButton.frame = CGRectMake(self.tempInstagramButton.frame.origin.x, self.tempInstagramButton.frame.origin.y, 184.0f, 243.0f);

                self.iPadPortraitCenterX.constant = self.fPortraitCenterConstant_iPadPortrait;
            }
            else
            {
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateNormal];
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateSelected];
                self.tempInstagramButton.frame = CGRectMake(self.tempInstagramButton.frame.origin.x, self.tempInstagramButton.frame.origin.y, 220.0f, 210.0f);

                self.iPadPortraitCenterX.constant = self.fPortraitCenterConstant_iPadLadscape;
            }
#else
            if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateNormal];
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"instagram"] forState:UIControlStateSelected];
                self.tempInstagramButton.frame = CGRectMake(self.tempInstagramButton.frame.origin.x, self.tempInstagramButton.frame.origin.y, 184.0f, 243.0f);

                self.iPadPortraitCenterX.constant = self.fPortraitCenterConstant_iPadPortrait;
            }
            else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateNormal];
                [self.tempInstagramButton setImage:[UIImage imageNamed:@"1080p"] forState:UIControlStateSelected];
                self.tempInstagramButton.frame = CGRectMake(self.tempInstagramButton.frame.origin.x, self.tempInstagramButton.frame.origin.y, 220.0f, 210.0f);

                self.iPadPortraitCenterX.constant = self.fPortraitCenterConstant_iPadLadscape;
            }
#endif
        }

        if (self.customModalView)
        {
            [self.customModalView hideCustomModalView];
            self.customModalView = nil;
        }

        if (self.settingsView != nil)
        {
            [self.settingsView hideActionSettingsView];
        }
    }];
}


#pragma mark -
#pragma mark - get device`s supported frame rate

- (void) detectFramePerSec
{
    
    grFrameRate = 30.0f;
    
    CGFloat maxRate = 30.0f;
    
    AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    for (AVCaptureDeviceFormat *vFormat in [videoDevice formats]) {
        CGFloat frameRate = ((AVFrameRateRange *)[vFormat.videoSupportedFrameRateRanges objectAtIndex:0]).maxFrameRate;

        if (frameRate > maxRate)
            maxRate = frameRate;
    }
    
    if (maxRate > 60.0f)
        grFrameRate = 60.0f;
    else if(maxRate > 30.0f)
        grFrameRate = 40.0f;
    else
        grFrameRate = 30.0f;
}


#pragma mark -
#pragma mark - Projects Processing

- (void) getProjects {
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;

    NSError *error;
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString* documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    NSArray* sortedFiles = nil;
    
    if (filesArray.count > 0) {
        NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
        
        for (NSString* file in filesArray) {
            error = nil;

            NSString* filePath = [documentsPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:filePath
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            
            if(error == nil) {
                [filesAndProperties addObject:@{@"path": file,
                                                @"lastModDate": modDate}];
            }
        }
        
        sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                                ^(id path1, id path2)
                                {
                                    NSComparisonResult comp = [[path2 objectForKey:@"lastModDate"] compare:
                                                               [path1 objectForKey:@"lastModDate"]];
                                    if (comp == NSOrderedDescending)
                                        comp = NSOrderedAscending;
                                    else if(comp == NSOrderedAscending)
                                        comp = NSOrderedDescending;

                                    return comp;
                                }];
    }
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    self.projectNamesArray = [[NSMutableArray alloc] init];

    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;
    self.projectThumbViewArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < sortedFiles.count; i++) {
        NSDictionary* dict = [sortedFiles objectAtIndex:i];

        NSString* projectName = [dict objectForKey:@"path"];
        NSString* projectPath = [documentsPath stringByAppendingPathComponent:projectName];
        NSString* filePath = [projectPath stringByAppendingPathComponent:@"screenshot.png"];
        
        UIImage* screenshotImage = [UIImage imageWithContentsOfFile:filePath];
        
        if (screenshotImage) {
            [self.projectNamesArray addObject:[dict objectForKey:@"path"]];

            CGSize thumbSize = CGSizeMake(self.projectView.bounds.size.height*0.9f * 2.0f, self.projectView.bounds.size.height*0.9f);
            
            ProjectThumbView* thumbView = [[ProjectThumbView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, thumbSize.width, thumbSize.height) caption:projectName name:projectName image:screenshotImage];
            [thumbView setDelegate:self];
            
            [self.projectThumbViewArray addObject:thumbView];
        } else {
            NSLog(@"%@", projectPath);
            [localFileManager removeItemAtPath:projectPath error:&error ];
            continue;
        }
    }
    
    localFileManager = nil;
    
    
    //Project Carousel

    if (!self.projectCarousel) {
        self.projectCarousel = [[iCarousel alloc] initWithFrame:self.projectView.bounds];
        self.projectCarousel.delegate = self;
        self.projectCarousel.dataSource = self;
        self.projectCarousel.backgroundColor = [UIColor clearColor];
        self.projectCarousel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.projectView addSubview:self.projectCarousel];
    }

    if (self.projectThumbViewArray.count > 5)
        self.projectCarousel.type = iCarouselTypeCylinder;
    else
        self.projectCarousel.type = iCarouselTypeCoverFlow;

    [self.projectCarousel reloadData];
    
    if (self.projectThumbViewArray.count == 0)
        self.savedProjectLabel.hidden = YES;
    else
        self.savedProjectLabel.hidden = NO;
    
}

-(void) tapGesture:(UITapGestureRecognizer*) gesture
{
    [self actionProjectDeleteDesabled];
}

-(void) actionProjectDeleteDesabled
{
    isDeleteButtonShow = NO;

    for (int i = 0; i < self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        thumbView.deleteButton.hidden = YES;
        [thumbView.thumbImageView setUserInteractionEnabled:YES];
        [thumbView vibrateDesable];
    }
}


#pragma mark - 
#pragma mark - ProjectThumbViewDelegate

-(void) selectedProject:(NSString*) projectName
{
    gstrCurrentProjectName = [projectName copy];
    
    [[SHKActivityIndicator currentIndicator] displayActivity:(NSLocalizedString(@"Opening...", nil)) isLock:YES];

    [self performSelector:@selector(openProject) withObject:nil afterDelay:0.02f];
}

-(void) deleteProject:(NSString*) projectName
{
    NSError *error;
    
    //delete project on the local directory
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* projectPath = [docsDir stringByAppendingPathComponent:projectName];
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    [localFileManager removeItemAtPath:projectPath error:&error ];
    
    //delete project on the array
    for (int i = 0; i < self.projectNamesArray.count; i++)
    {
        NSString* name = [self.projectNamesArray objectAtIndex:i];
        
        if ([projectName isEqualToString:name])
        {
            [self.projectNamesArray removeObjectAtIndex:i];
            
            ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
            [thumbView removeFromSuperview];
            [self.projectThumbViewArray removeObjectAtIndex:i];
            
            break;
        }
    }
    
    [localFileManager release];
    
    if (self.projectThumbViewArray.count > 5)
        self.projectCarousel.type = iCarouselTypeCylinder;
    else
        self.projectCarousel.type = iCarouselTypeCoverFlow;
    
    [self.projectCarousel reloadData];
}

-(void) actionProjectDeleteEnabled
{
    isDeleteButtonShow = YES;
    
    if (self.projectThumbViewArray.count == 0)
        isDeleteButtonShow = NO;
    
    for (int i = 0; i < self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        thumbView.deleteButton.hidden = NO;
        [thumbView.thumbImageView setUserInteractionEnabled:NO];
        [thumbView vibrateEnable];
    }
}


#pragma mark -
#pragma mark - open project

-(void) openProject
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    
    NSString *folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *folderPath = [folderDir stringByAppendingPathComponent:gstrCurrentProjectName];
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"project.plist"];
    
    if ([localFileManager fileExistsAtPath:plistFileName])
    {
        NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
        
        gnOrientation = [[plistDict objectForKey:@"gnOrientation"] intValue];
        gnInstagramOrientation = [[plistDict objectForKey:@"gnInstagramOrientation"] intValue];
        gnTemplateIndex = [[plistDict objectForKey:@"gnTemplateIndex"] intValue];
        
        if ((gnOrientation == ORIENTATION_LANDSCAPE) && (gnTemplateIndex == TEMPLATE_LANDSCAPE))
        {
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                gnVisibleMaxCount = 6;
            else
                gnVisibleMaxCount = 12;
        }
        else if ((gnOrientation == ORIENTATION_PORTRAIT) && (gnTemplateIndex == TEMPLATE_PORTRAIT))
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (isIPhoneFive)
                    gnVisibleMaxCount = 13;
                else
                    gnVisibleMaxCount = 10;
            }
            else
            {
                gnVisibleMaxCount = 17;
            }
        }
        else if ((gnOrientation == ORIENTATION_PORTRAIT) && (gnTemplateIndex == TEMPLATE_SQUARE))
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (isIPhoneFive)
                    gnVisibleMaxCount = 13;
                else
                    gnVisibleMaxCount = 10;
            }
            else
            {
                gnVisibleMaxCount = 17;
            }
        }
        else if ((gnOrientation == ORIENTATION_LANDSCAPE) && (gnTemplateIndex == TEMPLATE_1080P))
        {
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                gnVisibleMaxCount = 6;
            else
                gnVisibleMaxCount = 12;
        }
        
        [localFileManager release];
        [plistDict release];
    }
    else
    {
        [localFileManager release];
        
        [[SHKActivityIndicator currentIndicator] hide];

        return;
    }
    
    [self actionProjectDeleteDesabled];
    
    [self.customModalView hideCustomModalView];
    self.customModalView = nil;
    
    for (int i = 0; i < self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        [thumbView removeFromSuperview];
        thumbView = nil;
    }
    
    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    
    [self.projectCarousel removeFromSuperview];
    self.projectCarousel = nil;

    [self fixDeviceOrientation];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
    else
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:self.makeVideoVC animated:NO];
}


-(void) fixDeviceOrientation
{
    UIInterfaceOrientation orientation = [UIApplication orientation];

    if ((orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)&&(gnTemplateIndex == TEMPLATE_LANDSCAPE || gnTemplateIndex == TEMPLATE_1080P))
    {
        //[[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    else if ((orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)&&(gnTemplateIndex == TEMPLATE_PORTRAIT || gnTemplateIndex == TEMPLATE_SQUARE))
    {
        //[[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
}


#pragma mark -
#pragma mark - Select a template size

- (IBAction)onDidSelectTemplate:(id)sender
{
    [self actionProjectDeleteDesabled];

    [self.customModalView hideCustomModalView];
    self.customModalView = nil;
    
    UIInterfaceOrientation orientation = [UIApplication orientation];

    switch ([sender tag])
    {
        case 1://landscape
            gnOrientation = ORIENTATION_LANDSCAPE;
            gnTemplateIndex = TEMPLATE_LANDSCAPE;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                gnVisibleMaxCount = 6;
            else
                gnVisibleMaxCount = 12;
#if TARGET_OS_MACCATALYST
            [UIApplication updateScreenSize:gnOrientation];
            [AppDelegate sharedDelegate].customWindow.frame = SCREEN_FRAME_LANDSCAPE;
            [AppDelegate sharedDelegate].navigationController.view.frame = SCREEN_FRAME_LANDSCAPE;
            [SceneDelegate sharedDelegate].window.frame = SCREEN_FRAME_LANDSCAPE;
            [SceneDelegate sharedDelegate].navigationController.view.frame = SCREEN_FRAME_LANDSCAPE;
#endif
            break;
            
        case 2://portrait
            gnOrientation = ORIENTATION_PORTRAIT;
            gnTemplateIndex = TEMPLATE_PORTRAIT;
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            {
                if (isIPhoneFive)
                    gnVisibleMaxCount = 13;
                else
                    gnVisibleMaxCount = 10;
            }
            else
            {
                gnVisibleMaxCount = 17;
            }
#if TARGET_OS_MACCATALYST
            [UIApplication updateScreenSize:gnOrientation];
            [AppDelegate sharedDelegate].customWindow.frame = SCREEN_FRAME_PORTRAIT;
            [AppDelegate sharedDelegate].navigationController.view.frame = SCREEN_FRAME_PORTRAIT;
            [SceneDelegate sharedDelegate].window.frame = SCREEN_FRAME_PORTRAIT;
            [SceneDelegate sharedDelegate].navigationController.view.frame = SCREEN_FRAME_PORTRAIT;
#endif

            break;
            
        case 3://square or 1080p
            if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                gnOrientation = ORIENTATION_PORTRAIT;
                gnInstagramOrientation = ORIENTATION_PORTRAIT;
                gnTemplateIndex = TEMPLATE_SQUARE;
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                {
                    if (isIPhoneFive)
                        gnVisibleMaxCount = 13;
                    else
                        gnVisibleMaxCount = 10;
                }
                else
                {
                    gnVisibleMaxCount = 17;
                }
            }
            else if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
            {
                gnOrientation = ORIENTATION_LANDSCAPE;
                gnInstagramOrientation = ORIENTATION_LANDSCAPE;
                gnTemplateIndex = TEMPLATE_1080P;
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    gnVisibleMaxCount = 6;
                else
                    gnVisibleMaxCount = 12;
            }
            
#if TARGET_OS_MACCATALYST
            if (self.view.frame.size.width < self.view.frame.size.height) {
                gnOrientation = ORIENTATION_PORTRAIT;
                gnInstagramOrientation = ORIENTATION_PORTRAIT;
                gnTemplateIndex = TEMPLATE_SQUARE;
                
                [UIApplication updateScreenSize:gnOrientation];
                [AppDelegate sharedDelegate].customWindow.frame = SCREEN_FRAME_PORTRAIT;
                [AppDelegate sharedDelegate].navigationController.view.frame = SCREEN_FRAME_PORTRAIT;
                [SceneDelegate sharedDelegate].window.frame = SCREEN_FRAME_PORTRAIT;
                [SceneDelegate sharedDelegate].navigationController.view.frame = SCREEN_FRAME_PORTRAIT;
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                {
                    if (isIPhoneFive)
                        gnVisibleMaxCount = 13;
                    else
                        gnVisibleMaxCount = 10;
                }
                else
                {
                    gnVisibleMaxCount = 17;
                }
            }
            else
            {
                gnOrientation = ORIENTATION_LANDSCAPE;
                gnInstagramOrientation = ORIENTATION_LANDSCAPE;
                gnTemplateIndex = TEMPLATE_1080P;
                
                [UIApplication updateScreenSize:gnOrientation];
                [AppDelegate sharedDelegate].customWindow.frame = SCREEN_FRAME_LANDSCAPE;
                [AppDelegate sharedDelegate].navigationController.view.frame = SCREEN_FRAME_LANDSCAPE;
                [SceneDelegate sharedDelegate].window.frame = SCREEN_FRAME_LANDSCAPE;
                [SceneDelegate sharedDelegate].navigationController.view.frame = SCREEN_FRAME_LANDSCAPE;
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    gnVisibleMaxCount = 6;
                else
                    gnVisibleMaxCount = 12;
            }
#endif
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i < self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        [thumbView removeFromSuperview];
        thumbView = nil;
    }
    
    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;

    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;

    [self.projectCarousel removeFromSuperview];
    self.projectCarousel = nil;

    gstrCurrentProjectName = nil;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
    else
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:self.makeVideoVC animated:NO];
}


#pragma mark - 
#pragma mark - Settings Button Click Event

- (IBAction)onSettings:(id)sender
{
    [self actionProjectDeleteDesabled];

    [self.customModalView hideCustomModalView];
    self.customModalView = nil;
    
    [self.settingsView updateSettings];
    
    self.customModalView = [[CustomModalView alloc] initWithView:self.settingsView isCenter:YES];
    self.customModalView.delegate = self;
    self.customModalView.dismissButtonRight = YES;
    [self.customModalView show];
}


#pragma mark -
#pragma mark - Info Button Click Event

- (IBAction)onInfo:(id)sender
{
    [self actionProjectDeleteDesabled];
    
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
      
      ];
    
    [YJLActionMenu showMenuInView:self.navigationController.view
                         fromRect:self.infoButton.frame
                        menuItems:menuItems isWhiteBG:NO];
}

-(void) actionInfoVideo
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"VideoDreamTutorial" ofType:@"mp4" inDirectory:nil];
    NSURL *movieURL = [NSURL fileURLWithPath:path];
    
    if (self.infoVideoPlayer)
    {
        [self.infoVideoPlayer.player pause];
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

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) actionHowToRemoveICloud
{
    NSString* path = @"http://support.apple.com/kb/PH12794";
    NSURL* url = [NSURL URLWithString:path];

    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

-(void) actionGoToDreamSite
{
    NSString* path = @"http://www.dreamclouds.net/";
    NSURL* url = [NSURL URLWithString:path];
    
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

-(IBAction)actionTermsAndPrivacy:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TermsVC" bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"TermsVC"];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
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
        gnOrientation = ORIENTATION_ALL;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }];
}


#pragma mark -
#pragma mark - Play Saved Video

-(IBAction)actionPlaySavedVideo:(id)sender
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied)
    {
        [self showAlertViewController:NSLocalizedString(@"Video Dreamer is unable to access Camera Roll", nil) message:NSLocalizedString(@"To enable access to the Camera Roll, follow these steps:\r\n Go to: Settings -> Privacy -> Photos and turn ON access for Video Dreamer.", nil) okHandler:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }];
        return;
    }
    
    UIInterfaceOrientation orientation = [UIApplication orientation];

    if (UIInterfaceOrientationIsPortrait(orientation))
        gnOrientation = ORIENTATION_PORTRAIT;
    else if (UIInterfaceOrientationIsLandscape(orientation))
        gnOrientation = ORIENTATION_LANDSCAPE;
    
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


#pragma mark - 
#pragma mark - iCarousel

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.projectThumbViewArray.count;
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
    
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (self.projectThumbViewArray.count > 0)
    {
        if (view == nil)
        {
            ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:index];
            
            view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.projectView.bounds.size.height*2.0f, self.projectView.bounds.size.height)];
            view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
            view.layer.borderColor = [UIColor whiteColor].CGColor;
            view.layer.borderWidth = 1.0f;
            view.layer.cornerRadius = 5.0f;
            view.contentMode = UIViewContentModeScaleToFill;
            view.userInteractionEnabled = YES;
            [view addSubview:thumbView];
            
            thumbView.frame = CGRectMake((view.bounds.size.width - thumbView.bounds.size.width)/2.0f, (view.bounds.size.height-thumbView.bounds.size.height)/2.0f, thumbView.bounds.size.width, thumbView.bounds.size.height);
        }
    }
    else
    {
        return nil;
    }
    
    return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (self.projectThumbViewArray.count > 0)
    {
        if (view == nil)
        {
            ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:index];
            
            view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.projectView.bounds.size.height*2.0f, self.projectView.bounds.size.height)];
            view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
            view.layer.borderColor = [UIColor whiteColor].CGColor;
            view.layer.borderWidth = 1.0f;
            view.layer.cornerRadius = 5.0f;
            view.contentMode = UIViewContentModeScaleToFill;
            view.userInteractionEnabled = YES;
            [view addSubview:thumbView];
            
            thumbView.frame = CGRectMake((view.bounds.size.width-thumbView.bounds.size.width)/2.0f, (view.bounds.size.height-thumbView.bounds.size.height)/2.0f, thumbView.bounds.size.width, thumbView.bounds.size.height);
        }
    }
    else
    {
        return nil;
    }
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);

    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * _carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return YES;
        }
        case iCarouselOptionSpacing:
        {
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (_carousel.type == iCarouselTypeCustom)
                return 0.0f;

            return value;
        }
        default:
        {
            return value;
        }
    }
}


#pragma mark -
#pragma mark - CustomAssetPickerControllerDelegate

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    dispatch_async(dispatch_get_main_queue(), ^{

        self.openInProjectVideoAsset = [assets objectAtIndex:0];

        [self.customAssetPicker dismissViewControllerAnimated:NO completion:^{
            self.customAssetPicker = nil;
            
            [[SHKActivityIndicator currentIndicator] hide];
        }];

        gnOrientation = ORIENTATION_LANDSCAPE;
        gnInstagramOrientation = ORIENTATION_LANDSCAPE;
        gnTemplateIndex = TEMPLATE_1080P;
        
        UIInterfaceOrientation orientation = [UIApplication orientation];
        
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
        }

        [self performSelector:@selector(openInProjectWithVideo) withObject:nil afterDelay:0.5f];
    });
}

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker didFinishPickingMovies:(NSArray *)movies
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        MPMediaItemCollection* item = [movies objectAtIndex:0];
        
        MPMediaItem *representativeItem = [item representativeItem];
        self.openInProjectVideoUrl = [representativeItem valueForProperty:MPMediaItemPropertyAssetURL];
        
        [self.customAssetPicker dismissViewControllerAnimated:NO completion:^{
            self.customAssetPicker = nil;
            
            [[SHKActivityIndicator currentIndicator] hide];
        }];
        
        gnOrientation = ORIENTATION_LANDSCAPE;
        gnInstagramOrientation = ORIENTATION_LANDSCAPE;
        gnTemplateIndex = TEMPLATE_1080P;
        
        UIInterfaceOrientation orientation = [UIApplication orientation];
        
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        }
        
        [self performSelector:@selector(openInProjectWithMovie) withObject:nil afterDelay:0.5f];
    });
}

-(void) openInProjectWithVideo
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        gnVisibleMaxCount = 6;
    else
        gnVisibleMaxCount = 12;
    
    for (int i = 0; i < self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        [thumbView removeFromSuperview];
        thumbView = nil;
    }
    
    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    
    [self.projectCarousel removeFromSuperview];
    self.projectCarousel = nil;

    gstrCurrentProjectName = nil;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.openInProjectVideoAsset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        
        if ([avAsset isKindOfClass:[AVURLAsset class]]) //normal video
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.openInProjectVideoUrl = [(AVURLAsset*)avAsset URL];
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                    self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
                else
                    self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
                
                self.makeVideoVC.openInProjectVideoUrl = self.openInProjectVideoUrl;
                
                [self.navigationController pushViewController:self.makeVideoVC animated:NO];
                
            });
        }
        else  //Slow-Mo video
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:self.openInProjectVideoAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                    
                    self.openInProjectVideoUrl = [info objectForKey:@"PHImageFileURLKey"];
                    
                    if (self.openInProjectVideoUrl)
                    {
                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                            self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
                        else
                            self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
                        
                        self.makeVideoVC.openInProjectVideoUrl = self.openInProjectVideoUrl;
                        
                        [self.navigationController pushViewController:self.makeVideoVC animated:NO];
                    }
                }];
            });
        }
        
    }];
}


- (void)openInProjectWithMovie
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        gnVisibleMaxCount = 6;
    else
        gnVisibleMaxCount = 12;
    
    for (int i = 0; i < self.projectThumbViewArray.count; i++)
    {
        ProjectThumbView* thumbView = [self.projectThumbViewArray objectAtIndex:i];
        [thumbView removeFromSuperview];
        thumbView = nil;
    }
    
    [self.projectThumbViewArray removeAllObjects];
    self.projectThumbViewArray = nil;
    
    [self.projectNamesArray removeAllObjects];
    self.projectNamesArray = nil;
    
    [self.projectCarousel removeFromSuperview];
    self.projectCarousel = nil;

    gstrCurrentProjectName = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC" bundle:nil];
    else
        self.makeVideoVC = [[MakeVideoVC alloc] initWithNibName:@"MakeVideoVC_iPad" bundle:[NSBundle mainBundle]];
    
    self.makeVideoVC.openInProjectVideoUrl = self.openInProjectVideoUrl;
    
    [self.navigationController pushViewController:self.makeVideoVC animated:NO];
}


- (void)customAssetsPickerControllerDidCancel:(CustomAssetPickerController *)picker
{
    [self.customAssetPicker dismissViewControllerAnimated:YES completion:^{
        self.customAssetPicker = nil;
        gnOrientation = ORIENTATION_ALL;
    }];
}

- (void)customAssetsPickerController:(CustomAssetPickerController *)picker failedWithError:(NSError *)error
{
    gnOrientation = ORIENTATION_ALL;
}


#pragma mark - 
#pragma mark - SettingsViewDelegate

- (void) didBackupProjects
{
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


- (void) didSelectedOutput:(int)idx
{
    if( idx == OUTPUT_UHD )
        self.outputLbl.text = NSLocalizedString(@"UHD OUTPUT", nil);
    else if( idx == OUTPUT_HD )
        self.outputLbl.text = NSLocalizedString(@"HD OUTPUT", nil);
    else if ( idx == OUTPUT_UNIVERSAL )
        self.outputLbl.text = NSLocalizedString(@"UNIVERSAL", nil);
    else if( idx == OUTPUT_SDTV )
        self.outputLbl.text = NSLocalizedString(@"SDTV OUTPUT", nil);
}


#pragma mark -
#pragma mark - ProjectGalleryPickerControllerDelegate

-(void) projectGalleryPickerControllerDidCancel:(ProjectGalleryPickerController *)picker
{
    [self.projectGalleryPicker dismissViewControllerAnimated:YES completion:^{
        self.projectGalleryPicker = nil;
    }];
}

-(void) checkCloudsLastUpdateDate
{
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* plistFolderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSString* plistFileName = [plistFolderPath stringByAppendingPathComponent:@"LastUpdate.plist"];
    
    BOOL isDirectory = NO;
    BOOL exist = [localFileManager fileExistsAtPath:plistFileName isDirectory:&isDirectory];
    
    if (exist)
    {
        NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
        
        NSDate *lastUpdatedDate = [plistDict objectForKey:@"LastUpdatedDate"];
        NSDate *currentTime = [NSDate date];
        
        NSTimeInterval dateInterval = [currentTime timeIntervalSinceDate:lastUpdatedDate];
        
        NSInteger days = floor(dateInterval/86400.0f);

        if (days >= 9)
        {
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"You have not Backed up app settings in 10 days… Would you like to back up now?", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                [self actionProjectDeleteDesabled];
                
                [self.customModalView hideCustomModalView];
                self.customModalView = nil;
                
                [self.settingsView updateSettings];
                
                self.customModalView = [[CustomModalView alloc] initWithView:self.settingsView isCenter:YES];
                self.customModalView.delegate = self;
                self.customModalView.dismissButtonRight = YES;
                [self.customModalView show];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Remind me later", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                
            }];
            
            [alertController addAction:okAction];
            [alertController addAction:cancelAction];

            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    else
    {
        [localFileManager createFileAtPath:plistFileName contents:nil attributes:nil];
        
        NSMutableDictionary* plistDict = [NSMutableDictionary dictionary];
        
        NSDate* currentDate = [NSDate date];

        [plistDict setObject:currentDate forKey:@"LastUpdatedDate"];
        [plistDict writeToFile:plistFileName atomically:YES];
    }
}


#pragma mark - 
#pragma mark - Share a Saved Project

-(IBAction)actionShareSavedProject:(id)sender
{
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
        self.projectGalleryPicker.isSharing = YES;
    }
    
    self.projectGalleryPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:self.projectGalleryPicker animated:YES completion:nil];
}

- (void) receivedProject:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"ReceivedProjectNotification"])
    {
        NSLog (@"Successfully received project!");
        
        [self getProjects];
    }
}

#pragma mark -
#pragma mark - Music WebView

- (void)musicDownloadControllerDidCancel:(MusicDownloadController *)picker
{
    [self.musicDownloadController dismissViewControllerAnimated:YES completion:^{
        self.musicDownloadController = nil;
        [[SHKActivityIndicator currentIndicator] hide];
    }];
}

- (void)goToLibraryFromMusicDownloadController:(MusicDownloadController *)picker
{
    [self.musicDownloadController dismissViewControllerAnimated:YES completion:^{
        self.musicDownloadController = nil;
        [[SHKActivityIndicator currentIndicator] hide];

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

        self.musicDownloadController = nil;

        [[SHKActivityIndicator currentIndicator] hide];

        [self musicPickerControllerDidSelected:(YJLCustomMusicController *)picker asset:(NSURL *)assetUrl];
    }];
}

//-(void) goToLibrary{
//    if (self.customModalView != nil)
//    {
//        [self.customModalView hideCustomModalView];
//        self.customModalView = nil;
//    }
//
//    if (!self.musicPicker)
//    {
//        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"YJLCustomMusicPickerStoryboard" bundle:nil];
//        self.musicPicker = [sb instantiateViewControllerWithIdentifier:@"YJLCustomMusicController"];
//        self.musicPicker.customMusicDelegate = self;
//    }
//
//    self.musicPicker.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:self.musicPicker animated:YES completion:nil];
//}
//
//- (void)musicSiteDidSelected:(MusicDownload *)picker
//{
//    [self.musicDownload dismissViewControllerAnimated:YES completion:^{
//
//        self.musicDownload = nil;
//
//        [[SHKActivityIndicator currentIndicator] hide];
//
//        [self actionGoToFreeBackgroundMusic];
//    }];
//}
//
//- (void)musicDownloadDidCancel:(MusicDownload *)picker
//{
//    [self fixAppOrientationAfterDismissImagePickerController];
//
//    [self.musicDownload dismissViewControllerAnimated:YES completion:^{
//
//        self.musicDownload = nil;
//
//        [[SHKActivityIndicator currentIndicator] hide];
//    }];
//}

#pragma mark -
#pragma mark - ************** YJLCustomMusicPickerController Delegate - Custom Music ****************

- (void)musicPickerControllerDidCancel:(YJLCustomMusicController *)picker
{
    [self.musicPicker dismissViewControllerAnimated:YES completion:^{
        self.musicPicker = nil;
    }];
}

- (void)musicPickerControllerDidSelected:(YJLCustomMusicController *)picker asset:(NSURL *)assetUrl
{
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

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
