//
//  AppDelegate.m
//  VideoDreamer
//
//  Created by Yinjing Li on 11/2/22.
//

#import "AppDelegate.h"
#import "Definition.h"
#import "SelectTemplateVC.h"
#import "SHKActivityIndicator.h"
#import "UIColor-Expanded.h"
#import "MyCloudDocument.h"
#import "GIFImage.h"
#import "UIApplication+Extension.h"
#import "SilentBridge.h"
#import "VideoDreamer-Swift.h"
#import "ProjectManager.h"
#import <FirebaseCore.h>
#import <FIRCrashlytics.h>

@interface AppDelegate () <COSTouchVisualizerWindowDelegate>

@end

@implementation AppDelegate

+ (AppDelegate *)sharedDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
#if TARGET_OS_MACCATALYST
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSFullScreenMenuItemEverywhere"];
#else
    NSLog(@"Running iOS");
#endif
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.launchOptions = [NSMutableDictionary dictionaryWithDictionary:launchOptions];
    
    sleep(1.2f);
    
    // Init App parameters
    [self initAppGlobalParams];
    
    [FIRApp configure];
    [[FIRCrashlytics crashlytics] setCrashlyticsCollectionEnabled:YES];
#if TARGET_OS_MACCATALYST
    [UIApplication updateScreenSize:ORIENTATION_LANDSCAPE];
#else
    NSLog(@"Running iOS");
#endif
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.navigationController = [storyboard instantiateInitialViewController];
    
    SelectTemplateVC* selectTemplateVC = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        selectTemplateVC = [[SelectTemplateVC alloc] initWithNibName:@"SelectTemplateVC" bundle:nil];
    else
        selectTemplateVC = [[SelectTemplateVC alloc] initWithNibName:@"SelectTemplateVC_iPad" bundle:nil];
    self.navigationController = [[NavigationVC alloc] initWithRootViewController:selectTemplateVC];
    self.navigationController.navigationBar.hidden = YES;
    
#if TARGET_OS_MACCATALYST
    self.customWindow = [[COSTouchVisualizerWindow alloc] initWithFrame:SCREEN_FRAME_LANDSCAPE];
#else
    self.customWindow = [[COSTouchVisualizerWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
#endif
    self.customWindow.touchVisualizerWindowDelegate = self;
    self.customWindow.backgroundColor = [UIColor whiteColor];
    self.customWindow.rootViewController = self.navigationController;
    [self.customWindow makeKeyAndVisible];

    self.projectSharingManager = [[ProjectSharingManager alloc] init];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isAlreadyRunningApp"])  // First running
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAlreadyRunningApp"];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"MyriadPro-Bold" size:17.0]}];
    
    NSDictionary* normalButtonItemAttributes = @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                 NSForegroundColorAttributeName:[UIColor blackColor]};
    NSDictionary* highlightButtonItemAttributes = @{NSFontAttributeName:[UIFont fontWithName:MYRIADPRO size:16.0],
                                                    NSForegroundColorAttributeName:[UIColor darkGrayColor]};
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTitleTextAttributes:normalButtonItemAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTitleTextAttributes:highlightButtonItemAttributes forState:UIControlStateHighlighted];
    [[UIBarButtonItem appearance] setTitleTextAttributes:normalButtonItemAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:highlightButtonItemAttributes forState:UIControlStateHighlighted];
    
    [application customizeNavigationBar];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    self.launchOptions = [NSMutableDictionary dictionaryWithDictionary:options];
    self.launchOptions[@"URL"] = url;
    
    if ([url.pathExtension isEqualToString:@"zip"]) {
        [[ProjectManager sharedManager] importProject:url];
    } else {
        NSData* gifData = [NSData dataWithContentsOfURL:url];
        NSString* gifPath = [url path];
        
        if ([GIFImage AnimatedGifDataIsValid:gifData])
        {
            NSFileManager* localFileManager = [NSFileManager defaultManager];
            NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
            NSString* folderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
            NSString* gifFolderPath = [folderPath stringByAppendingPathComponent:@"GIFs"];
            
            BOOL isDirectory = NO;
            BOOL exist = [localFileManager fileExistsAtPath:gifFolderPath isDirectory:&isDirectory];
            
            if (!exist)
                [localFileManager createDirectoryAtPath:gifFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
            
            NSString* gifFileName = [gifPath lastPathComponent];
            NSString* gifFilePath = [gifFolderPath stringByAppendingPathComponent:gifFileName];
            [gifData writeToFile:gifFilePath atomically:YES];

            [self.navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"Gif saved successfully!", nil) okHandler:nil];
        }
    }
    
    return YES;
}


