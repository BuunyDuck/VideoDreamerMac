//
//  SASliderView.m
//  VideoFrame
//
//  Created by YinjingLi on 10/2/15.
//  Copyright © 2015 Yinjing Li. All rights reserved.
//

#import "SASliderView.h"
#import "Definition.h"
#import "SceneDelegate.h"

@implementation SASliderView


#pragma mark - 
#pragma mark - Init

- (id)initWithFrame:(CGRect)frame width:(CGFloat) thumbWidth sec:(Float64) duration value:(CGFloat) motionValue
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        red = arc4random() % 255 / 255.0;
        green = arc4random() % 255 / 255.0;
        blue = arc4random() % 255 / 255.0;

        self.myAssetDuration = duration;
        self.motionValue = motionValue;
        self.leftPos = self.frame.origin.x;
        self.rightPos = self.frame.size.width;
        
        self.isGestureProcessing = NO;        
        
        UIPanGestureRecognizer *centerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCenterPan:)];
        [self addGestureRecognizer:centerPan];

        // top border
        self.topBorder = [[UIView alloc] initWithFrame:CGRectMake(3.0f, 0, frame.size.width - 6.0f, SLIDER_BORDERS_SIZE)];
        self.topBorder.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
        [self addSubview:self.topBorder];
        
        //bottom border
        self.bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(3.0f, frame.size.height - SLIDER_BORDERS_SIZE, frame.size.width - 6.0f, SLIDER_BORDERS_SIZE)];
        self.bottomBorder.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
        [self addSubview:self.bottomBorder];
        
        //left thumb view
        self.leftThumb = [[SASliderLeft alloc] initWithFrame:CGRectMake(0, 0, thumbWidth, frame.size.height) red:red green:green blue:blue];
        self.leftThumb.contentMode = UIViewContentModeLeft;
        self.leftThumb.userInteractionEnabled = YES;
        self.leftThumb.clipsToBounds = YES;
        self.leftThumb.backgroundColor = [UIColor clearColor];
        self.leftThumb.layer.borderWidth = 0;
        [self addSubview:self.leftThumb];
        
        UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
        [self.leftThumb addGestureRecognizer:leftPan];
        
        //right thumb view
        self.rightThumb = [[SASliderRight alloc] initWithFrame:CGRectMake(frame.size.width - thumbWidth, 0, thumbWidth, frame.size.height) red:red green:green blue:blue];
        self.rightThumb.contentMode = UIViewContentModeRight;
        self.rightThumb.userInteractionEnabled = YES;
        self.rightThumb.clipsToBounds = YES;
        self.rightThumb.backgroundColor = [UIColor clearColor];
        [self addSubview:self.rightThumb];
        
        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
        [self.rightThumb addGestureRecognizer:rightPan];

        //popover bubble view
        self.popoverBubble = [[SAResizibleBubble alloc] initWithFrame:CGRectMake(0, -50, 100, 50)];
        self.popoverBubble.alpha = 0;
        self.popoverBubble.backgroundColor = [UIColor clearColor];
        [self addSubview:self.popoverBubble];
        
        //bubble text
        self.bubleText = [[UILabel alloc] initWithFrame:self.popoverBubble.frame];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            self.bubleText.font = [UIFont fontWithName:MYRIADPRO size:20];
        else
            self.bubleText.font = [UIFont fontWithName:MYRIADPRO size:12];
        
        self.bubleText.backgroundColor = [UIColor clearColor];
        self.bubleText.textColor = [UIColor blackColor];
        self.bubleText.numberOfLines = 0;
        self.bubleText.textAlignment = NSTextAlignmentCenter;
        [self.popoverBubble addSubview:self.bubleText];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            [self setPopoverBubbleSize:250.0f height:100.0f];
        else
            [self setPopoverBubbleSize:170.0f height:60.0f];
        
        UITapGestureRecognizer *selectGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelected:)];
        selectGesture.delegate = self;
        [self addGestureRecognizer:selectGesture];
        [selectGesture setNumberOfTapsRequired:1];
        
        self.deleteButton = [[YJLCustomDeleteButton alloc] init];
        self.deleteButton.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
        [self.deleteButton addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteButton];
        self.deleteButton.hidden = YES;

        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
        longGesture.delegate = self;
        [self addGestureRecognizer:longGesture];
    }
    
    return self;
}

- (void)handleSelected:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([_delegate respondsToSelector:@selector(didSelectedSASliderView:)])
    {
        [_delegate didSelectedSASliderView:self.nSliderIndex];
    }
    
    [self delegateNotification:CENTER];
}

