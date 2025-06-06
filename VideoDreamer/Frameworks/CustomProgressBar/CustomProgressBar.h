//
//  CustomProgressBar.h
//  VideoFrame
//
//  Created by Yinjing Li on 10/5/17.
//  Copyright (c) 2017 Yinjing Li. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface CustomProgressBar : UIView
{

}

@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIProgressView *progressView;

+ (CustomProgressBar *) currentProgressBar;

- (void)show;
- (void)hideAfterDelay;
- (void)hide;
- (void)hidden;
- (void)displayProgressBar:(NSString *)m;
- (void)displayProgressBarLockOnly:(BOOL) lock;
- (void)displayProgressBar:(NSString *)m isLock:(BOOL)l;
- (void)displayCompleted:(NSString *)m;
- (void)displayCompleted;
- (void)displayErrorMessage:(NSString *)m;
- (void)setCenterMessage:(NSString *)message;
- (void)showProgress;
- (void)setProperRotation;
- (void)setProperRotation:(BOOL)animated;
-(void) updateProgressBar:(CGFloat) progress;

@end
