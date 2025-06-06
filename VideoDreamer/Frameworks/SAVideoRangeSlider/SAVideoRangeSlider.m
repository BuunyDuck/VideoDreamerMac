
#import "SAVideoRangeSlider.h"
#import "Definition.h"
#import "SceneDelegate.h"

@implementation SAVideoRangeSlider

- (id)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl value:(CGFloat) motionValue
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.videoUrl = videoUrl;
        self.motionValue = motionValue;
        self.nSelectedSliderIndex = 0;
        
        thumbWidth = frame.size.width * 0.05f;

        _leftPosition = thumbWidth;
        _rightPosition = frame.size.width - thumbWidth;
        
        self.videoRangeSliderArray = [[NSMutableArray alloc] init];
        
        // background view
        self.bgView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.bgView.layer.borderColor = [UIColor blackColor].CGColor;
        self.bgView.layer.borderWidth = BG_VIEW_BORDERS_SIZE;
        [self addSubview:self.bgView];
        
        [self getMovieFrame];
        
        
        // SASliderView
        self.sliderView = [[SASliderView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) width:thumbWidth sec:self.durationSeconds value:self.motionValue];
        self.sliderView.delegate = self;
        self.sliderView.nSliderIndex = 0;
        [self addSubview:self.sliderView];

        [self.sliderView updateSlider:YES];
        
        [self.videoRangeSliderArray addObject:self.sliderView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
    }
    
    return self;
}

-(BOOL)isRetina
{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale >= 2.0));
}


#pragma mark -
#pragma mark - get & draw Video frames

-(void)getMovieFrame
{
    AVAsset *myAsset = [AVURLAsset URLAssetWithURL:_videoUrl options:nil];
    NSArray *videoDataSourceArray = [NSArray arrayWithArray: [myAsset tracksWithMediaType:AVMediaTypeVideo]];
    
    if (videoDataSourceArray != nil)
    {
        self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
        self.imageGenerator.appliesPreferredTrackTransform = YES;
        self.imageGenerator.maximumSize = CGSizeMake(200, 200);
        
        if ([self isRetina])
            self.imageGenerator.maximumSize = CGSizeMake(_bgView.frame.size.width * 2, _bgView.frame.size.height * 2);
        else
            self.imageGenerator.maximumSize = CGSizeMake(_bgView.frame.size.width, _bgView.frame.size.height);
        
        CGFloat picWidth = 20;
        int picCount = floor(_bgView.frame.size.width / picWidth);
        picWidth = _bgView.frame.size.width / picCount;
        _durationSeconds = CMTimeGetSeconds([myAsset duration]);
        CGFloat offsetSeconds = _durationSeconds / picCount;
        NSMutableArray *arrayTimes = [NSMutableArray array];
        for (int i = 0; i < picCount; i++) {
            [arrayTimes addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(i * offsetSeconds + offsetSeconds / 2.0, myAsset.duration.timescale)]];
        }
        
        __block int index = 0;
        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:arrayTimes completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {

            UIImage *uiImage = nil;
            if (image != nil && result == AVAssetImageGeneratorSucceeded) {
                uiImage = [UIImage imageWithCGImage:image];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = [[UIImageView alloc] initWithImage:uiImage];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                imageView.frame = CGRectMake(index * picWidth, 0, picWidth, self.bgView.frame.size.height);
            
                [self.bgView addSubview:imageView];
                index += 1;
            });
        }];
                
        myAsset = nil;
        
        return;
    }
    
    myAsset = nil;
}

-(void) setChangedMotionValue:(CGFloat) value
{
    self.motionValue = value;
    
    SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex];
    [sliderView changedVideoMotion:value];
}

-(void) setLeftRight:(CGFloat) startPosition end:(CGFloat)endPosition
{
    SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex];
    [sliderView setVideoSliderRangeForEditMotion:startPosition end:endPosition];
}


#pragma mark - 
#pragma mark - SASliderViewDelegate

- (void) didChangeSliderPosition:(CGFloat)fLeftPos right:(CGFloat)fRightPos LCR:(int)type value:(CGFloat)motionValue
{
    if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:LCR:value:)])
    {
        [_delegate videoRange:self didChangeLeftPosition:fLeftPos rightPosition:fRightPos LCR:type value:motionValue];
    }
}

