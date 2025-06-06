//
//  StingerGalleryCollectionViewCell.m
//  VideoFrame
//
//  Created by APPLE on 10/11/17.
//  Copyright © 2017 Yinjing Li. All rights reserved.
//

#import "StingerGalleryCollectionViewCell.h"

@implementation StingerGalleryCollectionViewCell

-(void) awakeFromNib
{
    self.pixelLabel.shadowColor = [UIColor blackColor];
    self.pixelLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);
    
    self.sizeLabel.shadowColor = [UIColor blackColor];
    self.sizeLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);
    
    self.durationLabel.shadowColor = [UIColor blackColor];
    self.durationLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);
    
    self.videoNameLabel.shadowColor = [UIColor blackColor];
    self.videoNameLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);
    
    self.videoNameLabel.minimumScaleFactor = 0.1f;
    self.videoNameLabel.adjustsFontSizeToFitWidth = YES;
    [super awakeFromNib];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.thumbnailImageView.image = nil;
}

@end
