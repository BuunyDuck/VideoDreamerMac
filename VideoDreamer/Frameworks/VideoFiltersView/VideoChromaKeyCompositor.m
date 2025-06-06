//
//  VideoCompositor.m
//  Blend
//
//  Created by Yinjing Li on 1/13/22.
//  Copyright © 2022 TotoVentures. All rights reserved.
//

#import "VideoChromaKeyCompositor.h"
#import <CoreImage/CoreImage.h>
//#import "ChromaKeyFilter.h"
#import "VideoDreamer-Swift.h"
#import "Definition.h"

void rgbToHSV(float rgb[3], float hsv[3])
{
    float min, max, delta;
    float r = rgb[0], g = rgb[1], b = rgb[2];
    //float *h = hsv[0], *s = hsv[1], *v = hsv[2];

    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    hsv[2] = max;               // v
    delta = max - min;
    if( max != 0 )
        hsv[1] = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        hsv[1] = 0;
        hsv[0] = -1;
        return;
    }
    if( r == max )
        hsv[0] = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        hsv[0] = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        hsv[0] = 4 + ( r - g ) / delta; // between magenta & cyan
    hsv[0] *= 60;               // degrees
    if( hsv[0] < 0 )
        hsv[0] += 360;
    hsv[0] /= 360.0;
}

void hsvToRGB(float hsv[3], float rgb[3])
{
    float C = hsv[2] * hsv[1];
    float HS = hsv[0] * 6.0;
    float X = C * (1.0 - fabs(fmodf(HS, 2.0) - 1.0));

    if (HS >= 0 && HS < 1)
    {
        rgb[0] = C;
        rgb[1] = X;
        rgb[2] = 0;
    }
    else if (HS >= 1 && HS < 2)
    {
        rgb[0] = X;
        rgb[1] = C;
        rgb[2] = 0;
    }
    else if (HS >= 2 && HS < 3)
    {
        rgb[0] = 0;
        rgb[1] = C;
        rgb[2] = X;
    }
    else if (HS >= 3 && HS < 4)
    {
        rgb[0] = 0;
        rgb[1] = X;
        rgb[2] = C;
    }
    else if (HS >= 4 && HS < 5)
    {
        rgb[0] = X;
        rgb[1] = 0;
        rgb[2] = C;
    }
    else if (HS >= 5 && HS < 6)
    {
        rgb[0] = C;
        rgb[1] = 0;
        rgb[2] = X;
    }
    else {
        rgb[0] = 0.0;
        rgb[1] = 0.0;
        rgb[2] = 0.0;
    }


    float m = hsv[2] - C;
    rgb[0] += m;
    rgb[1] += m;
    rgb[2] += m;
}

@interface VideoChromaKeyCompositor () {
    AVVideoCompositionRenderContext *renderContext;
    CIContext *context;
    CGColorSpaceRef deviceColorSpace;
    //ChromaKeyFilter *filter;
    CIFilter *chromakeyFilter;
    CIFilter *compositorFilter;
}

@end

@implementation VideoChromaKeyCompositor

@synthesize requiredPixelBufferAttributesForRenderContext;
@synthesize sourcePixelBufferAttributes;

