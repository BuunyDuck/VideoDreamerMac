//
//  UIApplication+Extension.m
//  VideoDreamer
//
//  Created by Yinjing Li on 2/15/23.
//

#import "UIApplication+Extension.h"
#import "Definition.h"

@implementation UIApplication (Extension)

+ (UIInterfaceOrientation)orientation {
    //if (@available(iOS 13.0, *)) {
        return [UIApplication sharedApplication].windows.firstObject.windowScene.interfaceOrientation;
    //} else {
        //return [UIApplication sharedApplication].statusBarOrientation;
    //}
}

+ (UIWindow *)keyWindow {
   NSPredicate *isKeyWindow = [NSPredicate predicateWithFormat:@"isKeyWindow == YES"];
   return [[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate:isKeyWindow].firstObject;
}

+ (void)updateScreenSize:(int)orientation {
    for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
        if ([windowScene isKindOfClass:[UIWindowScene class]]) {
            if (orientation == ORIENTATION_LANDSCAPE) {
                windowScene.sizeRestrictions.minimumSize = SCREEN_FRAME_LANDSCAPE.size;
                windowScene.sizeRestrictions.maximumSize = SCREEN_FRAME_LANDSCAPE.size;
            } else {
                windowScene.sizeRestrictions.minimumSize = SCREEN_FRAME_PORTRAIT.size;
                windowScene.sizeRestrictions.maximumSize = SCREEN_FRAME_PORTRAIT.size;
            }
        }
    }
}

@end