-(BOOL) checkSelectedGestureProcessing:(NSInteger) index
{
    BOOL isExistAnotherSelectedGesture = NO;
    
    for (int i = 0; i < self.videoRangeSliderArray.count; i++)
    {
        SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:i];
        
        if (sliderView.isGestureProcessing && (i != index))
        {
            isExistAnotherSelectedGesture = YES;
            break;
        }
    }
    
    return isExistAnotherSelectedGesture;
}

- (void) didSelectedSASliderView:(NSInteger) index
{
    self.nSelectedSliderIndex = index;
    
    for (int i = 0; i < self.videoRangeSliderArray.count; i++)
    {
        SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:i];
        
        if (i == self.nSelectedSliderIndex)
        {
            [sliderView updateSlider:YES];
        }
        else
        {
            [sliderView updateSlider:NO];
        }
        
        sliderView.deleteButton.hidden = YES;
    }
    
    SASliderView* selectedSliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex];
    self.motionValue = selectedSliderView.motionValue;
}

- (void) requestDetectEdge:(int) LCR
{
    SASliderView* selectedSliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex];

    if (self.nSelectedSliderIndex == 0)
    {
        if (self.videoRangeSliderArray.count > 1)
        {
            SASliderView* nextSliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex+1];

            if (selectedSliderView.rightPos > nextSliderView.leftPos)
            {
                if (LCR == CENTER)
                {
                    CGFloat deltaPos = selectedSliderView.rightPos - nextSliderView.leftPos;
                    selectedSliderView.leftPos -= deltaPos;
                    selectedSliderView.rightPos = nextSliderView.leftPos;
                }
                else
                {
                    selectedSliderView.rightPos = nextSliderView.leftPos;
                }
            }
        }
    }
    else if (self.nSelectedSliderIndex == self.videoRangeSliderArray.count-1)
    {
        if (self.videoRangeSliderArray.count > 1)
        {
            SASliderView* prevSliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex-1];

            if (selectedSliderView.leftPos < prevSliderView.rightPos)
            {
                if (LCR == CENTER)
                {
                    CGFloat deltaPos = prevSliderView.rightPos - selectedSliderView.leftPos;
                    selectedSliderView.rightPos += deltaPos;
                    selectedSliderView.leftPos = prevSliderView.rightPos;
                }
                else
                {
                    selectedSliderView.leftPos = prevSliderView.rightPos;
                }
            }
        }
    }
    else
    {
        SASliderView* prevSliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex-1];
        SASliderView* nextSliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex+1];

        if (selectedSliderView.leftPos < prevSliderView.rightPos)
        {
            if (LCR == CENTER)
            {
                CGFloat deltaPos = prevSliderView.rightPos - selectedSliderView.leftPos;
                selectedSliderView.rightPos += deltaPos;
                selectedSliderView.leftPos = prevSliderView.rightPos;
            }
            else
            {
                selectedSliderView.leftPos = prevSliderView.rightPos;
            }
        }

        if (selectedSliderView.rightPos > nextSliderView.leftPos)
        {
            if (LCR == CENTER)
            {
                CGFloat deltaPos = selectedSliderView.rightPos - nextSliderView.leftPos;
                selectedSliderView.leftPos -= deltaPos;
                selectedSliderView.rightPos = nextSliderView.leftPos;
            }
            else
            {
                selectedSliderView.rightPos = nextSliderView.leftPos;
            }
        }
    }
}

- (void) didLongPressedSASliderView;
{
    if (self.videoRangeSliderArray.count > 1)
    {
        for (int i = 0; i < self.videoRangeSliderArray.count; i++)
        {
            SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:i];

            sliderView.deleteButton.hidden = NO;
        }
    }
}

- (void) didDeleteSASliderView:(NSInteger) index
{
    [self deleteVideoRangeSlider:index];
}


#pragma mark -
#pragma mark - Add / Delete video range slider