- (instancetype)init {
    self = [super init];
    if (self) {
        requiredPixelBufferAttributesForRenderContext = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        sourcePixelBufferAttributes = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        
        context = [CIContext context];
        deviceColorSpace = CGColorSpaceCreateDeviceRGB();
        //filter = [[ChromaKeyFilter alloc] init];
        //filter = [self chromaKeyFilter:0.3 toHue:0.4];
        //NSLog(@"%@", [VideoFilterManager shared].mediaObjectView);
        MediaObjectView *objectView = [VideoFilterManager shared].mediaObjectView;
        UIColor *chromaKeyColor = objectView.objectChromaColor;
        if (objectView.objectChromaType == ChromakeyTypeStandard) {
            CGFloat offset = 0.0166666666667;
            CGFloat hue = [[VideoFilterManager shared] getHueWithColor:chromaKeyColor];
            hue += offset;
            CGFloat minHue = hue;// - 0.05; // 0.3 for green color
            CGFloat maxHue = hue;// + 0.05; // 0.4 for green color
            minHue -= objectView.objectChromaTolerance / TOLERANCE_SCALE;
            maxHue += objectView.objectChromaTolerance / TOLERANCE_SCALE;
            chromakeyFilter = [[VideoFilterManager shared] chromaKeyFilterFromHue:minHue toHue:maxHue edges:objectView.objectChromaEdges opacity:objectView.objectChromaOpacity];
        } else {
            CGFloat red;
            CGFloat green;
            CGFloat blue;
            [chromaKeyColor getRed:&red green:&green blue:&blue alpha:nil];
            if (@available(iOS 13.0, *)) {
                chromakeyFilter = [[VideoFilterManager shared] chromaKeyFilterWithTargetRed:red green:green blue:blue threshold:objectView.objectChromaTolerance opacity:objectView.objectChromaOpacity];
            }
            //NSLog(@"%f", red);
            //NSLog(@"%f", green);
            //NSLog(@"%f", blue);
            //NSLog(@"%f", objectView.objectChromaTolerance);
            //NSLog(@"%f", objectView.objectChromaOpacity);
        }
        compositorFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
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
    //filter.inputImage = sourceImage;
    sourceImage = [[VideoFilterManager shared] noiseFilterImageWithImage:sourceImage noise:[VideoFilterManager shared].mediaObjectView.objectChromaNoise sharp:0.1];
    [chromakeyFilter setValue:sourceImage forKey:kCIInputImageKey];
    if (asyncVideoCompositionRequest.sourceTrackIDs.count >= 2) {
        CVPixelBufferRef backgroundFrame = [asyncVideoCompositionRequest sourceFrameByTrackID:[[asyncVideoCompositionRequest.sourceTrackIDs firstObject] intValue]];
        CIImage *backgroundImage = [CIImage imageWithCVPixelBuffer:backgroundFrame];
        CIImage *foregroundImage = chromakeyFilter.outputImage;
        foregroundImage = [[VideoFilterManager shared] medianFilterImageWithImage:foregroundImage];
        //CIImage *foregroundImage = [[VideoFilterManager shared] chromakeyFilterWithImage:sourceImage red:0.0 green:1.0 blue:0.0 tolerance:[VideoFilterManager shared].mediaObjectView.objectChromaTolerance / 10.0 noise:[VideoFilterManager shared].mediaObjectView.objectChromaNoise / 10.0 edgeIntensity:1.0 opacity:1.0];
        [compositorFilter setValue:foregroundImage forKey:kCIInputImageKey];
        [compositorFilter setValue:backgroundImage forKey:kCIInputBackgroundImageKey];
        sourceImage = compositorFilter.outputImage;
    } else {
        sourceImage = chromakeyFilter.outputImage;
        sourceImage = [[VideoFilterManager shared] medianFilterImageWithImage:sourceImage];
        //sourceImage = [[VideoFilterManager shared] chromakeyFilterWithImage:sourceImage red:0.0 green:1.0 blue:0.0 tolerance:[VideoFilterManager shared].mediaObjectView.objectChromaTolerance / 10.0 noise:[VideoFilterManager shared].mediaObjectView.objectChromaNoise / 10.0 edgeIntensity:1.0 opacity:1.0];
    }
    
    CVPixelBufferRef buffer = [renderContext newPixelBuffer];
    [context render:sourceImage toCVPixelBuffer:buffer];
    [asyncVideoCompositionRequest finishWithComposedVideoFrame:buffer];
    CVPixelBufferRelease(buffer);
}

- (CIFilter *)chromaKeyFilter:(CGFloat)fromHue toHue:(CGFloat)toHue {
    // 1
    const unsigned int size = 64;
    size_t cubeDataSize = size * size * size * sizeof(float) * 4;
    float *cubeData = (float *)malloc(cubeDataSize);
    // 2
    size_t offset = 0;
    for (int z = 0; z < size; z++)
    {
        CGFloat blue = (CGFloat)(z) / (CGFloat)(size - 1);
        for (int y = 0; y < size; y++)
        {
            CGFloat green = (CGFloat)(y) / (CGFloat)(size - 1);
            for (int x = 0; x < size; x++)
            {
                CGFloat red = (CGFloat)(x) / (CGFloat)(size - 1);
                // 3
                CGFloat hue = [self getHueWith:red green:green blue:blue];
                CGFloat alpha = (hue >= fromHue && hue <= toHue) ? 0: 1;

                cubeData[offset] = red * alpha;
                cubeData[offset + 1] = green * alpha;
                cubeData[offset + 2] = blue * alpha;
                cubeData[offset + 3] = alpha;

                offset += 4;
            }
        }
    }

    NSData *data = [NSData dataWithBytes:cubeData length:cubeDataSize];
    // 5
    CIFilter *colorCubeFilter = [CIFilter filterWithName:@"CIColorCube" withInputParameters:@{@"inputCubeDimension": @(size), @"inputCubeData": data}];
    return colorCubeFilter;
}

- (CGFloat)getHueWith:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    CGFloat hue = 0;
    [color getHue:&hue saturation:nil brightness:nil alpha:nil];
    return hue;
}

@end