#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark -
#pragma mark - Init App Params

- (void) initAppGlobalParams
{
    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* folderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"ProjectSettings.plist"];
    
    if ([localFileManager fileExistsAtPath:plistFileName])
    {
        NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
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
        defaultOutlineColor = [UIColor colorWithHexString:[plistDict objectForKey:@"defaultOutlineColor"]];
        grDefaultOutlineWidth = [[plistDict objectForKey:@"grDefaultOutlineWidth"] floatValue];
        grDefaultOutlineCorner = [[plistDict objectForKey:@"grDefaultOutlineCorner"] floatValue];
        gnStartWithType = [[plistDict objectForKey:@"gnStartWithType"] intValue];
        isKenBurnsEnabled = [[plistDict objectForKey:@"isKenBurnsEnabled"] boolValue];
        isTouchVisualizerEnabled = [[plistDict objectForKey:@"isTouchVisualizerEnabled"] boolValue];
        gnKBZoomInOutType = [[plistDict objectForKey:@"gnKBZoomInOutType"] intValue];
        grKBScale = [[plistDict objectForKey:@"grKBScale"] floatValue] == 0.0f ? 2.2f : [[plistDict objectForKey:@"grKBScale"] floatValue];
    }
    else
    {
        grPhotoDefaultDuration = 10.0f;
        grTextDefaultDuration = 6.0f;
        gnStartActionTypeDef = ACTION_FADE;
        grStartActionTimeDef = 1.0f;
        gnEndActionTypeDef = ACTION_ZOOM_CC;
        grEndActionTimeDef = 1.0f;
        gnTimelineType = TIMELINE_TYPE_3;
        gnOutputQuality = OUTPUT_SDTV;
        grPreviewDuration = 60.0f;
        gnDefaultOutlineType = 1;
        defaultOutlineColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        grDefaultOutlineWidth = 15.0f;
        grDefaultOutlineCorner = 5.0f;
        gnStartWithType = START_WITH_TEMPLATE;
        isKenBurnsEnabled = NO;
        isTouchVisualizerEnabled = NO;
        gnKBZoomInOutType = KB_OUT;
        grKBScale = 2.2f;
    }
    
    //init values
    gnOrientation = ORIENTATION_ALL;
    rememberedTextAlignment = NSTextAlignmentCenter;
    isRememberedBold = NO;
    isRememberedItalic = NO;
    isRememberedUnderline = NO;
    isRememberedStroke = NO;
    
    //detect iPhone 5 more devices
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if (([UIScreen mainScreen].bounds.size.width > 480.0f) || ([UIScreen mainScreen].bounds.size.height > 480.0f))
            isIPhoneFive = YES;
        else
            isIPhoneFive = NO;
    }
    
    //load font names
    [self load_fontNames];
    
    //remembered font
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        rememberedFont = [UIFont fontWithName:@"ArialMT" size:IPHONE_DEFAULT_FONT_SIZE];
    else
        rememberedFont = [UIFont fontWithName:@"ArialMT" size:IPAD_DEFAULT_FONT_SIZE];
    
    //init recent color
    [self loadRecentColors];

    //init action name array
    gaActionNameArray = [[NSArray alloc] initWithObjects:
                        @"None",
                        @"Black",
                        @"Explode",
                        @"Fade",
                        @"FlipBT",
                        @"FlipLR",
                        @"FlipRL",
                        @"FlipTB",
                        @"FoldBT",
                        @"FoldLR",
                        @"FoldRL",
                        @"FoldTB",
                        @"GenieBL",
                        @"GenieBR",
                        @"GenieBT",
                        @"GenieLR",
                        @"GenieRL",
                        @"GenieTB",
                        @"GenieTL",
                        @"GenieTR",
                        @"Rotate",
                        @"RevealBT",
                        @"RevealLR",
                        @"RevealRL",
                        @"RevealTB",
                        @"SlideBL",
                        @"SlideBR",
                        @"SlideBT",
                        @"SlideLR",
                        @"SlideRL",
                        @"SlideTB",
                        @"SlideTL",
                        @"SlideTR",
                        @"SpinCC",
                        @"SwapALL",
                        @"SwapBL",
                        @"SwapBR",
                        @"SwapBT",
                        @"SwapLR",
                        @"SwapRL",
                        @"SwapTB",
                        @"SwapTL",
                        @"SwapTR",
                        @"SwingBT",
                        @"SwingLR",
                        @"SwingRL",
                        @"SwingTB",
                        @"ZoomALL",
                        @"ZoomBL",
                        @"ZoomBR",
                        @"ZoomBT",
                        @"ZoomCC",
                        @"ZoomLR",
                        @"ZoomRL",
                        @"ZoomTB",
                        @"ZoomTL",
                        @"ZoomTR",
                        nil];
    
    
    //[self installEffectVideos];
    
    [self installGIFs];
}