-(BOOL) addNewVideoRangeSlider
{
    if (![self isAvailableAddNewSegment])
    {
        [[SceneDelegate sharedDelegate].navigationController.visibleViewController showAlertViewController:NSLocalizedString(@"Video Dreamer", nil) message:NSLocalizedString(@"There is no room for another segment without making existing segment smaller.", nil) okHandler:nil];
        
        return NO;
    }
    else
    {
        self.motionValue = 0.5f;

        SASliderView* mySASliderView = [[SASliderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) width:thumbWidth sec:self.durationSeconds value:self.motionValue];
        mySASliderView.delegate = self;
        mySASliderView.nSliderIndex = self.videoRangeSliderArray.count;
        [self addSubview:mySASliderView];
        
        if (mnNewSegmentIndex == self.videoRangeSliderArray.count)
            [self.videoRangeSliderArray addObject:mySASliderView];
        else
            [self.videoRangeSliderArray insertObject:mySASliderView atIndex:mnNewSegmentIndex];
        
        for (int i = 0; i < self.videoRangeSliderArray.count; i++)
        {
            SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:i];
            sliderView.nSliderIndex = i;
        }
        
        [mySASliderView setVideoSliderRangeForEditMotion:mfNewSegmentLeftPos end:mfNewSegmentRightPos];

        self.nSelectedSliderIndex = mnNewSegmentIndex;

        for (int i = 0; i < self.videoRangeSliderArray.count; i++)
        {
            SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:i];
            
            if (i == self.nSelectedSliderIndex)
                [sliderView updateSlider:YES];
            else
                [sliderView updateSlider:NO];
            
            sliderView.deleteButton.hidden = YES;
        }
        
        SASliderView* selectedSliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex];
        [selectedSliderView selectedSASliderView];
    }
    
    return YES;
}

-(BOOL) isAvailableAddNewSegment
{
    BOOL isHaveFreeRoom = NO;
    
    mfNewSegmentLeftPos = 0.0f;
    mfNewSegmentRightPos = 0.0f;
    mnNewSegmentIndex = 0;
    
    for (int i = 0; i < self.videoRangeSliderArray.count; i++)
    {
        SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:i];

        if (i == 0)
        {
            if ((int)(sliderView.leftPos) > VIDEO_SLIDER_MIN_WIDTH)
            {
                CGFloat rightPos = sliderView.leftPos * self.durationSeconds / self.frame.size.width;
                
                if (rightPos > (mfNewSegmentRightPos - mfNewSegmentLeftPos))
                {
                    isHaveFreeRoom = YES;
                    
                    mfNewSegmentLeftPos = 0.0f;
                    mfNewSegmentRightPos = rightPos;
                    mnNewSegmentIndex = 0;
                }
            }
            
            if ((self.videoRangeSliderArray.count == 1) && ((int)(fabs(self.frame.size.width - sliderView.rightPos)) > VIDEO_SLIDER_MIN_WIDTH))
            {
                CGFloat leftPos = sliderView.rightPos * self.durationSeconds / self.frame.size.width;
                CGFloat rightPos = self.durationSeconds;
                
                if ((rightPos - leftPos) > (mfNewSegmentRightPos - mfNewSegmentLeftPos))
                {
                    isHaveFreeRoom = YES;
                    
                    mfNewSegmentLeftPos = leftPos;
                    mfNewSegmentRightPos = rightPos;
                    mnNewSegmentIndex = self.videoRangeSliderArray.count;
                }
            }
        }
        else
        {
            SASliderView* prevSliderView = [self.videoRangeSliderArray objectAtIndex:i-1];
            
            if ((int)(sliderView.leftPos - prevSliderView.rightPos) > VIDEO_SLIDER_MIN_WIDTH)
            {
                CGFloat leftPos = prevSliderView.rightPos * self.durationSeconds / self.frame.size.width;
                CGFloat rightPos = sliderView.leftPos * self.durationSeconds / self.frame.size.width;
                
                if ((rightPos - leftPos) > (mfNewSegmentRightPos - mfNewSegmentLeftPos))
                {
                    isHaveFreeRoom = YES;
                    
                    mfNewSegmentLeftPos = leftPos;
                    mfNewSegmentRightPos = rightPos;
                    mnNewSegmentIndex = i;
                }
            }
            
            if (i == self.videoRangeSliderArray.count-1)
            {
                if ((int)(fabs(self.frame.size.width - sliderView.rightPos)) > VIDEO_SLIDER_MIN_WIDTH)
                {
                    CGFloat leftPos = sliderView.rightPos * self.durationSeconds / self.frame.size.width;
                    CGFloat rightPos = self.durationSeconds;
                    
                    if ((rightPos - leftPos) > (mfNewSegmentRightPos - mfNewSegmentLeftPos))
                    {
                        isHaveFreeRoom = YES;
                        
                        mfNewSegmentLeftPos = leftPos;
                        mfNewSegmentRightPos = rightPos;
                        mnNewSegmentIndex = self.videoRangeSliderArray.count;
                    }
                }
            }
        }
    }
    
    return isHaveFreeRoom;
}

