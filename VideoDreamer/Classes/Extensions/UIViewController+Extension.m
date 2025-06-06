//
//  UIViewController+Extension.m
//  VideoDreamer
//
//  Created by Yinjing Li on 11/9/22.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (void)showAlertViewController:(NSString *)title message:(NSString *)message okHandler:(nullable void(^)(void))okHandler {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (okHandler != nil) {
            okHandler();
        }
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