#pragma mark -
#pragma mark - Load Recent Color

-(void) loadRecentColors
{
    gaRecentColorArray = [[NSMutableArray alloc] init];

    NSFileManager* localFileManager = [NSFileManager defaultManager];
    NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString* folderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
    NSString* plistFileName = [folderPath stringByAppendingPathComponent:@"RecentColor.plist"];
    
    if (![localFileManager fileExistsAtPath:plistFileName])
        return;
    
    NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFileName];
    int recentArrayCount = [[plistDict objectForKey:@"RecentColorCount"] intValue];
    
    for (int i = 0; i < recentArrayCount; i++)
    {
        NSString* recentString = [plistDict objectForKey:[NSString stringWithFormat:@"%d-RecentColorString", i]];
        [gaRecentColorArray addObject:recentString];
    }
}

#pragma mark -
#pragma mark - font name process

-(void) load_fontNames
{
    gaFontNameArray = [[NSArray alloc] initWithArray: [[UIFont familyNames] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    id presentedViewController = [window.rootViewController presentedViewController];
    NSString *className = presentedViewController ? NSStringFromClass([presentedViewController class]) : nil;

    if (window && [className isEqualToString:@"MusicDownloadController"]) {
        NSLog(@"");
    } else {
        if (gnOrientation == ORIENTATION_ALL) // orientation all
            return UIInterfaceOrientationMaskAll;
        else if (gnOrientation == ORIENTATION_PORTRAIT) //portrait
            return UIInterfaceOrientationMaskPortrait;
        else if (gnOrientation == ORIENTATION_LANDSCAPE)
            return UIInterfaceOrientationMaskLandscape;
    }
    
    return UIInterfaceOrientationMaskAll;
}

#pragma mark -
#pragma mark - install GIFs

- (void) installGIFs
{
    BOOL isInstalledGIFs = [[NSUserDefaults standardUserDefaults] boolForKey:@"installedGIFs"];
    
    if (!isInstalledGIFs)
    {
        //create a GIFs folder
        NSFileManager* localFileManager = [NSFileManager defaultManager];
        NSString* folderDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
        NSString* folderPath = [folderDir stringByAppendingPathComponent:@"Preferences"];
        NSString* gifFolderPath = [folderPath stringByAppendingPathComponent:@"GIFs"];
        [localFileManager createDirectoryAtPath:gifFolderPath withIntermediateDirectories:NO attributes:nil error:nil];

        //save a sample gifs to GIFs folder
        NSString* gifFileName = @"walkingworkman.gif";
        NSString *path = [[NSBundle mainBundle] pathForResource:[gifFileName stringByDeletingPathExtension] ofType:[gifFileName pathExtension] inDirectory:nil];
        NSData *gifData = [NSData dataWithContentsOfFile:path];
        NSString* gifFilePath = [gifFolderPath stringByAppendingPathComponent:gifFileName];
        [gifData writeToFile:gifFilePath atomically:YES];
        
        gifFileName = @"animated.gif";
        path = [[NSBundle mainBundle] pathForResource:[gifFileName stringByDeletingPathExtension] ofType:[gifFileName pathExtension] inDirectory:nil];
        gifData = [NSData dataWithContentsOfFile:path];
        gifFilePath = [gifFolderPath stringByAppendingPathComponent:gifFileName];
        [gifData writeToFile:gifFilePath atomically:YES];

        gifFileName = @"chinaflagmove.gif";
        path = [[NSBundle mainBundle] pathForResource:[gifFileName stringByDeletingPathExtension] ofType:[gifFileName pathExtension] inDirectory:nil];
        gifData = [NSData dataWithContentsOfFile:path];
        gifFilePath = [gifFolderPath stringByAppendingPathComponent:gifFileName];
        [gifData writeToFile:gifFilePath atomically:YES];

        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"installedGIFs"];
        [defaults synchronize];
    }
}


#pragma mark -
#pragma mark - install effect videos

- (void) installEffectVideos
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL isInstalled = [defaults boolForKey:@"dragon"];
    
    if (!isInstalled)
        [self installDragonVideo];
    
    isInstalled = [defaults boolForKey:@"war"];
    
    if (!isInstalled)
        [self installWarVideo];
}