- (void)delegateNotification:(int)LCR
{
    if ([_delegate respondsToSelector:@selector(didChangeSliderPosition:right:LCR:value:)])
    {
        CGFloat leftPosition = (self.leftPos * self.myAssetDuration / self.superview.frame.size.width);
        CGFloat rightPosition = (self.rightPos * self.myAssetDuration / self.superview.frame.size.width);
        
        [_delegate didChangeSliderPosition:leftPosition right:rightPosition LCR:LCR value:self.motionValue];
    }
}

- (void)updateSlider:(BOOL) isSelected
{
    if (isSelected)
    {
        self.layer.borderColor = [UIColor yellowColor].CGColor;
        self.layer.borderWidth = 5.0f;
    }
    else
    {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 2.0f;
    }
}

- (void) selectedSASliderView
{
    [self delegateNotification:CENTER];
}


#pragma mark -
#pragma mark - Left, Center, Right Moving Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            self.isGestureProcessing = YES;
            
            if ([_delegate respondsToSelector:@selector(checkSelectedGestureProcessing:)])
            {
                self.isGestureProcessing = ![_delegate checkSelectedGestureProcessing:self.nSliderIndex];
            }
            
            if (self.isGestureProcessing && [_delegate respondsToSelector:@selector(didSelectedSASliderView:)])
            {
                [_delegate didSelectedSASliderView:self.nSliderIndex];
                
                _popoverBubble.alpha = 1;
            }
        }
        
        if (self.isGestureProcessing)
        {
            CGPoint translation = [gesture translationInView:self.superview];
            
            self.leftPos += translation.x;
            
            if (self.leftPos < 0.0f)
                self.leftPos = 0.0f;
            
            if ((self.rightPos - self.leftPos) < VIDEO_SLIDER_MIN_WIDTH)
                self.leftPos -= translation.x;
            
            //detect left moving edge
            if ([_delegate respondsToSelector:@selector(requestDetectEdge:)])
            {
                [_delegate requestDetectEdge:LEFT];
            }
            
            [gesture setTranslation:CGPointZero inView:self];
            
            [self setNeedsLayout];
            
            [self delegateNotification:LEFT];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        self.isGestureProcessing = NO;

        [self hideBubble:_popoverBubble];
    }
}

- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            self.isGestureProcessing = YES;

            if ([_delegate respondsToSelector:@selector(checkSelectedGestureProcessing:)])
            {
                self.isGestureProcessing = ![_delegate checkSelectedGestureProcessing:self.nSliderIndex];
            }

            if (self.isGestureProcessing && [_delegate respondsToSelector:@selector(didSelectedSASliderView:)])
            {
                [_delegate didSelectedSASliderView:self.nSliderIndex];
                
                _popoverBubble.alpha = 1;
            }
        }

        if (self.isGestureProcessing)
        {
            CGPoint translation = [gesture translationInView:self.superview];
            
            self.rightPos += translation.x;
            
            if (self.rightPos > self.superview.frame.size.width)
            {
                self.rightPos = self.superview.frame.size.width;
            }
            
            if ((self.rightPos - self.leftPos) < VIDEO_SLIDER_MIN_WIDTH)
                self.rightPos -= translation.x;
            
            //detect right moving edge
            if ([_delegate respondsToSelector:@selector(requestDetectEdge:)])
            {
                [_delegate requestDetectEdge:RIGHT];
            }
            
            [gesture setTranslation:CGPointZero inView:self];
            
            [self setNeedsLayout];
            
            [self delegateNotification:RIGHT];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        self.isGestureProcessing = NO;

        [self hideBubble:_popoverBubble];
    }
}

- (void)handleCenterPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged)
    {
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            self.isGestureProcessing = YES;

            if ([_delegate respondsToSelector:@selector(checkSelectedGestureProcessing:)])
            {
                self.isGestureProcessing = ![_delegate checkSelectedGestureProcessing:self.nSliderIndex];
            }

            if (self.isGestureProcessing && [_delegate respondsToSelector:@selector(didSelectedSASliderView:)])
            {
                [_delegate didSelectedSASliderView:self.nSliderIndex];
                
                _popoverBubble.alpha = 1;
            }
        }

        if (self.isGestureProcessing)
        {
            CGPoint translation = [gesture translationInView:self.superview];
            
            self.leftPos += translation.x;
            self.rightPos += translation.x;
            
            if (self.rightPos > self.superview.frame.size.width || self.leftPos < 0.0f)
            {
                self.leftPos -= translation.x;
                self.rightPos -= translation.x;
            }
            
            if ((self.rightPos - self.leftPos) < VIDEO_SLIDER_MIN_WIDTH)
            {
                self.leftPos -= translation.x;
                self.rightPos -= translation.x;
            }
            
            //detect center moving edge
            if ([_delegate respondsToSelector:@selector(requestDetectEdge:)])
            {
                [_delegate requestDetectEdge:CENTER];
            }
            
            [gesture setTranslation:CGPointZero inView:self];
            
            [self setNeedsLayout];
            
            [self delegateNotification:CENTER];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        self.isGestureProcessing = NO;

        [self hideBubble:_popoverBubble];
    }
}

