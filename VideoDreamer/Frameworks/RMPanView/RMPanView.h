//
//  RMPanView.h
//  RandomMusicPlayer
//
//  Created by APPLE'S iMac on 6/15/20.
//  Copyright © 2020 Fredc Weber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMPanView : UIView

@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) BOOL visible;

- (instancetype)initWithView:(UIView *)view;
- (void)showInView:(UIView *)view offset:(CGFloat)offset;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
