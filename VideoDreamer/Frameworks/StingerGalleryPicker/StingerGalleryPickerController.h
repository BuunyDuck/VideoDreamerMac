//
//  StingerGalleryPickerController.h
//  VideoFrame
//
//  Created by APPLE on 10/11/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StingerGalleryPickerControllerDelegate;

@interface StingerGalleryPickerController : UINavigationController

@property (nonatomic, weak) id <StingerGalleryPickerControllerDelegate, UINavigationControllerDelegate> stingerGalleryPickerControllerDelegate;

@end

@protocol StingerGalleryPickerControllerDelegate <NSObject>
- (void)stingerGalleryPickerController:(StingerGalleryPickerController *)picker didFinishPickingStingerName:(NSString*)strStingerName;
- (void)stingerGalleryPickerControllerDidCancel:(StingerGalleryPickerController *)picker;
- (void)stingerGalleryPickerController:(StingerGalleryPickerController *)picker failedWithError:(NSError *)error;
@end
