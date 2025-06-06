//
//  CustomModalView.m
//  VideoFrame
//
//  Created by Yinjing Li on 11/14/13.
//  Copyright (c) 2013 Yinjing Li. All rights reserved.
//


#import "CustomModalView.h"
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>

#import "Definition.h"


CGFloat const kCustomDefaultDelay = 0.0f;
CGFloat const kRNDefaultBlurScale = 0.2f;
CGFloat const kCustomDefaultDuration = 0.2f;
CGFloat const kCustomViewMaxAlpha = 1.f;

NSString * const kCustomDidShowNotification = @"CustomModalView.show";
NSString * const kCustomDidHidewNotification = @"CustomModalView.hide";

typedef void (^CustomCompletion)(void);

@interface UILabel (AutoSize)
- (void)autoHeight;
@end

@interface UIView (Sizes)
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;
@end

@interface UIView (Screenshot)
- (UIImage*)screenshot;
@end

@interface UIImage (Blur)
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end

@interface CustomView : UIImageView
- (id)initWithCoverView:(UIView*)view;
@end

@interface RNCloseButton : UIButton
@end

@interface CustomModalView ()
@property (assign, readwrite) BOOL isVisible;
@end



#pragma mark - CustomModalView

@implementation CustomModalView
{
    UIViewController *_controller;
    
    UIView *_parentView;
    UIView *_contentView;
    UIView *_blurView;

    RNCloseButton *_dismissButton;
    CustomCompletion _completion;
}


+ (UIView*)generateModalViewWithTitle:(NSString*)title message:(NSString*)message
{
    CGFloat defaultWidth = 280.f;
    CGRect frame = CGRectMake(0, 0, defaultWidth, 0);
    CGFloat padding = 10.f;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor blackColor];
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 1.f;
    view.layer.cornerRadius = 10.f;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, defaultWidth - padding * 2.f, 0)];
    titleLabel.text = title;
    titleLabel.font = [UIFont fontWithName:MYRIADPRO size:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel autoHeight];
    titleLabel.numberOfLines = 0;
    titleLabel.top = padding;
    [view addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0, defaultWidth - padding * 2.f, 0)];
    messageLabel.text = message;
    messageLabel.numberOfLines = 0;
    messageLabel.font = [UIFont fontWithName:MYRIADPRO size:17];
    messageLabel.textColor = titleLabel.textColor;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor clearColor];
    [messageLabel autoHeight];
    messageLabel.top = titleLabel.bottom + padding;
    [view addSubview:messageLabel];
    
    view.height = messageLabel.bottom + padding;
    view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    return view;
}


#pragma mark - 
#pragma mark - 

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _dismissButton = [[RNCloseButton alloc] init];
        _dismissButton.center = CGPointZero;
        [_dismissButton addTarget:self action:@selector(didTappedCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.alpha = 0.f;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                  UIViewAutoresizingFlexibleHeight |
                                  UIViewAutoresizingFlexibleLeftMargin |
                                  UIViewAutoresizingFlexibleTopMargin);
    }
    
    return self;
}


#pragma mark - init with view

- (id)initWithView:(UIView*)view isCenter:(BOOL)centerFlag
{
//    if (self = [self initWithParentView:[[UIApplication sharedApplication].delegate window].rootViewController.view view:view isCenter:centerFlag])
  
    if (self = [self initWithParentView:[UIApplication keyWindow].rootViewController.view view:view isCenter:centerFlag])
    {
        // nothing to see here
    }
    
    return self;
}

- (id)initWithView:(UIView*)view bgColor:(UIColor*) color
{
//    if (self = [self initWithParentView:[[UIApplication sharedApplication].delegate window].rootViewController.view view:view bgColor:color])
    
    if (self = [self initWithParentView:[UIApplication keyWindow].rootViewController.view view:view bgColor:color])
    {
 
    }
    
    return self;
}

- (id)initWithViewController:(UIViewController*)viewController view:(UIView*)view
{
    if (self = [self initWithFrame:CGRectMake(0, 0, viewController.view.width, viewController.view.height)])
    {
        [self addSubview:view];
        
        _contentView = view;
        _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _contentView.clipsToBounds = YES;
        _contentView.layer.masksToBounds = YES;
        _controller = viewController;
       
        _parentView = nil;
        
        _dismissButton.center = CGPointMake(view.left, view.top);
        [self addSubview:_dismissButton];
    }
    
    return self;
}

