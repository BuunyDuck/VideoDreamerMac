//
//  CustomProgressBar.m
//  VideoFrame
//
//  Created by Yinjing Li on 10/5/17.
//  Copyright (c) 2017 Yinjing Li. All rights reserved.
//


#import "CustomProgressBar.h"
#import <QuartzCore/QuartzCore.h>

#define SHKdegreesToRadians(x) (M_PI * x / 180.0)

@implementation CustomProgressBar


static CustomProgressBar *currentProgressBar = nil;

+ (CustomProgressBar *)currentProgressBar
{
	if (currentProgressBar == nil)
	{
		UIWindow *keyWindow = [UIApplication keyWindow];
		CGFloat height = 50.0f;
		CGRect centeredFrame = CGRectMake(50.0f,
										  round(keyWindow.bounds.size.height/2 - height/2),
										  keyWindow.bounds.size.width - 100.0f,
										  height);
		
		currentProgressBar = [[super allocWithZone:NULL] initWithFrame:centeredFrame];
		
		currentProgressBar.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
		currentProgressBar.opaque = NO;
		currentProgressBar.alpha = 0;
		currentProgressBar.layer.cornerRadius = 5.0f;
		currentProgressBar.userInteractionEnabled = NO;
		currentProgressBar.autoresizesSubviews = YES;
		currentProgressBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin |  UIViewAutoresizingFlexibleBottomMargin;
		[currentProgressBar setProperRotation:NO];
		
		[[NSNotificationCenter defaultCenter] addObserver:currentProgressBar
												 selector:@selector(setProperRotation)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
	}
	
	return currentProgressBar;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -


- (void)setLockView:(BOOL)isLock
{
	if (!isLock && self.backgroundView != nil)
		self.backgroundView = nil;
    
	else if (isLock)
	{
		if (self.backgroundView == nil)
		{
			self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,0,1024,1024)];
			self.backgroundView.backgroundColor = [UIColor clearColor];
            [[UIApplication keyWindow] addSubview:self.backgroundView];
		}
        
   		[[UIApplication keyWindow] bringSubviewToFront:self.backgroundView];
	}
}

#pragma mark Creating Message

- (void)show
{	
	if (self.superview != [UIApplication keyWindow])
		[[UIApplication keyWindow] addSubview:self];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hideAfterDelay
{
	[self performSelector:@selector(hide) withObject:nil afterDelay:1.0];
}

- (void)hide
{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
        [[UIApplication keyWindow] sendSubviewToBack:self.backgroundView];
        
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    } completion:^(BOOL finished) {
        [self hidden];
    }];
}

- (void)persist
{	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hidden
{
	if (currentProgressBar.alpha > 0)
		return;
	
	[currentProgressBar removeFromSuperview];
	currentProgressBar = nil;
}

- (void)displayProgressBar:(NSString *)m isLock:(BOOL)l
{		
    [self setLockView:l];
	[self setCenterMessage:m];
	[self showProgress];
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
}

- (void)displayProgressBarLockOnly:(BOOL) lock
{
    [self setLockView:lock];
	[self setCenterMessage:@""];
    
    currentProgressBar.hidden = YES;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
}

- (void)displayProgressBar:(NSString *)m
{		
    [self setLockView:YES];
	[self setCenterMessage:m];
	[self showProgress];
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
}

- (void)displayCompleted:(NSString *)m
{	
	[self setCenterMessage:m];
	
	[self.progressView removeFromSuperview];
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
    
	[self hideAfterDelay];
}

- (void)displayCompleted
{	
	[self setCenterMessage:@""];
	
	[self.progressView removeFromSuperview];
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
    
	[self hideAfterDelay];
}


- (void)displayErrorMessage:(NSString *)m
{	
	[self setCenterMessage:m];
	
	[self.progressView removeFromSuperview];
	self.progressView = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
    
	[self hideAfterDelay];
    
}

- (void)setCenterMessage:(NSString *)message
{	
	if (message == nil && self.progressLabel != nil)
		self.progressLabel = nil;

	else if (message != nil)
	{
		if (self.progressLabel == nil)
		{
			self.progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5.0f, self.bounds.size.width, 20)];
			self.progressLabel.backgroundColor = [UIColor clearColor];
			self.progressLabel.opaque = NO;
			self.progressLabel.textColor = [UIColor whiteColor];
			self.progressLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:20.0f];
			self.progressLabel.textAlignment = NSTextAlignmentCenter;
			self.progressLabel.shadowColor = [UIColor darkGrayColor];
			self.progressLabel.shadowOffset = CGSizeMake(1,1);
			self.progressLabel.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:self.progressLabel];
		}
		
		self.progressLabel.text = message;
	}
}


- (void)showProgress
{	
	if (self.progressView == nil)
	{
		self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20.0f, self.bounds.size.height - 10.0f, self.bounds.size.width - 40.0f, 10.0f)];
        self.progressView.progressViewStyle = UIProgressViewStyleDefault;
	}
    self.progressView.progress = 0.0f;
    
	[self addSubview:self.progressView];
}

-(void) updateProgressBar:(CGFloat) progress
{
    self.progressView.progress = progress;
    
    NSString* strText = NSLocalizedString(@"Receiving", nil);
    strText = [strText stringByAppendingString:[NSString stringWithFormat:@" %.2f%%", progress*100.0f]];
    self.progressLabel.text = strText;
}

#pragma mark -
#pragma mark Rotation

- (void)setProperRotation
{
	[self setProperRotation:YES];
}

- (void)setProperRotation:(BOOL)animated
{
	if (animated)
	{
        [UIView animateWithDuration:0.3 animations:^{
            
        }];
	}
}


@end
