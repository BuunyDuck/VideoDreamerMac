//
//  VideoCompositor.m
//  Blend
//
//  Created by Yinjing Li on 1/13/22.
//  Copyright © 2022 TotoVentures. All rights reserved.
//

#import "VideoFilterCompositor.h"
#import <CoreImage/CoreImage.h>

#import "VideoFiltersView.h"
#import "Definition.h"

@interface VideoFilterCompositor () {
    AVVideoCompositionRenderContext *renderContext;
    CIContext *context;
    CGColorSpaceRef deviceColorSpace;
}

@end

@implementation VideoFilterCompositor

@synthesize requiredPixelBufferAttributesForRenderContext;
@synthesize sourcePixelBufferAttributes;

- (instancetype)init {
    self = [super init];
    if (self) {
        requiredPixelBufferAttributesForRenderContext = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        sourcePixelBufferAttributes = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        
        context = [CIContext context];
        deviceColorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return self;
}

- (void)renderContextChanged:(nonnull AVVideoCompositionRenderContext *)newRenderContext {
    renderContext = newRenderContext;
}

- (void)cancelAllPendingVideoCompositionRequests {
    
}

- (void)startVideoCompositionRequest:(nonnull AVAsynchronousVideoCompositionRequest *)asyncVideoCompositionRequest {
    CVPixelBufferRef sourceFrame = [asyncVideoCompositionRequest sourceFrameByTrackID:[[asyncVideoCompositionRequest.sourceTrackIDs lastObject] intValue]];
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:sourceFrame];
    CIFilter *filter = [[VideoFiltersView sharedInstance] setupFilterWithSize:sourceImage.extent.size];
    if (filter != nil) {
        if ([VideoFiltersView sharedInstance].filterIndex == FILTER_GAUSSIAN_POSITION) {
            CIImage *blurImage = filter.outputImage;
            sourceImage = [blurImage imageByCompositingOverImage:sourceImage];
        } else {
            [filter setValue:sourceImage forKey:kCIInputImageKey];
            sourceImage = filter.outputImage;
            if ([VideoFiltersView sharedInstance].filterIndex == FILTER_SKETCH) {
                sourceImage = [sourceImage imageByCompositingOverImage:[VideoFiltersView sharedInstance].whiteImage];
            }
        }
    }
    
    CVPixelBufferRef buffer = [renderContext newPixelBuffer];
    [context render:sourceImage toCVPixelBuffer:buffer];
    [asyncVideoCompositionRequest finishWithComposedVideoFrame:buffer];
    CVPixelBufferRelease(buffer);
}

@end