- (id)initWithViewController:(UIViewController*)viewController title:(NSString*)title message:(NSString*)message
{
    UIView *view = [CustomModalView generateModalViewWithTitle:title message:message];
    
    if (self = [self initWithViewController:viewController view:view])
    {
        // nothing to see here
    }
    
    return self;
}

- (id)initWithParentView:(UIView*)parentView view:(UIView*)view bgColor:(UIColor*)color
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        BOOL isPortrait  = NO;
        
        CGAffineTransform transform = parentView.transform;

        if(transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0)
        {
            isPortrait = YES;
        }
        else if(transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0)
        {
            isPortrait = YES;
        }
        
        if (isPortrait)
        {
            if (self = [self initWithFrame:CGRectMake(0, 0, parentView.height, parentView.width)])
            {
                [self addSubview:view];
                
                _contentView = view;
                _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                _contentView.clipsToBounds = YES;
                _contentView.layer.masksToBounds = YES;
                _contentView.backgroundColor = color;
                _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
                _contentView.layer.borderWidth = 1.f;
                _contentView.layer.cornerRadius = 10.f;

                _controller = nil;
                
                _parentView = parentView;
            }
        }
        else
        {
            if (self = [self initWithFrame:CGRectMake(0, 0, parentView.width, parentView.height)])
            {
                [self addSubview:view];
                
                _contentView = view;
                _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                _contentView.clipsToBounds = YES;
                _contentView.layer.masksToBounds = YES;
                _contentView.backgroundColor = color;
                _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
                _contentView.layer.borderWidth = 1.f;
                _contentView.layer.cornerRadius = 10.f;

                _controller = nil;
                
                _parentView = parentView;
            }
        }
    }
    else
    {
        BOOL isPortrait  = NO;
        
        CGAffineTransform transform = parentView.transform;
        
        if(transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0)
        {
            isPortrait = YES;
        }
        else if(transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0)
        {
            isPortrait = YES;
        }
        
        if (isPortrait)
        {
            if (self = [self initWithFrame:CGRectMake(0, 0, parentView.height, parentView.width)])
            {
                [self addSubview:view];
                
                _contentView = view;
                _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                _contentView.clipsToBounds = YES;
                _contentView.layer.masksToBounds = YES;
                _contentView.backgroundColor = color;
                _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
                _contentView.layer.borderWidth = 1.f;
                _contentView.layer.cornerRadius = 10.f;
                
                _controller = nil;
                
                _parentView = parentView;
            }
        }
        else
        {
            if (self = [self initWithFrame:CGRectMake(0, 0, parentView.width, parentView.height)])
            {
                [self addSubview:view];
                
                _contentView = view;
                _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                _contentView.clipsToBounds = YES;
                _contentView.layer.masksToBounds = YES;
                _contentView.backgroundColor = color;
                _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
                _contentView.layer.borderWidth = 1.f;
                _contentView.layer.cornerRadius = 10.f;

                _controller = nil;
                
                _parentView = parentView;
            }
        }
    }
    
    return self;
}