- (void) installDragonVideo
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dragon" ofType:@"m4v" inDirectory:nil];
    NSURL* videoUrl = [NSURL fileURLWithPath:path isDirectory:NO];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^
     {
         PHFetchOptions *fetchOptions = [PHFetchOptions new];
         fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title == %@", NSLocalizedString(@"Video Dreamer", nil)];
         
         PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
         
         //new create
         if (fetchResult.count == 0)
         {
             //create asset
             PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
             
             //Create Album
             PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:NSLocalizedString(@"Video Dreamer", nil)];
             
             //get a placeholder for the new asset and add it to the album editing request
             PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
             
             [albumRequest addAssets:@[assetPlaceholder]];
         }
         else //add video to album
         {
             //create asset
             PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
             
             //change Album
             PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
             PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
             
             //get a placeholder for the new asset and add it to the album editing request
             PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
             
             [albumRequest addAssets:@[assetPlaceholder]];
         }
         
     } completionHandler:^(BOOL success, NSError *error) {
         
         if (!error)
         {
             NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
             [defaults setBool:YES forKey:@"dragon"];
             [defaults synchronize];
         }
     }];
}

- (void) installWarVideo
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"war" ofType:@"m4v" inDirectory:nil];
    NSURL* videoUrl = [NSURL fileURLWithPath:path isDirectory:NO];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^
     {
         PHFetchOptions *fetchOptions = [PHFetchOptions new];
         fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title == %@", NSLocalizedString(@"Video Dreamer", nil)];
         
         PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOptions];
         
         //new create
         if (fetchResult.count == 0)
         {
             //create asset
             PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
             
             //Create Album
             PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:NSLocalizedString(@"Video Dreamer", nil)];
             
             //get a placeholder for the new asset and add it to the album editing request
             PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
             
             [albumRequest addAssets:@[assetPlaceholder]];
         }
         else  //add video to album
         {
             //create asset
             PHAssetChangeRequest *videoRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoUrl];
             
             //change Album
             PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
             PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
             
             //get a placeholder for the new asset and add it to the album editing request
             PHObjectPlaceholder* assetPlaceholder = [videoRequest placeholderForCreatedAsset];
             
             [albumRequest addAssets:@[assetPlaceholder]];
         }
         
     } completionHandler:^(BOOL success, NSError *error) {
         
         if (!error)
         {
             NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
             [defaults setBool:YES forKey:@"war"];
             [defaults synchronize];
         }
     }];
}

#pragma mark - COSTouchVisualizerWindowDelegate
- (BOOL)touchVisualizerWindowShouldShowFingertip:(COSTouchVisualizerWindow *)window {
    return isTouchVisualizerEnabled;  // Return YES to make the fingertip always display even if there's no any mirrored screen.
    // Return NO or don't implement this method if you want to keep the fingertip display only when
    // the device is connected to a mirrored screen.
}

- (BOOL)touchVisualizerWindowShouldAlwaysShowFingertip:(COSTouchVisualizerWindow *)window {
    return isTouchVisualizerEnabled;  // Return YES or don't implement this method to make this window show fingertip when necessary.
    // Return NO to make this window not to show fingertip.
}

@end
