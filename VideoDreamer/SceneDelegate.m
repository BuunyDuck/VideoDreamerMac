//
//  SceneDelegate.m
//  VideoDreamer
//
//  Created by Yinjing Li on 11/2/22.
//

#import "SceneDelegate.h"
#import "Definition.h"
#import "SelectTemplateVC.h"
#import "NavigationVC.h"
#import "SilentBridge.h"
#import "GIFImage.h"
#import "ProjectManager.h"

static SceneDelegate *_sceneDelegate;

@interface SceneDelegate () <COSTouchVisualizerWindowDelegate>

@end

@implementation SceneDelegate

+ (SceneDelegate *)sharedDelegate {
    return _sceneDelegate;
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    if (scene == nil || ![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
    
#if TARGET_OS_MACCATALYST
    [UIApplication updateScreenSize:ORIENTATION_LANDSCAPE];
#else
    NSLog(@"Running iOS");
#endif
    
    SelectTemplateVC* selectTemplateVC = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        selectTemplateVC = [[SelectTemplateVC alloc] initWithNibName:@"SelectTemplateVC" bundle:nil];
    else
        selectTemplateVC = [[SelectTemplateVC alloc] initWithNibName:@"SelectTemplateVC_iPad" bundle:nil];
    selectTemplateVC.view.backgroundColor = [UIColor blackColor];
    self.navigationController = [[NavigationVC alloc] initWithRootViewController:selectTemplateVC];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.view.backgroundColor = [UIColor blackColor];

    UIWindowScene *windowScene = (UIWindowScene *)scene;
#if TARGET_OS_MACCATALYST
    self.window = [[COSTouchVisualizerWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = SCREEN_FRAME_LANDSCAPE;
#else
    self.window = [[COSTouchVisualizerWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = [UIScreen mainScreen].bounds;
#endif
    self.window.touchVisualizerWindowDelegate = self;
    self.window.backgroundColor = [UIColor blackColor];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    _sceneDelegate = self;
    
#if TARGET_OS_MACCATALYST
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0), dispatch_get_main_queue(), ^{
        [SilentBridge disableCloseButtonFor:[self nsWindow:self.window]];
    });
#endif

    [self scene:scene openURLContexts:connectionOptions.URLContexts];
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    if (URLContexts == nil)
        return;
    
    NSLog(@"%@", URLContexts);
    for (UIOpenURLContext *URLContext in URLContexts.allObjects) {
        NSURL *url = URLContext.URL;
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
    }
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

#pragma mark - NSWindow
- (NSObject *)nsWindow:(UIWindow *)window {
    NSArray *nsWindows = [NSClassFromString(@"NSApplication") valueForKeyPath:@"sharedApplication.windows"];
    if (nsWindows == nil || [nsWindows isKindOfClass:[NSArray class]] == NO) {
        return nil;
    }
    
    for (NSObject *nsWindow in nsWindows) {
        NSArray *uiWindows = [nsWindow valueForKeyPath:@"uiWindows"];
        if (uiWindows != nil && [uiWindows isKindOfClass:[NSArray class]] && uiWindows.count > 0 && [uiWindows containsObject:window]) {
            return nsWindow;
        }
    }
    
    return nil;
}

#pragma mark - Import Project

@end