- (id)initWithParentView:(UIView*)parentView view:(UIView*)view isCenter:(BOOL)centerFlag
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        BOOL isPortrait  = NO;
        
        CGAffineTransform transform = parentView.transform;
        
        if(transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0)
        {
            isPortrait = YES;
        }
        else if(transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0)
        {
            isPortrait = YES;
        }

        if (isPortrait)
        {
            if (self = [self initWithFrame:CGRectMake(0, 0, parentView.height, parentView.width)])
            {
                [self addSubview:view];
                
                _contentView = view;
                _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                _contentView.clipsToBounds = YES;
                _contentView.layer.masksToBounds = YES;
                _contentView.backgroundColor = [UIColor blackColor];
                _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
                _contentView.layer.borderWidth = 1.f;
                _contentView.layer.cornerRadius = 10.f;

                if (!centerFlag)
                {
                    _contentView.center = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width/2.0f - _contentView.frame.size.width/2.0f - _dismissButton.frame.size.width/2.0f, CGRectGetMidY(self.frame) + self.frame.size.height/2.0f - _contentView.frame.size.height/2.0f - _dismissButton.frame.size.width/2.0f);
                }
                
                _controller = nil;
                
                _parentView = parentView;
                
                _dismissButton.center = CGPointMake(view.left, view.top);
                [self addSubview:_dismissButton];
            }
        }
        else
        {
            if (self = [self initWithFrame:CGRectMake(0, 0, parentView.width, parentView.height)])
            {
                [self addSubview:view];
                
                _contentView = view;
                _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                _contentView.clipsToBounds = YES;
                _contentView.layer.masksToBounds = YES;
                _contentView.backgroundColor = [UIColor blackColor];
                _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
                _contentView.layer.borderWidth = 1.f;
                _contentView.layer.cornerRadius = 10.f;

                if (!centerFlag)
                {
                    _contentView.center = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width/2.0f - _contentView.frame.size.width/2.0f - _dismissButton.frame.size.width/2.0f, CGRectGetMidY(self.frame) + self.frame.size.height/2.0f - _contentView.frame.size.height/2.0f - _dismissButton.frame.size.width/2.0f);
                }

                _controller = nil;
                
                _parentView = parentView;
                
                _dismissButton.center = CGPointMake(view.left, view.top);
                [self addSubview:_dismissButton];
            }
        }
    }
    else
    {
        BOOL isPortrait  = NO;
        CGAffineTransform transform = parentView.transform;

        if(transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0)
        {
            isPortrait = YES;
        }
        else if(transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0)
        {
            isPortrait = YES;
        }
        
        if (isPortrait)
        {
            if (self = [self initWithFrame:CGRectMake(0, 0, parentView.height, parentView.width)])
            {
                [self addSubview:view];
                
                _contentView = view;
                _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                _contentView.clipsToBounds = YES;
                _contentView.layer.masksToBounds = YES;
                _contentView.backgroundColor = [UIColor blackColor];
                _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
                _contentView.layer.borderWidth = 1.f;
                _contentView.layer.cornerRadius = 10.f;

                if (!centerFlag)
                {
                    _contentView.center = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width/2.0f - _contentView.frame.size.width/2.0f - _dismissButton.frame.size.width/2.0f, CGRectGetMidY(self.frame) + self.frame.size.height/2.0f - _contentView.frame.size.height/2.0f - _dismissButton.frame.size.width/2.0f);
                }

                _controller = nil;
                _parentView = parentView;
                
                _dismissButton.center = CGPointMake(view.left, view.top);
                [self addSubview:_dismissButton];
            }
        }
        else
        {
            if (self = [self initWithFrame:CGRectMake(0, 0, parentView.width, parentView.height)])
            {
                [self addSubview:view];
                
                _contentView = view;
                _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
                _contentView.clipsToBounds = YES;
                _contentView.layer.masksToBounds = YES;
                _contentView.backgroundColor = [UIColor blackColor];
                _contentView.layer.borderColor = [UIColor whiteColor].CGColor;
                _contentView.layer.borderWidth = 1.f;
                _contentView.layer.cornerRadius = 10.f;

                if (!centerFlag)
                {
                    _contentView.center = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width/2.0f - _contentView.frame.size.width/2.0f - _dismissButton.frame.size.width/2.0f, CGRectGetMidY(self.frame) + self.frame.size.height/2.0f - _contentView.frame.size.height/2.0f - _dismissButton.frame.size.width/2.0f);
                }

                _controller = nil;
                _parentView = parentView;
                
                _dismissButton.center = CGPointMake(view.left, view.top);
                [self addSubview:_dismissButton];
            }
        }
    }

    return self;
}

- (id)initWithParentView:(UIView*)parentView title:(NSString*)title message:(NSString*)message isCenter:(BOOL)centerFlag
{
    UIView *view = [CustomModalView generateModalViewWithTitle:title message:message];

    if (self = [self initWithParentView:parentView view:view isCenter:centerFlag])
    {
        // nothing to see here
    }
    
    return self;
}

- (id)initWithTitle:(NSString*)title message:(NSString*)message isCenter:(BOOL)centerFlag
{
    UIView *view = [CustomModalView generateModalViewWithTitle:title message:message];
    
    if (self = [self initWithView:view isCenter:centerFlag])
    {
        // nothing to see here
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat centerX = self.dismissButtonRight ? _contentView.right : _contentView.left;
    _dismissButton.center = CGPointMake(centerX, _contentView.top);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview)
    {
        self.center = CGPointMake(CGRectGetMidX(newSuperview.frame), CGRectGetMidY(newSuperview.frame));
    }
}

