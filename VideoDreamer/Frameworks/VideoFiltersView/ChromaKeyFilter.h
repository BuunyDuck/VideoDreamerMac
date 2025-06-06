//
//  ChromaKey.h
//  VideoDreamer
//
//  Created by Yinjing Li on 11/7/22.
//

#ifndef ChromaKey_h
#define ChromaKey_h

@interface ChromaKeyFilter: CIFilter
{
    CIImage *inputImage;
    CIImage *inputBackgroundImage;
    NSNumber *inputCubeDimension;
    NSNumber *inputCenterAngle;
    NSNumber *inputAngleWidth;
}

@property (retain, nonatomic) CIImage *inputImage;
@property (retain, nonatomic) CIImage *inputBackgroundImage;
@property (copy, nonatomic) NSNumber *inputCubeDimension;
@property (copy, nonatomic) NSNumber *inputCenterAngle;
@property (copy, nonatomic) NSNumber *inputAngleWidth;

@end

#endif /* ChromaKey_h */