-(void) deleteVideoRangeSlider:(NSInteger) index
{
    SASliderView* removeSliderView = [self.videoRangeSliderArray objectAtIndex:index];
    [removeSliderView removeFromSuperview];
    
    [self.videoRangeSliderArray removeObjectAtIndex:index];
    
    if (index >= self.videoRangeSliderArray.count)
        self.nSelectedSliderIndex = self.videoRangeSliderArray.count-1;
    else
        self.nSelectedSliderIndex = index;
    
    SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex];
    
    CGFloat leftPosition = sliderView.leftPos * self.durationSeconds / self.frame.size.width;
    CGFloat rightPosition = sliderView.rightPos * self.durationSeconds / self.frame.size.width;
    
    [sliderView setVideoSliderRangeForEditMotion:leftPosition end:rightPosition];
    
    for (int i = 0; i < self.videoRangeSliderArray.count; i++)
    {
        SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:i];
        sliderView.nSliderIndex = i;

        if (i == self.nSelectedSliderIndex)
            [sliderView updateSlider:YES];
        else
            [sliderView updateSlider:NO];
        
        sliderView.deleteButton.hidden = YES;
    }
    
    if ([_delegate respondsToSelector:@selector(fetchSASliderViews)])
    {
        [_delegate fetchSASliderViews];
    }
}


#pragma mark - 
#pragma mark - update selected bubble

-(void) updateSelectedRangeBubble
{
    if (self.nSelectedSliderIndex >= self.videoRangeSliderArray.count)
        self.nSelectedSliderIndex = self.videoRangeSliderArray.count - 1;
    
    CGFloat startPos = 0.0f;
    CGFloat stopPos = 0.0f;
    
    for (int i = 0; i < self.videoRangeSliderArray.count; i++)
    {
        if (i == 0)
        {
            SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:i];
            CGFloat leftPosition = (sliderView.leftPos * self.durationSeconds / self.frame.size.width);
            CGFloat rightPosition = (sliderView.rightPos * self.durationSeconds / self.frame.size.width);
            CGFloat totalDuration = (rightPosition - leftPosition)/sliderView.motionValue;
            
            if (i == self.nSelectedSliderIndex)
            {
                startPos = leftPosition;
                stopPos = leftPosition + totalDuration;
                
                break;
            }
            else
            {
                startPos = leftPosition + totalDuration;
            }
        }
        else
        {
            SASliderView* prevSliderView = [self.videoRangeSliderArray objectAtIndex:i-1];
            CGFloat prevRightPosition = (prevSliderView.rightPos * self.durationSeconds / self.frame.size.width);

            SASliderView* sliderView = [self.videoRangeSliderArray objectAtIndex:i];
            CGFloat leftPosition = (sliderView.leftPos * self.durationSeconds / self.frame.size.width);
            CGFloat rightPosition = (sliderView.rightPos * self.durationSeconds / self.frame.size.width);
            CGFloat totalDuration = (rightPosition - leftPosition)/sliderView.motionValue;
            
            if (leftPosition > prevRightPosition)
                startPos += (leftPosition - prevRightPosition);
            
            if (i == self.nSelectedSliderIndex)
            {
                stopPos = startPos + totalDuration;
                
                break;
            }
            else
            {
                startPos += totalDuration;
            }
        }
    }
    
    SASliderView* selectedSliderView = [self.videoRangeSliderArray objectAtIndex:self.nSelectedSliderIndex];
    
    [selectedSliderView updateBubble:startPos stop:stopPos];
}

@end
