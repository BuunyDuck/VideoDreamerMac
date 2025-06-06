
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#import "SASliderView.h"


@protocol SAVideoRangeSliderDelegate;

@interface SAVideoRangeSlider : UIView <SASliderViewDelegate>
{
    float thumbWidth;
    
    CGFloat mfNewSegmentLeftPos;
    CGFloat mfNewSegmentRightPos;
    NSInteger mnNewSegmentIndex;
}

@property (nonatomic, weak) id <SAVideoRangeSliderDelegate> delegate;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) SASliderView *sliderView;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic, strong) NSMutableArray* videoRangeSliderArray;

@property (nonatomic, assign) Float64 durationSeconds;
@property (nonatomic, assign) CGFloat leftPosition;
@property (nonatomic, assign) CGFloat rightPosition;
@property (nonatomic, assign) CGFloat motionValue;

@property (nonatomic, assign) NSInteger nSelectedSliderIndex;


-(id) initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl value:(CGFloat) motionValue;
-(void) setChangedMotionValue:(CGFloat) value;
-(void) setLeftRight:(CGFloat) startPosition end:(CGFloat)endPosition;  // call from VideoMotionView
-(BOOL) addNewVideoRangeSlider;
-(void) deleteVideoRangeSlider:(NSInteger) index;
-(void) updateSelectedRangeBubble;

@end


@protocol SAVideoRangeSliderDelegate <NSObject>

@optional

-(void) videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition LCR:(int)leftCenterRight value:(CGFloat) motionValue;

-(void) fetchSASliderViews;

@end