- (void)orientationDidChangeNotification:(NSNotification*)notification
{
	if ([self isVisible])
    {
		[self performSelector:@selector(updateSubviews) withObject:nil afterDelay:0.3f];
	}
}

- (void)updateSubviews
{
    self.hidden = YES;
    
    // get new screenshot after orientation
    [_blurView removeFromSuperview]; _blurView = nil;
    
    if (_controller)
    {
        _blurView = [[UIView alloc] initWithFrame:self.frame];
        _blurView.backgroundColor = [UIColor blackColor];
        _blurView.alpha = 0.0f;
        [_controller.view insertSubview:_blurView belowSubview:self];
    }
    else if(_parentView)
    {
        _blurView = [[UIView alloc] initWithFrame:self.frame];
        _blurView.alpha = 0.0f;
        [_parentView insertSubview:_blurView belowSubview:self];
    }
    
    self.hidden = NO;

    _contentView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    _dismissButton.center = _contentView.origin;
}

- (void)show
{
    [self showWithDuration:kCustomDefaultDuration delay:0 options:kNilOptions completion:NULL];
}

- (void)showWithDuration:(CGFloat)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options completion:(void (^)(void))completion
{
    self.animationDuration = duration;
    self.animationDelay = 0;
    self.animationOptions = options;
    _completion = [completion copy];
    
    // delay so we dont get button states
    [self performSelector:@selector(delayedShow) withObject:nil afterDelay:kCustomDefaultDelay];
}

- (void)delayedShow
{
    if (! self.isVisible)
    {
        if (! self.superview)
        {
            if (_controller)
            {
                self.frame = CGRectMake(0, 0, _controller.view.bounds.size.width, _controller.view.bounds.size.height);
                [_controller.view addSubview:self];
            }
            else if(_parentView)
            {
                self.frame = CGRectMake(0, 0, _parentView.bounds.size.width, _parentView.bounds.size.height);

                [_parentView addSubview:self];
            }
            self.top = 0;
        }
        
        if (_controller)
        {
            _blurView = [[UIView alloc] initWithFrame:_controller.view.bounds];
            _blurView.backgroundColor = [UIColor blackColor];
            _blurView.alpha = 0.f;
            self.frame = CGRectMake(0, 0, _controller.view.bounds.size.width, _controller.view.bounds.size.height);

            [_controller.view insertSubview:_blurView belowSubview:self];
        }
        else if(_parentView)
        {
            _blurView = [[UIView alloc] initWithFrame:_parentView.bounds];
            _blurView.backgroundColor = [UIColor blackColor];
            _blurView.alpha = 0.f;
            self.frame = CGRectMake(0, 0, _parentView.bounds.size.width, _parentView.bounds.size.height);

            [_parentView insertSubview:_blurView belowSubview:self];
        }
        
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
        
        CustomCompletion __completion = _completion;
        UIView *__blurView = _blurView;
        [UIView animateWithDuration:self.animationDuration animations:^{
            __blurView.alpha = 0.0f;
            self.alpha = 1.f;
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.f, 1.f);
        } completion:^(BOOL finished) {
            
            if (finished)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCustomDidShowNotification object:nil];
                
                self.isVisible = YES;
                
                if (__completion)
                {
                    __completion();
                }
            }
        }];
    }
}

- (void)didTappedCloseButton:(id)sender
{
    [self hideCustomModalView];

    if ([self.delegate respondsToSelector:@selector(didClosedCustomModalView)])
    {
        [self.delegate didClosedCustomModalView];
    }
}

- (void)hideCustomModalView
{
    self.alpha = 0.f;
    _blurView.alpha = 0.f;
    
    if (_blurView != nil)
    {
        [_blurView removeFromSuperview];
        _blurView = nil;
    }
    
    if (_dismissButton != nil)
    {
        [_dismissButton removeFromSuperview];
        _dismissButton = nil;
    }
    
    if (_blurView != nil)
    {
        [_blurView removeFromSuperview];
        _blurView = nil;
    }
    
    if (_contentView != nil)
    {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    
    [self removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCustomDidHidewNotification object:nil];
    
    self.isVisible = NO;
}

-(void)hideCloseButton:(BOOL)hide
{
    [_dismissButton setHidden:hide];
}


@end

#pragma mark - CustomView

@implementation CustomView
{
    UIView *_coverView;
}

- (id)initWithCoverView:(UIView *)view
{
    if (self = [super initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)])
    {
        _coverView = view;
        UIImage *blur = [_coverView screenshot];
        self.image = [blur boxblurImageWithBlur:kRNDefaultBlurScale];
    }
    
    return self;
}

