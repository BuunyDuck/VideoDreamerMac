//
//  AppDelegate.h
//  VideoDreamer
//
//  Created by Yinjing Li on 11/2/22.
//

#import <UIKit/UIKit.h>
#import "COSTouchVisualizerWindow.h"
#import "ProjectSharingManager.h"
#import "NavigationVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) COSTouchVisualizerWindow *customWindow;
@property (nonatomic, strong) NavigationVC *navigationController;

@property (nonatomic, strong) ProjectSharingManager* projectSharingManager;

@property (nonatomic, strong) NSMutableDictionary *launchOptions;

+ (AppDelegate *)sharedDelegate;

@end

