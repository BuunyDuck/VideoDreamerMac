//
//  SceneDelegate.h
//  VideoDreamer
//
//  Created by Yinjing Li on 11/2/22.
//

#import <UIKit/UIKit.h>
#import "COSTouchVisualizerWindow.h"
#import "NavigationVC.h"

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (nonatomic, strong) COSTouchVisualizerWindow *window;
@property (nonatomic, strong) NavigationVC *navigationController;

+ (SceneDelegate *)sharedDelegate;

@end

