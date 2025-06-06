//
//  UIViewController+Extension.h
//  VideoDreamer
//
//  Created by Yinjing Li on 11/9/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Extension)

- (void)showAlertViewController:(NSString *)title message:(NSString *)message okHandler:(nullable void(^)(void))okHandler;

@end

NS_ASSUME_NONNULL_END