-(void) handleLongGesture:(UILongPressGestureRecognizer*) gesture
{
    if ((gesture.state == UIGestureRecognizerStateBegan) && [self.delegate respondsToSelector:@selector(didLongPressedSASliderView)])
    {
        [self.delegate didLongPressedSASliderView];
    }
}

- (void)layoutSubviews
{
    self.frame = CGRectMake(self.leftPos, self.frame.origin.y, (self.rightPos - self.leftPos), self.frame.size.height);
    self.leftThumb.center = CGPointMake(self.leftThumb.frame.size.width/2.0f, _leftThumb.frame.size.height/2.0f);
    self.rightThumb.center = CGPointMake(self.frame.size.width - self.rightThumb.frame.size.width/2.0f, _rightThumb.frame.size.height/2);
    self.topBorder.frame = CGRectMake(3.0f, 0, self.frame.size.width - 6.0f, SLIDER_BORDERS_SIZE);
    self.bottomBorder.frame = CGRectMake(3.0f, self.frame.size.height - SLIDER_BORDERS_SIZE, self.frame.size.width - 6.0f, SLIDER_BORDERS_SIZE);
    self.deleteButton.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);

    CGRect frame = self.popoverBubble.frame;
    frame.origin.x = self.frame.size.width/2 - frame.size.width/2;
    _popoverBubble.frame = frame;
}


#pragma mark -
#pragma mark -

- (void)setVideoSliderRangeForEditMotion:(CGFloat) fStart end:(CGFloat)fEnd
{
    self.leftPos = fStart * self.superview.frame.size.width / self.myAssetDuration;
    self.rightPos = fEnd * self.superview.frame.size.width / self.myAssetDuration;
    
    [self delegateNotification:CENTER];

    [self setNeedsLayout];
}

- (void) changedVideoMotion:(CGFloat) value
{
    self.motionValue = value;
}


#pragma mark -
#pragma mark - Bubble

- (void)hideBubble:(UIView *)popover
{
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         
                         self.popoverBubble.alpha = 0;
                     }
                     completion:nil];
}


#pragma mark -
#pragma mark - Private

-(void)setPopoverBubbleSize: (CGFloat) width height:(CGFloat)height
{
    CGRect currentFrame = _popoverBubble.frame;
    currentFrame.size.width = width;
    currentFrame.size.height = height;
    currentFrame.origin.y = -height;
    _popoverBubble.frame = currentFrame;
    currentFrame.origin.x = 0;
    currentFrame.origin.y = 0;
    _bubleText.frame = currentFrame;
}

- (NSString *)timeToString:(CGFloat)time
{
    if (time < 0.0f)
        time = 0.0f;
    
    // time - seconds
    NSInteger min = floor(time / 60);
    NSInteger sec = floor(time - min * 60);
    NSInteger millisecond = roundf((time - (min*60 + sec))*1000);
    
    if (millisecond == 1000)
    {
        millisecond = 0;
        sec++;
    }
    
    NSString *minStr = [NSString stringWithFormat:min >= 10 ? @"%d" : @"0%d", (int)min];
    NSString *secStr = [NSString stringWithFormat:sec >= 10 ? @"%d" : @"0%d", (int)sec];
    
    NSString *millisecStr = nil;
    
    if (millisecond >= 100)
        millisecStr = [NSString stringWithFormat:@"%d", (int)millisecond];
    else if (millisecond >= 10)
        millisecStr = [NSString stringWithFormat:@"0%d", (int)millisecond];
    else
        millisecStr = [NSString stringWithFormat:@"00%d", (int)millisecond];
    
    return [NSString stringWithFormat:@"%@:%@.%@", minStr, secStr, millisecStr];
}

#pragma mark - 
#pragma mark - Update Bubble

- (void) updateBubble:(CGFloat) fStart stop:(CGFloat)fStop
{
    NSString* startTimeStr = [self timeToString:fStart];
    NSString* stopTimeStr = [self timeToString:fStop];
    NSString* durationStr = [self timeToString:(fStop - fStart)];

    self.bubleText.text = [NSString stringWithFormat:@"%@ - %@\n%@", startTimeStr, stopTimeStr, durationStr];
}

-(void)onDelete:(id)sender
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"Delete this segment?", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([self.delegate respondsToSelector:@selector(didDeleteSASliderView:)])
        {
            [self.delegate didDeleteSASliderView:self.nSliderIndex];
        }
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];

    [alertController addAction:okAction];
    [alertController addAction:cancelAction];

    [[SceneDelegate sharedDelegate].navigationController.visibleViewController presentViewController:alertController animated:YES completion:nil];
}

@end
