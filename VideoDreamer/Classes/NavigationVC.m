//
//  NavigationVC.m
//  VideoFrame
//
//  Created by Yinjing Li on 11/1/22.
//  Copyright © 2022 Yinjing Li. All rights reserved.
//

#import "NavigationVC.h"
#import "Definition.h"

@interface NavigationVC ()

@end

@implementation NavigationVC

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (gnOrientation == ORIENTATION_LANDSCAPE)
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    else if (gnOrientation == ORIENTATION_PORTRAIT)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[self fixDeviceOrientation];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //[self fixDeviceOrientation];
}

- (void)fixDeviceOrientation {
    UIInterfaceOrientation orientation = [UIApplication orientation];

    if ((orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)&&(gnTemplateIndex == TEMPLATE_LANDSCAPE || gnTemplateIndex == TEMPLATE_1080P))
    {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    else if((orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)&&(gnTemplateIndex == TEMPLATE_PORTRAIT || gnTemplateIndex == TEMPLATE_SQUARE))
    {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