@end

#pragma mark - UILabel + Autosize

@implementation UILabel (AutoSize)

- (void)autoHeight
{
    CGRect frame = self.frame;
    CGSize maxSize = CGSizeMake(frame.size.width, 9999);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{ NSFontAttributeName: self.font, NSParagraphStyleAttributeName: paragraphStyle };
    
    CGSize expectedSize = [self.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    frame.size.height = expectedSize.height;
    
    [self setFrame:frame];
}

@end

#pragma mark - UIView + Sizes

@implementation UIView (Sizes)

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end

#pragma mark - RNCloseButton

@implementation RNCloseButton

- (id)init
{
    if(!(self = [super initWithFrame:(CGRect){0, 0, 32, 32}]))
    {
        return nil;
    }
    
    static UIImage *closeButtonImage;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        closeButtonImage = [self closeButtonImage];
    });
    
    [self setBackgroundImage:closeButtonImage forState:UIControlStateNormal];
    self.accessibilityTraits |= UIAccessibilityTraitButton;
    self.accessibilityLabel = NSLocalizedString(@"Dismiss Alert", @"Dismiss Alert Close Button");
    self.accessibilityHint = NSLocalizedString(@"Dismisses this alert.",@"Dismiss Alert close button hint");
    return self;
}

- (UIImage *)closeButtonImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor *topGradient = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:0.9];
    UIColor *bottomGradient = [UIColor colorWithRed:0.03 green:0.03 blue:0.03 alpha:0.9];
    
    //// Gradient Declarations
    NSArray *gradientColors = @[(id)topGradient.CGColor,
    (id)bottomGradient.CGColor];
    CGFloat gradientLocations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    //// Shadow Declarations
    CGColorRef shadow = [UIColor blackColor].CGColor;
    CGSize shadowOffset = CGSizeMake(0, 1);
    CGFloat shadowBlurRadius = 3;
    CGColorRef shadow2 = [UIColor blackColor].CGColor;
    CGSize shadow2Offset = CGSizeMake(0, 1);
    CGFloat shadow2BlurRadius = 0;
    
    //// Oval Drawing
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(4, 3, 24, 24)];
    CGContextSaveGState(context);
    [ovalPath addClip];
    CGContextDrawLinearGradient(context, gradient, CGPointMake(16, 3), CGPointMake(16, 27), 0);
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow);
    [[UIColor whiteColor] setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    CGContextRestoreGState(context);
    
    //// Bezier Drawing
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(22.36, 11.46)];
    [bezierPath addLineToPoint:CGPointMake(18.83, 15)];
    [bezierPath addLineToPoint:CGPointMake(22.36, 18.54)];
    [bezierPath addLineToPoint:CGPointMake(19.54, 21.36)];
    [bezierPath addLineToPoint:CGPointMake(16, 17.83)];
    [bezierPath addLineToPoint:CGPointMake(12.46, 21.36)];
    [bezierPath addLineToPoint:CGPointMake(9.64, 18.54)];
    [bezierPath addLineToPoint:CGPointMake(13.17, 15)];
    [bezierPath addLineToPoint:CGPointMake(9.64, 11.46)];
    [bezierPath addLineToPoint:CGPointMake(12.46, 8.64)];
    [bezierPath addLineToPoint:CGPointMake(16, 12.17)];
    [bezierPath addLineToPoint:CGPointMake(19.54, 8.64)];
    [bezierPath addLineToPoint:CGPointMake(22.36, 11.46)];
    [bezierPath closePath];
    
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2);
    [[UIColor whiteColor] setFill];
    [bezierPath fill];
    CGContextRestoreGState(context);
    
    //// Cleanup
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

#pragma mark - UIView + Screenshot

@implementation UIView (Screenshot)

- (UIImage*)screenshot
{
    UIGraphicsBeginImageContext(self.bounds.size);
    
    if( [self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)] )
    {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    }
    else
    {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // hack, helps w/ our colors when blurring
    NSData *imageData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
    image = [UIImage imageWithData:imageData];
    
    return image;
}

@end

#pragma mark - UIImage + Blur

@implementation UIImage (Blur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur
{
    if (blur < 0.f || blur > 1.f)
    {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);

    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
