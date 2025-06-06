//
//  StingerGalleryCollectionViewController.h
//  VideoFrame
//
//  Created by APPLE on 10/11/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;

#import "StingerGalleryCollectionViewCell.h"

#import "StingerGalleryPickerController.h"

@interface StingerGalleryCollectionViewController : UICollectionViewController
{
    CGFloat myCell_Size;
    NSArray* stingerNameArray;
}

@property(nonatomic, strong) StingerGalleryPickerController* stingerGalleryPickerController;

@end
