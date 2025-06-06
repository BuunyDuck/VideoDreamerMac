//
//  StingerGalleryCollectionViewCell.h
//  VideoFrame
//
//  Created by APPLE on 10/11/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StingerGalleryCollectionViewCell : UICollectionViewCell
{

}

@property (nonatomic, strong) IBOutlet UIImageView* thumbnailImageView;

@property (nonatomic, strong) IBOutlet UIView* grayBgView;

@property (nonatomic, strong) IBOutlet UILabel* videoNameLabel;
@property (nonatomic, strong) IBOutlet UILabel* pixelLabel;
@property (nonatomic, strong) IBOutlet UILabel* sizeLabel;
@property (nonatomic, strong) IBOutlet UILabel* durationLabel;

@end
